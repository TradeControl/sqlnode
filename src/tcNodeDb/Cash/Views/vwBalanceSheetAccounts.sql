CREATE VIEW Cash.vwBalanceSheetAccounts
AS
	WITH account_statements AS
	(
		SELECT 
			account_statement.CashAccountCode, 
			StartOn, EntryNumber, PaidBalance
		FROM Cash.vwAccountStatement account_statement
			JOIN Org.tbAccount account ON account_statement.CashAccountCode = account.CashAccountCode
		WHERE StartOn >= (SELECT StartOn FROM Cash.vwBalanceStartOn) AND account.AccountTypeCode = 0
	)
	, account_last_tx AS
	(
		SELECT CashAccountCode, StartOn, MAX(EntryNumber) EntryNumber
		FROM account_statements
		GROUP BY CashAccountCode, StartOn
	)
	, account_balances AS
	(
		SELECT account_statements.CashAccountCode, account_statements.StartOn, account_statements.PaidBalance
		FROM account_statements
			JOIN account_last_tx ON account_statements.CashAccountCode = account_last_tx.CashAccountCode AND account_statements.EntryNumber = account_last_tx.EntryNumber
	)
	, account_polarity AS
	(
		SELECT CashCode, StartOn, SUM(PaidBalance) Balance
		FROM account_balances
			JOIN Org.tbAccount account ON account_balances.CashAccountCode = account.CashAccountCode
		GROUP BY CashCode, StartOn
	), account_base AS
	(
		SELECT 
			CASE WHEN NOT (CashCode IS NULL) 
				THEN (SELECT CashAccountCode FROM Cash.vwCurrentAccount) 
				ELSE (SELECT CashAccountCode FROM Cash.vwReserveAccount) 
			END AS AssetCode,
			CASE WHEN Balance < 0 THEN 0 ELSE 1 END CashModeCode,
			CASE WHEN (CashCode IS NULL) THEN 2 ELSE 3 END AssetTypeCode, StartOn, Balance
		FROM account_polarity
	)
	SELECT AssetCode, asset_type.AssetType AssetName, CashModeCode, asset_type.AssetTypeCode, StartOn, Balance
	FROM account_base
		JOIN Cash.tbAssetType asset_type ON account_base.AssetTypeCode = asset_type.AssetTypeCode;
