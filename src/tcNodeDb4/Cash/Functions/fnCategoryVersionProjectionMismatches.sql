CREATE FUNCTION Cash.fnCategoryVersionProjectionMismatches
(
    @CategoryVersionId nvarchar(10)
)
RETURNS TABLE
AS
RETURN
(
    WITH version_context AS
    (
        SELECT @CategoryVersionId AS SelectedVersionId, options.CategoryVersionId AS ActiveVersionId
        FROM App.tbOptions AS options
    ),
    vat_selected AS
    (
        SELECT CashCode FROM version_context CROSS APPLY App.fnTaxVatCashCodesByVersion(SelectedVersionId)
    ),
    vat_active AS
    (
        SELECT CashCode FROM version_context CROSS APPLY App.fnTaxVatCashCodesByVersion(ActiveVersionId)
    ),
    biz_selected AS
    (
        SELECT CashCode, CashTypeCode, CashPolarityCode
        FROM version_context CROSS APPLY App.fnTaxBizCashCodesByVersion(SelectedVersionId)
    ),
    biz_active AS
    (
        SELECT CashCode, CashTypeCode, CashPolarityCode
        FROM version_context CROSS APPLY App.fnTaxBizCashCodesByVersion(ActiveVersionId)
    ),
    open_projects AS
    (
        SELECT DISTINCT CashCode
        FROM Project.tbProject
        WHERE ProjectStatusCode BETWEEN 1 AND 2
          AND ActionOn <= (SELECT DATEADD(DAY, TaxHorizon, CURRENT_TIMESTAMP) FROM App.tbOptions)
    ),
    project_selected AS
    (
        SELECT project.CashCode, category.CashPolarityCode
        FROM open_projects AS project
        JOIN Cash.tbCategoryCodeMap AS category_code
          ON category_code.VersionId = @CategoryVersionId AND category_code.CashCode = project.CashCode
        JOIN Cash.tbCategory AS category
          ON category.VersionId = category_code.VersionId AND category.CategoryCode = category_code.CategoryCode
        JOIN Cash.tbCode AS code ON code.CashCode = category_code.CashCode
    ),
    project_active AS
    (
        SELECT project.CashCode, category.CashPolarityCode
        FROM open_projects AS project
        CROSS JOIN version_context
        JOIN Cash.tbCategoryCodeMap AS category_code
          ON category_code.VersionId = version_context.ActiveVersionId AND category_code.CashCode = project.CashCode
        JOIN Cash.tbCategory AS category
          ON category.VersionId = category_code.VersionId AND category.CategoryCode = category_code.CategoryCode
        JOIN Cash.tbCode AS code ON code.CashCode = category_code.CashCode
    ),
    asset_accounts AS
    (
        SELECT AccountCode, CashCode
        FROM Subject.tbAccount
        WHERE AccountTypeCode = 2 AND AccountClosed = 0
    ),
    asset_selected AS
    (
        SELECT account.AccountCode, category.CashPolarityCode
        FROM asset_accounts AS account
        JOIN Cash.tbCategoryCodeMap AS category_code
          ON category_code.VersionId = @CategoryVersionId AND category_code.CashCode = account.CashCode
        JOIN Cash.tbCategory AS category
          ON category.VersionId = category_code.VersionId AND category.CategoryCode = category_code.CategoryCode
        JOIN Cash.tbCode AS code ON code.CashCode = category_code.CashCode
    ),
    asset_active AS
    (
        SELECT account.AccountCode, category.CashPolarityCode
        FROM asset_accounts AS account
        CROSS JOIN version_context
        JOIN Cash.tbCategoryCodeMap AS category_code
          ON category_code.VersionId = version_context.ActiveVersionId AND category_code.CashCode = account.CashCode
        JOIN Cash.tbCategory AS category
          ON category.VersionId = category_code.VersionId AND category.CategoryCode = category_code.CategoryCode
        JOIN Cash.tbCode AS code ON code.CashCode = category_code.CashCode
    )
    SELECT Dependency
    FROM
    (
        SELECT N'VAT_ROOT' AS Dependency
        WHERE EXISTS (SELECT CashCode FROM vat_selected EXCEPT SELECT CashCode FROM vat_active)
           OR EXISTS (SELECT CashCode FROM vat_active EXCEPT SELECT CashCode FROM vat_selected)
        UNION ALL
        SELECT N'BIZ_ROOT'
        WHERE EXISTS
              (SELECT CashCode, CashTypeCode, CashPolarityCode FROM biz_selected
               EXCEPT SELECT CashCode, CashTypeCode, CashPolarityCode FROM biz_active)
           OR EXISTS
              (SELECT CashCode, CashTypeCode, CashPolarityCode FROM biz_active
               EXCEPT SELECT CashCode, CashTypeCode, CashPolarityCode FROM biz_selected)
        UNION ALL
        SELECT N'OPEN_PROJECT_POLARITY'
        WHERE EXISTS
              (SELECT CashCode, CashPolarityCode FROM project_selected
               EXCEPT SELECT CashCode, CashPolarityCode FROM project_active)
           OR EXISTS
              (SELECT CashCode, CashPolarityCode FROM project_active
               EXCEPT SELECT CashCode, CashPolarityCode FROM project_selected)
        UNION ALL
        SELECT N'ASSET_ACCOUNT_POLARITY'
        WHERE EXISTS
              (SELECT AccountCode, CashPolarityCode FROM asset_selected
               EXCEPT SELECT AccountCode, CashPolarityCode FROM asset_active)
           OR EXISTS
              (SELECT AccountCode, CashPolarityCode FROM asset_active
               EXCEPT SELECT AccountCode, CashPolarityCode FROM asset_selected)
    ) AS mismatches
);
