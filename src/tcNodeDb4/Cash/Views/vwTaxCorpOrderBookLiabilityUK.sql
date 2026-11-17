/*
    UK annual Corporation Tax projection including the confirmed order book.

    The calculation recomputes the loss roll-forward from combined actual and
    uninvoiced Project facts. TaxAccrual is the liability delta
    T(actual + confirmed) - T(actual); no flat rate is assigned to a Project.
*/
CREATE VIEW Cash.vwTaxCorpOrderBookLiabilityUK
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
    SELECT DISTINCT context.TaxSourceCode, mapping.CashCode
    FROM tax_source_context context
    JOIN Cash.vwTaxTagCashCode mapping
      ON mapping.TaxSourceCode = context.TaxSourceCode
     AND mapping.TagCode = N'RelevantDistributions'
), order_book_by_year AS
(
    SELECT order_book.YearNumber,
           OrderBookProfit = CONVERT(decimal(38,5), SUM(CASE
               WHEN distribution.CashCode IS NULL THEN order_book.OrderValue ELSE 0 END)),
           OrderBookDistributions = CONVERT(decimal(38,5), SUM(CASE
               WHEN distribution.CashCode IS NOT NULL THEN order_book.OrderValue ELSE 0 END))
    FROM Cash.vwTaxBizOrderBook order_book
    LEFT JOIN distribution_codes distribution
      ON distribution.CashCode = order_book.CashCode
    GROUP BY order_book.YearNumber
), year_source AS
(
    SELECT actual.*,
           OrderBookProfit = CONVERT(decimal(38,5), COALESCE(order_book.OrderBookProfit, 0)),
           OrderBookDistributions = CONVERT(decimal(38,5), COALESCE(order_book.OrderBookDistributions, 0)),
           ProjectedTaxableResultBeforeRelief = CONVERT(decimal(38,5),
               actual.TaxableResultBeforeRelief + COALESCE(order_book.OrderBookProfit, 0)),
           ProjectedRelevantDistributions = CONVERT(decimal(38,5),
               actual.RelevantDistributions + COALESCE(order_book.OrderBookDistributions, 0)),
           SequenceNumber = ROW_NUMBER() OVER (ORDER BY actual.YearNumber)
    FROM Cash.vwTaxCorpLiabilityUK actual
    LEFT JOIN order_book_by_year order_book
      ON order_book.YearNumber = actual.YearNumber
), loss_rollup AS
(
    SELECT source.*,
           ProjectedOpeningLoss = CONVERT(decimal(38,5), 0),
           ProjectedLossCreated = CONVERT(decimal(38,5), CASE
               WHEN source.ProjectedTaxableResultBeforeRelief < 0
               THEN -source.ProjectedTaxableResultBeforeRelief ELSE 0 END),
           ProjectedLossUsed = CONVERT(decimal(38,5), 0),
           ProjectedClosingLoss = CONVERT(decimal(38,5), CASE
               WHEN source.ProjectedTaxableResultBeforeRelief < 0
               THEN -source.ProjectedTaxableResultBeforeRelief ELSE 0 END),
           ProjectedTaxableTotalProfits = CONVERT(decimal(38,5), CASE
               WHEN source.ProjectedTaxableResultBeforeRelief > 0
               THEN source.ProjectedTaxableResultBeforeRelief ELSE 0 END)
    FROM year_source source
    WHERE source.SequenceNumber = 1

    UNION ALL

    SELECT source.*,
           ProjectedOpeningLoss = CONVERT(decimal(38,5), prior.ProjectedClosingLoss),
           ProjectedLossCreated = CONVERT(decimal(38,5), CASE
               WHEN source.ProjectedTaxableResultBeforeRelief < 0
               THEN -source.ProjectedTaxableResultBeforeRelief ELSE 0 END),
           ProjectedLossUsed = CONVERT(decimal(38,5), CASE
               WHEN source.ProjectedTaxableResultBeforeRelief <= 0 THEN 0
               WHEN prior.ProjectedClosingLoss < source.ProjectedTaxableResultBeforeRelief
               THEN prior.ProjectedClosingLoss
               ELSE source.ProjectedTaxableResultBeforeRelief END),
           ProjectedClosingLoss = CONVERT(decimal(38,5), CASE
               WHEN source.ProjectedTaxableResultBeforeRelief < 0
               THEN prior.ProjectedClosingLoss - source.ProjectedTaxableResultBeforeRelief
               WHEN prior.ProjectedClosingLoss > source.ProjectedTaxableResultBeforeRelief
               THEN prior.ProjectedClosingLoss - source.ProjectedTaxableResultBeforeRelief
               ELSE 0 END),
           ProjectedTaxableTotalProfits = CONVERT(decimal(38,5), CASE
               WHEN source.ProjectedTaxableResultBeforeRelief > prior.ProjectedClosingLoss
               THEN source.ProjectedTaxableResultBeforeRelief - prior.ProjectedClosingLoss
               ELSE 0 END)
    FROM loss_rollup prior
    JOIN year_source source
      ON source.SequenceNumber = prior.SequenceNumber + 1
)
SELECT projection.YearNumber,
       projection.JurisdictionCode,
       projection.TaxSourceCode,
       projection.ReportingProfileCode,
       projection.Description,
       projection.PeriodStart,
       projection.PeriodEnd,
       ActualTaxableResultBeforeRelief = projection.TaxableResultBeforeRelief,
       ActualRelevantDistributions = projection.RelevantDistributions,
       projection.BusinessTaxAdjustment,
       projection.AssociatedCompanyCount,
       projection.MainRate,
       projection.SmallProfitsRate,
       projection.MarginalReliefFraction,
       projection.LowerLimit,
       projection.UpperLimit,
       projection.OrderBookProfit,
       projection.OrderBookDistributions,
       projection.ProjectedTaxableResultBeforeRelief,
       projection.ProjectedRelevantDistributions,
       projection.ProjectedOpeningLoss,
       projection.ProjectedLossCreated,
       projection.ProjectedLossUsed,
       projection.ProjectedClosingLoss,
       projection.ProjectedTaxableTotalProfits,
       kernel.AugmentedProfits,
       kernel.CalculationCode,
       kernel.MarginalRelief,
       ActualLiability = projection.TaxDue,
       ProjectedLiability = CONVERT(decimal(38,5),
           ROUND(kernel.CorporationTaxChargeable + projection.BusinessTaxAdjustment, 5)),
       TaxAccrual = CONVERT(decimal(38,5), CASE
           WHEN projection.IsAccrualReady = 1 AND kernel.IsValid = 1
           THEN ROUND(kernel.CorporationTaxChargeable + projection.BusinessTaxAdjustment
               - projection.TaxDue, 5)
           ELSE NULL END),
       FindingCode = CONVERT(nvarchar(40), COALESCE(
           projection.RateFindingCode,
           projection.ProfileFindingCode,
           kernel.FindingCode)),
       IsAccrualReady = CONVERT(bit, CASE
           WHEN projection.IsAccrualReady = 1 AND kernel.IsValid = 1 THEN 1 ELSE 0 END)
FROM loss_rollup projection
CROSS APPLY Cash.fnTaxCorpMarginalReliefUK
(
    projection.ProjectedTaxableTotalProfits,
    projection.ProjectedRelevantDistributions,
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
