
CREATE   VIEW Org.vwListAll
AS
	SELECT TOP (100) PERCENT Org.tbOrg.AccountCode, Org.tbOrg.AccountName, Org.tbType.CashModeCode
	FROM Org.tbOrg INNER JOIN Org.tbType ON Org.tbOrg.OrganisationTypeCode = Org.tbType.OrganisationTypeCode
	ORDER BY Org.tbOrg.AccountName;
