CREATE VIEW [Cash].[vwCategoryActive]
AS
SELECT
    category.VersionId,
    category.CategoryCode,
    category.Category,
    category.CategoryTypeCode,
    category.CashPolarityCode,
    category.CashTypeCode,
    category.DisplayOrder,
    category.IsEnabled,
    category.InsertedBy,
    category.InsertedOn,
    category.UpdatedBy,
    category.UpdatedOn,
    category.RowVer
FROM App.tbOptions AS options
JOIN Cash.tbCategory AS category
  ON category.VersionId = options.CategoryVersionId;
