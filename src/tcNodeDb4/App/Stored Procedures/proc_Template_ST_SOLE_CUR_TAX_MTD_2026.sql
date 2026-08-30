CREATE PROCEDURE App.proc_Template_ST_SOLE_CUR_TAX_MTD_2026
AS
SET NOCOUNT, XACT_ABORT ON;
BEGIN TRY
    BEGIN TRAN SoleTraderTaxMtd;

    IF NOT EXISTS (SELECT 1 FROM Cash.tbTaxTagSource WHERE TaxSourceCode = 'UK-ITSA-SE-CUM')
        INSERT INTO Cash.tbTaxTagSource
            (TaxSourceCode, JurisdictionCode, SourceName, SourceDescription, TaxTypeCode)
        VALUES ('UK-ITSA-SE-CUM', 'UK', 'ITSA',
                'MTD ITSA Sole Trader cumulative accounting projection', 5);

    ;WITH TagSeed AS
    (
        SELECT * FROM (VALUES
            ('turnover', 'Turnover', 1, 10), ('otherBusinessIncome', 'Other business income', 1, 20),
            ('consolidatedExpenses', 'Consolidated expenses', 0, 100),
            ('costOfGoods', 'Cost of goods', 0, 110),
            ('paymentsToSubcontractors', 'Payments to subcontractors', 0, 120),
            ('wagesAndStaffCosts', 'Wages and staff costs', 0, 130),
            ('carVanTravelExpenses', 'Car, van and travel expenses', 0, 140),
            ('premisesRunningCosts', 'Premises running costs', 0, 150),
            ('maintenanceCosts', 'Maintenance costs', 0, 160),
            ('adminCosts', 'Administration costs', 0, 170),
            ('advertisingCosts', 'Advertising costs', 0, 180),
            ('businessEntertainmentCosts', 'Business entertainment costs', 0, 190),
            ('interestOnBankOtherLoans', 'Interest on bank and other loans', 0, 200),
            ('financeCharges', 'Finance charges', 0, 210),
            ('professionalFees', 'Professional fees', 0, 220),
            ('otherExpenses', 'Other expenses', 0, 230)
        ) v(TagCode, TagName, CashPolarityCode, DisplayOrder)
    )
    INSERT INTO Cash.tbTaxTag
        (TaxSourceCode, TagCode, TagName, TagClassCode, CashPolarityCode, DisplayOrder)
    SELECT 'UK-ITSA-SE-CUM', TagCode, TagName, 1, CashPolarityCode, DisplayOrder
    FROM TagSeed s
    WHERE NOT EXISTS
    (
        SELECT 1 FROM Cash.tbTaxTag t
        WHERE t.TaxSourceCode = 'UK-ITSA-SE-CUM' AND t.TagCode = s.TagCode
    );

    COMMIT TRAN SoleTraderTaxMtd;
END TRY
BEGIN CATCH
    EXEC App.proc_ErrorLog;
END CATCH;
GO
