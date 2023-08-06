CREATE VIEW Subject.vwWallets
AS
	SELECT        Subject.tbAccount.CashAccountCode, Subject.tbAccount.CashAccountName, Subject.tbAccount.CashCode, Subject.tbAccount.CoinTypeCode
	FROM            Subject.tbAccount INNER JOIN
							 App.tbOptions ON Subject.tbAccount.AccountCode = App.tbOptions.AccountCode LEFT OUTER JOIN
							 Cash.tbCode ON Subject.tbAccount.CashCode = Cash.tbCode.CashCode
	WHERE        (Subject.tbAccount.AccountTypeCode = 0) AND Subject.tbAccount.CoinTypeCode < 2;
