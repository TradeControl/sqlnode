CREATE VIEW Invoice.vwStatusLive
AS
    WITH nonzero_balance_subjects AS
    (
        SELECT
            SubjectCode,
            ParentSubjectCode,
            ABS(Balance) AS Balance,
            CASE
                WHEN Balance > 0 THEN 0
                ELSE 1
            END AS CashPolarityCode
        FROM Subject.vwCurrentBalance
    ),
    paid_invoices AS
    (
        SELECT
            balance.SubjectCode,
            balance.ParentSubjectCode,
            invoices.InvoiceNumber,
            3 AS InvoiceStatusCode,
            invoices.TotalPaid,
            invoices.TaxRate
        FROM nonzero_balance_subjects AS balance
            CROSS APPLY
            (
                SELECT
                    invoice.InvoiceNumber,
                    invoice.InvoiceValue + invoice.TaxValue AS TotalPaid,
                    invoice.TaxValue / CASE invoice.InvoiceValue WHEN 0 THEN 1 ELSE invoice.InvoiceValue END AS TaxRate
                FROM Invoice.tbInvoice AS invoice
                    JOIN Invoice.tbType AS type
                        ON invoice.InvoiceTypeCode = type.InvoiceTypeCode
                WHERE invoice.SubjectCode = balance.SubjectCode
                  AND
                  (
                      invoice.ParentSubjectCode = balance.ParentSubjectCode
                      OR
                      (
                          invoice.ParentSubjectCode IS NULL
                          AND balance.ParentSubjectCode IS NULL
                      )
                  )
                  AND type.CashPolarityCode <> balance.CashPolarityCode
            ) AS invoices
    ),
    candidates_invoices AS
    (
        SELECT
            SubjectCode,
            ParentSubjectCode,
            CAST(NULL AS nvarchar(20)) AS InvoiceNumber,
            0 AS RowNumber,
            Balance AS TotalCharge,
            CAST(0 AS decimal(18, 12)) AS TaxRate
        FROM nonzero_balance_subjects

        UNION

        SELECT
            balance.SubjectCode,
            balance.ParentSubjectCode,
            invoices.InvoiceNumber,
            invoices.RowNumber,
            invoices.TotalCharge,
            invoices.TaxRate
        FROM nonzero_balance_subjects AS balance
            CROSS APPLY
            (
                SELECT
                    invoice.InvoiceNumber,
                    ROW_NUMBER() OVER (ORDER BY invoice.InvoicedOn DESC) AS RowNumber,
                    (invoice.InvoiceValue + invoice.TaxValue) * -1 AS TotalCharge,
                    invoice.TaxValue / CASE invoice.InvoiceValue WHEN 0 THEN 1 ELSE invoice.InvoiceValue END AS TaxRate
                FROM Invoice.tbInvoice AS invoice
                    JOIN Invoice.tbType AS type
                        ON invoice.InvoiceTypeCode = type.InvoiceTypeCode
                WHERE invoice.SubjectCode = balance.SubjectCode
                  AND
                  (
                      invoice.ParentSubjectCode = balance.ParentSubjectCode
                      OR
                      (
                          invoice.ParentSubjectCode IS NULL
                          AND balance.ParentSubjectCode IS NULL
                      )
                  )
                  AND type.CashPolarityCode = balance.CashPolarityCode
            ) AS invoices
    ),
    candidate_balance AS
    (
        SELECT
            SubjectCode,
            ParentSubjectCode,
            InvoiceNumber,
            TotalCharge,
            TaxRate,
            CAST
            (
                SUM(TotalCharge) OVER
                (
                    PARTITION BY SubjectCode, ParentSubjectCode
                    ORDER BY RowNumber
                    ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
                ) AS float
            ) AS Balance
        FROM candidates_invoices
    ),
    candidate_status AS
    (
        SELECT
            SubjectCode,
            ParentSubjectCode,
            InvoiceNumber,
            CASE
                WHEN Balance >= 0 THEN 1
                ELSE CASE WHEN TotalCharge < Balance THEN 2 ELSE 3 END
            END AS InvoiceStatusCode,
            CASE
                WHEN Balance >= 0 THEN 0
                ELSE CASE WHEN TotalCharge < Balance THEN ABS(Balance) ELSE ABS(TotalCharge) END
            END AS TotalPaid,
            TaxRate
        FROM candidate_balance
    ),
    invoice_status AS
    (
        SELECT
            SubjectCode,
            ParentSubjectCode,
            InvoiceNumber,
            InvoiceStatusCode,
            TotalPaid,
            TaxRate
        FROM paid_invoices

        UNION

        SELECT
            SubjectCode,
            ParentSubjectCode,
            InvoiceNumber,
            InvoiceStatusCode,
            TotalPaid,
            TaxRate
        FROM candidate_status
        WHERE InvoiceNumber IS NOT NULL
    )
    SELECT
        SubjectCode,
        ParentSubjectCode,
        InvoiceNumber,
        InvoiceStatusCode,
        TotalPaid / (1 + TaxRate) AS PaidValue,
        TotalPaid - (TotalPaid / (1 + TaxRate)) AS PaidTaxValue
    FROM invoice_status;
