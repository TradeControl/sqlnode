CREATE PROCEDURE App.proc_Template_ST_SOLE_CUR_TAX_MTD_2026
AS
    SET NOCOUNT, XACT_ABORT ON;
BEGIN TRY

    BEGIN TRAN SoleTraderTaxMtd;

    ----------------------------------------------------------------
    -- MTD Tag Sources (same as MIN section 9)
    ----------------------------------------------------------------
    IF NOT EXISTS (SELECT 1 FROM Cash.tbTaxTagSource WHERE TaxSourceCode = 'UK-ITSA-SE-QU')
    BEGIN
        INSERT INTO Cash.tbTaxTagSource
            (TaxSourceCode, JurisdictionCode, SourceName, SourceDescription, TaxTypeCode)
        VALUES
            ('UK-ITSA-SE-QU', 'UK', 'ITSA',
             'MTD ITSA Self-Employment Quarterly Update field set', 5);
    END;

    IF NOT EXISTS (SELECT 1 FROM Cash.tbTaxTagSource WHERE TaxSourceCode = 'UK-ITSA-SE-EOPS')
    BEGIN
        INSERT INTO Cash.tbTaxTagSource
            (TaxSourceCode, JurisdictionCode, SourceName, SourceDescription, TaxTypeCode)
        VALUES
            ('UK-ITSA-SE-EOPS', 'UK', 'ITSA',
             'MTD ITSA Self-Employment annual business return field set (EOPS)', 4);
    END;

    ----------------------------------------------------------------
    -- MTD QU Tags (HMRC Quarterly Update Direction)
    ----------------------------------------------------------------
    ;WITH TagSeed AS
    (
        SELECT * FROM (VALUES
            ('turnover',                      'Turnover',                                      CONVERT(TINYINT, 1), CONVERT(SMALLINT, 10)),
            ('otherBusinessIncome',           'Other business income',                         CONVERT(TINYINT, 1), CONVERT(SMALLINT, 20)),

            ('costOfGoods',                   'Cost of goods bought for resale or goods used', CONVERT(TINYINT, 1), CONVERT(SMALLINT, 110)),
            ('cisPaymentsToSubcontractors',   'Construction industry – payments to subcontractors', CONVERT(TINYINT, 1), CONVERT(SMALLINT, 120)),
            ('wagesSalariesStaffCosts',       'Wages, salaries, and other staff costs',        CONVERT(TINYINT, 1), CONVERT(SMALLINT, 130)),
            ('carVanTravelExpenses',          'Car, van, and travel expenses',                 CONVERT(TINYINT, 1), CONVERT(SMALLINT, 140)),
            ('rentRatesPowerInsurance',       'Rent, rates, power, and insurance costs',       CONVERT(TINYINT, 1), CONVERT(SMALLINT, 150)),
            ('repairsMaintenance',            'Repairs and maintenance of property and equipment', CONVERT(TINYINT, 1), CONVERT(SMALLINT, 160)),
            ('phoneFaxStationeryOtherOffice', 'Phone, fax, stationery, and other office costs',CONVERT(TINYINT, 1), CONVERT(SMALLINT, 170)),
            ('advertising',                   'Advertising',                                   CONVERT(TINYINT, 1), CONVERT(SMALLINT, 180)),
            ('businessEntertainment',         'Business entertainment costs',                  CONVERT(TINYINT, 1), CONVERT(SMALLINT, 190)),
            ('interestOnLoans',               'Interest on bank and other loans',              CONVERT(TINYINT, 1), CONVERT(SMALLINT, 200)),
            ('bankFinancialCharges',          'Bank, credit card and other financial charges', CONVERT(TINYINT, 1), CONVERT(SMALLINT, 210)),
            ('accountancyLegalProfessionalFees','Accountancy, legal and other professional fees', CONVERT(TINYINT, 1), CONVERT(SMALLINT, 220)),
            ('otherBusinessExpenses',         'Other business expenses',                       CONVERT(TINYINT, 1), CONVERT(SMALLINT, 230))
        ) v(TagCode, TagName, TagClassCode, DisplayOrder)
    )
    INSERT INTO Cash.tbTaxTag
        (TaxSourceCode, TagCode, TagName, TagClassCode, DisplayOrder)
    SELECT
        'UK-ITSA-SE-QU',
        s.TagCode,
        s.TagName,
        s.TagClassCode,
        s.DisplayOrder
    FROM TagSeed s
    WHERE NOT EXISTS
    (
        SELECT 1
        FROM Cash.tbTaxTag t
        WHERE t.TaxSourceCode = 'UK-ITSA-SE-QU'
          AND t.TagCode = s.TagCode
    );

    ----------------------------------------------------------------
    -- MTD EOPS Tags (HMRC adjustments + allowances + losses)
    ----------------------------------------------------------------
    ;WITH EopsSeed AS
    (
        SELECT * FROM (VALUES
            -- Adjustments
            ('basisPeriodStart',              'Basis period start',                     CONVERT(TINYINT, 1), CONVERT(SMALLINT, 710)),
            ('basisPeriodEnd',                'Basis period end',                       CONVERT(TINYINT, 1), CONVERT(SMALLINT, 720)),
            ('overlapProfit',                 'Overlap profit',                          CONVERT(TINYINT, 1), CONVERT(SMALLINT, 810)),
            ('overlapReliefUsed',             'Overlap relief used',                     CONVERT(TINYINT, 1), CONVERT(SMALLINT, 820)),
            ('transitionalProfit',            'Transitional profit',                     CONVERT(TINYINT, 1), CONVERT(SMALLINT, 830)),
            ('transitionalRelief',            'Transitional relief',                     CONVERT(TINYINT, 1), CONVERT(SMALLINT, 840)),
            ('privateUseAdjustment',          'Private use adjustment',                  CONVERT(TINYINT, 1), CONVERT(SMALLINT, 1030)),

            -- Capital Allowances
            ('annualInvestmentAllowance',     'Annual Investment Allowance',             CONVERT(TINYINT, 1), CONVERT(SMALLINT, 920)),
            ('writingDownAllowanceMainPool',  'Writing Down Allowance (Main pool)',      CONVERT(TINYINT, 1), CONVERT(SMALLINT, 930)),
            ('writingDownAllowanceSpecialRate','Writing Down Allowance (Special rate)',  CONVERT(TINYINT, 1), CONVERT(SMALLINT, 940)),
            ('writingDownAllowanceSingleAsset','Writing Down Allowance (Single asset)',  CONVERT(TINYINT, 1), CONVERT(SMALLINT, 950)),
            ('smallPoolsAllowance',           'Small pools allowance',                   CONVERT(TINYINT, 1), CONVERT(SMALLINT, 960)),
            ('balancingChargeMainPool',       'Balancing charge (Main pool)',            CONVERT(TINYINT, 1), CONVERT(SMALLINT, 970)),
            ('balancingChargeSpecialRate',    'Balancing charge (Special rate)',         CONVERT(TINYINT, 1), CONVERT(SMALLINT, 980)),
            ('balancingChargeSingleAsset',    'Balancing charge (Single asset)',         CONVERT(TINYINT, 1), CONVERT(SMALLINT, 990)),
            ('balancingAllowanceMainPool',    'Balancing allowance (Main pool)',         CONVERT(TINYINT, 1), CONVERT(SMALLINT, 1000)),
            ('balancingAllowanceSpecialRate', 'Balancing allowance (Special rate)',      CONVERT(TINYINT, 1), CONVERT(SMALLINT, 1010)),
            ('balancingAllowanceSingleAsset', 'Balancing allowance (Single asset)',      CONVERT(TINYINT, 1), CONVERT(SMALLINT, 1020)),

            -- Losses
            ('lossBroughtForward',            'Loss brought forward',                    CONVERT(TINYINT, 1), CONVERT(SMALLINT, 610)),
            ('lossUsedAgainstProfit',         'Loss used against profit',                CONVERT(TINYINT, 1), CONVERT(SMALLINT, 620)),
            ('lossCarriedForward',            'Loss carried forward',                    CONVERT(TINYINT, 1), CONVERT(SMALLINT, 630)),
            ('lossUsedAgainstOtherIncome',    'Loss used against other income',          CONVERT(TINYINT, 1), CONVERT(SMALLINT, 640)),
            ('lossUsedAgainstCapitalGains',   'Loss used against capital gains',         CONVERT(TINYINT, 1), CONVERT(SMALLINT, 650)),

            -- Totals
            ('adjustedProfitForTax',          'Adjusted profit for tax',                 CONVERT(TINYINT, 2), CONVERT(SMALLINT, 860)),
            ('capitalAllowancesTotal',        'Capital allowances total',                CONVERT(TINYINT, 2), CONVERT(SMALLINT, 1180))
        ) v(TagCode, TagName, TagClassCode, DisplayOrder)
    )
    INSERT INTO Cash.tbTaxTag
        (TaxSourceCode, TagCode, TagName, TagClassCode, DisplayOrder)
    SELECT
        'UK-ITSA-SE-EOPS',
        s.TagCode,
        s.TagName,
        s.TagClassCode,
        s.DisplayOrder
    FROM EopsSeed s
    WHERE NOT EXISTS
    (
        SELECT 1
        FROM Cash.tbTaxTag t
        WHERE t.TaxSourceCode = 'UK-ITSA-SE-EOPS'
          AND t.TagCode = s.TagCode
    );

    ----------------------------------------------------------------
    -- Mapping placeholder (as agreed)
    ----------------------------------------------------------------
    -- TODO: Add QU + EOPS mappings here.

    EXEC Cash.proc_TaxTagMapValidate @TaxSourceCode = 'UK-ITSA-SE-QU';
    EXEC Cash.proc_TaxTagMapValidate @TaxSourceCode = 'UK-ITSA-SE-EOPS';

    COMMIT TRAN SoleTraderTaxMtd;

END TRY
BEGIN CATCH
    EXEC App.proc_ErrorLog;
END CATCH;
GO
