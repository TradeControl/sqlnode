CREATE FUNCTION [Cash].[fnCategoryVersionDefault]()
RETURNS NVARCHAR(10)
AS
BEGIN
    DECLARE @VersionId NVARCHAR(10);

    SELECT @VersionId = MIN([VersionId])
    FROM [Cash].[tbCategoryVersion]
    HAVING COUNT(*) = 1;

    RETURN @VersionId;
END;
