CREATE PROCEDURE [Cash].[proc_CategoryCodeMapMove]
(
    @VersionId NVARCHAR(10),
    @CashCode NVARCHAR(50),
    @CategoryCode NVARCHAR(10),
    @ChangeNote NVARCHAR(MAX) = NULL
)
AS
BEGIN
    SET NOCOUNT, XACT_ABORT ON;

    DECLARE @StatusCode SMALLINT, @UserId NVARCHAR(10), @UserName NVARCHAR(50);
    SELECT TOP (1) @UserId = UserId, @UserName = UserName FROM Usr.vwCredentials;
    IF @UserId IS NULL THROW 51157, 'Cash Code mapping mutation requires an enabled application user.', 1;

    BEGIN TRY
        BEGIN TRAN;

        SELECT @StatusCode = VersionStatusCode
        FROM Cash.tbCategoryVersion WITH (UPDLOCK, HOLDLOCK)
        WHERE VersionId = @VersionId;

    IF @StatusCode NOT IN (0, 1)
        THROW 51152, 'Cash Code mappings can be changed only in Draft or Published versions.', 1;
    IF @StatusCode = 1
       AND NOT EXISTS (SELECT 1 FROM App.tbOptions WHERE CategoryVersionId = @VersionId)
        THROW 51153, 'Only the active Published version can be edited.', 1;
    IF NOT EXISTS (SELECT 1 FROM Cash.tbCode WHERE CashCode = @CashCode)
        THROW 51154, 'The persistent Cash Code was not found.', 1;
    IF NOT EXISTS
    (
        SELECT 1 FROM Cash.tbCategory
        WHERE VersionId = @VersionId AND CategoryCode = @CategoryCode AND CategoryTypeCode = 0
    )
        THROW 51155, 'A Cash Code mapping must target a Nominal category in the same version.', 1;

    UPDATE Cash.tbCategoryCodeMap
    SET CategoryCode = @CategoryCode
    WHERE VersionId = @VersionId AND CashCode = @CashCode;

    IF @@ROWCOUNT <> 1
        THROW 51156, 'The version does not contain the Cash Code mapping.', 1;

        INSERT Cash.tbCategoryVersionEvent
            (VersionId, EventTypeCode, FromStatusCode, ToStatusCode, UserId, UserName, ChangeNote)
        VALUES
            (@VersionId, 1, @StatusCode, @StatusCode, @UserId, @UserName,
             COALESCE(NULLIF(LTRIM(RTRIM(@ChangeNote)), N''), N'Cash Code mapping moved.'));

        COMMIT TRAN;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0 ROLLBACK TRAN;
        THROW;
    END CATCH;
END;
