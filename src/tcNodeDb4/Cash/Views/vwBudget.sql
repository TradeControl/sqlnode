CREATE VIEW Cash.vwBudget
AS
SELECT TOP 100 PERCENT code.CategoryCode, Cash.tbPeriod.CashCode, code.CashDescription,
	Cash.tbPeriod.StartOn, App.tbYearPeriod.YearNumber, App.tbMonth.MonthName, Format(App.tbYearPeriod.StartOn, 'yy-MM') AS Period,  
	Cash.tbPeriod.ForecastValue, Cash.tbPeriod.ForecastTax, Cash.tbPeriod.InvoiceValue, Cash.tbPeriod.InvoiceTax, Cash.tbPeriod.Note, Cash.tbPolarity.CashPolarity, App.tbTaxCode.TaxRate
FROM            App.tbYearPeriod INNER JOIN
                         Cash.tbPeriod ON App.tbYearPeriod.StartOn = Cash.tbPeriod.StartOn INNER JOIN
                         App.tbMonth ON App.tbYearPeriod.MonthNumber = App.tbMonth.MonthNumber INNER JOIN
                         Cash.vwCodeActive AS code ON Cash.tbPeriod.CashCode = code.CashCode INNER JOIN
                         Cash.vwCategoryActive AS category ON code.CategoryCode = category.CategoryCode INNER JOIN
						 Cash.tbPolarity ON category.CashPolarityCode = Cash.tbPolarity.CashPolarityCode INNER JOIN
                         App.tbTaxCode ON code.TaxCode = App.tbTaxCode.TaxCode


