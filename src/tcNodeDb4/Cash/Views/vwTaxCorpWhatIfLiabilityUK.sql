/*
    UK Corporation Tax liability delta for the current What-if costing set.

    The base is actual plus the confirmed order book. Scenario quotation facts
    are added by financial year and the same reviewed loss roll-forward and
    marginal-relief kernel are rerun. The result is
    T(actual + confirmed + scenario) - T(actual + confirmed).
*/
CREATE VIEW Cash.vwTaxCorpWhatIfLiabilityUK
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
), scenario_by_year AS
(
    SELECT scenario.YearNumber,
           ScenarioProfit = CONVERT(decimal(38,5), SUM(CASE
               WHEN distribution.CashCode IS NULL THEN scenario.OrderValue ELSE 0 END)),
           ScenarioDistributions = CONVERT(decimal(38,5), SUM(CASE
               WHEN distribution.CashCode IS NOT NULL THEN scenario.OrderValue ELSE 0 END))
    FROM Cash.vwTaxBizWhatIfOrderBook scenario
    LEFT JOIN distribution_codes distribution
      ON distribution.CashCode = scenario.CashCode
    GROUP BY scenario.YearNumber
), year_source AS
(
    SELECT base.*,
           ScenarioProfit = CONVERT(decimal(38,5), COALESCE(scenario.ScenarioProfit, 0)),
           ScenarioDistributions = CONVERT(decimal(38,5), COALESCE(scenario.ScenarioDistributions, 0)),
           WhatIfTaxableResultBeforeRelief = CONVERT(decimal(38,5),
               base.ProjectedTaxableResultBeforeRelief + COALESCE(scenario.ScenarioProfit, 0)),
           WhatIfRelevantDistributions = CONVERT(decimal(38,5),
               base.ProjectedRelevantDistributions + COALESCE(scenario.ScenarioDistributions, 0)),
           SequenceNumber = ROW_NUMBER() OVER (ORDER BY base.YearNumber)
    FROM Cash.fnTaxCorpOrderBookLiabilityUK() base
    LEFT JOIN scenario_by_year scenario
      ON scenario.YearNumber = base.YearNumber
), loss_rollup AS
(
    SELECT source.*,
           WhatIfOpeningLoss = CONVERT(decimal(38,5), 0),
           WhatIfClosingLoss = CONVERT(decimal(38,5), CASE
               WHEN source.WhatIfTaxableResultBeforeRelief < 0
               THEN -source.WhatIfTaxableResultBeforeRelief ELSE 0 END),
           WhatIfTaxableTotalProfits = CONVERT(decimal(38,5), CASE
               WHEN source.WhatIfTaxableResultBeforeRelief > 0
               THEN source.WhatIfTaxableResultBeforeRelief ELSE 0 END)
    FROM year_source source
    WHERE source.SequenceNumber = 1

    UNION ALL

    SELECT source.*,
           WhatIfOpeningLoss = CONVERT(decimal(38,5), prior.WhatIfClosingLoss),
           WhatIfClosingLoss = CONVERT(decimal(38,5), CASE
               WHEN source.WhatIfTaxableResultBeforeRelief < 0
               THEN prior.WhatIfClosingLoss - source.WhatIfTaxableResultBeforeRelief
               WHEN prior.WhatIfClosingLoss > source.WhatIfTaxableResultBeforeRelief
               THEN prior.WhatIfClosingLoss - source.WhatIfTaxableResultBeforeRelief
               ELSE 0 END),
           WhatIfTaxableTotalProfits = CONVERT(decimal(38,5), CASE
               WHEN source.WhatIfTaxableResultBeforeRelief > prior.WhatIfClosingLoss
               THEN source.WhatIfTaxableResultBeforeRelief - prior.WhatIfClosingLoss
               ELSE 0 END)
    FROM loss_rollup prior
    JOIN year_source source
      ON source.SequenceNumber = prior.SequenceNumber + 1
)
SELECT projection.YearNumber,
       projection.PeriodStart,
       projection.PeriodEnd,
       projection.ScenarioProfit,
       projection.ScenarioDistributions,
       projection.WhatIfTaxableResultBeforeRelief,
       projection.WhatIfRelevantDistributions,
       projection.WhatIfOpeningLoss,
       projection.WhatIfClosingLoss,
       projection.WhatIfTaxableTotalProfits,
       kernel.AugmentedProfits,
       kernel.CalculationCode,
       kernel.MarginalRelief,
       BaseProjectedLiability = projection.ProjectedLiability,
       WhatIfLiability = CONVERT(decimal(38,5),
           ROUND(kernel.CorporationTaxChargeable + projection.BusinessTaxAdjustment, 5)),
       ScenarioTaxAccrual = CONVERT(decimal(38,5), CASE
           WHEN projection.IsAccrualReady = 1 AND kernel.IsValid = 1
           THEN ROUND(kernel.CorporationTaxChargeable + projection.BusinessTaxAdjustment
               - projection.ProjectedLiability, 5)
           ELSE NULL END),
       FindingCode = CONVERT(nvarchar(40), COALESCE(
           projection.FindingCode,
           kernel.FindingCode)),
       IsAccrualReady = CONVERT(bit, CASE
           WHEN projection.IsAccrualReady = 1 AND kernel.IsValid = 1 THEN 1 ELSE 0 END)
FROM loss_rollup projection
CROSS APPLY Cash.fnTaxCorpMarginalReliefUK
(
    projection.WhatIfTaxableTotalProfits,
    projection.WhatIfRelevantDistributions,
    projection.PeriodStart,
    projection.PeriodEnd,
    projection.AssociatedCompanyCount,
    projection.MainRate,
    projection.SmallProfitsRate,
    projection.LowerLimit,
    projection.UpperLimit,
    projection.MarginalReliefFraction
) kernel;
GO
