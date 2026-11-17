/*
    UK confirmed-order-book liability projection regression.

    Read-only: validates the annual N/D accumulation, loss roll-forward and
    liability-delta identity without changing the live tax-accrual view.
*/
SET NOCOUNT ON;
SET XACT_ABORT ON;

IF OBJECT_ID(N'Cash.vwTaxCorpOrderBookLiabilityUK', N'V') IS NULL
    THROW 51440, 'The UK CT order-book liability projection is not deployed.', 1;

/*
    The expanded annual views are materialised once so each invariant inspects
    one identical calculation set. Re-reading the view for every assertion
    obscures the live execution cost with repeated compilation and execution.
*/
SELECT *
INTO #OrderBook
FROM Cash.vwTaxBizOrderBook;

SELECT *
INTO #Actual
FROM Cash.vwTaxCorpLiabilityUK;

SELECT *
INTO #Projection
FROM Cash.vwTaxCorpOrderBookLiabilityUK;

IF EXISTS
(
    SELECT 1
    FROM #Projection projection
    WHERE projection.ProjectedLiability - projection.ActualLiability <> projection.TaxAccrual
)
    THROW 51441, 'The order-book tax accrual does not reconcile to projected less actual liability.', 1;

IF EXISTS
(
    SELECT 1
    FROM #Projection projection
    WHERE projection.OrderBookProfit = 0
      AND projection.OrderBookDistributions = 0
      AND projection.ProjectedTaxableResultBeforeRelief
          <> (SELECT actual.TaxableResultBeforeRelief
              FROM #Actual actual
              WHERE actual.YearNumber = projection.YearNumber)
)
    THROW 51442, 'A zero-order-book year changed its taxable result before relief.', 1;

IF EXISTS
(
    SELECT order_book.YearNumber,
           OrderBookProfit = CONVERT(decimal(38,5), SUM(CASE
               WHEN distribution.CashCode IS NULL THEN order_book.OrderValue ELSE 0 END)),
           OrderBookDistributions = CONVERT(decimal(38,5), SUM(CASE
               WHEN distribution.CashCode IS NOT NULL THEN order_book.OrderValue ELSE 0 END))
    FROM #OrderBook order_book
    LEFT JOIN
    (
        SELECT DISTINCT projection.TaxSourceCode, mapping.CashCode
        FROM #Projection projection
        JOIN Cash.vwTaxTagCashCode mapping
          ON mapping.TaxSourceCode = projection.TaxSourceCode
         AND mapping.TagCode = N'RelevantDistributions'
    ) distribution ON distribution.CashCode = order_book.CashCode
    GROUP BY order_book.YearNumber

    EXCEPT

    SELECT YearNumber, OrderBookProfit, OrderBookDistributions
    FROM #Projection
    WHERE OrderBookProfit <> 0 OR OrderBookDistributions <> 0
)
    THROW 51443, 'The UK order-book N/D accumulation does not reconcile to the canonical order book.', 1;

IF EXISTS
(
    SELECT 1
    FROM #Projection
    WHERE IsAccrualReady = 0
      AND TaxAccrual IS NOT NULL
)
    THROW 51444, 'A non-ready order-book projection exposed a usable tax accrual.', 1;

SELECT YearNumber, OrderBookProfit, OrderBookDistributions,
       ProjectedTaxableTotalProfits, AugmentedProfits,
       CalculationCode, MarginalRelief,
       ActualLiability, ProjectedLiability, TaxAccrual,
       FindingCode, IsAccrualReady
FROM #Projection
ORDER BY YearNumber;
