CREATE VIEW Cash.vwFlowVatRecurrenceAccruals
AS	
	WITH active_periods AS
	(
		SELECT App.tbYear.YearNumber, App.tbYearPeriod.StartOn
		FROM            App.tbYearPeriod INNER JOIN
								 App.tbMonth ON App.tbYearPeriod.MonthNumber = App.tbMonth.MonthNumber INNER JOIN
								 App.tbYear ON App.tbYearPeriod.YearNumber = App.tbYear.YearNumber
		WHERE        (App.tbYear.CashStatusCode < 3)
	),	vat_dates AS
	(
		SELECT PayFrom, PayTo FROM Cash.fnTaxTypeDueDates(1)
	), vatPeriod AS
	(
		SELECT        StartOn, y.YearNumber, p.MonthNumber,
			(SELECT PayTo FROM vat_dates WHERE p.StartOn >= PayFrom AND p.StartOn < PayTo) AS VatStartOn, VatAdjustment
		FROM            App.tbYearPeriod AS p JOIN App.tbYear AS y ON p.YearNumber = y.YearNumber 
	)
	, vat_accruals AS
	(
		SELECT  vatPeriod.VatStartOn AS StartOn,
				SUM(HomeSales) AS HomeSales, SUM(HomePurchases) AS HomePurchases, SUM(ExportSales) AS ExportSales, SUM(ExportPurchases) AS ExportPurchases, 
				SUM(HomeSalesVat) AS HomeSalesVat, SUM(HomePurchasesVat) AS HomePurchasesVat, 
				SUM(ExportSalesVat) AS ExportSalesVat, SUM(ExportPurchasesVat) AS ExportPurchasesVat, SUM(VatDue) AS VatDue
		FROM Cash.vwFlowVatPeriodAccruals accruals JOIN vatPeriod ON accruals.StartOn = vatPeriod.StartOn
		GROUP BY vatPeriod.VatStartOn
	)
	SELECT active_periods.YearNumber, active_periods.StartOn, CAST(ISNULL(HomeSales, 0) AS money) AS HomeSales, CAST(ISNULL(HomePurchases, 0) AS money) AS HomePurchases, 
		CAST(ISNULL(ExportSales, 0) AS money) AS ExportSales, CAST(ISNULL(ExportPurchases, 0) AS money) AS ExportPurchases, CAST(ISNULL(HomeSalesVat, 0) as money) AS HomeSalesVat, 
		CAST(ISNULL(HomePurchasesVat, 0) AS money) AS HomePurchasesVat, CAST(ISNULL(ExportSalesVat, 0) AS money) AS ExportSalesVat, 
		CAST(ISNULL(ExportPurchasesVat, 0) AS money) AS ExportPurchasesVat, CAST(ISNULL(VatDue, 0) AS money) AS VatDue 
	FROM vat_accruals 
		RIGHT OUTER JOIN active_periods ON active_periods.StartOn = vat_accruals.StartOn;		
