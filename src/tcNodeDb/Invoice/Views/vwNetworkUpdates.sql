﻿CREATE   VIEW Invoice.vwNetworkUpdates
AS
	WITH updates AS
	(
		SELECT DISTINCT InvoiceNumber FROM Invoice.tbChangeLog 
		WHERE TransmitStatusCode = 2
		EXCEPT
		SELECT DISTINCT InvoiceNumber FROM Invoice.tbChangeLog 
		WHERE TransmitStatusCode = 1
	)
	SELECT Invoice.tbInvoice.InvoiceNumber, Invoice.tbInvoice.AccountCode, Invoice.tbInvoice.InvoiceStatusCode,
			Invoice.tbInvoice.DueOn, Invoice.tbInvoice.PaidValue, Invoice.tbInvoice.PaidTaxValue
	FROM updates 
		JOIN Invoice.tbInvoice ON updates.InvoiceNumber = Invoice.tbInvoice.InvoiceNumber 
		JOIN Invoice.tbType ON Invoice.tbInvoice.InvoiceTypeCode = Invoice.tbType.InvoiceTypeCode
