CREATE   VIEW Invoice.vwChangeLog
AS
	SELECT LogId, InvoiceNumber, ChangedOn, changelog.TransmitStatusCode, transmit.TransmitStatus, changelog.InvoiceStatusCode, invoicestatus.InvoiceStatus, DueOn, InvoiceValue, TaxValue, PaidValue, PaidTaxValue, UpdatedBy
	FROM Invoice.tbChangeLog changelog
		JOIN Org.tbTransmitStatus transmit ON changelog.TransmitStatusCode = transmit.TransmitStatusCode
		JOIN Invoice.tbStatus invoicestatus ON changelog.InvoiceStatusCode = invoicestatus.InvoiceStatusCode;
