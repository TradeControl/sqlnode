CREATE PROCEDURE [Cash].[proc_CategoryVersionSubmissionComplete]
(
    @VersionId NVARCHAR(10),
    @SubmissionLockReference NVARCHAR(64),
    @SubmissionLockSha256 BINARY(32),
    @ChangeNote NVARCHAR(MAX)
)
AS
BEGIN
    SET NOCOUNT, XACT_ABORT ON;

    IF LEN(LTRIM(RTRIM(COALESCE(@ChangeNote, N'')))) = 0
        THROW 51182, 'Category Tree submission completion requires an authority outcome note.', 1;

    DECLARE @UserId NVARCHAR(10), @UserName NVARCHAR(50), @StatusCode SMALLINT;
    SELECT TOP (1) @UserId = UserId, @UserName = UserName FROM Usr.vwCredentials;
    IF @UserId IS NULL
        THROW 51183, 'Category Tree submission completion requires an enabled application user.', 1;

    BEGIN TRY
        BEGIN TRAN;

        DECLARE @LockResult INT;
        EXEC @LockResult = sys.sp_getapplock
            @Resource = N'Cash.CategoryTree.Publish',
            @LockMode = N'Exclusive',
            @LockOwner = N'Transaction',
            @LockTimeout = 15000;
        IF @LockResult < 0
            THROW 51184, 'The Category Tree submission completion could not acquire the lifecycle boundary.', 1;

        IF NOT EXISTS
        (
            SELECT 1 FROM App.tbOptions WITH (UPDLOCK, HOLDLOCK)
            WHERE CategoryVersionId = @VersionId
        )
            THROW 51185, 'Only the active Category Tree can complete a statutory submission.', 1;

        SELECT @StatusCode = VersionStatusCode
        FROM Cash.tbCategoryVersion WITH (UPDLOCK, HOLDLOCK)
        WHERE VersionId = @VersionId;

        IF @StatusCode = 2
           AND NOT EXISTS
           (
               SELECT 1 FROM Cash.tbCategoryVersion
               WHERE VersionId = @VersionId AND SubmissionLockReference IS NOT NULL
           )
        BEGIN
            COMMIT TRAN;
            RETURN;
        END

        IF @StatusCode NOT IN (1, 2)
            THROW 51186, 'The active Category Tree is not eligible for submission completion.', 1;

        IF NOT EXISTS
        (
            SELECT 1 FROM Cash.tbCategoryVersion
            WHERE VersionId = @VersionId
              AND SubmissionLockReference = @SubmissionLockReference
              AND SubmissionLockSha256 = @SubmissionLockSha256
        )
            THROW 51187, 'The statutory workflow does not own this Category Tree submission lock.', 1;

        UPDATE Cash.tbCategoryVersion
        SET VersionStatusCode = CASE WHEN VersionStatusCode = 1 THEN 2 ELSE VersionStatusCode END,
            SubmissionLockReference = NULL,
            SubmissionLockSha256 = NULL,
            SubmissionLockedOn = NULL
        WHERE VersionId = @VersionId;

        IF @StatusCode = 1
            INSERT Cash.tbCategoryVersionEvent
                (VersionId, EventTypeCode, FromStatusCode, ToStatusCode,
                 UserId, UserName, ChangeNote, ContentSha256)
            SELECT VersionId, 4, 1, 2, @UserId, @UserName, @ChangeNote, CanonicalSha256
            FROM Cash.tbCategoryVersion WHERE VersionId = @VersionId;

        COMMIT TRAN;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0 ROLLBACK TRAN;
        THROW;
    END CATCH;
END;
