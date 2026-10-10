SET NOCOUNT, XACT_ABORT ON;

BEGIN TRAN SubjectAgedBalancesTest;
BEGIN TRY
    DECLARE @AgedOn date = '2026-01-31';
    DECLARE @SubjectTypeCode smallint =
    (
        SELECT TOP (1) SubjectTypeCode
        FROM Subject.tbType
        WHERE SubjectClassCode <> 2
        ORDER BY SubjectTypeCode
    );
    DECLARE @UserId nvarchar(10) = (SELECT TOP (1) UserId FROM Usr.tbUser ORDER BY UserId);
    DECLARE @AccountCode nvarchar(10) =
    (
        SELECT TOP (1) AccountCode
        FROM Subject.tbAccount
        WHERE AccountTypeCode < 2
        ORDER BY AccountCode
    );

    IF @SubjectTypeCode IS NULL OR @UserId IS NULL OR @AccountCode IS NULL
        THROW 51050, 'The aged-balance fixture prerequisites are unavailable.', 1;

    INSERT Subject.tbSubject
    (
        SubjectCode,
        SubjectName,
        SubjectTypeCode,
        OpeningBalance,
        InsertedOn
    )
    VALUES
        (N'AgeTestBands', N'Aged invoice band fixture', @SubjectTypeCode, 0, '2025-01-01'),
        (N'AgeTestCredit', N'Aged invoice credit fixture', @SubjectTypeCode, 0, '2025-01-01'),
        (N'AgeTestPurchase', N'Aged invoice purchase fixture', @SubjectTypeCode, 0, '2025-01-01'),
        (N'AgeTestPayment', N'Aged invoice payment fixture', @SubjectTypeCode, 0, '2025-01-01'),
        (N'AgeTestOpening', N'Aged invoice opening fixture', @SubjectTypeCode, -5, '2025-01-01'),
        (N'AgeTestHistorical', N'Dated balance polarity fixture', @SubjectTypeCode, 0, '2025-01-01'),
        (N'AgeTestZero', N'Aged invoice zero fixture', @SubjectTypeCode, 0, '2025-01-01'),
        (N'AgeTestParentA', N'Aged invoice parent A', @SubjectTypeCode, 0, '2025-01-01'),
        (N'AgeTestParentB', N'Aged invoice parent B', @SubjectTypeCode, 0, '2025-01-01');

    INSERT Invoice.tbInvoice
    (
        InvoiceNumber,
        UserId,
        SubjectCode,
        InvoiceTypeCode,
        InvoiceStatusCode,
        InvoicedOn,
        DueOn,
        ExpectedOn,
        InvoiceValue,
        TaxValue,
        PaidValue,
        PaidTaxValue
    )
    VALUES
        (N'AGE-BAND-0', @UserId, N'AgeTestBands', 0, 1, '2026-01-01', @AgedOn, @AgedOn, 10, 0, 0, 0),
        (N'AGE-BAND-1', @UserId, N'AgeTestBands', 0, 1, '2025-12-01', DATEADD(DAY, -1, @AgedOn), DATEADD(DAY, -1, @AgedOn), 10, 0, 0, 0),
        (N'AGE-BAND-31', @UserId, N'AgeTestBands', 0, 1, '2025-11-01', DATEADD(DAY, -31, @AgedOn), DATEADD(DAY, -31, @AgedOn), 10, 0, 0, 0),
        (N'AGE-BAND-61', @UserId, N'AgeTestBands', 0, 1, '2025-10-01', DATEADD(DAY, -61, @AgedOn), DATEADD(DAY, -61, @AgedOn), 10, 0, 0, 0),
        (N'AGE-BAND-91', @UserId, N'AgeTestBands', 0, 1, '2025-09-01', DATEADD(DAY, -91, @AgedOn), DATEADD(DAY, -91, @AgedOn), 10, 0, 0, 0),
        (N'AGE-CREDIT-SALE', @UserId, N'AgeTestCredit', 0, 1, '2026-01-01', @AgedOn, @AgedOn, 100, 0, 0, 0),
        (N'AGE-CREDIT-NOTE', @UserId, N'AgeTestCredit', 1, 1, '2026-01-02', @AgedOn, @AgedOn, 25, 0, 0, 0),
        (N'AGE-PURCHASE', @UserId, N'AgeTestPurchase', 2, 1, '2026-01-01', @AgedOn, @AgedOn, 70, 0, 0, 0),
        (N'AGE-PAY-SALE', @UserId, N'AgeTestPayment', 0, 2, '2026-01-01', '2026-01-15', '2026-01-15', 20, 0, 5, 0),
        (N'AGE-OPEN-SALE', @UserId, N'AgeTestOpening', 0, 1, '2026-01-01', '2026-01-15', '2026-01-15', 20, 0, 0, 0),
        (N'AGE-HIST-SALE', @UserId, N'AgeTestHistorical', 0, 1, '2026-01-01', '2026-01-31', '2026-01-31', 100, 0, 0, 0),
        (N'AGE-HIST-CREDIT', @UserId, N'AgeTestHistorical', 1, 1, '2026-02-01', '2026-02-01', '2026-02-01', 150, 0, 0, 0),
        (N'AGE-ZERO-SALE', @UserId, N'AgeTestZero', 0, 1, '2026-01-01', '2026-01-15', '2026-01-15', 25, 0, 0, 0),
        (N'AGE-ZERO-CREDIT', @UserId, N'AgeTestZero', 1, 1, '2026-01-02', '2026-01-15', '2026-01-15', 25, 0, 0, 0);

    -- Sales invoice insertion derives contractual dates. Restore the exact
    -- boundary dates required by this fixture after the trigger has run.
    UPDATE Invoice.tbInvoice
    SET DueOn = CASE InvoiceNumber
        WHEN N'AGE-BAND-0' THEN @AgedOn
        WHEN N'AGE-BAND-1' THEN DATEADD(DAY, -1, @AgedOn)
        WHEN N'AGE-BAND-31' THEN DATEADD(DAY, -31, @AgedOn)
        WHEN N'AGE-BAND-61' THEN DATEADD(DAY, -61, @AgedOn)
        WHEN N'AGE-BAND-91' THEN DATEADD(DAY, -91, @AgedOn)
        ELSE DueOn
    END
    WHERE InvoiceNumber LIKE N'AGE-BAND-%';

    UPDATE Invoice.tbInvoice
    SET DueOn = @AgedOn
    WHERE InvoiceNumber IN (N'AGE-CREDIT-SALE', N'AGE-CREDIT-NOTE');

    INSERT Cash.tbPayment
    (
        PaymentCode,
        UserId,
        PaymentStatusCode,
        SubjectCode,
        AccountCode,
        PaidOn,
        PaidInValue,
        PaidOutValue
    )
    VALUES
        (N'AGE-PAYMENT', @UserId, 1, N'AgeTestPayment', @AccountCode, '2026-01-20', 5, 0);

    -- Namespace paths are navigation context and must not duplicate accounting rows.
    INSERT Subject.tbNamespace (ParentSubjectCode, ChildSubjectCode, Ordinal, IsDefault)
    VALUES
        (N'AgeTestParentA', N'AgeTestBands', 0, 1),
        (N'AgeTestParentB', N'AgeTestBands', 0, 1);

    IF NOT EXISTS
    (
        SELECT 1
        FROM Subject.fnCurrentAgedInvoices(@AgedOn)
        WHERE SubjectCode = N'AgeTestBands'
          AND BusinessBalance = 50
          AND PositionCode = 0
          AND CurrentAmount = 10
          AND Days1To30Amount = 10
          AND Days31To60Amount = 10
          AND Days61To90Amount = 10
          AND Over90Amount = 10
          AND ReconciliationResidual = 0
    )
        THROW 51051, 'Current invoice due-date bands or debt orientation changed.', 1;

    IF (SELECT COUNT(*) FROM Subject.fnCurrentAgedInvoices(@AgedOn) WHERE SubjectCode = N'AgeTestBands') <> 1
        THROW 51052, 'A multi-parent Subject was counted more than once.', 1;

    IF EXISTS (SELECT 1 FROM Subject.fnCurrentAgedInvoices(@AgedOn) WHERE SubjectCode = N'AgeTestZero')
        THROW 51053, 'A zero-net current invoice position remained in an aged population.', 1;

    IF NOT EXISTS
    (
        SELECT 1
        FROM Subject.fnCurrentAgedInvoices(@AgedOn)
        WHERE SubjectCode = N'AgeTestCredit'
          AND BusinessBalance = 75
          AND PositionCode = 0
          AND CurrentAmount = 75
          AND ReconciliationResidual = 0
    )
        THROW 51054, 'A current credit note did not reduce aged debt.', 1;

    IF NOT EXISTS
    (
        SELECT 1
        FROM Subject.fnCurrentAgedInvoices(@AgedOn)
        WHERE SubjectCode = N'AgeTestPurchase'
          AND BusinessBalance = -70
          AND PositionCode = 1
          AND CurrentAmount = 70
          AND ReconciliationResidual = 0
    )
        THROW 51055, 'A current purchase invoice did not produce an aged liability.', 1;

    IF NOT EXISTS
    (
        SELECT 1
        FROM Subject.fnCurrentAgedInvoices(@AgedOn)
        WHERE SubjectCode = N'AgeTestPayment'
          AND BusinessBalance = 15
          AND StatementBusinessBalance = 15
          AND ReconciliationResidual = 0
    )
        THROW 51056, 'Current paid values and the posted payment do not reconcile.', 1;

    IF NOT EXISTS
    (
        SELECT 1
        FROM Subject.fnCurrentAgedInvoices(@AgedOn)
        WHERE SubjectCode = N'AgeTestOpening'
          AND BusinessBalance = 20
          AND StatementBusinessBalance = 25
          AND ReconciliationResidual = 5
    )
        THROW 51057, 'The brought-forward statement residual was hidden inside invoice ageing.', 1;

    IF EXISTS
    (
        SELECT 1
        FROM Subject.fnCurrentInvoiceReconciliation()
        WHERE SubjectCode LIKE N'AgeTest%'
          AND StatementBusinessBalance <> OpenInvoiceBusinessBalance + ReconciliationResidual
    )
        THROW 51058, 'Current invoice reconciliation does not equal the current statement.', 1;

    IF NOT EXISTS
    (
        SELECT 1
        FROM Subject.fnDatedBalances('2026-01-31')
        WHERE SubjectCode = N'AgeTestHistorical'
          AND NativeStatementBalance = -100
          AND BusinessBalance = 100
          AND PositionCode = 0
    )
    OR NOT EXISTS
    (
        SELECT 1
        FROM Subject.fnDatedBalances('2026-02-28')
        WHERE SubjectCode = N'AgeTestHistorical'
          AND NativeStatementBalance = 50
          AND BusinessBalance = -50
          AND PositionCode = 1
    )
        THROW 51059, 'The historical statement position did not cross polarity at its dated cutoff.', 1;

    SELECT
        aged.SubjectCode,
        aged.BusinessBalance,
        aged.PositionCode,
        aged.CurrentAmount,
        aged.Days1To30Amount,
        aged.Days31To60Amount,
        aged.Days61To90Amount,
        aged.Over90Amount,
        aged.StatementBusinessBalance,
        aged.ReconciliationResidual
    FROM Subject.fnCurrentAgedInvoices(@AgedOn) AS aged
    WHERE aged.SubjectCode LIKE N'AgeTest%'
    ORDER BY aged.SubjectCode;

    ROLLBACK TRAN SubjectAgedBalancesTest;
END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0 ROLLBACK TRAN SubjectAgedBalancesTest;
    THROW;
END CATCH;
