CREATE VIEW Cash.vwCategoryTotalCandidates
AS
	SELECT Cash.vwCategoryActive.CategoryCode, Cash.vwCategoryActive.Category, Cash.tbCategoryType.CategoryType, Cash.tbType.CashType, Cash.tbPolarity.CashPolarity
	FROM   Cash.vwCategoryActive INNER JOIN
				Cash.tbCategoryType ON Cash.vwCategoryActive.CategoryTypeCode = Cash.tbCategoryType.CategoryTypeCode INNER JOIN
				Cash.tbType ON Cash.vwCategoryActive.CashTypeCode = Cash.tbType.CashTypeCode INNER JOIN
				Cash.tbPolarity ON Cash.vwCategoryActive.CashPolarityCode = Cash.tbPolarity.CashPolarityCode
	WHERE        (Cash.vwCategoryActive.CashTypeCode < 2) AND (Cash.vwCategoryActive.IsEnabled <> 0)
	UNION
	SELECT CategoryCode, Category, CategoryType, CashType, CashPolarity
	FROM Cash.vwCategoryCapital
