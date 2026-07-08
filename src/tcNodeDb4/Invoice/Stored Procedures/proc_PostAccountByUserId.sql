CREATE PROCEDURE Invoice.proc_PostAccountByUserId
(
    @UserId nvarchar(10),
    @SubjectCode nvarchar(50),
    @ParentSubjectCode nvarchar(50) = NULL
)
AS
BEGIN
    SET NOCOUNT, XACT_ABORT ON;

    DECLARE
        @InvoiceTypeCode smallint,
        @InvoiceNumber nvarchar(20),
        @ResolvedParentSubjectCode nvarchar(50),
        @ParentCount int,
        @DefaultParentCount int;

    BEGIN TRY
        SET @ParentSubjectCode = NULLIF(LTRIM(RTRIM(@ParentSubjectCode)), N'');

        IF @ParentSubjectCode IS NULL
        BEGIN
            SELECT TOP (1) @ParentSubjectCode = NULLIF(LTRIM(RTRIM(ParentSubjectCode)), N'')
            FROM Invoice.tbEntry
            WHERE UserId = @UserId
              AND SubjectCode = @SubjectCode
              AND ParentSubjectCode IS NOT NULL;

            IF @ParentSubjectCode IS NULL
            BEGIN
                SELECT @ParentCount = COUNT(*)
                FROM Subject.tbNamespace
                WHERE ChildSubjectCode = @SubjectCode;

                IF ISNULL(@ParentCount, 0) = 0
                BEGIN
                    SET @ResolvedParentSubjectCode = NULL;
                END
                ELSE IF @ParentCount = 1
                BEGIN
                    SELECT @ResolvedParentSubjectCode = ParentSubjectCode
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
                        SELECT @ResolvedParentSubjectCode = ParentSubjectCode
                        FROM Subject.tbNamespace
                        WHERE ChildSubjectCode = @SubjectCode
                          AND IsDefault = 1;
                    END
                    ELSE
                    BEGIN
                        RAISERROR('A namespace must be selected for the invoice subject.', 16, 1);
                    END
                END
            END
            ELSE
            BEGIN
                SET @ResolvedParentSubjectCode = @ParentSubjectCode;
            END
        END
        ELSE
        BEGIN
            IF NOT EXISTS
            (
                SELECT 1
                FROM Subject.tbNamespace
                WHERE ParentSubjectCode = @ParentSubjectCode
                  AND ChildSubjectCode = @SubjectCode
            )
            BEGIN
                RAISERROR('The supplied namespace could not be resolved for the invoice subject.', 16, 1);
            END;

            SET @ResolvedParentSubjectCode = @ParentSubjectCode;
        END;

        DECLARE c1 CURSOR LOCAL FAST_FORWARD FOR
            SELECT InvoiceTypeCode
            FROM Invoice.tbEntry
            WHERE UserId = @UserId
              AND SubjectCode = @SubjectCode
              AND (
                    (ParentSubjectCode IS NULL AND @ResolvedParentSubjectCode IS NULL)
                    OR ParentSubjectCode = @ResolvedParentSubjectCode
                  )
            GROUP BY InvoiceTypeCode;

        OPEN c1;

        BEGIN TRAN;

        FETCH NEXT FROM c1 INTO @InvoiceTypeCode;

        WHILE @@FETCH_STATUS = 0
        BEGIN
            EXEC Invoice.proc_RaiseBlank
                @SubjectCode,
                @InvoiceTypeCode,
                @InvoiceNumber OUTPUT,
                @ResolvedParentSubjectCode;

            WITH invoice_entry AS
            (
                SELECT @InvoiceNumber AS InvoiceNumber, MIN(InvoicedOn) AS InvoicedOn
                FROM Invoice.tbEntry
                WHERE UserId = @UserId
                  AND SubjectCode = @SubjectCode
                  AND InvoiceTypeCode = @InvoiceTypeCode
                  AND (
                        (ParentSubjectCode IS NULL AND @ResolvedParentSubjectCode IS NULL)
                        OR ParentSubjectCode = @ResolvedParentSubjectCode
                      )
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
              AND SubjectCode = @SubjectCode
              AND InvoiceTypeCode = @InvoiceTypeCode
              AND (
                    (ParentSubjectCode IS NULL AND @ResolvedParentSubjectCode IS NULL)
                    OR ParentSubjectCode = @ResolvedParentSubjectCode
                  );

            EXEC Invoice.proc_Accept @InvoiceNumber;

            FETCH NEXT FROM c1 INTO @InvoiceTypeCode;
        END;

        DELETE FROM Invoice.tbEntry
        WHERE UserId = @UserId
          AND SubjectCode = @SubjectCode
          AND (
                (ParentSubjectCode IS NULL AND @ResolvedParentSubjectCode IS NULL)
                OR ParentSubjectCode = @ResolvedParentSubjectCode
              );

        COMMIT TRAN;

        CLOSE c1;
        DEALLOCATE c1;
    END TRY
    BEGIN CATCH
        EXEC App.proc_ErrorLog;
    END CATCH
END
