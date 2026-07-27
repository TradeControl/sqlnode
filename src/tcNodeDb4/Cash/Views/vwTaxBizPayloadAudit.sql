CREATE VIEW Cash.vwTaxBizPayloadAudit
AS
WITH windows AS
(
    SELECT DISTINCT
        TaxSourceCode,
        TagCode,
        PeriodFrom,
        PeriodTo
    FROM Cash.vwTagCashPeriodMap
)
, raw AS
(
    SELECT
        w.TaxSourceCode,
        w.TagCode,
        c.CashCode,
        w.PeriodFrom,
        w.PeriodTo,
        SUM(c.InvoiceValue) AS RawTotal
    FROM windows w
    JOIN Cash.vwCashCodePeriodValues c
        ON c.StartOn >= w.PeriodFrom
       AND c.StartOn <  w.PeriodTo
    GROUP BY
        w.TaxSourceCode,
        w.TagCode,
        c.CashCode,
        w.PeriodFrom,
        w.PeriodTo
)
, payload AS
(
    SELECT
        TaxSourceCode,
        TagCode,
        CashCode,
        PeriodFrom,
        PeriodTo,
        SUM(PeriodInvoiceValue) AS PayloadTotal
    FROM Cash.vwTaxBizPayload
    GROUP BY
        TaxSourceCode,
        TagCode,
        CashCode,
        PeriodFrom,
        PeriodTo
)
SELECT
    r.TaxSourceCode,
    r.TagCode,
    r.CashCode,
    r.PeriodFrom,
    r.PeriodTo,
    r.RawTotal,
    COALESCE(p.PayloadTotal, 0) PayloadTotal,
    CASE WHEN p.PayloadTotal IS NULL THEN 0 ELSE (p.PayloadTotal - r.RawTotal) END AS Difference
FROM raw r
LEFT JOIN payload p
    ON p.TaxSourceCode = r.TaxSourceCode
   AND p.TagCode       = r.TagCode
   AND p.CashCode      = r.CashCode
   AND p.PeriodFrom    = r.PeriodFrom
   AND p.PeriodTo      = r.PeriodTo
--ORDER BY
--    r.TaxSourceCode,
--    r.TagCode,
--    r.CashCode,
--    r.PeriodFrom;
