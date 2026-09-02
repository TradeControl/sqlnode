/*
    Phase 4D repeatable database acceptance fixture.
    Run against a freshly created Sole Trader MIN MTD or STD MTD node.
    Every mutation is enclosed in a transaction and rolled back.
*/
SET NOCOUNT, XACT_ABORT ON;

BEGIN TRAN Phase4DCumulativeFixture;
BEGIN TRY
    DECLARE @Source NVARCHAR(20) = 'UK-ITSA-SE-CUM';
    DECLARE @IsConsolidated BIT = CASE WHEN EXISTS
        (SELECT 1 FROM Cash.tbTaxTagMap WHERE TaxSourceCode = @Source
         AND TagCode = 'consolidatedExpenses' AND IsEnabled = 1) THEN 1 ELSE 0 END;

    IF (SELECT COUNT(*) FROM Cash.tbTaxTag WHERE TaxSourceCode = @Source) <> 18
        THROW 51000, 'Expected the eighteen-tag cumulative manifest.', 1;
    IF NOT EXISTS
       (
           SELECT 1
           FROM Cash.tbTaxTag
           WHERE TaxSourceCode = @Source
             AND TagCode = 'consolidatedExpenses'
             AND TagClassCode = 1
             AND CashPolarityCode = 0
       )
        THROW 51000, 'Consolidated expenses must remain a writable expense Component.', 1;
    IF (SELECT COUNT(*) FROM Cash.tbTaxTag
        WHERE TaxSourceCode = @Source
          AND TagCode IN ('irrecoverableDebts', 'depreciation')
          AND TagClassCode = 1
          AND CashPolarityCode = 0) <> 2
        THROW 51000, 'The two new detailed expense tags must be writable expense Components.', 1;
    IF EXISTS (SELECT 1 FROM Cash.tbTaxTagMap WHERE TaxSourceCode = @Source
               AND TagCode IN ('irrecoverableDebts', 'depreciation'))
        THROW 51000, 'Irrecoverable debts and depreciation must be unmapped by default.', 1;
    IF EXISTS (SELECT 1 FROM Cash.fnTaxTagMapValidate(@Source) WHERE IsError = 1)
        THROW 51000, 'Bootstrap mapping must validate.', 1;

    IF @IsConsolidated = 1
    BEGIN
        IF (SELECT COUNT(*) FROM Cash.tbTaxTagMap WHERE TaxSourceCode = @Source AND IsEnabled = 1) <> 3
            THROW 51000, 'MIN must contain exactly two income roots and one consolidated-expense root.', 1;
        IF NOT EXISTS (SELECT 1 FROM Cash.tbTaxTagMap WHERE TaxSourceCode = @Source
                       AND TagCode = 'consolidatedExpenses' AND MapTypeCode = 0
                       AND CategoryCode = 'CT-CUMEXP' AND CashCode = '' AND IsEnabled = 1)
            THROW 51000, 'MIN must map CT-CUMEXP to consolidatedExpenses.', 1;
        IF EXISTS (SELECT 1 FROM Cash.tbTaxTagMap WHERE TaxSourceCode = @Source
                   AND TagCode IN ('costOfGoods', 'paymentsToSubcontractors', 'wagesAndStaffCosts',
                       'carVanTravelExpenses', 'premisesRunningCosts', 'maintenanceCosts', 'adminCosts',
                       'advertisingCosts', 'businessEntertainmentCosts', 'interestOnBankOtherLoans',
                       'financeCharges', 'irrecoverableDebts', 'professionalFees', 'depreciation',
                       'otherExpenses'))
            THROW 51000, 'MIN must not install detailed mappings.', 1;
    END
    ELSE
    BEGIN
        IF (SELECT COUNT(DISTINCT TagCode) FROM Cash.tbTaxTagMap WHERE TaxSourceCode = @Source
            AND TagCode NOT IN ('turnover', 'otherBusinessIncome') AND IsEnabled = 1) <> 13
            THROW 51000, 'STD must map all thirteen detailed expense tags.', 1;
        IF EXISTS (SELECT 1 FROM Cash.tbTaxTagMap WHERE TaxSourceCode = @Source
                   AND TagCode = 'consolidatedExpenses' AND IsEnabled = 1)
            THROW 51000, 'STD must not install a consolidated mapping.', 1;
        IF EXISTS (SELECT 1 FROM Cash.tbCode WHERE CashCode IN ('CC-DIRCT', 'CC-ADMIN') AND IsEnabled <> 0)
            THROW 51000, 'STD coarse posting codes must be disabled.', 1;
    END;

    IF (SELECT COUNT(*) FROM Cash.tbTaxTagMap WHERE TaxSourceCode = @Source
        AND TagCode IN ('turnover', 'otherBusinessIncome') AND IsEnabled = 1) <> 2
        THROW 51000, 'Both income Components must retain enabled mappings.', 1;

    DECLARE @PeriodStart DATE =
        (SELECT TOP (1) CAST(yp.StartOn AS DATE) FROM App.tbYearPeriod yp
         JOIN App.tbYear y ON y.YearNumber = yp.YearNumber AND y.CashStatusCode BETWEEN 1 AND 2
         WHERE EXISTS (SELECT 1 FROM App.tbYearPeriod nextPeriod WHERE nextPeriod.StartOn > yp.StartOn)
         ORDER BY yp.StartOn DESC);
    DECLARE @NextBoundary DATE =
        (SELECT MIN(CAST(StartOn AS DATE)) FROM App.tbYearPeriod WHERE StartOn > @PeriodStart);
    DECLARE @PeriodEnd DATE = DATEADD(DAY, -1, @NextBoundary);
    IF @PeriodStart IS NULL OR @NextBoundary IS NULL
        THROW 51000, 'Fixture needs an active configured period and a following period.', 1;

    DECLARE @IncomeCode NVARCHAR(50) =
        (SELECT TOP (1) CashCode FROM Cash.vwTaxTagCashCode
         WHERE TaxSourceCode = @Source AND TagCode = 'turnover');
    DECLARE @ExpenseTag NVARCHAR(64) = CASE WHEN @IsConsolidated = 1
        THEN 'consolidatedExpenses' ELSE 'costOfGoods' END;
    DECLARE @ExpenseCode NVARCHAR(50) =
        (SELECT TOP (1) CashCode FROM Cash.vwTaxTagCashCode
         WHERE TaxSourceCode = @Source AND TagCode = @ExpenseTag);

    IF NOT EXISTS (SELECT 1 FROM Cash.tbPeriod WHERE CashCode = @IncomeCode AND StartOn = @PeriodStart)
        INSERT INTO Cash.tbPeriod (CashCode, StartOn, InvoiceValue) VALUES (@IncomeCode, @PeriodStart, 0);
    IF NOT EXISTS (SELECT 1 FROM Cash.tbPeriod WHERE CashCode = @ExpenseCode AND StartOn = @PeriodStart)
        INSERT INTO Cash.tbPeriod (CashCode, StartOn, InvoiceValue) VALUES (@ExpenseCode, @PeriodStart, 0);

    UPDATE Cash.tbPeriod SET InvoiceValue = 100 WHERE CashCode = @IncomeCode AND StartOn = @PeriodStart;
    UPDATE Cash.tbPeriod SET InvoiceValue = 40 WHERE CashCode = @ExpenseCode AND StartOn = @PeriodStart;
    IF NOT EXISTS (SELECT 1 FROM Cash.fnTaxBizCumulative(@Source, @PeriodStart, @PeriodEnd)
                   WHERE TagCode = 'turnover' AND TradeControlAmount = 100 AND StatutoryAmount = 100)
        THROW 51000, 'Ordinary income polarity conversion failed.', 1;
    IF NOT EXISTS (SELECT 1 FROM Cash.fnTaxBizCumulative(@Source, @PeriodStart, @PeriodEnd)
                   WHERE TagCode = @ExpenseTag AND TradeControlAmount = -40 AND StatutoryAmount = 40)
        THROW 51000, 'Ordinary expense polarity conversion failed.', 1;

    UPDATE Cash.tbPeriod SET InvoiceValue = -10 WHERE CashCode = @ExpenseCode AND StartOn = @PeriodStart;
    IF NOT EXISTS (SELECT 1 FROM Cash.fnTaxBizCumulative(@Source, @PeriodStart, @PeriodEnd)
                   WHERE TagCode = @ExpenseTag AND TradeControlAmount = 10 AND StatutoryAmount = -10)
        THROW 51000, 'Expense credit/reversal polarity conversion failed.', 1;
    UPDATE Cash.tbPeriod SET InvoiceValue = -55 WHERE CashCode = @ExpenseCode AND StartOn = @PeriodStart;
    IF NOT EXISTS (SELECT 1 FROM Cash.fnTaxBizCumulative(@Source, @PeriodStart, @PeriodEnd)
                   WHERE TagCode = @ExpenseTag AND StatutoryAmount = -55)
        THROW 51000, 'Credits exceeding expenditure must remain negative statutory expense.', 1;

    UPDATE Cash.tbPeriod SET InvoiceValue = 0 WHERE CashCode = @ExpenseCode AND StartOn = @PeriodStart;
    IF NOT EXISTS (SELECT 1 FROM Cash.fnTaxBizCumulative(@Source, @PeriodStart, @PeriodEnd)
                   WHERE TagCode = @ExpenseTag AND SupportStatus = 'Supported' AND StatutoryAmount = 0)
        THROW 51000, 'A mapped genuine zero must remain supported.', 1;
    IF @IsConsolidated = 1 AND NOT EXISTS
        (SELECT 1 FROM Cash.fnTaxBizCumulative(@Source, @PeriodStart, @PeriodEnd)
         WHERE TagCode = 'costOfGoods' AND SupportStatus = 'Unsupported' AND StatutoryAmount IS NULL)
        THROW 51000, 'An unmapped concept must remain unsupported rather than zero.', 1;

    -- Parent/descendant overlap.
    INSERT INTO Cash.tbTaxTagMap VALUES (@Source, 'turnover', 0, 'CA-SALES', '', 1);
    IF NOT EXISTS (SELECT 1 FROM Cash.fnTaxTagMapValidate(@Source)
                   WHERE IsError = 1 AND Message LIKE N'%multiple times%')
        THROW 51000, 'Parent/descendant overlap was not detected.', 1;
    DELETE FROM Cash.tbTaxTagMap WHERE TaxSourceCode = @Source AND TagCode = 'turnover'
        AND MapTypeCode = 0 AND CategoryCode = 'CA-SALES';

    -- Cross-tag overlap.
    INSERT INTO Cash.tbTaxTagMap VALUES (@Source, 'otherBusinessIncome', 1, '', @IncomeCode, 1);
    IF NOT EXISTS
       (
           SELECT ec.CashCode
           FROM Cash.vwTaxTagCashCode ec
           WHERE ec.TaxSourceCode = @Source AND ec.CashCode = @IncomeCode
           GROUP BY ec.CashCode
           HAVING COUNT(DISTINCT ec.TagCode) > 1
       )
        THROW 51000, 'Cross-tag overlap was not detected.', 1;
    DELETE FROM Cash.tbTaxTagMap WHERE TaxSourceCode = @Source AND TagCode = 'otherBusinessIncome'
        AND MapTypeCode = 1 AND CashCode = @IncomeCode;

    -- Mixed/neutral polarity.
    DECLARE @IncomeCategory NVARCHAR(10) = (SELECT CategoryCode FROM Cash.tbCode WHERE CashCode = @IncomeCode);
    UPDATE Cash.tbCategory SET CashPolarityCode = 2 WHERE CategoryCode = @IncomeCategory;
    IF NOT EXISTS (SELECT 1 FROM Cash.fnTaxTagMapValidate(@Source)
                   WHERE IsError = 1 AND Message LIKE N'%polarity%')
        THROW 51000, 'Neutral contributor polarity was not detected.', 1;
    UPDATE Cash.tbCategory SET CashPolarityCode = 1 WHERE CategoryCode = @IncomeCategory;

    -- Consolidated and detailed patterns are mutually exclusive.
    IF @IsConsolidated = 1
        INSERT INTO Cash.tbTaxTagMap VALUES (@Source, 'costOfGoods', 0, 'CA-DIRECT', '', 1);
    ELSE
        INSERT INTO Cash.tbTaxTagMap VALUES (@Source, 'consolidatedExpenses', 0, 'CT-CUMEXP', '', 1);
    IF NOT EXISTS
       (
           SELECT 1
           FROM Cash.tbTaxTagMap consolidated
            JOIN Cash.tbTaxTagMap detailed
              ON detailed.TaxSourceCode = consolidated.TaxSourceCode
             AND detailed.TagCode IN ('costOfGoods', 'paymentsToSubcontractors', 'wagesAndStaffCosts',
                 'carVanTravelExpenses', 'premisesRunningCosts', 'maintenanceCosts', 'adminCosts',
                 'advertisingCosts', 'businessEntertainmentCosts', 'interestOnBankOtherLoans',
                'financeCharges', 'irrecoverableDebts', 'professionalFees', 'depreciation',
                'otherExpenses')
            AND detailed.IsEnabled = 1
           WHERE consolidated.TaxSourceCode = @Source
             AND consolidated.TagCode = 'consolidatedExpenses'
             AND consolidated.IsEnabled = 1
       )
        THROW 51000, 'Consolidated/detailed coexistence was not detected.', 1;
    DELETE FROM Cash.tbTaxTagMap WHERE TaxSourceCode = @Source
        AND ((@IsConsolidated = 1 AND TagCode = 'costOfGoods' AND CategoryCode = 'CA-DIRECT')
          OR (@IsConsolidated = 0 AND TagCode = 'consolidatedExpenses' AND CategoryCode = 'CT-CUMEXP'));

    -- Supplied dates are workflow context; only chronological ordering is generic here.
    DECLARE @ArbitraryStart DATE = DATEADD(DAY, 1, @PeriodStart);
    DECLARE @ArbitraryEnd DATE = DATEADD(DAY, -1, @PeriodEnd);
    IF NOT EXISTS (SELECT 1 FROM Cash.fnTaxBizCumulative(@Source, @ArbitraryStart, @ArbitraryEnd)
                   WHERE ValidationStatus = 'Ready')
        THROW 51000, 'An arbitrary chronological supplied date range must be accepted.', 1;
    IF NOT EXISTS (SELECT 1 FROM Cash.fnTaxBizCumulative(@Source, @ArbitraryEnd, @ArbitraryStart)
                   WHERE ValidationStatus = 'Invalid')
        THROW 51000, 'A reversed supplied date range must be rejected.', 1;

    -- Customised trees are assessed by effective mapping, not bootstrap root identity.
    DELETE FROM Cash.tbTaxTagMap WHERE TaxSourceCode = @Source AND TagCode = 'turnover';
    INSERT INTO Cash.tbTaxTagMap VALUES (@Source, 'turnover', 0, @IncomeCategory, '', 1);
    IF EXISTS (SELECT 1 FROM Cash.fnTaxTagMapValidate(@Source) WHERE IsError = 1)
        THROW 51000, 'A valid customised effective mapping should remain submission-capable.', 1;
    DELETE FROM Cash.tbTaxTagMap WHERE TaxSourceCode = @Source AND TagCode = 'turnover';
    IF EXISTS (SELECT 1 FROM Cash.tbTaxTagMap
               WHERE TaxSourceCode = @Source AND TagCode = 'turnover' AND IsEnabled = 1)
        THROW 51000, 'An incomplete customised mapping should not be submission-capable.', 1;

    ROLLBACK TRAN Phase4DCumulativeFixture;
    PRINT 'Phase 4D cumulative projection fixture passed.';
END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0 ROLLBACK TRAN Phase4DCumulativeFixture;
    THROW;
END CATCH;
