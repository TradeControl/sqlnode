/*
    Loss-making synthetic Equity Bridge fixture.

    Destructive when @Apply = 1. Run only against the backed-up local company
    MIN tree database named below. The Standard company template is selected
    deliberately because its ordinary opening-position bridge is already an
    accepted within-tolerance synthetic baseline.

    After this fixture, run CategoryTreeEquityReconciliationBuild20.sql to
    compare the complete 4.1.19 body with both 4.1.20 calculation paths.
*/
SET NOCOUNT ON;
SET XACT_ABORT ON;

DECLARE @Apply bit = 0;
DECLARE @ExpectedDatabase sysname = N'tcNodeDb4-COMIPFVT1-COMIN26';

IF DB_NAME() <> @ExpectedDatabase
    THROW 51150, 'The loss fixture is restricted to the local company MIN tree database.', 1;

IF App.fnVersion() <> N'4.1.20'
    THROW 51151, 'The loss fixture requires tcNodeDb4 4.1.20.', 1;

IF @Apply = 0
BEGIN
    SELECT DatabaseName = DB_NAME(),
           InstalledBuild = App.fnVersion(),
           ApplyChanges = @Apply,
           TemplateCode = N'COSTD26',
           PriceRatio = CONVERT(decimal(18,7), 0.5),
           CompletedYearCount = 2,
           AsOfDate = CONVERT(date, '20261105'),
           Result = N'DRY RUN - set @Apply = 1 after confirming the recovery point.';
    RETURN;
END;

EXEC App.proc_DatasetSyntheticMIS
    @IsCompany = 1,
    @IsVatRegistered = 1,
    @PriceRatio = 0.5000000,
    @UseStdCompanyTemplate = 1,
    @CompletedYearCount = 2,
    @FinancialMonth = 4,
    @AsOfDate = '20261105';

DECLARE @CategoryVersionId nvarchar(10) =
(
    SELECT CategoryVersionId
    FROM App.tbOptions
);

SELECT YearNumber,
       Description,
       Profit,
       BusinessTax,
       ProfitAfterTax,
       TaxCarry,
       OpeningLossesCarriedForward,
       ClosingLossesCarriedForward,
       LossesCarriedForwardDelta,
       Variance
INTO #Bridge
FROM Cash.fnEquityReconciliationByYearByVersion(@CategoryVersionId);

IF Cash.fnGetBizTaxType() <> 0
    THROW 51152, 'The loss fixture did not generate a company corporation-tax context.', 1;

IF (SELECT COUNT(*) FROM #Bridge WHERE Profit < 0) < 2
    THROW 51153, 'The loss fixture did not generate the required multi-year losses.', 1;

IF NOT EXISTS
(
    SELECT 1
    FROM #Bridge
    WHERE OpeningLossesCarriedForward > 0
      AND ClosingLossesCarriedForward > OpeningLossesCarriedForward
)
    THROW 51154, 'The loss fixture did not exercise loss carry-forward.', 1;

IF EXISTS
(
    SELECT 1
    FROM #Bridge
    WHERE Profit < 0
      AND BusinessTax <> 0
)
    THROW 51155, 'A loss year unexpectedly contains a corporation-tax expense.', 1;

IF EXISTS
(
    SELECT 1
    FROM #Bridge
    WHERE ABS(Variance) > 0.10
)
    THROW 51156, 'The loss-making Equity Bridge exceeds the reporting tolerance.', 1;

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

IF EXISTS (SELECT * FROM #Wrapper EXCEPT SELECT * FROM #Bridge)
   OR EXISTS (SELECT * FROM #Bridge EXCEPT SELECT * FROM #Wrapper)
    THROW 51157, 'The active wrapper differs from the loss-making version-explicit bridge.', 1;

SELECT DatabaseName = DB_NAME(),
       InstalledBuild = App.fnVersion(),
       CategoryVersionId = @CategoryVersionId,
       YearsCompared = COUNT(*),
       LossYears = SUM(CASE WHEN Profit < 0 THEN 1 ELSE 0 END),
       MaximumClosingLoss = MAX(ClosingLossesCarriedForward),
       MaximumAbsoluteVariance = MAX(ABS(Variance)),
       Result = N'PASS'
FROM #Bridge;

SELECT YearNumber,
       Description,
       Profit,
       BusinessTax,
       OpeningLossesCarriedForward,
       ClosingLossesCarriedForward,
       LossesCarriedForwardDelta,
       Variance
FROM #Bridge
ORDER BY YearNumber;
