CREATE VIEW [App].[vwTaxVatCashCodes]
AS
SELECT member.CashCode
FROM App.tbOptions AS options
CROSS APPLY App.fnTaxVatCashCodesByVersion(options.CategoryVersionId) AS member;
