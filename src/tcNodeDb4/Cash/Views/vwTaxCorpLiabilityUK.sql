/*
    UK ordinary-company Corporation Tax liability projection.

    This view sits alongside the legacy flat-rate statement during MR-3. It
    derives N and D, applies the existing loss policy, resolves the configured
    period parameters once per accounting year and invokes the pure marginal-
    relief kernel. Provisional rates and unreviewed profile facts may support a
    labelled tax accrual, but they never make the result filing-ready.
*/
CREATE VIEW Cash.vwTaxCorpLiabilityUK
AS
WITH profile_context AS
(
    SELECT
        options.SubjectCode,
        profile.ReportingProfileCode,
        profile.TaxSourceCode,
        ProfileValidFrom = profile.ValidFrom,
        ProfileValidTo = profile.ValidTo,
        ProfileStatusCode = profile.StatusCode,
        ProfileIsReviewed = profile.IsReviewed,
        AssociatedCompanyCount = associates.IntegerValue,
        AssociatesEffectiveFrom = associates.EffectiveFrom,
        AssociatesEffectiveTo = associates.EffectiveTo,
        AssociatesStatusCode = associates.StatusCode,
        AssociatesIsReviewed = associates.IsReviewed,
        IsUkResident = resident.BooleanValue,
        ResidentEffectiveFrom = resident.EffectiveFrom,
        ResidentEffectiveTo = resident.EffectiveTo,
        ResidentStatusCode = resident.StatusCode,
        ResidentIsReviewed = resident.IsReviewed,
        IsCloseInvestmentHolding = close_holding.BooleanValue,
        CloseHoldingEffectiveFrom = close_holding.EffectiveFrom,
        CloseHoldingEffectiveTo = close_holding.EffectiveTo,
        CloseHoldingStatusCode = close_holding.StatusCode,
        CloseHoldingIsReviewed = close_holding.IsReviewed,
        HasRingFenceProfits = ring_fence.BooleanValue,
        RingFenceEffectiveFrom = ring_fence.EffectiveFrom,
        RingFenceEffectiveTo = ring_fence.EffectiveTo,
        RingFenceStatusCode = ring_fence.StatusCode,
        RingFenceIsReviewed = ring_fence.IsReviewed
    FROM App.tbOptions options
    OUTER APPLY
    (
        SELECT TOP (1) candidate.*
        FROM Cash.tbReportingProfile candidate
        WHERE candidate.SubjectCode = options.SubjectCode
          AND candidate.ReportingTypeCode = 2
          AND candidate.TaxSourceCode IS NOT NULL
        ORDER BY CASE candidate.StatusCode WHEN 1 THEN 0 ELSE 1 END,
                 candidate.ValidFrom DESC,
                 candidate.ReportingProfileCode
    ) profile
    OUTER APPLY
    (
        SELECT TOP (1) setting.*
        FROM Cash.tbReportingProfileSetting setting
        WHERE setting.SubjectCode = profile.SubjectCode
          AND setting.ReportingProfileCode = profile.ReportingProfileCode
          AND setting.SettingCode = N'CT-ASSOCIATED-COMPANIES'
        ORDER BY setting.EffectiveFrom DESC
    ) associates
    OUTER APPLY
    (
        SELECT TOP (1) setting.*
        FROM Cash.tbReportingProfileSetting setting
        WHERE setting.SubjectCode = profile.SubjectCode
          AND setting.ReportingProfileCode = profile.ReportingProfileCode
          AND setting.SettingCode = N'CT-UK-RESIDENT'
        ORDER BY setting.EffectiveFrom DESC
    ) resident
    OUTER APPLY
    (
        SELECT TOP (1) setting.*
        FROM Cash.tbReportingProfileSetting setting
        WHERE setting.SubjectCode = profile.SubjectCode
          AND setting.ReportingProfileCode = profile.ReportingProfileCode
          AND setting.SettingCode = N'CT-CLOSE-INVESTMENT-HOLDING'
        ORDER BY setting.EffectiveFrom DESC
    ) close_holding
    OUTER APPLY
    (
        SELECT TOP (1) setting.*
        FROM Cash.tbReportingProfileSetting setting
        WHERE setting.SubjectCode = profile.SubjectCode
          AND setting.ReportingProfileCode = profile.ReportingProfileCode
          AND setting.SettingCode = N'CT-RING-FENCE-PROFITS'
        ORDER BY setting.EffectiveFrom DESC
    ) ring_fence
    WHERE options.JurisdictionCode = N'UK'
      AND Cash.fnGetBizTaxType() = 0
), distribution_codes AS
(
    SELECT DISTINCT mapping.CashCode, mapping.CashPolarityCode
    FROM profile_context profile
    JOIN Cash.vwTaxTagCashCode mapping
      ON mapping.TaxSourceCode = profile.TaxSourceCode
     AND mapping.TagCode = N'RelevantDistributions'
), distribution_values AS
(
    SELECT code.CashCode,
           cash_period.StartOn,
           StatutoryAmount = CONVERT(decimal(38,5), cash_period.InvoiceValue)
    FROM distribution_codes code
    JOIN Cash.tbPeriod cash_period
      ON cash_period.CashCode = code.CashCode
    JOIN App.tbYearPeriod period
      ON period.StartOn = cash_period.StartOn
    JOIN App.tbYear year_definition
      ON year_definition.YearNumber = period.YearNumber
     AND year_definition.CashStatusCode BETWEEN 1 AND 2
), distribution_by_year AS
(
    SELECT period.YearNumber,
           RelevantDistributions = CONVERT(decimal(38,5), COALESCE(SUM(value.StatutoryAmount), 0))
    FROM App.tbYearPeriod period
    LEFT JOIN distribution_values value ON value.StartOn = period.StartOn
    GROUP BY period.YearNumber
), parameter_by_year AS
(
    SELECT period.YearNumber,
           PeriodCount = COUNT_BIG(*),
           ParameterRowCount = COUNT_BIG(parameters.StartOn),
           MainRate = MIN(parameters.CorporationTaxMainRate),
           MainRateMaximum = MAX(parameters.CorporationTaxMainRate),
           SmallProfitsRate = MIN(parameters.CorporationTaxSmallProfitsRate),
           SmallProfitsRateMaximum = MAX(parameters.CorporationTaxSmallProfitsRate),
           MarginalReliefFraction = MIN(parameters.CorporationTaxMarginalReliefFraction),
           MarginalReliefFractionMaximum = MAX(parameters.CorporationTaxMarginalReliefFraction),
           LowerLimit = MIN(parameters.CorporationTaxLowerLimit),
           LowerLimitMaximum = MAX(parameters.CorporationTaxLowerLimit),
           UpperLimit = MIN(parameters.CorporationTaxUpperLimit),
           UpperLimitMaximum = MAX(parameters.CorporationTaxUpperLimit),
           IsProvisional = CONVERT(bit, MAX(CASE
               WHEN seed.FinancialYear IS NULL OR seed.IsProvisional = 1
                    OR period.StartOn > seed.EffectiveTo THEN 1 ELSE 0 END))
    FROM App.tbYearPeriod period
    LEFT JOIN App.tbYearPeriodTaxUk parameters
      ON parameters.YearNumber = period.YearNumber
     AND parameters.StartOn = period.StartOn
    OUTER APPLY
    (
        SELECT TOP (1) ledger.FinancialYear, ledger.EffectiveTo, ledger.IsProvisional
        FROM App.vwYearPeriodTaxUkSeed ledger
        WHERE period.StartOn >= ledger.EffectiveFrom
        ORDER BY ledger.EffectiveFrom DESC, ledger.SQLBuild DESC
    ) seed
    GROUP BY period.YearNumber
), accounting_by_year AS
(
    SELECT year_definition.YearNumber,
           year_definition.Description,
           PeriodStart = CONVERT(date, MIN(period.StartOn)),
           PeriodEnd = CONVERT(date, DATEADD(day, -1, DATEADD(month, 1, MAX(period.StartOn)))),
           AccountingResult = CONVERT(decimal(38,5), SUM(COALESCE(totals.NetProfit, 0))),
           BusinessTaxAdjustment = CONVERT(decimal(38,5), SUM(period.BusinessTaxAdjustment))
    FROM App.tbYear year_definition
    JOIN App.tbYearPeriod period
      ON period.YearNumber = year_definition.YearNumber
    LEFT JOIN Cash.vwTaxBizTotalsByPeriod totals
      ON totals.StartOn = period.StartOn
    GROUP BY year_definition.YearNumber, year_definition.Description
), year_source AS
(
    SELECT accounting.YearNumber,
           accounting.Description,
           accounting.PeriodStart,
           accounting.PeriodEnd,
           accounting.AccountingResult,
           distribution.RelevantDistributions,
           TaxableResultBeforeRelief = CONVERT(decimal(38,5),
               accounting.AccountingResult - distribution.RelevantDistributions),
           accounting.BusinessTaxAdjustment,
           parameters.PeriodCount,
           parameters.ParameterRowCount,
           parameters.MainRate,
           parameters.MainRateMaximum,
           parameters.SmallProfitsRate,
           parameters.SmallProfitsRateMaximum,
           parameters.MarginalReliefFraction,
           parameters.MarginalReliefFractionMaximum,
           parameters.LowerLimit,
           parameters.LowerLimitMaximum,
           parameters.UpperLimit,
           parameters.UpperLimitMaximum,
           parameters.IsProvisional,
           profile.*,
           SequenceNumber = ROW_NUMBER() OVER (ORDER BY accounting.YearNumber)
    FROM accounting_by_year accounting
    JOIN distribution_by_year distribution ON distribution.YearNumber = accounting.YearNumber
    JOIN parameter_by_year parameters ON parameters.YearNumber = accounting.YearNumber
    CROSS JOIN profile_context profile
), loss_rollup AS
(
    SELECT source.*,
           OpeningLoss = CONVERT(decimal(38,5), 0),
           LossCreated = CONVERT(decimal(38,5), CASE
               WHEN source.TaxableResultBeforeRelief < 0 THEN -source.TaxableResultBeforeRelief ELSE 0 END),
           LossUsed = CONVERT(decimal(38,5), 0),
           ClosingLoss = CONVERT(decimal(38,5), CASE
               WHEN source.TaxableResultBeforeRelief < 0 THEN -source.TaxableResultBeforeRelief ELSE 0 END),
           TaxableTotalProfits = CONVERT(decimal(38,5), CASE
               WHEN source.TaxableResultBeforeRelief > 0 THEN source.TaxableResultBeforeRelief ELSE 0 END)
    FROM year_source source
    WHERE source.SequenceNumber = 1

    UNION ALL

    SELECT source.*,
           OpeningLoss = CONVERT(decimal(38,5), prior.ClosingLoss),
           LossCreated = CONVERT(decimal(38,5), CASE
               WHEN source.TaxableResultBeforeRelief < 0 THEN -source.TaxableResultBeforeRelief ELSE 0 END),
           LossUsed = CONVERT(decimal(38,5), CASE
               WHEN source.TaxableResultBeforeRelief <= 0 THEN 0
               WHEN prior.ClosingLoss < source.TaxableResultBeforeRelief THEN prior.ClosingLoss
               ELSE source.TaxableResultBeforeRelief END),
           ClosingLoss = CONVERT(decimal(38,5), CASE
               WHEN source.TaxableResultBeforeRelief < 0
                   THEN prior.ClosingLoss - source.TaxableResultBeforeRelief
               WHEN prior.ClosingLoss > source.TaxableResultBeforeRelief
                   THEN prior.ClosingLoss - source.TaxableResultBeforeRelief
               ELSE 0 END),
           TaxableTotalProfits = CONVERT(decimal(38,5), CASE
               WHEN source.TaxableResultBeforeRelief > prior.ClosingLoss
                   THEN source.TaxableResultBeforeRelief - prior.ClosingLoss
               ELSE 0 END)
    FROM loss_rollup prior
    JOIN year_source source ON source.SequenceNumber = prior.SequenceNumber + 1
), prepared AS
(
    SELECT rollup.*,
           HasCompleteParameters = CONVERT(bit, CASE
               WHEN rollup.ParameterRowCount = rollup.PeriodCount THEN 1 ELSE 0 END),
           HasUniformParameters = CONVERT(bit, CASE
               WHEN rollup.MainRate = rollup.MainRateMaximum
                AND rollup.SmallProfitsRate = rollup.SmallProfitsRateMaximum
                AND rollup.MarginalReliefFraction = rollup.MarginalReliefFractionMaximum
                AND rollup.LowerLimit = rollup.LowerLimitMaximum
                AND rollup.UpperLimit = rollup.UpperLimitMaximum THEN 1 ELSE 0 END),
           HasCompleteProfile = CONVERT(bit, CASE
               WHEN rollup.ReportingProfileCode IS NOT NULL
                AND rollup.AssociatedCompanyCount IS NOT NULL
                AND rollup.IsUkResident IS NOT NULL
                AND rollup.IsCloseInvestmentHolding IS NOT NULL
                AND rollup.HasRingFenceProfits IS NOT NULL THEN 1 ELSE 0 END),
           IsProfileReviewed = CONVERT(bit, CASE
               WHEN rollup.ProfileStatusCode = 1 AND rollup.ProfileIsReviewed = 1
                AND rollup.AssociatesStatusCode = 1 AND rollup.AssociatesIsReviewed = 1
                AND rollup.ResidentStatusCode = 1 AND rollup.ResidentIsReviewed = 1
                AND rollup.CloseHoldingStatusCode = 1 AND rollup.CloseHoldingIsReviewed = 1
                AND rollup.RingFenceStatusCode = 1 AND rollup.RingFenceIsReviewed = 1
               THEN 1 ELSE 0 END),
           HasProfileCoverage = CONVERT(bit, CASE
               WHEN rollup.ProfileValidFrom <= rollup.PeriodStart
                AND (rollup.ProfileValidTo IS NULL OR rollup.ProfileValidTo >= rollup.PeriodEnd)
                AND rollup.AssociatesEffectiveFrom <= rollup.PeriodStart
                AND (rollup.AssociatesEffectiveTo IS NULL OR rollup.AssociatesEffectiveTo >= rollup.PeriodEnd)
                AND rollup.ResidentEffectiveFrom <= rollup.PeriodStart
                AND (rollup.ResidentEffectiveTo IS NULL OR rollup.ResidentEffectiveTo >= rollup.PeriodEnd)
                AND rollup.CloseHoldingEffectiveFrom <= rollup.PeriodStart
                AND (rollup.CloseHoldingEffectiveTo IS NULL OR rollup.CloseHoldingEffectiveTo >= rollup.PeriodEnd)
                AND rollup.RingFenceEffectiveFrom <= rollup.PeriodStart
                AND (rollup.RingFenceEffectiveTo IS NULL OR rollup.RingFenceEffectiveTo >= rollup.PeriodEnd)
               THEN 1 ELSE 0 END),
           IsSupportedProfile = CONVERT(bit, CASE
               WHEN rollup.IsUkResident = 1
                AND rollup.IsCloseInvestmentHolding = 0
                AND rollup.HasRingFenceProfits = 0
                AND rollup.AssociatedCompanyCount BETWEEN 0 AND 2147483646
               THEN 1 ELSE 0 END)
    FROM loss_rollup rollup
)
SELECT
    projection.YearNumber,
    JurisdictionCode = CONVERT(nvarchar(10), N'UK'),
    projection.TaxSourceCode,
    projection.ReportingProfileCode,
    projection.Description,
    projection.PeriodStart,
    projection.PeriodEnd,
    projection.AccountingResult,
    projection.RelevantDistributions,
    projection.TaxableResultBeforeRelief,
    projection.OpeningLoss,
    projection.LossCreated,
    projection.LossUsed,
    projection.ClosingLoss,
    projection.TaxableTotalProfits,
    kernel.AugmentedProfits,
    AssociatedCompanyCount = CONVERT(int, projection.AssociatedCompanyCount),
    projection.MainRate,
    projection.SmallProfitsRate,
    projection.MarginalReliefFraction,
    projection.LowerLimit,
    projection.UpperLimit,
    projection.IsProvisional,
    projection.HasCompleteParameters,
    projection.HasUniformParameters,
    projection.HasCompleteProfile,
    projection.IsProfileReviewed,
    projection.HasProfileCoverage,
    projection.IsSupportedProfile,
    RateFindingCode = CONVERT(nvarchar(40), CASE
        WHEN projection.HasCompleteParameters = 0 THEN N'CT-RATE-MISSING'
        WHEN projection.HasUniformParameters = 0 THEN N'CT-RATE-SPLIT-REQUIRED'
        WHEN projection.IsProvisional = 1 THEN N'CT-RATE-PROVISIONAL'
        ELSE NULL END),
    ProfileFindingCode = CONVERT(nvarchar(40), CASE
        WHEN projection.HasCompleteProfile = 0 THEN N'CT-PROFILE-MISSING'
        WHEN projection.IsSupportedProfile = 0 THEN N'CT-PROFILE-UNSUPPORTED'
        WHEN projection.HasProfileCoverage = 0 THEN N'CT-PROFILE-PERIOD-COVERAGE'
        WHEN projection.IsProfileReviewed = 0 THEN N'CT-PROFILE-UNREVIEWED'
        ELSE NULL END),
    KernelFindingCode = kernel.FindingCode,
    kernel.CalculationCode,
    kernel.AdjustedLowerLimit,
    kernel.AdjustedUpperLimit,
    kernel.TaxBeforeMarginalRelief,
    kernel.MarginalRelief,
    kernel.CorporationTaxChargeable,
    projection.BusinessTaxAdjustment,
    TaxDue = CONVERT(decimal(38,5),
        ROUND(kernel.CorporationTaxChargeable + projection.BusinessTaxAdjustment, 5)),
    IsAccrualReady = CONVERT(bit, CASE
        WHEN kernel.IsValid = 1
         AND projection.HasCompleteParameters = 1
         AND projection.HasUniformParameters = 1
         AND projection.HasCompleteProfile = 1
         AND projection.IsSupportedProfile = 1 THEN 1 ELSE 0 END),
    IsFilingReady = CONVERT(bit, CASE
        WHEN kernel.IsValid = 1
         AND projection.HasCompleteParameters = 1
         AND projection.HasUniformParameters = 1
         AND projection.IsProvisional = 0
         AND projection.HasCompleteProfile = 1
         AND projection.IsSupportedProfile = 1
         AND projection.HasProfileCoverage = 1
         AND projection.IsProfileReviewed = 1 THEN 1 ELSE 0 END)
FROM prepared projection
CROSS APPLY Cash.fnTaxCorpMarginalReliefUK
(
    projection.TaxableTotalProfits,
    projection.RelevantDistributions,
    projection.PeriodStart,
    projection.PeriodEnd,
    CONVERT(int, projection.AssociatedCompanyCount),
    projection.MainRate,
    projection.SmallProfitsRate,
    projection.LowerLimit,
    projection.UpperLimit,
    projection.MarginalReliefFraction
) kernel;
GO
