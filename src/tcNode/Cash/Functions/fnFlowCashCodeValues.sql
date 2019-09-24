CREATE   FUNCTION Cash.fnFlowCashCodeValues(@CashCode nvarchar(50), @YearNumber smallint, @IncludeActivePeriods BIT = 0, @IncludeOrderBook BIT = 0, @IncludeTaxAccruals BIT = 0)
RETURNS TABLE
AS
	--ref Cash.proc_FlowCashCodeValues() for live implementation including accruals
   	RETURN (
		WITH invoice_history AS
		(
			SELECT        Cash.tbPeriod.CashCode, Cash.tbPeriod.StartOn, App.tbYearPeriod.CashStatusCode,
				CASE WHEN App.tbYearPeriod.CashStatusCode = 2 OR @IncludeActivePeriods <> 0 THEN Cash.tbPeriod.ForecastValue ELSE 0 END AS ForecastValue, 
				CASE WHEN App.tbYearPeriod.CashStatusCode = 2 OR @IncludeActivePeriods <> 0 THEN Cash.tbPeriod.ForecastTax ELSE 0 END AS ForecastTax, 
				CASE App.tbYearPeriod.CashStatusCode WHEN 2 THEN Cash.tbPeriod.InvoiceValue ELSE 0 END AS InvoiceValue, 
				CASE App.tbYearPeriod.CashStatusCode WHEN 2 THEN Cash.tbPeriod.InvoiceTax ELSE 0 END AS InvoiceTax
			FROM            Cash.tbPeriod INNER JOIN
									 App.tbYearPeriod ON Cash.tbPeriod.StartOn = App.tbYearPeriod.StartOn INNER JOIN
									 App.tbYear ON App.tbYearPeriod.YearNumber = App.tbYear.YearNumber
			WHERE        (App.tbYear.CashStatusCode < 3) AND (App.tbYearPeriod.YearNumber = @YearNumber) AND (Cash.tbPeriod.CashCode = @CashCode)
		), live_tasks AS
		(
			SELECT items.CashCode,
					(SELECT TOP (1) StartOn FROM App.tbYearPeriod AS p WHERE (StartOn <= invoices.InvoicedOn) ORDER BY StartOn DESC) AS StartOn,
					CASE WHEN invoice_type.CashModeCode = 0 THEN items.InvoiceValue * - 1 ELSE items.InvoiceValue END AS InvoiceValue, 
					CASE WHEN invoice_type.CashModeCode = 0 THEN items.TaxValue * - 1 ELSE items.TaxValue END AS InvoiceTax,
					0 AS ForecastValue,
					0 As ForecastTax 
			FROM Invoice.tbInvoice invoices
				JOIN Invoice.tbType invoice_type ON invoices.InvoiceTypeCode = invoice_type.InvoiceTypeCode
				JOIN Invoice.tbTask items ON invoices.InvoiceNumber = items.InvoiceNumber
			WHERE @IncludeActivePeriods <> 0 
				AND invoices.InvoicedOn >= (SELECT MIN(StartOn) FROM invoice_history WHERE CashStatusCode < 2)
				AND items.CashCode = @CashCode
		), live_items AS
		(
			SELECT items.CashCode,
					(SELECT TOP (1) StartOn FROM App.tbYearPeriod AS p WHERE (StartOn <= invoices.InvoicedOn) ORDER BY StartOn DESC) AS StartOn,
					CASE WHEN invoice_type.CashModeCode = 0 THEN items.InvoiceValue * - 1 ELSE items.InvoiceValue END AS InvoiceValue, 
					CASE WHEN invoice_type.CashModeCode = 0 THEN items.TaxValue * - 1 ELSE items.TaxValue END AS InvoiceTax,
					0 AS ForecastValue,
					0 As ForecastTax 
			FROM Invoice.tbInvoice invoices
				JOIN Invoice.tbType invoice_type ON invoices.InvoiceTypeCode = invoice_type.InvoiceTypeCode
				JOIN Invoice.tbItem items ON invoices.InvoiceNumber = items.InvoiceNumber
			WHERE @IncludeActivePeriods <> 0 
				AND invoices.InvoicedOn >= (SELECT MIN(StartOn) FROM invoice_history WHERE CashStatusCode < 2)
				AND items.CashCode = @CashCode
		), tasks AS
		(
			SELECT task.TaskCode,
					(SELECT        TOP (1) StartOn
					FROM            App.tbYearPeriod
					WHERE        (StartOn <= task.ActionOn)
					ORDER BY StartOn DESC) AS StartOn, task.TotalCharge, ISNULL(tax.TaxRate, 0) AS TaxRate
			FROM            Task.tbTask AS task INNER JOIN
										App.tbTaxCode AS tax ON task.TaxCode = tax.TaxCode
			WHERE   (@IncludeOrderBook <> 0) AND (task.CashCode = @CashCode) AND ((task.TaskStatusCode = 1) OR (task.TaskStatusCode = 2))
		), tasks_foryear AS
		(
			SELECT tasks.TaskCode, tasks.StartOn, tasks.TotalCharge, tasks.TaxRate
			FROM tasks
				JOIN invoice_history ON tasks.StartOn = invoice_history.StartOn		
		)
		, order_invoice_value AS
		(
			SELECT   invoices.TaskCode, tasks_foryear.StartOn, SUM(invoices.InvoiceValue) AS InvoiceValue, SUM(invoices.TaxValue) AS InvoiceTax
			FROM  Invoice.tbTask invoices
				JOIN tasks_foryear ON invoices.TaskCode = tasks_foryear.TaskCode 
			GROUP BY invoices.TaskCode, StartOn
		), orders AS
		(
			SELECT tasks_foryear.StartOn, 
				tasks_foryear.TotalCharge - ISNULL(order_invoice_value.InvoiceValue, 0) AS InvoiceValue,
				(tasks_foryear.TotalCharge * tasks_foryear.TaxRate) - ISNULL(order_invoice_value.InvoiceTax, 0) AS InvoiceTax
			FROM tasks_foryear LEFT OUTER JOIN order_invoice_value ON tasks_foryear.TaskCode = order_invoice_value.TaskCode
		), live_orders AS
		(
			SELECT StartOn, SUM(InvoiceValue) As InvoiceValue, SUM(InvoiceTax) As InvoiceTax, 0 AS ForecastValue, 0 As ForecastTax 
			FROM orders
			GROUP BY StartOn
		), corptax_due AS
		(
			SELECT corp_statement.StartOn, Balance AS InvoiceValue, 0 AS InvoiceTax, 0 AS ForecastValue, 0 As ForecastTax 
			FROM Cash.vwTaxCorpStatement corp_statement
				JOIN invoice_history ON invoice_history.StartOn = corp_statement.StartOn
			WHERE (@IncludeOrderBook <> 0) AND EXISTS (SELECT CashCode FROM Cash.tbTaxType WHERE CashCode = @CashCode AND TaxTypeCode = 0)			
				AND invoice_history.StartOn >= (SELECT MIN(StartOn) FROM invoice_history WHERE CashStatusCode < 2)
		), vat_balances AS
		(
			SELECT (SELECT TOP (1) StartOn FROM App.tbYearPeriod AS p WHERE (StartOn <= vat_statement.StartOn) ORDER BY StartOn DESC) AS StartOn, Balance 
			FROM Cash.vwTaxVatStatement vat_statement
			WHERE (@IncludeOrderBook <> 0) AND EXISTS (SELECT CashCode FROM Cash.tbTaxType WHERE CashCode = @CashCode AND TaxTypeCode = 1)			
				AND vat_statement.StartOn >= (SELECT MIN(StartOn) FROM invoice_history WHERE CashStatusCode < 2)
		), vat_due AS
		(
			SELECT invoice_history.StartOn, Balance AS InvoiceValue, 0 AS InvoiceTax, 0 AS ForecastValue, 0 As ForecastTax 
			FROM vat_balances
				JOIN invoice_history ON invoice_history.StartOn = vat_balances.StartOn
		)
		, resultset AS
		(
			SELECT StartOn, InvoiceValue, InvoiceTax, ForecastValue, ForecastTax FROM invoice_history
			UNION
			SELECT StartOn, InvoiceValue, InvoiceTax, ForecastValue, ForecastTax FROM live_tasks
			UNION
			SELECT StartOn, InvoiceValue, InvoiceTax, ForecastValue, ForecastTax FROM live_tasks
			UNION
			SELECT StartOn, InvoiceValue, InvoiceTax, ForecastValue, ForecastTax FROM live_orders
			UNION
			SELECT StartOn, InvoiceValue, InvoiceTax, ForecastValue, ForecastTax FROM corptax_due
			UNION
			SELECT StartOn, InvoiceValue, InvoiceTax, ForecastValue, ForecastTax FROM vat_due
		)
		SELECT StartOn, CAST(SUM(InvoiceValue) AS MONEY) AS InvoiceValue, CAST(SUM(InvoiceTax) AS MONEY) AS InvoiceTax, SUM(ForecastValue) AS ForecastValue, SUM(ForecastTax) AS ForecastTax
		FROM resultset
		GROUP BY StartOn
	)
