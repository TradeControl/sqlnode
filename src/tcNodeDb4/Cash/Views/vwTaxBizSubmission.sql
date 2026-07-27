CREATE   VIEW Cash.vwTaxBizSubmission
AS
SELECT
    TaxSourceCode,
    TagCode,
    PeriodFrom,
    PeriodTo,
    SUM(PeriodInvoiceValue) AS TaxableAmount
FROM Cash.vwTaxBizPayload
GROUP BY
    TaxSourceCode,
    TagCode,
    PeriodFrom,
    PeriodTo;
