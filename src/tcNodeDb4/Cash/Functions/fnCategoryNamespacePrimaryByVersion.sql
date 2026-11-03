CREATE FUNCTION [Cash].[fnCategoryNamespacePrimaryByVersion]
(
    @VersionId NVARCHAR(10),
    @CategoryCode NVARCHAR(10)
)
RETURNS NVARCHAR(MAX)
AS
BEGIN
    DECLARE @Result NVARCHAR(MAX);

    IF @VersionId IS NULL OR @CategoryCode IS NULL OR LEN(@CategoryCode) = 0
        RETURN NULL;

    IF NOT EXISTS
    (
        SELECT 1 FROM Cash.tbCategory
        WHERE VersionId = @VersionId AND CategoryCode = @CategoryCode
    )
        RETURN NULL;

    IF NOT EXISTS
    (
        SELECT 1 FROM Cash.tbCategoryTotal
        WHERE VersionId = @VersionId
          AND (ParentCode = @CategoryCode OR ChildCode = @CategoryCode)
    )
    BEGIN
        SELECT @Result = N'Disconnected.' + REPLACE(Category, N' ', N'_')
        FROM Cash.tbCategory
        WHERE VersionId = @VersionId AND CategoryCode = @CategoryCode;

        RETURN App.fnToAlphaNumeric(@Result);
    END;

    ;WITH ParentMap AS
    (
        SELECT ChildCode, ParentCode
        FROM Cash.fnCategoryPrimaryParentByVersion(@VersionId)
        WHERE rn = 1
    ),
    ParentCTE AS
    (
        SELECT
            category.CategoryCode,
            REPLACE(category.Category, N' ', N'_') AS [Path],
            CAST(0 AS INT) AS Depth
        FROM Cash.tbCategory AS category
        WHERE category.VersionId = @VersionId
          AND category.CategoryCode = @CategoryCode

        UNION ALL

        SELECT
            parent_map.ParentCode,
            REPLACE(parent.Category, N' ', N'_') + N'.' + category_path.[Path],
            category_path.Depth + 1
        FROM ParentCTE AS category_path
        JOIN ParentMap AS parent_map
          ON parent_map.ChildCode = category_path.CategoryCode
        JOIN Cash.tbCategory AS parent
          ON parent.VersionId = @VersionId
         AND parent.CategoryCode = parent_map.ParentCode
    )
    SELECT TOP (1) @Result = [Path]
    FROM ParentCTE
    ORDER BY Depth DESC;

    RETURN App.fnToAlphaNumeric(@Result);
END;
