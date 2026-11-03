CREATE VIEW [Cash].[vwTaxTagCashCode]
AS
SELECT effective.*
FROM App.tbOptions AS options
CROSS APPLY Cash.fnTaxTagCashCodeByVersion(options.CategoryVersionId) AS effective;
