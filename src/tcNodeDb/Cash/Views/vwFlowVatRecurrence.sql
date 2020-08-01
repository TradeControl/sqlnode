CREATE VIEW Cash.vwFlowVatRecurrence
AS
		WITH active_periods AS
	(
		SELECT App.tbYear.YearNumber, App.tbYearPeriod.StartOn
		FROM            App.tbYearPeriod INNER JOIN
								 App.tbMonth ON App.tbYearPeriod.MonthNumber = App.tbMonth.MonthNumber INNER JOIN
								 App.tbYear ON App.tbYearPeriod.YearNumber = App.tbYear.YearNumber
		WHERE        (App.tbYear.CashStatusCode < 3)
	)
	SELECT        active_periods.YearNumber, active_periods.StartOn, ISNULL(SUM(vat.HomeSales), 0) AS HomeSales, ISNULL(SUM(vat.HomePurchases), 0) AS HomePurchases, ISNULL(SUM(vat.ExportSales), 0) AS ExportSales, ISNULL(SUM(vat.ExportPurchases), 0) AS ExportPurchases, 
							 ISNULL(SUM(vat.HomeSalesVat), 0) AS HomeSalesVat, ISNULL(SUM(vat.HomePurchasesVat), 0) AS HomePurchasesVat, ISNULL(SUM(vat.ExportSalesVat), 0) AS ExportSalesVat, ISNULL(SUM(vat.ExportPurchasesVat), 0) AS ExportPurchasesVat, 
							 ISNULL(SUM(vat.VatAdjustment), 0) AS VatAdjustment, ISNULL(SUM(vat.VatDue), 0) AS VatDue
	FROM            active_periods LEFT OUTER JOIN
							 Cash.vwTaxVatTotals AS vat ON active_periods.StartOn = vat.StartOn
	GROUP BY active_periods.YearNumber, active_periods.StartOn;
