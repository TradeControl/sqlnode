CREATE VIEW Cash.vwReserveAccount
AS
	SELECT TOP 1 CashAccountCode, LiquidityLevel, CashAccountName, AccountNumber, SortCode 
	FROM Subject.tbAccount 
			LEFT OUTER JOIN Cash.tbCode ON Subject.tbAccount.CashCode = Cash.tbCode.CashCode 
	WHERE (Cash.tbCode.CashCode) IS NULL AND (Subject.tbAccount.AccountTypeCode = 0) AND (Subject.tbAccount.AccountClosed = 0)
	ORDER BY CashAccountCode
