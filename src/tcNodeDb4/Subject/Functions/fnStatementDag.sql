CREATE FUNCTION Subject.fnStatementDag
(
    @SubjectCode nvarchar(50),
    @ParentSubjectCode nvarchar(50) = NULL
)
RETURNS TABLE
AS
RETURN
(
    WITH closure AS
    (
        SELECT
            SubjectCode,
            ParentSubjectCode,
            Depth
        FROM Subject.fnNamespaceClosure(@SubjectCode, @ParentSubjectCode)
    ),
    subjects_in_scope AS
    (
        SELECT DISTINCT
            SubjectCode
        FROM closure
    ),
    payment_data AS
    (
        SELECT
            c.SubjectCode AS SourceSubjectCode,
            c.ParentSubjectCode AS SourceParentSubjectCode,
            payment.PaidOn AS TransactedOn,
            2 AS OrderBy,
            CASE
                WHEN LEN(COALESCE(payment.PaymentReference, N'')) = 0 THEN payment.PaymentCode
                ELSE payment.PaymentReference
            END AS Reference,
            status.PaymentStatus AS StatementType,
            CASE
                WHEN payment.PaidInValue > 0 THEN payment.PaidInValue
                ELSE payment.PaidOutValue * -1
            END AS Charge
        FROM Cash.tbPayment AS payment
            JOIN closure AS c
                ON c.SubjectCode = payment.SubjectCode
               AND ISNULL(c.ParentSubjectCode, N'') = ISNULL(payment.ParentSubjectCode, N'')
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
            SourceSubjectCode,
            SourceParentSubjectCode,
            TransactedOn,
            OrderBy,
            Reference,
            StatementType,
            SUM(Charge) AS Charge
        FROM payment_data
        GROUP BY
            SourceSubjectCode,
            SourceParentSubjectCode,
            TransactedOn,
            OrderBy,
            Reference,
            StatementType
    ),
    invoices AS
    (
        SELECT
            c.SubjectCode AS SourceSubjectCode,
            c.ParentSubjectCode AS SourceParentSubjectCode,
            invoice.InvoicedOn AS TransactedOn,
            1 AS OrderBy,
            invoice.InvoiceNumber AS Reference,
            type.InvoiceType AS StatementType,
            CASE type.CashPolarityCode
                WHEN 0 THEN invoice.InvoiceValue + invoice.TaxValue
                WHEN 1 THEN (invoice.InvoiceValue + invoice.TaxValue) * -1
            END AS Charge
        FROM Invoice.tbInvoice AS invoice
            JOIN closure AS c
                ON c.SubjectCode = invoice.SubjectCode
               AND ISNULL(c.ParentSubjectCode, N'') = ISNULL(invoice.ParentSubjectCode, N'')
            JOIN Invoice.tbType AS type
                ON invoice.InvoiceTypeCode = type.InvoiceTypeCode
    ),
    transactions_union AS
    (
        SELECT
            SourceSubjectCode,
            SourceParentSubjectCode,
            TransactedOn,
            OrderBy,
            Reference,
            StatementType,
            Charge
        FROM payments

        UNION ALL

        SELECT
            SourceSubjectCode,
            SourceParentSubjectCode,
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
            CAST(@SubjectCode AS nvarchar(50)) AS SubjectCode,
            CAST(@ParentSubjectCode AS nvarchar(50)) AS ParentSubjectCode,
            ROW_NUMBER() OVER
            (
                ORDER BY
                    TransactedOn,
                    OrderBy,
                    Reference,
                    SourceParentSubjectCode,
                    SourceSubjectCode
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
            CAST(@SubjectCode AS nvarchar(50)) AS SubjectCode,
            CAST(@ParentSubjectCode AS nvarchar(50)) AS ParentSubjectCode,
            0 AS RowNumber,
            COALESCE(MIN(subject.InsertedOn), GETDATE()) AS TransactedOn,
            CAST(NULL AS nvarchar(50)) AS Reference,
            CAST
            (
                (
                    SELECT Message
                    FROM App.tbText
                    WHERE TextId = 3005
                ) AS nvarchar(30)
            ) AS StatementType,
            COALESCE(SUM(subject.OpeningBalance), 0) AS Charge
        FROM subjects_in_scope AS scope
            JOIN Subject.tbSubject AS subject
                ON subject.SubjectCode = scope.SubjectCode
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

        UNION ALL

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
                    LEAD(TransactedOn) OVER (ORDER BY RowNumber),
                    TransactedOn
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
                ORDER BY RowNumber
                ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
            ) AS float
        ) AS Balance
    FROM statement_data
);
GO
