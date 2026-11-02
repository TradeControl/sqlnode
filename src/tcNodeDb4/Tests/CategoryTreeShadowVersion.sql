/*
    Category Tree shadow-version acceptance fixture.
    Run against a freshly commissioned node. All mutations roll back.
*/
SET NOCOUNT, XACT_ABORT ON;

BEGIN TRAN CategoryTreeShadowFixture;
BEGIN TRY
    DECLARE @VersionId NVARCHAR(10) =
    (
        SELECT VersionId
        FROM Cash.tbCategoryVersion
        WHERE VersionStatusCode = 1
    );

    IF @VersionId IS NULL OR (SELECT COUNT(*) FROM Cash.tbCategoryVersion) <> 1
        THROW 51075, 'Shadow commissioning must create exactly one Published Category Tree version.', 1;

    IF EXISTS
    (
        SELECT 1
        FROM Cash.tbCategoryVersion
        WHERE VersionId = @VersionId
          AND
          (
              CanonicalProfile <> N'trade-control-category-tree-v1'
              OR CanonicalSha256 IS NULL
              OR CanonicalByteLength IS NULL
          )
    )
        THROW 51115, 'The commissioned Category Tree version lacks canonical evidence.', 1;

    IF NOT EXISTS
    (
        SELECT 1
        FROM Cash.tbCategoryVersionEvent AS event
        JOIN Cash.tbCategoryVersion AS version
          ON version.VersionId = event.VersionId
         AND version.CanonicalSha256 = event.ContentSha256
        WHERE version.VersionId = @VersionId
    )
        THROW 51116, 'No Category Tree event binds the current canonical digest.', 1;

    IF (SELECT CategoryVersionId FROM App.tbOptions) <> @VersionId
        THROW 51093, 'The options row does not select the commissioned Category Tree version.', 1;

    IF EXISTS (SELECT 1 FROM Cash.tbCategory WHERE VersionId <> @VersionId)
        THROW 51076, 'A category belongs to the wrong shadow version.', 1;

    IF EXISTS (SELECT 1 FROM Cash.tbCategoryTotal WHERE VersionId <> @VersionId)
        THROW 51077, 'A category edge belongs to the wrong shadow version.', 1;

    IF (SELECT COUNT(*) FROM Cash.vwCategoryActive) <> (SELECT COUNT(*) FROM Cash.tbCategory WHERE VersionId = @VersionId)
        THROW 51094, 'The active category view does not expose exactly the options-selected version.', 1;

    IF (SELECT COUNT(*) FROM Cash.vwCategoryTotalActive) <> (SELECT COUNT(*) FROM Cash.tbCategoryTotal WHERE VersionId = @VersionId)
        THROW 51095, 'The active category-total view does not expose exactly the options-selected version.', 1;

    IF (SELECT COUNT(*) FROM Cash.vwCategoryCodeMapActive) <> (SELECT COUNT(*) FROM Cash.tbCategoryCodeMap WHERE VersionId = @VersionId)
        THROW 51096, 'The active Cash Code mapping view does not expose exactly the options-selected version.', 1;

    IF (SELECT COUNT(*) FROM Cash.vwCategoryRootActive) <> 2
        THROW 51097, 'The active root view does not expose both options-selected roots.', 1;

    IF (SELECT COUNT(*) FROM Cash.vwCategoryVersionActive) <> 1
        THROW 51098, 'The active version view does not expose exactly one options-selected header.', 1;

    IF EXISTS
    (
        SELECT code.CashCode, code.CategoryCode
        FROM Cash.tbCode AS code
        EXCEPT
        SELECT map.CashCode, map.CategoryCode
        FROM Cash.tbCategoryCodeMap AS map
        WHERE map.VersionId = @VersionId
    )
    OR EXISTS
    (
        SELECT map.CashCode, map.CategoryCode
        FROM Cash.tbCategoryCodeMap AS map
        WHERE map.VersionId = @VersionId
        EXCEPT
        SELECT code.CashCode, code.CategoryCode
        FROM Cash.tbCode AS code
    )
        THROW 51078, 'Shadow Cash Code mappings differ from the operational tbCode relationship.', 1;

    IF EXISTS
    (
        SELECT root.RootTypeCode, root.CategoryCode
        FROM App.tbOptions AS options
        CROSS APPLY
        (
            VALUES
                (CAST(0 AS SMALLINT), options.NetProfitCode),
                (CAST(1 AS SMALLINT), options.VatCategoryCode)
        ) AS root (RootTypeCode, CategoryCode)
        EXCEPT
        SELECT RootTypeCode, CategoryCode
        FROM Cash.tbCategoryRoot
        WHERE VersionId = @VersionId
    )
    OR EXISTS
    (
        SELECT RootTypeCode, CategoryCode
        FROM Cash.tbCategoryRoot
        WHERE VersionId = @VersionId
        EXCEPT
        SELECT root.RootTypeCode, root.CategoryCode
        FROM App.tbOptions AS options
        CROSS APPLY
        (
            VALUES
                (CAST(0 AS SMALLINT), options.NetProfitCode),
                (CAST(1 AS SMALLINT), options.VatCategoryCode)
        ) AS root (RootTypeCode, CategoryCode)
    )
        THROW 51079, 'Shadow roots differ from the operational options roots.', 1;

    IF EXISTS
    (
        SELECT root.CategoryCode AS RootCode, member.CashCode, member.CategoryCode
        FROM Cash.tbCategoryRoot AS root
        CROSS APPLY Cash.fnCategoryCashCodes(root.CategoryCode) AS member
        WHERE root.VersionId = @VersionId
        EXCEPT
        SELECT root.CategoryCode, member.CashCode, member.CategoryCode
        FROM Cash.tbCategoryRoot AS root
        CROSS APPLY Cash.fnCategoryCashCodesByVersion(@VersionId, root.CategoryCode) AS member
        WHERE root.VersionId = @VersionId
    )
    OR EXISTS
    (
        SELECT root.CategoryCode AS RootCode, member.CashCode, member.CategoryCode
        FROM Cash.tbCategoryRoot AS root
        CROSS APPLY Cash.fnCategoryCashCodesByVersion(@VersionId, root.CategoryCode) AS member
        WHERE root.VersionId = @VersionId
        EXCEPT
        SELECT root.CategoryCode, member.CashCode, member.CategoryCode
        FROM Cash.tbCategoryRoot AS root
        CROSS APPLY Cash.fnCategoryCashCodes(root.CategoryCode) AS member
        WHERE root.VersionId = @VersionId
    )
        THROW 51087, 'Version-aware category Cash Code traversal differs from the current function.', 1;

    IF EXISTS
    (
        SELECT CategoryCode, CashCode, CashTypeCode, CashPolarityCode
        FROM App.vwTaxBizCashCodes
        EXCEPT
        SELECT CategoryCode, CashCode, CashTypeCode, CashPolarityCode
        FROM App.fnTaxBizCashCodesByVersion(@VersionId)
    )
    OR EXISTS
    (
        SELECT CategoryCode, CashCode, CashTypeCode, CashPolarityCode
        FROM App.fnTaxBizCashCodesByVersion(@VersionId)
        EXCEPT
        SELECT CategoryCode, CashCode, CashTypeCode, CashPolarityCode
        FROM App.vwTaxBizCashCodes
    )
        THROW 51080, 'Version-aware business-tax Cash Codes differ from the current view.', 1;

    IF EXISTS
    (
        SELECT CashCode FROM App.vwTaxVatCashCodes
        EXCEPT
        SELECT CashCode FROM App.fnTaxVatCashCodesByVersion(@VersionId)
    )
    OR EXISTS
    (
        SELECT CashCode FROM App.fnTaxVatCashCodesByVersion(@VersionId)
        EXCEPT
        SELECT CashCode FROM App.vwTaxVatCashCodes
    )
        THROW 51081, 'Version-aware VAT Cash Codes differ from the current view.', 1;

    IF EXISTS
    (
        SELECT ChildCode, ParentCode, RootCode, PrimaryKind, Depth, rn, ParentCount
        FROM Cash.vwCategoryPrimaryParent
        EXCEPT
        SELECT ChildCode, ParentCode, RootCode, PrimaryKind, Depth, rn, ParentCount
        FROM Cash.fnCategoryPrimaryParentByVersion(@VersionId)
    )
    OR EXISTS
    (
        SELECT ChildCode, ParentCode, RootCode, PrimaryKind, Depth, rn, ParentCount
        FROM Cash.fnCategoryPrimaryParentByVersion(@VersionId)
        EXCEPT
        SELECT ChildCode, ParentCode, RootCode, PrimaryKind, Depth, rn, ParentCount
        FROM Cash.vwCategoryPrimaryParent
    )
        THROW 51082, 'Version-aware primary-parent traversal differs from the current view.', 1;

    DECLARE @NominalCategoryCode NVARCHAR(10) =
    (
        SELECT TOP (1) CategoryCode
        FROM Cash.tbCategory
        WHERE VersionId = @VersionId
          AND CategoryTypeCode = 0
          AND IsEnabled <> 0
        ORDER BY CategoryCode
    );

    INSERT INTO Cash.tbCode
    (
        CashCode,
        CashDescription,
        CategoryCode,
        TaxCode
    )
    VALUES
    (
        N'ZZ-CT-SHADOW',
        N'Category Tree shadow fixture',
        @NominalCategoryCode,
        N'T0'
    );

    IF NOT EXISTS
    (
        SELECT 1
        FROM Cash.tbCategoryCodeMap
        WHERE VersionId = @VersionId
          AND CashCode = N'ZZ-CT-SHADOW'
          AND CategoryCode = @NominalCategoryCode
    )
        THROW 51083, 'Cash Code insertion did not create its shadow mapping.', 1;

    DELETE FROM Cash.tbCode WHERE CashCode = N'ZZ-CT-SHADOW';

    IF EXISTS
    (
        SELECT 1
        FROM Cash.tbCategoryCodeMap
        WHERE VersionId = @VersionId
          AND CashCode = N'ZZ-CT-SHADOW'
    )
        THROW 51084, 'Cash Code deletion did not remove its shadow mapping.', 1;

    ROLLBACK TRAN CategoryTreeShadowFixture;
    PRINT 'Category Tree shadow-version fixture passed.';
END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0 ROLLBACK TRAN CategoryTreeShadowFixture;
    THROW;
END CATCH;
