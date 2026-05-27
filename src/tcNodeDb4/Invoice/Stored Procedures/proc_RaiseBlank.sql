CREATE PROCEDURE Invoice.proc_RaiseBlank
(
    @SubjectCode nvarchar(50),
    @InvoiceTypeCode smallint,
    @InvoiceNumber nvarchar(20) = NULL OUTPUT,
    @ParentSubjectCode nvarchar(50) = NULL
)
AS
    SET NOCOUNT, XACT_ABORT ON;

    BEGIN TRY
        DECLARE
            @UserId nvarchar(10),
            @NextNumber int,
            @InvoiceSuffix nvarchar(4),
            @InvoicedOn datetime,
            @ParentCount int;

        SELECT @UserId = UserId
        FROM Usr.vwCredentials;

        SET @InvoiceSuffix = N'.' + @UserId;
        SET @ParentSubjectCode = NULLIF(LTRIM(RTRIM(@ParentSubjectCode)), N'');

        IF @ParentSubjectCode IS NULL
        BEGIN
            SELECT @ParentCount = COUNT(*)
            FROM Subject.tbNamespace
            WHERE ChildSubjectCode = @SubjectCode;

            IF @ParentCount = 1
            BEGIN
                SELECT @ParentSubjectCode = ParentSubjectCode
                FROM Subject.tbNamespace
                WHERE ChildSubjectCode = @SubjectCode;
            END
            ELSE IF @ParentCount > 1
            BEGIN
                RAISERROR('A namespace must be selected for the invoice subject.', 16, 1);
            END
        END
        ELSE IF NOT EXISTS
        (
            SELECT 1
            FROM Subject.tbNamespace
            WHERE ParentSubjectCode = @ParentSubjectCode
              AND ChildSubjectCode = @SubjectCode
        )
        BEGIN
            RAISERROR('The supplied namespace could not be resolved for the invoice subject.', 16, 1);
        END;

        SELECT @NextNumber = NextNumber
        FROM Invoice.tbType
        WHERE InvoiceTypeCode = @InvoiceTypeCode;

        SELECT @InvoiceNumber = FORMAT(@NextNumber, '000000') + @InvoiceSuffix;

        WHILE EXISTS
        (
            SELECT 1
            FROM Invoice.tbInvoice
            WHERE InvoiceNumber = @InvoiceNumber
        )
        BEGIN
            SET @NextNumber = @NextNumber + 1;
            SET @InvoiceNumber = FORMAT(@NextNumber, '000000') + @InvoiceSuffix;
        END;

        SET @InvoicedOn = CAST(CURRENT_TIMESTAMP AS date);

        BEGIN TRANSACTION;

        EXEC Invoice.proc_Cancel;

        UPDATE Invoice.tbType
        SET NextNumber = @NextNumber + 1
        WHERE InvoiceTypeCode = @InvoiceTypeCode;

        INSERT INTO Invoice.tbInvoice
        (
            InvoiceNumber,
            UserId,
            SubjectCode,
            ParentSubjectCode,
            InvoiceTypeCode,
            InvoicedOn,
            InvoiceStatusCode,
            PaymentTerms
        )
        SELECT
            @InvoiceNumber,
            @UserId,
            @SubjectCode,
            @ParentSubjectCode,
            @InvoiceTypeCode,
            @InvoicedOn,
            0,
            subject.PaymentTerms
        FROM Subject.tbSubject AS subject
        WHERE subject.SubjectCode = @SubjectCode;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        EXEC App.proc_ErrorLog;
    END CATCH
