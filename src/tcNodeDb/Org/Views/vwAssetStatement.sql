﻿CREATE VIEW Org.vwAssetStatement
AS
	SELECT (SELECT TOP 1 StartOn FROM App.tbYearPeriod	WHERE (StartOn <= TransactedOn) ORDER BY StartOn DESC) AS StartOn, *
	FROM Org.vwStatement
