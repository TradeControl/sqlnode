CREATE VIEW Cash.vwCurrentAccount
AS
	SELECT TOP (1) Subject.tbAccount.AccountCode, Subject.tbAccount.LiquidityLevel, Subject.tbAccount.AccountName, Subject.tbAccount.AccountNumber, Subject.tbAccount.SortCode, Subject.tbAccount.SubjectCode, Subject.tbSubject.SubjectName
	FROM            Subject.tbAccount INNER JOIN
							 Cash.vwCodeActive ON Subject.tbAccount.CashCode = Cash.vwCodeActive.CashCode INNER JOIN
							 Cash.vwCategoryActive ON Cash.vwCodeActive.CategoryCode = Cash.vwCategoryActive.CategoryCode INNER JOIN
							 Subject.tbSubject ON Subject.tbAccount.SubjectCode = Subject.tbSubject.SubjectCode
	WHERE        (Cash.vwCategoryActive.CashTypeCode = 2) AND (Subject.tbAccount.AccountTypeCode = 0) AND (Subject.tbAccount.AccountClosed = 0)
	ORDER BY Subject.tbAccount.AccountCode;
