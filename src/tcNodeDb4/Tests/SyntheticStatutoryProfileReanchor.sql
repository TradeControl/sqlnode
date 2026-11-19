/*
    Synthetic statutory-profile temporal re-anchoring regression.

    Proves that a regenerated synthetic company can move its single generated
    CT and Companies House setting rows back to the complete accounting-history
    boundary without creating overlaps or duplicate history. All changes roll
    back.
*/
SET NOCOUNT, XACT_ABORT ON;

IF Cash.fnGetBizTaxType() <> 0
    THROW 51523, 'The statutory-profile re-anchor fixture requires a company node.', 1;

DECLARE
    @SubjectCode nvarchar(50) = (SELECT SubjectCode FROM App.tbOptions),
    @EarliestPeriod date = (SELECT MIN(CONVERT(date, StartOn)) FROM App.tbYearPeriod),
    @LaterDate date;

SELECT @LaterDate = DATEADD(day, 1, MAX(CONVERT(date, StartOn)))
FROM App.tbYearPeriod;

BEGIN TRAN SyntheticProfileReanchor;
BEGIN TRY
    UPDATE profile
    SET ValidFrom = @LaterDate
    FROM Cash.tbReportingProfile profile
    WHERE profile.SubjectCode = @SubjectCode
      AND profile.ReportingTypeCode IN (2, 3)
      AND profile.ValueSourceCode IN (N'IMPORTED', N'SYNTHETIC');

    UPDATE setting
    SET EffectiveFrom = @LaterDate
    FROM Cash.tbReportingProfileSetting setting
    JOIN Cash.tbReportingProfile profile
      ON profile.SubjectCode = setting.SubjectCode
     AND profile.ReportingProfileCode = setting.ReportingProfileCode
    WHERE profile.SubjectCode = @SubjectCode
      AND profile.ReportingTypeCode IN (2, 3)
      AND setting.ValueSourceCode IN (N'IMPORTED', N'SYNTHETIC');

    EXEC App.proc_DatasetSyntheticMIS_StatutoryProfile @AsOfDate = @LaterDate;
    EXEC App.proc_DatasetSyntheticMIS_StatutoryProfile @AsOfDate = @LaterDate;

    IF EXISTS
    (
        SELECT 1
        FROM Cash.tbReportingProfile profile
        WHERE profile.SubjectCode = @SubjectCode
          AND profile.ReportingTypeCode IN (2, 3)
          AND
          (
              profile.ValidFrom <> @EarliestPeriod
              OR profile.StatusCode <> 1
              OR profile.IsReviewed = 0
          )
    )
        THROW 51524, 'A generated statutory profile was not re-anchored to the accounting history.', 1;

    IF EXISTS
    (
        SELECT setting.ReportingProfileCode, setting.SettingCode
        FROM Cash.tbReportingProfileSetting setting
        JOIN Cash.tbReportingProfile profile
          ON profile.SubjectCode = setting.SubjectCode
         AND profile.ReportingProfileCode = setting.ReportingProfileCode
        WHERE profile.SubjectCode = @SubjectCode
          AND profile.ReportingTypeCode IN (2, 3)
          AND setting.SettingCode IN
          (
              N'CT-ASSOCIATED-COMPANIES', N'CT-UK-RESIDENT',
              N'CT-CLOSE-INVESTMENT-HOLDING', N'CT-RING-FENCE-PROFITS',
              N'ACCOUNTING-STANDARD', N'ACCOUNTS-TYPE',
              N'BALANCE-SHEET-FORMAT', N'ACCOUNTING-POLICIES'
          )
        GROUP BY setting.ReportingProfileCode, setting.SettingCode
        HAVING COUNT(*) <> 1 OR MIN(setting.EffectiveFrom) <> @EarliestPeriod
    )
        THROW 51525, 'Generated statutory setting history is duplicated or has the wrong temporal anchor.', 1;

    IF EXISTS
    (
        SELECT 1
        FROM App.fnStatutoryContextReadiness(
            @SubjectCode, 2, N'UK-CO-CT-2026', N'GB-UTR', NULL, @EarliestPeriod)
    )
        THROW 51526, 'The re-anchored Corporation Tax context is not ready.', 1;

    IF EXISTS
    (
        SELECT 1
        FROM App.fnStatutoryContextReadiness(
            @SubjectCode, 3, N'UK-CO-ACCTS-2026', NULL,
            N'ACCOUNTING-STANDARD', @EarliestPeriod)
    )
        THROW 51527, 'The re-anchored Companies House context is not ready.', 1;

    SELECT EarliestPeriod = @EarliestPeriod,
           ProfilesChecked = COUNT(DISTINCT profile.ReportingProfileCode),
           SettingsChecked = COUNT(*)
    FROM Cash.tbReportingProfile profile
    JOIN Cash.tbReportingProfileSetting setting
      ON setting.SubjectCode = profile.SubjectCode
     AND setting.ReportingProfileCode = profile.ReportingProfileCode
    WHERE profile.SubjectCode = @SubjectCode
      AND profile.ReportingTypeCode IN (2, 3)
      AND setting.EffectiveFrom = @EarliestPeriod;

    ROLLBACK TRAN SyntheticProfileReanchor;
END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0 ROLLBACK TRAN SyntheticProfileReanchor;
    THROW;
END CATCH;
