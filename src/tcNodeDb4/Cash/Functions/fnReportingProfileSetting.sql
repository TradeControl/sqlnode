CREATE FUNCTION [Cash].[fnReportingProfileSetting]
(
    @SubjectCode NVARCHAR(50),
    @ReportingProfileCode NVARCHAR(20),
    @SettingCode NVARCHAR(30),
    @AsOfDate DATE
)
RETURNS TABLE
AS
RETURN
(
    SELECT
        setting.SubjectCode,
        setting.ReportingProfileCode,
        setting.SettingCode,
        definition.SettingName,
        definition.ValueTypeCode,
        setting.TextValue,
        setting.IntegerValue,
        setting.DecimalValue,
        setting.DateValue,
        setting.BooleanValue,
        setting.EffectiveFrom,
        setting.EffectiveTo,
        setting.StatusCode,
        status.StatusName,
        setting.ValueSourceCode,
        source.ValueSourceName,
        setting.IsReviewed,
        setting.InsertedBy,
        setting.InsertedOn,
        setting.UpdatedBy,
        setting.UpdatedOn,
        CONVERT(binary(8), setting.RowVer) AS RowVer,
        CONVERT(binary(8), definition.RowVer) AS DefinitionRowVer
    FROM Cash.tbReportingProfileSetting setting
    JOIN App.tbSettingDefinition definition ON definition.SettingCode = setting.SettingCode
    JOIN App.tbStatutoryStatus status
      ON status.StatusCode = setting.StatusCode AND status.IsActive = 1
    JOIN App.tbValueSource source ON source.ValueSourceCode = setting.ValueSourceCode
    WHERE setting.SubjectCode = @SubjectCode
      AND setting.ReportingProfileCode = @ReportingProfileCode
      AND (@SettingCode IS NULL OR setting.SettingCode = @SettingCode)
      AND setting.EffectiveFrom <= @AsOfDate
      AND (setting.EffectiveTo IS NULL OR setting.EffectiveTo >= @AsOfDate)
);
