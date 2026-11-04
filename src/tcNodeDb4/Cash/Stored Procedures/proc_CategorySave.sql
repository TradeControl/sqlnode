CREATE PROCEDURE [Cash].[proc_CategorySave]
(
    @VersionId NVARCHAR(10),
    @CategoryCode NVARCHAR(10),
    @Category NVARCHAR(50),
    @CategoryTypeCode SMALLINT,
    @CashPolarityCode SMALLINT,
    @CashTypeCode SMALLINT,
    @DisplayOrder SMALLINT = 0,
    @IsEnabled SMALLINT = 1,
    @ChangeNote NVARCHAR(MAX) = NULL
)
AS
BEGIN
    SET NOCOUNT, XACT_ABORT ON;

    DECLARE @StatusCode SMALLINT, @UserId NVARCHAR(10), @UserName NVARCHAR(50);
    SELECT TOP (1) @UserId = UserId, @UserName = UserName FROM Usr.vwCredentials;
    IF @UserId IS NULL THROW 51140, 'Category mutation requires an enabled application user.', 1;

    BEGIN TRY
        BEGIN TRAN;

        SELECT @StatusCode = VersionStatusCode
        FROM Cash.tbCategoryVersion WITH (UPDLOCK, HOLDLOCK)
        WHERE VersionId = @VersionId;

    IF @StatusCode NOT IN (0, 1)
        THROW 51137, 'Categories can be changed only in Draft or Published versions.', 1;

    IF @StatusCode = 1
       AND NOT EXISTS (SELECT 1 FROM App.tbOptions WHERE CategoryVersionId = @VersionId)
        THROW 51138, 'Only the active Published version can be edited.', 1;

    IF EXISTS
    (
        SELECT 1
        FROM Cash.tbCategoryCodeMap
        WHERE VersionId = @VersionId AND CategoryCode = @CategoryCode
    ) AND @CategoryTypeCode <> 0
        THROW 51139, 'A mapped Nominal category cannot change type.', 1;

    IF EXISTS
    (
        SELECT 1
        FROM Cash.tbCategory
        WHERE VersionId = @VersionId AND CategoryCode = @CategoryCode
    )
        UPDATE Cash.tbCategory
        SET Category = @Category,
            CategoryTypeCode = @CategoryTypeCode,
            CashPolarityCode = @CashPolarityCode,
            CashTypeCode = @CashTypeCode,
            DisplayOrder = @DisplayOrder,
            IsEnabled = @IsEnabled
        WHERE VersionId = @VersionId AND CategoryCode = @CategoryCode;
    ELSE
        INSERT INTO Cash.tbCategory
        (
            VersionId, CategoryCode, Category, CategoryTypeCode,
            CashPolarityCode, CashTypeCode, DisplayOrder, IsEnabled
        )
        VALUES
        (
            @VersionId, @CategoryCode, @Category, @CategoryTypeCode,
            @CashPolarityCode, @CashTypeCode, @DisplayOrder, @IsEnabled
        );

        INSERT Cash.tbCategoryVersionEvent
            (VersionId, EventTypeCode, FromStatusCode, ToStatusCode, UserId, UserName, ChangeNote)
        VALUES
            (@VersionId, 1, @StatusCode, @StatusCode, @UserId, @UserName,
             COALESCE(NULLIF(LTRIM(RTRIM(@ChangeNote)), N''), N'Category saved.'));

        COMMIT TRAN;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0 ROLLBACK TRAN;
        THROW;
    END CATCH;
END;
