/*
    Jurisdiction-selected annual business-tax computation.

    Provider selection occurs once in fnTaxBizComputationByYearSelected so SQL
    Server does not execute both the retained flat-rate control and the UK
    marginal-relief provider. Unsupported UK rows remain available with their
    findings in Cash.vwTaxCorpLiabilityUK and are omitted here, causing
    downstream liability creation to fail closed.
*/
CREATE VIEW Cash.vwTaxBizComputationByYear
AS
SELECT YearNumber,
       Description,
       PeriodStart,
       PeriodEnd,
       TaxableResult,
       OpeningLoss,
       LossCreated,
       LossUsed,
       ClosingLoss,
       EffectiveTaxRate,
       BusinessTaxAdjustment,
       TaxableProfitAfterRelief,
       TaxBeforeRelief,
       TaxReliefApplied,
       TaxDue
FROM Cash.fnTaxBizComputationByYearSelected()
WHERE IsAccrualReady = 1;
GO
