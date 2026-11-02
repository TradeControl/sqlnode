CREATE FUNCTION [App].[fnTaxVatCashCodesByVersion]
(
    @VersionId NVARCHAR(10)
)
RETURNS TABLE
AS
RETURN
(
    WITH vat_enabled AS
    (
        SELECT IsEnabled
        FROM Cash.tbTaxType
        WHERE TaxTypeCode = 1
    ),
    category_relations AS
    (
        SELECT
            edge.ParentCode,
            edge.ChildCode,
            category.CategoryTypeCode,
            code.CashCode
        FROM Cash.tbCategoryTotal AS edge
        JOIN Cash.tbCategory AS category
          ON category.VersionId = edge.VersionId
         AND category.CategoryCode = edge.ChildCode
        LEFT JOIN Cash.tbCategoryCodeMap AS map
          ON map.VersionId = category.VersionId
         AND map.CategoryCode = category.CategoryCode
        LEFT JOIN Cash.tbCode AS code
          ON code.CashCode = map.CashCode
        CROSS JOIN vat_enabled AS vat
        WHERE edge.VersionId = @VersionId
          AND vat.IsEnabled = 1
          AND category.CashTypeCode = 0
          AND category.IsEnabled = 1
          AND (code.CashCode IS NULL OR code.IsEnabled = 1)
    ),
    cashcode_candidates AS
    (
        SELECT relation.ChildCode, relation.CashCode
        FROM category_relations AS relation
        JOIN Cash.tbCategoryRoot AS root
          ON root.VersionId = @VersionId
         AND root.RootTypeCode = 1
         AND root.CategoryCode = relation.ParentCode
        WHERE relation.CategoryTypeCode = 1

        UNION ALL

        SELECT relation.ChildCode, relation.CashCode
        FROM category_relations AS relation
        JOIN cashcode_candidates AS candidate
          ON candidate.ChildCode = relation.ParentCode
    ),
    cashcode_selected AS
    (
        SELECT CashCode
        FROM cashcode_candidates

        UNION

        SELECT relation.CashCode
        FROM category_relations AS relation
        JOIN Cash.tbCategoryRoot AS root
          ON root.VersionId = @VersionId
         AND root.RootTypeCode = 1
         AND root.CategoryCode = relation.ParentCode
    )
    SELECT CashCode
    FROM cashcode_selected
    WHERE CashCode IS NOT NULL
);
