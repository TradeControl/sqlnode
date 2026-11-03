CREATE PROCEDURE [Cash].[proc_CategoryVersionSubmit]
(
    @VersionId NVARCHAR(10),
    @ChangeNote NVARCHAR(MAX)
)
AS
BEGIN
    SET NOCOUNT, XACT_ABORT ON;

    DECLARE
        @CanonicalSha256 BINARY(32),
        @CanonicalByteLength BIGINT,
        @UserId NVARCHAR(10),
        @UserName NVARCHAR(50),
        @LockResult INT;

    SELECT TOP (1) @UserId = UserId, @UserName = UserName
    FROM Usr.vwCredentials;

    IF @UserId IS NULL
        THROW 51130, 'Category Tree submission requires an enabled application user.', 1;

    IF LEN(LTRIM(RTRIM(COALESCE(@ChangeNote, N'')))) = 0
        THROW 51131, 'Category Tree submission requires a submission note.', 1;

    BEGIN TRY
        BEGIN TRAN;

        EXEC @LockResult = sys.sp_getapplock
            @Resource = N'Cash.CategoryTree.Publish',
            @LockMode = N'Exclusive',
            @LockOwner = N'Transaction',
            @LockTimeout = 15000;

        IF @LockResult < 0
            THROW 51132, 'The Category Tree lifecycle lock could not be acquired.', 1;

        IF NOT EXISTS
        (
            SELECT 1
            FROM App.tbOptions WITH (UPDLOCK, HOLDLOCK)
            WHERE CategoryVersionId = @VersionId
        )
            THROW 51133, 'Only the active Category Tree version can be submitted.', 1;

        IF NOT EXISTS
        (
            SELECT 1
            FROM Cash.tbCategoryVersion WITH (UPDLOCK, HOLDLOCK)
            WHERE VersionId = @VersionId AND VersionStatusCode = 1
        )
            THROW 51134, 'Only a Published Category Tree version can be submitted.', 1;

        EXEC Cash.proc_CategoryVersionValidate
            @VersionId = @VersionId,
            @CanonicalSha256 = @CanonicalSha256 OUTPUT,
            @CanonicalByteLength = @CanonicalByteLength OUTPUT;

        UPDATE Cash.tbCategoryVersion
        SET VersionStatusCode = 2
        WHERE VersionId = @VersionId;

        INSERT INTO Cash.tbCategoryVersionEvent
        (
            VersionId, EventTypeCode, FromStatusCode, ToStatusCode,
            UserId, UserName, ChangeNote, ContentSha256
        )
        VALUES
        (@VersionId, 4, 1, 2, @UserId, @UserName, @ChangeNote, @CanonicalSha256);

        COMMIT TRAN;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0 ROLLBACK TRAN;
        THROW;
    END CATCH;
END;
