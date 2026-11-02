CREATE VIEW [App].[vwTaxBizCashCodes]
AS
SELECT
    member.CategoryCode,
    member.CashCode,
    member.CashTypeCode,
    member.CashPolarityCode
FROM App.tbOptions AS options
CROSS APPLY App.fnTaxBizCashCodesByVersion(options.CategoryVersionId) AS member;
