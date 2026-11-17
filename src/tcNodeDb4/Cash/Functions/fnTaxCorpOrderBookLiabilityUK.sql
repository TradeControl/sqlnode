/*
    Materialises the reviewed annual actual-plus-order-book liability set once
    for transaction-grained consumers. The boundary prevents SQL Server from
    repeatedly expanding the complete Category Tree, accounting and profile
    projection through downstream window expressions.
*/
CREATE FUNCTION Cash.fnTaxCorpOrderBookLiabilityUK()
RETURNS @Liability TABLE
(
    YearNumber smallint NOT NULL,
    TaxSourceCode nvarchar(20) NULL,
    PeriodStart date NOT NULL,
    PeriodEnd date NOT NULL,
    ActualTaxableResultBeforeRelief decimal(38,5) NULL,
    ActualRelevantDistributions decimal(38,5) NULL,
    BusinessTaxAdjustment decimal(38,5) NULL,
    AssociatedCompanyCount int NULL,
    MainRate decimal(9,6) NULL,
    SmallProfitsRate decimal(9,6) NULL,
    MarginalReliefFraction decimal(9,6) NULL,
    LowerLimit decimal(28,5) NULL,
    UpperLimit decimal(28,5) NULL,
    ProjectedOpeningLoss decimal(38,5) NULL,
    ProjectedTaxableResultBeforeRelief decimal(38,5) NULL,
    ProjectedRelevantDistributions decimal(38,5) NULL,
    ProjectedLiability decimal(38,5) NULL,
    TaxAccrual decimal(38,5) NULL,
    FindingCode nvarchar(40) NULL,
    IsAccrualReady bit NOT NULL
)
AS
BEGIN
    INSERT @Liability
    (
        YearNumber, TaxSourceCode, PeriodStart, PeriodEnd,
        ActualTaxableResultBeforeRelief, ActualRelevantDistributions,
        BusinessTaxAdjustment, AssociatedCompanyCount,
        MainRate, SmallProfitsRate, MarginalReliefFraction,
        LowerLimit, UpperLimit, ProjectedOpeningLoss,
        ProjectedTaxableResultBeforeRelief, ProjectedRelevantDistributions,
        ProjectedLiability,
        TaxAccrual, FindingCode, IsAccrualReady
    )
    SELECT YearNumber,
           TaxSourceCode,
           PeriodStart,
           PeriodEnd,
           ActualTaxableResultBeforeRelief,
           ActualRelevantDistributions,
           BusinessTaxAdjustment,
           AssociatedCompanyCount,
           MainRate,
           SmallProfitsRate,
           MarginalReliefFraction,
           LowerLimit,
           UpperLimit,
           ProjectedOpeningLoss,
           ProjectedTaxableResultBeforeRelief,
           ProjectedRelevantDistributions,
           ProjectedLiability,
           TaxAccrual,
           FindingCode,
           IsAccrualReady
    FROM Cash.vwTaxCorpOrderBookLiabilityUK;

    RETURN;
END;
GO
