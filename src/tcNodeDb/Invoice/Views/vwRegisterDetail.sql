CREATE VIEW Invoice.vwRegisterDetail
AS
	WITH register AS
	(
		SELECT     StartOn, InvoiceNumber, TaskCode, CashCode, CashDescription, TaxCode, TaxDescription, AccountCode, InvoiceTypeCode, InvoiceStatusCode, 
							  InvoicedOn, Quantity, InvoiceValue, TaxValue, PaymentTerms, Printed, AccountName, UserName, InvoiceStatus, CashModeCode, 
							  InvoiceType
		FROM         Invoice.vwRegisterTasks
		UNION
		SELECT     StartOn, InvoiceNumber, TaskCode, CashCode, CashDescription, TaxCode, TaxDescription, AccountCode, InvoiceTypeCode, InvoiceStatusCode, 
							  InvoicedOn, 0 Quantity, InvoiceValue, TaxValue, PaymentTerms, Printed, AccountName, UserName, InvoiceStatus, CashModeCode, 
							  InvoiceType
		FROM         Invoice.vwRegisterItems
	)
	SELECT StartOn, InvoiceNumber, TaskCode, CashCode, CashDescription, TaxCode, TaxDescription, AccountCode, InvoiceTypeCode, InvoiceStatusCode, InvoicedOn, PaymentTerms, Printed, AccountName, UserName, InvoiceStatus, CashModeCode, InvoiceType,
		CAST(Quantity as float) Quantity, CAST(InvoiceValue as float) InvoiceValue, CAST(TaxValue as float) TaxValue
	FROM register;
