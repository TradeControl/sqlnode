/*
    Category Tree version-infrastructure acceptance fixture.
    Run against an initialised node after deploying the current DACPAC.
    All mutations roll back; sequence gaps are expected and identifiers are never reused.
*/
SET NOCOUNT ON;
SET XACT_ABORT OFF;

BEGIN TRAN CategoryTreeVersionFixture;
BEGIN TRY
    IF (SELECT COUNT(*) FROM Cash.tbCategoryVersionStatus) <> 4
        THROW 51061, 'Category Tree version status vocabulary is incomplete.', 1;

    IF EXISTS
    (
        SELECT expected.VersionStatusCode, expected.VersionStatus
        FROM
        (
            VALUES (0, N'Draft'), (1, N'Published'), (2, N'Submitted'), (3, N'Archived')
        ) expected (VersionStatusCode, VersionStatus)
        EXCEPT
        SELECT VersionStatusCode, VersionStatus
        FROM Cash.tbCategoryVersionStatus
    )
        THROW 51062, 'Category Tree version status vocabulary differs from the contract.', 1;

    IF (SELECT COUNT(*) FROM Cash.tbCategoryRootType) <> 2
        THROW 51063, 'Category Tree root-type vocabulary is incomplete.', 1;

    IF EXISTS
    (
        SELECT expected.RootTypeCode, expected.RootType
        FROM (VALUES (0, N'NET_PROFIT'), (1, N'VAT')) expected (RootTypeCode, RootType)
        EXCEPT
        SELECT RootTypeCode, RootType
        FROM Cash.tbCategoryRootType
    )
        THROW 51064, 'Category Tree root-type vocabulary differs from the contract.', 1;

    DECLARE
        @UserId NVARCHAR(10) = (SELECT TOP (1) UserId FROM Usr.vwCredentials),
        @VersionId NVARCHAR(10),
        @NextVersionId NVARCHAR(10);

    IF @UserId IS NULL
        THROW 51065, 'The fixture requires one current application user.', 1;

    EXEC Cash.proc_CategoryVersionIdNext @VersionId = @VersionId OUTPUT;
    EXEC Cash.proc_CategoryVersionIdNext @VersionId = @NextVersionId OUTPUT;

    IF @VersionId NOT LIKE N'CV[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'
        THROW 51066, 'The allocated Category Tree version identifier has the wrong format.', 1;

    IF @VersionId = @NextVersionId
        THROW 51067, 'Category Tree version allocation reused an identifier.', 1;

    INSERT INTO Cash.tbCategoryVersion
    (
        VersionId,
        VersionStatusCode,
        Description,
        CreatedByUserId
    )
    VALUES
    (
        @VersionId,
        0,
        N'Infrastructure fixture Draft',
        @UserId
    );

    IF EXISTS
    (
        SELECT 1
        FROM Cash.tbCategoryVersion
        WHERE VersionId = @VersionId
          AND (EffectiveFromOn IS NOT NULL OR EffectiveToOn IS NOT NULL)
    )
        THROW 51068, 'A Draft acquired an effective interval.', 1;

    BEGIN TRY
        UPDATE Cash.tbCategoryVersion
        SET VersionStatusCode = 1
        WHERE VersionId = @VersionId;

        THROW 51069, 'Published status was accepted without an effective start.', 1;
    END TRY
    BEGIN CATCH
        IF ERROR_NUMBER() = 51069 THROW;
    END CATCH;

    UPDATE Cash.tbCategoryVersion
    SET VersionStatusCode = 1,
        EffectiveFromOn = CONVERT(DATE, SYSUTCDATETIME())
    WHERE VersionId = @VersionId;

    BEGIN TRY
        UPDATE Cash.tbCategoryVersion
        SET VersionStatusCode = 3
        WHERE VersionId = @VersionId;

        THROW 51070, 'Archived status was accepted without an effective end.', 1;
    END TRY
    BEGIN CATCH
        IF ERROR_NUMBER() = 51070 THROW;
    END CATCH;

    ROLLBACK TRAN CategoryTreeVersionFixture;
    PRINT 'Category Tree version infrastructure fixture passed.';
END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0 ROLLBACK TRAN CategoryTreeVersionFixture;
    THROW;
END CATCH;
