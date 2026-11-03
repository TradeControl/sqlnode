CREATE FUNCTION [Cash].[fnTaxTagCashCodeByVersion]
(
    @VersionId NVARCHAR(10)
)
RETURNS TABLE
AS
RETURN
(
    WITH CategoryTree AS
    (
        SELECT map.TaxSourceCode, map.TagCode,
               map.CategoryCode AS MappingRoot, map.CategoryCode
        FROM Cash.tbTaxTagMap AS map
        JOIN Cash.tbCategory AS root
          ON root.VersionId = @VersionId
         AND root.CategoryCode = map.CategoryCode
         AND root.CategoryTypeCode IN (0, 1)
         AND root.IsEnabled = 1
        WHERE map.MapTypeCode = 0 AND map.IsEnabled = 1

        UNION ALL

        SELECT parent.TaxSourceCode, parent.TagCode,
               parent.MappingRoot, edge.ChildCode
        FROM CategoryTree AS parent
        JOIN Cash.tbCategoryTotal AS edge
          ON edge.VersionId = @VersionId
         AND edge.ParentCode = parent.CategoryCode
        JOIN Cash.tbCategory AS child
          ON child.VersionId = edge.VersionId
         AND child.CategoryCode = edge.ChildCode
         AND child.CategoryTypeCode IN (0, 1)
         AND child.IsEnabled = 1
    ),
    CategoryMappings AS
    (
        SELECT tree.TaxSourceCode, tree.TagCode,
               CONVERT(TINYINT, 0) AS MapTypeCode, tree.MappingRoot,
               map.CashCode, map.CategoryCode AS LeafCategoryCode,
               category.CashPolarityCode
        FROM CategoryTree AS tree
        JOIN Cash.tbCategory AS category
          ON category.VersionId = @VersionId
         AND category.CategoryCode = tree.CategoryCode
         AND category.CategoryTypeCode = 0
         AND category.IsEnabled = 1
        JOIN Cash.tbCategoryCodeMap AS map
          ON map.VersionId = @VersionId
         AND map.CategoryCode = category.CategoryCode
        JOIN Cash.tbCode AS code
          ON code.CashCode = map.CashCode
         AND code.IsEnabled = 1
    ),
    CashCodeMappings AS
    (
        SELECT tag_map.TaxSourceCode, tag_map.TagCode,
               CONVERT(TINYINT, 1) AS MapTypeCode,
               tag_map.CashCode AS MappingRoot, code.CashCode,
               map.CategoryCode AS LeafCategoryCode,
               category.CashPolarityCode
        FROM Cash.tbTaxTagMap AS tag_map
        JOIN Cash.tbCode AS code
          ON code.CashCode = tag_map.CashCode
         AND code.IsEnabled = 1
        JOIN Cash.tbCategoryCodeMap AS map
          ON map.VersionId = @VersionId
         AND map.CashCode = code.CashCode
        JOIN Cash.tbCategory AS category
          ON category.VersionId = map.VersionId
         AND category.CategoryCode = map.CategoryCode
         AND category.CategoryTypeCode = 0
         AND category.IsEnabled = 1
        WHERE tag_map.MapTypeCode = 1 AND tag_map.IsEnabled = 1
    )
    SELECT TaxSourceCode, TagCode, MapTypeCode, MappingRoot,
           CashCode, LeafCategoryCode, CashPolarityCode
    FROM CategoryMappings
    UNION ALL
    SELECT TaxSourceCode, TagCode, MapTypeCode, MappingRoot,
           CashCode, LeafCategoryCode, CashPolarityCode
    FROM CashCodeMappings
);
