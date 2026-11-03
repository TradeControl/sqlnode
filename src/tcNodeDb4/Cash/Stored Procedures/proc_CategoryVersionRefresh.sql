CREATE PROCEDURE [Cash].[proc_CategoryVersionRefresh]
(
    @VersionId NVARCHAR(10),
    @ChangeNote NVARCHAR(MAX)
)
AS
BEGIN
    SET NOCOUNT, XACT_ABORT ON;

    DECLARE @PredecessorVersionId NVARCHAR(10), @ActiveVersionId NVARCHAR(10),
            @PredecessorStatusCode SMALLINT, @PredecessorSha256 BINARY(32),
            @DraftSha256 BINARY(32), @CanonicalByteLength BIGINT,
            @UserId NVARCHAR(10), @UserName NVARCHAR(50), @LockResult INT;

    SELECT TOP (1) @UserId = UserId, @UserName = UserName FROM Usr.vwCredentials;
    IF @UserId IS NULL THROW 51165, 'Category Tree refresh requires an enabled application user.', 1;
    IF LEN(LTRIM(RTRIM(COALESCE(@ChangeNote, N'')))) = 0
        THROW 51166, 'Category Tree refresh requires a change note.', 1;

    BEGIN TRY
        BEGIN TRAN;

        EXEC @LockResult = sys.sp_getapplock
            @Resource = N'Cash.CategoryTree.Publish',
            @LockMode = N'Exclusive',
            @LockOwner = N'Transaction',
            @LockTimeout = 15000;
        IF @LockResult < 0 THROW 51167, 'The Category Tree lifecycle lock could not be acquired.', 1;

        SELECT @ActiveVersionId = CategoryVersionId
        FROM App.tbOptions WITH (UPDLOCK, HOLDLOCK);

        SELECT @PredecessorVersionId = PredecessorVersionId
        FROM Cash.tbCategoryVersion WITH (UPDLOCK, HOLDLOCK)
        WHERE VersionId = @VersionId AND VersionStatusCode = 0;

        IF @PredecessorVersionId IS NULL OR @PredecessorVersionId <> @ActiveVersionId
            THROW 51168, 'Only a Draft cloned from the active version can be refreshed.', 1;

        SELECT @PredecessorStatusCode = VersionStatusCode,
               @PredecessorSha256 = CanonicalSha256
        FROM Cash.tbCategoryVersion WITH (UPDLOCK, HOLDLOCK)
        WHERE VersionId = @PredecessorVersionId;

        IF @PredecessorStatusCode NOT IN (1, 2)
            THROW 51169, 'The active predecessor is not eligible for Draft refresh.', 1;

        IF @PredecessorStatusCode = 1
            EXEC Cash.proc_CategoryVersionCanonicalise
                @VersionId = @PredecessorVersionId,
                @CanonicalSha256 = @PredecessorSha256 OUTPUT,
                @CanonicalByteLength = @CanonicalByteLength OUTPUT;

        IF @PredecessorSha256 IS NULL
            THROW 51170, 'The active predecessor does not have canonical evidence.', 1;

        DELETE FROM Cash.tbCategoryRoot WHERE VersionId = @VersionId;
        DELETE FROM Cash.tbCategoryCodeMap WHERE VersionId = @VersionId;
        DELETE FROM Cash.tbCategoryTotal WHERE VersionId = @VersionId;
        DELETE FROM Cash.tbCategory WHERE VersionId = @VersionId;

        INSERT Cash.tbCategory
            (VersionId, CategoryCode, Category, CategoryTypeCode,
             CashPolarityCode, CashTypeCode, DisplayOrder, IsEnabled)
        SELECT @VersionId, CategoryCode, Category, CategoryTypeCode,
               CashPolarityCode, CashTypeCode, DisplayOrder, IsEnabled
        FROM Cash.tbCategory
        WHERE VersionId = @PredecessorVersionId;

        INSERT Cash.tbCategoryTotal (VersionId, ParentCode, ChildCode, DisplayOrder)
        SELECT @VersionId, ParentCode, ChildCode, DisplayOrder
        FROM Cash.tbCategoryTotal
        WHERE VersionId = @PredecessorVersionId;

        INSERT Cash.tbCategoryCodeMap (VersionId, CashCode, CategoryCode)
        SELECT @VersionId, CashCode, CategoryCode
        FROM Cash.tbCategoryCodeMap
        WHERE VersionId = @PredecessorVersionId;

        INSERT Cash.tbCategoryRoot (VersionId, RootTypeCode, CategoryCode)
        SELECT @VersionId, RootTypeCode, CategoryCode
        FROM Cash.tbCategoryRoot
        WHERE VersionId = @PredecessorVersionId;

        UPDATE Cash.tbCategoryVersion
        SET BaseContentSha256 = @PredecessorSha256
        WHERE VersionId = @VersionId;

        EXEC Cash.proc_CategoryVersionCanonicalise
            @VersionId = @VersionId,
            @CanonicalSha256 = @DraftSha256 OUTPUT,
            @CanonicalByteLength = @CanonicalByteLength OUTPUT;

        INSERT Cash.tbCategoryVersionEvent
            (VersionId, EventTypeCode, FromStatusCode, ToStatusCode,
             UserId, UserName, ChangeNote, ContentSha256)
        VALUES
            (@VersionId, 6, 0, 0, @UserId, @UserName, @ChangeNote, @DraftSha256);

        COMMIT TRAN;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0 ROLLBACK TRAN;
        THROW;
    END CATCH;
END;
