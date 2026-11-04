CREATE FUNCTION Cash.fnFlowCategoryByVersion
(
    @CategoryVersionId nvarchar(10),
    @CashTypeCode smallint
)
RETURNS TABLE
AS
RETURN
(
    SELECT CategoryCode, Category, CashPolarityCode, DisplayOrder
    FROM Cash.tbCategory
    WHERE VersionId = @CategoryVersionId
      AND CategoryTypeCode = 0
      AND CashTypeCode = @CashTypeCode
      AND IsEnabled <> 0
);
