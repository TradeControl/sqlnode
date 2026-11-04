CREATE FUNCTION Cash.fnFlowCategoryCashCodesByVersion
(
    @CategoryVersionId nvarchar(10),
    @CategoryCode nvarchar(10)
)
RETURNS TABLE
AS
RETURN
(
    SELECT code.CashCode, code.CashDescription
    FROM Cash.tbCategoryCodeMap AS category_code
    JOIN Cash.tbCode AS code
      ON code.CashCode = category_code.CashCode
    WHERE category_code.VersionId = @CategoryVersionId
      AND category_code.CategoryCode = @CategoryCode
      AND code.IsEnabled <> 0
);
