﻿CREATE VIEW Cash.vwStatementReserves
AS
	WITH reserve_account AS
	(
		SELECT  Subject.tbAccount.AccountCode, Subject.tbAccount.AccountName, Subject.tbAccount.CurrentBalance
		FROM            Subject.tbAccount LEFT OUTER JOIN
								 Cash.tbCode ON Subject.tbAccount.CashCode = Cash.tbCode.CashCode 
		WHERE        (Subject.tbAccount.SubjectCode <> (SELECT SubjectCode FROM App.tbOptions))
			AND (Cash.tbCode.CashCode IS NULL) AND (Subject.tbAccount.AccountTypeCode = 0)
	), last_payment AS
	(
		SELECT MAX( payments.PaidOn) AS TransactOn
		FROM reserve_account JOIN Cash.tbPayment payments 
						ON reserve_account.AccountCode = payments.AccountCode 
		WHERE payments.PaymentStatusCode = 1
	
	), opening_balance AS
	(
		SELECT 	
			(SELECT SubjectCode FROM App.tbOptions) AS SubjectCode,		
			(SELECT TransactOn FROM last_payment) AS TransactOn,
			0 AS CashEntryTypeCode,
			(SELECT CAST(Message AS NVARCHAR) FROM App.tbText WHERE TextId = 1219) AS ReferenceCode,
			CASE WHEN SUM(CurrentBalance) > 0 THEN SUM(CurrentBalance) ELSE 0 END AS PayIn, 
			CASE WHEN SUM(CurrentBalance) < 0 THEN SUM(CurrentBalance) ELSE 0 END  AS PayOut
		FROM reserve_account 

	), unbalanced_reserves AS
	(
		SELECT  0 AS RowNumber, Subject.SubjectCode, Subject.SubjectName, TransactOn, CashEntryTypeCode, ReferenceCode, 
					PayOut, PayIn, NULL AS CashCode, NULL AS CashDescription
		FROM opening_balance
			JOIN Subject.tbSubject Subject ON opening_balance.SubjectCode = Subject.SubjectCode

		UNION
	
		SELECT ROW_NUMBER() OVER (ORDER BY payments.PaidOn) AS RowNumber, reserve_account.AccountCode AS SubjectCode,
			reserve_account.AccountName AS SubjectName,
			payments.PaidOn AS TransactOn, 6 AS CashEntryTypeCode, payments.PaymentCode AS ReferenceCode,  
			payments.PaidOutValue, payments.PaidInValue, payments.CashCode, cash_code.CashDescription 
		FROM reserve_account 
			JOIN Cash.tbPayment payments ON reserve_account.AccountCode = payments.AccountCode
			JOIN Cash.tbCode cash_code ON payments.CashCode = cash_code.CashCode
		WHERE payments.PaymentStatusCode = 2
	)
	SELECT RowNumber, TransactOn, entry_type.CashEntryTypeCode, entry_type.CashEntryType, ReferenceCode, unbalanced_reserves.SubjectCode, unbalanced_reserves.SubjectName,
		CAST(PayOut as float) PayOut, CAST(PayIn as float) PayIn,
		CAST(SUM(PayIn + (PayOut * -1)) OVER (ORDER BY RowNumber) as float) Balance,
		CashCode, CashDescription
	FROM unbalanced_reserves 
		JOIN Cash.tbEntryType entry_type ON unbalanced_reserves.CashEntryTypeCode = entry_type.CashEntryTypeCode
