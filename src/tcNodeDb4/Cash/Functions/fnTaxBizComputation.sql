CREATE FUNCTION Cash.fnTaxBizComputation
(
    @PeriodStart DATE,
    @PeriodEnd DATE
)
RETURNS TABLE
AS
RETURN
(
    WITH DueDates AS
    (
        SELECT
            PayOn = CONVERT(DATE, PayOn),
            PayFrom = CONVERT(DATE, PayFrom),
            PayTo = CONVERT(DATE, PayTo),
            PreviousPayOn = LAG(CONVERT(DATE, PayOn)) OVER (ORDER BY PayOn)
        FROM Cash.fnTaxTypeDueDates(Cash.fnGetBizTaxType(), 0)
    ), SelectedDueDate AS
    (
        SELECT PayOn, PayFrom, PayTo, PreviousPayOn
        FROM DueDates
        WHERE PayFrom = @PeriodStart
          AND PayTo = @PeriodEnd
    ), RateProfile AS
    (
        SELECT
            IsUkCompany = CONVERT(BIT, MAX(CASE
                WHEN options.JurisdictionCode = N'UK'
                 AND Cash.fnGetBizTaxType() = 0 THEN 1 ELSE 0 END)),
            PeriodCount = COUNT_BIG(*),
            UkParameterCount = COUNT_BIG(uk.StartOn),
            MinimumTaxRate = MIN(period.BusinessTaxRate),
            MaximumTaxRate = MAX(period.BusinessTaxRate),
            MinimumMainRate = MIN(uk.CorporationTaxMainRate),
            MaximumMainRate = MAX(uk.CorporationTaxMainRate),
            MinimumSmallProfitsRate = MIN(uk.CorporationTaxSmallProfitsRate),
            MaximumSmallProfitsRate = MAX(uk.CorporationTaxSmallProfitsRate),
            MinimumMarginalReliefFraction = MIN(uk.CorporationTaxMarginalReliefFraction),
            MaximumMarginalReliefFraction = MAX(uk.CorporationTaxMarginalReliefFraction),
            MinimumLowerLimit = MIN(uk.CorporationTaxLowerLimit),
            MaximumLowerLimit = MAX(uk.CorporationTaxLowerLimit),
            MinimumUpperLimit = MIN(uk.CorporationTaxUpperLimit),
            MaximumUpperLimit = MAX(uk.CorporationTaxUpperLimit)
        FROM App.tbYearPeriod period
        CROSS JOIN App.tbOptions options
        LEFT JOIN App.tbYearPeriodTaxUk uk
          ON uk.YearNumber = period.YearNumber
         AND uk.StartOn = period.StartOn
        WHERE CONVERT(DATE, period.StartOn) >= @PeriodStart
          AND CONVERT(DATE, period.StartOn) < @PeriodEnd
    ), Periods AS
    (
        SELECT
            NetProfit = computation.TaxableResult,
            CalculatedTaxDue = computation.TaxDue,
            computation.BusinessTaxAdjustment,
            BusinessTaxRate = computation.EffectiveTaxRate,
            IsUniformTaxRate = CONVERT(BIT, CASE
                WHEN rates.IsUkCompany = 1
                 AND rates.UkParameterCount = rates.PeriodCount
                 AND rates.MinimumMainRate = rates.MaximumMainRate
                 AND rates.MinimumSmallProfitsRate = rates.MaximumSmallProfitsRate
                 AND rates.MinimumMarginalReliefFraction = rates.MaximumMarginalReliefFraction
                 AND rates.MinimumLowerLimit = rates.MaximumLowerLimit
                 AND rates.MinimumUpperLimit = rates.MaximumUpperLimit THEN 1
                WHEN rates.IsUkCompany = 0
                 AND rates.MinimumTaxRate = rates.MaximumTaxRate THEN 1
                ELSE 0 END),
            PreviousLossesCarriedForward = computation.OpeningLoss,
            LossesCarriedForward = computation.ClosingLoss
        FROM Cash.vwTaxBizComputationByYear computation
        CROSS JOIN RateProfile rates
        WHERE computation.PeriodStart = @PeriodStart
          AND DATEADD(day, 1, computation.PeriodEnd) = @PeriodEnd
    ), StatementRows AS
    (
        SELECT due.PayOn,
               due.PreviousPayOn,
               statement.StartOn,
               statement.TaxDue,
               statement.TaxPaid,
               LastBalance = FIRST_VALUE(statement.Balance) OVER
               (
                   PARTITION BY due.PayOn
                   ORDER BY statement.StartOn DESC, statement.TaxDue DESC
               )
        FROM SelectedDueDate due
        LEFT JOIN Cash.vwTaxBizStatement statement
          ON CONVERT(DATE, statement.StartOn) <= due.PayOn
    ), StatementSummary AS
    (
        SELECT PayOn,
               StatementTaxDue = COALESCE(SUM(CASE
                   WHEN CONVERT(DATE, StartOn) = PayOn THEN TaxDue ELSE 0 END), 0),
               StatementTaxPaid = COALESCE(SUM(CASE
                   WHEN CONVERT(DATE, StartOn) > COALESCE(PreviousPayOn, @PeriodStart)
                    AND CONVERT(DATE, StartOn) <= PayOn THEN TaxPaid ELSE 0 END), 0),
               StatementBalance = COALESCE(MAX(LastBalance), 0)
        FROM StatementRows
        GROUP BY PayOn
    )
    SELECT
        PeriodStart = @PeriodStart,
        PeriodEnd = @PeriodEnd,
        statement.PayOn,
        periods.NetProfit,
        periods.CalculatedTaxDue,
        periods.BusinessTaxAdjustment,
        periods.BusinessTaxRate,
        periods.IsUniformTaxRate,
        statement.StatementTaxDue,
        statement.StatementTaxPaid,
        statement.StatementBalance,
        periods.PreviousLossesCarriedForward,
        periods.LossesCarriedForward,
        SnapshotRowVer = CONVERT(BINARY(8), @@DBTS)
    FROM StatementSummary statement
    CROSS JOIN Periods periods
);
GO
