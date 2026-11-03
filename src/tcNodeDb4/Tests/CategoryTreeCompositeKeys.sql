/*
    Category Tree composite-key acceptance fixture.
    Run against an initialised node after deploying the current DACPAC.
    All mutations roll back; sequence gaps are expected and identifiers are never reused.
*/
SET NOCOUNT ON;
SET XACT_ABORT ON;

BEGIN TRAN CategoryTreeCompositeKeyFixture;
BEGIN TRY
    DECLARE
        @ActiveVersionId NVARCHAR(10) = (SELECT CategoryVersionId FROM App.tbOptions),
        @DraftVersionId NVARCHAR(10),
        @UserId NVARCHAR(10) = (SELECT TOP (1) UserId FROM Usr.vwCredentials),
        @BaseContentSha256 BINARY(32),
        @ParentCode NVARCHAR(10),
        @ChildCode NVARCHAR(10),
        @MissingDraftChildCode NVARCHAR(10);

    SELECT @BaseContentSha256 = CanonicalSha256
    FROM Cash.tbCategoryVersion
    WHERE VersionId = @ActiveVersionId;

    IF @ActiveVersionId IS NULL OR @UserId IS NULL OR @BaseContentSha256 IS NULL
        THROW 51120, 'The composite-key fixture requires an active canonical version and current user.', 1;

    SELECT TOP (1)
        @ParentCode = ParentCode,
        @ChildCode = ChildCode
    FROM Cash.tbCategoryTotal
    WHERE VersionId = @ActiveVersionId
    ORDER BY ParentCode, ChildCode;

    SELECT TOP (1) @MissingDraftChildCode = CategoryCode
    FROM Cash.tbCategory
    WHERE VersionId = @ActiveVersionId
      AND CategoryCode NOT IN (@ParentCode, @ChildCode)
    ORDER BY CategoryCode;

    IF @ParentCode IS NULL OR @ChildCode IS NULL OR @MissingDraftChildCode IS NULL
        THROW 51121, 'The composite-key fixture requires one edge and a third category.', 1;

    EXEC Cash.proc_CategoryVersionIdNext @VersionId = @DraftVersionId OUTPUT;

    INSERT INTO Cash.tbCategoryVersion
    (
        VersionId,
        VersionStatusCode,
        Description,
        PredecessorVersionId,
        BaseContentSha256,
        CreatedByUserId
    )
    VALUES
    (
        @DraftVersionId,
        0,
        N'Composite-key fixture Draft',
        @ActiveVersionId,
        @BaseContentSha256,
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
    SELECT
        @DraftVersionId,
        CategoryCode,
        Category,
        CategoryTypeCode,
        CashPolarityCode,
        CashTypeCode,
        DisplayOrder,
        IsEnabled
    FROM Cash.tbCategory
    WHERE VersionId = @ActiveVersionId
      AND CategoryCode IN (@ParentCode, @ChildCode);

    INSERT INTO Cash.tbCategoryTotal (VersionId, ParentCode, ChildCode, DisplayOrder)
    SELECT @DraftVersionId, ParentCode, ChildCode, DisplayOrder
    FROM Cash.tbCategoryTotal
    WHERE VersionId = @ActiveVersionId
      AND ParentCode = @ParentCode
      AND ChildCode = @ChildCode;

    IF (SELECT COUNT(*) FROM Cash.tbCategory WHERE CategoryCode = @ParentCode) <> 2
        THROW 51122, 'A stable CategoryCode was not accepted in both predecessor and Draft versions.', 1;

    IF (SELECT COUNT(*) FROM Cash.tbCategoryTotal WHERE ParentCode = @ParentCode AND ChildCode = @ChildCode) <> 2
        THROW 51123, 'A stable category edge was not accepted in both predecessor and Draft versions.', 1;

    BEGIN TRY
        INSERT INTO Cash.tbCategoryTotal (VersionId, ParentCode, ChildCode, DisplayOrder)
        VALUES (@DraftVersionId, @ParentCode, @MissingDraftChildCode, 999);

        THROW 51124, 'A cross-version category edge was accepted.', 1;
    END TRY
    BEGIN CATCH
        IF ERROR_NUMBER() = 51124 THROW;
    END CATCH;

    ROLLBACK TRAN CategoryTreeCompositeKeyFixture;
    PRINT 'Category Tree composite-key fixture passed.';
END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0 ROLLBACK TRAN CategoryTreeCompositeKeyFixture;
    THROW;
END CATCH;
