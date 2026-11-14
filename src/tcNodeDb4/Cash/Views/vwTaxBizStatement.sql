
CREATE VIEW Cash.vwTaxBizStatement
AS
	WITH period_totals AS
	(
		SELECT liability.PayOn AS StartOn, liability.LiabilityAmount AS BusinessTax
		FROM Cash.vwTaxBizLiability liability
		WHERE liability.IsAccrualReady = 1
		  AND liability.PayOn IS NOT NULL
	), tax_entries AS
	(
		SELECT StartOn, SUM(BusinessTax) AS TaxDue, 0 AS TaxPaid
		FROM period_totals
		WHERE NOT StartOn IS NULL
		GROUP BY StartOn
		
		UNION

		SELECT Cash.tbPayment.PaidOn AS StartOn, 0 As TaxDue, (Cash.tbPayment.PaidOutValue * -1) + Cash.tbPayment.PaidInValue AS TaxPaid
		FROM Cash.tbPayment 
			JOIN Cash.tbTaxType tt ON Cash.tbPayment.CashCode = tt.CashCode
		WHERE (tt.TaxTypeCode = Cash.fnGetBizTaxType())

	), tax_statement AS
	(
		SELECT StartOn, TaxDue, TaxPaid,
			SUM(TaxDue + TaxPaid) OVER (ORDER BY StartOn, TaxDue ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS Balance
		FROM tax_entries
	)
	SELECT StartOn, CAST(TaxDue AS decimal(18, 5)) TaxDue, CAST(TaxPaid AS decimal(18, 5)) TaxPaid, CAST(Balance AS decimal(18, 5)) Balance
	FROM tax_statement
	WHERE StartOn >= (SELECT MIN(StartOn) FROM App.tbYearPeriod p JOIN App.tbYear y ON p.YearNumber = y.YearNumber WHERE y.CashStatusCode < 3);
