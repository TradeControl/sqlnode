CREATE VIEW Cash.vwCodeLookup
AS
	SELECT        Cash.vwCodeActive.CashCode, Cash.vwCodeActive.CashDescription, Cash.vwCategoryActive.Category, Cash.tbPolarity.CashPolarityCode, Cash.tbPolarity.CashPolarity, Cash.vwCodeActive.TaxCode, Cash.vwCategoryActive.CashTypeCode, Cash.tbType.CashType
	FROM            Cash.vwCodeActive INNER JOIN
							 Cash.vwCategoryActive ON Cash.vwCodeActive.CategoryCode = Cash.vwCategoryActive.CategoryCode INNER JOIN
							 Cash.tbPolarity ON Cash.vwCategoryActive.CashPolarityCode = Cash.tbPolarity.CashPolarityCode INNER JOIN
							 Cash.tbType ON Cash.vwCategoryActive.CashTypeCode = Cash.tbType.CashTypeCode
	WHERE        (Cash.vwCodeActive.IsEnabled <> 0) AND (Cash.vwCategoryActive.IsEnabled <> 0)
