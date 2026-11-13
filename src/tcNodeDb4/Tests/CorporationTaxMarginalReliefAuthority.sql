/*
Authoritative examples for Cash.fnTaxCorpMarginalReliefUK.

Sources pinned for this corpus:
  CTM03925: formula and the N = 90,000 / D = 8,000 example.
  CTM03930: short accounting periods reduce limits by days (the manual's
             displayed 9/12 figures are explicitly illustrative).
  CTM03935: three other associated companies divide both limits by four.

The exact decimal expectations below are literals, not values calculated by a
second copy of the production expression.
*/
SET NOCOUNT ON;
SET XACT_ABORT ON;

IF OBJECT_ID(N'Cash.fnTaxCorpMarginalReliefUK', N'IF') IS NULL
    THROW 51380, 'CorporationTaxMarginalReliefAuthority requires Cash.fnTaxCorpMarginalReliefUK.', 1;

DECLARE @HmrcDistributionExample table
(
    CalculationCode nvarchar(20),
    AugmentedProfits decimal(38,5),
    MarginalRelief decimal(38,5),
    CorporationTaxChargeable decimal(38,5)
);

INSERT @HmrcDistributionExample
SELECT CalculationCode, AugmentedProfits, MarginalRelief, CorporationTaxChargeable
FROM Cash.fnTaxCorpMarginalReliefUK
    (90000, 8000, '20251001', '20260930', 0, 0.25, 0.19, 50000, 250000, 0.015);

IF NOT EXISTS
(
    SELECT 1
    FROM @HmrcDistributionExample
    WHERE CalculationCode = N'MARGINAL-RELIEF'
      AND AugmentedProfits = 98000
      AND MarginalRelief = 2093.87755
      AND CorporationTaxChargeable = 20406.12245
      AND ROUND(CorporationTaxChargeable, 0) = 20406
)
    THROW 51381, 'The CTM03925 distribution example did not reconcile.', 1;

-- CTM03930 says the strict short-period calculation is by days. The 2024
-- example period contains 274 days, giving the following exact limits/result.
IF NOT EXISTS
(
    SELECT 1
    FROM Cash.fnTaxCorpMarginalReliefUK
        (55000, 0, '20240101', '20240930', 0, 0.25, 0.19, 50000, 250000, 0.015)
    WHERE PeriodDays = 274
      AND AdjustedLowerLimit = 37534.24658
      AND AdjustedUpperLimit = 187671.23288
      AND MarginalRelief = 1990.06849
      AND CorporationTaxChargeable = 11759.93151
)
    THROW 51382, 'The CTM03930 strict day-based short-period example did not reconcile.', 1;

-- CTM03935 states that three other associated companies produce a divisor of
-- four and annual limits of 12,500 and 62,500.
IF NOT EXISTS
(
    SELECT 1
    FROM Cash.fnTaxCorpMarginalReliefUK
        (30000, 0, '20250401', '20260331', 3, 0.25, 0.19, 50000, 250000, 0.015)
    WHERE AssociatedCompanyDivisor = 4
      AND AdjustedLowerLimit = 12500
      AND AdjustedUpperLimit = 62500
      AND MarginalRelief = 487.5
      AND CorporationTaxChargeable = 7012.5
)
    THROW 51383, 'The CTM03935 associated-company example did not reconcile.', 1;

PRINT 'Corporation Tax marginal-relief authority regression passed.';
