CREATE   VIEW Cash.vwBalanceSheetAssets
AS
	WITH asset_statements AS
	(
		SELECT account_statement.CashAccountCode, StartOn, EntryNumber, PaidBalance
		FROM Cash.vwAccountStatement account_statement
			JOIN Org.tbAccount account ON account_statement.CashAccountCode = account.CashAccountCode
		WHERE StartOn >= (SELECT StartOn FROM Cash.vwBalanceStartOn) AND account.AccountTypeCode = 2
	), asset_last_tx AS
	(
		SELECT CashAccountCode, MAX(EntryNumber) EntryNumber
		FROM asset_statements
		GROUP BY CashAccountCode, StartOn
	), asset_polarity AS
	(
		SELECT asset_statements.CashAccountCode, asset_statements.StartOn, SUM(asset_statements.PaidBalance) Balance
		FROM asset_statements
			JOIN asset_last_tx ON asset_statements.CashAccountCode = asset_last_tx.CashAccountCode AND asset_statements.EntryNumber = asset_last_tx.EntryNumber
		GROUP BY asset_statements.CashAccountCode, asset_statements.StartOn
	), asset_base AS
	(
		SELECT CashAccountCode, asset_polarity.StartOn, asset_polarity.Balance, CASE WHEN Balance < 0 THEN 0 ELSE 1 END CashModeCode
		FROM asset_polarity
	)
	SELECT account.CashAccountCode AssetCode, account.CashAccountName AssetName, CashModeCode, 4 AssetTypeCode, StartOn, Balance
	FROM asset_base
		JOIN Org.tbAccount account ON asset_base.CashAccountCode = account.CashAccountCode;

