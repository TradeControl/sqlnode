CREATE VIEW App.vwYears
AS
    SELECT
        y.YearNumber,
        CONCAT(m.MonthName, ' ', y.YearNumber) AS StartMonth,
        y.CashStatusCode,
        s.CashStatus,
        y.Description,
        y.InsertedBy,
        y.InsertedOn
    FROM App.tbYear y
        INNER JOIN Cash.tbStatus s
            ON y.CashStatusCode = s.CashStatusCode
        INNER JOIN App.tbMonth m
            ON y.StartMonth = m.MonthNumber;
