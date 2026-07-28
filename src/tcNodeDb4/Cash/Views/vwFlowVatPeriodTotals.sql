CREATE VIEW Cash.vwFlowVatPeriodTotals
AS
	WITH active_periods AS
	(
		SELECT App.tbYear.YearNumber, App.tbYearPeriod.StartOn
		FROM App.tbYearPeriod
			INNER JOIN App.tbMonth ON App.tbYearPeriod.MonthNumber = App.tbMonth.MonthNumber
			INNER JOIN App.tbYear ON App.tbYearPeriod.YearNumber = App.tbYear.YearNumber
		WHERE App.tbYear.CashStatusCode < 3
	),
	vat_totals AS
	(
		SELECT
			active_periods.YearNumber,
			active_periods.StartOn,
			CAST(ISNULL(SUM(vat.vatDueSales), 0) AS decimal(18, 5)) AS vatDueSales,
			CAST(ISNULL(SUM(vat.vatDueAcquisitions), 0) AS decimal(18, 5)) AS vatDueAcquisitions,
			CAST(ISNULL(SUM(vat.vatReclaimedCurrPeriod), 0) AS decimal(18, 5)) AS vatReclaimedCurrPeriod,
			CAST(ISNULL(SUM(vat.totalValueSalesExVAT), 0) AS decimal(18, 5)) AS totalValueSalesExVAT,
			CAST(ISNULL(SUM(vat.totalValuePurchasesExVAT), 0) AS decimal(18, 5)) AS totalValuePurchasesExVAT,
			CAST(ISNULL(SUM(vat.totalValueGoodsSuppliedExVAT), 0) AS decimal(18, 5)) AS totalValueGoodsSuppliedExVAT,
			CAST(ISNULL(SUM(vat.totalValueGoodsReceivedExVAT), 0) AS decimal(18, 5)) AS totalValueGoodsReceivedExVAT
		FROM active_periods
			LEFT OUTER JOIN Cash.vwTaxVatSummary AS vat ON active_periods.StartOn = vat.StartOn
		GROUP BY active_periods.YearNumber, active_periods.StartOn
	)
	SELECT
		YearNumber,
		StartOn,
		vatDueSales,
		vatDueAcquisitions,
		CAST(vatDueSales + vatDueAcquisitions AS decimal(18, 5)) AS totalVatDue,
		vatReclaimedCurrPeriod,
		CAST(vatDueSales + vatDueAcquisitions + vatReclaimedCurrPeriod AS decimal(18, 5)) AS netVatDue,
		totalValueSalesExVAT,
		totalValuePurchasesExVAT,
		totalValueGoodsSuppliedExVAT,
		totalValueGoodsReceivedExVAT
	FROM vat_totals;
