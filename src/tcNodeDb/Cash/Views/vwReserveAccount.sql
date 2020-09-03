CREATE   VIEW Cash.vwReserveAccount
AS
	SELECT TOP 1 CashAccountCode, LiquidityLevel 
	FROM Org.tbAccount 
			LEFT OUTER JOIN Cash.tbCode ON Org.tbAccount.CashCode = Cash.tbCode.CashCode 
	WHERE (Cash.tbCode.CashCode) IS NULL AND (Org.tbAccount.AccountTypeCode = 0) AND (Org.tbAccount.AccountClosed = 0)
	ORDER BY CashAccountCode
