﻿CREATE   VIEW Subject.vwCompanyHeader
AS
SELECT        TOP (1) Subject.tbSubject.AccountName AS CompanyName, Subject.tbAddress.Address AS CompanyAddress, Subject.tbSubject.PhoneNumber AS CompanyPhoneNumber, 
                         Subject.tbSubject.EmailAddress AS CompanyEmailAddress, Subject.tbSubject.WebSite AS CompanyWebsite, Subject.tbSubject.CompanyNumber, Subject.tbSubject.VatNumber
FROM            Subject.tbSubject INNER JOIN
                         App.tbOptions ON Subject.tbSubject.AccountCode = App.tbOptions.AccountCode LEFT OUTER JOIN
                         Subject.tbAddress ON Subject.tbSubject.AddressCode = Subject.tbAddress.AddressCode;
