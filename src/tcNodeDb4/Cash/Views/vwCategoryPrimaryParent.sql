CREATE VIEW [Cash].[vwCategoryPrimaryParent]
AS
SELECT
    parent.ChildCode,
    parent.ParentCode,
    parent.RootCode,
    parent.PrimaryKind,
    parent.Depth,
    parent.rn,
    parent.ParentCount
FROM App.tbOptions AS options
CROSS APPLY Cash.fnCategoryPrimaryParentByVersion(options.CategoryVersionId) AS parent;
