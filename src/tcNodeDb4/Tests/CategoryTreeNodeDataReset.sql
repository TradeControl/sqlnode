/*
    Category Tree full-node reset fixture.
    Run against a commissioned node. All mutations roll back.
*/
SET NOCOUNT ON;
SET XACT_ABORT ON;

DECLARE
    @ActiveVersionId NVARCHAR(10) = (SELECT CategoryVersionId FROM App.tbOptions),
    @UserId NVARCHAR(10) = (SELECT TOP (1) UserId FROM Usr.vwCredentials),
    @LockSha256 BINARY(32) = HASHBYTES('SHA2_256', N'CategoryTreeNodeDataReset'),
    @InstallCount INT = (SELECT COUNT(*) FROM App.tbInstall),
    @LatestInstallId INT = (SELECT MAX(InstallId) FROM App.tbInstall);

IF @ActiveVersionId IS NULL OR @UserId IS NULL
    THROW 51210, 'The Category Tree reset fixture requires a commissioned node and current user.', 1;

/* Archived history and an unfinished submission must not prevent a deliberate full-node reset. */
BEGIN TRAN CategoryTreeFullResetFixture;
BEGIN TRY
    DECLARE @ArchivedVersionId NVARCHAR(10);
    EXEC Cash.proc_CategoryVersionIdNext @VersionId = @ArchivedVersionId OUTPUT;

    INSERT INTO Cash.tbCategoryVersion
    (
        VersionId, VersionStatusCode, Description, CreatedByUserId
    )
    VALUES
    (
        @ArchivedVersionId, 0, N'Node reset archived-history fixture', @UserId
    );

    INSERT INTO Cash.tbCategory
    (
        VersionId, CategoryCode, Category, CategoryTypeCode,
        CashPolarityCode, CashTypeCode, DisplayOrder, IsEnabled
    )
    SELECT
        @ArchivedVersionId, CategoryCode, Category, CategoryTypeCode,
        CashPolarityCode, CashTypeCode, DisplayOrder, IsEnabled
    FROM Cash.tbCategory
    WHERE VersionId = @ActiveVersionId;

    INSERT INTO Cash.tbCategoryTotal (VersionId, ParentCode, ChildCode, DisplayOrder)
    SELECT @ArchivedVersionId, ParentCode, ChildCode, DisplayOrder
    FROM Cash.tbCategoryTotal
    WHERE VersionId = @ActiveVersionId;

    INSERT INTO Cash.tbCategoryCodeMap (VersionId, CashCode, CategoryCode)
    SELECT @ArchivedVersionId, CashCode, CategoryCode
    FROM Cash.tbCategoryCodeMap
    WHERE VersionId = @ActiveVersionId;

    INSERT INTO Cash.tbCategoryRoot (VersionId, RootTypeCode, CategoryCode)
    SELECT @ArchivedVersionId, RootTypeCode, CategoryCode
    FROM Cash.tbCategoryRoot
    WHERE VersionId = @ActiveVersionId;

    UPDATE Cash.tbCategoryVersion
    SET VersionStatusCode = 3,
        EffectiveFromOn = '20000101',
        EffectiveToOn = '20001231'
    WHERE VersionId = @ArchivedVersionId;

    UPDATE Cash.tbCategoryVersion
    SET SubmissionLockReference = N'CATEGORY-TREE-RESET-FIXTURE',
        SubmissionLockSha256 = @LockSha256,
        SubmissionLockedOn = SYSUTCDATETIME()
    WHERE VersionId = @ActiveVersionId;

    EXEC App.proc_NodeDataInit;

    IF EXISTS (SELECT 1 FROM Cash.tbCategoryVersion)
        THROW 51211, 'Node data reset retained Category Tree version or submission-lock history.', 1;

    IF (SELECT COUNT(*) FROM Cash.tbCategoryVersionStatus) <> 4
        THROW 51212, 'Node data reset did not retain the Category Tree status catalogue.', 1;

    IF (SELECT COUNT(*) FROM App.tbInstall) <> @InstallCount
       OR COALESCE((SELECT MAX(InstallId) FROM App.tbInstall), -1) <> COALESCE(@LatestInstallId, -1)
        THROW 51213, 'Node data reset changed the deployment-owned schema build history.', 1;

    ROLLBACK TRAN CategoryTreeFullResetFixture;
    PRINT 'Category Tree node-data reset fixture passed.';
END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0 ROLLBACK TRAN CategoryTreeFullResetFixture;
    THROW;
END CATCH;
