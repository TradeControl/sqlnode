/*
    Canonical business-tax order-book regression.

    Read-only: proves invoice consolidation, uniqueness and exact reconciliation
    to the confirmed less base-invoiced Project facts.
*/
SET NOCOUNT ON;
SET XACT_ABORT ON;

IF OBJECT_ID(N'Cash.vwTaxBizOrderBook', N'V') IS NULL
    THROW 51430, 'The canonical business-tax order-book view is not deployed.', 1;

IF EXISTS
(
    SELECT ProjectCode
    FROM Cash.vwTaxBizOrderBook
    GROUP BY ProjectCode
    HAVING COUNT_BIG(*) <> 1
)
    THROW 51431, 'The canonical business-tax order book contains duplicate Projects.', 1;

IF EXISTS (SELECT 1 FROM Cash.vwTaxBizOrderBook WHERE QuantityRemaining <= 0)
    THROW 51432, 'The canonical business-tax order book contains a fulfilled or over-invoiced Project.', 1;

IF EXISTS
(
    SELECT 1
    FROM Cash.vwTaxBizOrderBook order_book
    LEFT JOIN App.vwTaxBizCashCodes tax_code ON tax_code.CashCode = order_book.CashCode
    WHERE tax_code.CashCode IS NULL
)
    THROW 51434, 'The canonical business-tax order book contains a cash code outside the active profit root.', 1;

WITH confirmed AS
(
    SELECT project.ProjectCode,
           project.CashCode,
           project.ActionOn,
           project.Quantity,
           OrderValue = CONVERT(decimal(38,5), CASE category.CashPolarityCode
               WHEN 0 THEN project.TotalCharge * -1 ELSE project.TotalCharge END)
    FROM Project.tbProject project
    JOIN App.vwTaxBizCashCodes category ON category.CashCode = project.CashCode
    WHERE project.ProjectStatusCode BETWEEN 1 AND 2
      AND project.ActionOn <=
          (SELECT DATEADD(day, TaxHorizon, CURRENT_TIMESTAMP) FROM App.tbOptions)
), invoiced AS
(
    SELECT invoice_project.ProjectCode,
           InvoiceQuantity = SUM(invoice_project.Quantity),
           InvoiceValue = CONVERT(decimal(38,5), SUM(CASE invoice_type.CashPolarityCode
               WHEN 0 THEN invoice_project.InvoiceValue * -1 ELSE invoice_project.InvoiceValue END))
    FROM Invoice.tbProject invoice_project
    JOIN Invoice.tbInvoice invoice
      ON invoice.InvoiceNumber = invoice_project.InvoiceNumber
     AND invoice.InvoiceTypeCode IN (0, 2)
    JOIN Invoice.tbType invoice_type ON invoice_type.InvoiceTypeCode = invoice.InvoiceTypeCode
    GROUP BY invoice_project.ProjectCode
), expected AS
(
    SELECT period.StartOn,
           period.YearNumber,
           confirmed.ProjectCode,
           confirmed.CashCode,
           confirmed.ActionOn,
           QuantityRemaining = CONVERT(decimal(18,4),
               confirmed.Quantity - COALESCE(invoiced.InvoiceQuantity, 0)),
           OrderValue = CONVERT(decimal(38,5),
               confirmed.OrderValue - COALESCE(invoiced.InvoiceValue, 0))
    FROM confirmed
    LEFT JOIN invoiced ON invoiced.ProjectCode = confirmed.ProjectCode
    CROSS APPLY
    (
        SELECT TOP (1) year_period.StartOn, year_period.YearNumber
        FROM App.tbYearPeriod year_period
        WHERE year_period.StartOn <= confirmed.ActionOn
        ORDER BY year_period.StartOn DESC
    ) period
    WHERE confirmed.Quantity - COALESCE(invoiced.InvoiceQuantity, 0) > 0
)
SELECT * INTO #ExpectedOrderBook FROM expected;

IF EXISTS
(
    SELECT * FROM #ExpectedOrderBook
    EXCEPT
    SELECT * FROM Cash.vwTaxBizOrderBook
)
OR EXISTS
(
    SELECT * FROM Cash.vwTaxBizOrderBook
    EXCEPT
    SELECT * FROM #ExpectedOrderBook
)
    THROW 51433, 'The canonical business-tax order book does not reconcile to confirmed less invoiced Projects.', 1;

SELECT YearNumber,
       ProjectRows = COUNT_BIG(*),
       OrderValue = SUM(OrderValue)
FROM Cash.vwTaxBizOrderBook
GROUP BY YearNumber
ORDER BY YearNumber;

DROP TABLE #ExpectedOrderBook;
