CREATE   VIEW Subject.vwEmailAddresses
AS
	SELECT AccountCode, AccountName ContactName, EmailAddress, CAST(1 as bit) IsAdmin
	FROM Subject.tbSubject
	WHERE (NOT (EmailAddress IS NULL))
	UNION
	SELECT AccountCode, ContactName, EmailAddress, CAST(0 as bit) IsAdmin
	FROM            Subject.tbContact
	WHERE        (NOT (EmailAddress IS NULL))
