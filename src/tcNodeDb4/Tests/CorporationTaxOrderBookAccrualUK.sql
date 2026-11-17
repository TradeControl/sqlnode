/*
    Transaction-grained UK Corporation Tax order-book accrual regression.

    Read-only: verifies stable Project/year identity and exact telescoping from
    Project deltas plus explicit carry bridges to the reviewed annual result.
*/
SET NOCOUNT ON;
SET XACT_ABORT ON;

IF OBJECT_ID(N'Cash.vwTaxCorpOrderBookAccrualUK', N'V') IS NULL
    THROW 51450, 'The UK CT Project-level accrual provider is not deployed.', 1;

SELECT * INTO #OrderBook FROM Cash.vwTaxBizOrderBook;
SELECT * INTO #Annual FROM Cash.vwTaxCorpOrderBookLiabilityUK;
SELECT * INTO #Accrual FROM Cash.vwTaxCorpOrderBookAccrualUK;

IF EXISTS
(
    SELECT accrual.ProjectCode
    FROM #Accrual accrual
    WHERE accrual.IsCarryEffect = 0
    GROUP BY accrual.ProjectCode
    HAVING COUNT_BIG(*) <> 1
)
    THROW 51451, 'A Project emitted more than one own-year CT accrual event.', 1;

IF EXISTS
(
    SELECT order_book.ProjectCode FROM #OrderBook order_book
    EXCEPT
    SELECT accrual.ProjectCode FROM #Accrual accrual WHERE accrual.IsCarryEffect = 0
)
    THROW 51452, 'A canonical order-book Project has no own-year CT accrual event.', 1;

IF EXISTS
(
    SELECT 1
    FROM #Accrual accrual
    JOIN #OrderBook order_book ON order_book.ProjectCode = accrual.ProjectCode
    WHERE accrual.SourceStartOn <> order_book.StartOn
       OR accrual.SourceYearNumber <> order_book.YearNumber
       OR accrual.CashCode <> order_book.CashCode
       OR accrual.ActionOn <> order_book.ActionOn
       OR accrual.SourceQuantityRemaining <> order_book.QuantityRemaining
       OR accrual.SourceOrderValue <> order_book.OrderValue
)
    THROW 51453, 'A CT accrual event does not retain its canonical Project source facts.', 1;

IF EXISTS
(
    SELECT annual.YearNumber, annual.TaxAccrual
    FROM #Annual annual
    EXCEPT
    SELECT annual.YearNumber,
           TaxAccrual = CONVERT(decimal(38,5), COALESCE(SUM(accrual.TaxDue), 0))
    FROM #Annual annual
    LEFT JOIN #Accrual accrual
      ON accrual.LiabilityYearNumber = annual.YearNumber
    GROUP BY annual.YearNumber
)
OR EXISTS
(
    SELECT annual.YearNumber,
           TaxAccrual = CONVERT(decimal(38,5), COALESCE(SUM(accrual.TaxDue), 0))
    FROM #Annual annual
    LEFT JOIN #Accrual accrual
      ON accrual.LiabilityYearNumber = annual.YearNumber
    GROUP BY annual.YearNumber
    EXCEPT
    SELECT annual.YearNumber, annual.TaxAccrual
    FROM #Annual annual
)
    THROW 51454, 'Project and carry deltas do not reconcile to the annual CT accrual.', 1;

IF EXISTS
(
    SELECT 1
    FROM #Accrual accrual
    WHERE accrual.IsAccrualReady = 0 AND accrual.TaxDue IS NOT NULL
)
    THROW 51455, 'A non-ready Project event exposed a usable CT accrual.', 1;

IF EXISTS
(
    SELECT CONVERT(datetime, accrual.StartOn) AS StartOn,
           accrual.ProjectCode,
           accrual.QuantityRemaining,
           accrual.OrderValue,
           accrual.TaxDue
    FROM #Accrual accrual
    WHERE accrual.IsAccrualReady = 1
      AND accrual.TaxDue IS NOT NULL
    EXCEPT
    SELECT live.StartOn,
           live.ProjectCode,
           live.QuantityRemaining,
           live.OrderValue,
           live.TaxDue
    FROM Cash.vwTaxBizAccruals live
)
OR EXISTS
(
    SELECT live.StartOn,
           live.ProjectCode,
           live.QuantityRemaining,
           live.OrderValue,
           live.TaxDue
    FROM Cash.vwTaxBizAccruals live
    EXCEPT
    SELECT CONVERT(datetime, accrual.StartOn),
           accrual.ProjectCode,
           accrual.QuantityRemaining,
           accrual.OrderValue,
           accrual.TaxDue
    FROM #Accrual accrual
    WHERE accrual.IsAccrualReady = 1
      AND accrual.TaxDue IS NOT NULL
)
    THROW 51456, 'The live business-tax accrual contract does not equal the selected UK provider.', 1;

SELECT accrual.LiabilityYearNumber,
       ProjectRows = SUM(CASE WHEN accrual.IsCarryEffect = 0 THEN 1 ELSE 0 END),
       CarryRows = SUM(CASE WHEN accrual.IsCarryEffect = 1 THEN 1 ELSE 0 END),
       TaxDue = CONVERT(decimal(38,5), SUM(accrual.TaxDue))
FROM #Accrual accrual
GROUP BY accrual.LiabilityYearNumber
ORDER BY accrual.LiabilityYearNumber;
