﻿CREATE VIEW Invoice.vwCreditSpoolByItem
AS
	SELECT        credit_note.InvoiceNumber, Invoice.tbType.InvoiceType, credit_note.InvoiceStatusCode, Usr.tbUser.UserName, credit_note.AccountCode, Org.tbOrg.AccountName, Invoice.tbStatus.InvoiceStatus, credit_note.InvoicedOn, 
							 credit_note.InvoiceValue AS InvoiceValueTotal, credit_note.TaxValue AS TaxValueTotal, credit_note.PaymentTerms, credit_note.DueOn, credit_note.Notes, Org.tbOrg.EmailAddress, Org.tbAddress.Address AS InvoiceAddress, 
							 tbInvoiceItem.CashCode, Cash.tbCode.CashDescription, tbInvoiceItem.ItemReference, tbInvoiceItem.TaxCode, tbInvoiceItem.InvoiceValue, tbInvoiceItem.TaxValue
	FROM            Invoice.tbInvoice AS credit_note INNER JOIN
							 Invoice.tbStatus ON credit_note.InvoiceStatusCode = Invoice.tbStatus.InvoiceStatusCode INNER JOIN
							 Org.tbOrg ON credit_note.AccountCode = Org.tbOrg.AccountCode INNER JOIN
							 Usr.tbUser ON credit_note.UserId = Usr.tbUser.UserId LEFT OUTER JOIN
							 Org.tbAddress ON Org.tbOrg.AddressCode = Org.tbAddress.AddressCode INNER JOIN
							 Invoice.tbItem AS tbInvoiceItem ON credit_note.InvoiceNumber = tbInvoiceItem.InvoiceNumber INNER JOIN
							 Invoice.tbType ON credit_note.InvoiceTypeCode = Invoice.tbType.InvoiceTypeCode INNER JOIN
							 Cash.tbCode ON tbInvoiceItem.CashCode = Cash.tbCode.CashCode
	WHERE        (credit_note.InvoiceTypeCode = 1 OR
							 credit_note.InvoiceTypeCode = 3) AND EXISTS
								 (SELECT * FROM  App.tbDocSpool AS doc
								   WHERE (DocTypeCode BETWEEN 5 AND 6) AND (UserName = SUSER_SNAME()) AND (credit_note.InvoiceNumber = DocumentNumber))
							   