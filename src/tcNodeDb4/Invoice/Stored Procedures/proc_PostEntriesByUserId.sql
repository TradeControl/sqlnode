CREATE PROCEDURE Invoice.proc_PostEntriesByUserId
(
    @UserId nvarchar(10)
)
AS
BEGIN
    SET NOCOUNT, XACT_ABORT ON;

    DECLARE
        @SubjectCode nvarchar(50),
        @ParentSubjectCode nvarchar(50),
        @InvoiceTypeCode smallint,
        @InvoicedOn datetime,
        @InvoiceNumber nvarchar(20),
        @ParentCount int,
        @DefaultParentCount int;

    BEGIN TRY
        DECLARE c1 CURSOR LOCAL FAST_FORWARD FOR
            SELECT
                entry.SubjectCode,
                entry.ParentSubjectCode,
                entry.InvoiceTypeCode,
                entry.InvoicedOn
            FROM Invoice.tbEntry entry
            WHERE entry.UserId = @UserId
            GROUP BY
                entry.SubjectCode,
                entry.ParentSubjectCode,
                entry.InvoiceTypeCode,
                entry.InvoicedOn
            ORDER BY
                entry.SubjectCode,
                entry.ParentSubjectCode,
                entry.InvoiceTypeCode,
                entry.InvoicedOn;

        OPEN c1;

        BEGIN TRAN;

        FETCH NEXT FROM c1 INTO @SubjectCode, @ParentSubjectCode, @InvoiceTypeCode, @InvoicedOn;

        WHILE @@FETCH_STATUS = 0
        BEGIN
            SET @ParentSubjectCode = NULLIF(LTRIM(RTRIM(@ParentSubjectCode)), N'');
            SET @ParentCount = 0;
            SET @DefaultParentCount = 0;

            IF @ParentSubjectCode IS NULL
            BEGIN
                SELECT @ParentCount = COUNT(*)
                FROM Subject.tbNamespace
                WHERE ChildSubjectCode = @SubjectCode;

                IF ISNULL(@ParentCount, 0) = 0
                BEGIN
                    SET @ParentSubjectCode = NULL;
                END
                ELSE IF @ParentCount = 1
                BEGIN
                    SELECT @ParentSubjectCode = ParentSubjectCode
                    FROM Subject.tbNamespace
                    WHERE ChildSubjectCode = @SubjectCode;
                END
                ELSE
                BEGIN
                    SELECT @DefaultParentCount = COUNT(*)
                    FROM Subject.tbNamespace
                    WHERE ChildSubjectCode = @SubjectCode
                      AND IsDefault = 1;

                    IF @DefaultParentCount = 1
                    BEGIN
                        SELECT @ParentSubjectCode = ParentSubjectCode
                        FROM Subject.tbNamespace
                        WHERE ChildSubjectCode = @SubjectCode
                          AND IsDefault = 1;
                    END
                    ELSE
                    BEGIN
                        RAISERROR('A namespace must be selected for the invoice subject.', 16, 1);
                    END
                END
            END;

            EXEC Invoice.proc_RaiseBlank
                @SubjectCode,
                @InvoiceTypeCode,
                @InvoiceNumber OUTPUT,
                @ParentSubjectCode;

            UPDATE invoice_header
            SET
                UserId = @UserId,
                InvoicedOn = @InvoicedOn,
                Printed = CASE WHEN @InvoiceTypeCode < 2 THEN 0 ELSE 1 END
            FROM Invoice.tbInvoice invoice_header
            WHERE invoice_header.InvoiceNumber = @InvoiceNumber;

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
              AND SubjectCode = @SubjectCode
              AND InvoiceTypeCode = @InvoiceTypeCode
              AND InvoicedOn = @InvoicedOn
              AND (
                    (ParentSubjectCode IS NULL AND @ParentSubjectCode IS NULL)
                    OR ParentSubjectCode = @ParentSubjectCode
                  );

            EXEC Invoice.proc_Accept @InvoiceNumber;

            FETCH NEXT FROM c1 INTO @SubjectCode, @ParentSubjectCode, @InvoiceTypeCode, @InvoicedOn;
        END;

        DELETE FROM Invoice.tbEntry
        WHERE UserId = @UserId;

        COMMIT TRAN;

        CLOSE c1;
        DEALLOCATE c1;
    END TRY
    BEGIN CATCH
        EXEC App.proc_ErrorLog;
    END CATCH
END
