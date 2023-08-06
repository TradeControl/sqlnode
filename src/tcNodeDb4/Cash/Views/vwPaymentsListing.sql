CREATE VIEW Cash.vwPaymentsListing
AS
	SELECT Subject.tbSubject.AccountCode, Subject.tbSubject.AccountName, Subject.tbType.SubjectType, Subject.tbStatus.SubjectStatus, Cash.tbPayment.PaymentCode, Usr.tbUser.UserName, 
							 App.tbTaxCode.TaxDescription AS PaymentTaxDescription, Subject.tbAccount.CashAccountName, Cash.tbCode.CashDescription, Cash.tbPayment.UserId, Cash.tbPayment.CashAccountCode, Cash.tbPayment.CashCode, 
							 Cash.tbPayment.TaxCode, CONCAT(YEAR(Cash.tbPayment.PaidOn), Format(MONTH(Cash.tbPayment.PaidOn), '00')) AS Period, Cash.tbPayment.PaidOn, Cash.tbPayment.PaidInValue, Cash.tbPayment.PaidOutValue, 
							 Cash.tbPayment.InsertedBy, Cash.tbPayment.InsertedOn, Cash.tbPayment.UpdatedBy, Cash.tbPayment.UpdatedOn, Cash.tbPayment.PaymentReference
	FROM            Cash.tbPayment INNER JOIN
							 Usr.tbUser ON Cash.tbPayment.UserId = Usr.tbUser.UserId INNER JOIN
							 Subject.tbAccount ON Cash.tbPayment.CashAccountCode = Subject.tbAccount.CashAccountCode INNER JOIN
							 Cash.tbCode ON Cash.tbPayment.CashCode = Cash.tbCode.CashCode LEFT OUTER JOIN
							 App.tbTaxCode ON Cash.tbPayment.TaxCode = App.tbTaxCode.TaxCode INNER JOIN
							 Subject.tbSubject ON Cash.tbPayment.AccountCode = Subject.tbSubject.AccountCode INNER JOIN
							 Subject.tbType ON Subject.tbSubject.SubjectTypeCode = Subject.tbType.SubjectTypeCode INNER JOIN
							 Subject.tbStatus ON Subject.tbSubject.SubjectStatusCode = Subject.tbStatus.SubjectStatusCode
	WHERE        (Cash.tbPayment.PaymentStatusCode = 1);
