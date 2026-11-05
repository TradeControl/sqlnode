/*
    Build 4.1.20 Equity Bridge equivalence gate.

    Run after applying the 4.1.20 reporting objects to a build 4.1.19
    Category Tree database. The Legacy CTEs preserve the committed 4.1.19
    Cash.vwEquityReconciliationByYear body. The test compares that result
    with both the active compatibility view and the version-explicit head
    function, in both directions and with explicit columns.
*/
SET NOCOUNT ON;

IF App.fnVersion() <> N'4.1.20'
    THROW 51130, 'The Equity Bridge build gate requires tcNodeDb4 4.1.20.', 1;

DECLARE @CategoryVersionId nvarchar(10) =
(
    SELECT CategoryVersionId
    FROM App.tbOptions
);

IF @CategoryVersionId IS NULL
    THROW 51131, 'The active Category Tree version is not configured.', 1;

;WITH first_period AS
(
    SELECT StartOn = MIN(period.StartOn)
    FROM App.tbYearPeriod AS period
    JOIN App.tbYear AS year
      ON year.YearNumber = period.YearNumber
    WHERE year.CashStatusCode BETWEEN 1 AND 2
),
opening_subject_position AS
(
    SELECT OpeningSubjectPosition = -SUM(subject.OpeningBalance)
    FROM Subject.tbSubject AS subject
    WHERE subject.OpeningBalance <> 0
),
opening_account_position AS
(
    SELECT OpeningAccountPosition = SUM(account.OpeningBalance)
    FROM Subject.tbAccount AS account
    WHERE account.AccountTypeCode = 0
      AND account.AccountClosed = 0
      AND account.OpeningBalance <> 0
),
opening_capital AS
(
    SELECT Capital = SUM(balance_sheet.Balance)
    FROM Cash.vwBalanceSheet AS balance_sheet
    JOIN first_period
      ON first_period.StartOn = balance_sheet.StartOn
),
year_bounds AS
(
    SELECT period.YearNumber, YearEndOn = MAX(period.StartOn)
    FROM App.tbYearPeriod AS period
    JOIN App.tbYear AS year
      ON year.YearNumber = period.YearNumber
    WHERE year.CashStatusCode BETWEEN 1 AND 2
    GROUP BY period.YearNumber
),
closing_capital AS
(
    SELECT bounds.YearNumber,
           StartOn = bounds.YearEndOn,
           Capital = SUM(balance_sheet.Balance)
    FROM year_bounds AS bounds
    JOIN Cash.vwBalanceSheet AS balance_sheet
      ON balance_sheet.StartOn = bounds.YearEndOn
    GROUP BY bounds.YearNumber, bounds.YearEndOn
),
balances AS
(
    SELECT capital.YearNumber,
           OpeningCapital = LAG(capital.Capital) OVER (ORDER BY capital.StartOn),
           ClosingCapital = capital.Capital
    FROM closing_capital AS capital
),
profit_by_year AS
(
    SELECT profit.YearNumber, Profit = SUM(profit.InvoiceValue)
    FROM Cash.vwProfitAndLossByYear AS profit
    GROUP BY profit.YearNumber
),
business_tax_by_year AS
(
    SELECT YearNumber,
           BusinessTaxExpense = CASE Cash.fnGetBizTaxType()
               WHEN 0 THEN TaxDue
               ELSE 0
           END,
           TaxCarry = TaxReliefApplied,
           OpeningLoss,
           ClosingLoss
    FROM Cash.vwTaxBizComputationByYear
),
loss_cf_delta AS
(
    SELECT YearNumber,
           OpeningLossesCarriedForward = LAG(ClosingLoss) OVER (ORDER BY YearNumber),
           ClosingLossesCarriedForward = ClosingLoss
    FROM business_tax_by_year
),
capital_position_by_year AS
(
    SELECT bounds.YearNumber,
           CapitalPosition = SUM(asset.Balance)
    FROM year_bounds AS bounds
    JOIN Cash.vwBalanceSheetAssets AS asset
      ON asset.StartOn = bounds.YearEndOn
    JOIN Subject.tbAccount AS account
      ON account.AccountCode = asset.AssetCode
    WHERE account.BalanceConstraintCode = 2
    GROUP BY bounds.YearNumber
),
capital_movement_by_year AS
(
    SELECT YearNumber,
           CapitalMovement = COALESCE(CapitalPosition, 0)
               - COALESCE(LAG(CapitalPosition) OVER (ORDER BY YearNumber), 0)
    FROM capital_position_by_year
),
reconciliation AS
(
    SELECT year.YearNumber,
           year.Description,
           OpeningCapital = CASE
               WHEN balance.OpeningCapital IS NULL THEN 0
               ELSE ROUND(balance.OpeningCapital, 2)
           END,
           ClosingCapital = ROUND(balance.ClosingCapital, 2),
           Profit = ROUND(profit.Profit, 2),
           BusinessTax = ROUND(COALESCE(tax.BusinessTaxExpense, 0), 2),
           ProfitAfterTax = ROUND(COALESCE(profit.Profit, 0)
               - COALESCE(tax.BusinessTaxExpense, 0), 2),
           TaxCarry = ROUND(COALESCE(tax.TaxCarry, 0), 2),
           OpeningSubjectPosition = CASE
               WHEN balance.OpeningCapital IS NULL
                   THEN COALESCE((SELECT OpeningSubjectPosition FROM opening_subject_position), 0)
               ELSE 0
           END,
           OpeningAccountPosition = CASE
               WHEN balance.OpeningCapital IS NULL
                   THEN COALESCE((SELECT OpeningAccountPosition FROM opening_account_position), 0)
               ELSE 0
           END,
           OpeningLossesCarriedForward =
               ROUND(COALESCE(loss.OpeningLossesCarriedForward, 0), 2),
           ClosingLossesCarriedForward =
               ROUND(COALESCE(loss.ClosingLossesCarriedForward, 0), 2),
           LossesCarriedForwardDelta =
               ROUND(COALESCE(loss.ClosingLossesCarriedForward, 0)
                   - COALESCE(loss.OpeningLossesCarriedForward, 0), 2),
           CapitalDelta = ROUND(balance.ClosingCapital
               - CASE
                   WHEN balance.OpeningCapital IS NULL THEN 0
                   ELSE balance.OpeningCapital
                 END, 2),
           CapitalMovement = COALESCE(movement.CapitalMovement, 0)
    FROM App.tbYear AS year
    JOIN balances AS balance
      ON balance.YearNumber = year.YearNumber
    LEFT JOIN profit_by_year AS profit
      ON profit.YearNumber = year.YearNumber
    LEFT JOIN business_tax_by_year AS tax
      ON tax.YearNumber = year.YearNumber
    LEFT JOIN loss_cf_delta AS loss
      ON loss.YearNumber = year.YearNumber
    LEFT JOIN capital_movement_by_year AS movement
      ON movement.YearNumber = year.YearNumber
    WHERE year.CashStatusCode BETWEEN 1 AND 2
)
SELECT YearNumber,
       Description,
       OpeningCapital = CONVERT(decimal(38,5), OpeningCapital),
       ClosingCapital = CONVERT(decimal(38,5), ClosingCapital),
       Profit,
       BusinessTax,
       ProfitAfterTax,
       TaxCarry,
       CapitalMovement = CONVERT(decimal(38,5), CapitalMovement),
       OpeningSubjectPosition,
       OpeningAccountPosition,
       OpeningLossesCarriedForward,
       ClosingLossesCarriedForward,
       LossesCarriedForwardDelta,
       CapitalDelta = CONVERT(decimal(38,5), CapitalDelta),
       Variance = CONVERT(decimal(38,5), CapitalDelta
           - (ProfitAfterTax + CapitalMovement + OpeningAccountPosition))
INTO #Legacy
FROM reconciliation;

SELECT YearNumber,
       Description,
       OpeningCapital,
       ClosingCapital,
       Profit,
       BusinessTax,
       ProfitAfterTax,
       TaxCarry,
       CapitalMovement,
       OpeningSubjectPosition,
       OpeningAccountPosition,
       OpeningLossesCarriedForward,
       ClosingLossesCarriedForward,
       LossesCarriedForwardDelta,
       CapitalDelta,
       Variance
INTO #Wrapper
FROM Cash.vwEquityReconciliationByYear;

SELECT YearNumber,
       Description,
       OpeningCapital,
       ClosingCapital,
       Profit,
       BusinessTax,
       ProfitAfterTax,
       TaxCarry,
       CapitalMovement,
       OpeningSubjectPosition,
       OpeningAccountPosition,
       OpeningLossesCarriedForward,
       ClosingLossesCarriedForward,
       LossesCarriedForwardDelta,
       CapitalDelta,
       Variance
INTO #Versioned
FROM Cash.fnEquityReconciliationByYearByVersion(@CategoryVersionId);

IF EXISTS (SELECT * FROM #Legacy EXCEPT SELECT * FROM #Wrapper)
   OR EXISTS (SELECT * FROM #Wrapper EXCEPT SELECT * FROM #Legacy)
    THROW 51132, 'The 4.1.20 active wrapper differs from the 4.1.19 Equity Bridge body.', 1;

IF EXISTS (SELECT * FROM #Legacy EXCEPT SELECT * FROM #Versioned)
   OR EXISTS (SELECT * FROM #Versioned EXCEPT SELECT * FROM #Legacy)
    THROW 51133, 'The version-explicit Equity Bridge differs from the 4.1.19 Equity Bridge body.', 1;

SELECT DatabaseName = DB_NAME(),
       InstalledBuild = App.fnVersion(),
       CategoryVersionId = @CategoryVersionId,
       YearsCompared = COUNT(*),
       LossYears = SUM(CASE WHEN Profit < 0 THEN 1 ELSE 0 END),
       CarryForwardYears = SUM(CASE WHEN ClosingLossesCarriedForward > 0 THEN 1 ELSE 0 END),
       MaximumAbsoluteVariance = MAX(ABS(Variance)),
       Result = N'PASS'
FROM #Versioned;

SELECT YearNumber,
       Description,
       Profit,
       BusinessTax,
       TaxCarry,
       OpeningLossesCarriedForward,
       ClosingLossesCarriedForward,
       LossesCarriedForwardDelta,
       Variance
FROM #Versioned
ORDER BY YearNumber;
