CREATE VIEW Cash.vwCurrentAccount
AS
	SELECT TOP (1) Subject.tbAccount.CashAccountCode, Subject.tbAccount.LiquidityLevel, Subject.tbAccount.CashAccountName, Subject.tbAccount.AccountNumber, Subject.tbAccount.SortCode, Subject.tbAccount.AccountCode, Subject.tbSubject.AccountName
	FROM            Subject.tbAccount INNER JOIN
							 Cash.tbCode ON Subject.tbAccount.CashCode = Cash.tbCode.CashCode INNER JOIN
							 Cash.tbCategory ON Cash.tbCode.CategoryCode = Cash.tbCategory.CategoryCode INNER JOIN
							 Subject.tbSubject ON Subject.tbAccount.AccountCode = Subject.tbSubject.AccountCode
	WHERE        (Cash.tbCategory.CashTypeCode = 2) AND (Subject.tbAccount.AccountTypeCode = 0) AND (Subject.tbAccount.AccountClosed = 0)
	ORDER BY Subject.tbAccount.CashAccountCode;
