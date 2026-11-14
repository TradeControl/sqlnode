/*
    Canonical uninvoiced order-book facts used by business-tax accruals.

    Project cash codes are selected from App.vwTaxBizCashCodes, the active
    Category Tree profit root. Invoice rows are consolidated before they are
    subtracted from a Project.
    This prevents one Project from being repeated for each invoice line and
    aligns the remaining-quantity rule with Cash.vwStatementBase. Credit and
    debit notes settle invoice balances but do not fulfil additional Project
    quantity, so only sales and purchase invoices reduce the order book.
*/
CREATE VIEW Cash.vwTaxBizOrderBook
AS
WITH confirmed AS
(
    SELECT project.ProjectCode,
           project.CashCode,
           project.ActionOn,
           project.Quantity,
           OrderValue = CONVERT(decimal(38,5), CASE category.CashPolarityCode
               WHEN 0 THEN project.TotalCharge * -1 ELSE project.TotalCharge END)
    FROM Project.tbProject project
    JOIN App.vwTaxBizCashCodes category
      ON category.CashCode = project.CashCode
    WHERE project.ProjectStatusCode BETWEEN 1 AND 2
      AND project.ActionOn <=
          (SELECT DATEADD(day, TaxHorizon, CURRENT_TIMESTAMP) FROM App.tbOptions)
), invoiced AS
(
    SELECT invoice_project.ProjectCode,
           InvoiceQuantity = SUM(invoice_project.Quantity),
           InvoiceValue = CONVERT(decimal(38,5), SUM(CASE invoice_type.CashPolarityCode
               WHEN 0 THEN invoice_project.InvoiceValue * -1
               ELSE invoice_project.InvoiceValue END))
    FROM Invoice.tbProject invoice_project
    JOIN Invoice.tbInvoice invoice
      ON invoice.InvoiceNumber = invoice_project.InvoiceNumber
     AND invoice.InvoiceTypeCode IN (0, 2)
    JOIN Invoice.tbType invoice_type
      ON invoice_type.InvoiceTypeCode = invoice.InvoiceTypeCode
    GROUP BY invoice_project.ProjectCode
), remaining AS
(
    SELECT confirmed.ProjectCode,
           confirmed.CashCode,
           confirmed.ActionOn,
           QuantityRemaining = CONVERT(decimal(18,4),
               confirmed.Quantity - COALESCE(invoiced.InvoiceQuantity, 0)),
           OrderValue = CONVERT(decimal(38,5),
               confirmed.OrderValue - COALESCE(invoiced.InvoiceValue, 0))
    FROM confirmed
    LEFT JOIN invoiced ON invoiced.ProjectCode = confirmed.ProjectCode
)
SELECT period.StartOn,
       period.YearNumber,
       remaining.ProjectCode,
       remaining.CashCode,
       remaining.ActionOn,
       remaining.QuantityRemaining,
       remaining.OrderValue
FROM remaining
CROSS APPLY
(
    SELECT TOP (1) year_period.StartOn, year_period.YearNumber
    FROM App.tbYearPeriod year_period
    WHERE year_period.StartOn <= remaining.ActionOn
    ORDER BY year_period.StartOn DESC
) period
WHERE remaining.QuantityRemaining > 0;
GO
