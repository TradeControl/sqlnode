CREATE VIEW dbo.vwAccountsMode
AS 
	SELECT Invoice.tbInvoice.InvoiceNumber, Invoice.tbInvoice.UserId, Invoice.tbInvoice.AccountCode, Invoice.tbInvoice.InvoiceTypeCode, Invoice.tbInvoice.InvoiceStatusCode, Invoice.tbInvoice.InvoicedOn, Invoice.tbInvoice.Notes, 
		   Invoice.tbItem.CashCode, Invoice.tbItem.TaxCode, Invoice.tbItem.ItemReference, Invoice.tbInvoice.RowVer AS InvoiceRowVer, Invoice.tbItem.RowVer AS ItemRowVer, Invoice.tbItem.TotalValue, Invoice.tbItem.InvoiceValue, Invoice.tbInvoice.PaidValue, Invoice.tbInvoice.PaidTaxValue
	FROM Invoice.tbInvoice 
		INNER JOIN Invoice.tbItem ON Invoice.tbInvoice.InvoiceNumber = Invoice.tbItem.InvoiceNumber;
