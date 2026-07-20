CREATE   VIEW Cash.vwTaxHubSubmission
AS
SELECT
    TaxSourceCode,
    TagCode,
    PeriodFrom,
    PeriodTo,
    SUM(PeriodInvoiceValue) AS TaxableAmount
FROM Cash.vwTaxHubPayload
GROUP BY
    TaxSourceCode,
    TagCode,
    PeriodFrom,
    PeriodTo;