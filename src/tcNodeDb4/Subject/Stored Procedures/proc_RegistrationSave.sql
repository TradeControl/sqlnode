CREATE PROCEDURE [Subject].[proc_RegistrationSave]
(
    @SubjectCode NVARCHAR(50),
    @RegistrationSchemeCode NVARCHAR(20),
    @RegistrationValue NVARCHAR(255),
    @ValidFrom DATE,
    @ValidTo DATE = NULL,
    @StatusCode SMALLINT = 0,
    @ValueSourceCode NVARCHAR(10) = N'USER',
    @IsReviewed BIT = 0,
    @RegistrationCode NVARCHAR(20) = NULL OUTPUT
)
AS
    SET NOCOUNT, XACT_ABORT ON;

    BEGIN TRY
        IF NULLIF(LTRIM(RTRIM(@RegistrationValue)), N'') IS NULL
            THROW 51030, 'Registration value is required.', 1;

        IF @RegistrationCode IS NULL
            EXEC Subject.proc_DefaultRegistrationCode
                @SubjectCode = @SubjectCode,
                @RegistrationSchemeCode = @RegistrationSchemeCode,
                @RegistrationCode = @RegistrationCode OUTPUT;

        IF EXISTS
        (
            SELECT 1
            FROM Subject.tbRegistration
            WHERE SubjectCode = @SubjectCode
              AND RegistrationCode = @RegistrationCode
        )
            UPDATE Subject.tbRegistration
            SET RegistrationSchemeCode = @RegistrationSchemeCode,
                RegistrationValue = @RegistrationValue,
                ValidFrom = @ValidFrom,
                ValidTo = @ValidTo,
                StatusCode = @StatusCode,
                ValueSourceCode = @ValueSourceCode,
                IsReviewed = @IsReviewed,
                UpdatedBy = suser_sname(),
                UpdatedOn = current_timestamp
            WHERE SubjectCode = @SubjectCode
              AND RegistrationCode = @RegistrationCode;
        ELSE
            INSERT Subject.tbRegistration
            (
                SubjectCode, RegistrationCode, RegistrationSchemeCode, RegistrationValue,
                ValidFrom, ValidTo, StatusCode, ValueSourceCode, IsReviewed
            )
            VALUES
            (
                @SubjectCode, @RegistrationCode, @RegistrationSchemeCode, @RegistrationValue,
                @ValidFrom, @ValidTo, @StatusCode, @ValueSourceCode, @IsReviewed
            );
    END TRY
    BEGIN CATCH
        EXEC App.proc_ErrorLog;
    END CATCH;
GO
