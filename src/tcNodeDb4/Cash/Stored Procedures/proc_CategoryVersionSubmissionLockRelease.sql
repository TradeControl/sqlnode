CREATE PROCEDURE [Cash].[proc_CategoryVersionSubmissionLockRelease]
(
    @VersionId NVARCHAR(10),
    @SubmissionLockReference NVARCHAR(64),
    @SubmissionLockSha256 BINARY(32)
)
AS
BEGIN
    SET NOCOUNT, XACT_ABORT ON;

    BEGIN TRY
        BEGIN TRAN;

        DECLARE @LockResult INT;
        EXEC @LockResult = sys.sp_getapplock
            @Resource = N'Cash.CategoryTree.Publish',
            @LockMode = N'Exclusive',
            @LockOwner = N'Transaction',
            @LockTimeout = 15000;

        IF @LockResult < 0
            THROW 51179, 'The Category Tree submission lock could not acquire the lifecycle boundary.', 1;

        IF EXISTS
        (
            SELECT 1
            FROM Cash.tbCategoryVersion WITH (UPDLOCK, HOLDLOCK)
            WHERE VersionId = @VersionId
              AND SubmissionLockReference IS NOT NULL
              AND (SubmissionLockReference <> @SubmissionLockReference
                   OR SubmissionLockSha256 <> @SubmissionLockSha256)
        )
            THROW 51180, 'The statutory workflow does not own this Category Tree submission lock.', 1;

        UPDATE Cash.tbCategoryVersion
        SET SubmissionLockReference = NULL,
            SubmissionLockSha256 = NULL,
            SubmissionLockedOn = NULL
        WHERE VersionId = @VersionId
          AND SubmissionLockReference = @SubmissionLockReference
          AND SubmissionLockSha256 = @SubmissionLockSha256;

        COMMIT TRAN;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0 ROLLBACK TRAN;
        THROW;
    END CATCH;
END;
