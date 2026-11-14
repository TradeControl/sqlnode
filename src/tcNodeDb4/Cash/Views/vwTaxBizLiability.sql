/*
    Jurisdiction-neutral annual business-tax liability contract.

    Jurisdiction-specific measures remain in their provider. This boundary
    exposes only the selected calculation identity, dated liability, readiness
    and primary finding required by common statement and audit consumers.
*/
CREATE VIEW Cash.vwTaxBizLiability
AS
WITH due_dates AS
(
    SELECT PayOn = CONVERT(date, PayOn),
           PayFrom = CONVERT(date, PayFrom),
           PayTo = CONVERT(date, PayTo)
    FROM Cash.fnTaxTypeDueDates(Cash.fnGetBizTaxType(), 0)
)
SELECT computation.YearNumber,
       computation.JurisdictionCode,
       computation.TaxSourceCode,
       computation.ReportingProfileCode,
       computation.CalculationCode,
       computation.FindingCode,
       computation.PeriodStart,
       computation.PeriodEnd,
       due.PayOn,
       LiabilityAmount = computation.TaxDue,
       computation.BusinessTaxAdjustment,
       computation.IsAccrualReady,
       computation.IsFilingReady
FROM Cash.fnTaxBizComputationByYearSelected() computation
LEFT JOIN due_dates due
  ON due.PayFrom = computation.PeriodStart
 AND due.PayTo = DATEADD(day, 1, computation.PeriodEnd);
GO
