/*
    DEBK business-tax recognition and equity-bridge proof.

    Read-only proof of the rules used by Cash.vwTaxBizComputationByYear:
      - losses are carried in taxable-profit units, not monetary tax units;
      - brought-forward losses are used only against later profits;
      - tax payments do not affect tax expense or loss relief;
      - an accounting period spanning rate changes uses a day-weighted rate;
      - the Equity Bridge consumes the resulting signed tax expense.
*/
SET NOCOUNT ON;
SET XACT_ABORT ON;

DECLARE @Tolerance decimal(18,5) = 0.10;

DECLARE @Cases table
(
    Scenario nvarchar(40) NOT NULL,
    SequenceNumber int NOT NULL,
    TaxableResult decimal(18,5) NOT NULL,
    EffectiveTaxRate decimal(18,12) NOT NULL,
    TaxPaid decimal(18,5) NOT NULL,
    ExpectedOpeningLoss decimal(18,5) NOT NULL,
    ExpectedLossUsed decimal(18,5) NOT NULL,
    ExpectedClosingLoss decimal(18,5) NOT NULL,
    ExpectedTaxExpense decimal(18,5) NOT NULL,
    PRIMARY KEY (Scenario, SequenceNumber)
);

INSERT @Cases
(
    Scenario, SequenceNumber, TaxableResult, EffectiveTaxRate, TaxPaid,
    ExpectedOpeningLoss, ExpectedLossUsed, ExpectedClosingLoss, ExpectedTaxExpense
)
VALUES
    (N'profit-rate-change',  1,  100.00, 0.19,    0.00,   0.00,   0.00,   0.00, 19.00),
    (N'profit-rate-change',  2,  100.00, 0.25,  -19.00,   0.00,   0.00,   0.00, 25.00),
    (N'loss-only',           1, -100.00, 0.19,    0.00,   0.00,   0.00, 100.00,  0.00),
    (N'loss-only',           2,  -50.00, 0.25,    0.00, 100.00,   0.00, 150.00,  0.00),
    (N'loss-then-profit',    1, -100.00, 0.19,    0.00,   0.00,   0.00, 100.00,  0.00),
    (N'loss-then-profit',    2,  100.00, 0.25,    0.00, 100.00, 100.00,   0.00,  0.00),
    (N'partial-loss-use',    1, -100.00, 0.19,    0.00,   0.00,   0.00, 100.00,  0.00),
    (N'partial-loss-use',    2,  160.00, 0.25,    0.00, 100.00, 100.00,   0.00, 15.00),
    (N'profit-then-loss',    1,  100.00, 0.19,    0.00,   0.00,   0.00,   0.00, 19.00),
    (N'profit-then-loss',    2,  -40.00, 0.25,  -19.00,   0.00,   0.00,  40.00,  0.00),
    (N'payment-independence',1,  100.00, 0.19, -999.00,   0.00,   0.00,   0.00, 19.00),
    (N'payment-independence',2,  100.00, 0.25,  777.00,   0.00,   0.00,   0.00, 25.00);

WITH ordered AS
(
    SELECT * FROM @Cases
), rollup AS
(
    SELECT c.Scenario,
           c.SequenceNumber,
           c.TaxableResult,
           c.EffectiveTaxRate,
           c.TaxPaid,
           OpeningLoss = CONVERT(decimal(38,5), 0),
           LossUsed = CONVERT(decimal(38,5), 0),
           ClosingLoss = CONVERT(decimal(38,5), CASE WHEN c.TaxableResult < 0 THEN -c.TaxableResult ELSE 0 END),
           TaxableProfitAfterRelief = CONVERT(decimal(38,5), CASE WHEN c.TaxableResult > 0 THEN c.TaxableResult ELSE 0 END)
    FROM ordered c
    WHERE c.SequenceNumber = 1

    UNION ALL

    SELECT c.Scenario,
           c.SequenceNumber,
           c.TaxableResult,
           c.EffectiveTaxRate,
           c.TaxPaid,
           OpeningLoss = CONVERT(decimal(38,5), r.ClosingLoss),
           LossUsed = CONVERT(decimal(38,5), CASE
               WHEN c.TaxableResult <= 0 THEN 0
               WHEN r.ClosingLoss < c.TaxableResult THEN r.ClosingLoss
               ELSE c.TaxableResult END),
           ClosingLoss = CONVERT(decimal(38,5), CASE
               WHEN c.TaxableResult < 0 THEN r.ClosingLoss - c.TaxableResult
               WHEN r.ClosingLoss > c.TaxableResult THEN r.ClosingLoss - c.TaxableResult
               ELSE 0 END),
           TaxableProfitAfterRelief = CONVERT(decimal(38,5), CASE
               WHEN c.TaxableResult > r.ClosingLoss THEN c.TaxableResult - r.ClosingLoss
               ELSE 0 END)
    FROM rollup r
    JOIN ordered c
      ON c.Scenario = r.Scenario
     AND c.SequenceNumber = r.SequenceNumber + 1
)
SELECT c.Scenario,
       c.SequenceNumber,
       c.TaxableResult,
       c.EffectiveTaxRate,
       c.TaxPaid,
       c.ExpectedOpeningLoss,
       ActualOpeningLoss = r.OpeningLoss,
       c.ExpectedLossUsed,
       ActualLossUsed = r.LossUsed,
       c.ExpectedClosingLoss,
       ActualClosingLoss = r.ClosingLoss,
       c.ExpectedTaxExpense,
       ActualTaxExpense = CONVERT(decimal(18,5), ROUND(r.TaxableProfitAfterRelief * r.EffectiveTaxRate, 5))
INTO #RecognitionProof
FROM rollup r
JOIN @Cases c
  ON c.Scenario = r.Scenario
 AND c.SequenceNumber = r.SequenceNumber
OPTION (MAXRECURSION 100);

IF EXISTS
(
    SELECT 1
    FROM #RecognitionProof
    WHERE ActualOpeningLoss <> ExpectedOpeningLoss
       OR ActualLossUsed <> ExpectedLossUsed
       OR ActualClosingLoss <> ExpectedClosingLoss
       OR ActualTaxExpense <> ExpectedTaxExpense
)
    THROW 51090, 'DEBK proof failed: taxable-loss recognition failed an abstract scenario.', 1;

DECLARE @RateSlices table
(
    SliceStart date NOT NULL,
    SliceEnd date NOT NULL,
    BusinessTaxRate decimal(18,12) NOT NULL
);

INSERT @RateSlices (SliceStart, SliceEnd, BusinessTaxRate)
VALUES ('2023-04-01', '2023-10-01', 0.19),
       ('2023-10-02', '2024-03-31', 0.25);

DECLARE @WeightedRate decimal(18,12) =
(
    SELECT CONVERT(decimal(18,12),
        CONVERT(decimal(28,12),
            SUM(CONVERT(decimal(19,12), BusinessTaxRate) * (DATEDIFF(day, SliceStart, SliceEnd) + 1)))
        / CONVERT(decimal(10,0), SUM(DATEDIFF(day, SliceStart, SliceEnd) + 1)))
    FROM @RateSlices
);
DECLARE @ExpectedWeightedRate decimal(18,12) = 0.219836065574;

IF ABS(@WeightedRate - @ExpectedWeightedRate) > 0.000000000001
    THROW 51091, 'DEBK proof failed: the day-weighted rate calculation is incorrect.', 1;

IF OBJECT_ID(N'Cash.vwTaxBizComputationByYear', N'V') IS NULL
    THROW 51092, 'DEBK proof failed: Cash.vwTaxBizComputationByYear is not deployed.', 1;

WITH raw_years AS
(
    SELECT y.YearNumber,
           TaxableResult = CONVERT(decimal(38,5), SUM(COALESCE(t.NetProfit, 0))),
           BusinessTaxAdjustment = CONVERT(decimal(38,5), SUM(yp.BusinessTaxAdjustment)),
           EffectiveTaxRate = CONVERT(decimal(38,12),
               CONVERT(decimal(28,12),
                   SUM(CONVERT(decimal(19,12), yp.BusinessTaxRate)
                       * DATEDIFF(day, yp.StartOn, DATEADD(month, 1, yp.StartOn))))
               / NULLIF(CONVERT(decimal(10,0),
                   SUM(DATEDIFF(day, yp.StartOn, DATEADD(month, 1, yp.StartOn)))), 0))
    FROM App.tbYear y
    JOIN App.tbYearPeriod yp ON yp.YearNumber = y.YearNumber
    LEFT JOIN Cash.vwTaxBizTotalsByPeriod t ON t.StartOn = yp.StartOn
    GROUP BY y.YearNumber
), raw_ordered AS
(
    SELECT *, SequenceNumber = ROW_NUMBER() OVER (ORDER BY YearNumber)
    FROM raw_years
), independent_rollup AS
(
    SELECT r.SequenceNumber,
           r.YearNumber,
           r.TaxableResult,
           r.BusinessTaxAdjustment,
           r.EffectiveTaxRate,
           OpeningLoss = CONVERT(decimal(38,5), 0),
           ClosingLoss = CONVERT(decimal(38,5), CASE WHEN r.TaxableResult < 0 THEN -r.TaxableResult ELSE 0 END),
           TaxableProfitAfterRelief = CONVERT(decimal(38,5), CASE WHEN r.TaxableResult > 0 THEN r.TaxableResult ELSE 0 END)
    FROM raw_ordered r
    WHERE r.SequenceNumber = 1

    UNION ALL

    SELECT r.SequenceNumber,
           r.YearNumber,
           r.TaxableResult,
           r.BusinessTaxAdjustment,
           r.EffectiveTaxRate,
           OpeningLoss = CONVERT(decimal(38,5), prior.ClosingLoss),
           ClosingLoss = CONVERT(decimal(38,5), CASE
               WHEN r.TaxableResult < 0 THEN prior.ClosingLoss - r.TaxableResult
               WHEN prior.ClosingLoss > r.TaxableResult THEN prior.ClosingLoss - r.TaxableResult
               ELSE 0 END),
           TaxableProfitAfterRelief = CONVERT(decimal(38,5), CASE
               WHEN r.TaxableResult > prior.ClosingLoss THEN r.TaxableResult - prior.ClosingLoss
               ELSE 0 END)
    FROM independent_rollup prior
    JOIN raw_ordered r ON r.SequenceNumber = prior.SequenceNumber + 1
), independent AS
(
    SELECT YearNumber,
           TaxableResult,
           OpeningLoss,
           ClosingLoss,
           EffectiveTaxRate,
           TaxDue = CONVERT(decimal(38,5),
               ROUND(TaxableProfitAfterRelief * EffectiveTaxRate + BusinessTaxAdjustment, 5))
    FROM independent_rollup
)
SELECT c.YearNumber,
       c.Description,
       c.PeriodStart,
       c.PeriodEnd,
       c.TaxableResult,
       c.OpeningLoss,
       c.LossCreated,
       c.LossUsed,
       c.ClosingLoss,
       c.EffectiveTaxRate,
       c.BusinessTaxAdjustment,
       c.TaxableProfitAfterRelief,
       c.TaxBeforeRelief,
       c.TaxReliefApplied,
       c.TaxDue,
       IndependentTaxDue = i.TaxDue,
       CanonicalTaxDifference = CONVERT(decimal(18,5), c.TaxDue - i.TaxDue),
       CanonicalOpeningLossDifference = CONVERT(decimal(18,5), c.OpeningLoss - i.OpeningLoss),
       CanonicalClosingLossDifference = CONVERT(decimal(18,5), c.ClosingLoss - i.ClosingLoss),
       CanonicalRateDifference = CONVERT(decimal(18,12), c.EffectiveTaxRate - i.EffectiveTaxRate),
       BridgeBusinessTax = e.BusinessTax,
       e.Variance,
       TaxExpenseDifference = CONVERT(decimal(18,5), e.BusinessTax - ROUND(c.TaxDue, 2))
INTO #LiveProof
FROM Cash.vwTaxBizComputationByYear c
JOIN independent i ON i.YearNumber = c.YearNumber
JOIN Cash.vwEquityReconciliationByYear e ON e.YearNumber = c.YearNumber;

IF EXISTS
(
    SELECT 1
    FROM #LiveProof
    WHERE CanonicalTaxDifference <> 0
       OR CanonicalOpeningLossDifference <> 0
       OR CanonicalClosingLossDifference <> 0
       OR CanonicalRateDifference <> 0
       OR ABS(TaxExpenseDifference) > 0.01
       OR ABS(Variance) > @Tolerance
)
    THROW 51093, 'DEBK proof failed: canonical tax, live tax expense or Equity Bridge is outside tolerance.', 1;

SELECT *
FROM #RecognitionProof
ORDER BY Scenario, SequenceNumber;

SELECT WeightedRate = @WeightedRate,
       ExpectedWeightedRate = @ExpectedWeightedRate,
       Difference = @WeightedRate - @ExpectedWeightedRate;

SELECT *
FROM #LiveProof
ORDER BY YearNumber;

SELECT AbstractScenarios = COUNT(DISTINCT Scenario),
       AbstractRows = COUNT(*),
       AbstractFailures = SUM(CASE
           WHEN ActualOpeningLoss <> ExpectedOpeningLoss
             OR ActualLossUsed <> ExpectedLossUsed
             OR ActualClosingLoss <> ExpectedClosingLoss
             OR ActualTaxExpense <> ExpectedTaxExpense THEN 1 ELSE 0 END)
FROM #RecognitionProof;

SELECT LiveYears = COUNT(*),
       IndependentComputationFailures = SUM(CASE
           WHEN CanonicalTaxDifference <> 0
             OR CanonicalOpeningLossDifference <> 0
             OR CanonicalClosingLossDifference <> 0
             OR CanonicalRateDifference <> 0 THEN 1 ELSE 0 END),
       BridgeFailures = SUM(CASE WHEN ABS(Variance) > @Tolerance THEN 1 ELSE 0 END),
       TaxExpenseFailures = SUM(CASE WHEN ABS(TaxExpenseDifference) > 0.01 THEN 1 ELSE 0 END),
       MaximumAbsoluteVariance = MAX(ABS(Variance))
FROM #LiveProof;
