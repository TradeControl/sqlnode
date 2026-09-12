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
    ), Periods AS
    (
        SELECT
            NetProfit = SUM(totals.NetProfit),
            CalculatedTaxDue = SUM(totals.BusinessTax),
            BusinessTaxAdjustment = SUM(totals.BusinessTaxAdjustment),
            MinimumTaxRate = MIN(period.BusinessTaxRate),
            MaximumTaxRate = MAX(period.BusinessTaxRate)
        FROM Cash.vwTaxBizTotalsByPeriod totals
        JOIN App.tbYearPeriod period ON period.StartOn = totals.StartOn
        WHERE CONVERT(DATE, totals.StartOn) >= @PeriodStart
          AND CONVERT(DATE, totals.StartOn) < @PeriodEnd
    )
    SELECT
        PeriodStart = @PeriodStart,
        PeriodEnd = @PeriodEnd,
        due.PayOn,
        periods.NetProfit,
        periods.CalculatedTaxDue,
        periods.BusinessTaxAdjustment,
        BusinessTaxRate = CASE WHEN periods.MinimumTaxRate = periods.MaximumTaxRate
            THEN periods.MinimumTaxRate END,
        IsUniformTaxRate = CONVERT(BIT, CASE WHEN periods.MinimumTaxRate = periods.MaximumTaxRate THEN 1 ELSE 0 END),
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
        PreviousLossesCarriedForward = COALESCE((
            SELECT TOP (1) losses.LossesCarriedForward
            FROM Cash.vwTaxLossesCarriedForward losses
            WHERE CONVERT(DATE, losses.StartOn) < @PeriodEnd
            ORDER BY losses.StartOn DESC), 0),
        LossesCarriedForward = COALESCE((
            SELECT MAX(losses.LossesCarriedForward)
            FROM Cash.vwTaxLossesCarriedForward losses
            WHERE CONVERT(DATE, losses.StartOn) = @PeriodEnd), 0),
        SnapshotRowVer = CONVERT(BINARY(8), @@DBTS)
    FROM SelectedDueDate due
    CROSS JOIN Periods periods
);
GO
