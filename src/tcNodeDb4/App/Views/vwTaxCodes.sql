CREATE VIEW App.vwTaxCodes
AS
    SELECT
        tc.TaxCode,
        tc.TaxDescription,
        tt.TaxType,
        tc.TaxTypeCode,
        tc.RoundingCode,
        r.Rounding,
        tc.TaxRate,
        tc.Decimals,
        tc.UpdatedBy,
        tc.UpdatedOn
    FROM App.tbTaxCode tc
        INNER JOIN Cash.tbTaxType tt
            ON tc.TaxTypeCode = tt.TaxTypeCode
        INNER JOIN App.tbRounding r
            ON tc.RoundingCode = r.RoundingCode;
