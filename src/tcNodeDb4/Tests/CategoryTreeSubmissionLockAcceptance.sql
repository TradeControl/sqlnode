/*
    Category Tree durable submission-lock acceptance.

    The publication and successful-completion phases are rollback-only. The
    observable lock phase is released explicitly, including best-effort cleanup
    from its CATCH block. A passing run restores the original Published version,
    pointer, canonical evidence and empty lock state.
*/
SET NOCOUNT ON;
SET XACT_ABORT ON;

DECLARE
    @VersionId NVARCHAR(10),
    @DraftVersionId NVARCHAR(10),
    @UserId NVARCHAR(10),
    @CanonicalProfile NVARCHAR(50),
    @CanonicalSha256 BINARY(32),
    @CanonicalByteLength BIGINT,
    @LockReference NVARCHAR(64) = N'hosted-category-tree-lock-acceptance',
    @CompletionReference NVARCHAR(64) = N'hosted-category-tree-completion-acceptance',
    @LockSha256 BINARY(32) = HASHBYTES('SHA2_256', N'hosted-category-tree-lock-acceptance'),
    @CompletionSha256 BINARY(32) = HASHBYTES('SHA2_256', N'hosted-category-tree-completion-acceptance'),
    @EffectiveFromOn DATE = CONVERT(DATE, SYSUTCDATETIME()),
    @LockedOn DATETIME2(3),
    @PublishRejected BIT = 0,
    @CompetingLockRejected BIT = 0,
    @WrongReleaseRejected BIT = 0,
    @CanonicalMismatchRejected BIT = 0,
    @ManualSubmitRejected BIT = 0;

SELECT
    @VersionId = options.CategoryVersionId,
    @CanonicalProfile = version.CanonicalProfile,
    @CanonicalSha256 = version.CanonicalSha256,
    @CanonicalByteLength = version.CanonicalByteLength
FROM App.tbOptions AS options
JOIN Cash.tbCategoryVersion AS version
  ON version.VersionId = options.CategoryVersionId
WHERE version.VersionStatusCode = 1
  AND version.SubmissionLockReference IS NULL;

SELECT TOP (1) @UserId = UserId
FROM Usr.tbUser
WHERE IsEnabled <> 0
ORDER BY IsAdministrator DESC, UserId;

IF @VersionId IS NULL OR @UserId IS NULL
    THROW 51970, 'Acceptance requires one unlocked active Published version and an enabled user.', 1;

/* A locked predecessor must reject successor publication atomically. */
BEGIN TRY
    BEGIN TRANSACTION;

    UPDATE Usr.tbUser
    SET LogonName = SUSER_SNAME()
    WHERE UserId = @UserId;

    EXEC Cash.proc_CategoryVersionClone
        @Description = N'Submission-lock acceptance Draft',
        @Notes = N'Rollback-only hosted acceptance.',
        @EffectiveFromOn = @EffectiveFromOn,
        @VersionId = @DraftVersionId OUTPUT;

    EXEC Cash.proc_CategoryVersionSubmissionLockAcquire
        @VersionId = @VersionId,
        @CanonicalProfile = @CanonicalProfile,
        @CanonicalSha256 = @CanonicalSha256,
        @CanonicalByteLength = @CanonicalByteLength,
        @SubmissionLockReference = @LockReference,
        @SubmissionLockSha256 = @LockSha256;

    BEGIN TRY
        EXEC Cash.proc_CategoryVersionPublish
            @VersionId = @DraftVersionId,
            @ChangeNote = N'Expected submission-lock rejection.';
    END TRY
    BEGIN CATCH
        IF ERROR_NUMBER() = 51181
            SET @PublishRejected = 1;
        ELSE
            THROW;
    END CATCH;

    IF XACT_STATE() <> 0
        ROLLBACK TRANSACTION;
END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0
        ROLLBACK TRANSACTION;
    THROW;
END CATCH;

IF @PublishRejected = 0
    THROW 51971, 'A locked predecessor did not reject successor publication.', 1;

IF (SELECT CategoryVersionId FROM App.tbOptions) <> @VersionId
   OR EXISTS (SELECT 1 FROM Cash.tbCategoryVersion WHERE VersionId = @DraftVersionId)
   OR EXISTS
      (
          SELECT 1
          FROM Cash.tbCategoryVersion
          WHERE VersionId = @VersionId
            AND SubmissionLockReference IS NOT NULL
      )
    THROW 51972, 'The rejected publication did not restore the baseline atomically.', 1;

/* Reject stale canonical evidence before a lock is acquired. */
BEGIN TRY
    EXEC Cash.proc_CategoryVersionSubmissionLockAcquire
        @VersionId = @VersionId,
        @CanonicalProfile = @CanonicalProfile,
        @CanonicalSha256 = 0x00,
        @CanonicalByteLength = @CanonicalByteLength,
        @SubmissionLockReference = @LockReference,
        @SubmissionLockSha256 = @LockSha256;
END TRY
BEGIN CATCH
    IF ERROR_NUMBER() = 51177
        SET @CanonicalMismatchRejected = 1;
    ELSE
        THROW;
END CATCH;

IF @CanonicalMismatchRejected = 0
    THROW 51973, 'Stale canonical evidence was accepted for locking.', 1;

/* Exercise a visible durable lock, with explicit cleanup on every path. */
BEGIN TRY
    EXEC Cash.proc_CategoryVersionSubmissionLockAcquire
        @VersionId = @VersionId,
        @CanonicalProfile = @CanonicalProfile,
        @CanonicalSha256 = @CanonicalSha256,
        @CanonicalByteLength = @CanonicalByteLength,
        @SubmissionLockReference = @LockReference,
        @SubmissionLockSha256 = @LockSha256;

    SELECT @LockedOn = SubmissionLockedOn
    FROM Cash.tbCategoryVersion
    WHERE VersionId = @VersionId
      AND SubmissionLockReference = @LockReference
      AND SubmissionLockSha256 = @LockSha256;

    IF @LockedOn IS NULL
        THROW 51974, 'The durable lock was not stored.', 1;

    EXEC Cash.proc_CategoryVersionSubmissionLockAcquire
        @VersionId = @VersionId,
        @CanonicalProfile = @CanonicalProfile,
        @CanonicalSha256 = @CanonicalSha256,
        @CanonicalByteLength = @CanonicalByteLength,
        @SubmissionLockReference = @LockReference,
        @SubmissionLockSha256 = @LockSha256;

    IF (SELECT SubmissionLockedOn FROM Cash.tbCategoryVersion WHERE VersionId = @VersionId) <> @LockedOn
        THROW 51975, 'Idempotent acquisition changed the original lock timestamp.', 1;

    BEGIN TRY
        EXEC Cash.proc_CategoryVersionSubmissionLockAcquire
            @VersionId = @VersionId,
            @CanonicalProfile = @CanonicalProfile,
            @CanonicalSha256 = @CanonicalSha256,
            @CanonicalByteLength = @CanonicalByteLength,
            @SubmissionLockReference = N'competing-hosted-workflow',
            @SubmissionLockSha256 = 0x01;
    END TRY
    BEGIN CATCH
        IF ERROR_NUMBER() = 51178
            SET @CompetingLockRejected = 1;
        ELSE
            THROW;
    END CATCH;

    BEGIN TRY
        EXEC Cash.proc_CategoryVersionSubmissionLockRelease
            @VersionId = @VersionId,
            @SubmissionLockReference = N'wrong-hosted-workflow',
            @SubmissionLockSha256 = 0x02;
    END TRY
    BEGIN CATCH
        IF ERROR_NUMBER() = 51180
            SET @WrongReleaseRejected = 1;
        ELSE
            THROW;
    END CATCH;

    IF @CompetingLockRejected = 0
       OR @WrongReleaseRejected = 0
        THROW 51976, 'One or more locked-state guards did not reject the operation.', 1;

    IF NOT EXISTS
    (
        SELECT 1
        FROM Cash.tbCategoryVersion
        WHERE VersionId = @VersionId
          AND VersionStatusCode = 1
          AND CanonicalSha256 = @CanonicalSha256
          AND CanonicalByteLength = @CanonicalByteLength
          AND SubmissionLockReference = @LockReference
          AND SubmissionLockSha256 = @LockSha256
          AND SubmissionLockedOn = @LockedOn
    )
        THROW 51977, 'A rejected locked-state operation changed the version or its lock.', 1;

    EXEC Cash.proc_CategoryVersionSubmissionLockRelease
        @VersionId = @VersionId,
        @SubmissionLockReference = @LockReference,
        @SubmissionLockSha256 = @LockSha256;
END TRY
BEGIN CATCH
    IF EXISTS
    (
        SELECT 1
        FROM Cash.tbCategoryVersion
        WHERE VersionId = @VersionId
          AND SubmissionLockReference = @LockReference
          AND SubmissionLockSha256 = @LockSha256
    )
        EXEC Cash.proc_CategoryVersionSubmissionLockRelease
            @VersionId = @VersionId,
            @SubmissionLockReference = @LockReference,
            @SubmissionLockSha256 = @LockSha256;
    THROW;
END CATCH;

IF EXISTS
(
    SELECT 1
    FROM Cash.tbCategoryVersion
    WHERE VersionId = @VersionId
      AND SubmissionLockReference IS NOT NULL
)
    THROW 51978, 'Conclusive release did not clear the durable lock.', 1;

/* Manual submission is no longer an alternative lifecycle path. */
BEGIN TRY
    EXEC Cash.proc_CategoryVersionSubmit
        @VersionId = @VersionId,
        @ChangeNote = N'Expected sealed-workflow-only rejection.';
END TRY
BEGIN CATCH
    IF ERROR_NUMBER() = 51188
        SET @ManualSubmitRejected = 1;
    ELSE
        THROW;
END CATCH;

IF @ManualSubmitRejected = 0
    THROW 51979, 'The retired manual submission path remained available.', 1;

/* Prove the successful transition and event inside a transaction, then undo it. */
BEGIN TRY
    BEGIN TRANSACTION;

    UPDATE Usr.tbUser
    SET LogonName = SUSER_SNAME()
    WHERE UserId = @UserId;

    EXEC Cash.proc_CategoryVersionSubmissionLockAcquire
        @VersionId = @VersionId,
        @CanonicalProfile = @CanonicalProfile,
        @CanonicalSha256 = @CanonicalSha256,
        @CanonicalByteLength = @CanonicalByteLength,
        @SubmissionLockReference = @CompletionReference,
        @SubmissionLockSha256 = @CompletionSha256;

    EXEC Cash.proc_CategoryVersionSubmissionComplete
        @VersionId = @VersionId,
        @SubmissionLockReference = @CompletionReference,
        @SubmissionLockSha256 = @CompletionSha256,
        @ChangeNote = N'Rollback-only hosted completion acceptance.';

    IF NOT EXISTS
    (
        SELECT 1
        FROM Cash.tbCategoryVersion
        WHERE VersionId = @VersionId
          AND VersionStatusCode = 2
          AND SubmissionLockReference IS NULL
          AND CanonicalSha256 = @CanonicalSha256
          AND CanonicalByteLength = @CanonicalByteLength
    )
        THROW 51980, 'Successful completion did not produce the expected Submitted state.', 1;

    IF NOT EXISTS
    (
        SELECT 1
        FROM Cash.tbCategoryVersionEvent
        WHERE VersionId = @VersionId
          AND EventTypeCode = 4
          AND FromStatusCode = 1
          AND ToStatusCode = 2
          AND ChangeNote = N'Rollback-only hosted completion acceptance.'
          AND ContentSha256 = @CanonicalSha256
    )
        THROW 51981, 'Successful completion did not record the sealed lifecycle event.', 1;

    ROLLBACK TRANSACTION;
END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0
        ROLLBACK TRANSACTION;
    THROW;
END CATCH;

IF NOT EXISTS
(
    SELECT 1
    FROM App.tbOptions AS options
    JOIN Cash.tbCategoryVersion AS version
      ON version.VersionId = options.CategoryVersionId
    WHERE options.CategoryVersionId = @VersionId
      AND version.VersionStatusCode = 1
      AND version.CanonicalProfile = @CanonicalProfile
      AND version.CanonicalSha256 = @CanonicalSha256
      AND version.CanonicalByteLength = @CanonicalByteLength
      AND version.SubmissionLockReference IS NULL
      AND version.SubmissionLockSha256 IS NULL
      AND version.SubmissionLockedOn IS NULL
)
    THROW 51982, 'The acceptance fixture did not restore the Published baseline.', 1;

SELECT
    N'PASS' AS SubmissionLockAcceptanceStatus,
    @VersionId AS RestoredActiveVersionId,
    @CanonicalMismatchRejected AS CanonicalMismatchRejected,
    @PublishRejected AS LockedPublicationRejected,
    @CompetingLockRejected AS CompetingLockRejected,
    @WrongReleaseRejected AS WrongReleaseRejected,
    @ManualSubmitRejected AS ManualSubmitRejected;
