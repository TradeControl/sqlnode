CREATE FUNCTION [Cash].[fnCategoryNamespaceInContext]
(
    @CategoryCode VARCHAR(10),
    @ParentCode VARCHAR(10) = NULL
)
RETURNS NVARCHAR(MAX)
AS
BEGIN
    DECLARE @VersionId NVARCHAR(10) = (SELECT CategoryVersionId FROM App.tbOptions);
    RETURN Cash.fnCategoryNamespaceInContextByVersion(@VersionId, @CategoryCode, @ParentCode);
END;
