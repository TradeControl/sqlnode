CREATE FUNCTION App.fnStatementPeriods()
RETURNS TABLE
AS
RETURN
(
    WITH periods AS
    (
        SELECT
            period.YearNumber,
            period.MonthNumber,
            CONVERT(date, period.StartOn) AS StartOn,
            CONVERT(date, LEAD(period.StartOn, 1, DATEADD(month, 1, period.StartOn))
                OVER (ORDER BY period.StartOn)) AS NextStartOn
        FROM App.tbYearPeriod AS period
        JOIN App.tbYear AS year
          ON year.YearNumber = period.YearNumber
        WHERE year.CashStatusCode < 3
    )
    SELECT
        YearNumber,
        MonthNumber,
        StartOn,
        DATEADD(day, -1, NextStartOn) AS EndOn
    FROM periods
);
