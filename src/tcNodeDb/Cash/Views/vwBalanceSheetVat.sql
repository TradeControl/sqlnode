CREATE   VIEW Cash.vwBalanceSheetVat
AS
	WITH asset_rows AS
	(
		SELECT StartOn, MAX(RowNumber) AssetRow
		FROM Cash.vwTaxVatStatement
		GROUP BY StartOn
	)
	SELECT tax_type.AssetCode, tax_type.AssetName, 
		CAST(0 as smallint) CashModeCode,  
		CAST(1 as smallint) AssetTypeCode,  
		DATEADD(MONTH, 1, DATEADD(DAY, (DATEPART(DAY, vat.StartOn) * -1) + 1, vat.StartOn)) StartOn, 		
		Balance * -1 Balance 
	FROM Cash.vwTaxVatStatement vat
		JOIN asset_rows ON vat.RowNumber = asset_rows.AssetRow
		CROSS JOIN
		(
			SELECT UPPER(LEFT(TaxType, 3)) AssetCode, UPPER(TaxType) AssetName
			FROM Cash.tbTaxType
			WHERE TaxTypeCode = 1
		) tax_type;