CREATE VIEW Object.vwCandidateCashCodes
AS
	SELECT Cash.vwCodeActive.CashCode, Cash.vwCodeActive.CashDescription, Cash.vwCategoryActive.Category, Cash.vwCategoryActive.CashPolarityCode, Cash.vwCategoryActive.CashTypeCode
	FROM            Cash.vwCodeActive INNER JOIN
							 Cash.vwCategoryActive ON Cash.vwCodeActive.CategoryCode = Cash.vwCategoryActive.CategoryCode
	WHERE        (Cash.vwCategoryActive.CashTypeCode < 2)  AND (Cash.vwCategoryActive.IsEnabled <> 0) AND (Cash.vwCodeActive.IsEnabled <> 0)
