CREATE VIEW Subject.vwBalanceOutstanding
AS
    WITH invoices_unpaid AS
    (
        SELECT
            invoice.SubjectCode,
            invoice.ParentSubjectCode,
            CASE type.CashPolarityCode
                WHEN 0 THEN ((invoice.InvoiceValue + invoice.TaxValue) - (invoice.PaidValue + invoice.PaidTaxValue)) * -1
                WHEN 1 THEN (invoice.InvoiceValue + invoice.TaxValue) - (invoice.PaidValue + invoice.PaidTaxValue)
            END AS OutstandingValue
        FROM Invoice.tbInvoice AS invoice
            INNER JOIN Invoice.tbType AS type
                ON invoice.InvoiceTypeCode = type.InvoiceTypeCode
        WHERE invoice.InvoiceStatusCode > 0
          AND invoice.InvoiceStatusCode < 3
    ),
    current_balance AS
    (
        SELECT
            SubjectCode,
            ParentSubjectCode,
            SUM(OutstandingValue) AS Balance
        FROM invoices_unpaid
        GROUP BY
            SubjectCode,
            ParentSubjectCode
    ),
    subject_instances AS
    (
        SELECT
            ns.ChildSubjectCode AS SubjectCode,
            ns.ParentSubjectCode
        FROM Subject.tbNamespace AS ns

        UNION

        SELECT
            subject.SubjectCode,
            CAST(NULL AS nvarchar(50)) AS ParentSubjectCode
        FROM Subject.tbSubject AS subject
        WHERE NOT EXISTS
        (
            SELECT 1
            FROM Subject.tbNamespace AS ns
            WHERE ns.ChildSubjectCode = subject.SubjectCode
        )
    )
    SELECT
        instance.SubjectCode,
        instance.ParentSubjectCode,
        ISNULL(balance.Balance, 0) AS Balance
    FROM subject_instances AS instance
        LEFT OUTER JOIN current_balance AS balance
            ON instance.SubjectCode = balance.SubjectCode
           AND
           (
               instance.ParentSubjectCode = balance.ParentSubjectCode
               OR
               (
                   instance.ParentSubjectCode IS NULL
                   AND balance.ParentSubjectCode IS NULL
               )
           );
