CREATE VIEW Cash.vwTaxTagCashCode
AS
WITH CategoryTree AS
(
    SELECT
        tm.TaxSourceCode,
        tm.TagCode,
        tm.CategoryCode AS MappingRoot,
        tm.CategoryCode
    FROM Cash.tbTaxTagMap tm
    WHERE tm.MapTypeCode = 0 AND tm.IsEnabled = 1

    UNION ALL

    SELECT
        ct.TaxSourceCode,
        ct.TagCode,
        ct.MappingRoot,
        rel.ChildCode
    FROM CategoryTree ct
    JOIN Cash.tbCategoryTotal rel ON rel.ParentCode = ct.CategoryCode
),
CategoryMappings AS
(
    SELECT
        ct.TaxSourceCode,
        ct.TagCode,
        CONVERT(TINYINT, 0) AS MapTypeCode,
        ct.MappingRoot,
        cc.CashCode,
        cc.CategoryCode AS LeafCategoryCode,
        cat.CashPolarityCode
    FROM CategoryTree ct
    JOIN Cash.tbCategory cat
      ON cat.CategoryCode = ct.CategoryCode
     AND cat.CategoryTypeCode = 0
     AND cat.IsEnabled = 1
    JOIN Cash.tbCode cc
      ON cc.CategoryCode = cat.CategoryCode
     AND cc.IsEnabled = 1
),
CashCodeMappings AS
(
    SELECT
        tm.TaxSourceCode,
        tm.TagCode,
        CONVERT(TINYINT, 1) AS MapTypeCode,
        tm.CashCode AS MappingRoot,
        cc.CashCode,
        cc.CategoryCode AS LeafCategoryCode,
        cat.CashPolarityCode
    FROM Cash.tbTaxTagMap tm
    JOIN Cash.tbCode cc ON cc.CashCode = tm.CashCode AND cc.IsEnabled = 1
    JOIN Cash.tbCategory cat
      ON cat.CategoryCode = cc.CategoryCode
     AND cat.CategoryTypeCode = 0
     AND cat.IsEnabled = 1
    WHERE tm.MapTypeCode = 1 AND tm.IsEnabled = 1
)
SELECT TaxSourceCode, TagCode, MapTypeCode, MappingRoot, CashCode, LeafCategoryCode, CashPolarityCode
FROM CategoryMappings
UNION ALL
SELECT TaxSourceCode, TagCode, MapTypeCode, MappingRoot, CashCode, LeafCategoryCode, CashPolarityCode
FROM CashCodeMappings;
GO
