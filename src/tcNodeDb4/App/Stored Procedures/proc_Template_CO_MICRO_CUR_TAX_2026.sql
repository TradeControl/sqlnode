CREATE PROCEDURE App.proc_Template_CO_MICRO_CUR_TAX_2026
AS
SET NOCOUNT, XACT_ABORT ON;
BEGIN TRY
    BEGIN TRAN CompanyStatutoryProjection;

    -- Retire the obsolete Government Gateway-era mixed vocabulary if this
    -- projection is applied to an upgraded rather than freshly reset node.
    DELETE FROM Cash.tbTaxTagSource
    WHERE TaxSourceCode IN ('UK-MTD', 'UK-CO-ACCTS-2026', 'UK-CO-CT-2026', 'UK-CO-CT600-2026');

    INSERT INTO Cash.tbTaxTagSource
        (TaxSourceCode, JurisdictionCode, SourceName, SourceDescription, TaxTypeCode)
    VALUES
        ('UK-CO-ACCTS-2026', 'UK', 'Company Accounts',
         'FRS 105 micro-entity statutory accounts semantic projection; FRC 2026 contract family', 0),
        ('UK-CO-CT-2026', 'UK', 'Corporation Tax',
         'Ordinary company Corporation Tax computation inputs; CT600 V3 RIM 1.994 contract family', 0),
        ('UK-CO-CT600-2026', 'UK', 'CT600 Return',
         'CT600 return semantic projection; CT600 V3 RIM 1.994 contract family', 0);

    INSERT INTO Cash.tbTaxTag
        (TaxSourceCode, TagCode, TagName, TagClassCode, CashPolarityCode, TagDescription, DisplayOrder)
    VALUES
        -- Statutory accounts: only the first four facts are directly writable
        -- from the accounting Category Tree. The remaining manifest is explicit
        -- so unsupported/unmapped is never confused with a genuine zero.
        ('UK-CO-ACCTS-2026', 'Company', 'Company identity', 2, 0, 'Contextual company name, registration number and jurisdiction.', 1),
        ('UK-CO-ACCTS-2026', 'Period', 'Accounts period', 2, 0, 'Contextual approved accounts reporting period.', 2),
        ('UK-CO-ACCTS-2026', 'ComparativePeriod', 'Comparative period', 2, 0, 'Contextual; optional only when a comparative is not statutorily applicable.', 3),
        ('UK-CO-ACCTS-2026', 'Profile', 'Accounts profile', 2, 0, 'Contextual FRS 105 micro-entity and audit-exemption choices.', 4),
        ('UK-CO-ACCTS-2026', 'Currency', 'Reporting currency', 2, 0, 'Contextual reporting currency.', 5),
        ('UK-CO-ACCTS-2026', 'IncomeStatement.Turnover', 'Turnover', 1, 1, 'Direct accounting component.', 10),
        ('UK-CO-ACCTS-2026', 'IncomeStatement.OtherIncome', 'Other income', 1, 1, 'Direct accounting component.', 20),
        ('UK-CO-ACCTS-2026', 'IncomeStatement.CostOfSales', 'Cost of sales', 1, 0, 'Direct accounting component.', 30),
        ('UK-CO-ACCTS-2026', 'IncomeStatement.AdministrativeExpenses', 'Administrative expenses', 1, 0, 'Direct accounting component including staff, overhead and depreciation expense.', 40),
        ('UK-CO-ACCTS-2026', 'IncomeStatement.TaxOnProfit', 'Tax on profit', 2, 0, 'Derived from the approved Corporation Tax computation; not mapped to the tax control account.', 50),
        ('UK-CO-ACCTS-2026', 'IncomeStatement.ProfitLossForPeriod', 'Profit or loss for period', 2, 1, 'Derived statement total; polarity may be profit or loss.', 60),
        ('UK-CO-ACCTS-2026', 'BalanceSheet.FixedAssets', 'Fixed assets', 2, 1, 'Derived from balance-sheet/account balances, not period cash-category mapping.', 100),
        ('UK-CO-ACCTS-2026', 'BalanceSheet.CurrentAssets', 'Current assets', 2, 1, 'Derived from balance-sheet/account balances.', 110),
        ('UK-CO-ACCTS-2026', 'BalanceSheet.PrepaymentsAndAccruedIncome', 'Prepayments and accrued income', 2, 1, 'External or derived after period-end adjustments.', 120),
        ('UK-CO-ACCTS-2026', 'BalanceSheet.CreditorsDueWithinOneYear', 'Creditors due within one year', 2, 0, 'Derived from balance-sheet/account balances and maturity classification.', 130),
        ('UK-CO-ACCTS-2026', 'BalanceSheet.NetCurrentAssetsLiabilities', 'Net current assets or liabilities', 2, 1, 'Derived statement total.', 140),
        ('UK-CO-ACCTS-2026', 'BalanceSheet.TotalAssetsLessCurrentLiabilities', 'Total assets less current liabilities', 2, 1, 'Derived statement total.', 150),
        ('UK-CO-ACCTS-2026', 'BalanceSheet.CreditorsDueAfterOneYear', 'Creditors due after one year', 2, 0, 'Derived using maturity classification.', 160),
        ('UK-CO-ACCTS-2026', 'BalanceSheet.Provisions', 'Provisions', 2, 0, 'External or derived after statutory review.', 170),
        ('UK-CO-ACCTS-2026', 'BalanceSheet.AccrualsAndDeferredIncome', 'Accruals and deferred income', 2, 0, 'External or derived after period-end adjustments.', 180),
        ('UK-CO-ACCTS-2026', 'BalanceSheet.NetAssetsLiabilities', 'Net assets or liabilities', 2, 1, 'Derived statement total.', 190),
        ('UK-CO-ACCTS-2026', 'BalanceSheet.CapitalAndReserves', 'Capital and reserves', 2, 1, 'Derived from equity/account balances.', 200),
        ('UK-CO-ACCTS-2026', 'Notes.PrincipalActivity', 'Principal activity', 2, 0, 'External/contextual narrative disclosure.', 280),
        ('UK-CO-ACCTS-2026', 'Notes.AccountingPolicies', 'Accounting policies', 2, 0, 'External/contextual narrative disclosure.', 290),
        ('UK-CO-ACCTS-2026', 'Notes.AverageEmployees', 'Average employees', 2, 0, 'External/contextual non-monetary value.', 300),
        ('UK-CO-ACCTS-2026', 'Notes.DirectorAdvances', 'Director advances', 2, 0, 'External structured repeating disclosure.', 310),
        ('UK-CO-ACCTS-2026', 'Notes.CommitmentsAndContingencies', 'Commitments and contingencies', 2, 0, 'External structured repeating disclosure; optional when absent.', 320),
        ('UK-CO-ACCTS-2026', 'Approval', 'Accounts approval', 2, 0, 'Contextual workflow value including date and signing director.', 400),

        -- Computation inputs and results. Accounting depreciation is exposed as
        -- evidence for a reviewed add-back; it is never a capital allowance.
        ('UK-CO-CT-2026', 'AccountsProfitLossBeforeTax', 'Accounts profit or loss before tax', 2, 1, 'Derived from the approved accounts statement.', 10),
        ('UK-CO-CT-2026', 'AddBacks.AccountingDepreciation', 'Accounting depreciation', 1, 0, 'Direct accounting component supplied to the reviewed adjustment schedule.', 20),
        ('UK-CO-CT-2026', 'AddBacks.Other', 'Other add-backs', 2, 0, 'External/reviewed structured adjustments; unsupported by the Category Tree.', 30),
        ('UK-CO-CT-2026', 'Deductions', 'Tax deductions', 2, 1, 'External/reviewed structured adjustments.', 40),
        ('UK-CO-CT-2026', 'CapitalAllowances', 'Capital allowances', 2, 0, 'External or future asset-workflow calculation; never accounting depreciation.', 50),
        ('UK-CO-CT-2026', 'Losses', 'Loss relief schedule', 2, 0, 'External/contextual loss and claims state.', 60),
        ('UK-CO-CT-2026', 'TaxableTotalProfits', 'Taxable total profits', 2, 1, 'Derived computation result.', 70),
        ('UK-CO-CT-2026', 'MainRate', 'Corporation Tax rate', 2, 0, 'Contextual statutory rate selected for the Corporation Tax period.', 80),
        ('UK-CO-CT-2026', 'CorporationTaxChargeable', 'Corporation Tax chargeable', 2, 0, 'Derived computation result.', 90),
        ('UK-CO-CT-2026', 'Reliefs', 'Reliefs', 2, 0, 'External/reviewed relief claims.', 100),
        ('UK-CO-CT-2026', 'TaxPayable', 'Tax payable', 2, 0, 'Derived computation result.', 110),
        ('UK-CO-CT-2026', 'CT600A', 'CT600A loans to participators', 2, 0, 'Conditional structured supplementary-page input; optional when not applicable.', 200),

        -- CT600 return: only turnover is independently supplied by the Category
        -- Tree. Computation results are reconciled projections, not duplicate maps.
        ('UK-CO-CT600-2026', 'CompanyName', 'Company name', 2, 0, 'Contextual legal identity.', 10),
        ('UK-CO-CT600-2026', 'CompanyRegistrationNumber', 'Company registration number', 2, 0, 'Contextual legal identity.', 20),
        ('UK-CO-CT600-2026', 'Utr', 'Unique Taxpayer Reference', 2, 0, 'External authority identifier.', 30),
        ('UK-CO-CT600-2026', 'Period', 'Corporation Tax period', 2, 0, 'Derived period allocation, distinct from the accounts period.', 40),
        ('UK-CO-CT600-2026', 'Turnover', 'Turnover', 1, 1, 'Direct accounting component reconciled to statutory accounts.', 50),
        ('UK-CO-CT600-2026', 'ProfitBeforeTax', 'Profit before tax', 2, 1, 'Derived from approved accounts and reconciled to the computation.', 60),
        ('UK-CO-CT600-2026', 'TaxableTotalProfits', 'Taxable total profits', 2, 1, 'Derived from the approved computation.', 70),
        ('UK-CO-CT600-2026', 'CorporationTaxChargeable', 'Corporation Tax chargeable', 2, 0, 'Derived from the approved computation.', 80),
        ('UK-CO-CT600-2026', 'TaxPayable', 'Tax payable', 2, 0, 'Derived from the approved computation.', 90),
        ('UK-CO-CT600-2026', 'AccountsAttached', 'Accounts attached', 2, 0, 'Workflow/package declaration.', 100),
        ('UK-CO-CT600-2026', 'ComputationsAttached', 'Computations attached', 2, 0, 'Workflow/package declaration.', 110),
        ('UK-CO-CT600-2026', 'SupplementaryPageA', 'CT600A', 2, 0, 'Conditional structured supplementary page; optional when not applicable.', 120),
        ('UK-CO-CT600-2026', 'Declaration', 'Return declaration', 2, 0, 'Contextual workflow name and declaration date.', 130);

    INSERT INTO Cash.tbTaxTagMap
        (TaxSourceCode, TagCode, MapTypeCode, CategoryCode, CashCode, IsEnabled)
    VALUES
        ('UK-CO-ACCTS-2026', 'IncomeStatement.Turnover', 0, 'CT-TURNOV', '', 1),
        ('UK-CO-ACCTS-2026', 'IncomeStatement.OtherIncome', 0, 'CT-OTHRIN', '', 1),
        ('UK-CO-ACCTS-2026', 'IncomeStatement.CostOfSales', 0, 'CT-CSTSAL', '', 1),
        ('UK-CO-ACCTS-2026', 'IncomeStatement.AdministrativeExpenses', 0, 'CT-STAFFC', '', 1),
        ('UK-CO-ACCTS-2026', 'IncomeStatement.AdministrativeExpenses', 0, 'CT-OVERHD', '', 1),
        ('UK-CO-CT-2026', 'AddBacks.AccountingDepreciation', 0, 'CA-DEPREC', '', 1),
        ('UK-CO-CT600-2026', 'Turnover', 0, 'CT-TURNOV', '', 1);

    COMMIT TRAN CompanyStatutoryProjection;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRAN CompanyStatutoryProjection;
    EXEC App.proc_ErrorLog;
END CATCH;
GO
