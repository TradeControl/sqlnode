CREATE FUNCTION Cash.fnFlowCategoryTotalsByVersion
(
    @CategoryVersionId nvarchar(10)
)
RETURNS TABLE
AS
RETURN
(
    SELECT CategoryCode, Category, DisplayOrder
    FROM Cash.tbCategory
    WHERE VersionId = @CategoryVersionId
      AND CategoryTypeCode = 1
      AND IsEnabled <> 0
);
