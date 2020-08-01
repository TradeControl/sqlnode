CREATE VIEW Invoice.vwRegisterCashCodes
AS
	SELECT TOP 100 PERCENT StartOn, CashCode, CashDescription, SUM(InvoiceValue) AS TotalInvoiceValue, SUM(TaxValue) AS TotalTaxValue
	FROM            Invoice.vwRegisterDetail
	GROUP BY StartOn, CashCode, CashDescription
	ORDER BY StartOn, CashCode;

