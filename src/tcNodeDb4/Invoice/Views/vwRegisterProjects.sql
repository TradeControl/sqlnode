CREATE VIEW Invoice.vwRegisterProjects
AS
SELECT
    (
        SELECT TOP (1) p.StartOn
        FROM App.tbYearPeriod p
        WHERE p.StartOn <= i.InvoicedOn
        ORDER BY p.StartOn DESC
    ) AS StartOn,

    i.InvoiceNumber,
    ip.ProjectCode,
    pr.ProjectTitle,
    pr.ObjectCode,
    o.ObjectDescription,
    c.CashCode,
    c.CashDescription,
    ip.TaxCode,
    tc.TaxDescription,

    i.SubjectCode,
    i.InvoiceTypeCode,
    i.InvoiceStatusCode,
    i.InvoicedOn,
    i.DueOn,
    i.ExpectedOn,

    ip.Quantity,
    CASE WHEN t.CashPolarityCode = 0 THEN ip.InvoiceValue * -1 ELSE ip.InvoiceValue END AS InvoiceValue,
    CASE WHEN t.CashPolarityCode = 0 THEN ip.TaxValue     * -1 ELSE ip.TaxValue     END AS TaxValue,

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
JOIN Invoice.tbProject ip ON i.InvoiceNumber = ip.InvoiceNumber
JOIN Cash.tbCode c ON ip.CashCode = c.CashCode
JOIN Project.tbProject pr ON ip.ProjectCode = pr.ProjectCode
JOIN Object.tbObject o ON pr.ObjectCode = o.ObjectCode
LEFT JOIN App.tbTaxCode tc ON ip.TaxCode = tc.TaxCode;
