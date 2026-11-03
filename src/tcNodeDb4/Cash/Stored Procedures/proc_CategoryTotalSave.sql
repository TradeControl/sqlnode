CREATE PROCEDURE [Cash].[proc_CategoryTotalSave]
(
    @VersionId NVARCHAR(10),
    @ParentCode NVARCHAR(10),
    @ChildCode NVARCHAR(10),
    @DisplayOrder SMALLINT = 0,
    @IsDelete BIT = 0,
    @ChangeNote NVARCHAR(MAX) = NULL
)
AS
BEGIN
    SET NOCOUNT, XACT_ABORT ON;

    DECLARE @StatusCode SMALLINT, @UserId NVARCHAR(10), @UserName NVARCHAR(50);
    SELECT TOP (1) @UserId = UserId, @UserName = UserName FROM Usr.vwCredentials;
    IF @UserId IS NULL THROW 51151, 'Category edge mutation requires an enabled application user.', 1;

    BEGIN TRY
        BEGIN TRAN;

        SELECT @StatusCode = VersionStatusCode
        FROM Cash.tbCategoryVersion WITH (UPDLOCK, HOLDLOCK)
        WHERE VersionId = @VersionId;

    IF @StatusCode NOT IN (0, 1)
        THROW 51148, 'Category edges can be changed only in Draft or Published versions.', 1;
    IF @StatusCode = 1
       AND NOT EXISTS (SELECT 1 FROM App.tbOptions WHERE CategoryVersionId = @VersionId)
        THROW 51149, 'Only the active Published version can be edited.', 1;

    IF @IsDelete = 1
    BEGIN
        DELETE FROM Cash.tbCategoryTotal
        WHERE VersionId = @VersionId AND ParentCode = @ParentCode AND ChildCode = @ChildCode;
        IF @@ROWCOUNT <> 1 THROW 51150, 'The Category Tree edge was not found.', 1;
    END
    ELSE IF EXISTS
    (
        SELECT 1 FROM Cash.tbCategoryTotal
        WHERE VersionId = @VersionId AND ParentCode = @ParentCode AND ChildCode = @ChildCode
    )
        UPDATE Cash.tbCategoryTotal
        SET DisplayOrder = @DisplayOrder
        WHERE VersionId = @VersionId AND ParentCode = @ParentCode AND ChildCode = @ChildCode;
    ELSE
        INSERT Cash.tbCategoryTotal (VersionId, ParentCode, ChildCode, DisplayOrder)
        VALUES (@VersionId, @ParentCode, @ChildCode, @DisplayOrder);

        INSERT Cash.tbCategoryVersionEvent
            (VersionId, EventTypeCode, FromStatusCode, ToStatusCode, UserId, UserName, ChangeNote)
        VALUES
            (@VersionId, 1, @StatusCode, @StatusCode, @UserId, @UserName,
             COALESCE(NULLIF(LTRIM(RTRIM(@ChangeNote)), N''),
                      CASE WHEN @IsDelete = 1 THEN N'Category edge deleted.' ELSE N'Category edge saved.' END));

        COMMIT TRAN;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0 ROLLBACK TRAN;
        THROW;
    END CATCH;
END;
