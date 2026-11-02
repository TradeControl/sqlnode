CREATE VIEW [Cash].[vwCodeActive]
AS
SELECT
    map.VersionId,
    code.CashCode,
    code.CashDescription,
    map.CategoryCode,
    code.TaxCode,
    code.IsEnabled,
    code.InsertedBy,
    code.InsertedOn,
    code.UpdatedBy,
    code.UpdatedOn,
    code.RowVer
FROM App.tbOptions AS options
JOIN Cash.tbCategoryCodeMap AS map
  ON map.VersionId = options.CategoryVersionId
JOIN Cash.tbCode AS code
  ON code.CashCode = map.CashCode;
