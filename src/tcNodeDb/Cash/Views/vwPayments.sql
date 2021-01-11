CREATE VIEW Cash.vwPayments
AS
	SELECT        Cash.tbPayment.AccountCode, Cash.tbPayment.PaymentCode, Cash.tbPayment.UserId, Cash.tbPayment.PaymentStatusCode, Cash.tbPayment.CashAccountCode, Cash.tbPayment.CashCode, Cash.tbPayment.TaxCode, 
							 Cash.tbPayment.PaidOn, Cash.tbPayment.PaidInValue, Cash.tbPayment.PaidOutValue, Cash.tbPayment.PaymentReference, Cash.tbPayment.InsertedBy, Cash.tbPayment.InsertedOn, Cash.tbPayment.UpdatedBy, 
							 Cash.tbPayment.UpdatedOn, Usr.tbUser.UserName, App.tbTaxCode.TaxDescription, Org.tbAccount.CashAccountName, Cash.tbCode.CashDescription
	FROM            Cash.tbPayment INNER JOIN
							 Usr.tbUser ON Cash.tbPayment.UserId = Usr.tbUser.UserId INNER JOIN
							 Org.tbAccount ON Cash.tbPayment.CashAccountCode = Org.tbAccount.CashAccountCode LEFT OUTER JOIN
							 Cash.tbCode ON Cash.tbPayment.CashCode = Cash.tbCode.CashCode LEFT OUTER JOIN
							 App.tbTaxCode ON Cash.tbPayment.TaxCode = App.tbTaxCode.TaxCode
	WHERE        (Cash.tbPayment.PaymentStatusCode = 1);
