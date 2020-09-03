CREATE   VIEW Cash.vwBalanceSheetOrgs
AS
	WITH financial_periods AS
	(
		SELECT pd.StartOn
		FROM App.tbYear yr
			JOIN App.tbYearPeriod pd ON yr.YearNumber = pd.YearNumber
		WHERE (yr.CashStatusCode BETWEEN 1 AND 2)
	), org_periods AS
	(
		SELECT AccountCode, StartOn, CashModeCode
		FROM Org.tbOrg orgs
			JOIN Org.tbType org_types ON orgs.OrganisationTypeCode = org_types.OrganisationTypeCode
			CROSS JOIN financial_periods	
	), org_statements AS
	(
		SELECT (SELECT TOP 1 StartOn FROM App.tbYearPeriod	WHERE (StartOn <= os.TransactedOn) ORDER BY StartOn DESC) AS StartOn, 
			AccountCode, os.RowNumber, TransactedOn, Balance
		FROM Org.vwAssetStatement os
		WHERE TransactedOn >= (SELECT StartOn FROM Cash.vwBalanceStartOn)
	), org_last_tx AS
	(
		SELECT AccountCode, MAX(RowNumber) RowNumber
		FROM org_statements
		GROUP BY AccountCode, StartOn
	), org_last_balance AS
	(
		SELECT org_statements.AccountCode, org_statements.StartOn, org_statements.Balance, t.CashModeCode
		FROM org_statements 
			JOIN org_last_tx ON org_statements.AccountCode = org_last_tx.AccountCode AND org_statements.RowNumber = org_last_tx.RowNumber
			JOIN Org.tbOrg o ON org_statements.AccountCode = o.AccountCode
			JOIN Org.tbType t ON o.OrganisationTypeCode = t.OrganisationTypeCode
	)
	, org_balances AS
	(
		SELECT AccountCode, StartOn, CashModeCode,
			CASE CashModeCode WHEN 0 THEN MIN(Balance) WHEN 1 THEN MAX(Balance) ELSE MIN(Balance) END Balance
		FROM org_last_balance
		GROUP BY AccountCode, StartOn, CashModeCode
	), org_ordered AS
	(
		SELECT ROW_NUMBER() OVER (ORDER BY org_periods.AccountCode, org_periods.StartOn) EntryNumber,
			org_periods.AccountCode, org_periods.StartOn, 
			CASE WHEN org_balances.CashModeCode IS NULL THEN org_periods.CashModeCode ELSE org_balances.CashModeCode END CashModeCode, 
			COALESCE(Balance, 0) Balance,
			CASE WHEN org_balances.StartOn IS NULL THEN 0 ELSE 1 END IsEntry
		FROM org_periods
			LEFT OUTER JOIN org_balances 
				ON org_periods.AccountCode = org_balances.AccountCode AND org_periods.StartOn = org_balances.StartOn
	), org_ranked AS
	(
		SELECT *,
			RANK() OVER (PARTITION BY AccountCode, CashModeCode, IsEntry ORDER BY EntryNumber) RNK
		FROM org_ordered
	), org_grouped AS
	(
		SELECT EntryNumber, AccountCode, StartOn, CashModeCode, IsEntry, Balance,
			MAX(CASE IsEntry WHEN 0 THEN 0 ELSE RNK END) OVER (PARTITION BY AccountCode, CashModeCode ORDER BY EntryNumber) RNK
		FROM org_ranked
	), org_projected AS
	(
		SELECT EntryNumber, AccountCode, StartOn, CashModeCode, IsEntry,
			CASE IsEntry WHEN 0 THEN
				MAX(Balance) OVER (PARTITION BY AccountCode, CashModeCode, RNK ORDER BY EntryNumber) +
				MIN(Balance) OVER (PARTITION BY AccountCode, CashModeCode, RNK ORDER BY EntryNumber) 
			ELSE
				Balance
			END
			AS Balance
		FROM org_grouped	
	), org_polarity AS
	(
		SELECT StartOn, SUM(Balance) * -1 Balance, CashModeCode
		FROM org_projected
		GROUP BY StartOn, CashModeCode
	), org_base AS
	(
		SELECT 			
			CashModeCode,
			CASE WHEN Balance >= 0 THEN 0 ELSE 1 END AssetTypeCode, StartOn, Balance
		FROM org_polarity
	)
	SELECT 
		(SELECT CashAccountCode FROM Cash.vwCurrentAccount) AssetCode,
		AssetType AssetName, CashModeCode, asset_type.AssetTypeCode, StartOn, Balance
	FROM org_base
		JOIN Cash.tbAssetType asset_type ON org_base.AssetTypeCode = asset_type.AssetTypeCode;
