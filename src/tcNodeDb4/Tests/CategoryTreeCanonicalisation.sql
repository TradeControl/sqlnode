/*
    Category Tree canonicalisation conformance fixture.
    Run against a commissioned node. All mutations roll back.
*/
SET NOCOUNT, XACT_ABORT ON;

BEGIN TRAN CategoryTreeCanonicalFixture;
BEGIN TRY
    DECLARE
        @VersionId NVARCHAR(10) = N'CV99999998',
        @UserId NVARCHAR(10) = (SELECT UserId FROM Usr.vwCredentials),
        @CanonicalSha256 BINARY(32),
        @CanonicalByteLength BIGINT,
        @CanonicalJson NVARCHAR(MAX),
        @ExpectedJson NVARCHAR(MAX) = N'{"profile":"trade-control-category-tree-v1","categories":[{"categoryCode":"CAT-1","category":"Sales & services","categoryTypeCode":0,"cashPolarityCode":1,"cashTypeCode":0,"displayOrder":10,"isEnabled":true},{"categoryCode":"ROOT-1","category":"Net profit","categoryTypeCode":1,"cashPolarityCode":2,"cashTypeCode":0,"displayOrder":1,"isEnabled":true}],"totals":[{"parentCode":"ROOT-1","childCode":"CAT-1","displayOrder":1}],"codeMap":[{"cashCode":"CC-SALES","categoryCode":"CAT-1"}],"roots":[{"rootType":"NET_PROFIT","categoryCode":"ROOT-1"},{"rootType":"VAT","categoryCode":"ROOT-1"}]}';

    INSERT INTO Cash.tbCategoryVersion
    (
        VersionId,
        VersionStatusCode,
        Description,
        CreatedByUserId
    )
    VALUES
    (
        @VersionId,
        0,
        N'Canonical conformance vector',
        @UserId
    );

    INSERT INTO Cash.tbCategory
    (
        VersionId,
        CategoryCode,
        Category,
        CategoryTypeCode,
        CashPolarityCode,
        CashTypeCode,
        DisplayOrder,
        IsEnabled
    )
    VALUES
        (@VersionId, N'ROOT-1', N'Net profit', 1, 2, 0, 1, 1),
        (@VersionId, N'CAT-1', N'Sales & services', 0, 1, 0, 10, 1);

    INSERT INTO Cash.tbCategoryTotal
        (VersionId, ParentCode, ChildCode, DisplayOrder)
    VALUES
        (@VersionId, N'ROOT-1', N'CAT-1', 1);

    INSERT INTO Cash.tbCategoryCodeMap
        (VersionId, CashCode, CategoryCode)
    VALUES
        (@VersionId, N'CC-SALES', N'CAT-1');

    INSERT INTO Cash.tbCategoryRoot
        (VersionId, RootTypeCode, CategoryCode)
    VALUES
        (@VersionId, 1, N'ROOT-1'),
        (@VersionId, 0, N'ROOT-1');

    EXEC Cash.proc_CategoryVersionCanonicalise
        @VersionId = @VersionId,
        @CanonicalSha256 = @CanonicalSha256 OUTPUT,
        @CanonicalByteLength = @CanonicalByteLength OUTPUT,
        @CanonicalJson = @CanonicalJson OUTPUT;

    IF @CanonicalJson <> @ExpectedJson
        THROW 51102, 'The SQL canonical Category Tree JSON differs from the v1 conformance vector.', 1;

    IF @CanonicalByteLength <> 585
        THROW 51103, 'The SQL canonical Category Tree byte length differs from the v1 conformance vector.', 1;

    IF CONVERT(VARCHAR(64), @CanonicalSha256, 2) <> '8B77B246D3DFDB77230B52695747D5D31A135FC5FFB65CD89CE4844A6D032177'
        THROW 51104, 'The SQL canonical Category Tree SHA-256 differs from the v1 conformance vector.', 1;

    IF NOT EXISTS
    (
        SELECT 1
        FROM Cash.tbCategoryVersion
        WHERE VersionId = @VersionId
          AND CanonicalProfile = N'trade-control-category-tree-v1'
          AND CanonicalByteLength = @CanonicalByteLength
          AND CanonicalSha256 = @CanonicalSha256
    )
        THROW 51105, 'Canonical Category Tree evidence was not stored on the version header.', 1;

    ROLLBACK TRAN CategoryTreeCanonicalFixture;
    PRINT 'Category Tree canonicalisation fixture passed.';
END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0 ROLLBACK TRAN CategoryTreeCanonicalFixture;
    THROW;
END CATCH;
