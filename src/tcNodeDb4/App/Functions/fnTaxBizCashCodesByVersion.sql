CREATE FUNCTION [App].[fnTaxBizCashCodesByVersion]
(
    @VersionId NVARCHAR(10)
)
RETURNS TABLE
AS
RETURN
(
    WITH category_tree AS
    (
        SELECT
            edge.ParentCode,
            edge.ChildCode
        FROM Cash.tbCategoryRoot AS root
        JOIN Cash.tbCategoryTotal AS edge
          ON edge.VersionId = root.VersionId
         AND edge.ParentCode = root.CategoryCode
        JOIN Cash.tbCategory AS category
          ON category.VersionId = edge.VersionId
         AND category.CategoryCode = edge.ChildCode
        WHERE root.VersionId = @VersionId
          AND root.RootTypeCode = 0
          AND category.CategoryTypeCode = 1

        UNION ALL

        SELECT
            edge.ParentCode,
            edge.ChildCode
        FROM category_tree AS tree
        JOIN Cash.tbCategoryTotal AS edge
          ON edge.VersionId = @VersionId
         AND edge.ParentCode = tree.ChildCode
    ),
    selected_categories AS
    (
        SELECT tree.ChildCode AS CategoryCode
        FROM category_tree AS tree

        UNION

        SELECT edge.ChildCode
        FROM Cash.tbCategoryRoot AS root
        JOIN Cash.tbCategoryTotal AS edge
          ON edge.VersionId = root.VersionId
         AND edge.ParentCode = root.CategoryCode
        WHERE root.VersionId = @VersionId
          AND root.RootTypeCode = 0
    )
    SELECT
        category.CategoryCode,
        code.CashCode,
        category.CashTypeCode,
        category.CashPolarityCode
    FROM selected_categories AS selected
    JOIN Cash.tbCategory AS category
      ON category.VersionId = @VersionId
     AND category.CategoryCode = selected.CategoryCode
    JOIN Cash.tbCategoryCodeMap AS map
      ON map.VersionId = category.VersionId
     AND map.CategoryCode = category.CategoryCode
    JOIN Cash.tbCode AS code
      ON code.CashCode = map.CashCode
);
