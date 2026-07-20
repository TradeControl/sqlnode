
CREATE   VIEW Cash.vwCashCodePeriodValues 
AS
--cash code invoice value by period

	WITH active_periods AS
	(
		SELECT yr.YearNumber, pd.StartOn
		FROM App.tbYear yr
			JOIN App.tbYearPeriod pd ON yr.YearNumber = pd.YearNumber
		WHERE (yr.CashStatusCode BETWEEN 1 AND 2)
	)
	SELECT cc.CategoryCode, cc.CashCode, cat.CashTypeCode, cp.StartOn,
			CASE cat.CashPolarityCode WHEN 0 THEN cp.InvoiceValue * -1 ELSE cp.InvoiceValue END AS InvoiceValue
	FROM Cash.tbPeriod cp
		JOIN Cash.tbCode cc
			ON cp.CashCode = cc.CashCode
		JOIN Cash.tbCategory cat
			ON cc.CategoryCode = cat.CategoryCode
		JOIN active_periods ap
			ON ap.StartOn = cp.StartOn;