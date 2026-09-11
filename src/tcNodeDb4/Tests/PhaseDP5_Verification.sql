/* DP5 persisted sandbox verification. Emits no raw statutory identifier. */
SET NOCOUNT, XACT_ABORT ON;

DECLARE @SubjectCode NVARCHAR(50) =
    (SELECT TOP (1) SubjectCode FROM App.tbOptions ORDER BY Identifier);
DECLARE @AsOfDate DATE = CONVERT(date, getdate());
DECLARE @BusinessTaxType SMALLINT = Cash.fnGetBizTaxType();

IF NOT EXISTS
(
    SELECT 1 FROM Subject.fnStatutoryIdentity(@AsOfDate)
    WHERE SubjectCode = @SubjectCode
      AND NULLIF(LTRIM(RTRIM(SubjectName)), N'') IS NOT NULL
      AND EffectiveRegistryJurisdictionCode IS NOT NULL
      AND OptionsRowVer IS NOT NULL AND SubjectRowVer IS NOT NULL
      AND VirtualRowVer IS NOT NULL
)
    THROW 51080, 'The authoritative statutory identity is incomplete.', 1;

IF NOT EXISTS
(
    SELECT 1 FROM Subject.fnRegistrationMasked(@SubjectCode, N'GB-UTR', @AsOfDate)
    WHERE IsReviewed = 1 AND RegistrationDisplayValue NOT LIKE N'%[0-9][0-9][0-9][0-9][0-9]%'
)
    THROW 51081, 'The reviewed UTR is absent or insufficiently masked.', 1;

IF @BusinessTaxType = 0
BEGIN
    IF NOT EXISTS
       (SELECT 1 FROM Subject.fnStatutoryIdentity(@AsOfDate)
        WHERE SubjectCode = @SubjectCode
          AND NULLIF(LTRIM(RTRIM(CompanyNumber)), N'') IS NOT NULL
          AND NULLIF(LTRIM(RTRIM(StatutoryAddress)), N'') IS NOT NULL
          AND StatutoryAddressCode = COALESCE(RegisteredAddressCode, TradingAddressCode)
          AND StatutoryAddressRowVer IS NOT NULL)
        THROW 51082, 'The company number or effective statutory address is missing.', 1;

    IF (SELECT COUNT(DISTINCT AuthorityCode) FROM Cash.fnReportingProfile(@SubjectCode, NULL, NULL, @AsOfDate)) < 2
        THROW 51083, 'The company does not have independent HMRC and Companies House profiles.', 1;

    IF EXISTS
       (SELECT 1 FROM App.fnStatutoryContextReadiness(@SubjectCode, N'COMPANY-TAX', N'UK-CO-CT-2026', N'GB-UTR', NULL, @AsOfDate))
        THROW 51084, 'The Corporation Tax context is not ready.', 1;

    IF EXISTS
       (SELECT 1 FROM App.fnStatutoryContextReadiness(@SubjectCode, N'STATUTORY-ACCOUNTS', N'UK-CO-ACCTS-2026', NULL, N'ACCOUNTING-STANDARD', @AsOfDate))
        THROW 51085, 'The statutory accounts context is not ready.', 1;

    IF EXISTS
       (SELECT 1 FROM App.fnStatutoryContextReadiness(@SubjectCode, N'STATUTORY-ACCOUNTS', N'UK-CO-ACCTS-2026', NULL, N'ACCOUNTING-POLICIES', @AsOfDate))
        THROW 51091, 'The accounting policies suggestion is not ready.', 1;
END;

IF @BusinessTaxType = 4
   AND NOT EXISTS
   (SELECT 1 FROM Subject.fnStatutoryIdentity(@AsOfDate)
    WHERE SubjectCode = @SubjectCode
      AND NULLIF(LTRIM(RTRIM(StatutoryAddress)), N'') IS NOT NULL
      AND StatutoryAddressCode = COALESCE(RegisteredAddressCode, TradingAddressCode)
      AND StatutoryAddressRowVer IS NOT NULL)
    THROW 51092, 'The sole trader statutory address is missing.', 1;

IF @BusinessTaxType = 4
BEGIN
    IF NOT EXISTS
       (SELECT 1 FROM Subject.fnRegistrationMasked(@SubjectCode, N'GB-NI', @AsOfDate)
        WHERE IsReviewed = 1 AND RegistrationDisplayValue LIKE N'%*%')
        THROW 51086, 'The reviewed masked NINO is missing.', 1;

    IF EXISTS
       (SELECT 1 FROM App.fnStatutoryContextReadiness(@SubjectCode, N'SELF-EMPLOYMENT', N'UK-ITSA-SE-CUM', N'GB-NI', N'ACCOUNTING-BASIS', @AsOfDate))
        THROW 51087, 'The self-employment context is not ready.', 1;

    DECLARE @HasConsolidated BIT = CASE WHEN EXISTS
        (SELECT 1 FROM Cash.tbTaxTagMap WHERE TaxSourceCode = N'UK-ITSA-SE-CUM' AND TagCode = N'consolidatedExpenses')
        THEN 1 ELSE 0 END;
    DECLARE @HasDetailed BIT = CASE WHEN EXISTS
        (SELECT 1 FROM Cash.tbTaxTagMap WHERE TaxSourceCode = N'UK-ITSA-SE-CUM' AND TagCode = N'costOfGoods')
        THEN 1 ELSE 0 END;

    IF @HasConsolidated = @HasDetailed
        THROW 51088, 'The cumulative profile is not unambiguously MIN or STD.', 1;
END;

IF EXISTS (SELECT 1 FROM Cash.tbTaxType WHERE TaxTypeCode = 1 AND IsEnabled = 1)
BEGIN
    IF NOT EXISTS
       (SELECT 1 FROM Subject.fnStatutoryIdentity(@AsOfDate)
        WHERE SubjectCode = @SubjectCode AND NULLIF(LTRIM(RTRIM(VatNumber)), N'') IS NOT NULL)
        THROW 51089, 'The VAT number is missing.', 1;

    IF EXISTS
       (SELECT 1 FROM App.fnStatutoryContextReadiness(@SubjectCode, N'INDIRECT-TAX', NULL, NULL, NULL, @AsOfDate))
        THROW 51090, 'The VAT context is not ready.', 1;
END;

PRINT 'DP5 persisted statutory-context verification passed.';
