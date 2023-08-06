CREATE VIEW Subject.vwStatusReport
AS
	SELECT        Subject.vwDatasheet.AccountCode, Subject.vwDatasheet.AccountName, Subject.vwDatasheet.SubjectType, Subject.vwDatasheet.SubjectStatus, Subject.vwDatasheet.TaxDescription, Subject.vwDatasheet.Address, 
							 Subject.vwDatasheet.AreaCode, Subject.vwDatasheet.PhoneNumber, Subject.vwDatasheet.EmailAddress, Subject.vwDatasheet.WebSite, Subject.vwDatasheet.IndustrySector, 
							 Subject.vwDatasheet.AccountSource, Subject.vwDatasheet.PaymentTerms, Subject.vwDatasheet.PaymentDays, Subject.vwDatasheet.ExpectedDays, Subject.vwDatasheet.NumberOfEmployees, Subject.vwDatasheet.CompanyNumber, Subject.vwDatasheet.VatNumber, 
							 Subject.vwDatasheet.Turnover, Subject.vwDatasheet.OpeningBalance, Subject.vwDatasheet.EUJurisdiction, Subject.vwDatasheet.BusinessDescription, 
							 Cash.tbPayment.PaymentCode, Usr.tbUser.UserName, App.tbTaxCode.TaxDescription AS PaymentTaxDescription, Subject.tbAccount.CashAccountName, Cash.tbCode.CashDescription, Cash.tbPayment.UserId, 
							 Cash.tbPayment.CashAccountCode, Cash.tbPayment.CashCode, Cash.tbPayment.TaxCode, Cash.tbPayment.PaidOn, Cash.tbPayment.PaidInValue, Cash.tbPayment.PaidOutValue, 
							 Cash.tbPayment.InsertedBy, Cash.tbPayment.InsertedOn, Cash.tbPayment.UpdatedBy, Cash.tbPayment.UpdatedOn, Cash.tbPayment.PaymentReference
	FROM            Cash.tbPayment INNER JOIN
							 Usr.tbUser ON Cash.tbPayment.UserId = Usr.tbUser.UserId INNER JOIN
							 Subject.tbAccount ON Cash.tbPayment.CashAccountCode = Subject.tbAccount.CashAccountCode INNER JOIN
							 Cash.tbCode ON Cash.tbPayment.CashCode = Cash.tbCode.CashCode LEFT OUTER JOIN
							 App.tbTaxCode ON Cash.tbPayment.TaxCode = App.tbTaxCode.TaxCode INNER JOIN
							 Subject.vwDatasheet ON Cash.tbPayment.AccountCode = Subject.vwDatasheet.AccountCode
	WHERE        (Cash.tbPayment.PaymentStatusCode = 1);
