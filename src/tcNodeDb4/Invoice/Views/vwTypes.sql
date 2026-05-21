CREATE VIEW Invoice.vwTypes
AS
    SELECT
        t.InvoiceTypeCode,
        t.InvoiceType,
        t.CashPolarityCode,
        p.CashPolarity,
        t.NextNumber
    FROM Invoice.tbType t
        INNER JOIN Cash.tbPolarity p
            ON t.CashPolarityCode = p.CashPolarityCode;
