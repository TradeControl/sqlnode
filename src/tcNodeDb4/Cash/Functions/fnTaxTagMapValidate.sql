CREATE FUNCTION Cash.fnTaxTagMapValidate
(
    @TaxSourceCode NVARCHAR(20)
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
    IF NOT EXISTS (SELECT 1 FROM Cash.tbTaxTagSource WHERE TaxSourceCode = @TaxSourceCode)
        INSERT INTO @Result VALUES
            (1, NULL, NULL, NULL, NULL, NULL, N'Tax Source does not exist.');

    ----------------------------------------------------------------
    -- Only Component tags are eligible for accounting mappings.
    ----------------------------------------------------------------
    INSERT INTO @Result
    SELECT 1, tm.TagCode, t.TagName, NULLIF(tm.CashCode, ''), NULLIF(tm.CategoryCode, ''), NULL,
           N'Only Component Tax Tags may have Category or CashCode mappings.'
    FROM Cash.tbTaxTagMap tm
    JOIN Cash.tbTaxTag t
      ON t.TaxSourceCode = tm.TaxSourceCode
     AND t.TagCode = tm.TagCode
    WHERE tm.TaxSourceCode = @TaxSourceCode
      AND t.TagClassCode <> 1;

    ----------------------------------------------------------------
    -- Category roots must exist, be enabled, have an eligible tree type,
    -- and resolve to at least one enabled nominal CashCode contributor.
    ----------------------------------------------------------------
    INSERT INTO @Result
    SELECT 1, tm.TagCode, t.TagName, NULL, tm.CategoryCode, NULL,
           CASE
               WHEN c.CategoryCode IS NULL THEN N'Mapped Category does not exist.'
               WHEN c.IsEnabled = 0 THEN N'Mapped Category is disabled.'
               WHEN c.CategoryTypeCode NOT IN (0, 1) THEN N'Mapped Category is not a nominal or total Category.'
               ELSE N'Mapped Category resolves to no enabled nominal CashCode contributor.'
           END
    FROM Cash.tbTaxTagMap tm
    JOIN Cash.tbTaxTag t
      ON t.TaxSourceCode = tm.TaxSourceCode
     AND t.TagCode = tm.TagCode
    LEFT JOIN Cash.tbCategory c ON c.CategoryCode = tm.CategoryCode
    WHERE tm.TaxSourceCode = @TaxSourceCode
      AND tm.IsEnabled = 1
      AND tm.MapTypeCode = 0
      AND
      (
          c.CategoryCode IS NULL OR c.IsEnabled = 0 OR c.CategoryTypeCode NOT IN (0, 1)
          OR NOT EXISTS
          (
              SELECT 1 FROM Cash.vwTaxTagCashCode ec
              WHERE ec.TaxSourceCode = tm.TaxSourceCode
                AND ec.TagCode = tm.TagCode
                AND ec.MapTypeCode = tm.MapTypeCode
                AND ec.MappingRoot = tm.CategoryCode
          )
      );

    ----------------------------------------------------------------
    -- Direct CashCode roots must be enabled nominal contributors.
    ----------------------------------------------------------------
    INSERT INTO @Result
    SELECT 1, tm.TagCode, t.TagName, tm.CashCode, cc.CategoryCode, NULL,
           CASE
               WHEN cc.CashCode IS NULL THEN N'Mapped CashCode does not exist.'
               WHEN cc.IsEnabled = 0 THEN N'Mapped CashCode is disabled.'
               WHEN c.CategoryCode IS NULL OR c.IsEnabled = 0 OR c.CategoryTypeCode <> 0
                   THEN N'Mapped CashCode is not attached to an enabled nominal Category.'
               ELSE N'Mapped CashCode is not an eligible effective contributor.'
           END
    FROM Cash.tbTaxTagMap tm
    JOIN Cash.tbTaxTag t
      ON t.TaxSourceCode = tm.TaxSourceCode
     AND t.TagCode = tm.TagCode
    LEFT JOIN Cash.tbCode cc ON cc.CashCode = tm.CashCode
    LEFT JOIN Cash.tbCategory c ON c.CategoryCode = cc.CategoryCode
    WHERE tm.TaxSourceCode = @TaxSourceCode
      AND tm.IsEnabled = 1
      AND tm.MapTypeCode = 1
      AND
      (
          cc.CashCode IS NULL OR cc.IsEnabled = 0
          OR c.CategoryCode IS NULL OR c.IsEnabled = 0 OR c.CategoryTypeCode <> 0
          OR NOT EXISTS
          (
              SELECT 1 FROM Cash.vwTaxTagCashCode ec
              WHERE ec.TaxSourceCode = tm.TaxSourceCode
                AND ec.TagCode = tm.TagCode
                AND ec.MapTypeCode = tm.MapTypeCode
                AND ec.MappingRoot = tm.CashCode
          )
      );

    ----------------------------------------------------------------
    -- Preserve route multiplicity: duplicate effective inclusion in one tag
    -- is parent/descendant or multiple-root double counting.
    ----------------------------------------------------------------
    INSERT INTO @Result
    SELECT 1, ec.TagCode, t.TagName, ec.CashCode, ec.LeafCategoryCode, COUNT(*),
           N'CashCode is included multiple times in this tag through overlapping mapping roots.'
    FROM Cash.vwTaxTagCashCode ec
    JOIN Cash.tbTaxTag t
      ON t.TaxSourceCode = ec.TaxSourceCode
     AND t.TagCode = ec.TagCode
     AND t.TagClassCode = 1
    WHERE ec.TaxSourceCode = @TaxSourceCode
    GROUP BY ec.TagCode, t.TagName, ec.CashCode, ec.LeafCategoryCode
    HAVING COUNT(*) > 1;

    ----------------------------------------------------------------
    -- The Tax Tag cash orientation is independent of the mapping being checked
    -- and must match every actual leaf contributor.
    ----------------------------------------------------------------
    INSERT INTO @Result
    SELECT 1, ec.TagCode, t.TagName, ec.CashCode, ec.LeafCategoryCode, NULL,
           N'Contributor polarity is neutral, null, or does not match the Tax Tag cash polarity.'
    FROM Cash.vwTaxTagCashCode ec
    JOIN Cash.tbTaxTag t
      ON t.TaxSourceCode = ec.TaxSourceCode
     AND t.TagCode = ec.TagCode
     AND t.TagClassCode = 1
    WHERE ec.TaxSourceCode = @TaxSourceCode
      AND (ec.CashPolarityCode IS NULL OR ec.CashPolarityCode = 2
           OR ec.CashPolarityCode <> t.CashPolarityCode);

    ----------------------------------------------------------------
    -- Warn only for enabled nominal P&L CashCodes in the configured business-
    -- tax universe which are not covered, directly or indirectly, by this source.
    ----------------------------------------------------------------
    INSERT INTO @Result
    SELECT DISTINCT 0, NULL, NULL, cc.CashCode, cc.CategoryCode, NULL,
           N'Enabled business-tax CashCode is not covered by any Component Tax Tag mapping for this source.'
    FROM App.vwTaxBizCashCodes biz
    JOIN Cash.tbCode cc ON cc.CashCode = biz.CashCode AND cc.IsEnabled = 1
    JOIN Cash.tbCategory c
      ON c.CategoryCode = cc.CategoryCode
     AND c.CategoryTypeCode = 0
     AND c.IsEnabled = 1
    WHERE EXISTS (SELECT 1 FROM Cash.tbTaxTagSource WHERE TaxSourceCode = @TaxSourceCode)
      AND NOT EXISTS
    (
        SELECT 1
        FROM Cash.vwTaxTagCashCode ec
        JOIN Cash.tbTaxTag t
          ON t.TaxSourceCode = ec.TaxSourceCode
         AND t.TagCode = ec.TagCode
         AND t.TagClassCode = 1
        WHERE ec.TaxSourceCode = @TaxSourceCode
          AND ec.CashCode = cc.CashCode
    );

    RETURN;
END;
GO
