/*
    Pure UK ordinary-company Corporation Tax kernel.

    The caller supplies the statutory rates, limits and reviewed company facts.
    This function contains no statement, payment, Category Tree or jurisdiction
    lookup, so it can be reused by actual, forecast and What-if projections.

    AssociatedCompanyCount is the number of other associated companies. The
    statutory divisor is therefore one plus that value.
*/
CREATE FUNCTION Cash.fnTaxCorpMarginalReliefUK
(
    @TaxableTotalProfits decimal(28,5),
    @RelevantDistributions decimal(28,5),
    @AccountingPeriodStart date,
    @AccountingPeriodEnd date,
    @AssociatedCompanyCount int,
    @MainRate decimal(9,6),
    @SmallProfitsRate decimal(9,6),
    @LowerLimit decimal(28,5),
    @UpperLimit decimal(28,5),
    @StandardFraction decimal(9,6)
)
RETURNS TABLE
AS
RETURN
(
    WITH source AS
    (
        SELECT
            TaxableTotalProfits = CONVERT(decimal(38,5), @TaxableTotalProfits),
            RelevantDistributions = CONVERT(decimal(38,5), @RelevantDistributions),
            AugmentedProfits = CONVERT(decimal(38,5),
                COALESCE(@TaxableTotalProfits, 0) + COALESCE(@RelevantDistributions, 0)),
            AccountingPeriodStart = @AccountingPeriodStart,
            AccountingPeriodEnd = @AccountingPeriodEnd,
            PeriodDays = CASE
                WHEN @AccountingPeriodStart IS NULL OR @AccountingPeriodEnd IS NULL THEN NULL
                ELSE DATEDIFF(day, @AccountingPeriodStart, @AccountingPeriodEnd) + 1
            END,
            AssociatedCompanyCount = @AssociatedCompanyCount,
            AssociatedCompanyDivisor = CASE
                WHEN @AssociatedCompanyCount >= 0 THEN CONVERT(decimal(18,9), @AssociatedCompanyCount + 1)
                ELSE NULL
            END,
            MainRate = CONVERT(decimal(18,9), @MainRate),
            SmallProfitsRate = CONVERT(decimal(18,9), @SmallProfitsRate),
            BaseLowerLimit = CONVERT(decimal(38,5), @LowerLimit),
            BaseUpperLimit = CONVERT(decimal(38,5), @UpperLimit),
            StandardFraction = CONVERT(decimal(18,9), @StandardFraction),
            FindingCode = CONVERT(nvarchar(40), CASE
                WHEN @AccountingPeriodStart IS NULL OR @AccountingPeriodEnd IS NULL
                    THEN N'CTMR-PERIOD-REQUIRED'
                WHEN @AccountingPeriodEnd < @AccountingPeriodStart
                    THEN N'CTMR-PERIOD-INVALID'
                WHEN DATEDIFF(day, @AccountingPeriodStart, @AccountingPeriodEnd) + 1 > 366
                    THEN N'CTMR-PERIOD-TOO-LONG'
                WHEN @TaxableTotalProfits IS NULL OR @TaxableTotalProfits < 0
                    THEN N'CTMR-PROFITS-INVALID'
                WHEN @RelevantDistributions IS NULL OR @RelevantDistributions < 0
                    THEN N'CTMR-DISTRIBUTIONS-INVALID'
                WHEN @AssociatedCompanyCount IS NULL OR @AssociatedCompanyCount < 0
                    THEN N'CTMR-ASSOCIATES-INVALID'
                WHEN @MainRate IS NULL OR @MainRate < 0 OR @MainRate > 1
                  OR @SmallProfitsRate IS NULL OR @SmallProfitsRate < 0 OR @SmallProfitsRate > @MainRate
                    THEN N'CTMR-RATES-INVALID'
                WHEN @LowerLimit IS NULL OR @LowerLimit <= 0
                  OR @UpperLimit IS NULL OR @UpperLimit <= @LowerLimit
                    THEN N'CTMR-LIMITS-INVALID'
                WHEN @StandardFraction IS NULL OR @StandardFraction < 0 OR @StandardFraction > 1
                    THEN N'CTMR-FRACTION-INVALID'
                ELSE NULL
            END)
    ), adjusted AS
    (
        SELECT source.*,
            -- CTA 2010 s18D reduces the limits by the number of days in a
            -- short accounting period. Cap at one so a complete leap-year
            -- accounting period does not increase the annual limits.
            PeriodFraction = CONVERT(decimal(18,12), CASE
                WHEN PeriodDays >= 365 THEN 1
                WHEN PeriodDays > 0 THEN CONVERT(decimal(18,12), PeriodDays) / CONVERT(decimal(18,12), 365)
                ELSE 0
            END)
        FROM source
    ), limits AS
    (
        SELECT adjusted.*,
            AdjustedLowerLimit = CONVERT(decimal(38,5), ROUND(
                BaseLowerLimit * PeriodFraction / NULLIF(AssociatedCompanyDivisor, 0), 5)),
            AdjustedUpperLimit = CONVERT(decimal(38,5), ROUND(
                BaseUpperLimit * PeriodFraction / NULLIF(AssociatedCompanyDivisor, 0), 5))
        FROM adjusted
    ), calculation AS
    (
        SELECT limits.*,
            CalculationCode = CONVERT(nvarchar(20), CASE
                WHEN FindingCode IS NOT NULL THEN N'INVALID'
                WHEN TaxableTotalProfits = 0 THEN N'NO-TAX'
                WHEN AugmentedProfits <= AdjustedLowerLimit THEN N'SMALL-PROFITS'
                WHEN AugmentedProfits <= AdjustedUpperLimit THEN N'MARGINAL-RELIEF'
                ELSE N'MAIN-RATE'
            END),
            TaxBeforeMarginalRelief = CONVERT(decimal(38,5), ROUND(CASE
                WHEN FindingCode IS NOT NULL OR TaxableTotalProfits = 0 THEN 0
                WHEN AugmentedProfits <= AdjustedLowerLimit
                    THEN TaxableTotalProfits * SmallProfitsRate
                ELSE TaxableTotalProfits * MainRate
            END, 5)),
            MarginalRelief = CONVERT(decimal(38,5), ROUND(CASE
                WHEN FindingCode IS NULL
                 AND AugmentedProfits > AdjustedLowerLimit
                 AND AugmentedProfits <= AdjustedUpperLimit
                    THEN StandardFraction * (AdjustedUpperLimit - AugmentedProfits)
                        * TaxableTotalProfits / NULLIF(AugmentedProfits, 0)
                ELSE 0
            END, 5))
        FROM limits
    )
    SELECT
        IsValid = CONVERT(bit, CASE WHEN FindingCode IS NULL THEN 1 ELSE 0 END),
        FindingCode,
        CalculationCode,
        TaxableTotalProfits,
        RelevantDistributions,
        AugmentedProfits,
        AccountingPeriodStart,
        AccountingPeriodEnd,
        PeriodDays,
        PeriodFraction,
        AssociatedCompanyCount,
        AssociatedCompanyDivisor,
        MainRate,
        SmallProfitsRate,
        BaseLowerLimit,
        BaseUpperLimit,
        AdjustedLowerLimit,
        AdjustedUpperLimit,
        StandardFraction,
        TaxBeforeMarginalRelief,
        MarginalRelief,
        CorporationTaxChargeable = CONVERT(decimal(38,5),
            ROUND(TaxBeforeMarginalRelief - MarginalRelief, 5)),
        EffectiveTaxRate = CONVERT(decimal(38,12), CASE
            WHEN FindingCode IS NULL AND TaxableTotalProfits > 0
                THEN (TaxBeforeMarginalRelief - MarginalRelief) / TaxableTotalProfits
            ELSE 0
        END)
    FROM calculation
);
