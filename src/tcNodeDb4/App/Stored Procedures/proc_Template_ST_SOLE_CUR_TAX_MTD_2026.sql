CREATE PROCEDURE App.proc_Template_ST_SOLE_CUR_TAX_MTD_2026
AS
SET NOCOUNT, XACT_ABORT ON;
BEGIN TRY
    BEGIN TRAN SoleTraderTaxMtd;

    IF NOT EXISTS (SELECT 1 FROM Cash.tbTaxTagSource WHERE TaxSourceCode = 'UK-ITSA-SE-CUM')
        INSERT INTO Cash.tbTaxTagSource
            (TaxSourceCode, SourceName, SourceDescription, TaxTypeCode, ReportingTypeCode)
        VALUES ('UK-ITSA-SE-CUM', 'ITSA',
                'MTD ITSA Sole Trader cumulative accounting projection', 5, 1);

    DECLARE
        @SubjectCode NVARCHAR(50) = (SELECT SubjectCode FROM App.tbOptions),
        @ValidFrom DATE = COALESCE((SELECT MIN(CONVERT(DATE, StartOn)) FROM App.tbYearPeriod), CONVERT(DATE, CURRENT_TIMESTAMP)),
        @ReportingProfileCode NVARCHAR(20) = NULL;

    SELECT @ReportingProfileCode = ReportingProfileCode
    FROM Cash.tbReportingProfile
    WHERE SubjectCode = @SubjectCode
      AND ReportingTypeCode = 1
      AND TaxSourceCode = N'UK-ITSA-SE-CUM';

    IF @ReportingProfileCode IS NULL
        EXEC Cash.proc_ReportingProfileSave
            @SubjectCode = @SubjectCode,
            @ReportingTypeCode = 1,
            @TaxSourceCode = N'UK-ITSA-SE-CUM',
            @ValidFrom = @ValidFrom,
            @StatusCode = 0,
            @ValueSourceCode = N'IMPORTED',
            @IsReviewed = 0,
            @ReportingProfileCode = @ReportingProfileCode OUTPUT;

    IF EXISTS (SELECT 1 FROM Cash.tbTaxType WHERE TaxTypeCode = 1 AND IsEnabled = 1)
       AND NOT EXISTS
       (
           SELECT 1 FROM Cash.tbReportingProfile
           WHERE SubjectCode = @SubjectCode
             AND ReportingTypeCode = 0
       )
    BEGIN
        SET @ReportingProfileCode = NULL;
        EXEC Cash.proc_ReportingProfileSave
            @SubjectCode = @SubjectCode,
            @ReportingTypeCode = 0,
            @TaxSourceCode = NULL,
            @ValidFrom = @ValidFrom,
            @StatusCode = 0,
            @ValueSourceCode = N'IMPORTED',
            @IsReviewed = 0,
            @ReportingProfileCode = @ReportingProfileCode OUTPUT;
    END;

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
            ('irrecoverableDebts', 'Irrecoverable debts', 0, 220),
            ('professionalFees', 'Professional fees', 0, 230),
            ('depreciation', 'Depreciation', 0, 240),
            ('otherExpenses', 'Other expenses', 0, 250)
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
