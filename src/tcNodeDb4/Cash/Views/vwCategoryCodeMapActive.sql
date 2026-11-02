CREATE VIEW [Cash].[vwCategoryCodeMapActive]
AS
SELECT
    map.VersionId,
    map.CashCode,
    map.CategoryCode,
    map.RowVer
FROM App.tbOptions AS options
JOIN Cash.tbCategoryCodeMap AS map
  ON map.VersionId = options.CategoryVersionId;
