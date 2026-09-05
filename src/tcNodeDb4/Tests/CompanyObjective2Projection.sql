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

    IF (SELECT COUNT(*) FROM Cash.tbTaxTagMap WHERE TaxSourceCode IN ('UK-CO-ACCTS-2026', 'UK-CO-CT-2026', 'UK-CO-CT600-2026')) <> 7
        THROW 51009, 'Rerunning statutory composition changed the mapping cardinality.', 1;

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
