/*
Rollback-only regression for the sole-trader cash-flow tax-rate estimate.
Run against a sole-trader synthetic sandbox after deployment.
*/
SET NOCOUNT ON;
SET XACT_ABORT ON;

IF NOT EXISTS
(
    SELECT 1
    FROM Cash.tbTaxType
    WHERE TaxTypeCode = 4
      AND IsEnabled <> 0
)
    THROW 51310, 'SoleTraderBusinessTaxRate requires a sole-trader sandbox.', 1;

BEGIN TRANSACTION;

DECLARE @ExpectedAnnualProfit decimal(18, 2) = 50000;
DECLARE @ExpectedBootstrapRate decimal(9, 6) =
    CAST(Cash.fnPersonalEffectiveRateCalculator(@ExpectedAnnualProfit) AS decimal(9, 6));

IF @ExpectedBootstrapRate <= 0 OR @ExpectedBootstrapRate = CAST(0.19 AS decimal(9, 6))
    THROW 51313, 'The sole-trader expected-profit calculation did not produce a distinct positive effective rate.', 1;

EXEC App.proc_DatasetSyntheticMIS_SoleTraderPersonalTaxRate @IsCompany = 0;

IF EXISTS (SELECT 1 FROM App.tbYearPeriod WHERE BusinessTaxRate <= 0)
    THROW 51311, 'A sole-trader period has a zero or negative business-tax planning rate.', 1;

DECLARE @FinalYear smallint = (SELECT MAX(YearNumber) FROM App.tbYear);
DECLARE @FinalRate decimal(9, 6) =
(
    SELECT MIN(BusinessTaxRate)
    FROM App.tbYearPeriod
    WHERE YearNumber = @FinalYear
);
DECLARE @PreviousRate decimal(9, 6) =
(
    SELECT MIN(BusinessTaxRate)
    FROM App.tbYearPeriod
    WHERE YearNumber = @FinalYear - 1
);

IF @FinalRate IS NULL OR @PreviousRate IS NULL OR @FinalRate <> @PreviousRate
    THROW 51312, 'The empty final forecast year did not inherit the latest planning rate.', 1;

ROLLBACK TRANSACTION;
PRINT 'Sole-trader business-tax planning-rate regression passed.';
