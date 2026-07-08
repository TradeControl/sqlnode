CREATE PROCEDURE Invoice.proc_DefaultEntryCode
(
    @UserId nvarchar(10),
    @EntryId nvarchar(50) OUTPUT
)
AS
    SET NOCOUNT, XACT_ABORT ON;

    BEGIN TRY
        DECLARE @CheckSql nvarchar(max) =
            N'SELECT @cnt = COUNT(*) FROM Invoice.tbEntry WHERE EntryId = @Code';

        EXEC App.proc_DefaultCodeGenerator
            @Description = @UserId,
            @CheckSql = @CheckSql,
            @UseWholeWords = 1,
            @Code = @EntryId OUTPUT;
    END TRY
    BEGIN CATCH
        EXEC App.proc_ErrorLog;
    END CATCH
GO
