
CREATE   VIEW App.vwYearPeriod
AS
SELECT TOP (100) PERCENT App.tbYear.Description, App.tbMonth.MonthName, App.tbYearPeriod.CashStatusCode, App.tbYearPeriod.YearNumber, App.tbYearPeriod.StartOn, App.tbYearPeriod.RowVer
FROM            App.tbYearPeriod INNER JOIN
                         App.tbMonth ON App.tbYearPeriod.MonthNumber = App.tbMonth.MonthNumber INNER JOIN
                         App.tbYear ON App.tbYearPeriod.YearNumber = App.tbYear.YearNumber
ORDER BY App.tbYearPeriod.YearNumber, App.tbYearPeriod.StartOn;
