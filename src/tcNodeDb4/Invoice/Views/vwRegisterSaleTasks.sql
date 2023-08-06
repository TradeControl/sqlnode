CREATE VIEW Invoice.vwRegisterSaleProjects
AS
	SELECT        StartOn, InvoiceNumber, ProjectCode, CashCode, CashDescription, TaxCode, TaxDescription, AccountCode, InvoiceTypeCode, InvoiceStatusCode, InvoicedOn, InvoiceValue, TaxValue,
							 PaymentTerms, Printed, AccountName, UserName, InvoiceStatus, CashPolarityCode, InvoiceType
	FROM            Invoice.vwRegisterDetail
	WHERE        (InvoiceTypeCode < 2);

