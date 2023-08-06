CREATE VIEW Subject.vwCashAccountAssets
AS
	SELECT        Subject.tbAccount.CashAccountCode, Subject.tbAccount.LiquidityLevel, Subject.tbAccount.CashAccountName, Subject.tbAccount.AccountCode, Cash.tbCode.CashCode, Cash.tbCode.TaxCode, Subject.tbAccount.AccountClosed
	FROM            Subject.tbAccount INNER JOIN
							 Cash.tbCode ON Subject.tbAccount.CashCode = Cash.tbCode.CashCode
	WHERE        (Subject.tbAccount.AccountTypeCode = 2);
