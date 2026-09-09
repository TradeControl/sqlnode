CREATE PROCEDURE [Cash].[proc_DefaultReportingProfileCode]
(
    @SubjectCode NVARCHAR(50),
    @ReportingTypeCode NVARCHAR(20),
    @ReportingProfileCode NVARCHAR(20) OUTPUT
)
AS
    SET NOCOUNT, XACT_ABORT ON;

    BEGIN TRY
        DECLARE @Description NVARCHAR(100) =
        (
            SELECT ReportingTypeName
            FROM App.tbReportingType
            WHERE ReportingTypeCode = @ReportingTypeCode
        );

        DECLARE @CheckSql NVARCHAR(MAX) = N'
            SELECT @cnt = COUNT(*)
            FROM Cash.tbReportingProfile
            WHERE SubjectCode = N''' + REPLACE(@SubjectCode, N'''', N'''''') + N'''
              AND ReportingProfileCode = @Code';

        DECLARE @GeneratedCode NVARCHAR(50);

        EXEC App.proc_DefaultCodeGenerator
            @Description = @Description,
            @CheckSql = @CheckSql,
            @Code = @GeneratedCode OUTPUT;

        SET @ReportingProfileCode = CONVERT(NVARCHAR(20), @GeneratedCode);
    END TRY
    BEGIN CATCH
        EXEC App.proc_ErrorLog;
    END CATCH;
GO
