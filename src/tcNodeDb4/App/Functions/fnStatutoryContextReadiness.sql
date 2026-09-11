CREATE FUNCTION [App].[fnStatutoryContextReadiness]
(
    @SubjectCode NVARCHAR(50),
    @ReportingTypeCode NVARCHAR(20),
    @TaxSourceCode NVARCHAR(20),
    @RegistrationSchemeCode NVARCHAR(20),
    @SettingCode NVARCHAR(30),
    @AsOfDate DATE
)
RETURNS @Findings TABLE
(
    [FindingCode] NVARCHAR(50) NOT NULL,
    [SeverityCode] NVARCHAR(10) NOT NULL,
    [ScopeCode] NVARCHAR(20) NOT NULL,
    [RecordCode] NVARCHAR(100) NULL,
    [FindingMessage] NVARCHAR(255) NOT NULL
)
AS
BEGIN
    DECLARE @ResolvedSubjectCode NVARCHAR(50) = COALESCE
    (
        @SubjectCode,
        (SELECT TOP (1) options.SubjectCode FROM App.tbOptions options ORDER BY options.Identifier)
    );

    IF @ResolvedSubjectCode IS NULL OR NOT EXISTS
       (SELECT 1 FROM Subject.tbSubject subject WHERE subject.SubjectCode = @ResolvedSubjectCode)
        INSERT @Findings VALUES
            (N'HOME-SUBJECT-MISSING', N'ERROR', N'IDENTITY', NULL, N'The reporting subject cannot be resolved.');
    ELSE
    BEGIN
        IF EXISTS
           (SELECT 1 FROM Subject.tbSubject WHERE SubjectCode = @ResolvedSubjectCode AND NULLIF(LTRIM(RTRIM(SubjectName)), N'') IS NULL)
            INSERT @Findings VALUES
                (N'LEGAL-NAME-MISSING', N'ERROR', N'IDENTITY', NULL, N'The reporting subject has no legal name.');

        IF Cash.fnGetBizTaxType() = 4 AND EXISTS
           (SELECT 1 FROM Subject.tbSubject WHERE SubjectCode = @ResolvedSubjectCode AND AddressCode IS NULL)
            INSERT @Findings VALUES
                (N'TRADING-ADDRESS-MISSING', N'ERROR', N'ADDRESS', NULL, N'The reporting sole trader has no selected trading address.');

        IF Cash.fnGetBizTaxType() = 0
           AND @ReportingTypeCode IN (N'COMPANY-TAX', N'STATUTORY-ACCOUNTS')
           AND NOT EXISTS
           (
               SELECT 1
               FROM Subject.tbAddress address
               WHERE address.SubjectCode = @ResolvedSubjectCode
                 AND address.AddressTypeCode = 2
                 AND NULLIF(LTRIM(RTRIM(address.Address)), N'') IS NOT NULL
           )
            INSERT @Findings VALUES
                (N'REGISTERED-ADDRESS-MISSING', N'ERROR', N'ADDRESS', NULL, N'The reporting company has no registered address.');

        IF Cash.fnGetBizTaxType() = 0
           AND @ReportingTypeCode IN (N'COMPANY-TAX', N'STATUTORY-ACCOUNTS')
           AND NOT EXISTS
           (
               SELECT 1
               FROM Subject.tbVirtual virtual
               CROSS JOIN App.tbOptions options
               WHERE virtual.SubjectCode = @ResolvedSubjectCode
                 AND COALESCE(virtual.RegistryJurisdictionCode, options.JurisdictionCode) IS NOT NULL
           )
            INSERT @Findings VALUES
                (N'REGISTRY-JURISDICTION-MISSING', N'ERROR', N'IDENTITY', NULL, N'The reporting company has no effective registry jurisdiction.');

        IF @RegistrationSchemeCode IS NOT NULL
        BEGIN
            IF NOT EXISTS
               (SELECT 1 FROM Subject.fnRegistration(@ResolvedSubjectCode, @RegistrationSchemeCode, @AsOfDate))
                INSERT @Findings
                SELECT
                    CASE WHEN EXISTS
                    (
                        SELECT 1 FROM Subject.tbRegistration registration
                        WHERE registration.SubjectCode = @ResolvedSubjectCode
                          AND registration.RegistrationSchemeCode = @RegistrationSchemeCode
                          AND (registration.ValidTo < @AsOfDate OR registration.StatusCode = 3)
                    ) THEN N'REGISTRATION-EXPIRED' ELSE N'REGISTRATION-MISSING' END,
                    N'ERROR', N'REGISTRATION', NULL,
                    CASE WHEN EXISTS
                    (
                        SELECT 1 FROM Subject.tbRegistration registration
                        WHERE registration.SubjectCode = @ResolvedSubjectCode
                          AND registration.RegistrationSchemeCode = @RegistrationSchemeCode
                          AND (registration.ValidTo < @AsOfDate OR registration.StatusCode = 3)
                    ) THEN N'The required registration has expired.' ELSE N'The required registration is missing.' END;

            INSERT @Findings
            SELECT N'REGISTRATION-UNREVIEWED', N'ERROR', N'REGISTRATION',
                   CONCAT(registration.SubjectCode, N';', registration.RegistrationCode),
                   N'The effective registration has not been reviewed.'
            FROM Subject.fnRegistration(@ResolvedSubjectCode, @RegistrationSchemeCode, @AsOfDate) registration
            WHERE registration.IsReviewed = 0;

            IF (SELECT COUNT(*) FROM Subject.fnRegistration(@ResolvedSubjectCode, @RegistrationSchemeCode, @AsOfDate)) > 1
                INSERT @Findings VALUES
                    (N'REGISTRATION-DUPLICATE', N'ERROR', N'REGISTRATION', NULL, N'More than one effective registration satisfies the requested scheme.');
        END;

        IF @ReportingTypeCode IS NOT NULL
        BEGIN
            IF NOT EXISTS
               (SELECT 1 FROM Cash.fnReportingProfile(@ResolvedSubjectCode, @ReportingTypeCode, @TaxSourceCode, @AsOfDate))
                INSERT @Findings
                SELECT
                    CASE WHEN EXISTS
                    (
                        SELECT 1 FROM Cash.tbReportingProfile profile
                        WHERE profile.SubjectCode = @ResolvedSubjectCode
                          AND profile.ReportingTypeCode = @ReportingTypeCode
                          AND (@TaxSourceCode IS NULL OR profile.TaxSourceCode = @TaxSourceCode)
                          AND (profile.ValidTo < @AsOfDate OR profile.StatusCode = 3)
                    ) THEN N'REPORTING-PROFILE-EXPIRED' ELSE N'REPORTING-PROFILE-MISSING' END,
                    N'ERROR', N'REPORTING-PROFILE', NULL,
                    CASE WHEN EXISTS
                    (
                        SELECT 1 FROM Cash.tbReportingProfile profile
                        WHERE profile.SubjectCode = @ResolvedSubjectCode
                          AND profile.ReportingTypeCode = @ReportingTypeCode
                          AND (@TaxSourceCode IS NULL OR profile.TaxSourceCode = @TaxSourceCode)
                          AND (profile.ValidTo < @AsOfDate OR profile.StatusCode = 3)
                    ) THEN N'The requested reporting profile has expired.' ELSE N'The requested reporting profile is missing.' END;

            INSERT @Findings
            SELECT N'REPORTING-PROFILE-UNREVIEWED', N'ERROR', N'REPORTING-PROFILE',
                   CONCAT(profile.SubjectCode, N';', profile.ReportingProfileCode),
                   N'The effective reporting profile has not been reviewed.'
            FROM Cash.fnReportingProfile(@ResolvedSubjectCode, @ReportingTypeCode, @TaxSourceCode, @AsOfDate) profile
            WHERE profile.IsReviewed = 0;

            IF (SELECT COUNT(*) FROM Cash.fnReportingProfile(@ResolvedSubjectCode, @ReportingTypeCode, @TaxSourceCode, @AsOfDate)) > 1
                INSERT @Findings VALUES
                    (N'REPORTING-PROFILE-DUPLICATE', N'ERROR', N'REPORTING-PROFILE', NULL, N'More than one effective reporting profile satisfies the requested scope.');

            IF @SettingCode IS NOT NULL
            BEGIN
                IF NOT EXISTS
                (
                    SELECT 1
                    FROM Cash.fnReportingProfile(@ResolvedSubjectCode, @ReportingTypeCode, @TaxSourceCode, @AsOfDate) profile
                    CROSS APPLY Cash.fnReportingProfileSetting(profile.SubjectCode, profile.ReportingProfileCode, @SettingCode, @AsOfDate) setting
                )
                    INSERT @Findings VALUES
                        (N'PROFILE-SETTING-MISSING', N'ERROR', N'PROFILE-SETTING', NULL, N'The requested effective profile setting is missing.');

                INSERT @Findings
                SELECT N'PROFILE-SETTING-UNREVIEWED', N'ERROR', N'PROFILE-SETTING',
                       CONCAT(setting.SubjectCode, N';', setting.ReportingProfileCode, N';', setting.SettingCode, N';', CONVERT(nvarchar(10), setting.EffectiveFrom, 23)),
                       N'The effective profile setting has not been reviewed.'
                FROM Cash.fnReportingProfile(@ResolvedSubjectCode, @ReportingTypeCode, @TaxSourceCode, @AsOfDate) profile
                CROSS APPLY Cash.fnReportingProfileSetting(profile.SubjectCode, profile.ReportingProfileCode, @SettingCode, @AsOfDate) setting
                WHERE setting.IsReviewed = 0;
            END;
        END;
    END;

    RETURN;
END;
