CREATE FUNCTION Cash.fnCategoryCashCodes
(	
	@CategoryCode nvarchar(10)
)
RETURNS TABLE 
AS
RETURN 
(
    WITH ct_parent AS
    (
        SELECT c.CategoryCode, c.CategoryTypeCode
        FROM Cash.tbCategory c
        WHERE c.CategoryCode = @CategoryCode

        UNION ALL

        SELECT ct.ChildCode CategoryCode, c.CategoryTypeCode
        FROM ct_parent
            JOIN Cash.tbCategoryTotal ct
                ON ct.ParentCode = ct_parent.CategoryCode
            JOIN Cash.tbCategory c
                ON ct.ChildCode = c.CategoryCode
        WHERE c.IsEnabled != 0
    ), cat AS
    (
        SELECT c.CategoryCode
        FROM ct_parent c
        WHERE c.CategoryTypeCode = 0
    )
    SELECT cc.CashCode, cc.CategoryCode
    FROM Cash.tbCode cc
        JOIN cat
            ON cat.CategoryCode = cc.CategoryCode
    WHERE cc.IsEnabled != 0
)

GO

