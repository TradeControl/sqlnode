﻿CREATE   VIEW Subject.vwAddressList
AS
	SELECT        Subject.tbSubject.AccountCode, Subject.tbAddress.AddressCode, Subject.tbSubject.AccountName, Subject.tbStatus.SubjectStatusCode, Subject.tbStatus.SubjectStatus, Subject.tbType.SubjectTypeCode, Subject.tbType.SubjectType, 
							 Subject.tbAddress.Address, Subject.tbAddress.InsertedBy, Subject.tbAddress.InsertedOn, CAST(CASE WHEN Subject.tbAddress.AddressCode = Subject.tbSubject.AddressCode THEN 1 ELSE 0 END AS bit) AS IsAdminAddress
	FROM            Subject.tbSubject INNER JOIN
							 Subject.tbAddress ON Subject.tbSubject.AccountCode = Subject.tbAddress.AccountCode INNER JOIN
							 Subject.tbStatus ON Subject.tbSubject.SubjectStatusCode = Subject.tbStatus.SubjectStatusCode INNER JOIN
							 Subject.tbType ON Subject.tbSubject.SubjectTypeCode = Subject.tbType.SubjectTypeCode
