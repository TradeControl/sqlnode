/*
    Category Tree version-explicit Equity Bridge acceptance.

    The operational Cash.vwEquityReconciliationByYear view is the protected
    accounting contract. This test proves that the separate parameterised
    calculation returns exactly the same result for the active version.

    Run against a rebuilt synthetic node after publishing the SQL project.
*/
SET NOCOUNT ON;

DECLARE @CategoryVersionId nvarchar(10) =
(
    SELECT CategoryVersionId
    FROM App.tbOptions
);

IF @CategoryVersionId IS NULL
    THROW 51121, 'The active Category Tree version is not configured.', 1;

IF OBJECT_ID(N'Cash.fnTaxCorpLiabilityUKByVersion', N'IF') IS NULL
    THROW 51123, 'The version-explicit UK Corporation Tax projection is not deployed.', 1;

IF OBJECT_ID(N'Cash.fnTaxBizComputationByYearSelectedByVersion', N'TF') IS NULL
    THROW 51124, 'The version-explicit business-tax provider is not deployed.', 1;

SELECT *
INTO #ExpectedTax
FROM Cash.fnTaxBizComputationByYearSelected();

SELECT *
INTO #ActualTax
FROM Cash.fnTaxBizComputationByYearSelectedByVersion(@CategoryVersionId);

IF EXISTS (SELECT * FROM #ExpectedTax EXCEPT SELECT * FROM #ActualTax)
   OR EXISTS (SELECT * FROM #ActualTax EXCEPT SELECT * FROM #ExpectedTax)
    THROW 51125, 'The active and version-explicit business-tax providers differ.', 1;

SELECT *
INTO #ExpectedUkLiability
FROM Cash.vwTaxCorpLiabilityUK;

SELECT *
INTO #ActualUkLiability
FROM Cash.fnTaxCorpLiabilityUKByVersion(@CategoryVersionId);

IF EXISTS (SELECT * FROM #ExpectedUkLiability EXCEPT SELECT * FROM #ActualUkLiability)
   OR EXISTS (SELECT * FROM #ActualUkLiability EXCEPT SELECT * FROM #ExpectedUkLiability)
    THROW 51126, 'The active UK CT view differs from its version-explicit projection.', 1;

SELECT *
INTO #Expected
FROM Cash.vwEquityReconciliationByYear;

SELECT TOP (0) *
INTO #Actual
FROM Cash.vwEquityReconciliationByYear;

INSERT INTO #Actual
SELECT *
FROM Cash.fnEquityReconciliationByYearByVersion(@CategoryVersionId);

IF EXISTS
(
    SELECT * FROM #Expected
    EXCEPT
    SELECT * FROM #Actual
)
OR EXISTS
(
    SELECT * FROM #Actual
    EXCEPT
    SELECT * FROM #Expected
)
    THROW 51122, 'The version-explicit Equity Bridge differs from the protected active view.', 1;

IF EXISTS
(
    SELECT 1
    FROM #Actual AS bridge
    JOIN #ActualTax AS tax
      ON tax.YearNumber = bridge.YearNumber
    WHERE bridge.BusinessTax <> ROUND(COALESCE(tax.TaxDue, 0), 2)
)
    THROW 51127, 'The Equity Bridge bypasses the jurisdiction-selected business-tax provider.', 1;

IF EXISTS (SELECT 1 FROM #Actual WHERE ABS(Variance) > 0.10)
    THROW 51128, 'The active Equity Bridge exceeds the reporting tolerance.', 1;

DECLARE @HistoricalVersionId nvarchar(10) =
(
    SELECT TOP (1) version.VersionId
    FROM Cash.tbCategoryVersion AS version
    WHERE version.VersionId <> @CategoryVersionId
      AND version.VersionStatusCode IN (2, 3)
    ORDER BY version.EffectiveFromOn DESC, version.CreatedOn DESC, version.VersionId DESC
);

IF @HistoricalVersionId IS NOT NULL
BEGIN
    IF NOT EXISTS
    (
        SELECT 1
        FROM Cash.fnEquityReconciliationByYearByVersion(@HistoricalVersionId)
    )
        THROW 51129, 'Historical Equity Bridge reconstruction returned no rows.', 1;
END;

DECLARE @Timing TABLE
(
    Iteration smallint NOT NULL,
    ExistingViewMilliseconds int NOT NULL,
    VersionedFunctionMilliseconds int NOT NULL
);

DECLARE @Iteration smallint = 1;
DECLARE @StartedAt datetime2(7);
DECLARE @ExistingViewMilliseconds int;
DECLARE @VersionedFunctionMilliseconds int;

WHILE @Iteration <= 5
BEGIN
    TRUNCATE TABLE #Expected;
    SET @StartedAt = SYSUTCDATETIME();

    INSERT INTO #Expected
    SELECT *
    FROM Cash.vwEquityReconciliationByYear;

    SET @ExistingViewMilliseconds = DATEDIFF(millisecond, @StartedAt, SYSUTCDATETIME());

    TRUNCATE TABLE #Actual;
    SET @StartedAt = SYSUTCDATETIME();

    INSERT INTO #Actual
    SELECT *
    FROM Cash.fnEquityReconciliationByYearByVersion(@CategoryVersionId);

    SET @VersionedFunctionMilliseconds = DATEDIFF(millisecond, @StartedAt, SYSUTCDATETIME());

    INSERT INTO @Timing
        (Iteration, ExistingViewMilliseconds, VersionedFunctionMilliseconds)
    VALUES
        (@Iteration, @ExistingViewMilliseconds, @VersionedFunctionMilliseconds);

    SET @Iteration += 1;
END;

SELECT CategoryVersionId = @CategoryVersionId,
       HistoricalVersionId = @HistoricalVersionId,
       YearsCompared = COUNT(*)
FROM #Actual;

SELECT Iteration,
       ExistingViewMilliseconds,
       VersionedFunctionMilliseconds
FROM @Timing
ORDER BY Iteration;
