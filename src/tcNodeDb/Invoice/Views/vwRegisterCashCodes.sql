CREATE VIEW Invoice.vwRegisterCashCodes
AS
	SELECT TOP 100 PERCENT StartOn, CashCode, CashDescription, CAST(SUM(InvoiceValue) as float) AS TotalInvoiceValue, CAST(SUM(TaxValue) as float) AS TotalTaxValue
	FROM            Invoice.vwRegisterDetail
	GROUP BY StartOn, CashCode, CashDescription
	ORDER BY StartOn, CashCode;

