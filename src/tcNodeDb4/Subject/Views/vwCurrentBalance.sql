CREATE   VIEW Subject.vwCurrentBalance
AS
	WITH current_balance AS
	(
		SELECT AccountCode, MAX(RowNumber) CurrentBalanceRow
		FROM Subject.vwStatement
		GROUP BY AccountCode
	)
	SELECT Subject_statement.AccountCode, Subject_statement.Balance
	FROM Subject.vwStatement Subject_statement
		JOIN current_balance ON Subject_statement.AccountCode = current_balance.AccountCode 
			AND Subject_statement.RowNumber = current_balance.CurrentBalanceRow
