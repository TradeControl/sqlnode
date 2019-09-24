CREATE   FUNCTION Cash.fnFlowCategory(@CashTypeCode SMALLINT)
RETURNS TABLE
AS
	RETURN
	(
		SELECT        CategoryCode, Category, CategoryTypeCode, CashModeCode, CashTypeCode, DisplayOrder, IsEnabled, InsertedBy, InsertedOn, UpdatedBy, UpdatedOn, RowVer
		FROM            Cash.tbCategory
		WHERE        (CategoryTypeCode = 0) AND (CashTypeCode = @CashTypeCode) AND (IsEnabled <> 0)		
	)
