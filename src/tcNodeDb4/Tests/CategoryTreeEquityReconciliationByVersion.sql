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
       YearsCompared = COUNT(*)
FROM #Actual;

SELECT Iteration,
       ExistingViewMilliseconds,
       VersionedFunctionMilliseconds
FROM @Timing
ORDER BY Iteration;
