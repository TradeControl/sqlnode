CREATE FUNCTION Cash.fnProfitAndLossDataByVersion
(
    @CategoryVersionId nvarchar(10)
)
RETURNS TABLE
AS
RETURN
(
    WITH active_periods AS
    (
        SELECT period.StartOn
        FROM App.tbYear AS year
        JOIN App.tbYearPeriod AS period
          ON period.YearNumber = year.YearNumber
        WHERE year.CashStatusCode BETWEEN 1 AND 2
    ),
    category_data AS
    (
        SELECT cash_code.CategoryCode,
               cash_code.CashTypeCode,
               period.StartOn,
               InvoiceValue = CASE cash_code.CashPolarityCode
                   WHEN 0 THEN period.InvoiceValue * -1
                   ELSE period.InvoiceValue
               END
        FROM App.fnTaxBizCashCodesByVersion(@CategoryVersionId) AS cash_code
        JOIN Cash.tbPeriod AS period
          ON period.CashCode = cash_code.CashCode
        JOIN active_periods
          ON active_periods.StartOn = period.StartOn
    )
    SELECT CategoryCode,
           CashTypeCode,
           StartOn,
           InvoiceValue = SUM(InvoiceValue)
    FROM category_data
    GROUP BY CategoryCode, CashTypeCode, StartOn
);
