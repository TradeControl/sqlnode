CREATE   VIEW Subject.vwListAll
AS
	WITH accounts AS
	(
		SELECT AccountCode, AccountName, SubjectTypeCode, SubjectStatusCode, TaxCode,
			(SELECT TOP 1 CashCode FROM Project.tbProject WHERE AccountCode = Subjects.AccountCode ORDER BY ActionOn DESC) ProjectCashCode,
			(SELECT TOP 1 CashCode FROM Cash.tbPayment WHERE AccountCode = Subjects.AccountCode ORDER BY PaidOn DESC) PaymentCashCode
		FROM  Subject.tbSubject Subjects
	)
		SELECT accounts.AccountCode, accounts.AccountName, Subject_type.SubjectType, accounts.TaxCode, Subject_type.CashPolarityCode, accounts.SubjectStatusCode,
			COALESCE(accounts.ProjectCashCode, accounts.PaymentCashCode) CashCode
		FROM accounts 
			INNER JOIN Subject.tbType AS Subject_type ON accounts.SubjectTypeCode = Subject_type.SubjectTypeCode
