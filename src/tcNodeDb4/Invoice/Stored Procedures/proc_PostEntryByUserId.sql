CREATE PROCEDURE Invoice.proc_PostEntryByUserId
(
    @UserId nvarchar(10),
    @EntryId nvarchar(20),
    @ParentSubjectCode nvarchar(50) = NULL
)
AS
BEGIN
    SET NOCOUNT, XACT_ABORT ON;

    BEGIN TRY
        DECLARE
            @SubjectCode nvarchar(50),
            @CashCode nvarchar(50),
            @InvoiceTypeCode smallint,
            @InvoiceNumber nvarchar(20);

        SET @ParentSubjectCode = NULLIF(LTRIM(RTRIM(@ParentSubjectCode)), N'');

        SELECT
            @SubjectCode = SubjectCode,
            @CashCode = CashCode,
            @InvoiceTypeCode = InvoiceTypeCode,
            @ParentSubjectCode = COALESCE(NULLIF(LTRIM(RTRIM(ParentSubjectCode)), N''), @ParentSubjectCode)
        FROM Invoice.tbEntry
        WHERE UserId = @UserId
          AND EntryId = @EntryId;

        IF @InvoiceTypeCode IS NULL
            RAISERROR('The pending invoice entry was not found.', 16, 1);

        BEGIN TRAN;

        EXEC Invoice.proc_RaiseBlank
            @SubjectCode,
            @InvoiceTypeCode,
            @InvoiceNumber OUTPUT,
            @ParentSubjectCode;

        WITH invoice_entry AS
        (
            SELECT @InvoiceNumber AS InvoiceNumber, InvoicedOn
            FROM Invoice.tbEntry
            WHERE UserId = @UserId
              AND EntryId = @EntryId
        )
        UPDATE invoice_header
        SET
            UserId = @UserId,
            InvoicedOn = invoice_entry.InvoicedOn,
            Printed = CASE WHEN @InvoiceTypeCode < 2 THEN 0 ELSE 1 END
        FROM Invoice.tbInvoice invoice_header
        JOIN invoice_entry
            ON invoice_header.InvoiceNumber = invoice_entry.InvoiceNumber;

        INSERT INTO Invoice.tbItem (InvoiceNumber, CashCode, TaxCode, ItemReference, TotalValue, InvoiceValue)
        SELECT
            @InvoiceNumber,
            CashCode,
            TaxCode,
            ItemReference,
            TotalValue,
            InvoiceValue
        FROM Invoice.tbEntry
        WHERE UserId = @UserId
          AND EntryId = @EntryId;

        EXEC Invoice.proc_Accept @InvoiceNumber;

        DELETE FROM Invoice.tbEntry
        WHERE UserId = @UserId
          AND EntryId = @EntryId;

        COMMIT TRAN;
    END TRY
    BEGIN CATCH
        EXEC App.proc_ErrorLog;
    END CATCH
END
