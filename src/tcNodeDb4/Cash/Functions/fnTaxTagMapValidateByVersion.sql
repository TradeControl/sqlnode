CREATE FUNCTION [Cash].[fnTaxTagMapValidateByVersion]
(
    @TaxSourceCode NVARCHAR(20),
    @VersionId NVARCHAR(10)
)
RETURNS @Result TABLE
(
    IsError BIT NOT NULL,
    TagCode NVARCHAR(64) NULL,
    TagName NVARCHAR(100) NULL,
    CashCode NVARCHAR(50) NULL,
    CategoryCode NVARCHAR(10) NULL,
    HitCount INT NULL,
    Message NVARCHAR(4000) NOT NULL
)
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM Cash.tbCategoryVersion WHERE VersionId = @VersionId)
        INSERT INTO @Result VALUES
            (1, NULL, NULL, NULL, NULL, NULL, N'Category Tree version does not exist.');

    IF NOT EXISTS (SELECT 1 FROM Cash.tbTaxTagSource WHERE TaxSourceCode = @TaxSourceCode)
        INSERT INTO @Result VALUES
            (1, NULL, NULL, NULL, NULL, NULL, N'Tax Source does not exist.');

    INSERT INTO @Result
    SELECT 1, map.TagCode, tag.TagName, NULLIF(map.CashCode, ''), NULLIF(map.CategoryCode, ''), NULL,
           N'Only Component Tax Tags may have Category or CashCode mappings.'
    FROM Cash.tbTaxTagMap AS map
    JOIN Cash.tbTaxTag AS tag
      ON tag.TaxSourceCode = map.TaxSourceCode AND tag.TagCode = map.TagCode
    WHERE map.TaxSourceCode = @TaxSourceCode AND tag.TagClassCode <> 1;

    INSERT INTO @Result
    SELECT 1, map.TagCode, tag.TagName, NULL, map.CategoryCode, NULL,
           CASE
               WHEN category.CategoryCode IS NULL THEN N'Mapped Category does not exist.'
               WHEN category.IsEnabled = 0 THEN N'Mapped Category is disabled.'
               WHEN category.CategoryTypeCode NOT IN (0, 1) THEN N'Mapped Category is not a nominal or total Category.'
               ELSE N'Mapped Category resolves to no enabled nominal CashCode contributor.'
           END
    FROM Cash.tbTaxTagMap AS map
    JOIN Cash.tbTaxTag AS tag
      ON tag.TaxSourceCode = map.TaxSourceCode AND tag.TagCode = map.TagCode
    LEFT JOIN Cash.tbCategory AS category
      ON category.VersionId = @VersionId AND category.CategoryCode = map.CategoryCode
    WHERE map.TaxSourceCode = @TaxSourceCode
      AND map.IsEnabled = 1 AND map.MapTypeCode = 0
      AND
      (
          category.CategoryCode IS NULL OR category.IsEnabled = 0
          OR category.CategoryTypeCode NOT IN (0, 1)
          OR NOT EXISTS
             (
                 SELECT 1
                 FROM Cash.fnTaxTagCashCodeByVersion(@VersionId) AS effective
                 WHERE effective.TaxSourceCode = map.TaxSourceCode
                   AND effective.TagCode = map.TagCode
                   AND effective.MapTypeCode = map.MapTypeCode
                   AND effective.MappingRoot = map.CategoryCode
             )
      );

    INSERT INTO @Result
    SELECT 1, map.TagCode, tag.TagName, map.CashCode, code_map.CategoryCode, NULL,
           CASE
               WHEN code.CashCode IS NULL THEN N'Mapped CashCode does not exist.'
               WHEN code.IsEnabled = 0 THEN N'Mapped CashCode is disabled.'
               WHEN category.CategoryCode IS NULL OR category.IsEnabled = 0 OR category.CategoryTypeCode <> 0
                   THEN N'Mapped CashCode is not attached to an enabled nominal Category.'
               ELSE N'Mapped CashCode is not an eligible effective contributor.'
           END
    FROM Cash.tbTaxTagMap AS map
    JOIN Cash.tbTaxTag AS tag
      ON tag.TaxSourceCode = map.TaxSourceCode AND tag.TagCode = map.TagCode
    LEFT JOIN Cash.tbCode AS code ON code.CashCode = map.CashCode
    LEFT JOIN Cash.tbCategoryCodeMap AS code_map
      ON code_map.VersionId = @VersionId AND code_map.CashCode = code.CashCode
    LEFT JOIN Cash.tbCategory AS category
      ON category.VersionId = code_map.VersionId AND category.CategoryCode = code_map.CategoryCode
    WHERE map.TaxSourceCode = @TaxSourceCode
      AND map.IsEnabled = 1 AND map.MapTypeCode = 1
      AND
      (
          code.CashCode IS NULL OR code.IsEnabled = 0
          OR category.CategoryCode IS NULL OR category.IsEnabled = 0 OR category.CategoryTypeCode <> 0
          OR NOT EXISTS
             (
                 SELECT 1
                 FROM Cash.fnTaxTagCashCodeByVersion(@VersionId) AS effective
                 WHERE effective.TaxSourceCode = map.TaxSourceCode
                   AND effective.TagCode = map.TagCode
                   AND effective.MapTypeCode = map.MapTypeCode
                   AND effective.MappingRoot = map.CashCode
             )
      );

    INSERT INTO @Result
    SELECT 1, effective.TagCode, tag.TagName, effective.CashCode,
           effective.LeafCategoryCode, COUNT(*),
           N'CashCode is included multiple times in this tag through overlapping mapping roots.'
    FROM Cash.fnTaxTagCashCodeByVersion(@VersionId) AS effective
    JOIN Cash.tbTaxTag AS tag
      ON tag.TaxSourceCode = effective.TaxSourceCode
     AND tag.TagCode = effective.TagCode AND tag.TagClassCode = 1
    WHERE effective.TaxSourceCode = @TaxSourceCode
    GROUP BY effective.TagCode, tag.TagName, effective.CashCode, effective.LeafCategoryCode
    HAVING COUNT(*) > 1;

    INSERT INTO @Result
    SELECT 1, effective.TagCode, tag.TagName, effective.CashCode,
           effective.LeafCategoryCode, NULL,
           N'Contributor polarity is neutral, null, or does not match the Tax Tag cash polarity.'
    FROM Cash.fnTaxTagCashCodeByVersion(@VersionId) AS effective
    JOIN Cash.tbTaxTag AS tag
      ON tag.TaxSourceCode = effective.TaxSourceCode
     AND tag.TagCode = effective.TagCode AND tag.TagClassCode = 1
    WHERE effective.TaxSourceCode = @TaxSourceCode
      AND
      (
          effective.CashPolarityCode IS NULL
          OR
          (
              tag.CashPolarityCode <> 2
              AND (effective.CashPolarityCode = 2 OR effective.CashPolarityCode <> tag.CashPolarityCode)
          )
      );

    INSERT INTO @Result
    SELECT DISTINCT 0, NULL, NULL, code.CashCode, code_map.CategoryCode, NULL,
           N'Enabled business-tax CashCode is not covered by any Component Tax Tag mapping for this source.'
    FROM App.fnTaxBizCashCodesByVersion(@VersionId) AS business_code
    JOIN Cash.tbCode AS code
      ON code.CashCode = business_code.CashCode AND code.IsEnabled = 1
    JOIN Cash.tbCategoryCodeMap AS code_map
      ON code_map.VersionId = @VersionId AND code_map.CashCode = code.CashCode
    JOIN Cash.tbCategory AS category
      ON category.VersionId = code_map.VersionId
     AND category.CategoryCode = code_map.CategoryCode
     AND category.CategoryTypeCode = 0 AND category.IsEnabled = 1
    WHERE EXISTS (SELECT 1 FROM Cash.tbTaxTagSource WHERE TaxSourceCode = @TaxSourceCode)
      AND NOT EXISTS
      (
          SELECT 1
          FROM Cash.fnTaxTagCashCodeByVersion(@VersionId) AS effective
          JOIN Cash.tbTaxTag AS tag
            ON tag.TaxSourceCode = effective.TaxSourceCode
           AND tag.TagCode = effective.TagCode AND tag.TagClassCode = 1
          WHERE effective.TaxSourceCode = @TaxSourceCode
            AND effective.CashCode = code.CashCode
      );

    RETURN;
END;
