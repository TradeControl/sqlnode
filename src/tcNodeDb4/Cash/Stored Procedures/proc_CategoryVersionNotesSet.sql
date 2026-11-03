CREATE PROCEDURE [Cash].[proc_CategoryVersionNotesSet]
(
    @VersionId NVARCHAR(10),
    @Description NVARCHAR(100),
    @Notes NVARCHAR(MAX) = NULL,
    @ChangeNote NVARCHAR(MAX) = NULL
)
AS
BEGIN
    SET NOCOUNT, XACT_ABORT ON;

    DECLARE @StatusCode SMALLINT, @CanonicalSha256 BINARY(32),
            @UserId NVARCHAR(10), @UserName NVARCHAR(50);

    SELECT TOP (1) @UserId = UserId, @UserName = UserName FROM Usr.vwCredentials;
    IF @UserId IS NULL THROW 51161, 'Category Tree metadata mutation requires an enabled application user.', 1;
    IF LEN(LTRIM(RTRIM(COALESCE(@Description, N'')))) = 0
        THROW 51162, 'A Category Tree version requires a description.', 1;

    BEGIN TRY
        BEGIN TRAN;

        SELECT @StatusCode = VersionStatusCode, @CanonicalSha256 = CanonicalSha256
        FROM Cash.tbCategoryVersion WITH (UPDLOCK, HOLDLOCK)
        WHERE VersionId = @VersionId;

        IF @StatusCode NOT IN (0, 1)
            THROW 51163, 'Only Draft or Published Category Tree metadata can be changed.', 1;
        IF @StatusCode = 1
           AND NOT EXISTS (SELECT 1 FROM App.tbOptions WHERE CategoryVersionId = @VersionId)
            THROW 51164, 'Only the active Published version can be edited.', 1;

        UPDATE Cash.tbCategoryVersion
        SET Description = @Description,
            Notes = @Notes
        WHERE VersionId = @VersionId;

        INSERT Cash.tbCategoryVersionEvent
            (VersionId, EventTypeCode, FromStatusCode, ToStatusCode,
             UserId, UserName, ChangeNote, ContentSha256)
        VALUES
            (@VersionId, 1, @StatusCode, @StatusCode,
             @UserId, @UserName,
             COALESCE(NULLIF(LTRIM(RTRIM(@ChangeNote)), N''), N'Category Tree description or notes changed.'),
             @CanonicalSha256);

        COMMIT TRAN;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0 ROLLBACK TRAN;
        THROW;
    END CATCH;
END;
