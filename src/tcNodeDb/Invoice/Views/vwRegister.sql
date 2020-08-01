CREATE VIEW Invoice.vwRegister
AS
	SELECT       (SELECT TOP (1) p.StartOn FROM App.tbYearPeriod p WHERE (p.StartOn <= Invoice.tbInvoice.InvoicedOn) ORDER BY p.StartOn DESC) AS StartOn,  
			Invoice.tbInvoice.InvoiceNumber, Invoice.tbInvoice.AccountCode, Invoice.tbInvoice.InvoiceTypeCode, Invoice.tbInvoice.InvoiceStatusCode, 
							 Invoice.tbInvoice.InvoicedOn, CASE WHEN Invoice.tbType.CashModeCode = 0 THEN Invoice.tbInvoice.InvoiceValue * - 1 ELSE Invoice.tbInvoice.InvoiceValue END AS InvoiceValue, 
							 CASE WHEN Invoice.tbType.CashModeCode = 0 THEN Invoice.tbInvoice.TaxValue * - 1 ELSE Invoice.tbInvoice.TaxValue END AS TaxValue, 
							 CASE WHEN Invoice.tbType.CashModeCode = 0 THEN Invoice.tbInvoice.PaidValue * - 1 ELSE Invoice.tbInvoice.PaidValue END AS PaidValue, 
							 CASE WHEN Invoice.tbType.CashModeCode = 0 THEN Invoice.tbInvoice.PaidTaxValue * - 1 ELSE Invoice.tbInvoice.PaidTaxValue END AS PaidTaxValue, Invoice.tbInvoice.PaymentTerms, Invoice.tbInvoice.Notes, 
							 Invoice.tbInvoice.Printed, Org.tbOrg.AccountName, Usr.tbUser.UserName, Invoice.tbStatus.InvoiceStatus, Invoice.tbType.CashModeCode, Invoice.tbType.InvoiceType
	FROM            Invoice.tbInvoice INNER JOIN
							 Org.tbOrg ON Invoice.tbInvoice.AccountCode = Org.tbOrg.AccountCode INNER JOIN
							 Invoice.tbType ON Invoice.tbInvoice.InvoiceTypeCode = Invoice.tbType.InvoiceTypeCode INNER JOIN
							 Invoice.tbStatus ON Invoice.tbInvoice.InvoiceStatusCode = Invoice.tbStatus.InvoiceStatusCode INNER JOIN
							 Usr.tbUser ON Invoice.tbInvoice.UserId = Usr.tbUser.UserId
	WHERE        (Invoice.tbInvoice.AccountCode <> (SELECT AccountCode FROM App.tbOptions));

