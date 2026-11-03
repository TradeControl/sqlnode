CREATE   FUNCTION Cash.fnFlowCategoriesByType
	(
	@CashTypeCode smallint,
	@CategoryTypeCode smallint = 1
	)
RETURNS TABLE
AS
	RETURN (
		SELECT category.DisplayOrder, category.Category, Cash.tbType.CashType, category.CategoryCode
		FROM Cash.vwCategoryActive AS category
		INNER JOIN Cash.tbType ON category.CashTypeCode = Cash.tbType.CashTypeCode
		WHERE category.CashTypeCode = @CashTypeCode
		  AND category.CategoryTypeCode = @CategoryTypeCode
		)

