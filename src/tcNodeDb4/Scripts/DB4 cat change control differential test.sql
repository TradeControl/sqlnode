/*
    Differential acceptance for the Category Tree schema migration.

    Build one complete pre-update synthetic database, clone it, and apply the
    migration only to the clone. Run this script from SQLCMD mode on the same
    SQL Server instance after supplying both database names.

    Volatile audit columns, rowversion values and Category Tree lifecycle metadata
    are deliberately excluded. All accounting/classification rowsets are compared
    with EXCEPT in both directions, so counts and values must be identical.
*/
:ON ERROR EXIT
:setvar BaselineDatabase "tcNodeDb4-B1-Baseline"
:setvar CandidateDatabase "tcNodeDb4-B1-Candidate"

SET NOCOUNT ON;
SET XACT_ABORT ON;

IF DB_ID(N'$(BaselineDatabase)') IS NULL
    THROW 51300, 'The Category Tree differential baseline database does not exist.', 1;
IF DB_ID(N'$(CandidateDatabase)') IS NULL
    THROW 51301, 'The Category Tree differential candidate database does not exist.', 1;
IF N'$(BaselineDatabase)' = N'$(CandidateDatabase)'
    THROW 51302, 'The baseline and candidate databases must be different.', 1;

/* Category content, graph, mappings and roots. */
IF EXISTS
(
    SELECT CategoryCode, Category, CategoryTypeCode, CashPolarityCode,
           CashTypeCode, DisplayOrder, IsEnabled
    FROM [$(BaselineDatabase)].Cash.tbCategory
    EXCEPT
    SELECT CategoryCode, Category, CategoryTypeCode, CashPolarityCode,
           CashTypeCode, DisplayOrder, IsEnabled
    FROM [$(CandidateDatabase)].Cash.vwCategoryActive
)
OR EXISTS
(
    SELECT CategoryCode, Category, CategoryTypeCode, CashPolarityCode,
           CashTypeCode, DisplayOrder, IsEnabled
    FROM [$(CandidateDatabase)].Cash.vwCategoryActive
    EXCEPT
    SELECT CategoryCode, Category, CategoryTypeCode, CashPolarityCode,
           CashTypeCode, DisplayOrder, IsEnabled
    FROM [$(BaselineDatabase)].Cash.tbCategory
)
    THROW 51303, 'Category rows differ between the baseline and migrated databases.', 1;

IF EXISTS
(
    SELECT ParentCode, ChildCode, DisplayOrder FROM [$(BaselineDatabase)].Cash.tbCategoryTotal
    EXCEPT
    SELECT ParentCode, ChildCode, DisplayOrder FROM [$(CandidateDatabase)].Cash.vwCategoryTotalActive
)
OR EXISTS
(
    SELECT ParentCode, ChildCode, DisplayOrder FROM [$(CandidateDatabase)].Cash.vwCategoryTotalActive
    EXCEPT
    SELECT ParentCode, ChildCode, DisplayOrder FROM [$(BaselineDatabase)].Cash.tbCategoryTotal
)
    THROW 51304, 'Category edges differ between the baseline and migrated databases.', 1;

IF EXISTS
(
    SELECT CashCode, CategoryCode FROM [$(BaselineDatabase)].Cash.tbCode
    EXCEPT
    SELECT CashCode, CategoryCode FROM [$(CandidateDatabase)].Cash.vwCategoryCodeMapActive
)
OR EXISTS
(
    SELECT CashCode, CategoryCode FROM [$(CandidateDatabase)].Cash.vwCategoryCodeMapActive
    EXCEPT
    SELECT CashCode, CategoryCode FROM [$(BaselineDatabase)].Cash.tbCode
)
    THROW 51305, 'Cash Code category mappings differ between the baseline and migrated databases.', 1;

IF EXISTS
(
    SELECT root.RootTypeCode, root.CategoryCode
    FROM [$(BaselineDatabase)].App.tbOptions AS options
    CROSS APPLY
    (
        VALUES
        (CAST(0 AS SMALLINT), options.NetProfitCode),
        (CAST(1 AS SMALLINT), options.VatCategoryCode)
    ) AS root (RootTypeCode, CategoryCode)
    EXCEPT
    SELECT RootTypeCode, CategoryCode FROM [$(CandidateDatabase)].Cash.vwCategoryRootActive
)
OR EXISTS
(
    SELECT RootTypeCode, CategoryCode FROM [$(CandidateDatabase)].Cash.vwCategoryRootActive
    EXCEPT
    SELECT root.RootTypeCode, root.CategoryCode
    FROM [$(BaselineDatabase)].App.tbOptions AS options
    CROSS APPLY
    (
        VALUES
        (CAST(0 AS SMALLINT), options.NetProfitCode),
        (CAST(1 AS SMALLINT), options.VatCategoryCode)
    ) AS root (RootTypeCode, CategoryCode)
)
    THROW 51306, 'Net Profit or VAT roots differ between the baseline and migrated databases.', 1;

/* Stable public calculation surfaces. */
IF EXISTS (SELECT * FROM [$(BaselineDatabase)].App.vwTaxBizCashCodes EXCEPT SELECT * FROM [$(CandidateDatabase)].App.vwTaxBizCashCodes)
 OR EXISTS (SELECT * FROM [$(CandidateDatabase)].App.vwTaxBizCashCodes EXCEPT SELECT * FROM [$(BaselineDatabase)].App.vwTaxBizCashCodes)
    THROW 51307, 'Business-tax Cash Code membership differs.', 1;

IF EXISTS (SELECT * FROM [$(BaselineDatabase)].App.vwTaxVatCashCodes EXCEPT SELECT * FROM [$(CandidateDatabase)].App.vwTaxVatCashCodes)
 OR EXISTS (SELECT * FROM [$(CandidateDatabase)].App.vwTaxVatCashCodes EXCEPT SELECT * FROM [$(BaselineDatabase)].App.vwTaxVatCashCodes)
    THROW 51308, 'VAT Cash Code membership differs.', 1;

IF EXISTS (SELECT * FROM [$(BaselineDatabase)].Cash.vwStatementBase EXCEPT SELECT * FROM [$(CandidateDatabase)].Cash.vwStatementBase)
 OR EXISTS (SELECT * FROM [$(CandidateDatabase)].Cash.vwStatementBase EXCEPT SELECT * FROM [$(BaselineDatabase)].Cash.vwStatementBase)
    THROW 51309, 'Cash Statement base results differ.', 1;

IF EXISTS (SELECT * FROM [$(BaselineDatabase)].Cash.vwStatementWhatIf EXCEPT SELECT * FROM [$(CandidateDatabase)].Cash.vwStatementWhatIf)
 OR EXISTS (SELECT * FROM [$(CandidateDatabase)].Cash.vwStatementWhatIf EXCEPT SELECT * FROM [$(BaselineDatabase)].Cash.vwStatementWhatIf)
    THROW 51310, 'Cash Statement What-If results differ.', 1;

IF EXISTS (SELECT * FROM [$(BaselineDatabase)].Cash.vwBudget EXCEPT SELECT * FROM [$(CandidateDatabase)].Cash.vwBudget)
 OR EXISTS (SELECT * FROM [$(CandidateDatabase)].Cash.vwBudget EXCEPT SELECT * FROM [$(BaselineDatabase)].Cash.vwBudget)
    THROW 51311, 'Budget results differ.', 1;

IF EXISTS (SELECT * FROM [$(BaselineDatabase)].Cash.vwProfitAndLossByYear EXCEPT SELECT * FROM [$(CandidateDatabase)].Cash.vwProfitAndLossByYear)
 OR EXISTS (SELECT * FROM [$(CandidateDatabase)].Cash.vwProfitAndLossByYear EXCEPT SELECT * FROM [$(BaselineDatabase)].Cash.vwProfitAndLossByYear)
    THROW 51312, 'Profit and Loss by year results differ.', 1;

IF EXISTS (SELECT * FROM [$(BaselineDatabase)].Cash.vwProfitAndLossByPeriod EXCEPT SELECT * FROM [$(CandidateDatabase)].Cash.vwProfitAndLossByPeriod)
 OR EXISTS (SELECT * FROM [$(CandidateDatabase)].Cash.vwProfitAndLossByPeriod EXCEPT SELECT * FROM [$(BaselineDatabase)].Cash.vwProfitAndLossByPeriod)
    THROW 51313, 'Profit and Loss by period results differ.', 1;

IF EXISTS (SELECT * FROM [$(BaselineDatabase)].Cash.vwProfitAndLossData EXCEPT SELECT * FROM [$(CandidateDatabase)].Cash.vwProfitAndLossData)
 OR EXISTS (SELECT * FROM [$(CandidateDatabase)].Cash.vwProfitAndLossData EXCEPT SELECT * FROM [$(BaselineDatabase)].Cash.vwProfitAndLossData)
    THROW 51314, 'Profit and Loss data results differ.', 1;

IF EXISTS (SELECT * FROM [$(BaselineDatabase)].Cash.vwTaxBizAccruals EXCEPT SELECT * FROM [$(CandidateDatabase)].Cash.vwTaxBizAccruals)
 OR EXISTS (SELECT * FROM [$(CandidateDatabase)].Cash.vwTaxBizAccruals EXCEPT SELECT * FROM [$(BaselineDatabase)].Cash.vwTaxBizAccruals)
    THROW 51315, 'Business-tax accrual results differ.', 1;

IF EXISTS (SELECT * FROM [$(BaselineDatabase)].Cash.vwTaxVatAccruals EXCEPT SELECT * FROM [$(CandidateDatabase)].Cash.vwTaxVatAccruals)
 OR EXISTS (SELECT * FROM [$(CandidateDatabase)].Cash.vwTaxVatAccruals EXCEPT SELECT * FROM [$(BaselineDatabase)].Cash.vwTaxVatAccruals)
    THROW 51316, 'VAT accrual results differ.', 1;

IF EXISTS (SELECT * FROM [$(BaselineDatabase)].Cash.vwEquityReconciliationByYear EXCEPT SELECT * FROM [$(CandidateDatabase)].Cash.vwEquityReconciliationByYear)
 OR EXISTS (SELECT * FROM [$(CandidateDatabase)].Cash.vwEquityReconciliationByYear EXCEPT SELECT * FROM [$(BaselineDatabase)].Cash.vwEquityReconciliationByYear)
    THROW 51317, 'Equity reconciliation results differ.', 1;

SELECT
    N'PASS' AS DifferentialStatus,
    N'$(BaselineDatabase)' AS BaselineDatabase,
    N'$(CandidateDatabase)' AS CandidateDatabase,
    (SELECT COUNT(*) FROM [$(CandidateDatabase)].Cash.vwCategoryActive) AS CategoryCount,
    (SELECT COUNT(*) FROM [$(CandidateDatabase)].Cash.vwCategoryTotalActive) AS EdgeCount,
    (SELECT COUNT(*) FROM [$(CandidateDatabase)].Cash.vwCategoryCodeMapActive) AS MappingCount,
    (SELECT COUNT(*) FROM [$(CandidateDatabase)].Cash.vwStatementBase) AS CashStatementRowCount;
