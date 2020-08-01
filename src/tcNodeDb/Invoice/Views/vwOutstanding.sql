CREATE VIEW Invoice.vwOutstanding
AS
	WITH invoiced_items AS
	(
		SELECT        Invoice.tbItem.InvoiceNumber, '' AS TaskCode, Invoice.tbItem.CashCode, Invoice.tbItem.TaxCode, (Invoice.tbItem.InvoiceValue + Invoice.tbItem.TaxValue) - (Invoice.tbItem.PaidValue + Invoice.tbItem.PaidTaxValue)
								  AS OutstandingValue, CASE WHEN InvoiceValue = 0 THEN 0 ELSE TaxValue / InvoiceValue END AS TaxRate, App.tbTaxCode.RoundingCode, App.tbTaxCode.Decimals
		FROM            Invoice.tbItem INNER JOIN
								 App.tbTaxCode ON Invoice.tbItem.TaxCode = App.tbTaxCode.TaxCode
	), invoiced_tasks AS
	(
		SELECT        Invoice.tbTask.InvoiceNumber, Invoice.tbTask.TaskCode, Invoice.tbTask.CashCode, Invoice.tbTask.TaxCode, (Invoice.tbTask.InvoiceValue + Invoice.tbTask.TaxValue) 
								 - (Invoice.tbTask.PaidValue + Invoice.tbTask.PaidTaxValue) AS OutstandingValue, 
									CASE WHEN InvoiceValue = 0 THEN 0 ELSE TaxValue / InvoiceValue END AS TaxRate, App.tbTaxCode.RoundingCode, App.tbTaxCode.Decimals
		FROM            Invoice.tbTask INNER JOIN
								 App.tbTaxCode ON Invoice.tbTask.TaxCode = App.tbTaxCode.TaxCode
	), invoices_outstanding AS
	(
		SELECT        InvoiceNumber AS InvoiceNumber, TaskCode AS TaskCode, CashCode AS CashCode, TaxCode AS TaxCode, OutstandingValue, TaxRate, RoundingCode, Decimals
		FROM            invoiced_items
		UNION
		SELECT        InvoiceNumber AS InvoiceNumber, TaskCode AS TaskCode, CashCode AS CashCode, TaxCode AS TaxCode, OutstandingValue, TaxRate, RoundingCode, Decimals
		FROM            invoiced_tasks
	)
	SELECT Invoice.tbInvoice.AccountCode, Invoice.tbInvoice.DueOn, Invoice.tbInvoice.ExpectedOn, Invoice.tbInvoice.InvoiceNumber, invoices_outstanding.TaskCode, Invoice.tbInvoice.InvoiceStatusCode, 
							 Invoice.tbType.CashModeCode, invoices_outstanding.CashCode, invoices_outstanding.TaxCode, invoices_outstanding.TaxRate, invoices_outstanding.RoundingCode, invoices_outstanding.Decimals,
							 CASE WHEN Invoice.tbType.CashModeCode = 0 THEN OutstandingValue * - 1 ELSE OutstandingValue END AS ItemValue
	FROM            invoices_outstanding INNER JOIN
							 Invoice.tbInvoice ON invoices_outstanding.InvoiceNumber = Invoice.tbInvoice.InvoiceNumber INNER JOIN
							 Invoice.tbType ON Invoice.tbInvoice.InvoiceTypeCode = Invoice.tbType.InvoiceTypeCode
	WHERE        (Invoice.tbInvoice.InvoiceStatusCode = 1) OR
							 (Invoice.tbInvoice.InvoiceStatusCode = 2);

