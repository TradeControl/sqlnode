/*
    DP4 UK configuration and maintenance fixture.
    Run against a freshly initialized company or sole-trader node.
    All subject/profile mutations roll back.
*/
SET NOCOUNT, XACT_ABORT ON;

IF (SELECT COUNT(*) FROM App.tbSettingDefinition) <> 9
    THROW 51041, 'The initial statutory setting catalogue is incomplete.', 1;

IF EXISTS
(
    SELECT 1
    FROM App.tbSettingDefinition
    WHERE SettingCode IN (N'ACCOUNTING-STANDARD', N'ACCOUNTS-TYPE', N'BALANCE-SHEET-FORMAT')
      AND JurisdictionCode <> N'UK'
)
    THROW 51042, 'A UK company-account setting has an invalid scope.', 1;

BEGIN TRAN PhaseDP4Configuration;
BEGIN TRY
    DECLARE @SubjectCode NVARCHAR(50) =
        (SELECT TOP (1) SubjectCode FROM App.tbOptions ORDER BY Identifier);
    DECLARE @AsOfDate DATE = CONVERT(date, getdate());
    DECLARE @ReportingTypeCode NVARCHAR(20) = CASE
        WHEN EXISTS (SELECT 1 FROM Cash.tbTaxTagSource WHERE TaxSourceCode LIKE N'%ITSA%')
            THEN N'SELF-EMPLOYMENT'
        ELSE N'COMPANY-TAX'
    END;
    DECLARE @TaxSourceCode NVARCHAR(20) = CASE @ReportingTypeCode
        WHEN N'SELF-EMPLOYMENT' THEN
            (SELECT TOP (1) TaxSourceCode FROM Cash.tbTaxTagSource WHERE TaxSourceCode LIKE N'%ITSA%' ORDER BY TaxSourceCode)
        ELSE
            (SELECT TOP (1) TaxSourceCode FROM Cash.tbTaxTagSource WHERE TaxSourceCode LIKE N'%CT%' ORDER BY TaxSourceCode)
    END;
    DECLARE @SettingCode NVARCHAR(30) = CASE @ReportingTypeCode
        WHEN N'SELF-EMPLOYMENT' THEN N'ACCOUNTING-BASIS'
        ELSE N'ACCOUNTING-STANDARD'
    END;
    DECLARE @SettingValue NVARCHAR(30) = CASE @ReportingTypeCode
        WHEN N'SELF-EMPLOYMENT' THEN N'CASH'
        ELSE N'FRS-105'
    END;
    DECLARE @RegistrationCode NVARCHAR(20);
    DECLARE @NinoRegistrationCode NVARCHAR(20);
    DECLARE @ReportingProfileCode NVARCHAR(20);
    DECLARE @AccountsProfileCode NVARCHAR(20);

    IF NOT EXISTS
    (
        SELECT 1
        FROM Subject.fnStatutoryIdentity(@AsOfDate)
        WHERE SubjectCode = @SubjectCode
          AND EffectiveRegistryJurisdictionCode =
              (SELECT TOP (1) JurisdictionCode FROM App.tbOptions ORDER BY Identifier)
    )
        THROW 51040, 'The registry jurisdiction does not fall back to the node jurisdiction.', 1;

    EXEC Subject.proc_RegistrationSave
        @SubjectCode = @SubjectCode,
        @RegistrationSchemeCode = N'GB-UTR',
        @RegistrationValue = N'0000000000',
        @ValidFrom = @AsOfDate,
        @StatusCode = 1,
        @ValueSourceCode = N'SYNTHETIC',
        @IsReviewed = 1,
        @RegistrationCode = @RegistrationCode OUTPUT;

    EXEC Subject.proc_RegistrationSave
        @SubjectCode = @SubjectCode,
        @RegistrationSchemeCode = N'GB-NI',
        @RegistrationValue = N'QQ123456C',
        @ValidFrom = @AsOfDate,
        @StatusCode = 1,
        @ValueSourceCode = N'SYNTHETIC',
        @IsReviewed = 1,
        @RegistrationCode = @NinoRegistrationCode OUTPUT;

    EXEC Cash.proc_ReportingProfileSave
        @SubjectCode = @SubjectCode,
        @ReportingTypeCode = @ReportingTypeCode,
        @TaxSourceCode = @TaxSourceCode,
        @AuthorityReference = N'DP4-ROLLBACK-REFERENCE',
        @ValidFrom = @AsOfDate,
        @StatusCode = 1,
        @ValueSourceCode = N'SYNTHETIC',
        @IsReviewed = 1,
        @ReportingProfileCode = @ReportingProfileCode OUTPUT;

    IF NOT EXISTS
    (
        SELECT 1
        FROM App.fnStatutoryContextReadiness
        (
            @SubjectCode, @ReportingTypeCode, @TaxSourceCode,
            N'GB-UTR', @SettingCode, @AsOfDate
        )
        WHERE FindingCode = N'PROFILE-SETTING-MISSING'
    )
        THROW 51046, 'An incomplete reporting profile was not identified.', 1;

    EXEC Cash.proc_ReportingProfileSettingSave
        @SubjectCode = @SubjectCode,
        @ReportingProfileCode = @ReportingProfileCode,
        @SettingCode = @SettingCode,
        @EffectiveFrom = @AsOfDate,
        @TextValue = @SettingValue,
        @StatusCode = 1,
        @ValueSourceCode = N'SYNTHETIC',
        @IsReviewed = 1;

    IF NOT EXISTS
    (
        SELECT 1
        FROM Subject.fnRegistrationMasked(@SubjectCode, N'GB-UTR', @AsOfDate)
        WHERE RegistrationCode = @RegistrationCode
          AND RegistrationDisplayValue = N'******0000'
    )
        THROW 51043, 'The sensitive registration projection is not masked.', 1;

    IF NOT EXISTS
    (
        SELECT 1
        FROM Subject.fnRegistrationMasked(@SubjectCode, N'GB-NI', @AsOfDate)
        WHERE RegistrationCode = @NinoRegistrationCode
          AND RegistrationDisplayValue = N'*****456C'
    )
        THROW 51047, 'The National Insurance number projection is not masked.', 1;

    IF NOT EXISTS
    (
        SELECT 1
        FROM Cash.fnReportingProfile(@SubjectCode, @ReportingTypeCode, @TaxSourceCode, @AsOfDate)
        WHERE ReportingProfileCode = @ReportingProfileCode
          AND IsReviewed = 1
    )
        THROW 51044, 'The reviewed reporting profile did not resolve.', 1;

    IF NOT EXISTS
    (
        SELECT 1
        FROM Cash.fnReportingProfileSetting(@SubjectCode, @ReportingProfileCode, @SettingCode, @AsOfDate)
        WHERE TextValue = @SettingValue
          AND IsReviewed = 1
    )
        THROW 51045, 'The reviewed profile setting did not resolve.', 1;

    IF EXISTS
    (
        SELECT 1
        FROM App.fnStatutoryContextReadiness
        (
            @SubjectCode, @ReportingTypeCode, @TaxSourceCode,
            N'GB-UTR', @SettingCode, @AsOfDate
        )
        WHERE FindingCode IN
        (
            N'REGISTRATION-MISSING', N'REGISTRATION-EXPIRED',
            N'REGISTRATION-UNREVIEWED', N'REGISTRATION-DUPLICATE',
            N'REPORTING-PROFILE-MISSING', N'REPORTING-PROFILE-EXPIRED',
            N'REPORTING-PROFILE-UNREVIEWED', N'REPORTING-PROFILE-DUPLICATE',
            N'PROFILE-SETTING-MISSING', N'PROFILE-SETTING-UNREVIEWED'
        )
    )
        THROW 51049, 'The completed statutory context still has configuration findings.', 1;

    IF Cash.fnGetBizTaxType() = 0
    BEGIN
        EXEC Cash.proc_ReportingProfileSave
            @SubjectCode = @SubjectCode,
            @ReportingTypeCode = N'STATUTORY-ACCOUNTS',
            @TaxSourceCode = @TaxSourceCode,
            @AuthorityReference = N'DP4-ROLLBACK-ACCOUNTS',
            @ValidFrom = @AsOfDate,
            @StatusCode = 1,
            @ValueSourceCode = N'SYNTHETIC',
            @IsReviewed = 1,
            @ReportingProfileCode = @AccountsProfileCode OUTPUT;

        IF (SELECT COUNT(DISTINCT AuthorityCode)
            FROM Cash.tbReportingProfile
            WHERE SubjectCode = @SubjectCode
              AND ReportingProfileCode IN (@ReportingProfileCode, @AccountsProfileCode)) <> 2
            THROW 51050, 'Multiple authority business profiles were not represented independently.', 1;
    END;

    ROLLBACK TRAN PhaseDP4Configuration;
    PRINT 'DP4 UK configuration and maintenance fixture passed.';
END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0 ROLLBACK TRAN PhaseDP4Configuration;
    THROW;
END CATCH;
