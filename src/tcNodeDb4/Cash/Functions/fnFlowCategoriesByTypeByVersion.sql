CREATE FUNCTION Cash.fnFlowCategoriesByTypeByVersion
(
    @CategoryVersionId nvarchar(10),
    @CashTypeCode smallint,
    @CategoryTypeCode smallint
)
RETURNS TABLE
AS
RETURN
(
    SELECT category.DisplayOrder, category.CategoryCode, category.Category, cash_type.CashType
    FROM Cash.tbCategory AS category
    JOIN Cash.tbType AS cash_type
      ON cash_type.CashTypeCode = category.CashTypeCode
    WHERE category.VersionId = @CategoryVersionId
      AND category.CashTypeCode = @CashTypeCode
      AND category.CategoryTypeCode = @CategoryTypeCode
);
