CREATE VIEW Cash.vwTransferCodeLookup
AS
	SELECT Cash.vwCodeActive.CashCode, Cash.vwCodeActive.CashDescription, Cash.vwCategoryActive.Category, Cash.tbPolarity.CashPolarity, Cash.tbPolarity.CashPolarityCode
	FROM Cash.vwCodeActive 
		INNER JOIN Cash.vwCategoryActive 
			ON Cash.vwCodeActive.CategoryCode = Cash.vwCategoryActive.CategoryCode 
		INNER JOIN Cash.tbPolarity 
			ON Cash.vwCategoryActive.CashPolarityCode = Cash.tbPolarity.CashPolarityCode 
		LEFT OUTER JOIN Subject.tbAccount 
			ON Cash.vwCodeActive.CashCode = Subject.tbAccount.CashCode
	WHERE 
		(Cash.vwCodeActive.IsEnabled <> 0) 
		AND (Cash.vwCategoryActive.IsEnabled <> 0) 
		AND (Cash.vwCategoryActive.CashTypeCode = 2) 
		AND (Cash.tbPolarity.CashPolarityCode < 2) 
		AND (Subject.tbAccount.AccountCode IS NULL)
