CREATE PROCEDURE App.proc_DatasetSyntheticMIS_StatutoryProfile
(
    @AsOfDate DATE = NULL
)
AS
SET NOCOUNT, XACT_ABORT ON;

DECLARE
    @SubjectCode NVARCHAR(50) = (SELECT TOP (1) SubjectCode FROM App.tbOptions ORDER BY Identifier),
    @JurisdictionCode NVARCHAR(10) = (SELECT TOP (1) JurisdictionCode FROM App.tbOptions ORDER BY Identifier),
    @BusinessTaxType SMALLINT = Cash.fnGetBizTaxType(),
    @StatusCode SMALLINT = (SELECT TOP (1) StatusCode FROM App.tbStatutoryStatus WHERE IsActive = 1 ORDER BY StatusCode),
    @SyntheticUtr NVARCHAR(10),
    @RegistrationCode NVARCHAR(20),
    @ProfileCode NVARCHAR(20);

IF @SubjectCode IS NULL
    THROW 51071, 'Synthetic statutory profile: the home subject is required.', 1;

IF @JurisdictionCode <> N'UK'
    RETURN;

IF @StatusCode IS NULL
    THROW 51072, 'Synthetic statutory profile: an active statutory status is required.', 1;

-- A synthetic profile must cover the complete generated accounting history.
-- The dataset temporal anchor can be later than its completed years, so it is
-- only a fallback when no generated financial period is available.
SET @AsOfDate = COALESCE
(
    (SELECT MIN(CONVERT(DATE, StartOn)) FROM App.tbYearPeriod),
    @AsOfDate,
    CONVERT(DATE, CURRENT_TIMESTAMP)
);

SET @SyntheticUtr = CASE @BusinessTaxType WHEN 0 THEN N'1000000001' ELSE N'2000000001' END;

IF @BusinessTaxType = 0
BEGIN
    DECLARE @RegisteredAddressCode NVARCHAR(15) =
    (
        SELECT TOP (1) AddressCode
        FROM Subject.tbAddress
        WHERE SubjectCode = @SubjectCode AND AddressTypeCode = 2
        ORDER BY AddressCode
    );

    IF @RegisteredAddressCode IS NULL
    BEGIN
        EXEC Subject.proc_NextAddressCode
            @SubjectCode = @SubjectCode,
            @AddressCode = @RegisteredAddressCode OUTPUT;

        INSERT INTO Subject.tbAddress (AddressCode, SubjectCode, AddressTypeCode, Address)
        VALUES
        (
            @RegisteredAddressCode, @SubjectCode, 2,
            N'1 Synthetic Registered Office Way' + CHAR(13) + CHAR(10)
                + N'Testborough' + CHAR(13) + CHAR(10) + N'TE1 1ST'
        );
    END
    ELSE
        UPDATE Subject.tbAddress
        SET Address = N'1 Synthetic Registered Office Way' + CHAR(13) + CHAR(10)
            + N'Testborough' + CHAR(13) + CHAR(10) + N'TE1 1ST'
        WHERE SubjectCode = @SubjectCode AND AddressCode = @RegisteredAddressCode;
END;

UPDATE Subject.tbVirtual
SET VatNumber = CASE
        WHEN EXISTS (SELECT 1 FROM Cash.tbTaxType WHERE TaxTypeCode = 1 AND IsEnabled = 1)
            THEN CASE
                WHEN LEN(LTRIM(RTRIM(VatNumber))) = 9
                    AND LTRIM(RTRIM(VatNumber)) NOT LIKE N'%[^0-9]%'
                    THEN LTRIM(RTRIM(VatNumber))
                ELSE N'999000001'
            END
        ELSE VatNumber
    END,
    BusinessDescription = COALESCE(NULLIF(LTRIM(RTRIM(BusinessDescription)), N''), N'Synthetic test business')
WHERE SubjectCode = @SubjectCode;

SELECT @RegistrationCode = RegistrationCode
FROM Subject.tbRegistration
WHERE SubjectCode = @SubjectCode AND RegistrationSchemeCode = N'GB-UTR';

EXEC Subject.proc_RegistrationSave
    @SubjectCode = @SubjectCode,
    @RegistrationSchemeCode = N'GB-UTR',
    @RegistrationValue = @SyntheticUtr,
    @ValidFrom = @AsOfDate,
    @StatusCode = @StatusCode,
    @ValueSourceCode = N'SYNTHETIC',
    @IsReviewed = 1,
    @RegistrationCode = @RegistrationCode OUTPUT;

IF @BusinessTaxType = 4
BEGIN
    SET @RegistrationCode = NULL;
    SELECT @RegistrationCode = RegistrationCode
    FROM Subject.tbRegistration
    WHERE SubjectCode = @SubjectCode AND RegistrationSchemeCode = N'GB-NI';

    EXEC Subject.proc_RegistrationSave
        @SubjectCode = @SubjectCode,
        @RegistrationSchemeCode = N'GB-NI',
        @RegistrationValue = N'QQ123456C',
        @ValidFrom = @AsOfDate,
        @StatusCode = @StatusCode,
        @ValueSourceCode = N'SYNTHETIC',
        @IsReviewed = 1,
        @RegistrationCode = @RegistrationCode OUTPUT;

    SELECT @ProfileCode = ReportingProfileCode
    FROM Cash.tbReportingProfile
    WHERE SubjectCode = @SubjectCode AND ReportingTypeCode = 1;

    EXEC Cash.proc_ReportingProfileSave
        @SubjectCode = @SubjectCode,
        @ReportingTypeCode = 1,
        @TaxSourceCode = N'UK-ITSA-SE-CUM',
        @AuthorityReference = N'XQIS00000000001',
        @ValidFrom = @AsOfDate,
        @StatusCode = @StatusCode,
        @ValueSourceCode = N'SYNTHETIC',
        @IsReviewed = 1,
        @ReportingProfileCode = @ProfileCode OUTPUT;

    IF EXISTS
    (
        SELECT setting.SettingCode
        FROM Cash.tbReportingProfileSetting setting
        WHERE setting.SubjectCode = @SubjectCode
          AND setting.ReportingProfileCode = @ProfileCode
          AND setting.SettingCode IN (N'ACCOUNTING-BASIS', N'QUARTERLY-PERIOD-TYPE')
        GROUP BY setting.SettingCode
        HAVING COUNT(*) <> 1
            OR MAX(CASE WHEN setting.ValueSourceCode IN (N'IMPORTED', N'SYNTHETIC')
                        THEN 0 ELSE 1 END) = 1
    )
        THROW 51520, 'Synthetic statutory profile: existing income-tax setting history cannot be re-anchored safely.', 1;

    UPDATE setting
    SET EffectiveFrom = @AsOfDate
    FROM Cash.tbReportingProfileSetting setting
    WHERE setting.SubjectCode = @SubjectCode
      AND setting.ReportingProfileCode = @ProfileCode
      AND setting.SettingCode IN (N'ACCOUNTING-BASIS', N'QUARTERLY-PERIOD-TYPE')
      AND setting.ValueSourceCode IN (N'IMPORTED', N'SYNTHETIC')
      AND setting.EffectiveFrom <> @AsOfDate;

    EXEC Cash.proc_ReportingProfileSettingSave @SubjectCode, @ProfileCode, N'ACCOUNTING-BASIS', @AsOfDate,
        @TextValue = N'CASH', @StatusCode = @StatusCode, @ValueSourceCode = N'SYNTHETIC', @IsReviewed = 1;
    EXEC Cash.proc_ReportingProfileSettingSave @SubjectCode, @ProfileCode, N'QUARTERLY-PERIOD-TYPE', @AsOfDate,
        @TextValue = N'STANDARD', @StatusCode = @StatusCode, @ValueSourceCode = N'SYNTHETIC', @IsReviewed = 1;
END;

IF @BusinessTaxType = 0
BEGIN
    SELECT @ProfileCode = ReportingProfileCode
    FROM Cash.tbReportingProfile
    WHERE SubjectCode = @SubjectCode AND ReportingTypeCode = 2;

    EXEC Cash.proc_ReportingProfileSave
        @SubjectCode = @SubjectCode, @ReportingTypeCode = 2,
        @TaxSourceCode = N'UK-CO-CT-2026', @ValidFrom = @AsOfDate,
        @StatusCode = @StatusCode, @ValueSourceCode = N'SYNTHETIC', @IsReviewed = 1,
        @ReportingProfileCode = @ProfileCode OUTPUT;

    IF EXISTS
    (
        SELECT setting.SettingCode
        FROM Cash.tbReportingProfileSetting setting
        WHERE setting.SubjectCode = @SubjectCode
          AND setting.ReportingProfileCode = @ProfileCode
          AND setting.SettingCode IN
          (
              N'CT-ASSOCIATED-COMPANIES', N'CT-UK-RESIDENT',
              N'CT-CLOSE-INVESTMENT-HOLDING', N'CT-RING-FENCE-PROFITS'
          )
        GROUP BY setting.SettingCode
        HAVING COUNT(*) <> 1
            OR MAX(CASE WHEN setting.ValueSourceCode IN (N'IMPORTED', N'SYNTHETIC')
                        THEN 0 ELSE 1 END) = 1
    )
        THROW 51521, 'Synthetic statutory profile: existing Corporation Tax setting history cannot be re-anchored safely.', 1;

    UPDATE setting
    SET EffectiveFrom = @AsOfDate
    FROM Cash.tbReportingProfileSetting setting
    WHERE setting.SubjectCode = @SubjectCode
      AND setting.ReportingProfileCode = @ProfileCode
      AND setting.SettingCode IN
      (
          N'CT-ASSOCIATED-COMPANIES', N'CT-UK-RESIDENT',
          N'CT-CLOSE-INVESTMENT-HOLDING', N'CT-RING-FENCE-PROFITS'
      )
      AND setting.ValueSourceCode IN (N'IMPORTED', N'SYNTHETIC')
      AND setting.EffectiveFrom <> @AsOfDate;

    -- Node commissioning creates conservative, unreviewed eligibility
    -- placeholders. A disposable synthetic company has explicit fixture facts,
    -- so replace only those untouched imported defaults before saving the
    -- reviewed effective-dated values.
    DELETE Cash.tbReportingProfileSetting
    WHERE SubjectCode = @SubjectCode
      AND ReportingProfileCode = @ProfileCode
      AND SettingCode IN
      (
          N'CT-ASSOCIATED-COMPANIES', N'CT-UK-RESIDENT',
          N'CT-CLOSE-INVESTMENT-HOLDING', N'CT-RING-FENCE-PROFITS'
      )
      AND ValueSourceCode = N'IMPORTED'
      AND IsReviewed = 0;

    EXEC Cash.proc_ReportingProfileSettingSave @SubjectCode, @ProfileCode,
        N'CT-ASSOCIATED-COMPANIES', @AsOfDate,
        @IntegerValue = 0, @StatusCode = @StatusCode,
        @ValueSourceCode = N'SYNTHETIC', @IsReviewed = 1;
    EXEC Cash.proc_ReportingProfileSettingSave @SubjectCode, @ProfileCode,
        N'CT-UK-RESIDENT', @AsOfDate,
        @BooleanValue = 1, @StatusCode = @StatusCode,
        @ValueSourceCode = N'SYNTHETIC', @IsReviewed = 1;
    EXEC Cash.proc_ReportingProfileSettingSave @SubjectCode, @ProfileCode,
        N'CT-CLOSE-INVESTMENT-HOLDING', @AsOfDate,
        @BooleanValue = 0, @StatusCode = @StatusCode,
        @ValueSourceCode = N'SYNTHETIC', @IsReviewed = 1;
    EXEC Cash.proc_ReportingProfileSettingSave @SubjectCode, @ProfileCode,
        N'CT-RING-FENCE-PROFITS', @AsOfDate,
        @BooleanValue = 0, @StatusCode = @StatusCode,
        @ValueSourceCode = N'SYNTHETIC', @IsReviewed = 1;

    SET @ProfileCode = NULL;
    SELECT @ProfileCode = ReportingProfileCode
    FROM Cash.tbReportingProfile
    WHERE SubjectCode = @SubjectCode AND ReportingTypeCode = 3;

    EXEC Cash.proc_ReportingProfileSave
        @SubjectCode = @SubjectCode, @ReportingTypeCode = 3,
        @TaxSourceCode = N'UK-CO-ACCTS-2026', @ValidFrom = @AsOfDate,
        @StatusCode = @StatusCode, @ValueSourceCode = N'SYNTHETIC', @IsReviewed = 1,
        @ReportingProfileCode = @ProfileCode OUTPUT;

    IF EXISTS
    (
        SELECT setting.SettingCode
        FROM Cash.tbReportingProfileSetting setting
        WHERE setting.SubjectCode = @SubjectCode
          AND setting.ReportingProfileCode = @ProfileCode
          AND setting.SettingCode IN
          (
              N'ACCOUNTING-STANDARD', N'ACCOUNTS-TYPE',
              N'BALANCE-SHEET-FORMAT', N'ACCOUNTING-POLICIES'
          )
        GROUP BY setting.SettingCode
        HAVING COUNT(*) <> 1
            OR MAX(CASE WHEN setting.ValueSourceCode IN (N'IMPORTED', N'SYNTHETIC')
                        THEN 0 ELSE 1 END) = 1
    )
        THROW 51522, 'Synthetic statutory profile: existing Companies House setting history cannot be re-anchored safely.', 1;

    UPDATE setting
    SET EffectiveFrom = @AsOfDate
    FROM Cash.tbReportingProfileSetting setting
    WHERE setting.SubjectCode = @SubjectCode
      AND setting.ReportingProfileCode = @ProfileCode
      AND setting.SettingCode IN
      (
          N'ACCOUNTING-STANDARD', N'ACCOUNTS-TYPE',
          N'BALANCE-SHEET-FORMAT', N'ACCOUNTING-POLICIES'
      )
      AND setting.ValueSourceCode IN (N'IMPORTED', N'SYNTHETIC')
      AND setting.EffectiveFrom <> @AsOfDate;

    EXEC Cash.proc_ReportingProfileSettingSave @SubjectCode, @ProfileCode, N'ACCOUNTING-STANDARD', @AsOfDate,
        @TextValue = N'FRS-105', @StatusCode = @StatusCode, @ValueSourceCode = N'SYNTHETIC', @IsReviewed = 1;
    EXEC Cash.proc_ReportingProfileSettingSave @SubjectCode, @ProfileCode, N'ACCOUNTS-TYPE', @AsOfDate,
        @TextValue = N'MICRO-ENTITY', @StatusCode = @StatusCode, @ValueSourceCode = N'SYNTHETIC', @IsReviewed = 1;
    EXEC Cash.proc_ReportingProfileSettingSave @SubjectCode, @ProfileCode, N'BALANCE-SHEET-FORMAT', @AsOfDate,
        @TextValue = N'FORMAT-1', @StatusCode = @StatusCode, @ValueSourceCode = N'SYNTHETIC', @IsReviewed = 1;
    EXEC Cash.proc_ReportingProfileSettingSave @SubjectCode, @ProfileCode, N'ACCOUNTING-POLICIES', @AsOfDate,
        @TextValue = N'These synthetic accounts use the historical-cost basis and FRS 105.',
        @StatusCode = @StatusCode, @ValueSourceCode = N'SYNTHETIC', @IsReviewed = 1;
END;

IF EXISTS (SELECT 1 FROM Cash.tbTaxType WHERE TaxTypeCode = 1 AND IsEnabled = 1)
BEGIN
    SET @ProfileCode = NULL;
    SELECT @ProfileCode = ReportingProfileCode
    FROM Cash.tbReportingProfile
    WHERE SubjectCode = @SubjectCode AND ReportingTypeCode = 0;

    EXEC Cash.proc_ReportingProfileSave
        @SubjectCode = @SubjectCode, @ReportingTypeCode = 0,
        @TaxSourceCode = NULL, @ValidFrom = @AsOfDate,
        @StatusCode = @StatusCode, @ValueSourceCode = N'SYNTHETIC', @IsReviewed = 1,
        @ReportingProfileCode = @ProfileCode OUTPUT;
END;
GO
