/*
    MR-3 actual-accounting statement cutover regression.

    Prerequisite: an initialised UK company with complete UK period parameters,
    a CT reporting profile and at least one accrual-ready accounting year.
    Fixture changes are rolled back.
*/
SET NOCOUNT ON;
SET XACT_ABORT ON;

IF OBJECT_ID(N'Cash.vwTaxCorpLiabilityUK', N'V') IS NULL
    THROW 51411, 'The UK CT liability projection is not deployed.', 1;

IF OBJECT_ID(N'Cash.vwTaxBizLiability', N'V') IS NULL
    THROW 51423, 'The common business-tax liability contract is not deployed.', 1;

IF COL_LENGTH(N'App.tbYearPeriod', N'BusinessTaxRate') IS NULL
    THROW 51412, 'The legacy BusinessTaxRate comparison field has been removed.', 1;

IF NOT EXISTS
(
    SELECT 1
    FROM App.tbOptions
    WHERE JurisdictionCode = N'UK'
      AND Cash.fnGetBizTaxType() = 0
)
    THROW 51413, 'This regression requires a UK company node.', 1;

IF NOT EXISTS (SELECT 1 FROM Cash.vwTaxCorpLiabilityUK WHERE IsAccrualReady = 1)
    THROW 51414, 'This regression requires at least one accrual-ready UK CT year.', 1;

BEGIN TRAN CtStatementReconcile;

BEGIN TRY
    /*
        Materialise the superseded flat-rate calculation inside the regression
        fixture. It remains a useful comparison, but is not a production schema
        object or a callable alternative business-tax provider.
    */
    ;WITH year_source AS
    (
        SELECT year_definition.YearNumber,
               year_definition.Description,
               PeriodStart = CONVERT(date, MIN(period.StartOn)),
               PeriodEnd = CONVERT(date,
                   DATEADD(day, -1, DATEADD(month, 1, MAX(period.StartOn)))),
               TaxableResult = CONVERT(decimal(38,5),
                   SUM(COALESCE(totals.NetProfit, 0))),
               BusinessTaxAdjustment = CONVERT(decimal(38,5),
                   SUM(period.BusinessTaxAdjustment)),
               EffectiveTaxRate = CONVERT(decimal(38,12),
                   CONVERT(decimal(28,12),
                       SUM(CONVERT(decimal(19,12), period.BusinessTaxRate)
                           * DATEDIFF(day, period.StartOn,
                               DATEADD(month, 1, period.StartOn))))
                   / NULLIF(CONVERT(decimal(10,0),
                       SUM(DATEDIFF(day, period.StartOn,
                           DATEADD(month, 1, period.StartOn)))), 0))
        FROM App.tbYear year_definition
        JOIN App.tbYearPeriod period
          ON period.YearNumber = year_definition.YearNumber
        LEFT JOIN Cash.vwTaxBizTotalsByPeriod totals
          ON totals.StartOn = period.StartOn
        GROUP BY year_definition.YearNumber, year_definition.Description
    ), ordered AS
    (
        SELECT *, SequenceNumber = ROW_NUMBER() OVER (ORDER BY YearNumber)
        FROM year_source
    ), tax_rollup AS
    (
        SELECT source.SequenceNumber,
               source.YearNumber,
               source.TaxableResult,
               source.BusinessTaxAdjustment,
               source.EffectiveTaxRate,
               ClosingLoss = CONVERT(decimal(38,5), CASE
                   WHEN source.TaxableResult < 0 THEN -source.TaxableResult ELSE 0 END),
               TaxableProfitAfterRelief = CONVERT(decimal(38,5), CASE
                   WHEN source.TaxableResult > 0 THEN source.TaxableResult ELSE 0 END)
        FROM ordered source
        WHERE source.SequenceNumber = 1

        UNION ALL

        SELECT source.SequenceNumber,
               source.YearNumber,
               source.TaxableResult,
               source.BusinessTaxAdjustment,
               source.EffectiveTaxRate,
               ClosingLoss = CONVERT(decimal(38,5), CASE
                   WHEN source.TaxableResult < 0
                   THEN prior.ClosingLoss - source.TaxableResult
                   WHEN prior.ClosingLoss > source.TaxableResult
                   THEN prior.ClosingLoss - source.TaxableResult
                   ELSE 0 END),
               TaxableProfitAfterRelief = CONVERT(decimal(38,5), CASE
                   WHEN source.TaxableResult > prior.ClosingLoss
                   THEN source.TaxableResult - prior.ClosingLoss ELSE 0 END)
        FROM tax_rollup prior
        JOIN ordered source
          ON source.SequenceNumber = prior.SequenceNumber + 1
    )
    SELECT tax_rollup.YearNumber,
           TaxDue = CONVERT(decimal(38,5), ROUND(
               tax_rollup.TaxableProfitAfterRelief * tax_rollup.EffectiveTaxRate
                   + tax_rollup.BusinessTaxAdjustment, 5))
    INTO #LegacyControl
    FROM tax_rollup;

    IF EXISTS
    (
        SELECT projection.YearNumber
        FROM Cash.vwTaxCorpLiabilityUK projection
        WHERE projection.IsAccrualReady = 1
        EXCEPT
        SELECT computation.YearNumber
        FROM Cash.vwTaxBizComputationByYear computation
    )
    OR EXISTS
    (
        SELECT computation.YearNumber
        FROM Cash.vwTaxBizComputationByYear computation
        EXCEPT
        SELECT projection.YearNumber
        FROM Cash.vwTaxCorpLiabilityUK projection
        WHERE projection.IsAccrualReady = 1
    )
        THROW 51415, 'The selected annual computation does not contain exactly the accrual-ready UK years.', 1;

    IF EXISTS
    (
        SELECT 1
        FROM Cash.vwTaxCorpLiabilityUK projection
        JOIN Cash.vwTaxBizComputationByYear computation
          ON computation.YearNumber = projection.YearNumber
        WHERE projection.IsAccrualReady = 1
          AND
          (
              computation.TaxableResult <> projection.AccountingResult
           OR computation.OpeningLoss <> projection.OpeningLoss
           OR computation.LossCreated <> projection.LossCreated
           OR computation.LossUsed <> projection.LossUsed
           OR computation.ClosingLoss <> projection.ClosingLoss
           OR computation.TaxableProfitAfterRelief <> projection.TaxableTotalProfits
           OR computation.BusinessTaxAdjustment <> projection.BusinessTaxAdjustment
           OR computation.TaxDue <> projection.TaxDue
           OR computation.TaxReliefApplied <> projection.MarginalRelief * -1
          )
    )
        THROW 51416, 'The selected annual computation does not reconcile to the UK liability projection.', 1;

    IF NOT EXISTS
    (
        SELECT 1
        FROM Cash.vwTaxBizComputationByYear selected
        JOIN #LegacyControl legacy
          ON legacy.YearNumber = selected.YearNumber
        WHERE ABS(selected.TaxDue - legacy.TaxDue) > 0.00001
    )
        THROW 51417, 'The UK computation has not demonstrably replaced the flat-rate control.', 1;

    IF EXISTS
    (
        SELECT computation.YearNumber
        FROM Cash.vwTaxBizComputationByYear computation
        JOIN Cash.fnTaxTypeDueDates(Cash.fnGetBizTaxType(), 0) due
          ON CONVERT(date, due.PayFrom) = computation.PeriodStart
         AND CONVERT(date, due.PayTo) = DATEADD(day, 1, computation.PeriodEnd)
        OUTER APPLY
        (
            SELECT StatementTaxDue = SUM(statement.TaxDue)
            FROM Cash.vwTaxBizStatement statement
            WHERE CONVERT(date, statement.StartOn) = CONVERT(date, due.PayOn)
        ) statement
        WHERE computation.TaxDue <> COALESCE(statement.StatementTaxDue, 0)
    )
        THROW 51418, 'The CT statement liability does not reconcile to the selected annual computation.', 1;

    SELECT selected.YearNumber,
           LegacyTaxDue = legacy.TaxDue,
           SelectedTaxDue = selected.TaxDue,
           Difference = selected.TaxDue - legacy.TaxDue
    FROM Cash.vwTaxBizComputationByYear selected
    JOIN #LegacyControl legacy
      ON legacy.YearNumber = selected.YearNumber
    ORDER BY selected.YearNumber;

    DECLARE @PeriodStart date;
    DECLARE @PeriodEnd date;

    SELECT TOP (1)
        @PeriodStart = computation.PeriodStart,
        @PeriodEnd = DATEADD(day, 1, computation.PeriodEnd)
    FROM Cash.vwTaxBizComputationByYear computation
    ORDER BY computation.YearNumber;

    IF NOT EXISTS
    (
        SELECT 1
        FROM Cash.fnTaxBizComputation(@PeriodStart, @PeriodEnd)
        WHERE CalculatedTaxDue = StatementTaxDue
          AND IsUniformTaxRate = 1
    )
        THROW 51419, 'The period CT computation does not reconcile to the selected statement liability.', 1;

    DECLARE @PaymentCode nvarchar(20);
    DECLARE @OriginalPaidOut decimal(18,5);
    DECLARE @TaxExpenseBefore decimal(38,5);
    DECLARE @TaxBalanceBefore decimal(38,5);

    SELECT TOP (1)
        @PaymentCode = payment.PaymentCode,
        @OriginalPaidOut = payment.PaidOutValue
    FROM Cash.tbPayment payment
    JOIN Cash.tbTaxType tax_type
      ON tax_type.CashCode = payment.CashCode
     AND tax_type.TaxTypeCode = Cash.fnGetBizTaxType()
    WHERE payment.PaidOutValue > 0
    ORDER BY payment.PaidOn, payment.PaymentCode;

    IF @PaymentCode IS NULL
        THROW 51426, 'A posted business-tax payment is required for settlement isolation.', 1;

    SELECT @TaxExpenseBefore = SUM(TaxDue)
    FROM Cash.vwTaxBizComputationByYear;

    SELECT @TaxBalanceBefore = SUM(TaxDue + TaxPaid)
    FROM Cash.vwTaxBizStatement;

    UPDATE Cash.tbPayment
    SET PaidOutValue = PaidOutValue + 1
    WHERE PaymentCode = @PaymentCode;

    IF (SELECT SUM(TaxDue) FROM Cash.vwTaxBizComputationByYear) <> @TaxExpenseBefore
        THROW 51427, 'Changing a tax settlement changed the calculated tax expense.', 1;

    IF (SELECT SUM(TaxDue + TaxPaid) FROM Cash.vwTaxBizStatement) <> @TaxBalanceBefore - 1
        THROW 51428, 'Changing a tax settlement did not change the tax-control balance by the same amount.', 1;

    UPDATE Cash.tbPayment
    SET PaidOutValue = @OriginalPaidOut
    WHERE PaymentCode = @PaymentCode;

    IF (SELECT SUM(TaxDue + TaxPaid) FROM Cash.vwTaxBizStatement) <> @TaxBalanceBefore
        THROW 51429, 'Reversing the tax-settlement fixture did not restore the prior balance.', 1;

    DECLARE @SubjectCode nvarchar(10);
    DECLARE @ReportingProfileCode nvarchar(20);
    DECLARE @EffectiveFrom date;

    SELECT TOP (1)
        @SubjectCode = setting.SubjectCode,
        @ReportingProfileCode = setting.ReportingProfileCode,
        @EffectiveFrom = setting.EffectiveFrom
    FROM Cash.tbReportingProfileSetting setting
    JOIN Cash.tbReportingProfile profile
      ON profile.SubjectCode = setting.SubjectCode
     AND profile.ReportingProfileCode = setting.ReportingProfileCode
    WHERE profile.ReportingTypeCode = 2
      AND setting.SettingCode = N'CT-UK-RESIDENT'
    ORDER BY setting.EffectiveFrom DESC;

    IF @SubjectCode IS NULL
        THROW 51420, 'The CT residence setting required for fail-closed verification is missing.', 1;

    UPDATE Cash.tbReportingProfileSetting
    SET BooleanValue = 0
    WHERE SubjectCode = @SubjectCode
      AND ReportingProfileCode = @ReportingProfileCode
      AND SettingCode = N'CT-UK-RESIDENT'
      AND EffectiveFrom = @EffectiveFrom;

    IF EXISTS (SELECT 1 FROM Cash.vwTaxCorpLiabilityUK WHERE IsAccrualReady <> 0)
        THROW 51421, 'An unsupported CT profile remained tax-accrual ready.', 1;

    IF EXISTS (SELECT 1 FROM Cash.vwTaxBizComputationByYear)
        THROW 51422, 'The selected annual computation did not fail closed for an unsupported UK profile.', 1;

    IF EXISTS (SELECT 1 FROM Cash.vwTaxBizLiability WHERE IsAccrualReady <> 0)
        THROW 51424, 'The common liability contract exposed an unsupported CT accrual as ready.', 1;

    IF NOT EXISTS
    (
        SELECT 1
        FROM Cash.vwTaxBizLiability
        WHERE FindingCode = N'CT-PROFILE-UNSUPPORTED'
          AND IsAccrualReady = 0
          AND IsFilingReady = 0
    )
        THROW 51425, 'The common liability contract did not retain the unsupported-profile diagnostic.', 1;

    ROLLBACK TRAN CtStatementReconcile;
END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0 ROLLBACK TRAN CtStatementReconcile;
    THROW;
END CATCH;
