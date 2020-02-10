CREATE   FUNCTION Cash.fnFlowBankBalances (@CashAccountCode NVARCHAR(10))
RETURNS TABLE
AS
	RETURN
	WITH account_periods AS
	(
		SELECT    @CashAccountCode AS CashAccountCode, App.tbYear.YearNumber, App.tbYearPeriod.StartOn
		FROM            App.tbYearPeriod INNER JOIN
								 App.tbYear ON App.tbYearPeriod.YearNumber = App.tbYear.YearNumber
		WHERE        (App.tbYear.CashStatusCode < 3)
	), last_entries AS
	(
		SELECT account_statement.CashAccountCode, account_statement.StartOn, MAX(account_statement.EntryNumber) As EntryNumber
		FROM Cash.vwAccountStatement account_statement 
		WHERE account_statement.CashAccountCode = @CashAccountCode
		GROUP BY account_statement.CashAccountCode, account_statement.StartOn
	), closing_balance AS
	(
		SELECT account_statement.CashAccountCode,  account_statement.StartOn, account_statement.PaidBalance 
		FROM last_entries 
			JOIN Cash.vwAccountStatement account_statement ON last_entries.CashAccountCode = account_statement.CashAccountCode
				AND last_entries.EntryNumber = account_statement.EntryNumber
	)
	SELECT account_periods.CashAccountCode, account_periods.YearNumber, account_periods.StartOn, closing_balance.PaidBalance
	FROM account_periods
		LEFT OUTER JOIN closing_balance ON account_periods.CashAccountCode = closing_balance.CashAccountCode
												AND account_periods.StartOn = closing_balance.StartOn;
