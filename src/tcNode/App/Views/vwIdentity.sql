CREATE   VIEW App.vwIdentity
AS
SELECT TOP (1) Org.tbOrg.AccountName, Org.tbAddress.Address, Org.tbOrg.PhoneNumber, Org.tbOrg.EmailAddress, Org.tbOrg.WebSite, Org.tbOrg.Logo, Usr.tbUser.UserName, Usr.tbUser.LogonName, 
                         Usr.tbUser.Avatar, Org.tbOrg.CompanyNumber, Org.tbOrg.VatNumber
FROM            Org.tbOrg INNER JOIN
                         Org.tbAddress ON Org.tbOrg.AddressCode = Org.tbAddress.AddressCode INNER JOIN
                         App.tbOptions ON Org.tbOrg.AccountCode = App.tbOptions.AccountCode CROSS JOIN
                         Usr.vwCredentials INNER JOIN
                         Usr.tbUser ON Usr.vwCredentials.UserId = Usr.tbUser.UserId;
