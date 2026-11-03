CREATE   VIEW Cash.vwCode
AS
	SELECT        Cash.vwCodeActive.CashCode, Cash.vwCodeActive.CashDescription, Cash.vwCodeActive.CategoryCode, Cash.vwCategoryActive.Category, Cash.tbPolarity.CashPolarityCode, Cash.tbPolarity.CashPolarity, App.tbTaxCode.TaxDescription, 
							 Cash.vwCategoryActive.CashTypeCode, Cash.tbType.CashType, CAST(Cash.vwCodeActive.IsEnabled AS bit) AS IsCashEnabled, CAST(Cash.vwCategoryActive.IsEnabled AS bit) AS IsCategoryEnabled, Cash.vwCodeActive.InsertedBy, 
							 Cash.vwCodeActive.InsertedOn, Cash.vwCodeActive.UpdatedBy, Cash.vwCodeActive.UpdatedOn
	FROM            Cash.vwCodeActive INNER JOIN
							 Cash.vwCategoryActive ON Cash.vwCodeActive.CategoryCode = Cash.vwCategoryActive.CategoryCode INNER JOIN
							 Cash.tbPolarity ON Cash.vwCategoryActive.CashPolarityCode = Cash.tbPolarity.CashPolarityCode INNER JOIN
							 Cash.tbType ON Cash.vwCategoryActive.CashTypeCode = Cash.tbType.CashTypeCode INNER JOIN
							 App.tbTaxCode ON Cash.vwCodeActive.TaxCode = App.tbTaxCode.TaxCode
