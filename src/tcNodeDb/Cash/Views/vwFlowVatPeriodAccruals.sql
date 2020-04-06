CREATE   VIEW Cash.vwFlowVatPeriodAccruals
AS
	WITH active_periods AS
	(
		SELECT App.tbYear.YearNumber, App.tbYearPeriod.StartOn
		FROM            App.tbYearPeriod INNER JOIN
								 App.tbMonth ON App.tbYearPeriod.MonthNumber = App.tbMonth.MonthNumber INNER JOIN
								 App.tbYear ON App.tbYearPeriod.YearNumber = App.tbYear.YearNumber
		WHERE        (App.tbYear.CashStatusCode < 3)
	),	 vat_accruals AS
	(
		SELECT   active_periods.YearNumber, active_periods.StartOn, ISNULL(SUM(vat_audit.HomeSales), 0) AS HomeSales, ISNULL(SUM(vat_audit.HomePurchases), 0) AS HomePurchases, ISNULL(SUM(vat_audit.ExportSales), 0) AS ExportSales, ISNULL(SUM(vat_audit.ExportPurchases), 0) 
								 AS ExportPurchases, ISNULL(SUM(vat_audit.HomeSalesVat), 0) AS HomeSalesVat, ISNULL(SUM(vat_audit.HomePurchasesVat), 0) AS HomePurchasesVat, ISNULL(SUM(vat_audit.ExportSalesVat), 0) AS ExportSalesVat, 
								 ISNULL(SUM(vat_audit.ExportPurchasesVat), 0) AS ExportPurchasesVat
		FROM            Cash.vwTaxVatAuditAccruals AS vat_audit RIGHT OUTER JOIN
								 active_periods ON active_periods.StartOn = vat_audit.StartOn
		GROUP BY active_periods.YearNumber, active_periods.StartOn
	)
	SELECT YearNumber, StartOn, CAST(HomeSales AS money) HomeSales, CAST(HomePurchases AS money) HomePurchases, CAST(ExportSales AS money) AS ExportSales, 
		CAST(ExportPurchases AS money) ExportPurchases, CAST(HomeSalesVat AS money) HomeSalesVat, CAST(HomePurchasesVat AS money) HomePurchasesVat, 
		CAST(ExportSalesVat AS money) ExportSalesVat, CAST(ExportPurchasesVat AS money) ExportPurchasesVat,
		CAST((HomeSalesVat + ExportSalesVat) - (HomePurchasesVat + ExportPurchasesVat) AS money) VatDue
	FROM vat_accruals;