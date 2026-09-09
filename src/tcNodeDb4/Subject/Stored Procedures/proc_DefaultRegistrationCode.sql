CREATE PROCEDURE [Subject].[proc_DefaultRegistrationCode]
(
    @SubjectCode NVARCHAR(50),
    @RegistrationSchemeCode NVARCHAR(20),
    @RegistrationCode NVARCHAR(20) OUTPUT
)
AS
    SET NOCOUNT, XACT_ABORT ON;

    BEGIN TRY
        DECLARE @Description NVARCHAR(100) =
        (
            SELECT SchemeName
            FROM App.tbRegistrationScheme
            WHERE RegistrationSchemeCode = @RegistrationSchemeCode
        );

        DECLARE @CheckSql NVARCHAR(MAX) = N'
            SELECT @cnt = COUNT(*)
            FROM Subject.tbRegistration
            WHERE SubjectCode = N''' + REPLACE(@SubjectCode, N'''', N'''''') + N'''
              AND RegistrationCode = @Code';

        DECLARE @GeneratedCode NVARCHAR(50);

        EXEC App.proc_DefaultCodeGenerator
            @Description = @Description,
            @CheckSql = @CheckSql,
            @Code = @GeneratedCode OUTPUT;

        SET @RegistrationCode = CONVERT(NVARCHAR(20), @GeneratedCode);
    END TRY
    BEGIN CATCH
        EXEC App.proc_ErrorLog;
    END CATCH;
GO
