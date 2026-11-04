CREATE FUNCTION Cash.fnFlowCategoryTotalCodesByVersion
(
    @CategoryVersionId nvarchar(10),
    @CategoryCode nvarchar(10)
)
RETURNS TABLE
AS
RETURN
(
    SELECT ChildCode AS CategoryCode, DisplayOrder
    FROM Cash.tbCategoryTotal
    WHERE VersionId = @CategoryVersionId
      AND ParentCode = @CategoryCode
);
