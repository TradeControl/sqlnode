CREATE PROCEDURE [Cash].[proc_CategoryVersionDiscard]
(
    @VersionId NVARCHAR(10)
)
AS
BEGIN
    SET NOCOUNT, XACT_ABORT ON;

    IF EXISTS (SELECT 1 FROM App.tbOptions WHERE CategoryVersionId = @VersionId)
        THROW 51135, 'The active Category Tree version cannot be discarded.', 1;

    IF NOT EXISTS
    (
        SELECT 1
        FROM Cash.tbCategoryVersion
        WHERE VersionId = @VersionId AND VersionStatusCode = 0
    )
        THROW 51136, 'Only an inactive Draft Category Tree version can be discarded.', 1;

    BEGIN TRY
        BEGIN TRAN;

        DELETE FROM Cash.tbCategoryRoot WHERE VersionId = @VersionId;
        DELETE FROM Cash.tbCategoryCodeMap WHERE VersionId = @VersionId;
        DELETE FROM Cash.tbCategoryTotal WHERE VersionId = @VersionId;
        DELETE FROM Cash.tbCategory WHERE VersionId = @VersionId;
        DELETE FROM Cash.tbCategoryVersionEvent WHERE VersionId = @VersionId;
        DELETE FROM Cash.tbCategoryVersion WHERE VersionId = @VersionId;

        COMMIT TRAN;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0 ROLLBACK TRAN;
        THROW;
    END CATCH;
END;
