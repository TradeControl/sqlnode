CREATE VIEW Cash.vwTaxCorpTotalsByPeriod
AS
	WITH invoiced_tasks AS
	(
		SELECT (SELECT TOP (1) StartOn FROM App.tbYearPeriod WHERE (StartOn <= Invoice.tbInvoice.InvoicedOn) ORDER BY StartOn DESC) AS StartOn,  
								 CASE WHEN Invoice.tbType.CashModeCode = 0 THEN Invoice.tbTask.InvoiceValue * - 1 ELSE Invoice.tbTask.InvoiceValue END AS InvoiceValue
		FROM            Invoice.tbTask INNER JOIN
								 App.vwCorpTaxCashCodes CashCodes  ON Invoice.tbTask.CashCode = CashCodes.CashCode INNER JOIN
								 Invoice.tbInvoice ON Invoice.tbTask.InvoiceNumber = Invoice.tbInvoice.InvoiceNumber INNER JOIN
								 Invoice.tbType ON Invoice.tbInvoice.InvoiceTypeCode = Invoice.tbType.InvoiceTypeCode
	), invoiced_items AS
	(
		SELECT (SELECT TOP (1) StartOn FROM App.tbYearPeriod WHERE (StartOn <= Invoice.tbInvoice.InvoicedOn) ORDER BY StartOn DESC) AS StartOn,  
							  CASE WHEN Invoice.tbType.CashModeCode = 0 THEN Invoice.tbItem.InvoiceValue * - 1 ELSE Invoice.tbItem.InvoiceValue END AS InvoiceValue
		FROM         Invoice.tbItem INNER JOIN
							  App.vwCorpTaxCashCodes CashCodes ON Invoice.tbItem.CashCode = CashCodes.CashCode INNER JOIN
							  Invoice.tbInvoice ON Invoice.tbItem.InvoiceNumber = Invoice.tbInvoice.InvoiceNumber INNER JOIN
							  Invoice.tbType ON Invoice.tbInvoice.InvoiceTypeCode = Invoice.tbType.InvoiceTypeCode
	), netprofits AS	
	(
		SELECT StartOn, SUM(InvoiceValue) AS NetProfit FROM invoiced_tasks GROUP BY StartOn
		UNION
		SELECT StartOn, SUM(InvoiceValue) AS NetProfit FROM invoiced_items GROUP BY StartOn
	)
	, netprofit_consolidated AS
	(
		SELECT StartOn, SUM(NetProfit) AS NetProfit FROM netprofits GROUP BY StartOn
	)
	SELECT App.tbYearPeriod.StartOn, netprofit_consolidated.NetProfit, 
							netprofit_consolidated.NetProfit * App.tbYearPeriod.CorporationTaxRate + App.tbYearPeriod.TaxAdjustment AS CorporationTax, 
							App.tbYearPeriod.TaxAdjustment
	FROM         netprofit_consolidated INNER JOIN
							App.tbYearPeriod ON netprofit_consolidated.StartOn = App.tbYearPeriod.StartOn;

