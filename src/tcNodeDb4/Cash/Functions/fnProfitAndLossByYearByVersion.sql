CREATE FUNCTION Cash.fnProfitAndLossByYearByVersion
(
    @CategoryVersionId nvarchar(10)
)
RETURNS TABLE
AS
RETURN
(
    SELECT financial_year.YearNumber,
           financial_year.Description,
           category.DisplayOrder,
           category.CategoryCode,
           category.Category,
           category.CashTypeCode,
           InvoiceValue = SUM(profit_data.InvoiceValue)
    FROM Cash.fnProfitAndLossDataByVersion(@CategoryVersionId) AS profit_data
    JOIN Cash.tbCategory AS category
      ON category.VersionId = @CategoryVersionId
     AND category.CategoryCode = profit_data.CategoryCode
    JOIN App.tbYearPeriod AS period
      ON period.StartOn = profit_data.StartOn
    JOIN App.tbYear AS financial_year
      ON financial_year.YearNumber = period.YearNumber
    GROUP BY financial_year.YearNumber,
             financial_year.Description,
             category.DisplayOrder,
             category.CategoryCode,
             category.Category,
             category.CashTypeCode
);
