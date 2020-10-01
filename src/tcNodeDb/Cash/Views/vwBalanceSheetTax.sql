CREATE   VIEW Cash.vwBalanceSheetTax
AS
	SELECT tax_type.AssetCode, tax_type.AssetName, 
		CAST(0 as smallint) CashModeCode,  
		CAST(1 as smallint) AssetTypeCode,  
		DATEADD(MONTH, 1, DATEADD(DAY, (DATEPART(DAY, StartOn) * -1) + 1, StartOn)) StartOn, 		
		CASE WHEN Balance < 0 THEN 0 ELSE Balance END Balance 
	FROM Cash.vwTaxCorpStatement
		CROSS JOIN
		(
			SELECT UPPER(LEFT(TaxType, 3)) AssetCode, UPPER(TaxType) AssetName
			FROM Cash.tbTaxType
			WHERE TaxTypeCode = 0
		) tax_type;
