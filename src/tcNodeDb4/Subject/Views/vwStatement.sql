CREATE VIEW Subject.vwStatement
AS
    WITH payment_data AS
    (
        SELECT
            payment.SubjectCode,
            payment.ParentSubjectCode,
            payment.PaidOn AS TransactedOn,
            2 AS OrderBy,
            CASE
                WHEN LEN(COALESCE(payment.PaymentReference, '')) = 0 THEN payment.PaymentCode
                ELSE payment.PaymentReference
            END AS Reference,
            status.PaymentStatus AS StatementType,
            CASE
                WHEN payment.PaidInValue > 0 THEN payment.PaidInValue
                ELSE payment.PaidOutValue * -1
            END AS Charge
        FROM Cash.tbPayment AS payment
            JOIN Subject.tbAccount AS account
                ON payment.AccountCode = account.AccountCode
            JOIN Cash.tbPaymentStatus AS status
                ON payment.PaymentStatusCode = status.PaymentStatusCode
        WHERE account.AccountTypeCode < 2
          AND payment.PaymentStatusCode = 1
    ),
    payments AS
    (
        SELECT
            SubjectCode,
            ParentSubjectCode,
            TransactedOn,
            OrderBy,
            Reference,
            StatementType,
            SUM(Charge) AS Charge
        FROM payment_data
        GROUP BY
            SubjectCode,
            ParentSubjectCode,
            TransactedOn,
            OrderBy,
            Reference,
            StatementType
    ),
    invoices AS
    (
        SELECT
            invoice.SubjectCode,
            invoice.ParentSubjectCode,
            invoice.InvoicedOn AS TransactedOn,
            1 AS OrderBy,
            invoice.InvoiceNumber AS Reference,
            type.InvoiceType AS StatementType,
            CASE type.CashPolarityCode
                WHEN 0 THEN invoice.InvoiceValue + invoice.TaxValue
                WHEN 1 THEN (invoice.InvoiceValue + invoice.TaxValue) * -1
            END AS Charge
        FROM Invoice.tbInvoice AS invoice
            JOIN Invoice.tbType AS type
                ON invoice.InvoiceTypeCode = type.InvoiceTypeCode
    ),
    transactions_union AS
    (
        SELECT
            SubjectCode,
            ParentSubjectCode,
            TransactedOn,
            OrderBy,
            Reference,
            StatementType,
            Charge
        FROM payments

        UNION ALL

        SELECT
            SubjectCode,
            ParentSubjectCode,
            TransactedOn,
            OrderBy,
            Reference,
            StatementType,
            Charge
        FROM invoices
    ),
    transactions AS
    (
        SELECT
            SubjectCode,
            ParentSubjectCode,
            ROW_NUMBER() OVER
            (
                PARTITION BY SubjectCode, ParentSubjectCode
                ORDER BY TransactedOn, OrderBy, Reference
            ) AS RowNumber,
            TransactedOn,
            Reference,
            StatementType,
            Charge
        FROM transactions_union
    ),
    opening_balance AS
    (
        SELECT
            subject.SubjectCode,
            CAST(NULL AS nvarchar(50)) AS ParentSubjectCode,
            0 AS RowNumber,
            subject.InsertedOn AS TransactedOn,
            NULL AS Reference,
            (SELECT CAST(Message AS nvarchar) FROM App.tbText WHERE TextId = 3005) AS StatementType,
            subject.OpeningBalance AS Charge
        FROM Subject.tbSubject AS subject
    ),
    statement_data AS
    (
        SELECT
            SubjectCode,
            ParentSubjectCode,
            RowNumber,
            TransactedOn,
            Reference,
            StatementType,
            Charge
        FROM transactions

        UNION

        SELECT
            SubjectCode,
            ParentSubjectCode,
            RowNumber,
            TransactedOn,
            Reference,
            StatementType,
            Charge
        FROM opening_balance
    )
    SELECT
        SubjectCode,
        ParentSubjectCode,
        CAST(RowNumber AS int) AS RowNumber,
        CASE RowNumber
            WHEN 0 THEN DATEADD
            (
                DAY,
                -1,
                COALESCE
                (
                    LEAD(TransactedOn) OVER
                    (
                        PARTITION BY SubjectCode, ParentSubjectCode
                        ORDER BY RowNumber
                    ),
                    0
                )
            )
            ELSE TransactedOn
        END AS TransactedOn,
        Reference,
        StatementType,
        CAST(Charge AS float) AS Charge,
        CAST
        (
            SUM(Charge) OVER
            (
                PARTITION BY SubjectCode, ParentSubjectCode
                ORDER BY RowNumber
                ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
            ) AS float
        ) AS Balance
    FROM statement_data;
