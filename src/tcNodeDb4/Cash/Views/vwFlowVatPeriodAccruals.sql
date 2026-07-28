CREATE VIEW Cash.vwFlowVatPeriodAccruals
AS
	WITH active_periods AS
	(
		SELECT App.tbYear.YearNumber, App.tbYearPeriod.StartOn
		FROM App.tbYearPeriod
			INNER JOIN App.tbMonth ON App.tbYearPeriod.MonthNumber = App.tbMonth.MonthNumber
			INNER JOIN App.tbYear ON App.tbYearPeriod.YearNumber = App.tbYear.YearNumber
		WHERE App.tbYear.CashStatusCode < 3
	),
	vat_accruals AS
	(
		SELECT
			active_periods.YearNumber,
			active_periods.StartOn,
			ISNULL(SUM(vat_audit.vatDueSales), 0) AS vatDueSales,
			ISNULL(SUM(vat_audit.vatDueAcquisitions), 0) AS vatDueAcquisitions,
			ISNULL(SUM(vat_audit.vatReclaimedCurrPeriod), 0) AS vatReclaimedCurrPeriod,
			ISNULL(SUM(vat_audit.totalValueSalesExVAT), 0) AS totalValueSalesExVAT,
			ISNULL(SUM(vat_audit.totalValuePurchasesExVAT), 0) AS totalValuePurchasesExVAT,
			ISNULL(SUM(vat_audit.totalValueGoodsSuppliedExVAT), 0) AS totalValueGoodsSuppliedExVAT,
			ISNULL(SUM(vat_audit.totalValueGoodsReceivedExVAT), 0) AS totalValueGoodsReceivedExVAT
		FROM Cash.vwTaxVatAuditAccruals AS vat_audit
			RIGHT OUTER JOIN active_periods ON active_periods.StartOn = vat_audit.StartOn
		GROUP BY active_periods.YearNumber, active_periods.StartOn
	)
	SELECT
		YearNumber,
		StartOn,
		CAST(vatDueSales AS decimal(18,5)) AS vatDueSales,
		CAST(vatDueAcquisitions AS decimal(18,5)) AS vatDueAcquisitions,
		CAST(vatDueSales + vatDueAcquisitions AS decimal(18,5)) AS totalVatDue,
		CAST(vatReclaimedCurrPeriod + vatDueAcquisitions AS decimal(18,5)) AS vatReclaimedCurrPeriod,
		CAST(vatDueSales + vatDueAcquisitions + vatReclaimedCurrPeriod AS decimal(18,5)) AS netVatDue,
		CAST(totalValueSalesExVAT AS decimal(18,5)) AS totalValueSalesExVAT,
		CAST(totalValuePurchasesExVAT AS decimal(18,5)) AS totalValuePurchasesExVAT,
		CAST(totalValueGoodsSuppliedExVAT AS decimal(18,5)) AS totalValueGoodsSuppliedExVAT,
		CAST(totalValueGoodsReceivedExVAT AS decimal(18,5)) AS totalValueGoodsReceivedExVAT
	FROM vat_accruals;
