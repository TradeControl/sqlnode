CREATE   FUNCTION Cash.fnFlowCategoryTotalCodes(@CategoryCode NVARCHAR(10))
RETURNS TABLE
AS
	RETURN
	(
		SELECT ChildCode AS CategoryCode FROM Cash.vwCategoryTotalActive WHERE ParentCode = @CategoryCode
	)
