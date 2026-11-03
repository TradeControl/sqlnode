CREATE PROCEDURE [Cash].[proc_CategoryDelete]
(
    @VersionId NVARCHAR(10),
    @CategoryCode NVARCHAR(10),
    @ChangeNote NVARCHAR(MAX) = NULL
)
AS
BEGIN
    SET NOCOUNT, XACT_ABORT ON;

    DECLARE @StatusCode SMALLINT, @UserId NVARCHAR(10), @UserName NVARCHAR(50);
    SELECT TOP (1) @UserId = UserId, @UserName = UserName FROM Usr.vwCredentials;
    IF @UserId IS NULL THROW 51147, 'Category mutation requires an enabled application user.', 1;

    BEGIN TRY
        BEGIN TRAN;

        SELECT @StatusCode = VersionStatusCode
        FROM Cash.tbCategoryVersion WITH (UPDLOCK, HOLDLOCK)
        WHERE VersionId = @VersionId;

    IF @StatusCode NOT IN (0, 1)
        THROW 51141, 'Categories can be deleted only from Draft or Published versions.', 1;

    IF @StatusCode = 1
       AND NOT EXISTS (SELECT 1 FROM App.tbOptions WHERE CategoryVersionId = @VersionId)
        THROW 51142, 'Only the active Published version can be edited.', 1;

    IF EXISTS (SELECT 1 FROM Cash.tbCategoryCodeMap WHERE VersionId = @VersionId AND CategoryCode = @CategoryCode)
        THROW 51143, 'Move the blocking Cash Codes before deleting this category.', 1;
    IF EXISTS (SELECT 1 FROM Cash.tbCategoryRoot WHERE VersionId = @VersionId AND CategoryCode = @CategoryCode)
        THROW 51144, 'Change the configured root before deleting this category.', 1;
    IF EXISTS
    (
        SELECT 1 FROM Cash.tbCategoryTotal
        WHERE VersionId = @VersionId AND (ParentCode = @CategoryCode OR ChildCode = @CategoryCode)
    )
        THROW 51145, 'Remove the category edges before deleting this category.', 1;

    DELETE FROM Cash.tbCategory
    WHERE VersionId = @VersionId AND CategoryCode = @CategoryCode;

    IF @@ROWCOUNT <> 1
        THROW 51146, 'The Category Tree category was not found.', 1;

        INSERT Cash.tbCategoryVersionEvent
            (VersionId, EventTypeCode, FromStatusCode, ToStatusCode, UserId, UserName, ChangeNote)
        VALUES
            (@VersionId, 1, @StatusCode, @StatusCode, @UserId, @UserName,
             COALESCE(NULLIF(LTRIM(RTRIM(@ChangeNote)), N''), N'Category deleted.'));

        COMMIT TRAN;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0 ROLLBACK TRAN;
        THROW;
    END CATCH;
END;
