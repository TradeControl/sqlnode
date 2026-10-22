CREATE PROCEDURE [Cash].[proc_TaxObligations]
    @AsOfDate date = NULL
AS
	BEGIN
	SET NOCOUNT ON;
	SET @AsOfDate = COALESCE(@AsOfDate, CONVERT(date, CURRENT_TIMESTAMP));

	SELECT TOP (1) CAST(Balance AS decimal(18,5))
	FROM Cash.vwTaxVatStatement
	WHERE StartOn >= @AsOfDate
	ORDER BY StartOn;

	SELECT TOP (1) CAST(Balance AS decimal(18,5))
	FROM Cash.vwTaxBizStatement
	WHERE StartOn >= @AsOfDate
	ORDER BY StartOn;
	END;
