CREATE PROCEDURE App.proc_Template_CO_MICRO_CUR_STD_EXP_2026
AS
BEGIN

    ----------------------------------------------------------------
    -- STD-SPECIFIC EXPRESSION CATEGORIES (CategoryTypeCode = 2)
    ----------------------------------------------------------------
    INSERT INTO Cash.tbCategory
        (CategoryCode, Category, CategoryTypeCode, CashPolarityCode, CashTypeCode, DisplayOrder, IsEnabled)
    VALUES
        -- Enabled by default (the “big four”)
        ('CE-COS',  'Cash Operating Surplus % (Structured)', 2, 2, 0, 20, 1),
        ('CE-LM',   'Labour Margin %',                       2, 2, 0, 21, 1),
        ('CE-MM',   'Materials Margin %',                    2, 2, 0, 22, 1),
        ('CE-SDR',  'Subcontractor Dependency Ratio',        2, 2, 0, 23, 1),

        -- Effective tax rate (enabled)
        ('CE-ETR',  'Effective Tax Rate',                    2, 2, 0, 24, 1),

        -- Disabled by default (progressive disclosure)
        ('CE-VCR',  'Vehicle Cost Ratio',                    2, 2, 0, 25, 0),

        ('CE-WPR',  'Wages % of Staff Costs',                2, 2, 0, 26, 0),
        ('CE-NPR',  'Employer NI % of Staff Costs',          2, 2, 0, 27, 0),
        ('CE-PPR',  'Pension % of Staff Costs',              2, 2, 0, 28, 0),

        ('CE-RPR',  'Rent % of Admin Expenses',              2, 2, 0, 29, 0),
        ('CE-UPR',  'Utilities % of Admin Expenses',         2, 2, 0, 30, 0),
        ('CE-IPR',  'Insurance % of Admin Expenses',         2, 2, 0, 31, 0),
        ('CE-MPR',  'Repairs % of Admin Expenses',           2, 2, 0, 32, 0),
        ('CE-TPR',  'Telephone % of Admin Expenses',         2, 2, 0, 33, 0),
        ('CE-APR',  'Advertising % of Admin Expenses',       2, 2, 0, 34, 0),
        ('CE-TRR',  'Travel % of Admin Expenses',            2, 2, 0, 35, 0),
        ('CE-PFR',  'Professional Fees % of Admin Expenses', 2, 2, 0, 36, 0),
        ('CE-BCR',  'Bank Charges % of Admin Expenses',      2, 2, 0, 37, 0),

        ('CE-DPL',  'Plant Depreciation % of Depreciation',  2, 2, 0, 38, 0),
        ('CE-DMV',  'Motor Depreciation % of Depreciation',  2, 2, 0, 39, 0),
        ('CE-DFX',  'Fixtures Depreciation % of Depreciation', 2, 2, 0, 40, 0);

    ----------------------------------------------------------------
    -- STD-SPECIFIC EXPRESSIONS (STABLE CODE REFERENCES)
    ----------------------------------------------------------------
    INSERT INTO Cash.tbCategoryExp
        (CategoryCode, Expression, Format, SyntaxTypeCode, IsError, ErrorMessage)
    VALUES
        -- Structured Cash Operating Surplus %
        ('CE-COS', 'IF([CT-TURNOV]=0,0,([CT-TURNOV]-[CT-CSTSAL]-[CT-STAFFC]-[CA-ADMIN])/[CT-TURNOV])', 'Pct0', 0, 0, NULL),

        -- Labour Margin %
        ('CE-LM', 'IF([CC-SALAB]=0,0,([CC-SALAB]-[CC-SALRY]-[CC-EMPNI]-[CC-PENSN])/[CC-SALAB])', 'Pct0', 0, 0, NULL),

        -- Materials Margin %
        ('CE-MM', 'IF([CC-SAMAT]=0,0,([CC-SAMAT]-[CC-MAT])/[CC-SAMAT])', 'Pct0', 0, 0, NULL),

        -- Subcontractor Dependency Ratio
        ('CE-SDR', 'IF([CT-CSTSAL]=0,0,[CC-SUB]/[CT-CSTSAL])', 'Pct0', 0, 0, NULL),

        -- Effective Tax Rate
        ('CE-ETR',
            'IF(([CT-TURNOV]-[CT-CSTSAL]-[CT-STAFFC]-[CA-ADMIN])=0,0,(ABS([CA-TAXCO])/([CT-TURNOV]-[CT-CSTSAL]-[CT-STAFFC]-[CA-ADMIN])))',
            'Pct0', 0, 0, NULL),

        -- Vehicle Cost Ratio
        ('CE-VCR', 'IF([CT-TURNOV]=0,0,([CC-FUEL]+[CC-MTRAV])/[CT-TURNOV])', 'Pct0', 0, 0, NULL),

        -- Staff Cost Structure
        ('CE-WPR', 'IF([CT-STAFFC]=0,0,[CC-SALRY]/[CT-STAFFC])', 'Pct0', 0, 0, NULL),
        ('CE-NPR', 'IF([CT-STAFFC]=0,0,[CC-EMPNI]/[CT-STAFFC])', 'Pct0', 0, 0, NULL),
        ('CE-PPR', 'IF([CT-STAFFC]=0,0,[CC-PENSN]/[CT-STAFFC])', 'Pct0', 0, 0, NULL),

        -- Admin Cost Structure
        ('CE-RPR', 'IF([CA-ADMIN]=0,0,[CC-RENT]/[CA-ADMIN])', 'Pct0', 0, 0, NULL),
        ('CE-UPR', 'IF([CA-ADMIN]=0,0,[CC-LHEAT]/[CA-ADMIN])', 'Pct0', 0, 0, NULL),
        ('CE-IPR', 'IF([CA-ADMIN]=0,0,[CC-INS]/[CA-ADMIN])', 'Pct0', 0, 0, NULL),
        ('CE-MPR', 'IF([CA-ADMIN]=0,0,[CC-REPA]/[CA-ADMIN])', 'Pct0', 0, 0, NULL),
        ('CE-TPR', 'IF([CA-ADMIN]=0,0,[CC-PHONE]/[CA-ADMIN])', 'Pct0', 0, 0, NULL),
        ('CE-APR', 'IF([CA-ADMIN]=0,0,[CC-ADVT]/[CA-ADMIN])', 'Pct0', 0, 0, NULL),
        ('CE-TRR', 'IF([CA-ADMIN]=0,0,[CC-TRAV]/[CA-ADMIN])', 'Pct0', 0, 0, NULL),
        ('CE-PFR', 'IF([CA-ADMIN]=0,0,[CC-PROF]/[CA-ADMIN])', 'Pct0', 0, 0, NULL),
        ('CE-BCR', 'IF([CA-ADMIN]=0,0,[CC-BANKC]/[CA-ADMIN])', 'Pct0', 0, 0, NULL),

        -- Depreciation Structure
        ('CE-DPL', 'IF([CA-DEPREC]=0,0,[CC-DEPPL]/[CA-DEPREC])', 'Pct0', 0, 0, NULL),
        ('CE-DMV', 'IF([CA-DEPREC]=0,0,[CC-DEPMV]/[CA-DEPREC])', 'Pct0', 0, 0, NULL),
        ('CE-DFX', 'IF([CA-DEPREC]=0,0,[CC-DEPFX]/[CA-DEPREC])', 'Pct0', 0, 0, NULL);

END;
GO
