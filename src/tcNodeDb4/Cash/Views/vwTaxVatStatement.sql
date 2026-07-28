CREATE VIEW Cash.vwTaxVatStatement
AS
	WITH vat_dates AS
	(
		SELECT PayOn, PayFrom, PayTo FROM Cash.fnTaxTypeDueDates(1, 0)
	),
	vat_codes AS
	(
		SELECT CashCode
		FROM Cash.tbTaxType
		WHERE TaxTypeCode = 1
	),
	vat_results AS
	(
		SELECT StartOn, netVatDue
		FROM Cash.vwTaxVatSubmission
	),
	vat_unordered AS
	(
		SELECT
			vat_dates.PayOn AS StartOn,
			r.netVatDue AS VatDue,
			0 AS VatPaid
		FROM vat_results r
			JOIN vat_dates ON r.StartOn = vat_dates.PayTo

		UNION

		SELECT
			Cash.tbPayment.PaidOn AS StartOn,
			0 AS VatDue,
			(Cash.tbPayment.PaidOutValue * -1) + Cash.tbPayment.PaidInValue AS VatPaid
		FROM Cash.tbPayment
			INNER JOIN vat_codes ON Cash.tbPayment.CashCode = vat_codes.CashCode
	),
	vat_ordered AS
	(
		SELECT
			ROW_NUMBER() OVER (ORDER BY StartOn, VatDue) AS RowNumber,
			StartOn,
			VatDue,
			VatPaid
		FROM vat_unordered
	),
	vat_statement AS
	(
		SELECT
			RowNumber,
			StartOn,
			VatDue,
			VatPaid,
			SUM(VatDue + VatPaid) OVER (ORDER BY RowNumber ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS Balance
		FROM vat_ordered
	)
	SELECT
		RowNumber,
		StartOn,
		VatDue,
		VatPaid,
		CAST(Balance AS decimal(18,5)) AS Balance
	FROM vat_statement
	WHERE StartOn >=
	(
		SELECT MIN(StartOn)
		FROM App.tbYearPeriod p
			JOIN App.tbYear y ON p.YearNumber = y.YearNumber
		WHERE y.CashStatusCode < 3
	);
