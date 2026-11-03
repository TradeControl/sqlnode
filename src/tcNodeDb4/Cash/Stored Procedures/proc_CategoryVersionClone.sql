CREATE PROCEDURE [Cash].[proc_CategoryVersionClone]
(
    @Description NVARCHAR(100),
    @Notes NVARCHAR(MAX) = NULL,
    @VersionId NVARCHAR(10) = NULL OUTPUT
)
AS
BEGIN
    SET NOCOUNT, XACT_ABORT ON;

    DECLARE
        @PredecessorVersionId NVARCHAR(10),
        @PredecessorStatusCode SMALLINT,
        @BaseContentSha256 BINARY(32),
        @CanonicalByteLength BIGINT,
        @UserId NVARCHAR(10),
        @UserName NVARCHAR(50),
        @LockResult INT;

    SELECT TOP (1) @UserId = UserId, @UserName = UserName
    FROM Usr.vwCredentials;

    IF @UserId IS NULL
        THROW 51119, 'Category Tree cloning requires an enabled application user.', 1;

    IF LEN(LTRIM(RTRIM(COALESCE(@Description, N'')))) = 0
        THROW 51120, 'A successor Draft requires a description.', 1;

    BEGIN TRY
        BEGIN TRAN;

        EXEC @LockResult = sys.sp_getapplock
            @Resource = N'Cash.CategoryTree.Publish',
            @LockMode = N'Exclusive',
            @LockOwner = N'Transaction',
            @LockTimeout = 15000;

        IF @LockResult < 0
            THROW 51121, 'The Category Tree lifecycle lock could not be acquired.', 1;

        SELECT @PredecessorVersionId = CategoryVersionId
        FROM App.tbOptions WITH (UPDLOCK, HOLDLOCK);

        SELECT
            @PredecessorStatusCode = VersionStatusCode,
            @BaseContentSha256 = CanonicalSha256
        FROM Cash.tbCategoryVersion WITH (UPDLOCK, HOLDLOCK)
        WHERE VersionId = @PredecessorVersionId;

        IF @PredecessorStatusCode NOT IN (1, 2)
            THROW 51122, 'A successor Draft requires an active Published or Submitted predecessor.', 1;

        IF @PredecessorStatusCode = 1
            EXEC Cash.proc_CategoryVersionCanonicalise
                @VersionId = @PredecessorVersionId,
                @CanonicalSha256 = @BaseContentSha256 OUTPUT,
                @CanonicalByteLength = @CanonicalByteLength OUTPUT;

        IF @BaseContentSha256 IS NULL
            THROW 51123, 'The active predecessor does not have canonical evidence.', 1;

        EXEC Cash.proc_CategoryVersionIdNext @VersionId = @VersionId OUTPUT;

        INSERT INTO Cash.tbCategoryVersion
        (
            VersionId, VersionStatusCode, Description, Notes,
            PredecessorVersionId, BaseContentSha256, CreatedByUserId
        )
        VALUES
        (
            @VersionId, 0, @Description, @Notes,
            @PredecessorVersionId, @BaseContentSha256, @UserId
        );

        INSERT INTO Cash.tbCategory
        (
            VersionId, CategoryCode, Category, CategoryTypeCode,
            CashPolarityCode, CashTypeCode, DisplayOrder, IsEnabled
        )
        SELECT
            @VersionId, CategoryCode, Category, CategoryTypeCode,
            CashPolarityCode, CashTypeCode, DisplayOrder, IsEnabled
        FROM Cash.tbCategory
        WHERE VersionId = @PredecessorVersionId;

        INSERT INTO Cash.tbCategoryTotal (VersionId, ParentCode, ChildCode, DisplayOrder)
        SELECT @VersionId, ParentCode, ChildCode, DisplayOrder
        FROM Cash.tbCategoryTotal
        WHERE VersionId = @PredecessorVersionId;

        INSERT INTO Cash.tbCategoryCodeMap (VersionId, CashCode, CategoryCode)
        SELECT @VersionId, CashCode, CategoryCode
        FROM Cash.tbCategoryCodeMap
        WHERE VersionId = @PredecessorVersionId;

        INSERT INTO Cash.tbCategoryRoot (VersionId, RootTypeCode, CategoryCode)
        SELECT @VersionId, RootTypeCode, CategoryCode
        FROM Cash.tbCategoryRoot
        WHERE VersionId = @PredecessorVersionId;

        EXEC Cash.proc_CategoryVersionCanonicalise
            @VersionId = @VersionId,
            @CanonicalSha256 = @BaseContentSha256 OUTPUT,
            @CanonicalByteLength = @CanonicalByteLength OUTPUT;

        INSERT INTO Cash.tbCategoryVersionEvent
        (
            VersionId, EventTypeCode, ToStatusCode,
            UserId, UserName, ChangeNote, ContentSha256
        )
        VALUES
        (
            @VersionId, 0, 0,
            @UserId, @UserName, N'Successor Draft cloned from the active version.', @BaseContentSha256
        );

        COMMIT TRAN;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0 ROLLBACK TRAN;
        THROW;
    END CATCH;
END;
