CREATE FUNCTION [Cash].[fnCategoryNamespace]
(
    @CategoryCode VARCHAR(10)
)
RETURNS NVARCHAR(MAX)
AS
BEGIN
    DECLARE @VersionId NVARCHAR(10) = (SELECT CategoryVersionId FROM App.tbOptions);
    RETURN Cash.fnCategoryNamespaceByVersion(@VersionId, @CategoryCode);
END;
