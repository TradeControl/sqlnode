CREATE FUNCTION Subject.fnDatedBalances
(
    @AsOfDate date
)
RETURNS TABLE
AS
RETURN
(
    WITH eligible_subjects AS
    (
        SELECT
            subject.SubjectCode,
            subject.SubjectName,
            subject.InsertedOn,
            subject.OpeningBalance
        FROM Subject.tbSubject AS subject
            JOIN Subject.tbType AS subject_type
                ON subject.SubjectTypeCode = subject_type.SubjectTypeCode
        WHERE subject_type.SubjectClassCode <> 2
    ),
    first_transactions AS
    (
        SELECT
            transaction_date.SubjectCode,
            MIN(transaction_date.TransactedOn) AS FirstTransactedOn
        FROM
        (
            SELECT invoice.SubjectCode, invoice.InvoicedOn AS TransactedOn
            FROM Invoice.tbInvoice AS invoice

            UNION ALL

            SELECT payment.SubjectCode, payment.PaidOn AS TransactedOn
            FROM Cash.tbPayment AS payment
                JOIN Subject.tbAccount AS account
                    ON payment.AccountCode = account.AccountCode
            WHERE account.AccountTypeCode < 2
              AND payment.PaymentStatusCode = 1
        ) AS transaction_date
        GROUP BY transaction_date.SubjectCode
    ),
    statement_movements AS
    (
        SELECT
            subject.SubjectCode,
            CAST(subject.OpeningBalance AS decimal(38, 5)) AS Charge
        FROM eligible_subjects AS subject
            LEFT JOIN first_transactions AS first_transaction
                ON subject.SubjectCode = first_transaction.SubjectCode
        WHERE CAST
        (
            COALESCE
            (
                DATEADD(DAY, -1, first_transaction.FirstTransactedOn),
                subject.InsertedOn
            )
            AS date
        ) <= @AsOfDate

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
        WHERE invoice.InvoicedOn < DATEADD(DAY, 1, @AsOfDate)

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
          AND payment.PaidOn < DATEADD(DAY, 1, @AsOfDate)
    ),
    balances AS
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
        HAVING COALESCE(SUM(movement.Charge), 0) <> 0
    )
    SELECT
        balance.SubjectCode,
        balance.SubjectName,
        CAST(@AsOfDate AS date) AS AsOfDate,
        balance.NativeStatementBalance,
        CAST(balance.NativeStatementBalance * -1 AS decimal(18, 5)) AS BusinessBalance,
        CAST(CASE WHEN balance.NativeStatementBalance < 0 THEN 0 ELSE 1 END AS smallint) AS PositionCode,
        CAST(ABS(balance.NativeStatementBalance) AS decimal(18, 5)) AS HumanBalance
    FROM balances AS balance
);
GO
