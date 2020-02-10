

CREATE   VIEW App.vwTaxCodes
AS
SELECT        App.tbTaxCode.TaxCode, App.tbTaxCode.TaxDescription, Cash.tbTaxType.TaxType
FROM            App.tbTaxCode INNER JOIN
                         Cash.tbTaxType ON App.tbTaxCode.TaxTypeCode = Cash.tbTaxType.TaxTypeCode;
