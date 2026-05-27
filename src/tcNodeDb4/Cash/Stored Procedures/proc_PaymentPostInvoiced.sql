CREATE PROCEDURE Cash.proc_PaymentPostInvoiced
    @PaymentCode nvarchar(20)
AS
    SET NOCOUNT, XACT_ABORT ON;

    BEGIN TRY
        DECLARE
            @SubjectCode nvarchar(50),
            @ParentSubjectCode nvarchar(50),
            @PostValue decimal(18, 5),
            @CashCode nvarchar(50);

        SELECT
            @PostValue = CASE
                WHEN payment.PaidInValue = 0 THEN payment.PaidOutValue
                ELSE payment.PaidInValue * -1
            END,
            @SubjectCode = payment.SubjectCode,
            @ParentSubjectCode = payment.ParentSubjectCode
        FROM Cash.tbPayment AS payment
        WHERE payment.PaymentCode = @PaymentCode;

        IF NOT EXISTS
        (
            SELECT 1
            FROM Invoice.tbInvoice AS invoice
            WHERE invoice.InvoiceStatusCode BETWEEN 1 AND 2
              AND invoice.SubjectCode = @SubjectCode
              AND
              (
                  invoice.ParentSubjectCode = @ParentSubjectCode
                  OR
                  (
                      invoice.ParentSubjectCode IS NULL
                      AND @ParentSubjectCode IS NULL
                  )
              )
        )
            RETURN;

        IF EXISTS
        (
            SELECT 1
            FROM Invoice.tbInvoice AS invoice
                JOIN Invoice.tbProject AS project
                    ON invoice.InvoiceNumber = project.InvoiceNumber
            WHERE invoice.SubjectCode = @SubjectCode
              AND
              (
                  invoice.ParentSubjectCode = @ParentSubjectCode
                  OR
                  (
                      invoice.ParentSubjectCode IS NULL
                      AND @ParentSubjectCode IS NULL
                  )
              )
              AND invoice.InvoiceStatusCode < 3
        )
        BEGIN
            SELECT
                @CashCode = project.CashCode
            FROM Invoice.tbInvoice AS invoice
                JOIN Invoice.tbProject AS project
                    ON invoice.InvoiceNumber = project.InvoiceNumber
            WHERE invoice.SubjectCode = @SubjectCode
              AND
              (
                  invoice.ParentSubjectCode = @ParentSubjectCode
                  OR
                  (
                      invoice.ParentSubjectCode IS NULL
                      AND @ParentSubjectCode IS NULL
                  )
              )
              AND invoice.InvoiceStatusCode < 3
            GROUP BY project.CashCode;
        END
        ELSE IF EXISTS
        (
            SELECT 1
            FROM Invoice.tbInvoice AS invoice
                JOIN Invoice.tbItem AS item
                    ON invoice.InvoiceNumber = item.InvoiceNumber
            WHERE invoice.SubjectCode = @SubjectCode
              AND
              (
                  invoice.ParentSubjectCode = @ParentSubjectCode
                  OR
                  (
                      invoice.ParentSubjectCode IS NULL
                      AND @ParentSubjectCode IS NULL
                  )
              )
              AND invoice.InvoiceStatusCode < 3
            GROUP BY item.CashCode
        )
        BEGIN
            SELECT
                @CashCode = item.CashCode
            FROM Invoice.tbInvoice AS invoice
                JOIN Invoice.tbItem AS item
                    ON invoice.InvoiceNumber = item.InvoiceNumber
            WHERE invoice.SubjectCode = @SubjectCode
              AND
              (
                  invoice.ParentSubjectCode = @ParentSubjectCode
                  OR
                  (
                      invoice.ParentSubjectCode IS NULL
                      AND @ParentSubjectCode IS NULL
                  )
              )
              AND invoice.InvoiceStatusCode < 3
            GROUP BY item.CashCode;
        END;

        BEGIN TRANSACTION;

        UPDATE Cash.tbPayment
        SET
            PaymentStatusCode = 1,
            CashCode = @CashCode
        WHERE PaymentCode = @PaymentCode;

        WITH invoice_status AS
        (
            SELECT
                InvoiceNumber,
                InvoiceStatusCode,
                PaidValue,
                PaidTaxValue
            FROM Invoice.vwStatusLive
            WHERE SubjectCode = @SubjectCode
              AND
              (
                  ParentSubjectCode = @ParentSubjectCode
                  OR
                  (
                      ParentSubjectCode IS NULL
                      AND @ParentSubjectCode IS NULL
                  )
              )
        )
        UPDATE invoice
        SET
            InvoiceStatusCode = invoice_status.InvoiceStatusCode,
            PaidValue = invoice_status.PaidValue,
            PaidTaxValue = invoice_status.PaidTaxValue
        FROM Invoice.tbInvoice AS invoice
            JOIN invoice_status
                ON invoice.InvoiceNumber = invoice_status.InvoiceNumber
        WHERE invoice.SubjectCode = @SubjectCode
          AND
          (
              invoice.ParentSubjectCode = @ParentSubjectCode
              OR
              (
                  invoice.ParentSubjectCode IS NULL
                  AND @ParentSubjectCode IS NULL
              )
          )
          AND
          (
              invoice.InvoiceStatusCode <> invoice_status.InvoiceStatusCode
              OR invoice.PaidValue <> invoice_status.PaidValue
              OR invoice.PaidTaxValue <> invoice_status.PaidTaxValue
          );

        UPDATE account
        SET account.CurrentBalance = account.CurrentBalance + (@PostValue * -1)
        FROM Subject.tbAccount AS account
            JOIN Cash.tbPayment AS payment
                ON account.AccountCode = payment.AccountCode
        WHERE payment.PaymentCode = @PaymentCode;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        EXEC App.proc_ErrorLog;
    END CATCH
