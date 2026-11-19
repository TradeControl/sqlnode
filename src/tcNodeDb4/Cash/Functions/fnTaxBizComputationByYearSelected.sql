/*
    Resolves the active Category Tree once, then delegates to the same
    version-explicit provider used by historical Equity Bridge reconstruction.
*/
CREATE FUNCTION Cash.fnTaxBizComputationByYearSelected()
RETURNS @Computation TABLE
(
    YearNumber smallint NOT NULL,
    Description nvarchar(10) NOT NULL,
    PeriodStart date NOT NULL,
    PeriodEnd date NOT NULL,
    TaxableResult decimal(38,5) NULL,
    OpeningLoss decimal(38,5) NULL,
    LossCreated decimal(38,5) NULL,
    LossUsed decimal(38,5) NULL,
    ClosingLoss decimal(38,5) NULL,
    EffectiveTaxRate decimal(38,12) NULL,
    BusinessTaxAdjustment decimal(38,5) NULL,
    TaxableProfitAfterRelief decimal(38,5) NULL,
    TaxBeforeRelief decimal(38,5) NULL,
    TaxReliefApplied decimal(38,5) NULL,
    TaxDue decimal(38,5) NULL,
    JurisdictionCode nvarchar(10) NULL,
    TaxSourceCode nvarchar(20) NULL,
    ReportingProfileCode nvarchar(20) NULL,
    CalculationCode nvarchar(40) NULL,
    FindingCode nvarchar(40) NULL,
    IsAccrualReady bit NOT NULL,
    IsFilingReady bit NOT NULL
)
AS
BEGIN
    DECLARE @CategoryVersionId nvarchar(10);

    SELECT @CategoryVersionId = options.CategoryVersionId
    FROM App.tbOptions AS options;

    INSERT @Computation
    (
        YearNumber, Description, PeriodStart, PeriodEnd, TaxableResult,
        OpeningLoss, LossCreated, LossUsed, ClosingLoss, EffectiveTaxRate,
        BusinessTaxAdjustment, TaxableProfitAfterRelief, TaxBeforeRelief,
        TaxReliefApplied, TaxDue, JurisdictionCode, TaxSourceCode,
        ReportingProfileCode, CalculationCode, FindingCode,
        IsAccrualReady, IsFilingReady
    )
    SELECT YearNumber, Description, PeriodStart, PeriodEnd, TaxableResult,
           OpeningLoss, LossCreated, LossUsed, ClosingLoss, EffectiveTaxRate,
           BusinessTaxAdjustment, TaxableProfitAfterRelief, TaxBeforeRelief,
           TaxReliefApplied, TaxDue, JurisdictionCode, TaxSourceCode,
           ReportingProfileCode, CalculationCode, FindingCode,
           IsAccrualReady, IsFilingReady
    FROM Cash.fnTaxBizComputationByYearSelectedByVersion(@CategoryVersionId);

    RETURN;
END;
GO
