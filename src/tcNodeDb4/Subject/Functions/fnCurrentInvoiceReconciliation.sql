CREATE FUNCTION Subject.fnCurrentInvoiceReconciliation()
RETURNS TABLE
AS
RETURN
(
    WITH eligible_subjects AS
    (
        SELECT
            subject.SubjectCode,
            subject.SubjectName,
            subject.OpeningBalance
        FROM Subject.tbSubject AS subject
            JOIN Subject.tbType AS subject_type
                ON subject.SubjectTypeCode = subject_type.SubjectTypeCode
        WHERE subject_type.SubjectClassCode <> 2
    ),
    statement_movements AS
    (
        SELECT
            subject.SubjectCode,
            CAST(subject.OpeningBalance AS decimal(38, 5)) AS Charge
        FROM eligible_subjects AS subject

        UNION ALL

        SELECT
            invoice.SubjectCode,
            CAST
            (
                CASE invoice_type.CashPolarityCode
                    WHEN 0 THEN invoice.InvoiceValue + invoice.TaxValue
                    WHEN 1 THEN (invoice.InvoiceValue + invoice.TaxValue) * -1
                END
                AS decimal(38, 5)
            ) AS Charge
        FROM Invoice.tbInvoice AS invoice
            JOIN Invoice.tbType AS invoice_type
                ON invoice.InvoiceTypeCode = invoice_type.InvoiceTypeCode
            JOIN eligible_subjects AS subject
                ON invoice.SubjectCode = subject.SubjectCode

        UNION ALL

        SELECT
            payment.SubjectCode,
            CAST
            (
                CASE
                    WHEN payment.PaidInValue > 0 THEN payment.PaidInValue
                    ELSE payment.PaidOutValue * -1
                END
                AS decimal(38, 5)
            ) AS Charge
        FROM Cash.tbPayment AS payment
            JOIN Subject.tbAccount AS account
                ON payment.AccountCode = account.AccountCode
            JOIN eligible_subjects AS subject
                ON payment.SubjectCode = subject.SubjectCode
        WHERE account.AccountTypeCode < 2
          AND payment.PaymentStatusCode = 1
    ),
    statement_balances AS
    (
        SELECT
            subject.SubjectCode,
            subject.SubjectName,
            CAST(COALESCE(SUM(movement.Charge), 0) AS decimal(18, 5)) AS NativeStatementBalance
        FROM eligible_subjects AS subject
            LEFT JOIN statement_movements AS movement
                ON subject.SubjectCode = movement.SubjectCode
        GROUP BY
            subject.SubjectCode,
            subject.SubjectName
    ),
    open_invoices AS
    (
        SELECT
            item.SubjectCode,
            CAST(SUM(item.BusinessAmount) AS decimal(18, 5)) AS OpenInvoiceBusinessBalance
        FROM Subject.fnCurrentAgedInvoiceItems(CAST(GETDATE() AS date)) AS item
        GROUP BY item.SubjectCode
    )
    SELECT
        statement.SubjectCode,
        statement.SubjectName,
        statement.NativeStatementBalance,
        CAST(statement.NativeStatementBalance * -1 AS decimal(18, 5)) AS StatementBusinessBalance,
        CAST(COALESCE(invoice.OpenInvoiceBusinessBalance, 0) AS decimal(18, 5)) AS OpenInvoiceBusinessBalance,
        CAST
        (
            (statement.NativeStatementBalance * -1)
            - COALESCE(invoice.OpenInvoiceBusinessBalance, 0)
            AS decimal(18, 5)
        ) AS ReconciliationResidual
    FROM statement_balances AS statement
        LEFT JOIN open_invoices AS invoice
            ON statement.SubjectCode = invoice.SubjectCode
    WHERE statement.NativeStatementBalance <> 0
       OR COALESCE(invoice.OpenInvoiceBusinessBalance, 0) <> 0
);
GO
