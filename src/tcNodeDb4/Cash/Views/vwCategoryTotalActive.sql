CREATE VIEW [Cash].[vwCategoryTotalActive]
AS
SELECT
    total.VersionId,
    total.ParentCode,
    total.ChildCode,
    total.DisplayOrder,
    total.RowVer
FROM App.tbOptions AS options
JOIN Cash.tbCategoryTotal AS total
  ON total.VersionId = options.CategoryVersionId;
