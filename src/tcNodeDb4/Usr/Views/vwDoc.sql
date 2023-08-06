CREATE VIEW Usr.vwDoc
AS
	WITH bank AS 
	(
		SELECT TOP (1) (SELECT AccountCode FROM App.tbOptions) AS AccountCode, 
			Subject.tbSubject.AccountName AS BankName,
			Subject.tbAccount.CashAccountName AS CurrentAccountName,
			CONCAT(Subject.tbSubject.AccountName, SPACE(1), Subject.tbAccount.CashAccountName) AS BankAccount, 
			Subject.tbAccount.SortCode AS BankSortCode, Subject.tbAccount.AccountNumber AS BankAccountNumber
		FROM Subject.tbAccount 
			INNER JOIN Subject.tbSubject ON Subject.tbAccount.AccountCode = Subject.tbSubject.AccountCode
		WHERE (NOT (Subject.tbAccount.CashCode IS NULL)) AND (Subject.tbAccount.AccountTypeCode = 0)
	)
    SELECT        TOP (1) company.AccountName AS CompanyName, Subject.tbAddress.Address AS CompanyAddress, company.PhoneNumber AS CompanyPhoneNumber,  
                              company.EmailAddress AS CompanyEmailAddress, company.WebSite AS CompanyWebsite, company.CompanyNumber, company.VatNumber, company.Logo, 
							  bank_details.BankName, bank_details.CurrentAccountName,
							  bank_details.BankAccount, bank_details.BankAccountNumber, bank_details.BankSortCode
     FROM            Subject.tbSubject AS company INNER JOIN
                              App.tbOptions ON company.AccountCode = App.tbOptions.AccountCode LEFT OUTER JOIN
                              bank AS bank_details ON company.AccountCode = bank_details.AccountCode LEFT OUTER JOIN
                              Subject.tbAddress ON company.AddressCode = Subject.tbAddress.AddressCode;

