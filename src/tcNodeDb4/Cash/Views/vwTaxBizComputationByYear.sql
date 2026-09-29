/*
    Canonical annual business-tax recognition used by the statement and DEBK
    Equity Bridge. Losses are carried forward in taxable-profit units and are
    applied before the configured, day-weighted accounting-period rate.
    Payments are deliberately excluded: they settle the liability but do not
    change tax expense or relief. BusinessTaxAdjustment is a monetary override.

    This is the default Trade Control policy (same loss pool, forward relief,
    no automatic carryback). Jurisdiction-specific elections, restricted loss
    use, marginal relief and multiple profit/loss classes require reviewed tax
    policy inputs rather than inference by this view.
*/
CREATE VIEW Cash.vwTaxBizComputationByYear
AS
WITH year_source AS
(
    SELECT y.YearNumber,
           y.Description,
           PeriodStart = CONVERT(date, MIN(yp.StartOn)),
           PeriodEnd = CONVERT(date, DATEADD(day, -1, DATEADD(month, 1, MAX(yp.StartOn)))),
           TaxableResult = CONVERT(decimal(38,5), SUM(COALESCE(totals.NetProfit, 0))),
           BusinessTaxAdjustment = CONVERT(decimal(38,5), SUM(yp.BusinessTaxAdjustment)),
           EffectiveTaxRate = CONVERT(decimal(38,12),
               CONVERT(decimal(28,12),
                   SUM(CONVERT(decimal(19,12), yp.BusinessTaxRate)
                       * DATEDIFF(day, yp.StartOn, DATEADD(month, 1, yp.StartOn))))
               / NULLIF(CONVERT(decimal(10,0),
                   SUM(DATEDIFF(day, yp.StartOn, DATEADD(month, 1, yp.StartOn)))), 0))
    FROM App.tbYear y
    JOIN App.tbYearPeriod yp ON yp.YearNumber = y.YearNumber
    LEFT JOIN Cash.vwTaxBizTotalsByPeriod totals ON totals.StartOn = yp.StartOn
    GROUP BY y.YearNumber, y.Description
), ordered AS
(
    SELECT *, SequenceNumber = ROW_NUMBER() OVER (ORDER BY YearNumber)
    FROM year_source
), tax_rollup AS
(
    SELECT o.SequenceNumber,
           o.YearNumber,
           o.Description,
           o.PeriodStart,
           o.PeriodEnd,
           o.TaxableResult,
           o.BusinessTaxAdjustment,
           o.EffectiveTaxRate,
           OpeningLoss = CONVERT(decimal(38,5), 0),
           LossCreated = CONVERT(decimal(38,5), CASE WHEN o.TaxableResult < 0 THEN -o.TaxableResult ELSE 0 END),
           LossUsed = CONVERT(decimal(38,5), 0),
           ClosingLoss = CONVERT(decimal(38,5), CASE WHEN o.TaxableResult < 0 THEN -o.TaxableResult ELSE 0 END),
           TaxableProfitAfterRelief = CONVERT(decimal(38,5), CASE WHEN o.TaxableResult > 0 THEN o.TaxableResult ELSE 0 END)
    FROM ordered o
    WHERE o.SequenceNumber = 1

    UNION ALL

    SELECT o.SequenceNumber,
           o.YearNumber,
           o.Description,
           o.PeriodStart,
           o.PeriodEnd,
           o.TaxableResult,
           o.BusinessTaxAdjustment,
           o.EffectiveTaxRate,
           OpeningLoss = CONVERT(decimal(38,5), r.ClosingLoss),
           LossCreated = CONVERT(decimal(38,5), CASE WHEN o.TaxableResult < 0 THEN -o.TaxableResult ELSE 0 END),
           LossUsed = CONVERT(decimal(38,5), CASE
               WHEN o.TaxableResult <= 0 THEN 0
               WHEN r.ClosingLoss < o.TaxableResult THEN r.ClosingLoss
               ELSE o.TaxableResult END),
           ClosingLoss = CONVERT(decimal(38,5), CASE
               WHEN o.TaxableResult < 0 THEN r.ClosingLoss - o.TaxableResult
               WHEN r.ClosingLoss > o.TaxableResult THEN r.ClosingLoss - o.TaxableResult
               ELSE 0 END),
           TaxableProfitAfterRelief = CONVERT(decimal(38,5), CASE
               WHEN o.TaxableResult > r.ClosingLoss THEN o.TaxableResult - r.ClosingLoss
               ELSE 0 END)
    FROM tax_rollup r
    JOIN ordered o ON o.SequenceNumber = r.SequenceNumber + 1
), computed AS
(
    SELECT *,
           TaxBeforeRelief = CONVERT(decimal(38,5),
               ROUND(CASE WHEN TaxableResult > 0 THEN TaxableResult ELSE 0 END * EffectiveTaxRate
                   + BusinessTaxAdjustment, 5)),
           TaxDue = CONVERT(decimal(38,5),
               ROUND(TaxableProfitAfterRelief * EffectiveTaxRate + BusinessTaxAdjustment, 5))
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
FROM computed;
