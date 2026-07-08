CREATE VIEW Invoice.vwRegisterItems
AS
SELECT
    (
        SELECT TOP (1) p.StartOn
        FROM App.tbYearPeriod p
        WHERE p.StartOn <= i.InvoicedOn
        ORDER BY p.StartOn DESC
    ) AS StartOn,

    i.InvoiceNumber,
    it.CashCode AS ProjectCode,
    c.CashCode,
    c.CashDescription,
    it.TaxCode,
    tc.TaxDescription,
    i.SubjectCode,
    i.ParentSubjectCode,
    i.InvoiceTypeCode,
    i.InvoiceStatusCode,
    i.InvoicedOn,
    i.DueOn,
    i.ExpectedOn,

    CASE WHEN t.CashPolarityCode = 0 THEN it.InvoiceValue * -1 ELSE it.InvoiceValue END AS InvoiceValue,
    CASE WHEN t.CashPolarityCode = 0 THEN it.TaxValue     * -1 ELSE it.TaxValue     END AS TaxValue,

    CAST(it.ItemReference AS nvarchar(100)) AS ItemReference,

    i.PaymentTerms,
    i.Printed,
    s.SubjectName,
    u.UserName,
    i.UserId,
    st.InvoiceStatus,
    t.CashPolarityCode,
    t.InvoiceType
FROM Invoice.tbInvoice i
JOIN Subject.tbSubject s ON i.SubjectCode = s.SubjectCode
JOIN Invoice.tbType t ON i.InvoiceTypeCode = t.InvoiceTypeCode
JOIN Invoice.tbStatus st ON i.InvoiceStatusCode = st.InvoiceStatusCode
JOIN Usr.tbUser u ON i.UserId = u.UserId
JOIN Invoice.tbItem it ON i.InvoiceNumber = it.InvoiceNumber
JOIN Cash.tbCode c ON it.CashCode = c.CashCode
LEFT JOIN App.tbTaxCode tc ON it.TaxCode = tc.TaxCode;

