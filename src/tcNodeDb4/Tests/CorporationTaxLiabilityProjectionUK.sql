/*
Rollback-only acceptance of the UK annual liability/accrual projection.
The live statement remains on the legacy calculation during this fixture.
*/
SET NOCOUNT ON;
SET XACT_ABORT ON;

IF OBJECT_ID(N'Cash.vwTaxCorpLiabilityUK', N'V') IS NULL
    THROW 51410, 'CorporationTaxLiabilityProjectionUK requires Cash.vwTaxCorpLiabilityUK.', 1;

IF Cash.fnGetBizTaxType() <> 0
    THROW 51411, 'CorporationTaxLiabilityProjectionUK requires a company node.', 1;

IF NOT EXISTS (SELECT 1 FROM App.tbOptions WHERE JurisdictionCode = N'UK')
    THROW 51412, 'CorporationTaxLiabilityProjectionUK requires the UK jurisdiction.', 1;

IF NOT EXISTS (SELECT 1 FROM Cash.vwTaxCorpLiabilityUK)
    THROW 51413, 'The UK liability projection returned no accounting years.', 1;

IF EXISTS
(
    SELECT 1
    FROM Cash.vwTaxCorpLiabilityUK
    WHERE AugmentedProfits <> TaxableTotalProfits + RelevantDistributions
       OR TaxDue <> CorporationTaxChargeable + BusinessTaxAdjustment
)
    THROW 51414, 'The UK liability projection does not reconcile N, D, A or the monetary adjustment.', 1;

IF EXISTS
(
    SELECT 1
    FROM Cash.vwTaxCorpLiabilityUK
    WHERE IsAccrualReady = 1
      AND (KernelFindingCode IS NOT NULL
        OR HasCompleteParameters = 0
        OR HasUniformParameters = 0
        OR HasCompleteProfile = 0
        OR IsSupportedProfile = 0)
)
    THROW 51415, 'An accrual-ready UK liability contains an arithmetic or supported-profile finding.', 1;

IF EXISTS
(
    SELECT 1
    FROM Cash.vwTaxCorpLiabilityUK
    WHERE IsProvisional = 1
      AND (RateFindingCode <> N'CT-RATE-PROVISIONAL' OR IsFilingReady <> 0)
)
    THROW 51416, 'A provisional UK rate did not block filing readiness.', 1;

IF EXISTS
(
    SELECT 1
    FROM Cash.vwTaxCorpLiabilityUK
    WHERE IsFilingReady = 1
      AND (RateFindingCode IS NOT NULL OR ProfileFindingCode IS NOT NULL
        OR KernelFindingCode IS NOT NULL)
)
    THROW 51417, 'A filing-ready UK liability still contains a readiness finding.', 1;

IF EXISTS (SELECT 1 FROM Cash.vwTaxCorpLiabilityUK WHERE RelevantDistributions > 0)
   AND NOT EXISTS
   (
       SELECT 1
       FROM Cash.vwTaxCorpLiabilityUK
       WHERE RelevantDistributions > 0
         AND AugmentedProfits > TaxableTotalProfits
   )
    THROW 51418, 'Positive relevant distributions did not increase augmented profits.', 1;

DECLARE
    @SubjectCode nvarchar(50),
    @ReportingProfileCode nvarchar(20),
    @EarliestPeriodStart date = (SELECT MIN(PeriodStart) FROM Cash.vwTaxCorpLiabilityUK);

SELECT TOP (1)
    @SubjectCode = profile.SubjectCode,
    @ReportingProfileCode = profile.ReportingProfileCode
FROM Cash.tbReportingProfile profile
JOIN App.tbOptions options ON options.SubjectCode = profile.SubjectCode
WHERE profile.ReportingTypeCode = 2
  AND profile.TaxSourceCode IS NOT NULL
ORDER BY CASE profile.StatusCode WHEN 1 THEN 0 ELSE 1 END,
         profile.ValidFrom DESC;

IF @ReportingProfileCode IS NULL
    THROW 51419, 'No CT reporting profile is available for the filing-readiness transition test.', 1;

BEGIN TRY
    BEGIN TRANSACTION;

    UPDATE Cash.tbReportingProfile
    SET ValidFrom = @EarliestPeriodStart,
        StatusCode = 1,
        IsReviewed = 1
    WHERE SubjectCode = @SubjectCode
      AND ReportingProfileCode = @ReportingProfileCode;

    UPDATE Cash.tbReportingProfileSetting
    SET EffectiveFrom = @EarliestPeriodStart,
        StatusCode = 1,
        IsReviewed = 1
    WHERE SubjectCode = @SubjectCode
      AND ReportingProfileCode = @ReportingProfileCode
      AND SettingCode IN
      (
          N'CT-ASSOCIATED-COMPANIES',
          N'CT-UK-RESIDENT',
          N'CT-CLOSE-INVESTMENT-HOLDING',
          N'CT-RING-FENCE-PROFITS'
      );

    IF EXISTS
    (
        SELECT 1
        FROM Cash.vwTaxCorpLiabilityUK
        WHERE IsAccrualReady = 1
          AND IsProvisional = 0
          AND IsFilingReady <> 1
    )
        THROW 51420, 'Reviewed, covered and non-provisional UK liabilities did not become filing-ready.', 1;

    IF EXISTS
    (
        SELECT 1
        FROM Cash.vwTaxCorpLiabilityUK
        WHERE IsAccrualReady = 1
          AND IsProvisional = 1
          AND (IsFilingReady <> 0 OR RateFindingCode <> N'CT-RATE-PROVISIONAL')
    )
        THROW 51421, 'Reviewing the company profile incorrectly cleared the provisional-rate filing block.', 1;

    ROLLBACK TRANSACTION;
END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;
    THROW;
END CATCH;

SELECT YearNumber, PeriodStart, PeriodEnd,
       AccountingResult, TaxableTotalProfits, RelevantDistributions, AugmentedProfits,
       CalculationCode, MarginalRelief, CorporationTaxChargeable, TaxDue,
       RateFindingCode, ProfileFindingCode, IsAccrualReady, IsFilingReady
FROM Cash.vwTaxCorpLiabilityUK
ORDER BY YearNumber;

PRINT 'UK Corporation Tax liability projection regression passed.';
