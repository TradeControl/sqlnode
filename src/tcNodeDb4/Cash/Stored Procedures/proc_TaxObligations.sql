CREATE PROCEDURE [Cash].[proc_TaxObligations]
AS
	SELECT TOP (1) CAST(Balance AS decimal(18,5))
	FROM Cash.vwTaxVatStatement
	WHERE StartOn >= CAST(GETDATE() AS date)
	ORDER BY StartOn;

	SELECT TOP (1) CAST(Balance AS decimal(18,5))
	FROM Cash.vwTaxBizStatement
	WHERE StartOn >= CAST(GETDATE() AS date)
	ORDER BY StartOn;
