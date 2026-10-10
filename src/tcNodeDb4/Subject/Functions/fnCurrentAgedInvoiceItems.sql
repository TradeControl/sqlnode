CREATE FUNCTION Subject.fnCurrentAgedInvoiceItems
(
    @AgedOn date
)
RETURNS TABLE
AS
RETURN
(
    SELECT
        invoice.SubjectCode,
        subject.SubjectName,
        CAST(@AgedOn AS date) AS AgedOn,
        invoice.InvoiceNumber,
        invoice.InvoiceTypeCode,
        invoice_type.InvoiceType,
        CAST(invoice.InvoicedOn AS date) AS InvoicedOn,
        CAST(invoice.DueOn AS date) AS DueOn,
        DATEDIFF(DAY, CAST(invoice.DueOn AS date), @AgedOn) AS DaysOverdue,
        CAST
        (
            CASE
                WHEN CAST(invoice.DueOn AS date) >= @AgedOn THEN 0
                WHEN DATEDIFF(DAY, CAST(invoice.DueOn AS date), @AgedOn) <= 30 THEN 1
                WHEN DATEDIFF(DAY, CAST(invoice.DueOn AS date), @AgedOn) <= 60 THEN 2
                WHEN DATEDIFF(DAY, CAST(invoice.DueOn AS date), @AgedOn) <= 90 THEN 3
                ELSE 4
            END
            AS smallint
        ) AS AgeBandCode,
        CAST
        (
            CASE invoice_type.CashPolarityCode
                WHEN 1 THEN
                    (invoice.InvoiceValue + invoice.TaxValue)
                    - (invoice.PaidValue + invoice.PaidTaxValue)
                WHEN 0 THEN
                    (
                        (invoice.InvoiceValue + invoice.TaxValue)
                        - (invoice.PaidValue + invoice.PaidTaxValue)
                    ) * -1
            END
            AS decimal(18, 5)
        ) AS BusinessAmount
    FROM Invoice.tbInvoice AS invoice
        JOIN Invoice.tbType AS invoice_type
            ON invoice.InvoiceTypeCode = invoice_type.InvoiceTypeCode
        JOIN Subject.tbSubject AS subject
            ON invoice.SubjectCode = subject.SubjectCode
        JOIN Subject.tbType AS subject_type
            ON subject.SubjectTypeCode = subject_type.SubjectTypeCode
    WHERE subject_type.SubjectClassCode <> 2
      AND invoice.InvoiceStatusCode < 3
      AND
      (
          (invoice.InvoiceValue + invoice.TaxValue)
          - (invoice.PaidValue + invoice.PaidTaxValue)
      ) <> 0
);
GO
