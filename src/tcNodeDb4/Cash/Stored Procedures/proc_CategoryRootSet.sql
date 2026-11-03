CREATE PROCEDURE [Cash].[proc_CategoryRootSet]
(
    @VersionId NVARCHAR(10),
    @RootTypeCode SMALLINT,
    @CategoryCode NVARCHAR(10),
    @ChangeNote NVARCHAR(MAX) = NULL
)
AS
BEGIN
    SET NOCOUNT, XACT_ABORT ON;

    DECLARE @StatusCode SMALLINT, @UserId NVARCHAR(10), @UserName NVARCHAR(50);
    SELECT TOP (1) @UserId = UserId, @UserName = UserName FROM Usr.vwCredentials;
    IF @UserId IS NULL THROW 51160, 'Root mutation requires an enabled application user.', 1;

    BEGIN TRY
        BEGIN TRAN;

        SELECT @StatusCode = VersionStatusCode
        FROM Cash.tbCategoryVersion WITH (UPDLOCK, HOLDLOCK)
        WHERE VersionId = @VersionId;

    IF @StatusCode NOT IN (0, 1)
        THROW 51158, 'Roots can be changed only in Draft or Published versions.', 1;
    IF @StatusCode = 1
       AND NOT EXISTS (SELECT 1 FROM App.tbOptions WHERE CategoryVersionId = @VersionId)
        THROW 51159, 'Only the active Published version can be edited.', 1;

    UPDATE Cash.tbCategoryRoot
    SET CategoryCode = @CategoryCode
    WHERE VersionId = @VersionId AND RootTypeCode = @RootTypeCode;

    IF @@ROWCOUNT = 0
        INSERT Cash.tbCategoryRoot (VersionId, RootTypeCode, CategoryCode)
        VALUES (@VersionId, @RootTypeCode, @CategoryCode);

        INSERT Cash.tbCategoryVersionEvent
            (VersionId, EventTypeCode, FromStatusCode, ToStatusCode, UserId, UserName, ChangeNote)
        VALUES
            (@VersionId, 1, @StatusCode, @StatusCode, @UserId, @UserName,
             COALESCE(NULLIF(LTRIM(RTRIM(@ChangeNote)), N''), N'Category Tree root changed.'));

        COMMIT TRAN;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0 ROLLBACK TRAN;
        THROW;
    END CATCH;
END;
