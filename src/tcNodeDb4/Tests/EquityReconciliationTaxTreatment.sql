/*
    Equity bridge tax-treatment regression.

    Corporation tax reduces company retained profit. Sole-trader income tax
    is personal and must not be deducted a second time by the business equity
    bridge; any cash withdrawal is already represented by capital movement.

    Run against a rebuilt synthetic company or sole-trader node.
*/
SET NOCOUNT ON;

DECLARE @BusinessTaxType smallint = Cash.fnGetBizTaxType();
DECLARE @Tolerance decimal(18, 5) = 0.10;

IF @BusinessTaxType NOT IN (0, 4)
    THROW 51090, 'Equity reconciliation test requires an enabled company or sole-trader business-tax type.', 1;

IF NOT EXISTS (SELECT 1 FROM Cash.vwEquityReconciliationByYear)
    THROW 51091, 'Equity reconciliation test requires generated accounting years.', 1;

IF EXISTS
(
    SELECT 1
    FROM Cash.vwEquityReconciliationByYear
    WHERE ABS(Variance) > @Tolerance
)
    THROW 51092, 'Equity reconciliation exceeds tolerance for the active business-tax treatment.', 1;

IF @BusinessTaxType = 4
   AND EXISTS
   (
       SELECT 1
       FROM Cash.vwEquityReconciliationByYear
       WHERE BusinessTax <> 0
   )
    THROW 51093, 'Sole-trader personal income tax must not be treated as a business equity expense.', 1;

SELECT
    BusinessTaxType = @BusinessTaxType,
    YearsChecked = COUNT(*),
    MaximumAbsoluteVariance = MAX(ABS(Variance))
FROM Cash.vwEquityReconciliationByYear;
