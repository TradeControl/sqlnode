CREATE FUNCTION [Cash].[fnCategoryCashCodesByVersion]
(
    @VersionId NVARCHAR(10),
    @CategoryCode NVARCHAR(10)
)
RETURNS TABLE
AS
RETURN
(
    WITH category_tree AS
    (
        SELECT c.CategoryCode, c.CategoryTypeCode
        FROM Cash.tbCategory AS c
        WHERE c.VersionId = @VersionId
          AND c.CategoryCode = @CategoryCode

        UNION ALL

        SELECT edge.ChildCode, child.CategoryTypeCode
        FROM category_tree AS parent
        JOIN Cash.tbCategoryTotal AS edge
          ON edge.VersionId = @VersionId
         AND edge.ParentCode = parent.CategoryCode
        JOIN Cash.tbCategory AS child
          ON child.VersionId = edge.VersionId
         AND child.CategoryCode = edge.ChildCode
        WHERE child.IsEnabled <> 0
    ),
    nominal_categories AS
    (
        SELECT CategoryCode
        FROM category_tree
        WHERE CategoryTypeCode = 0
    )
    SELECT map.CashCode, map.CategoryCode
    FROM Cash.tbCategoryCodeMap AS map
    JOIN nominal_categories AS category
      ON category.CategoryCode = map.CategoryCode
    JOIN Cash.tbCode AS code
      ON code.CashCode = map.CashCode
    WHERE map.VersionId = @VersionId
      AND code.IsEnabled <> 0
);
