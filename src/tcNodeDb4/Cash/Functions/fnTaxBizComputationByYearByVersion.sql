CREATE FUNCTION Cash.fnTaxBizComputationByYearByVersion
(
    @CategoryVersionId nvarchar(10)
)
RETURNS TABLE
AS
RETURN
(
    WITH year_source AS
    (
        SELECT year.YearNumber,
               year.Description,
               PeriodStart = CONVERT(date, MIN(period.StartOn)),
               PeriodEnd = CONVERT(date, DATEADD(day, -1, DATEADD(month, 1, MAX(period.StartOn)))),
               TaxableResult = CONVERT(decimal(38,5), SUM(COALESCE(total.NetProfit, 0))),
               BusinessTaxAdjustment = CONVERT(decimal(38,5), SUM(period.BusinessTaxAdjustment)),
               EffectiveTaxRate = CONVERT(decimal(38,12),
                   CONVERT(decimal(28,12),
                       SUM(CONVERT(decimal(19,12), period.BusinessTaxRate)
                           * DATEDIFF(day, period.StartOn, DATEADD(month, 1, period.StartOn))))
                   / NULLIF(CONVERT(decimal(10,0),
                       SUM(DATEDIFF(day, period.StartOn, DATEADD(month, 1, period.StartOn)))), 0))
        FROM App.tbYear AS year
        JOIN App.tbYearPeriod AS period
          ON period.YearNumber = year.YearNumber
        LEFT JOIN Cash.fnTaxBizTotalsByPeriodByVersion(@CategoryVersionId) AS total
          ON total.StartOn = period.StartOn
        GROUP BY year.YearNumber, year.Description
    ),
    ordered AS
    (
        SELECT *, SequenceNumber = ROW_NUMBER() OVER (ORDER BY YearNumber)
        FROM year_source
    ),
    tax_rollup AS
    (
        SELECT source.SequenceNumber,
               source.YearNumber,
               source.Description,
               source.PeriodStart,
               source.PeriodEnd,
               source.TaxableResult,
               source.BusinessTaxAdjustment,
               source.EffectiveTaxRate,
               OpeningLoss = CONVERT(decimal(38,5), 0),
               LossCreated = CONVERT(decimal(38,5), CASE
                   WHEN source.TaxableResult < 0 THEN -source.TaxableResult
                   ELSE 0
               END),
               LossUsed = CONVERT(decimal(38,5), 0),
               ClosingLoss = CONVERT(decimal(38,5), CASE
                   WHEN source.TaxableResult < 0 THEN -source.TaxableResult
                   ELSE 0
               END),
               TaxableProfitAfterRelief = CONVERT(decimal(38,5), CASE
                   WHEN source.TaxableResult > 0 THEN source.TaxableResult
                   ELSE 0
               END)
        FROM ordered AS source
        WHERE source.SequenceNumber = 1

        UNION ALL

        SELECT source.SequenceNumber,
               source.YearNumber,
               source.Description,
               source.PeriodStart,
               source.PeriodEnd,
               source.TaxableResult,
               source.BusinessTaxAdjustment,
               source.EffectiveTaxRate,
               OpeningLoss = CONVERT(decimal(38,5), rollup.ClosingLoss),
               LossCreated = CONVERT(decimal(38,5), CASE
                   WHEN source.TaxableResult < 0 THEN -source.TaxableResult
                   ELSE 0
               END),
               LossUsed = CONVERT(decimal(38,5), CASE
                   WHEN source.TaxableResult <= 0 THEN 0
                   WHEN rollup.ClosingLoss < source.TaxableResult THEN rollup.ClosingLoss
                   ELSE source.TaxableResult
               END),
               ClosingLoss = CONVERT(decimal(38,5), CASE
                   WHEN source.TaxableResult < 0 THEN rollup.ClosingLoss - source.TaxableResult
                   WHEN rollup.ClosingLoss > source.TaxableResult THEN rollup.ClosingLoss - source.TaxableResult
                   ELSE 0
               END),
               TaxableProfitAfterRelief = CONVERT(decimal(38,5), CASE
                   WHEN source.TaxableResult > rollup.ClosingLoss
                       THEN source.TaxableResult - rollup.ClosingLoss
                   ELSE 0
               END)
        FROM tax_rollup AS rollup
        JOIN ordered AS source
          ON source.SequenceNumber = rollup.SequenceNumber + 1
    ),
    computed AS
    (
        SELECT *,
               TaxBeforeRelief = CONVERT(decimal(38,5),
                   ROUND(CASE WHEN TaxableResult > 0 THEN TaxableResult ELSE 0 END
                       * EffectiveTaxRate + BusinessTaxAdjustment, 5)),
               TaxDue = CONVERT(decimal(38,5),
                   ROUND(TaxableProfitAfterRelief * EffectiveTaxRate
                       + BusinessTaxAdjustment, 5))
        FROM tax_rollup
    )
    SELECT YearNumber,
           Description,
           PeriodStart,
           PeriodEnd,
           TaxableResult,
           OpeningLoss,
           LossCreated,
           LossUsed,
           ClosingLoss,
           EffectiveTaxRate,
           BusinessTaxAdjustment,
           TaxableProfitAfterRelief,
           TaxBeforeRelief,
           TaxReliefApplied = CONVERT(decimal(38,5), TaxDue - TaxBeforeRelief),
           TaxDue
    FROM computed
);
