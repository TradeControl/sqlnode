CREATE FUNCTION Cash.fnTaxBizCumulative
(
    @TaxSourceCode NVARCHAR(20),
    @PeriodStart DATE,
    @PeriodEnd DATE
)
RETURNS @Projection TABLE
(
    TaxSourceCode NVARCHAR(20) NOT NULL,
    PeriodStart DATE NOT NULL,
    PeriodEnd DATE NOT NULL,
    ValidationStatus NVARCHAR(12) NOT NULL,
    TagCode NVARCHAR(64) NOT NULL,
    StatutoryPolarityCode SMALLINT NOT NULL,
    Orientation NVARCHAR(10) NOT NULL,
    SupportStatus NVARCHAR(12) NOT NULL,
    TradeControlAmount DECIMAL(18, 5) NULL,
    StatutoryAmount DECIMAL(18, 5) NULL
)
AS
BEGIN
    DECLARE @StartYear SMALLINT =
        (SELECT TOP (1) YearNumber FROM App.tbYearPeriod WHERE StartOn = @PeriodStart);
    DECLARE @DatesValid BIT = CASE
        WHEN @PeriodStart <= @PeriodEnd
         AND MONTH(@PeriodStart) = 4 AND DAY(@PeriodStart) = 6
         AND @PeriodStart = (SELECT MIN(CAST(StartOn AS DATE)) FROM App.tbYearPeriod WHERE YearNumber = @StartYear)
         AND EXISTS
             (SELECT 1 FROM App.tbYearPeriod WHERE CAST(StartOn AS DATE) = DATEADD(DAY, 1, @PeriodEnd))
        THEN 1 ELSE 0 END;
    DECLARE @MappingsValid BIT = CASE WHEN EXISTS
        (SELECT 1 FROM Cash.fnTaxTagMapValidate(@TaxSourceCode) WHERE IsError = 1)
        THEN 0 ELSE 1 END;

    ;WITH Effective AS
    (
        SELECT DISTINCT TaxSourceCode, TagCode, CashCode, CashPolarityCode
        FROM Cash.vwTaxTagCashCode
        WHERE TaxSourceCode = @TaxSourceCode
    ),
    Amounts AS
    (
        SELECT
            e.TagCode,
            SUM(COALESCE(p.InvoiceValue, 0)) AS TradeControlAmount
        FROM Effective e
        LEFT JOIN Cash.vwCashCodePeriodValues p
          ON p.CashCode = e.CashCode
         AND p.CashPolarityCode = e.CashPolarityCode
         AND CAST(p.StartOn AS DATE) >= @PeriodStart
         AND CAST(p.StartOn AS DATE) <= @PeriodEnd
        GROUP BY e.TagCode
    )
    INSERT INTO @Projection
    SELECT
        t.TaxSourceCode,
        @PeriodStart,
        @PeriodEnd,
        CASE WHEN @DatesValid = 1 AND @MappingsValid = 1 THEN N'Ready' ELSE N'Invalid' END,
        t.TagCode,
        t.StatutoryPolarityCode,
        CASE t.StatutoryPolarityCode WHEN 1 THEN N'Income' ELSE N'Expense' END,
        CASE
            WHEN @DatesValid = 0 OR @MappingsValid = 0 THEN N'Invalid'
            WHEN a.TagCode IS NULL THEN N'Unsupported'
            ELSE N'Supported'
        END,
        CASE WHEN @DatesValid = 1 AND @MappingsValid = 1 THEN a.TradeControlAmount END,
        CASE
            WHEN @DatesValid = 0 OR @MappingsValid = 0 OR a.TagCode IS NULL THEN NULL
            WHEN t.StatutoryPolarityCode = 0 THEN a.TradeControlAmount * -1
            ELSE a.TradeControlAmount
        END
    FROM Cash.tbTaxTag t
    LEFT JOIN Amounts a ON a.TagCode = t.TagCode
    WHERE t.TaxSourceCode = @TaxSourceCode;

    RETURN;
END;
GO
