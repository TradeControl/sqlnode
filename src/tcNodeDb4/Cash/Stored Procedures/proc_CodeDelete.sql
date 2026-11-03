CREATE PROCEDURE [Cash].[proc_CodeDelete]
(
    @CashCode NVARCHAR(50),
    @ChangeNote NVARCHAR(MAX) = NULL
)
AS
BEGIN
    SET NOCOUNT, XACT_ABORT ON;

    DECLARE @UserId NVARCHAR(10), @UserName NVARCHAR(50);
    DECLARE @AffectedVersions TABLE
    (
        VersionId NVARCHAR(10) NOT NULL PRIMARY KEY,
        VersionStatusCode SMALLINT NOT NULL
    );

    SELECT TOP (1) @UserId = UserId, @UserName = UserName FROM Usr.vwCredentials;
    IF @UserId IS NULL THROW 51171, 'Cash Code deletion requires an enabled application user.', 1;

    BEGIN TRY
        BEGIN TRAN;

        IF NOT EXISTS (SELECT 1 FROM Cash.tbCode WITH (UPDLOCK, HOLDLOCK) WHERE CashCode = @CashCode)
            THROW 51172, 'The Cash Code was not found.', 1;

        IF EXISTS
        (
            SELECT 1
            FROM Cash.tbCategoryCodeMap AS map WITH (UPDLOCK, HOLDLOCK)
            JOIN Cash.tbCategoryVersion AS version
              ON version.VersionId = map.VersionId
            WHERE map.CashCode = @CashCode
              AND version.VersionStatusCode IN (2, 3)
        )
            THROW 51173, 'A Cash Code mapped by a Submitted or Archived version cannot be deleted; disable it instead.', 1;

        INSERT @AffectedVersions (VersionId, VersionStatusCode)
        SELECT map.VersionId, version.VersionStatusCode
        FROM Cash.tbCategoryCodeMap AS map
        JOIN Cash.tbCategoryVersion AS version
          ON version.VersionId = map.VersionId
        WHERE map.CashCode = @CashCode
          AND version.VersionStatusCode IN (0, 1);

        EXEC sys.sp_set_session_context @key = N'CategoryTreeExplicitMapping', @value = 1;

        DELETE map
        FROM Cash.tbCategoryCodeMap AS map
        JOIN @AffectedVersions AS affected
          ON affected.VersionId = map.VersionId
        WHERE map.CashCode = @CashCode;

        DELETE FROM Cash.tbCode WHERE CashCode = @CashCode;

        INSERT Cash.tbCategoryVersionEvent
            (VersionId, EventTypeCode, FromStatusCode, ToStatusCode,
             UserId, UserName, ChangeNote)
        SELECT affected.VersionId, 1, affected.VersionStatusCode, affected.VersionStatusCode,
               @UserId, @UserName,
               COALESCE(NULLIF(LTRIM(RTRIM(@ChangeNote)), N''), N'Cash Code deleted with its editable-version mappings.')
        FROM @AffectedVersions AS affected;

        EXEC sys.sp_set_session_context @key = N'CategoryTreeExplicitMapping', @value = NULL;
        COMMIT TRAN;
    END TRY
    BEGIN CATCH
        EXEC sys.sp_set_session_context @key = N'CategoryTreeExplicitMapping', @value = NULL;
        IF XACT_STATE() <> 0 ROLLBACK TRAN;
        THROW;
    END CATCH;
END;
