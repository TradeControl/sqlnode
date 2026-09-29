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
            MinimumTaxRate = MIN(period.BusinessTaxRate),
            MaximumTaxRate = MAX(period.BusinessTaxRate)
        FROM App.tbYearPeriod period
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
                WHEN rates.MinimumTaxRate = rates.MaximumTaxRate THEN 1 ELSE 0 END),
            PreviousLossesCarriedForward = computation.OpeningLoss,
            LossesCarriedForward = computation.ClosingLoss
        FROM Cash.vwTaxBizComputationByYear computation
        CROSS JOIN RateProfile rates
        WHERE computation.PeriodStart = @PeriodStart
          AND DATEADD(day, 1, computation.PeriodEnd) = @PeriodEnd
    )
    SELECT
        PeriodStart = @PeriodStart,
        PeriodEnd = @PeriodEnd,
        due.PayOn,
        periods.NetProfit,
        periods.CalculatedTaxDue,
        periods.BusinessTaxAdjustment,
        periods.BusinessTaxRate,
        periods.IsUniformTaxRate,
        StatementTaxDue = COALESCE((
            SELECT SUM(statement.TaxDue)
            FROM Cash.vwTaxBizStatement statement
            WHERE CONVERT(DATE, statement.StartOn) = due.PayOn), 0),
        StatementTaxPaid = COALESCE((
            SELECT SUM(statement.TaxPaid)
            FROM Cash.vwTaxBizStatement statement
            WHERE CONVERT(DATE, statement.StartOn) > COALESCE(due.PreviousPayOn, @PeriodStart)
              AND CONVERT(DATE, statement.StartOn) <= due.PayOn), 0),
        StatementBalance = COALESCE((
            SELECT TOP (1) statement.Balance
            FROM Cash.vwTaxBizStatement statement
            WHERE CONVERT(DATE, statement.StartOn) <= due.PayOn
            ORDER BY statement.StartOn DESC, statement.TaxDue DESC), 0),
        periods.PreviousLossesCarriedForward,
        periods.LossesCarriedForward,
        SnapshotRowVer = CONVERT(BINARY(8), @@DBTS)
    FROM SelectedDueDate due
    CROSS JOIN Periods periods
);
GO
