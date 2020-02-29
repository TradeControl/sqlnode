CREATE   VIEW Invoice.vwChangeLog AS
	SELECT LogId, InvoiceNumber, ChangedOn, transmit.TransmitStatusCode, transmit.TransmitStatus, invoicestatus.InvoiceStatus, DueOn, InvoiceValue, TaxValue, PaidValue, PaidTaxValue, UpdatedBy
	FROM Invoice.tbChangeLog changelog
		JOIN Org.tbTransmitStatus transmit ON changelog.TransmitStatusCode = transmit.TransmitStatusCode
		JOIN Invoice.tbStatus invoicestatus ON changelog.InvoiceStatusCode = invoicestatus.InvoiceStatusCode;
