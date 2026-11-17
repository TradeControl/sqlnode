/*
    MR-4 UK What-if integration regression.

    The first section is always valid: an empty costing set must be an exact
    identity over the actual-plus-confirmed liability. The populated scenario
    assertions will be added once the retained B8 finished-goods fixture has
    been created through the application workflow.
*/
SET NOCOUNT ON;
SET XACT_ABORT ON;

IF EXISTS (SELECT 1 FROM Cash.vwTaxBizWhatIfOrderBook)
    THROW 51290, 'The empty-cost-set identity fixture requires no selected What-if Projects.', 1;

IF (SELECT COUNT_BIG(*) FROM Cash.vwTaxCorpWhatIfLiabilityUK)
    <> (SELECT COUNT_BIG(*) FROM Cash.fnTaxCorpOrderBookLiabilityUK())
    THROW 51291, 'The What-if annual projection did not preserve the base year set.', 1;

IF EXISTS
(
    SELECT 1
    FROM Cash.vwTaxCorpWhatIfLiabilityUK liability
    WHERE liability.ScenarioProfit <> 0
       OR liability.ScenarioDistributions <> 0
       OR liability.WhatIfLiability <> liability.BaseProjectedLiability
       OR liability.ScenarioTaxAccrual <> 0
       OR liability.IsAccrualReady <> 1
)
    THROW 51292, 'An empty What-if costing set changed the projected Corporation Tax liability.', 1;

IF EXISTS (SELECT 1 FROM Cash.fnTaxBizWhatIfAccrualsSelected())
    THROW 51293, 'The selected What-if tax provider emitted an accrual for an empty costing set.', 1;

DECLARE @LastConfiguredPeriod date =
(
    SELECT MAX(CONVERT(date, StartOn)) FROM App.tbYearPeriod
);

IF NOT EXISTS
(
    SELECT 1
    FROM Cash.fnTaxTypeDueDates(0, 0) due_date
    WHERE @LastConfiguredPeriod >= due_date.PayFrom
      AND @LastConfiguredPeriod < due_date.PayTo
      AND due_date.PayOn IS NOT NULL
)
    THROW 51306, 'The final configured period has no Corporation Tax payment-date mapping.', 1;

SELECT liability.YearNumber,
       liability.PeriodStart,
       liability.PeriodEnd,
       liability.BaseProjectedLiability,
       liability.WhatIfLiability,
       liability.ScenarioTaxAccrual,
       liability.FindingCode,
       liability.IsAccrualReady
FROM Cash.vwTaxCorpWhatIfLiabilityUK liability
ORDER BY liability.YearNumber;

PRINT N'CorporationTaxWhatIfUK empty-cost-set identity passed.';
