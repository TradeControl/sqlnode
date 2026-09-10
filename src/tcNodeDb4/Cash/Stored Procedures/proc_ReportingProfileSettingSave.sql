CREATE PROCEDURE [Cash].[proc_ReportingProfileSettingSave]
(
    @SubjectCode NVARCHAR(50),
    @ReportingProfileCode NVARCHAR(20),
    @SettingCode NVARCHAR(30),
    @EffectiveFrom DATE,
    @EffectiveTo DATE = NULL,
    @TextValue NVARCHAR(4000) = NULL,
    @IntegerValue BIGINT = NULL,
    @DecimalValue DECIMAL(28,9) = NULL,
    @DateValue DATE = NULL,
    @BooleanValue BIT = NULL,
    @StatusCode SMALLINT = 0,
    @ValueSourceCode NVARCHAR(10) = N'USER',
    @IsReviewed BIT = 0
)
AS
    SET NOCOUNT, XACT_ABORT ON;

    BEGIN TRY
        IF EXISTS
        (
            SELECT 1
            FROM Cash.tbReportingProfileSetting
            WHERE SubjectCode = @SubjectCode
              AND ReportingProfileCode = @ReportingProfileCode
              AND SettingCode = @SettingCode
              AND EffectiveFrom = @EffectiveFrom
        )
            UPDATE Cash.tbReportingProfileSetting
            SET EffectiveTo = @EffectiveTo,
                TextValue = @TextValue,
                IntegerValue = @IntegerValue,
                DecimalValue = @DecimalValue,
                DateValue = @DateValue,
                BooleanValue = @BooleanValue,
                StatusCode = @StatusCode,
                ValueSourceCode = @ValueSourceCode,
                IsReviewed = @IsReviewed,
                UpdatedBy = suser_sname(),
                UpdatedOn = current_timestamp
            WHERE SubjectCode = @SubjectCode
              AND ReportingProfileCode = @ReportingProfileCode
              AND SettingCode = @SettingCode
              AND EffectiveFrom = @EffectiveFrom;
        ELSE
            INSERT Cash.tbReportingProfileSetting
            (
                SubjectCode, ReportingProfileCode, SettingCode, EffectiveFrom, EffectiveTo,
                TextValue, IntegerValue, DecimalValue, DateValue, BooleanValue,
                StatusCode, ValueSourceCode, IsReviewed
            )
            VALUES
            (
                @SubjectCode, @ReportingProfileCode, @SettingCode, @EffectiveFrom, @EffectiveTo,
                @TextValue, @IntegerValue, @DecimalValue, @DateValue, @BooleanValue,
                @StatusCode, @ValueSourceCode, @IsReviewed
            );
    END TRY
    BEGIN CATCH
        EXEC App.proc_ErrorLog;
    END CATCH;
GO
