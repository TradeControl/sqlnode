
CREATE   VIEW Cash.vwBalanceSheetPeriods
AS
	WITH financial_periods AS
	(
		SELECT yr.YearNumber, pd.StartOn
		FROM App.tbYear yr
			JOIN App.tbYearPeriod pd ON yr.YearNumber = pd.YearNumber
		WHERE (yr.CashStatusCode BETWEEN 1 AND 2)
	), assets AS
	(
		SELECT CashAccountCode AssetCode, CashAccountName AssetName, LiquidityLevel, 4 AssetTypeCode, 
			category.CashModeCode,
			YearNumber, StartOn
		FROM Org.tbAccount account
			JOIN Cash.tbCode cash_code ON account.CashCode = cash_code.CashCode
			JOIN Cash.tbCategory category ON cash_code.CategoryCode = category.CategoryCode
			CROSS JOIN financial_periods
		WHERE (AccountTypeCode= 2) AND (AccountClosed = 0)
	), cash AS
	(
		SELECT CashAccountCode AssetCode, AssetType AssetName, LiquidityLevel, AssetTypeCode, 1 CashModeCode, YearNumber, StartOn
		FROM Cash.tbAssetType
			CROSS JOIN Cash.vwCurrentAccount 
			CROSS JOIN financial_periods
		WHERE AssetTypeCode = 3
	), bank AS
	(
		SELECT CashAccountCode AssetCode, AssetType AssetName, LiquidityLevel, AssetTypeCode, 1 CashModeCode, YearNumber, StartOn
		FROM Cash.tbAssetType
			CROSS JOIN Cash.vwReserveAccount 
			CROSS JOIN financial_periods
		WHERE AssetTypeCode = 2
	), orgs AS
	(
		SELECT CashAccountCode AssetCode, AssetType AssetName, LiquidityLevel, AssetTypeCode,
			CASE AssetTypeCode WHEN 0 THEN 1 ELSE 0 END CashModeCode,
			YearNumber, StartOn
		FROM Cash.tbAssetType
			CROSS JOIN Cash.vwCurrentAccount
			CROSS JOIN financial_periods
		WHERE AssetTypeCode BETWEEN 0 AND 1
	), asset_code_periods AS
	(
		SELECT AssetCode, AssetName, CashModeCode, LiquidityLevel, AssetTypeCode, YearNumber, StartOn FROM assets
		UNION 
		SELECT AssetCode, AssetName, CashModeCode, LiquidityLevel, AssetTypeCode, YearNumber, StartOn FROM cash
		UNION
		SELECT AssetCode, AssetName, CashModeCode, LiquidityLevel, AssetTypeCode, YearNumber, StartOn FROM bank
		UNION
		SELECT AssetCode, AssetName, CashModeCode, LiquidityLevel, AssetTypeCode, YearNumber, StartOn FROM orgs
	)
	SELECT AssetCode, AssetName, CashModeCode, LiquidityLevel, AssetTypeCode, YearNumber, StartOn, CAST(0 as bit) IsEntry
	FROM asset_code_periods;
