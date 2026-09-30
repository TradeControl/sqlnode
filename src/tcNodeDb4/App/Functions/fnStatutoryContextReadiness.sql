CREATE FUNCTION [App].[fnStatutoryContextReadiness]
(
    @SubjectCode NVARCHAR(50),
    @ReportingTypeCode SMALLINT,
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

        IF NOT EXISTS
           (
               SELECT 1
               FROM Subject.tbSubject subject
               LEFT JOIN Subject.tbAddress registeredAddress
                   ON registeredAddress.SubjectCode = subject.SubjectCode
                   AND registeredAddress.AddressTypeCode = 2
               LEFT JOIN Subject.tbAddress defaultAddress
                   ON defaultAddress.AddressCode = subject.AddressCode
               WHERE subject.SubjectCode = @ResolvedSubjectCode
                 AND NULLIF(LTRIM(RTRIM(COALESCE(registeredAddress.Address, defaultAddress.Address))), N'') IS NOT NULL
            )
            INSERT @Findings VALUES
                (N'STATUTORY-ADDRESS-MISSING', N'ERROR', N'ADDRESS', NULL, N'The reporting subject has neither a registered address nor a selected default address.');

        IF Cash.fnGetBizTaxType() = 0
           AND @ReportingTypeCode IN (2, 3)
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

        DECLARE @RequiredRegistrationScheme TABLE
        (
            RegistrationSchemeCode NVARCHAR(20) NOT NULL PRIMARY KEY
        );

        IF @RegistrationSchemeCode IS NOT NULL
            INSERT @RequiredRegistrationScheme (RegistrationSchemeCode)
            VALUES (@RegistrationSchemeCode);
        ELSE IF @ReportingTypeCode IS NOT NULL
            INSERT @RequiredRegistrationScheme (RegistrationSchemeCode)
            SELECT RegistrationSchemeCode
            FROM App.tbReportingTypeRegistrationScheme
            WHERE ReportingTypeCode = @ReportingTypeCode;

        IF EXISTS (SELECT 1 FROM @RequiredRegistrationScheme)
        BEGIN
            INSERT @Findings
            SELECT
                CASE WHEN EXISTS
                (
                    SELECT 1
                    FROM Subject.tbRegistration registration
                    WHERE registration.SubjectCode = @ResolvedSubjectCode
                      AND registration.RegistrationSchemeCode = required.RegistrationSchemeCode
                      AND (registration.ValidTo < @AsOfDate OR registration.StatusCode = 3)
                ) THEN N'REGISTRATION-EXPIRED' ELSE N'REGISTRATION-MISSING' END,
                N'ERROR', N'REGISTRATION', required.RegistrationSchemeCode,
                CASE WHEN EXISTS
                (
                    SELECT 1
                    FROM Subject.tbRegistration registration
                    WHERE registration.SubjectCode = @ResolvedSubjectCode
                      AND registration.RegistrationSchemeCode = required.RegistrationSchemeCode
                      AND (registration.ValidTo < @AsOfDate OR registration.StatusCode = 3)
                ) THEN CONCAT(N'The required ', scheme.SchemeName, N' has expired.')
                  ELSE CONCAT(N'The required ', scheme.SchemeName, N' is missing.') END
            FROM @RequiredRegistrationScheme required
            JOIN App.tbRegistrationScheme scheme
              ON scheme.RegistrationSchemeCode = required.RegistrationSchemeCode
            WHERE NOT EXISTS
            (
                SELECT 1
                FROM Subject.fnRegistration(@ResolvedSubjectCode, required.RegistrationSchemeCode, @AsOfDate)
            );

            INSERT @Findings
            SELECT N'REGISTRATION-UNREVIEWED', N'ERROR', N'REGISTRATION',
                   CONCAT(registration.SubjectCode, N';', registration.RegistrationCode),
                   CONCAT(N'The effective ', scheme.SchemeName, N' has not been reviewed.')
            FROM @RequiredRegistrationScheme required
            JOIN App.tbRegistrationScheme scheme
              ON scheme.RegistrationSchemeCode = required.RegistrationSchemeCode
            CROSS APPLY Subject.fnRegistration(@ResolvedSubjectCode, required.RegistrationSchemeCode, @AsOfDate) registration
            WHERE registration.IsReviewed = 0;

            INSERT @Findings
            SELECT N'REGISTRATION-DUPLICATE', N'ERROR', N'REGISTRATION',
                   required.RegistrationSchemeCode,
                   CONCAT(N'More than one effective ', scheme.SchemeName, N' satisfies the reporting requirement.')
            FROM @RequiredRegistrationScheme required
            JOIN App.tbRegistrationScheme scheme
              ON scheme.RegistrationSchemeCode = required.RegistrationSchemeCode
            CROSS APPLY
            (
                SELECT COUNT(*) RegistrationCount
                FROM Subject.fnRegistration(@ResolvedSubjectCode, required.RegistrationSchemeCode, @AsOfDate)
            ) registrations
            WHERE registrations.RegistrationCount > 1;
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

            IF @ReportingTypeCode = 0
               AND EXISTS
               (
                   SELECT 1
                   FROM Cash.vwTaxVatIdentity vatIdentity
                   WHERE vatIdentity.SubjectCode = @ResolvedSubjectCode
                     AND vatIdentity.ValidFrom <= @AsOfDate
                     AND (vatIdentity.ValidTo IS NULL OR vatIdentity.ValidTo >= @AsOfDate)
                     AND vatIdentity.IsConsistent = 0
               )
                INSERT @Findings VALUES
                    (N'VAT-IDENTITY-MISMATCH', N'ERROR', N'REPORTING-PROFILE', NULL,
                     N'The active indirect-tax profile does not match the reporting subject VAT registration number.');

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
