CREATE FUNCTION [Cash].[fnCategoryCashCodes]
(
    @CategoryCode NVARCHAR(10)
)
RETURNS TABLE
AS
RETURN
(
    SELECT member.CashCode, member.CategoryCode
    FROM App.tbOptions AS options
    CROSS APPLY Cash.fnCategoryCashCodesByVersion(options.CategoryVersionId, @CategoryCode) AS member
);
