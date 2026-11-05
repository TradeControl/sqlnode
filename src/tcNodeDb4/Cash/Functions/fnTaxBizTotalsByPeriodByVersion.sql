CREATE FUNCTION Cash.fnTaxBizTotalsByPeriodByVersion
(
    @CategoryVersionId nvarchar(10)
)
RETURNS TABLE
AS
RETURN
(
    WITH cash_codes AS
    (
        SELECT CategoryCode, CashCode, CashTypeCode, CashPolarityCode
        FROM App.fnTaxBizCashCodesByVersion(@CategoryVersionId)
    ),
    invoiced_projects AS
    (
        SELECT StartOn =
               (
                   SELECT TOP (1) period.StartOn
                   FROM App.tbYearPeriod AS period
                   WHERE period.StartOn <= invoice.InvoicedOn
                   ORDER BY period.StartOn DESC
               ),
               InvoiceValue = CASE invoice_type.CashPolarityCode
                   WHEN 0 THEN project.InvoiceValue * -1
                   ELSE project.InvoiceValue
               END
        FROM Invoice.tbProject AS project
        JOIN cash_codes
          ON cash_codes.CashCode = project.CashCode
        JOIN Invoice.tbInvoice AS invoice
          ON invoice.InvoiceNumber = project.InvoiceNumber
        JOIN Invoice.tbType AS invoice_type
          ON invoice_type.InvoiceTypeCode = invoice.InvoiceTypeCode
        WHERE cash_codes.CashTypeCode < 3
    ),
    invoiced_items AS
    (
        SELECT StartOn =
               (
                   SELECT TOP (1) period.StartOn
                   FROM App.tbYearPeriod AS period
                   WHERE period.StartOn <= invoice.InvoicedOn
                   ORDER BY period.StartOn DESC
               ),
               InvoiceValue = CASE invoice_type.CashPolarityCode
                   WHEN 0 THEN item.InvoiceValue * -1
                   ELSE item.InvoiceValue
               END
        FROM Invoice.tbItem AS item
        JOIN cash_codes
          ON cash_codes.CashCode = item.CashCode
        JOIN Invoice.tbInvoice AS invoice
          ON invoice.InvoiceNumber = item.InvoiceNumber
        JOIN Invoice.tbType AS invoice_type
          ON invoice_type.InvoiceTypeCode = invoice.InvoiceTypeCode
        WHERE cash_codes.CashTypeCode < 3
    ),
    assets AS
    (
        SELECT period.StartOn,
               AssetValue = CASE cash_codes.CashPolarityCode
                   WHEN 0 THEN period.InvoiceValue * -1
                   ELSE period.InvoiceValue
               END
        FROM cash_codes
        JOIN Cash.tbPeriod AS period
          ON period.CashCode = cash_codes.CashCode
        WHERE cash_codes.CashTypeCode = 2
    ),
    netprofits AS
    (
        SELECT StartOn, NetProfit = SUM(InvoiceValue)
        FROM invoiced_projects
        GROUP BY StartOn

        UNION

        SELECT StartOn, NetProfit = SUM(InvoiceValue)
        FROM invoiced_items
        GROUP BY StartOn

        UNION

        SELECT StartOn, NetProfit = SUM(AssetValue)
        FROM assets
        GROUP BY StartOn
    ),
    netprofit_consolidated AS
    (
        SELECT StartOn, NetProfit = SUM(NetProfit)
        FROM netprofits
        GROUP BY StartOn
    )
    SELECT period.StartOn,
           netprofit.NetProfit,
           BusinessTax = CAST(netprofit.NetProfit * period.BusinessTaxRate
               + period.BusinessTaxAdjustment AS decimal(18,5)),
           period.BusinessTaxAdjustment
    FROM netprofit_consolidated AS netprofit
    JOIN App.tbYearPeriod AS period
      ON period.StartOn = netprofit.StartOn
);
