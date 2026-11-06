CREATE PROCEDURE [Cash].[proc_CategoryVersionSubmissionLockAcquire]
(
    @VersionId NVARCHAR(10),
    @CanonicalProfile NVARCHAR(50),
    @CanonicalSha256 BINARY(32),
    @CanonicalByteLength BIGINT,
    @SubmissionLockReference NVARCHAR(64),
    @SubmissionLockSha256 BINARY(32)
)
AS
BEGIN
    SET NOCOUNT, XACT_ABORT ON;

    IF LEN(LTRIM(RTRIM(COALESCE(@SubmissionLockReference, N'')))) = 0
        THROW 51174, 'A durable statutory workflow reference is required.', 1;

    BEGIN TRY
        BEGIN TRAN;

        DECLARE @LockResult INT;
        EXEC @LockResult = sys.sp_getapplock
            @Resource = N'Cash.CategoryTree.Publish',
            @LockMode = N'Exclusive',
            @LockOwner = N'Transaction',
            @LockTimeout = 15000;

        IF @LockResult < 0
            THROW 51175, 'The Category Tree submission lock could not acquire the lifecycle boundary.', 1;

        IF NOT EXISTS
        (
            SELECT 1
            FROM App.tbOptions WITH (UPDLOCK, HOLDLOCK)
            WHERE CategoryVersionId = @VersionId
        )
            THROW 51176, 'Only the active Category Tree can be locked for statutory submission.', 1;

        IF NOT EXISTS
        (
            SELECT 1
            FROM Cash.tbCategoryVersion WITH (UPDLOCK, HOLDLOCK)
            WHERE VersionId = @VersionId
              AND VersionStatusCode IN (1, 2)
              AND CanonicalProfile = @CanonicalProfile
              AND CanonicalSha256 = @CanonicalSha256
              AND CanonicalByteLength = @CanonicalByteLength
        )
            THROW 51177, 'The Category Tree statutory evidence changed before the submission lock was acquired.', 1;

        IF EXISTS
        (
            SELECT 1
            FROM Cash.tbCategoryVersion
            WHERE VersionId = @VersionId
              AND SubmissionLockReference IS NOT NULL
              AND (SubmissionLockReference <> @SubmissionLockReference
                   OR SubmissionLockSha256 <> @SubmissionLockSha256)
        )
            THROW 51178, 'Another statutory workflow already owns the active Category Tree submission lock.', 1;

        UPDATE Cash.tbCategoryVersion
        SET SubmissionLockReference = @SubmissionLockReference,
            SubmissionLockSha256 = @SubmissionLockSha256,
            SubmissionLockedOn = COALESCE(SubmissionLockedOn, SYSUTCDATETIME())
        WHERE VersionId = @VersionId
          AND SubmissionLockReference IS NULL;

        COMMIT TRAN;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0 ROLLBACK TRAN;
        THROW;
    END CATCH;
END;
