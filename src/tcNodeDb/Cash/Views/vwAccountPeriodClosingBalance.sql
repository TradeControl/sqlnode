CREATE VIEW Cash.vwAccountPeriodClosingBalance
AS
	WITH last_entries AS
	(
		SELECT     CashAccountCode, StartOn, MAX(EntryNumber) AS LastEntry
		FROM         Cash.vwAccountStatement
		GROUP BY CashAccountCode, StartOn
		HAVING      (NOT (StartOn IS NULL))
	)
	SELECT        Org.tbAccount.CashAccountCode, Org.tbAccount.CashCode, last_entries.StartOn, SUM(Cash.vwAccountStatement.PaidBalance) AS ClosingBalance
	FROM            last_entries INNER JOIN
							 Cash.vwAccountStatement ON last_entries.CashAccountCode = Cash.vwAccountStatement.CashAccountCode AND 
							 last_entries.StartOn = Cash.vwAccountStatement.StartOn AND 
							 last_entries.LastEntry = Cash.vwAccountStatement.EntryNumber INNER JOIN
							 Org.tbAccount ON last_entries.CashAccountCode = Org.tbAccount.CashAccountCode
	GROUP BY Org.tbAccount.CashAccountCode, Org.tbAccount.CashCode, last_entries.StartOn
