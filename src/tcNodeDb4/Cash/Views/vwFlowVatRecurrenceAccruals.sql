CREATE VIEW Cash.vwFlowVatRecurrenceAccruals
AS	
	WITH active_periods AS
	(
		SELECT App.tbYear.YearNumber, App.tbYearPeriod.StartOn
		FROM App.tbYearPeriod
			INNER JOIN App.tbMonth ON App.tbYearPeriod.MonthNumber = App.tbMonth.MonthNumber
			INNER JOIN App.tbYear ON App.tbYearPeriod.YearNumber = App.tbYear.YearNumber
		WHERE App.tbYear.CashStatusCode < 3
	),
	vat_dates AS
	(
		SELECT PayFrom, PayTo FROM Cash.fnTaxTypeDueDates(1, 0)
	),
	vatPeriod AS
	(
		SELECT
			StartOn,
			y.YearNumber,
			p.MonthNumber,
			(
				SELECT PayTo
				FROM vat_dates
				WHERE p.StartOn >= PayFrom AND p.StartOn < PayTo
			) AS VatStartOn,
			VatAdjustment
		FROM App.tbYearPeriod AS p
			JOIN App.tbYear AS y ON p.YearNumber = y.YearNumber
	),
	vat_accruals AS
	(
		SELECT
			vatPeriod.VatStartOn AS StartOn,
			SUM(vatDueSales) AS vatDueSales,
			SUM(vatDueAcquisitions) AS vatDueAcquisitions,
			SUM(vatReclaimedCurrPeriod) AS vatReclaimedCurrPeriod,
			SUM(totalValueSalesExVAT) AS totalValueSalesExVAT,
			SUM(totalValuePurchasesExVAT) AS totalValuePurchasesExVAT,
			SUM(totalValueGoodsSuppliedExVAT) AS totalValueGoodsSuppliedExVAT,
			SUM(totalValueGoodsReceivedExVAT) AS totalValueGoodsReceivedExVAT
		FROM Cash.vwFlowVatPeriodAccruals AS accruals
			JOIN vatPeriod ON accruals.StartOn = vatPeriod.StartOn
		GROUP BY vatPeriod.VatStartOn
	)
	SELECT
		active_periods.YearNumber,
		active_periods.StartOn,
		CAST(ISNULL(vatDueSales, 0) AS decimal(18,5)) AS vatDueSales,
		CAST(ISNULL(vatDueAcquisitions, 0) AS decimal(18,5)) AS vatDueAcquisitions,
		CAST(ISNULL(vatDueSales, 0) + ISNULL(vatDueAcquisitions, 0) AS decimal(18,5)) AS totalVatDue,
		CAST(ISNULL(vatReclaimedCurrPeriod, 0) + ISNULL(vatDueAcquisitions, 0) AS decimal(18,5)) AS vatReclaimedCurrPeriod,
		CAST(ISNULL(vatDueSales, 0) + ISNULL(vatDueAcquisitions, 0) + ISNULL(vatReclaimedCurrPeriod, 0) AS decimal(18,5)) AS netVatDue,
		CAST(ISNULL(totalValueSalesExVAT, 0) AS decimal(18,5)) AS totalValueSalesExVAT,
		CAST(ISNULL(totalValuePurchasesExVAT, 0) AS decimal(18,5)) AS totalValuePurchasesExVAT,
		CAST(ISNULL(totalValueGoodsSuppliedExVAT, 0) AS decimal(18,5)) AS totalValueGoodsSuppliedExVAT,
		CAST(ISNULL(totalValueGoodsReceivedExVAT, 0) AS decimal(18,5)) AS totalValueGoodsReceivedExVAT
	FROM vat_accruals
		RIGHT OUTER JOIN active_periods ON active_periods.StartOn = vat_accruals.StartOn;
