/*
Rollback-only, tenant-neutral verification of the pure UK Corporation Tax
marginal-relief kernel. Expected values are independent literals derived from
CTA 2010 Part 3A and the HMRC CTM03925/CTM03930/CTM03935 examples.
*/
SET NOCOUNT ON;
SET XACT_ABORT ON;

IF OBJECT_ID(N'Cash.fnTaxCorpMarginalReliefUK', N'IF') IS NULL
    THROW 51370, 'CorporationTaxMarginalReliefBoundaries requires Cash.fnTaxCorpMarginalReliefUK.', 1;

DECLARE @Cases table
(
    CaseCode nvarchar(40) NOT NULL,
    TaxableTotalProfits decimal(28,5) NOT NULL,
    RelevantDistributions decimal(28,5) NOT NULL,
    PeriodStart date NOT NULL,
    PeriodEnd date NOT NULL,
    AssociatedCompanyCount int NOT NULL,
    ExpectedCalculationCode nvarchar(20) NOT NULL,
    ExpectedLowerLimit decimal(38,5) NOT NULL,
    ExpectedUpperLimit decimal(38,5) NOT NULL,
    ExpectedMarginalRelief decimal(38,5) NOT NULL,
    ExpectedTax decimal(38,5) NOT NULL
);

INSERT @Cases
    (CaseCode, TaxableTotalProfits, RelevantDistributions, PeriodStart, PeriodEnd,
     AssociatedCompanyCount, ExpectedCalculationCode, ExpectedLowerLimit,
     ExpectedUpperLimit, ExpectedMarginalRelief, ExpectedTax)
VALUES
    (N'ZERO', 0, 0, '20250701', '20260630', 0,
        N'NO-TAX', 50000, 250000, 0, 0),
    (N'BELOW-LOWER', 49999.99, 0, '20250701', '20260630', 0,
        N'SMALL-PROFITS', 50000, 250000, 0, 9499.99810),
    (N'AT-LOWER', 50000, 0, '20250701', '20260630', 0,
        N'SMALL-PROFITS', 50000, 250000, 0, 9500),
    (N'ABOVE-LOWER', 50000.01, 0, '20250701', '20260630', 0,
        N'MARGINAL-RELIEF', 50000, 250000, 2999.99985, 9500.00265),
    (N'INTERIOR', 100000, 0, '20250701', '20260630', 0,
        N'MARGINAL-RELIEF', 50000, 250000, 2250, 22750),
    (N'AT-UPPER', 250000, 0, '20250701', '20260630', 0,
        N'MARGINAL-RELIEF', 50000, 250000, 0, 62500),
    (N'ABOVE-UPPER', 250000.01, 0, '20250701', '20260630', 0,
        N'MAIN-RATE', 50000, 250000, 0, 62500.00250),
    (N'HMRC-DISTRIBUTIONS', 90000, 8000, '20251001', '20260930', 0,
        N'MARGINAL-RELIEF', 50000, 250000, 2093.87755, 20406.12245),
    (N'THREE-ASSOCIATES', 30000, 0, '20250401', '20260331', 3,
        N'MARGINAL-RELIEF', 12500, 62500, 487.5, 7012.5),
    (N'SHORT-PERIOD-DAYS', 55000, 0, '20240101', '20240930', 0,
        N'MARGINAL-RELIEF', 37534.24658, 187671.23288, 1990.06849, 11759.93151),
    (N'FULL-LEAP-YEAR', 50000, 0, '20230701', '20240630', 0,
        N'SMALL-PROFITS', 50000, 250000, 0, 9500);

IF EXISTS
(
    SELECT 1
    FROM @Cases expected
    CROSS APPLY Cash.fnTaxCorpMarginalReliefUK
    (
        expected.TaxableTotalProfits,
        expected.RelevantDistributions,
        expected.PeriodStart,
        expected.PeriodEnd,
        expected.AssociatedCompanyCount,
        0.25,
        0.19,
        50000,
        250000,
        0.015
    ) actual
    WHERE actual.IsValid <> 1
       OR actual.FindingCode IS NOT NULL
       OR actual.CalculationCode <> expected.ExpectedCalculationCode
       OR actual.AdjustedLowerLimit <> expected.ExpectedLowerLimit
       OR actual.AdjustedUpperLimit <> expected.ExpectedUpperLimit
       OR actual.MarginalRelief <> expected.ExpectedMarginalRelief
       OR actual.CorporationTaxChargeable <> expected.ExpectedTax
)
    THROW 51371, 'A Corporation Tax marginal-relief boundary case failed.', 1;

-- HMRC CTM03925 presents its £90,000 N / £8,000 D example to whole pounds.
IF
(
    SELECT ROUND(CorporationTaxChargeable, 0)
    FROM Cash.fnTaxCorpMarginalReliefUK
        (90000, 8000, '20251001', '20260930', 0, 0.25, 0.19, 50000, 250000, 0.015)
) <> 20406
    THROW 51372, 'The HMRC CTM03925 published presentation example did not reconcile.', 1;

DECLARE @Invalid table
(
    CaseCode nvarchar(40) NOT NULL,
    Profits decimal(28,5) NULL,
    Distributions decimal(28,5) NULL,
    PeriodStart date NULL,
    PeriodEnd date NULL,
    Associates int NULL,
    MainRate decimal(9,6) NULL,
    SmallRate decimal(9,6) NULL,
    LowerLimit decimal(28,5) NULL,
    UpperLimit decimal(28,5) NULL,
    Fraction decimal(9,6) NULL,
    ExpectedFindingCode nvarchar(40) NOT NULL
);

INSERT @Invalid VALUES
    (N'MISSING-PERIOD', 100000, 0, NULL, '20260630', 0, 0.25, 0.19, 50000, 250000, 0.015, N'CTMR-PERIOD-REQUIRED'),
    (N'REVERSED-PERIOD', 100000, 0, '20260701', '20260630', 0, 0.25, 0.19, 50000, 250000, 0.015, N'CTMR-PERIOD-INVALID'),
    (N'LONG-PERIOD', 100000, 0, '20240701', '20260630', 0, 0.25, 0.19, 50000, 250000, 0.015, N'CTMR-PERIOD-TOO-LONG'),
    (N'NEGATIVE-PROFIT', -1, 0, '20250701', '20260630', 0, 0.25, 0.19, 50000, 250000, 0.015, N'CTMR-PROFITS-INVALID'),
    (N'NEGATIVE-DISTRIBUTION', 100000, -1, '20250701', '20260630', 0, 0.25, 0.19, 50000, 250000, 0.015, N'CTMR-DISTRIBUTIONS-INVALID'),
    (N'NEGATIVE-ASSOCIATES', 100000, 0, '20250701', '20260630', -1, 0.25, 0.19, 50000, 250000, 0.015, N'CTMR-ASSOCIATES-INVALID'),
    (N'INVALID-RATES', 100000, 0, '20250701', '20260630', 0, 0.19, 0.25, 50000, 250000, 0.015, N'CTMR-RATES-INVALID'),
    (N'INVALID-LIMITS', 100000, 0, '20250701', '20260630', 0, 0.25, 0.19, 250000, 50000, 0.015, N'CTMR-LIMITS-INVALID'),
    (N'INVALID-FRACTION', 100000, 0, '20250701', '20260630', 0, 0.25, 0.19, 50000, 250000, -0.01, N'CTMR-FRACTION-INVALID');

IF EXISTS
(
    SELECT 1
    FROM @Invalid expected
    CROSS APPLY Cash.fnTaxCorpMarginalReliefUK
    (
        expected.Profits, expected.Distributions, expected.PeriodStart, expected.PeriodEnd,
        expected.Associates, expected.MainRate, expected.SmallRate,
        expected.LowerLimit, expected.UpperLimit, expected.Fraction
    ) actual
    WHERE actual.IsValid <> 0
       OR actual.CalculationCode <> N'INVALID'
       OR actual.FindingCode <> expected.ExpectedFindingCode
       OR actual.CorporationTaxChargeable <> 0
)
    THROW 51373, 'An invalid Corporation Tax marginal-relief input did not fail closed.', 1;

PRINT 'Corporation Tax marginal-relief boundary regression passed.';
