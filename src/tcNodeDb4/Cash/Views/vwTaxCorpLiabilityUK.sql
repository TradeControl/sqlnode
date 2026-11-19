/*
    Active Category Tree wrapper over the version-explicit UK Corporation Tax
    liability projection.
*/
CREATE VIEW Cash.vwTaxCorpLiabilityUK
AS
SELECT projection.*
FROM App.tbOptions AS options
CROSS APPLY Cash.fnTaxCorpLiabilityUKByVersion(options.CategoryVersionId) AS projection;
GO
