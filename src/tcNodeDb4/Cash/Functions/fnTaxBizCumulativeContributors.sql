CREATE FUNCTION Cash.fnTaxBizCumulativeContributors
(
    @TaxSourceCode NVARCHAR(20),
    @PeriodStart DATE,
    @PeriodEnd DATE
)
RETURNS TABLE
AS
RETURN
(
    WITH Effective AS
    (
        SELECT DISTINCT
            mapping.TaxSourceCode,
            mapping.TagCode,
            mapping.MapTypeCode,
            mapping.MappingRoot,
            mapping.CashCode,
            mapping.LeafCategoryCode,
            mapping.CashPolarityCode
        FROM Cash.vwTaxTagCashCode mapping
        WHERE mapping.TaxSourceCode = @TaxSourceCode
    )
    SELECT
        effective.TaxSourceCode,
        effective.TagCode,
        effective.MapTypeCode,
        effective.MappingRoot,
        effective.LeafCategoryCode,
        effective.CashCode,
        cashCode.CashDescription,
        effective.CashPolarityCode,
        CONVERT(DATE, period.StartOn) AS PeriodStartOn,
        periodValue.InvoiceValue AS TradeControlAmount,
        CONVERT(DECIMAL(18, 5),
            CASE effective.CashPolarityCode
                WHEN 0 THEN periodValue.InvoiceValue * -1
                ELSE periodValue.InvoiceValue
            END) AS StatutoryAmount,
        CONVERT(BINARY(8), cashCode.RowVer) AS CashCodeRowVer,
        CONVERT(BINARY(8), period.RowVer) AS PeriodRowVer,
        cashCode.UpdatedOn AS CashCodeUpdatedOn
    FROM Effective effective
    JOIN Cash.vwCashCodePeriodValues periodValue
      ON periodValue.CashCode = effective.CashCode
     AND periodValue.CashPolarityCode = effective.CashPolarityCode
    JOIN Cash.tbPeriod period
      ON period.CashCode = periodValue.CashCode
     AND period.StartOn = periodValue.StartOn
    JOIN Cash.tbCode cashCode
      ON cashCode.CashCode = effective.CashCode
    WHERE CONVERT(DATE, period.StartOn) >= @PeriodStart
      AND CONVERT(DATE, period.StartOn) <= @PeriodEnd
      AND @PeriodStart <= @PeriodEnd
);
GO
