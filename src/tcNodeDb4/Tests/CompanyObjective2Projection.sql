SET NOCOUNT, XACT_ABORT ON;

BEGIN TRAN CompanyObjective2ProjectionTest;
BEGIN TRY
    IF EXISTS (SELECT 1 FROM Cash.tbTaxTagSource WHERE TaxSourceCode = 'UK-MTD')
        THROW 51000, 'Obsolete UK-MTD source survived the company projection.', 1;

    IF (SELECT COUNT(*) FROM Cash.tbTaxTagSource WHERE TaxSourceCode IN ('UK-CO-ACCTS-2026', 'UK-CO-CT-2026', 'UK-CO-CT600-2026')) <> 3
        THROW 51001, 'Current company statutory sources are incomplete.', 1;

    IF (SELECT COUNT(*) FROM Cash.tbTaxTag WHERE TaxSourceCode = 'UK-CO-ACCTS-2026') <> 28
        THROW 51002, 'Accounts semantic manifest is incomplete.', 1;

    IF (SELECT COUNT(*) FROM Cash.tbTaxTag WHERE TaxSourceCode = 'UK-CO-CT-2026') <> 12
        THROW 51003, 'Corporation Tax semantic manifest is incomplete.', 1;

    IF (SELECT COUNT(*) FROM Cash.tbTaxTag WHERE TaxSourceCode = 'UK-CO-CT600-2026') <> 13
        THROW 51010, 'CT600 semantic manifest is incomplete.', 1;

    IF EXISTS
    (
        SELECT 1
        FROM Cash.tbTaxTagMap m
        JOIN Cash.tbTaxTag t ON t.TaxSourceCode = m.TaxSourceCode AND t.TagCode = m.TagCode
        WHERE m.TaxSourceCode IN ('UK-CO-ACCTS-2026', 'UK-CO-CT-2026', 'UK-CO-CT600-2026')
          AND t.TagClassCode <> 1
    )
        THROW 51004, 'A non-Component statutory value has an accounting mapping.', 1;

    IF EXISTS (SELECT 1 FROM Cash.fnTaxTagMapValidate('UK-CO-ACCTS-2026') WHERE IsError = 1)
        THROW 51005, 'Accounts mappings fail generic validation.', 1;

    IF EXISTS (SELECT 1 FROM Cash.fnTaxTagMapValidate('UK-CO-CT-2026') WHERE IsError = 1)
        THROW 51006, 'Corporation Tax mappings fail generic validation.', 1;

    IF EXISTS (SELECT 1 FROM Cash.fnTaxTagMapValidate('UK-CO-CT600-2026') WHERE IsError = 1)
        THROW 51011, 'CT600 mappings fail generic validation.', 1;

    IF NOT EXISTS
    (
        SELECT 1 FROM Cash.tbTaxTagMap
        WHERE TaxSourceCode = 'UK-CO-CT-2026'
          AND TagCode = 'AddBacks.AccountingDepreciation'
          AND CategoryCode = 'CA-DEPREC'
    )
        THROW 51007, 'Accounting depreciation evidence is not mapped separately.', 1;

    IF EXISTS
    (
        SELECT 1 FROM Cash.tbTaxTagMap
        WHERE TaxSourceCode = 'UK-CO-CT-2026'
          AND TagCode = 'CapitalAllowances'
    )
        THROW 51008, 'Accounting depreciation was incorrectly mapped as capital allowances.', 1;

    -- The statutory-composition procedure is deliberately repeatable.
    EXEC App.proc_Template_CO_MICRO_CUR_TAX_2026;

    IF (SELECT COUNT(*) FROM Cash.tbTaxTagMap WHERE TaxSourceCode IN ('UK-CO-ACCTS-2026', 'UK-CO-CT-2026', 'UK-CO-CT600-2026')) <> 10
        THROW 51009, 'Rerunning statutory composition changed the mapping cardinality.', 1;

    DECLARE @AccountsEnd DATE = DATEADD(DAY, -1,
        (SELECT PayTo FROM Cash.fnTaxTypeDueDates(Cash.fnGetBizTaxType(), 0)));

    IF (SELECT COUNT(*) FROM Cash.fnTaxBizBalanceSheet('UK-CO-ACCTS-2026', @AccountsEnd)) <> 4
        THROW 51018, 'The generic balance-sheet source projection is incomplete.', 1;

    IF EXISTS
    (
        SELECT TagCode
        FROM Cash.fnTaxBizBalanceSheet('UK-CO-ACCTS-2026', @AccountsEnd)
        WHERE TagCode NOT IN
        (
            N'BalanceSheet.NonCurrentAssets',
            N'BalanceSheet.CurrentAssets',
            N'BalanceSheet.CurrentLiabilities',
            N'BalanceSheet.NonCurrentLiabilities'
        )
    )
        THROW 51019, 'The generic balance-sheet projection exposed jurisdiction-specific semantics.', 1;

    IF (SELECT COUNT(*) FROM Cash.fnTaxBizBalanceSheetUK('UK-CO-ACCTS-2026', @AccountsEnd)) <> 4
        THROW 51012, 'The ledger-owned balance-sheet source projection is incomplete.', 1;

    -- Protect the exact year-end call that previously exceeded the query optimiser's plan resources.
    IF (SELECT COUNT(*) FROM Cash.fnTaxBizBalanceSheetUK('UK-CO-ACCTS-2026', '20270331')) <> 4
        THROW 51017, 'The year-end balance-sheet source projection did not compile and execute.', 1;

    IF EXISTS
    (
        SELECT 1
        FROM Cash.fnTaxBizBalanceSheetUK('UK-CO-ACCTS-2026', @AccountsEnd)
        WHERE ValidationStatus <> N'Ready'
           OR SupportStatus <> N'Supported'
           OR ValueState <> N'Source'
           OR StatutoryAmount IS NULL
    )
        THROW 51013, 'The statutory balance-sheet projection is not ready.', 1;

    IF EXISTS
    (
        SELECT expected.TagCode
        FROM (VALUES
            (N'BalanceSheet.FixedAssets'),
            (N'BalanceSheet.CurrentAssets'),
            (N'BalanceSheet.CreditorsDueWithinOneYear'),
            (N'BalanceSheet.CreditorsDueAfterOneYear')
        ) expected(TagCode)
        EXCEPT
        SELECT TagCode FROM Cash.fnTaxBizBalanceSheetUK('UK-CO-ACCTS-2026', @AccountsEnd)
    )
    OR EXISTS
    (
        SELECT TagCode FROM Cash.fnTaxBizBalanceSheetUK('UK-CO-ACCTS-2026', @AccountsEnd)
        EXCEPT
        SELECT expected.TagCode
        FROM (VALUES
            (N'BalanceSheet.FixedAssets'),
            (N'BalanceSheet.CurrentAssets'),
            (N'BalanceSheet.CreditorsDueWithinOneYear'),
            (N'BalanceSheet.CreditorsDueAfterOneYear')
        ) expected(TagCode)
    )
        THROW 51014, 'The balance-sheet source projection returned an unexpected semantic.', 1;

    DECLARE @PeriodEnd DATE = DATEADD(DAY, 1, @AccountsEnd);
    DECLARE @PeriodStart DATE = DATEADD(YEAR, -1, @PeriodEnd);

    IF EXISTS
    (
        SELECT 1
        FROM Cash.vwTaxBizSubmission submission
        JOIN Cash.fnTaxBizCumulative('UK-CO-ACCTS-2026', @PeriodStart, @PeriodEnd) projection
          ON projection.TaxSourceCode = submission.TaxSourceCode
         AND projection.TagCode = submission.TagCode
        JOIN Cash.tbTaxTag tag
          ON tag.TaxSourceCode = submission.TaxSourceCode
         AND tag.TagCode = submission.TagCode
        WHERE submission.TaxSourceCode = 'UK-CO-ACCTS-2026'
          AND CONVERT(DATE, submission.PeriodFrom) = @PeriodStart
          AND CONVERT(DATE, submission.PeriodTo) = @PeriodEnd
          AND projection.StatutoryAmount <> CASE tag.CashPolarityCode
              WHEN 0 THEN submission.TaxableAmount * -1 ELSE submission.TaxableAmount END
    )
        THROW 51015, 'The cumulative projection does not reconcile to Cash.vwTaxBizSubmission.', 1;

    IF NOT EXISTS
    (
        SELECT 1
        FROM Cash.fnTaxBizComputation(@PeriodStart, @PeriodEnd)
        WHERE CalculatedTaxDue = StatementTaxDue
          AND IsUniformTaxRate = 1
    )
        THROW 51016, 'The Corporation Tax computation does not reconcile to Cash.vwTaxBizStatement.', 1;

    SELECT TaxSourceCode, COUNT(*) AS TagCount
    FROM Cash.tbTaxTag
    WHERE TaxSourceCode IN ('UK-CO-ACCTS-2026', 'UK-CO-CT-2026', 'UK-CO-CT600-2026')
    GROUP BY TaxSourceCode
    ORDER BY TaxSourceCode;

    SELECT TaxSourceCode, TagCode, COUNT(*) AS EffectiveContributorCount
    FROM Cash.vwTaxTagCashCode
    WHERE TaxSourceCode IN ('UK-CO-ACCTS-2026', 'UK-CO-CT-2026', 'UK-CO-CT600-2026')
    GROUP BY TaxSourceCode, TagCode
    ORDER BY TaxSourceCode, TagCode;

    ROLLBACK TRAN CompanyObjective2ProjectionTest;
END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0 ROLLBACK TRAN CompanyObjective2ProjectionTest;
    THROW;
END CATCH;
