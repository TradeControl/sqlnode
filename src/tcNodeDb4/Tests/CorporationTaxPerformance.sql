/*
    Corporation Tax statement performance diagnostic.

    Executes the live and What-if statement graphs three times, proves stable
    result cardinality and totals, and reports elapsed milliseconds. Service-
    tier acceptance belongs with protected environment evidence, so this
    portable fixture deliberately does not impose a universal time limit.
*/
SET NOCOUNT ON;

DECLARE @Runs TABLE
(
    QueryName nvarchar(30) NOT NULL,
    RunNumber tinyint NOT NULL,
    ElapsedMilliseconds bigint NOT NULL,
    ResultRows bigint NOT NULL,
    PayIn decimal(38,5) NULL,
    PayOut decimal(38,5) NULL,
    BalanceChecksum decimal(38,5) NULL,
    PRIMARY KEY (QueryName, RunNumber)
);

DECLARE
    @RunNumber tinyint,
    @StartedAt datetime2(7),
    @ResultRows bigint,
    @PayIn decimal(38,5),
    @PayOut decimal(38,5),
    @BalanceChecksum decimal(38,5);

SET @RunNumber = 1;
WHILE @RunNumber <= 3
BEGIN
    SET @StartedAt = SYSUTCDATETIME();

    SELECT @ResultRows = COUNT_BIG(*),
           @PayIn = SUM(CONVERT(decimal(38,5), PayIn)),
           @PayOut = SUM(CONVERT(decimal(38,5), PayOut)),
           @BalanceChecksum = SUM(CONVERT(decimal(38,5), Balance))
    FROM Cash.vwStatement;

    INSERT @Runs
    (
        QueryName, RunNumber, ElapsedMilliseconds, ResultRows,
        PayIn, PayOut, BalanceChecksum
    )
    VALUES
    (
        N'Cash.vwStatement', @RunNumber,
        DATEDIFF_BIG(millisecond, @StartedAt, SYSUTCDATETIME()),
        @ResultRows, @PayIn, @PayOut, @BalanceChecksum
    );

    SET @RunNumber += 1;
END;

SET @RunNumber = 1;
WHILE @RunNumber <= 3
BEGIN
    SET @StartedAt = SYSUTCDATETIME();

    SELECT @ResultRows = COUNT_BIG(*),
           @PayIn = SUM(CONVERT(decimal(38,5), PayIn)),
           @PayOut = SUM(CONVERT(decimal(38,5), PayOut)),
           @BalanceChecksum = SUM(CONVERT(decimal(38,5), Balance))
    FROM Cash.vwStatementWhatIf;

    INSERT @Runs
    (
        QueryName, RunNumber, ElapsedMilliseconds, ResultRows,
        PayIn, PayOut, BalanceChecksum
    )
    VALUES
    (
        N'Cash.vwStatementWhatIf', @RunNumber,
        DATEDIFF_BIG(millisecond, @StartedAt, SYSUTCDATETIME()),
        @ResultRows, @PayIn, @PayOut, @BalanceChecksum
    );

    SET @RunNumber += 1;
END;

IF EXISTS
(
    SELECT QueryName
    FROM @Runs
    GROUP BY QueryName
    HAVING COUNT(*) <> 3
        OR MIN(ResultRows) = 0
        OR MIN(ResultRows) <> MAX(ResultRows)
        OR MIN(COALESCE(PayIn, 0)) <> MAX(COALESCE(PayIn, 0))
        OR MIN(COALESCE(PayOut, 0)) <> MAX(COALESCE(PayOut, 0))
        OR MIN(COALESCE(BalanceChecksum, 0)) <> MAX(COALESCE(BalanceChecksum, 0))
)
    THROW 51455, 'Corporation Tax statement performance runs did not return stable results.', 1;

SELECT QueryName,
       RunNumber,
       ElapsedMilliseconds,
       ResultRows,
       PayIn,
       PayOut,
       BalanceChecksum
FROM @Runs
ORDER BY QueryName, RunNumber;

PRINT 'Corporation Tax statement performance diagnostic passed.';
