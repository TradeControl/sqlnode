/*
    Rollback-only Category Tree lifecycle and mutation-boundary fixture.

    Run against an initialised node as a login that can update the disposable
    test database. The application actor binding is changed only inside the
    transaction and is restored by the final expected rollback.
*/
SET NOCOUNT ON;
SET XACT_ABORT ON;

IF EXISTS
(
    SELECT 1
    FROM sys.columns
    WHERE object_id = OBJECT_ID(N'Cash.tbCategory')
      AND name IN (N'CashPolarityCode', N'CashTypeCode')
      AND is_nullable = 1
)
    THROW 51962, 'Category classification fields must be structurally required.', 1;

IF COL_LENGTH(N'App.tbOptions', N'NetProfitCode') IS NOT NULL
   OR COL_LENGTH(N'App.tbOptions', N'VatCategoryCode') IS NOT NULL
   OR COL_LENGTH(N'Cash.tbCode', N'CategoryCode') IS NOT NULL
    THROW 51958, 'A retired Category Tree authority column is still present.', 1;

IF OBJECT_ID(N'Cash.Cash_tbCode_TriggerCategoryVersionShadow', N'TR') IS NOT NULL
   OR EXISTS
      (
          SELECT 1
          FROM sys.indexes
          WHERE object_id = OBJECT_ID(N'Cash.tbCode')
            AND name = N'IX_Cash_tbCode_Category_IsEnabled_Code'
      )
    THROW 51959, 'A retired Category Tree compatibility writer or index is still present.', 1;

IF EXISTS
(
    SELECT 1
    FROM sys.objects AS legacy
    JOIN sys.schemas AS schema_name
      ON schema_name.schema_id = legacy.schema_id
    WHERE schema_name.name = N'Usr'
      AND legacy.name IN
      (
          N'vwUserMenuList', N'vwUserMenus', N'vwMenuItemFormMode', N'vwMenuItemReportMode',
          N'proc_MenuCleanReferences', N'proc_MenuInsert', N'proc_MenuItemDelete',
          N'tbMenuUser', N'tbMenuEntry', N'tbMenu', N'tbMenuCommand', N'tbMenuOpenMode', N'tbMenuView'
      )
)
    THROW 51961, 'The retired Usr menu subsystem is still present.', 1;

IF EXISTS
(
    SELECT 1
    FROM sys.sql_modules
    WHERE definition LIKE N'%NetProfitCode%'
       OR definition LIKE N'%VatCategoryCode%'
)
    THROW 51960, 'A compiled module still references a retired options-root column.', 1;

DECLARE
    @OriginalVersionId NVARCHAR(10),
    @DraftVersionId NVARCHAR(10),
    @UserId NVARCHAR(10),
    @CategoryCode NVARCHAR(10),
    @Category NVARCHAR(50),
    @CategoryTypeCode SMALLINT,
    @CashPolarityCode SMALLINT,
    @CashTypeCode SMALLINT,
    @DisplayOrder SMALLINT,
    @IsEnabled SMALLINT,
    @TaxCode NVARCHAR(10),
    @OriginalSha256 BINARY(32),
    @OriginalCategory NVARCHAR(50),
    @FixtureCategory NVARCHAR(50),
    @ProtectedCashCode NVARCHAR(50),
    @EffectiveFromOn DATE = CONVERT(DATE, SYSUTCDATETIME()),
    @DirectDmlRejected BIT = 0,
    @DeleteRejected BIT = 0;

SELECT @OriginalVersionId = CategoryVersionId FROM App.tbOptions;
SELECT TOP (1) @UserId = UserId
FROM Usr.tbUser
WHERE IsEnabled <> 0
ORDER BY IsAdministrator DESC, UserId;

IF @OriginalVersionId IS NULL OR @UserId IS NULL
    THROW 51940, 'The lifecycle fixture requires one active version and an enabled user.', 1;

BEGIN TRY
    BEGIN TRANSACTION;

    UPDATE Usr.tbUser
    SET LogonName = SUSER_SNAME()
    WHERE UserId = @UserId;

    IF NOT EXISTS (SELECT 1 FROM Usr.vwCredentials WHERE UserId = @UserId)
        THROW 51941, 'The lifecycle fixture could not bind the SQL login to its disposable application actor.', 1;

    EXEC Cash.proc_CategoryVersionClone
        @Description = N'Lifecycle fixture Draft',
        @Notes = N'Rollback-only SQL acceptance.',
        @EffectiveFromOn = @EffectiveFromOn,
        @VersionId = @DraftVersionId OUTPUT;

    SELECT @OriginalSha256 = CanonicalSha256
    FROM Cash.tbCategoryVersion
    WHERE VersionId = @OriginalVersionId;

    IF (SELECT CategoryVersionId FROM App.tbOptions) <> @OriginalVersionId
        THROW 51942, 'Cloning a Draft changed the active version.', 1;
    IF NOT EXISTS
    (
        SELECT 1
        FROM Cash.tbCategoryVersion
        WHERE VersionId = @DraftVersionId
          AND VersionStatusCode = 0
          AND PredecessorVersionId = @OriginalVersionId
          AND BaseContentSha256 = @OriginalSha256
    )
        THROW 51943, 'The cloned Draft does not retain its predecessor evidence.', 1;

    SELECT TOP (1)
        @CategoryCode = CategoryCode,
        @Category = Category,
        @CategoryTypeCode = CategoryTypeCode,
        @CashPolarityCode = CashPolarityCode,
        @CashTypeCode = CashTypeCode,
        @DisplayOrder = DisplayOrder,
        @IsEnabled = IsEnabled
    FROM Cash.tbCategory
    WHERE VersionId = @DraftVersionId
      AND CategoryTypeCode = 0
    ORDER BY CategoryCode;

    SET @OriginalCategory = @Category;
    SET @FixtureCategory = CONCAT(@Category, N' test');

    EXEC Cash.proc_CategorySave
        @VersionId = @DraftVersionId,
        @CategoryCode = @CategoryCode,
        @Category = @FixtureCategory,
        @CategoryTypeCode = @CategoryTypeCode,
        @CashPolarityCode = @CashPolarityCode,
        @CashTypeCode = @CashTypeCode,
        @DisplayOrder = @DisplayOrder,
        @IsEnabled = @IsEnabled,
        @ChangeNote = N'Lifecycle fixture isolated Draft edit.';

    IF (SELECT Category FROM Cash.tbCategory WHERE VersionId = @OriginalVersionId AND CategoryCode = @CategoryCode) <> @OriginalCategory
        THROW 51944, 'A Draft edit leaked into the active predecessor.', 1;

    EXEC Cash.proc_CategoryVersionRefresh
        @VersionId = @DraftVersionId,
        @ChangeNote = N'Lifecycle fixture refresh.';

    IF (SELECT Category FROM Cash.tbCategory WHERE VersionId = @DraftVersionId AND CategoryCode = @CategoryCode) <> @OriginalCategory
        THROW 51945, 'Draft refresh did not restore predecessor content.', 1;

    EXEC Cash.proc_CategoryVersionNotesSet
        @VersionId = @DraftVersionId,
        @Description = N'Lifecycle fixture refreshed Draft',
        @Notes = N'Refreshed and ready to publish.',
        @ChangeNote = N'Lifecycle fixture metadata edit.';

    EXEC Cash.proc_CategoryVersionPublish
        @VersionId = @DraftVersionId,
        @ChangeNote = N'Lifecycle fixture publication.';

    IF (SELECT CategoryVersionId FROM App.tbOptions) <> @DraftVersionId
        THROW 51946, 'Publication did not atomically select the successor.', 1;
    IF NOT EXISTS
    (
        SELECT 1 FROM Cash.tbCategoryVersion
        WHERE VersionId = @OriginalVersionId AND VersionStatusCode = 3 AND EffectiveToOn IS NOT NULL
    )
        THROW 51947, 'Publication did not archive the predecessor.', 1;

    SELECT TOP (1) @TaxCode = TaxCode FROM App.tbTaxCode ORDER BY TaxCode;

    EXEC Cash.proc_CodeAdd
        @VersionId = @DraftVersionId,
        @CashCode = N'ZZ-CT-LIFE',
        @CashDescription = N'Category Tree lifecycle fixture',
        @CategoryCode = @CategoryCode,
        @TaxCode = @TaxCode,
        @IsEnabled = 1;

    IF NOT EXISTS
    (
        SELECT 1 FROM Cash.tbCategoryCodeMap
        WHERE VersionId = @DraftVersionId AND CashCode = N'ZZ-CT-LIFE' AND CategoryCode = @CategoryCode
    )
        THROW 51948, 'Atomic Cash Code creation did not create its active mapping.', 1;

    EXEC Cash.proc_CodeDelete
        @CashCode = N'ZZ-CT-LIFE',
        @ChangeNote = N'Lifecycle fixture editable Cash Code deletion.';

    IF EXISTS (SELECT 1 FROM Cash.tbCode WHERE CashCode = N'ZZ-CT-LIFE')
       OR EXISTS (SELECT 1 FROM Cash.tbCategoryCodeMap WHERE CashCode = N'ZZ-CT-LIFE')
        THROW 51949, 'Guarded Cash Code deletion left identity or mapping rows behind.', 1;

    EXEC Cash.proc_CategoryVersionSubmit
        @VersionId = @DraftVersionId,
        @ChangeNote = N'Lifecycle fixture submission transition.';

    /* This authoritative rejection deliberately rolls back the complete fixture. */
    SELECT TOP (1) @ProtectedCashCode = CashCode
    FROM Cash.tbCategoryCodeMap
    WHERE VersionId = @DraftVersionId
    ORDER BY CashCode;

    BEGIN TRY
        EXEC Cash.proc_CodeDelete
            @CashCode = @ProtectedCashCode,
            @ChangeNote = N'Expected protected-history rejection.';
    END TRY
    BEGIN CATCH
        IF ERROR_NUMBER() = 51173 SET @DeleteRejected = 1;
        ELSE THROW;
    END CATCH;

    IF @DeleteRejected = 0
        THROW 51951, 'Cash Code deletion was not blocked by Submitted or Archived mappings.', 1;
    IF XACT_STATE() <> 0
        THROW 51952, 'The expected guarded-delete rejection did not roll back the fixture transaction.', 1;
END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;
    THROW;
END CATCH;

IF (SELECT CategoryVersionId FROM App.tbOptions) <> @OriginalVersionId
    THROW 51953, 'The rollback-only fixture changed the active version.', 1;
IF EXISTS (SELECT 1 FROM Cash.tbCategoryVersion WHERE VersionId = @DraftVersionId)
    THROW 51954, 'The rollback-only fixture retained its Draft.', 1;

/* Direct-DML rejection has its own phase because the legacy audit trigger rolls
   back the enclosing transaction after logging the version-guard error. */
BEGIN TRY
    BEGIN TRANSACTION;

    UPDATE Cash.tbCategoryVersion
    SET VersionStatusCode = 2
    WHERE VersionId = @OriginalVersionId;

    SET XACT_ABORT OFF;
    BEGIN TRY
        UPDATE Cash.tbCategory
        SET Category = Category
        WHERE VersionId = @OriginalVersionId AND CategoryCode = @CategoryCode;
    END TRY
    BEGIN CATCH
        IF ERROR_NUMBER() = 51097
           OR (ERROR_NUMBER() = 50000 AND ERROR_MESSAGE() LIKE N'%51097%')
            SET @DirectDmlRejected = 1;
        ELSE THROW;
    END CATCH;
    SET XACT_ABORT ON;

    IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;

    IF @DirectDmlRejected = 0
        THROW 51950, 'Direct DML changed a Submitted Category Tree version.', 1;
END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;
    THROW;
END CATCH;

IF NOT EXISTS
(
    SELECT 1 FROM Cash.tbCategoryVersion
    WHERE VersionId = @OriginalVersionId AND VersionStatusCode = 1
)
    THROW 51955, 'The direct-DML phase did not restore the Published baseline.', 1;

SELECT N'PASS' AS CategoryTreeLifecycleStatus,
       @OriginalVersionId AS RestoredActiveVersionId,
       @DirectDmlRejected AS SubmittedDirectDmlRejected,
       @DeleteRejected AS ProtectedCashCodeDeleteRejected;
