/* Proves jurisdiction portability without retaining test catalogue data. */
SET ANSI_NULLS, ANSI_PADDING, ANSI_WARNINGS, ARITHABORT,
    CONCAT_NULL_YIELDS_NULL, QUOTED_IDENTIFIER, NOCOUNT, XACT_ABORT ON;
SET NUMERIC_ROUNDABORT OFF;

BEGIN TRAN PhaseDP5Portability;
BEGIN TRY
    DECLARE @SubjectCode NVARCHAR(50) =
        (SELECT TOP (1) SubjectCode FROM App.tbOptions ORDER BY Identifier);
    DECLARE @AsOfDate DATE = CONVERT(date, getdate());

    INSERT App.tbJurisdiction (JurisdictionCode, JurisdictionName, UocCode)
    VALUES (N'ZZ-TEST', N'Synthetic second jurisdiction', N'GBP');

    INSERT App.tbAuthority (AuthorityCode, JurisdictionCode, AuthorityName)
    VALUES (N'ZZ-AUTHORITY', N'ZZ-TEST', N'Synthetic revenue authority');

    INSERT App.tbRegistrationScheme
        (RegistrationSchemeCode, AuthorityCode, SchemeName, ValueTypeCode, IsSensitive, IsSingleValue)
    VALUES (N'ZZ-TAX-ID', N'ZZ-AUTHORITY', N'Synthetic taxpayer reference', N'TEXT', 1, 1);

    INSERT App.tbReportingType
        (ReportingTypeCode, AuthorityCode, ReportingTypeName, RequiresTaxSource)
    VALUES (N'ZZ-REPORT', N'ZZ-AUTHORITY', N'Synthetic statutory report', 0);

    INSERT App.tbSettingDefinition
        (SettingCode, SettingName, JurisdictionCode, AuthorityCode, ReportingTypeCode, ValueTypeCode)
    VALUES
        (N'ZZ-POLICY', N'Synthetic reporting policy', N'ZZ-TEST', N'ZZ-AUTHORITY', N'ZZ-REPORT', N'TEXT');

    INSERT Subject.tbRegistration
        (SubjectCode, RegistrationCode, RegistrationSchemeCode, RegistrationValue,
         ValidFrom, StatusCode, ValueSourceCode, IsReviewed)
    VALUES
        (@SubjectCode, N'ZZTAX', N'ZZ-TAX-ID', N'ZZ-SYNTHETIC-0001',
         @AsOfDate, 1, N'SYNTHETIC', 1);

    INSERT Cash.tbReportingProfile
        (SubjectCode, ReportingProfileCode, AuthorityCode, ReportingTypeCode,
         ValidFrom, StatusCode, ValueSourceCode, IsReviewed)
    VALUES
        (@SubjectCode, N'ZZREPORT', N'ZZ-AUTHORITY', N'ZZ-REPORT',
         @AsOfDate, 1, N'SYNTHETIC', 1);

    INSERT Cash.tbReportingProfileSetting
        (SubjectCode, ReportingProfileCode, SettingCode, EffectiveFrom, TextValue,
         StatusCode, ValueSourceCode, IsReviewed)
    VALUES
        (@SubjectCode, N'ZZREPORT', N'ZZ-POLICY', @AsOfDate, N'ZZ-SYNTHETIC-POLICY',
         1, N'SYNTHETIC', 1);

    UPDATE Subject.tbVirtual
    SET RegistryJurisdictionCode = N'ZZ-TEST'
    WHERE SubjectCode = @SubjectCode;

    IF NOT EXISTS
       (SELECT 1 FROM Subject.fnRegistrationMasked(@SubjectCode, N'ZZ-TAX-ID', @AsOfDate)
        WHERE JurisdictionCode = N'ZZ-TEST' AND RegistrationDisplayValue LIKE N'%*%')
        THROW 51092, 'The second-jurisdiction registration did not resolve safely.', 1;

    IF NOT EXISTS
       (SELECT 1 FROM Cash.fnReportingProfileSetting(@SubjectCode, N'ZZREPORT', N'ZZ-POLICY', @AsOfDate)
        WHERE TextValue = N'ZZ-SYNTHETIC-POLICY')
        THROW 51093, 'The second-jurisdiction reporting setting did not resolve.', 1;

    IF NOT EXISTS
       (SELECT 1 FROM Subject.fnStatutoryIdentity(@AsOfDate)
        WHERE SubjectCode = @SubjectCode AND EffectiveRegistryJurisdictionCode = N'ZZ-TEST')
        THROW 51094, 'The second registry jurisdiction did not project.', 1;

    ROLLBACK TRAN PhaseDP5Portability;
    PRINT 'DP5 second-jurisdiction portability verification passed.';
END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0 ROLLBACK TRAN PhaseDP5Portability;
    THROW;
END CATCH;
