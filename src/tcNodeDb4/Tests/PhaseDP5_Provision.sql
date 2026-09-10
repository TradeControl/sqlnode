/*
    DP5 synthetic statutory-context provisioning.
    This script persists conspicuously synthetic values and is guarded to the
    fixed Tax Hub sandbox catalogue. It is not part of database initialization.
*/
SET NOCOUNT, XACT_ABORT ON;

IF DB_NAME() NOT IN
(
    N'tcNodeDb4-COMIPFVT1-COMIN26', N'tcNodeDb4-COSIPFVT1-COSTD26',
    N'tcNodeDb4-STMIPFVT1-STMIN26', N'tcNodeDb4-STSIPFVT1-STSTD26'
)
    THROW 51070, 'DP5 provisioning is restricted to the named Tax Hub sandboxes.', 1;

DECLARE @SubjectCode NVARCHAR(50) =
    (SELECT TOP (1) SubjectCode FROM App.tbOptions ORDER BY Identifier);
DECLARE @AddressCode NVARCHAR(15) =
    (SELECT AddressCode FROM Subject.tbSubject WHERE SubjectCode = @SubjectCode);
DECLARE @AsOfDate DATE = CONVERT(date, '20250406');
DECLARE @BusinessTaxType SMALLINT = Cash.fnGetBizTaxType();
DECLARE @SyntheticUtr NVARCHAR(10) = CASE @BusinessTaxType
    WHEN 0 THEN N'1000000001' ELSE N'2000000001' END;
DECLARE @RegistrationCode NVARCHAR(20);
DECLARE @ProfileCode NVARCHAR(20);

IF @SubjectCode IS NULL OR @AddressCode IS NULL
    THROW 51071, 'The sandbox home subject and selected address are required.', 1;

BEGIN TRAN PhaseDP5Provision;
BEGIN TRY
    MERGE Subject.tbAddressDetail AS target
    USING
    (
        SELECT @AddressCode AS AddressCode,
               N'1 Synthetic Test Way' AS AddressLine1,
               N'Testborough' AS Locality,
               N'TE1 1ST' AS PostalCode,
               N'UK' AS JurisdictionCode
    ) AS source
    ON target.AddressCode = source.AddressCode
    WHEN MATCHED THEN UPDATE SET
        AddressLine1 = source.AddressLine1,
        AddressLine2 = NULL,
        AddressLine3 = NULL,
        Locality = source.Locality,
        Region = NULL,
        PostalCode = source.PostalCode,
        JurisdictionCode = source.JurisdictionCode,
        ValueSourceCode = N'SYNTHETIC',
        IsReviewed = 1
    WHEN NOT MATCHED THEN INSERT
    (
        AddressCode, AddressLine1, Locality, PostalCode,
        JurisdictionCode, ValueSourceCode, IsReviewed
    )
    VALUES
    (
        source.AddressCode, source.AddressLine1, source.Locality, source.PostalCode,
        source.JurisdictionCode, N'SYNTHETIC', 1
    );

    UPDATE Subject.tbVirtual
    SET VatNumber = CASE
            WHEN EXISTS (SELECT 1 FROM Cash.tbTaxType WHERE TaxTypeCode = 1 AND IsEnabled = 1)
                THEN COALESCE(NULLIF(LTRIM(RTRIM(VatNumber)), N''), N'999000001')
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
        @StatusCode = 1,
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
            @StatusCode = 1,
            @ValueSourceCode = N'SYNTHETIC',
            @IsReviewed = 1,
            @RegistrationCode = @RegistrationCode OUTPUT;

        SET @ProfileCode = NULL;
        SELECT @ProfileCode = ReportingProfileCode
        FROM Cash.tbReportingProfile
        WHERE SubjectCode = @SubjectCode
          AND ReportingTypeCode = N'SELF-EMPLOYMENT'
          AND TaxSourceCode = N'UK-ITSA-SE-CUM';

        EXEC Cash.proc_ReportingProfileSave
            @SubjectCode = @SubjectCode,
            @ReportingTypeCode = N'SELF-EMPLOYMENT',
            @TaxSourceCode = N'UK-ITSA-SE-CUM',
            @AuthorityReference = N'XQIS00000000001',
            @ValidFrom = @AsOfDate,
            @StatusCode = 1,
            @ValueSourceCode = N'SYNTHETIC',
            @IsReviewed = 1,
            @ReportingProfileCode = @ProfileCode OUTPUT;

        EXEC Cash.proc_ReportingProfileSettingSave
            @SubjectCode, @ProfileCode, N'ACCOUNTING-BASIS', @AsOfDate,
            @TextValue = N'CASH', @StatusCode = 1,
            @ValueSourceCode = N'SYNTHETIC', @IsReviewed = 1;

        EXEC Cash.proc_ReportingProfileSettingSave
            @SubjectCode, @ProfileCode, N'QUARTERLY-PERIOD-TYPE', @AsOfDate,
            @TextValue = N'STANDARD', @StatusCode = 1,
            @ValueSourceCode = N'SYNTHETIC', @IsReviewed = 1;
    END;

    IF @BusinessTaxType = 0
    BEGIN
        SET @ProfileCode = NULL;
        SELECT @ProfileCode = ReportingProfileCode
        FROM Cash.tbReportingProfile
        WHERE SubjectCode = @SubjectCode
          AND ReportingTypeCode = N'COMPANY-TAX'
          AND TaxSourceCode = N'UK-CO-CT-2026';

        EXEC Cash.proc_ReportingProfileSave
            @SubjectCode = @SubjectCode,
            @ReportingTypeCode = N'COMPANY-TAX',
            @TaxSourceCode = N'UK-CO-CT-2026',
            @ValidFrom = @AsOfDate,
            @StatusCode = 1,
            @ValueSourceCode = N'SYNTHETIC',
            @IsReviewed = 1,
            @ReportingProfileCode = @ProfileCode OUTPUT;

        SET @ProfileCode = NULL;
        SELECT @ProfileCode = ReportingProfileCode
        FROM Cash.tbReportingProfile
        WHERE SubjectCode = @SubjectCode
          AND ReportingTypeCode = N'STATUTORY-ACCOUNTS'
          AND TaxSourceCode = N'UK-CO-ACCTS-2026';

        EXEC Cash.proc_ReportingProfileSave
            @SubjectCode = @SubjectCode,
            @ReportingTypeCode = N'STATUTORY-ACCOUNTS',
            @TaxSourceCode = N'UK-CO-ACCTS-2026',
            @ValidFrom = @AsOfDate,
            @StatusCode = 1,
            @ValueSourceCode = N'SYNTHETIC',
            @IsReviewed = 1,
            @ReportingProfileCode = @ProfileCode OUTPUT;

        EXEC Cash.proc_ReportingProfileSettingSave
            @SubjectCode, @ProfileCode, N'ACCOUNTING-STANDARD', @AsOfDate,
            @TextValue = N'FRS-105', @StatusCode = 1,
            @ValueSourceCode = N'SYNTHETIC', @IsReviewed = 1;

        EXEC Cash.proc_ReportingProfileSettingSave
            @SubjectCode, @ProfileCode, N'ACCOUNTS-TYPE', @AsOfDate,
            @TextValue = N'MICRO-ENTITY', @StatusCode = 1,
            @ValueSourceCode = N'SYNTHETIC', @IsReviewed = 1;

        EXEC Cash.proc_ReportingProfileSettingSave
            @SubjectCode, @ProfileCode, N'BALANCE-SHEET-FORMAT', @AsOfDate,
            @TextValue = N'FORMAT-1', @StatusCode = 1,
            @ValueSourceCode = N'SYNTHETIC', @IsReviewed = 1;

        EXEC Cash.proc_ReportingProfileSettingSave
            @SubjectCode, @ProfileCode, N'ACCOUNTING-POLICIES', @AsOfDate,
            @TextValue = N'These synthetic accounts use the historical-cost basis and FRS 105.',
            @StatusCode = 1, @ValueSourceCode = N'SYNTHETIC', @IsReviewed = 1;
    END;

    IF EXISTS (SELECT 1 FROM Cash.tbTaxType WHERE TaxTypeCode = 1 AND IsEnabled = 1)
    BEGIN
        SET @ProfileCode = NULL;
        SELECT @ProfileCode = ReportingProfileCode
        FROM Cash.tbReportingProfile
        WHERE SubjectCode = @SubjectCode AND ReportingTypeCode = N'INDIRECT-TAX';

        EXEC Cash.proc_ReportingProfileSave
            @SubjectCode = @SubjectCode,
            @ReportingTypeCode = N'INDIRECT-TAX',
            @TaxSourceCode = NULL,
            @ValidFrom = @AsOfDate,
            @StatusCode = 1,
            @ValueSourceCode = N'SYNTHETIC',
            @IsReviewed = 1,
            @ReportingProfileCode = @ProfileCode OUTPUT;
    END;

    COMMIT TRAN PhaseDP5Provision;
    PRINT 'DP5 synthetic statutory context provisioned.';
END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0 ROLLBACK TRAN PhaseDP5Provision;
    THROW;
END CATCH;
