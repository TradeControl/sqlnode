CREATE VIEW [Cash].[vwCategoryRootActive]
AS
SELECT
    root.VersionId,
    root.RootTypeCode,
    root.CategoryCode,
    root.RowVer
FROM App.tbOptions AS options
JOIN Cash.tbCategoryRoot AS root
  ON root.VersionId = options.CategoryVersionId;
