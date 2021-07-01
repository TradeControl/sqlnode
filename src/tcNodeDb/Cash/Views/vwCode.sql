﻿CREATE   VIEW Cash.vwCode
AS
	SELECT        Cash.tbCode.CashCode, Cash.tbCode.CashDescription, Cash.tbCode.CategoryCode, Cash.tbCategory.Category, Cash.tbMode.CashModeCode, Cash.tbMode.CashMode, App.tbTaxCode.TaxDescription, 
							 Cash.tbCategory.CashTypeCode, Cash.tbType.CashType, CAST(Cash.tbCode.IsEnabled AS bit) AS IsCashEnabled, CAST(Cash.tbCategory.IsEnabled AS bit) AS IsCategoryEnabled, Cash.tbCode.InsertedBy, 
							 Cash.tbCode.InsertedOn, Cash.tbCode.UpdatedBy, Cash.tbCode.UpdatedOn
	FROM            Cash.tbCode INNER JOIN
							 Cash.tbCategory ON Cash.tbCode.CategoryCode = Cash.tbCategory.CategoryCode INNER JOIN
							 Cash.tbMode ON Cash.tbCategory.CashModeCode = Cash.tbMode.CashModeCode INNER JOIN
							 Cash.tbType ON Cash.tbCategory.CashTypeCode = Cash.tbType.CashTypeCode INNER JOIN
							 App.tbTaxCode ON Cash.tbCode.TaxCode = App.tbTaxCode.TaxCode
