CREATE PROCEDURE App.proc_YearPeriodTaxUkSet
(
    @StartOn datetime,
    @EndOn datetime,
    @CorporationTaxMainRate decimal(9, 6),
    @CorporationTaxSmallProfitsRate decimal(9, 6),
    @CorporationTaxMarginalReliefFraction decimal(9, 6),
    @CorporationTaxLowerLimit decimal(28, 5),
    @CorporationTaxUpperLimit decimal(28, 5)
)
AS
SET NOCOUNT, XACT_ABORT ON;

IF @StartOn IS NULL OR @EndOn IS NULL OR @StartOn > @EndOn
    THROW 51330, 'A valid inclusive period range is required.', 1;

IF @CorporationTaxSmallProfitsRate < 0
   OR @CorporationTaxSmallProfitsRate > @CorporationTaxMainRate
   OR @CorporationTaxMainRate > 1
   OR @CorporationTaxMarginalReliefFraction < 0
   OR @CorporationTaxMarginalReliefFraction > 1
    THROW 51331, 'The UK Corporation Tax rates or marginal-relief fraction are invalid.', 1;

IF @CorporationTaxLowerLimit <= 0 OR @CorporationTaxUpperLimit <= @CorporationTaxLowerLimit
    THROW 51332, 'The UK Corporation Tax annual base limits are invalid.', 1;

IF NOT EXISTS
(
    SELECT 1
    FROM App.tbYearPeriodTaxUk
    WHERE StartOn >= @StartOn AND StartOn <= @EndOn
)
    THROW 51333, 'The selected range contains no UK tax-period extensions.', 1;

UPDATE App.tbYearPeriodTaxUk
SET CorporationTaxMainRate = @CorporationTaxMainRate,
    CorporationTaxSmallProfitsRate = @CorporationTaxSmallProfitsRate,
    CorporationTaxMarginalReliefFraction = @CorporationTaxMarginalReliefFraction,
    CorporationTaxLowerLimit = @CorporationTaxLowerLimit,
    CorporationTaxUpperLimit = @CorporationTaxUpperLimit
WHERE StartOn >= @StartOn AND StartOn <= @EndOn;
GO
