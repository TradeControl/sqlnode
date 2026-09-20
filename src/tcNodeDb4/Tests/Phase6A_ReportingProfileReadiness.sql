/* Phase 6A reporting-profile registration applicability.
   All mutations are rolled back and no identifier values are emitted. */
SET NOCOUNT, XACT_ABORT ON;

DECLARE
    @SubjectCode NVARCHAR(50) = (SELECT TOP (1) SubjectCode FROM App.tbOptions ORDER BY Identifier),
    @BusinessTaxType SMALLINT = Cash.fnGetBizTaxType(),
    @AsOfDate DATE = CONVERT(DATE, CURRENT_TIMESTAMP),
    @ActiveStatus SMALLINT = (SELECT TOP (1) StatusCode FROM App.tbStatutoryStatus WHERE IsActive = 1 ORDER BY StatusCode),
    @InactiveStatus SMALLINT = (SELECT TOP (1) StatusCode FROM App.tbStatutoryStatus WHERE IsActive = 0 AND StatusCode <> 3 ORDER BY StatusCode DESC),
    @ReportingTypeCode NVARCHAR(20),
    @TaxSourceCode NVARCHAR(20),
    @RegistrationCode NVARCHAR(20),
    @ExpectedSchemeCount INT;

IF @BusinessTaxType = 0
BEGIN
    SET @ReportingTypeCode = N'COMPANY-TAX';
    SET @ExpectedSchemeCount = 1;

    IF NOT EXISTS
       (SELECT 1 FROM App.tbReportingTypeRegistrationScheme
        WHERE ReportingTypeCode = @ReportingTypeCode AND RegistrationSchemeCode = N'GB-UTR')
        THROW 51120, 'Company Tax must require the UK UTR.', 1;
END
ELSE IF @BusinessTaxType = 4
BEGIN
    SET @ReportingTypeCode = N'SELF-EMPLOYMENT';
    SET @ExpectedSchemeCount = 2;

    IF NOT EXISTS
       (SELECT 1 FROM App.tbReportingTypeRegistrationScheme
        WHERE ReportingTypeCode = @ReportingTypeCode AND RegistrationSchemeCode = N'GB-UTR')
       OR NOT EXISTS
       (SELECT 1 FROM App.tbReportingTypeRegistrationScheme
        WHERE ReportingTypeCode = @ReportingTypeCode AND RegistrationSchemeCode = N'GB-NI')
        THROW 51121, 'Self-employment must require both the UK UTR and NINO.', 1;
END
ELSE
    THROW 51122, 'Phase 6A verification requires a company or sole-trader node.', 1;

IF (SELECT COUNT(*) FROM App.tbReportingTypeRegistrationScheme WHERE ReportingTypeCode = @ReportingTypeCode) <> @ExpectedSchemeCount
    THROW 51123, 'The reporting type has an unexpected registration requirement.', 1;

IF EXISTS
   (SELECT 1 FROM App.tbReportingTypeRegistrationScheme
    WHERE ReportingTypeCode IN (N'INDIRECT-TAX', N'STATUTORY-ACCOUNTS'))
    THROW 51124, 'VAT or statutory accounts acquired an unrelated registration requirement.', 1;

SELECT TOP (1)
    @TaxSourceCode = profile.TaxSourceCode
FROM Cash.tbReportingProfile profile
WHERE profile.SubjectCode = @SubjectCode
  AND profile.ReportingTypeCode = @ReportingTypeCode
ORDER BY profile.ValidFrom DESC;

IF @TaxSourceCode IS NULL
    THROW 51125, 'The applicable reporting profile is missing its Tax Source.', 1;

BEGIN TRY
    BEGIN TRANSACTION;

    SELECT TOP (1) @RegistrationCode = registration.RegistrationCode
    FROM Subject.tbRegistration registration
    WHERE registration.SubjectCode = @SubjectCode
      AND registration.RegistrationSchemeCode = N'GB-UTR'
    ORDER BY registration.ValidFrom DESC;

    EXEC Subject.proc_RegistrationSave
        @SubjectCode = @SubjectCode,
        @RegistrationSchemeCode = N'GB-UTR',
        @RegistrationValue = N'1000000001',
        @ValidFrom = @AsOfDate,
        @StatusCode = @ActiveStatus,
        @ValueSourceCode = N'SYNTHETIC',
        @IsReviewed = 1,
        @RegistrationCode = @RegistrationCode OUTPUT;

    IF @@TRANCOUNT <> 1
        THROW 51130, 'The registration save unexpectedly changed the verification transaction boundary.', 1;

    IF EXISTS
       (SELECT 1 FROM App.fnStatutoryContextReadiness
        (@SubjectCode, @ReportingTypeCode, @TaxSourceCode, NULL, NULL, @AsOfDate)
        WHERE FindingCode LIKE N'REGISTRATION-%')
        THROW 51126, 'A reviewed active UTR did not satisfy the mapped reporting requirement.', 1;

    EXEC Subject.proc_RegistrationSave
        @SubjectCode = @SubjectCode,
        @RegistrationSchemeCode = N'GB-UTR',
        @RegistrationValue = NULL,
        @ValidFrom = @AsOfDate,
        @StatusCode = @InactiveStatus,
        @ValueSourceCode = N'USER',
        @IsReviewed = 0,
        @RegistrationCode = @RegistrationCode OUTPUT;

    IF @@TRANCOUNT <> 1
        THROW 51131, 'Clearing the registration unexpectedly changed the verification transaction boundary.', 1;

    IF NOT EXISTS
       (SELECT 1 FROM App.fnStatutoryContextReadiness
        (@SubjectCode, @ReportingTypeCode, @TaxSourceCode, NULL, NULL, @AsOfDate)
        WHERE FindingCode = N'REGISTRATION-MISSING'
          AND RecordCode = N'GB-UTR')
        THROW 51127, 'An inactive UTR did not make the mapped reporting profile incomplete.', 1;

    IF EXISTS
       (SELECT 1 FROM App.fnStatutoryContextReadiness
        (@SubjectCode, N'INDIRECT-TAX', NULL, NULL, NULL, @AsOfDate)
        WHERE FindingCode LIKE N'REGISTRATION-%')
        THROW 51128, 'The UTR state incorrectly affected indirect-tax readiness.', 1;

    IF @BusinessTaxType = 0
       AND EXISTS
       (SELECT 1 FROM App.fnStatutoryContextReadiness
        (@SubjectCode, N'STATUTORY-ACCOUNTS', N'UK-CO-ACCTS-2026', NULL, NULL, @AsOfDate)
        WHERE FindingCode LIKE N'REGISTRATION-%')
        THROW 51129, 'The UTR state incorrectly affected statutory-accounts readiness.', 1;

    ROLLBACK TRANSACTION;
END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;
    THROW;
END CATCH;

PRINT 'Phase 6A reporting-profile readiness verification passed.';
