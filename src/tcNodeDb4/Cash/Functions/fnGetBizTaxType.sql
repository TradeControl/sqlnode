CREATE FUNCTION Cash.fnGetBizTaxType()
RETURNS INT
AS
BEGIN
    DECLARE @TaxTypeCode smallint

    SELECT @TaxTypeCode = TaxTypeCode
    FROM Cash.tbTaxType
    WHERE TaxTypeCode IN (0, 4) AND IsEnabled = 1

	RETURN @TaxTypeCode
END
