
CREATE   VIEW Cash.vwExternalCodesLookup
AS
SELECT        Cash.vwCodeActive.CashCode, Cash.vwCodeActive.CashDescription, Cash.vwCategoryActive.Category
FROM            Cash.vwCodeActive INNER JOIN
                         Cash.vwCategoryActive ON Cash.vwCodeActive.CategoryCode = Cash.vwCategoryActive.CategoryCode
WHERE        (Cash.vwCategoryActive.CashTypeCode = 1);
