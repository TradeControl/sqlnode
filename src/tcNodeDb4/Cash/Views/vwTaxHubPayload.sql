CREATE   VIEW Cash.vwTaxHubPayload 
AS
WITH period_source AS
(
    SELECT
        ts.TaxSourceCode,
        c.CashCode,
        c.CategoryCode,
        c.CashTypeCode,
        c.StartOn,
        c.InvoiceValue
    FROM Cash.vwCashCodePeriodValues c
    CROSS JOIN Cash.tbTaxTagSource ts
)
SELECT
    m.TaxSourceCode,
    m.TagCode,
    m.SourceCode,
    ps.CashCode,
    ps.CategoryCode,
    ps.CashTypeCode,
    ps.StartOn AS PeriodStartOn,
    m.PeriodFrom,
    m.PeriodTo,
    ps.InvoiceValue AS PeriodInvoiceValue
FROM Cash.vwTagCashPeriodMap m
JOIN period_source ps
    ON ps.TaxSourceCode = m.TaxSourceCode
   AND ps.CashCode      = m.CashCode
   AND ps.StartOn >= m.PeriodFrom
   AND ps.StartOn <  m.PeriodTo;