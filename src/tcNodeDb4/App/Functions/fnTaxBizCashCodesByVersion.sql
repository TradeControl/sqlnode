CREATE FUNCTION [App].[fnTaxBizCashCodesByVersion]
(
    @VersionId NVARCHAR(10)
)
RETURNS TABLE
AS
RETURN
(
    WITH category_relations AS
    (
        SELECT
            edge.ParentCode,
            edge.ChildCode,
            category.CategoryTypeCode,
            category.CategoryCode,
            code.CashCode,
            category.CashTypeCode,
            category.CashPolarityCode
        FROM Cash.tbCategoryTotal AS edge
        JOIN Cash.tbCategory AS category
          ON category.VersionId = edge.VersionId
         AND category.CategoryCode = edge.ChildCode
        LEFT JOIN Cash.tbCategoryCodeMap AS map
          ON map.VersionId = category.VersionId
         AND map.CategoryCode = category.CategoryCode
        LEFT JOIN Cash.tbCode AS code
          ON code.CashCode = map.CashCode
        WHERE edge.VersionId = @VersionId
    ),
    cashcode_candidates AS
    (
        SELECT
            relation.ChildCode,
            relation.CategoryCode,
            relation.CashCode,
            relation.CashTypeCode,
            relation.CashPolarityCode
        FROM category_relations AS relation
        JOIN Cash.tbCategoryRoot AS root
          ON root.VersionId = @VersionId
         AND root.RootTypeCode = 0
         AND root.CategoryCode = relation.ParentCode
        WHERE relation.CategoryTypeCode = 1

        UNION ALL

        SELECT
            relation.ChildCode,
            relation.CategoryCode,
            relation.CashCode,
            relation.CashTypeCode,
            relation.CashPolarityCode
        FROM category_relations AS relation
        JOIN cashcode_candidates AS candidate
          ON candidate.ChildCode = relation.ParentCode
    ),
    cashcode_selected AS
    (
        SELECT CategoryCode, CashCode, CashTypeCode, CashPolarityCode
        FROM cashcode_candidates

        UNION

        SELECT
            relation.CategoryCode,
            relation.CashCode,
            relation.CashTypeCode,
            relation.CashPolarityCode
        FROM category_relations AS relation
        JOIN Cash.tbCategoryRoot AS root
          ON root.VersionId = @VersionId
         AND root.RootTypeCode = 0
         AND root.CategoryCode = relation.ParentCode
    )
    SELECT CategoryCode, CashCode, CashTypeCode, CashPolarityCode
    FROM cashcode_selected
    WHERE CashCode IS NOT NULL
);
