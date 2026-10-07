/*
    STD synthetic company: controlled additive Year 3 Category Tree evolution.

    Purpose
    -------
    Exercise a realistic, additive classification change at the boundary of the
    third completed accounting year without retrospectively changing Year 1 or
    Year 2. This is test evidence for the Companies House four-case programme;
    it is not the future production Category Tree change-control implementation.

    Public evidence dossier
    -----------------------
    https://github.com/TradeControl/tradecontrol.web/blob/master/docs/projects/Tax%20Hub/companies-house-approval/companies-house-test-submission-evidence.md

    Safety
    ------
    The script is dry-run by default. Set @ApplyChanges = 1 only for the intended
    synthetic STD database after the rolled-back rehearsal has passed.

    The script is rerunnable and fail-closed. Existing definitions must match
    exactly; it never updates or deletes an existing Category, Cash Code or edge.
*/
SET NOCOUNT, XACT_ABORT ON;

DECLARE
    @ApplyChanges bit = 0,
    @TaxSourceCode nvarchar(50) = N'UK-CO-ACCTS-2026',
    @Tolerance decimal(18, 5) = 0.10;

DECLARE @CompletedYears TABLE
(
    SequenceNumber int NOT NULL PRIMARY KEY,
    YearNumber smallint NOT NULL,
    PeriodStart date NOT NULL,
    PeriodEnd date NOT NULL
);

INSERT INTO @CompletedYears (SequenceNumber, YearNumber, PeriodStart, PeriodEnd)
SELECT
    ROW_NUMBER() OVER (ORDER BY y.YearNumber),
    y.YearNumber,
    MIN(CONVERT(date, yp.StartOn)),
    EOMONTH(MAX(CONVERT(date, yp.StartOn)))
FROM App.tbYear y
JOIN App.tbYearPeriod yp ON yp.YearNumber = y.YearNumber
WHERE y.CashStatusCode = 2
GROUP BY y.YearNumber;

IF (SELECT COUNT(*) FROM @CompletedYears) <> 3
    THROW 51970, 'Year 3 additive exercise requires exactly three completed accounting years.', 1;

IF EXISTS
(
    SELECT 1
    FROM @CompletedYears current_year
    JOIN @CompletedYears prior_year
      ON prior_year.SequenceNumber = current_year.SequenceNumber - 1
    WHERE current_year.YearNumber <> prior_year.YearNumber + 1
       OR current_year.PeriodStart <> DATEADD(day, 1, prior_year.PeriodEnd)
)
    THROW 51971, 'Year 3 additive exercise requires three consecutive completed accounting years.', 1;

DECLARE
    @Year3Start date = (SELECT PeriodStart FROM @CompletedYears WHERE SequenceNumber = 3),
    @Year3End date = (SELECT PeriodEnd FROM @CompletedYears WHERE SequenceNumber = 3),
    @UserId nvarchar(10) = (SELECT TOP (1) UserId FROM Usr.vwCredentials),
    @PlantAccountCode nvarchar(10) =
    (
        SELECT TOP (1) AccountCode
        FROM Subject.tbAccount
        WHERE AccountTypeCode = 2
          AND AccountClosed = 0
          AND CashCode = N'CC-DEPPL'
        ORDER BY AccountCode
    );

IF @UserId IS NULL
    THROW 51972, 'Year 3 additive exercise could not resolve the current node user.', 1;

IF @PlantAccountCode IS NULL
    THROW 51973, 'Year 3 additive exercise requires the open Plant & Tools capital account.', 1;

IF NOT EXISTS (SELECT 1 FROM Object.tbObject WHERE ObjectCode = N'PROJECT')
    THROW 51974, 'Year 3 additive exercise requires the standard PROJECT object.', 1;

IF EXISTS
(
    SELECT required.SubjectCode
    FROM (VALUES
        (N'DatasetOnlineCustomer'),
        (N'DatasetEnergySupplier'),
        (N'DatasetPrinter'),
        (N'HOME')
    ) required(SubjectCode)
    WHERE NOT EXISTS
        (SELECT 1 FROM Subject.tbSubject actual WHERE actual.SubjectCode = required.SubjectCode)
)
    THROW 51975, 'Year 3 additive exercise requires the standard synthetic subjects.', 1;

SELECT
    completed.SequenceNumber,
    projection.TaxSourceCode,
    projection.AsOfDate,
    projection.PeriodStart,
    projection.ValidationStatus,
    projection.TagCode,
    projection.ValueState,
    projection.SupportStatus,
    projection.StatutoryAmount
INTO #HistoricalFactsBefore
FROM @CompletedYears completed
CROSS APPLY Cash.fnTaxBizBalanceSheetUK(@TaxSourceCode, completed.PeriodEnd) projection
WHERE completed.SequenceNumber IN (1, 2);

SELECT
    completed.SequenceNumber,
    bridge.YearNumber,
    bridge.OpeningCapital,
    bridge.ClosingCapital,
    bridge.Profit,
    bridge.BusinessTax,
    bridge.ProfitAfterTax,
    bridge.CapitalMovement,
    bridge.CapitalDelta,
    bridge.Variance
INTO #HistoricalBridgeBefore
FROM @CompletedYears completed
JOIN Cash.vwEquityReconciliationByYear bridge ON bridge.YearNumber = completed.YearNumber
WHERE completed.SequenceNumber IN (1, 2);

BEGIN TRY
    BEGIN TRANSACTION;

    DECLARE @CategorySeed TABLE
    (
        CategoryCode nvarchar(10) NOT NULL PRIMARY KEY,
        Category nvarchar(50) NOT NULL,
        CategoryTypeCode smallint NOT NULL,
        CashPolarityCode smallint NOT NULL,
        CashTypeCode smallint NOT NULL,
        DisplayOrder smallint NOT NULL,
        IsEnabled smallint NOT NULL
    );

    INSERT INTO @CategorySeed
        (CategoryCode, Category, CategoryTypeCode, CashPolarityCode, CashTypeCode,
         DisplayOrder, IsEnabled)
    VALUES
        (N'CA-DIGSV', N'Digital Services',      0, 1, 0, 25, 1),
        (N'CA-CLOUD', N'Cloud Infrastructure',  0, 0, 0, 45, 1),
        (N'CA-AUTO',  N'Automation Equipment',  0, 0, 0, 55, 1);

    DECLARE @EdgeSeed TABLE
    (
        ParentCode nvarchar(10) NOT NULL,
        ChildCode nvarchar(10) NOT NULL,
        DisplayOrder smallint NOT NULL,
        PRIMARY KEY (ParentCode, ChildCode)
    );

    INSERT INTO @EdgeSeed (ParentCode, ChildCode, DisplayOrder)
    VALUES
        (N'CT-TURNOV', N'CA-DIGSV', 25),
        (N'CT-VAT',    N'CA-DIGSV', 25),
        (N'CT-OVERHD', N'CA-CLOUD', 45),
        (N'CT-OVERHD', N'CA-AUTO',  55);

    IF EXISTS
    (
        SELECT 1
        FROM @CategorySeed expected
        JOIN Cash.tbCategory actual ON actual.CategoryCode = expected.CategoryCode
        WHERE actual.Category <> expected.Category
           OR actual.CategoryTypeCode <> expected.CategoryTypeCode
           OR ISNULL(actual.CashPolarityCode, -1) <> expected.CashPolarityCode
           OR ISNULL(actual.CashTypeCode, -1) <> expected.CashTypeCode
           OR actual.DisplayOrder <> expected.DisplayOrder
           OR actual.IsEnabled <> expected.IsEnabled
    )
        THROW 51976, 'An existing Year 3 Category does not match the approved additive definition.', 1;

    IF EXISTS
    (
        SELECT 1
        FROM @EdgeSeed expected
        WHERE NOT EXISTS
            (SELECT 1 FROM Cash.tbCategory parent WHERE parent.CategoryCode = expected.ParentCode AND parent.CategoryTypeCode = 1)
    )
        THROW 51977, 'An approved parent total is missing or is not a total Category.', 1;

    INSERT INTO Cash.tbCategory
        (CategoryCode, Category, CategoryTypeCode, CashPolarityCode, CashTypeCode, DisplayOrder, IsEnabled)
    SELECT
        expected.CategoryCode,
        expected.Category,
        expected.CategoryTypeCode,
        expected.CashPolarityCode,
        expected.CashTypeCode,
        expected.DisplayOrder,
        expected.IsEnabled
    FROM @CategorySeed expected
    WHERE NOT EXISTS
        (SELECT 1 FROM Cash.tbCategory actual WHERE actual.CategoryCode = expected.CategoryCode);

    IF EXISTS
    (
        SELECT 1
        FROM Cash.tbCategoryTotal actual
        JOIN @CategorySeed category ON category.CategoryCode = actual.ChildCode
        LEFT JOIN @EdgeSeed expected
          ON expected.ParentCode = actual.ParentCode
         AND expected.ChildCode = actual.ChildCode
        WHERE expected.ChildCode IS NULL
           OR actual.DisplayOrder <> expected.DisplayOrder
    )
        THROW 51978, 'An existing Year 3 Category edge does not match the approved additive definition.', 1;

    INSERT INTO Cash.tbCategoryTotal (ParentCode, ChildCode, DisplayOrder)
    SELECT expected.ParentCode, expected.ChildCode, expected.DisplayOrder
    FROM @EdgeSeed expected
    WHERE NOT EXISTS
    (
        SELECT 1
        FROM Cash.tbCategoryTotal actual
        WHERE actual.ParentCode = expected.ParentCode
          AND actual.ChildCode = expected.ChildCode
    );

    DECLARE @CashCodeSeed TABLE
    (
        CashCode nvarchar(50) NOT NULL PRIMARY KEY,
        CashDescription nvarchar(100) NOT NULL,
        CategoryCode nvarchar(10) NOT NULL,
        TaxCode nvarchar(10) NOT NULL,
        IsEnabled smallint NOT NULL
    );

    INSERT INTO @CashCodeSeed (CashCode, CashDescription, CategoryCode, TaxCode, IsEnabled)
    VALUES
        (N'CC-DIGSV', N'Digital Services',     N'CA-DIGSV', N'T1', 1),
        (N'CC-CLOUD', N'Cloud Infrastructure', N'CA-CLOUD', N'T1', 1),
        (N'CC-AUTO',  N'Automation Equipment', N'CA-AUTO',  N'T1', 1);

    IF EXISTS
    (
        SELECT 1
        FROM @CashCodeSeed expected
        JOIN Cash.tbCode actual ON actual.CashCode = expected.CashCode
        WHERE actual.CashDescription <> expected.CashDescription
           OR actual.CategoryCode <> expected.CategoryCode
           OR actual.TaxCode <> expected.TaxCode
           OR actual.IsEnabled <> expected.IsEnabled
    )
        THROW 51979, 'An existing Year 3 Cash Code does not match the approved additive definition.', 1;

    INSERT INTO Cash.tbCode (CashCode, CashDescription, CategoryCode, TaxCode, IsEnabled)
    SELECT expected.CashCode, expected.CashDescription, expected.CategoryCode, expected.TaxCode, expected.IsEnabled
    FROM @CashCodeSeed expected
    WHERE NOT EXISTS
        (SELECT 1 FROM Cash.tbCode actual WHERE actual.CashCode = expected.CashCode);

    DECLARE @ProjectSeed TABLE
    (
        ProjectTitle nvarchar(100) NOT NULL PRIMARY KEY,
        SubjectCode nvarchar(50) NOT NULL,
        ActionOn date NOT NULL,
        CashCode nvarchar(50) NOT NULL,
        UnitCharge decimal(18, 7) NOT NULL
    );

    INSERT INTO @ProjectSeed (ProjectTitle, SubjectCode, ActionOn, CashCode, UnitCharge)
    VALUES
        (N'Year 3 digital service engagement', N'DatasetOnlineCustomer', DATEADD(day, 45,  @Year3Start), N'CC-DIGSV', 12000.0000000),
        (N'Year 3 cloud infrastructure',       N'DatasetEnergySupplier', DATEADD(day, 105, @Year3Start), N'CC-CLOUD',  3600.0000000),
        (N'Year 3 automation equipment',       N'DatasetPrinter',        DATEADD(day, 165, @Year3Start), N'CC-AUTO',   6000.0000000);

    IF EXISTS
    (
        SELECT 1
        FROM @ProjectSeed expected
        JOIN Project.tbProject actual ON actual.ProjectTitle = expected.ProjectTitle
        WHERE actual.SubjectCode <> expected.SubjectCode
           OR CONVERT(date, actual.ActionOn) <> expected.ActionOn
           OR actual.ObjectCode <> N'PROJECT'
           OR actual.CashCode <> expected.CashCode
           OR actual.TaxCode <> N'T1'
           OR actual.Quantity <> 1
           OR actual.UnitCharge <> expected.UnitCharge
    )
        THROW 51980, 'An existing Year 3 Project does not match the approved additive definition.', 1;

    DECLARE
        @ProjectTitle nvarchar(100),
        @SubjectCode nvarchar(50),
        @ActionOn date,
        @CashCode nvarchar(50),
        @UnitCharge decimal(18, 7),
        @ProjectCode nvarchar(20),
        @PaymentCode nvarchar(20);

    DECLARE project_cursor CURSOR LOCAL FAST_FORWARD FOR
        SELECT ProjectTitle, SubjectCode, ActionOn, CashCode, UnitCharge
        FROM @ProjectSeed
        ORDER BY ActionOn;

    OPEN project_cursor;
    FETCH NEXT FROM project_cursor INTO @ProjectTitle, @SubjectCode, @ActionOn, @CashCode, @UnitCharge;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        IF NOT EXISTS (SELECT 1 FROM Project.tbProject WHERE ProjectTitle = @ProjectTitle)
        BEGIN
            SET @ProjectCode = NULL;
            EXEC Project.proc_NextCode @ObjectCode = N'PROJECT', @ProjectCode = @ProjectCode OUTPUT;

            IF @ProjectCode IS NULL
                THROW 51981, 'Project.proc_NextCode returned NULL during the Year 3 additive exercise.', 1;

            INSERT INTO Project.tbProject
            (
                ProjectCode, UserId, SubjectCode, ProjectTitle, ObjectCode,
                ProjectStatusCode, ActionById, ActionOn, Quantity,
                CashCode, TaxCode, UnitCharge, TotalCharge
            )
            VALUES
            (
                @ProjectCode, @UserId, @SubjectCode, @ProjectTitle, N'PROJECT',
                0, @UserId, @ActionOn, 1,
                @CashCode, N'T1', @UnitCharge, 0
            );

            SET @PaymentCode = NULL;
            EXEC Project.proc_Pay
                @ProjectCode = @ProjectCode,
                @Post = 1,
                @PaymentCode = @PaymentCode OUTPUT;

            IF @PaymentCode IS NULL
                THROW 51982, 'Project.proc_Pay did not produce a payment during the Year 3 additive exercise.', 1;
        END

        FETCH NEXT FROM project_cursor INTO @ProjectTitle, @SubjectCode, @ActionOn, @CashCode, @UnitCharge;
    END

    CLOSE project_cursor;
    DEALLOCATE project_cursor;

    DECLARE @AutomationPurchaseOn date = DATEADD(day, 195, @Year3Start);

    IF NOT EXISTS
    (
        SELECT 1
        FROM Cash.tbPayment
        WHERE SubjectCode = N'HOME'
          AND AccountCode = @PlantAccountCode
          AND CashCode = N'CC-DEPPL'
          AND PaymentReference = N'Year 3 automation equipment (Capitalised)'
          AND CONVERT(date, PaidOn) = @AutomationPurchaseOn
    )
    BEGIN
        SET @PaymentCode = NULL;
        EXEC Cash.proc_NextPaymentCode @PaymentCode = @PaymentCode OUTPUT;

        INSERT INTO Cash.tbPayment
        (
            PaymentCode, UserId, PaymentStatusCode, SubjectCode, AccountCode,
            CashCode, TaxCode, PaidOn, PaidInValue, PaidOutValue, PaymentReference
        )
        VALUES
        (
            @PaymentCode, @UserId, 1, N'HOME', @PlantAccountCode,
            N'CC-DEPPL', N'N/A', @AutomationPurchaseOn, 6000.00000, 0.00000,
            N'Year 3 automation equipment (Capitalised)'
        );
    END

    IF NOT EXISTS
    (
        SELECT 1
        FROM Cash.tbPayment
        WHERE SubjectCode = N'HOME'
          AND AccountCode = @PlantAccountCode
          AND CashCode = N'CC-DEPPL'
          AND PaymentReference = N'Depreciation - Year 3 automation equipment'
          AND CONVERT(date, PaidOn) = @Year3End
    )
    BEGIN
        SET @PaymentCode = NULL;
        EXEC Cash.proc_NextPaymentCode @PaymentCode = @PaymentCode OUTPUT;

        INSERT INTO Cash.tbPayment
        (
            PaymentCode, UserId, PaymentStatusCode, SubjectCode, AccountCode,
            CashCode, TaxCode, PaidOn, PaidInValue, PaidOutValue, PaymentReference
        )
        VALUES
        (
            @PaymentCode, @UserId, 1, N'HOME', @PlantAccountCode,
            N'CC-DEPPL', N'N/A', @Year3End, 0.00000, 1200.00000,
            N'Depreciation - Year 3 automation equipment'
        );
    END

    EXEC App.proc_SystemRebuild;

    IF EXISTS
    (
        SELECT 1
        FROM Cash.tbPayment
        WHERE CashCode IN (N'CC-DIGSV', N'CC-CLOUD', N'CC-AUTO')
          AND CONVERT(date, PaidOn) NOT BETWEEN @Year3Start AND @Year3End
    )
        THROW 51983, 'A new Year 3 Cash Code has activity outside the third accounting year.', 1;

    IF EXISTS
    (
        SELECT required.CashCode
        FROM @CashCodeSeed required
        WHERE NOT EXISTS
        (
            SELECT 1
            FROM Cash.tbPayment payment
            WHERE payment.CashCode = required.CashCode
              AND CONVERT(date, payment.PaidOn) BETWEEN @Year3Start AND @Year3End
        )
    )
        THROW 51984, 'A new Year 3 Cash Code was not exercised by a payment.', 1;

    SELECT
        completed.SequenceNumber,
        projection.TaxSourceCode,
        projection.AsOfDate,
        projection.PeriodStart,
        projection.ValidationStatus,
        projection.TagCode,
        projection.ValueState,
        projection.SupportStatus,
        projection.StatutoryAmount
    INTO #HistoricalFactsAfter
    FROM @CompletedYears completed
    CROSS APPLY Cash.fnTaxBizBalanceSheetUK(@TaxSourceCode, completed.PeriodEnd) projection
    WHERE completed.SequenceNumber IN (1, 2);

    IF EXISTS
    (
        SELECT * FROM #HistoricalFactsBefore
        EXCEPT
        SELECT * FROM #HistoricalFactsAfter
    )
    OR EXISTS
    (
        SELECT * FROM #HistoricalFactsAfter
        EXCEPT
        SELECT * FROM #HistoricalFactsBefore
    )
        THROW 51985, 'Year 1 or Year 2 canonical statutory facts changed during the additive evolution.', 1;

    SELECT
        completed.SequenceNumber,
        bridge.YearNumber,
        bridge.OpeningCapital,
        bridge.ClosingCapital,
        bridge.Profit,
        bridge.BusinessTax,
        bridge.ProfitAfterTax,
        bridge.CapitalMovement,
        bridge.CapitalDelta,
        bridge.Variance
    INTO #HistoricalBridgeAfter
    FROM @CompletedYears completed
    JOIN Cash.vwEquityReconciliationByYear bridge ON bridge.YearNumber = completed.YearNumber
    WHERE completed.SequenceNumber IN (1, 2);

    IF EXISTS
    (
        SELECT * FROM #HistoricalBridgeBefore
        EXCEPT
        SELECT * FROM #HistoricalBridgeAfter
    )
    OR EXISTS
    (
        SELECT * FROM #HistoricalBridgeAfter
        EXCEPT
        SELECT * FROM #HistoricalBridgeBefore
    )
        THROW 51986, 'Year 1 or Year 2 Equity Bridge changed during the additive evolution.', 1;

    IF EXISTS
    (
        SELECT 1
        FROM @CompletedYears completed
        JOIN Cash.vwEquityReconciliationByYear bridge ON bridge.YearNumber = completed.YearNumber
        WHERE ABS(bridge.Variance) > @Tolerance
    )
    BEGIN
        SELECT
            completed.SequenceNumber,
            completed.YearNumber,
            bridge.OpeningCapital,
            bridge.ClosingCapital,
            bridge.Profit,
            bridge.BusinessTax,
            bridge.ProfitAfterTax,
            bridge.CapitalMovement,
            bridge.CapitalDelta,
            bridge.Variance
        FROM @CompletedYears completed
        JOIN Cash.vwEquityReconciliationByYear bridge ON bridge.YearNumber = completed.YearNumber
        ORDER BY completed.SequenceNumber;

        THROW 51987, 'A completed-year Equity Bridge exceeds tolerance after the additive evolution.', 1;
    END

    IF EXISTS
    (
        SELECT 1
        FROM @CompletedYears completed
        CROSS APPLY Cash.fnTaxBizBalanceSheetUK(@TaxSourceCode, completed.PeriodEnd) projection
        WHERE projection.ValidationStatus <> N'Ready'
    )
        THROW 51988, 'A completed-year statutory projection is not Ready after the additive evolution.', 1;

    SELECT
        RunMode = CASE @ApplyChanges WHEN 1 THEN N'APPLY' ELSE N'DRY RUN - ROLLBACK' END,
        HistoricalStatutoryFactsPreserved = CONVERT(bit, 1),
        HistoricalEquityBridgesPreserved = CONVERT(bit, 1),
        @Year3Start AS Year3Start,
        @Year3End AS Year3End;

    SELECT
        category.CategoryCode,
        category.Category,
        category.CategoryTypeCode,
        category.CashPolarityCode,
        category.CashTypeCode,
        edge.ParentCode,
        code.CashCode,
        code.CashDescription,
        code.TaxCode
    FROM @CategorySeed expected
    JOIN Cash.tbCategory category ON category.CategoryCode = expected.CategoryCode
    JOIN Cash.tbCategoryTotal edge ON edge.ChildCode = category.CategoryCode
    JOIN Cash.tbCode code ON code.CategoryCode = category.CategoryCode
    ORDER BY category.CategoryCode;

    SELECT
        completed.SequenceNumber,
        completed.YearNumber,
        completed.PeriodStart,
        completed.PeriodEnd,
        bridge.OpeningCapital,
        bridge.ClosingCapital,
        bridge.Profit,
        bridge.BusinessTax,
        bridge.ProfitAfterTax,
        bridge.CapitalMovement,
        bridge.CapitalDelta,
        bridge.Variance,
        Projects = (SELECT COUNT(*) FROM Project.tbProject project
            WHERE project.ActionOn BETWEEN completed.PeriodStart AND completed.PeriodEnd),
        Invoices = (SELECT COUNT(*) FROM Invoice.tbInvoice invoice
            WHERE invoice.InvoicedOn BETWEEN completed.PeriodStart AND completed.PeriodEnd),
        Payments = (SELECT COUNT(*) FROM Cash.tbPayment payment
            WHERE payment.PaidOn BETWEEN completed.PeriodStart AND completed.PeriodEnd)
    FROM @CompletedYears completed
    JOIN Cash.vwEquityReconciliationByYear bridge ON bridge.YearNumber = completed.YearNumber
    ORDER BY completed.SequenceNumber;

    SELECT
        projection.TagCode,
        projection.ValidationStatus,
        projection.ValueState,
        projection.SupportStatus,
        projection.StatutoryAmount
    FROM Cash.fnTaxBizBalanceSheetUK(@TaxSourceCode, @Year3End) projection
    ORDER BY projection.TagCode;

    IF @ApplyChanges = 1
        COMMIT TRANSACTION;
    ELSE
        ROLLBACK TRANSACTION;
END TRY
BEGIN CATCH
    IF CURSOR_STATUS('local', 'project_cursor') >= 0
        CLOSE project_cursor;
    IF CURSOR_STATUS('local', 'project_cursor') > -3
        DEALLOCATE project_cursor;
    IF XACT_STATE() <> 0
        ROLLBACK TRANSACTION;
    THROW;
END CATCH;
