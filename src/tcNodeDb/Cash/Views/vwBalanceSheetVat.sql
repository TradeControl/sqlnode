CREATE   VIEW Cash.vwBalanceSheetVat
AS
	SELECT tax_type.AssetCode, tax_type.AssetName, 
		CAST(0 as smallint) CashModeCode,  
		CAST(1 as smallint) AssetTypeCode,  
		DATEADD(MONTH, 1, DATEADD(DAY, (DATEPART(DAY, StartOn) * -1) + 1, StartOn)) StartOn, 		
		Balance * -1 Balance 
	FROM Cash.vwTaxVatStatement
		CROSS JOIN
		(
			SELECT UPPER(LEFT(TaxType, 3)) AssetCode, UPPER(TaxType) AssetName
			FROM Cash.tbTaxType
			WHERE TaxTypeCode = 1
		) tax_type;
