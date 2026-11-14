/*
Rollback-only verification of the optional UK Corporation Tax extension to
App.tbYearPeriod. Run on a UK company node after period generation.
*/
SET NOCOUNT ON;
SET XACT_ABORT ON;

IF OBJECT_ID(N'App.tbYearPeriodTaxUk', N'U') IS NULL
    THROW 51390, 'CorporationTaxPeriodParametersUk requires App.tbYearPeriodTaxUk.', 1;

IF OBJECT_ID(N'App.proc_YearPeriodTaxUkSet', N'P') IS NULL
    THROW 51391, 'CorporationTaxPeriodParametersUk requires App.proc_YearPeriodTaxUkSet.', 1;

IF OBJECT_ID(N'App.vwYearPeriodTaxUkSeed', N'V') IS NULL
    THROW 51398, 'CorporationTaxPeriodParametersUk requires the build-controlled UK seed ledger.', 1;

IF EXISTS
(
    SELECT 1
    FROM App.vwYearPeriodTaxUkSeed left_seed
    JOIN App.vwYearPeriodTaxUkSeed right_seed
      ON left_seed.FinancialYear <> right_seed.FinancialYear
     AND left_seed.EffectiveFrom <= right_seed.EffectiveTo
     AND right_seed.EffectiveFrom <= left_seed.EffectiveTo
)
    THROW 51399, 'The UK statutory parameter seed ledger contains overlapping effective ranges.', 1;

IF Cash.fnGetBizTaxType() <> 0
    THROW 51392, 'CorporationTaxPeriodParametersUk requires a company node.', 1;

IF NOT EXISTS (SELECT 1 FROM App.tbOptions WHERE JurisdictionCode = N'UK')
    THROW 51393, 'CorporationTaxPeriodParametersUk requires the UK jurisdiction.', 1;

IF EXISTS
(
    SELECT 1
    FROM App.tbYearPeriod period
    CROSS APPLY
    (
        SELECT TOP (1) FinancialYear
        FROM App.vwYearPeriodTaxUkSeed seed
        WHERE period.StartOn >= seed.EffectiveFrom
        ORDER BY seed.EffectiveFrom DESC, seed.SQLBuild DESC
    ) applicable_seed
    LEFT JOIN App.tbYearPeriodTaxUk parameters
      ON parameters.YearNumber = period.YearNumber
     AND parameters.StartOn = period.StartOn
    WHERE parameters.StartOn IS NULL
)
    THROW 51394, 'A UK company period on or after the first ledger entry is missing its UK tax extension.', 1;

IF EXISTS
(
    SELECT 1
    FROM App.tbYearPeriodTaxUk
    WHERE CorporationTaxSmallProfitsRate < 0
       OR CorporationTaxSmallProfitsRate > CorporationTaxMainRate
       OR CorporationTaxMainRate > 1
       OR CorporationTaxMarginalReliefFraction < 0
       OR CorporationTaxMarginalReliefFraction > 1
       OR CorporationTaxLowerLimit <= 0
       OR CorporationTaxUpperLimit <= CorporationTaxLowerLimit
)
    THROW 51395, 'A UK tax-period extension contains invalid statutory parameters.', 1;

IF EXISTS
(
    SELECT 1
    FROM App.vwYearPeriodTaxUkSeed
    WHERE SQLDataVersion <> 4 OR SQLRelease <> 1 OR SQLBuild <> 22
       OR CorporationTaxSmallProfitsRate < 0
       OR CorporationTaxSmallProfitsRate > CorporationTaxMainRate
       OR CorporationTaxMainRate > 1
       OR CorporationTaxMarginalReliefFraction < 0
       OR CorporationTaxMarginalReliefFraction > 1
       OR CorporationTaxLowerLimit <= 0
       OR CorporationTaxUpperLimit <= CorporationTaxLowerLimit
       OR IsProvisional NOT IN (0, 1)
       OR NULLIF(SourceReference, N'') IS NULL
)
    THROW 51400, 'The UK seed ledger is invalid or is not pinned to SQL build 4.1.22.', 1;

DECLARE
    @YearNumber smallint,
    @StartOn datetime;

SELECT TOP (1)
    @YearNumber = YearNumber,
    @StartOn = StartOn
FROM App.tbYearPeriodTaxUk
ORDER BY StartOn;

BEGIN TRANSACTION;

EXEC App.proc_YearPeriodTaxUkSet
    @StartOn = @StartOn,
    @EndOn = @StartOn,
    @CorporationTaxMainRate = 0.249,
    @CorporationTaxSmallProfitsRate = 0.189,
    @CorporationTaxMarginalReliefFraction = 0.014,
    @CorporationTaxLowerLimit = 49000,
    @CorporationTaxUpperLimit = 249000;

IF NOT EXISTS
(
    SELECT 1
    FROM App.tbYearPeriodTaxUk
    WHERE YearNumber = @YearNumber
      AND StartOn = @StartOn
      AND CorporationTaxMainRate = 0.249
      AND CorporationTaxSmallProfitsRate = 0.189
      AND CorporationTaxMarginalReliefFraction = 0.014
      AND CorporationTaxLowerLimit = 49000
      AND CorporationTaxUpperLimit = 249000
)
    THROW 51396, 'The atomic UK tax-period parameter update failed.', 1;

ROLLBACK TRANSACTION;

IF EXISTS
(
    SELECT 1
    FROM App.tbYearPeriodTaxUk
    WHERE YearNumber = @YearNumber
      AND StartOn = @StartOn
      AND CorporationTaxMainRate = 0.249
      AND CorporationTaxSmallProfitsRate = 0.189
      AND CorporationTaxMarginalReliefFraction = 0.014
      AND CorporationTaxLowerLimit = 49000
      AND CorporationTaxUpperLimit = 249000
)
    THROW 51397, 'The rollback-only UK tax-period parameter fixture persisted its changes.', 1;

PRINT 'UK Corporation Tax period-parameter regression passed.';
