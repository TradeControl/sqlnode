CREATE PROCEDURE [Cash].[proc_CategoryVersionPublish]
(
    @VersionId NVARCHAR(10),
    @ChangeNote NVARCHAR(MAX)
)
AS
BEGIN
    SET NOCOUNT, XACT_ABORT ON;

    DECLARE
        @PredecessorVersionId NVARCHAR(10),
        @PredecessorStatusCode SMALLINT,
        @BaseContentSha256 BINARY(32),
        @PredecessorSha256 BINARY(32),
        @DraftSha256 BINARY(32),
        @CanonicalByteLength BIGINT,
        @PublicationOn DATE = CONVERT(DATE, SYSUTCDATETIME()),
        @EffectiveFromOn DATE,
        @PredecessorEffectiveFromOn DATE,
        @PredecessorSubmissionLockReference NVARCHAR(64),
        @UserId NVARCHAR(10),
        @UserName NVARCHAR(50),
        @LockResult INT;

    SELECT TOP (1) @UserId = UserId, @UserName = UserName
    FROM Usr.vwCredentials;

    IF @UserId IS NULL
        THROW 51124, 'Category Tree publication requires an enabled application user.', 1;

    IF LEN(LTRIM(RTRIM(COALESCE(@ChangeNote, N'')))) = 0
        THROW 51125, 'Category Tree publication requires a change note.', 1;

    BEGIN TRY
        BEGIN TRAN;

        EXEC @LockResult = sys.sp_getapplock
            @Resource = N'Cash.CategoryTree.Publish',
            @LockMode = N'Exclusive',
            @LockOwner = N'Transaction',
            @LockTimeout = 15000;

        IF @LockResult < 0
            THROW 51126, 'The Category Tree lifecycle lock could not be acquired.', 1;

        SELECT @PredecessorVersionId = CategoryVersionId
        FROM App.tbOptions WITH (UPDLOCK, HOLDLOCK);

        SELECT
            @BaseContentSha256 = BaseContentSha256,
            @EffectiveFromOn = EffectiveFromOn
        FROM Cash.tbCategoryVersion WITH (UPDLOCK, HOLDLOCK)
        WHERE VersionId = @VersionId
          AND VersionStatusCode = 0
          AND PredecessorVersionId = @PredecessorVersionId;

        IF @BaseContentSha256 IS NULL
            THROW 51127, 'The Draft is not a successor of the active version.', 1;

        IF @EffectiveFromOn IS NULL
            THROW 51165, 'Category Tree publication requires a proposed effective date.', 1;

        IF @EffectiveFromOn > @PublicationOn
            THROW 51166, 'A Category Tree Draft cannot be published before its proposed effective date.', 1;

        SELECT
            @PredecessorStatusCode = VersionStatusCode,
            @PredecessorSha256 = CanonicalSha256,
            @PredecessorEffectiveFromOn = EffectiveFromOn,
            @PredecessorSubmissionLockReference = SubmissionLockReference
        FROM Cash.tbCategoryVersion WITH (UPDLOCK, HOLDLOCK)
        WHERE VersionId = @PredecessorVersionId;

        IF @PredecessorStatusCode NOT IN (1, 2)
            THROW 51128, 'The active predecessor is not eligible for successor publication.', 1;

        IF @PredecessorSubmissionLockReference IS NOT NULL
            THROW 51181, 'The active predecessor is locked by an unfinished statutory filing.', 1;

        IF @PredecessorEffectiveFromOn IS NULL OR @EffectiveFromOn <= @PredecessorEffectiveFromOn
            THROW 51167, 'A successor Category Tree must become effective after its predecessor.', 1;

        IF @PredecessorStatusCode = 1
            EXEC Cash.proc_CategoryVersionCanonicalise
                @VersionId = @PredecessorVersionId,
                @CanonicalSha256 = @PredecessorSha256 OUTPUT,
                @CanonicalByteLength = @CanonicalByteLength OUTPUT;

        IF @PredecessorSha256 <> @BaseContentSha256
            THROW 51129, 'The active predecessor changed after this Draft was cloned.', 1;

        EXEC Cash.proc_CategoryVersionValidate
            @VersionId = @VersionId,
            @CanonicalSha256 = @DraftSha256 OUTPUT,
            @CanonicalByteLength = @CanonicalByteLength OUTPUT;

        UPDATE Cash.tbCategoryVersion
        SET VersionStatusCode = 1,
            EffectiveFromOn = @EffectiveFromOn,
            EffectiveToOn = NULL
        WHERE VersionId = @VersionId;

        UPDATE App.tbOptions
        SET CategoryVersionId = @VersionId;

        UPDATE Cash.tbCategoryVersion
        SET VersionStatusCode = 3,
            EffectiveToOn = DATEADD(DAY, -1, @EffectiveFromOn)
        WHERE VersionId = @PredecessorVersionId;

        INSERT INTO Cash.tbCategoryVersionEvent
        (
            VersionId, EventTypeCode, FromStatusCode, ToStatusCode,
            UserId, UserName, ChangeNote, ContentSha256
        )
        VALUES
        (@VersionId, 3, 0, 1, @UserId, @UserName, @ChangeNote, @DraftSha256),
        (@PredecessorVersionId, 5, @PredecessorStatusCode, 3,
         @UserId, @UserName, N'Archived by successor publication.', @PredecessorSha256);

        COMMIT TRAN;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0 ROLLBACK TRAN;
        THROW;
    END CATCH;
END;
