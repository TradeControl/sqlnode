/*
    Deterministic Project-level UK Corporation Tax accrual events.

    The annual actual-plus-order-book liability is calculated by
    vwTaxCorpOrderBookLiabilityUK. This view uses its reviewed opening-loss
    state and statutory parameters to calculate only the cheap adjacent
    Project-prefix kernel deltas. A separate carry row bridges any annual
    difference caused by an earlier Project changing a later year's opening
    loss. No flat tax rate is assigned to a Project.
*/
CREATE VIEW Cash.vwTaxCorpOrderBookAccrualUK
AS
WITH tax_source_context AS
(
    SELECT profile.TaxSourceCode
    FROM App.tbOptions options
    OUTER APPLY
    (
        SELECT TOP (1) candidate.TaxSourceCode,
               candidate.StatusCode,
               candidate.ValidFrom,
               candidate.ReportingProfileCode
        FROM Cash.tbReportingProfile candidate
        WHERE candidate.SubjectCode = options.SubjectCode
          AND candidate.ReportingTypeCode = 2
          AND candidate.TaxSourceCode IS NOT NULL
        ORDER BY CASE candidate.StatusCode WHEN 1 THEN 0 ELSE 1 END,
                 candidate.ValidFrom DESC,
                 candidate.ReportingProfileCode
    ) profile
    WHERE options.JurisdictionCode = N'UK'
      AND Cash.fnGetBizTaxType() = 0
), distribution_codes AS
(
    SELECT DISTINCT mapping.CashCode
    FROM tax_source_context context
    JOIN Cash.vwTaxTagCashCode mapping
      ON mapping.TaxSourceCode = context.TaxSourceCode
     AND mapping.TagCode = N'RelevantDistributions'
), ordered_events AS
(
    SELECT order_book.StartOn AS SourceStartOn,
           order_book.YearNumber AS SourceYearNumber,
           order_book.ProjectCode,
           order_book.CashCode,
           order_book.ActionOn,
           order_book.QuantityRemaining,
           order_book.OrderValue,
           ProfitAmount = CONVERT(decimal(38,5), CASE
               WHEN distribution.CashCode IS NULL THEN order_book.OrderValue ELSE 0 END),
           DistributionAmount = CONVERT(decimal(38,5), CASE
               WHEN distribution.CashCode IS NOT NULL THEN order_book.OrderValue ELSE 0 END),
           EventNumber = ROW_NUMBER() OVER
               (ORDER BY order_book.ActionOn, order_book.ProjectCode),
           YearEventNumber = ROW_NUMBER() OVER
               (PARTITION BY order_book.YearNumber
                ORDER BY order_book.ActionOn, order_book.ProjectCode)
    FROM Cash.vwTaxBizOrderBook order_book
    LEFT JOIN distribution_codes distribution
      ON distribution.CashCode = order_book.CashCode
), cumulative_events AS
(
    SELECT event.*,
           CumulativeProfit = CONVERT(decimal(38,5), SUM(event.ProfitAmount) OVER
               (PARTITION BY event.SourceYearNumber
                ORDER BY event.YearEventNumber ROWS UNBOUNDED PRECEDING)),
           CumulativeDistributions = CONVERT(decimal(38,5), SUM(event.DistributionAmount) OVER
               (PARTITION BY event.SourceYearNumber
                ORDER BY event.YearEventNumber ROWS UNBOUNDED PRECEDING))
    FROM ordered_events event
), event_liabilities AS
(
    SELECT LiabilityYearNumber = annual.YearNumber,
           event.*,
           annual.PeriodStart,
           annual.PeriodEnd,
           annual.TaxAccrual AS AnnualTaxAccrual,
           annual.FindingCode,
           annual.IsAccrualReady,
           PrefixLiability = CONVERT(decimal(38,5), CASE
               WHEN annual.IsAccrualReady = 1 AND prefix_kernel.IsValid = 1
               THEN ROUND(prefix_kernel.CorporationTaxChargeable
                   + annual.BusinessTaxAdjustment, 5)
               ELSE NULL END),
           BaseLiability = CONVERT(decimal(38,5), CASE
               WHEN annual.IsAccrualReady = 1 AND base_kernel.IsValid = 1
               THEN ROUND(base_kernel.CorporationTaxChargeable
                   + annual.BusinessTaxAdjustment, 5)
               ELSE NULL END)
    FROM Cash.fnTaxCorpOrderBookLiabilityUK() annual
    LEFT JOIN cumulative_events event
      ON event.SourceYearNumber = annual.YearNumber
    CROSS APPLY Cash.fnTaxCorpMarginalReliefUK
    (
        CONVERT(decimal(38,5), CASE
            WHEN annual.ActualTaxableResultBeforeRelief
                    + COALESCE(event.CumulativeProfit, 0)
                    > annual.ProjectedOpeningLoss
            THEN annual.ActualTaxableResultBeforeRelief
                    + COALESCE(event.CumulativeProfit, 0)
                    - annual.ProjectedOpeningLoss
            ELSE 0 END),
        CONVERT(decimal(38,5),
            annual.ActualRelevantDistributions
                + COALESCE(event.CumulativeDistributions, 0)),
        annual.PeriodStart,
        annual.PeriodEnd,
        annual.AssociatedCompanyCount,
        annual.MainRate,
        annual.SmallProfitsRate,
        annual.LowerLimit,
        annual.UpperLimit,
        annual.MarginalReliefFraction
    ) prefix_kernel
    CROSS APPLY Cash.fnTaxCorpMarginalReliefUK
    (
        CONVERT(decimal(38,5), CASE
            WHEN annual.ActualTaxableResultBeforeRelief > annual.ProjectedOpeningLoss
            THEN annual.ActualTaxableResultBeforeRelief - annual.ProjectedOpeningLoss
            ELSE 0 END),
        annual.ActualRelevantDistributions,
        annual.PeriodStart,
        annual.PeriodEnd,
        annual.AssociatedCompanyCount,
        annual.MainRate,
        annual.SmallProfitsRate,
        annual.LowerLimit,
        annual.UpperLimit,
        annual.MarginalReliefFraction
    ) base_kernel
), event_deltas AS
(
    SELECT event.*,
           TaxDue = CONVERT(decimal(38,5), CASE
               WHEN event.ProjectCode IS NULL THEN 0
               ELSE event.PrefixLiability
                   - LAG(event.PrefixLiability, 1, event.BaseLiability) OVER
                       (PARTITION BY event.LiabilityYearNumber
                        ORDER BY event.YearEventNumber) END)
    FROM event_liabilities event
), summarized_events AS
(
    SELECT event.*,
           DirectTaxDue = CONVERT(decimal(38,5), SUM(event.TaxDue) OVER
               (PARTITION BY event.LiabilityYearNumber))
    FROM event_deltas event
), direct_events AS
(
    SELECT *
    FROM summarized_events
    WHERE ProjectCode IS NOT NULL
), annual_residual AS
(
    SELECT event.LiabilityYearNumber,
           PeriodStart = MAX(event.PeriodStart),
           PeriodEnd = MAX(event.PeriodEnd),
           ResidualTaxDue = CONVERT(decimal(38,5),
               MAX(event.AnnualTaxAccrual) - MAX(event.DirectTaxDue)),
           FindingCode = MAX(event.FindingCode),
           IsAccrualReady = CONVERT(bit, MIN(CONVERT(int, event.IsAccrualReady)))
    FROM summarized_events event
    GROUP BY event.LiabilityYearNumber
), carry_events AS
(
    SELECT residual.LiabilityYearNumber,
           StartOn = residual.PeriodStart,
           residual.PeriodEnd,
           source.SourceStartOn,
           source.SourceYearNumber,
           source.ProjectCode,
           source.CashCode,
           source.ActionOn,
           QuantityRemaining = CONVERT(decimal(18,4), 0),
           OrderValue = CONVERT(decimal(38,5), 0),
           SourceQuantityRemaining = source.QuantityRemaining,
           SourceOrderValue = source.OrderValue,
           TaxDue = residual.ResidualTaxDue,
           residual.FindingCode,
           residual.IsAccrualReady,
           IsCarryEffect = CONVERT(bit, 1)
    FROM annual_residual residual
    CROSS APPLY
    (
        SELECT TOP (1) event.*
        FROM cumulative_events event
        WHERE event.SourceYearNumber < residual.LiabilityYearNumber
        ORDER BY event.ActionOn DESC, event.ProjectCode DESC
    ) source
    WHERE residual.ResidualTaxDue <> 0
)
SELECT direct.LiabilityYearNumber,
       StartOn = direct.PeriodStart,
       direct.PeriodEnd,
       direct.SourceStartOn,
       direct.SourceYearNumber,
       direct.ProjectCode,
       direct.CashCode,
       direct.ActionOn,
       direct.QuantityRemaining,
       direct.OrderValue,
       SourceQuantityRemaining = direct.QuantityRemaining,
       SourceOrderValue = direct.OrderValue,
       direct.TaxDue,
       direct.FindingCode,
       direct.IsAccrualReady,
       IsCarryEffect = CONVERT(bit, 0)
FROM direct_events direct

UNION ALL

SELECT carry.LiabilityYearNumber,
       carry.StartOn,
       carry.PeriodEnd,
       carry.SourceStartOn,
       carry.SourceYearNumber,
       carry.ProjectCode,
       carry.CashCode,
       carry.ActionOn,
       carry.QuantityRemaining,
       carry.OrderValue,
       carry.SourceQuantityRemaining,
       carry.SourceOrderValue,
       carry.TaxDue,
       carry.FindingCode,
       carry.IsAccrualReady,
       carry.IsCarryEffect
FROM carry_events carry;
GO
