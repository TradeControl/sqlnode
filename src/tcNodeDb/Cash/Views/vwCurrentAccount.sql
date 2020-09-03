CREATE   VIEW Cash.vwCurrentAccount
AS
	SELECT TOP 1 CashAccountCode, LiquidityLevel 
	FROM Org.tbAccount 
			JOIN Cash.tbCode ON Org.tbAccount.CashCode = Cash.tbCode.CashCode 
			JOIN Cash.tbCategory ON Cash.tbCode.CategoryCode = Cash.tbCategory.CategoryCode
	WHERE (Cash.tbCategory.CashTypeCode = 2) AND (Org.tbAccount.AccountTypeCode = 0) AND (Org.tbAccount.AccountClosed = 0)
	ORDER BY CashAccountCode
