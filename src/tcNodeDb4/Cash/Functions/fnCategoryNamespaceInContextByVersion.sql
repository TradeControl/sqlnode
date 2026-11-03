CREATE FUNCTION [Cash].[fnCategoryNamespaceInContextByVersion]
(
    @VersionId NVARCHAR(10),
    @CategoryCode NVARCHAR(10),
    @ParentCode NVARCHAR(10) = NULL
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

    ;WITH ParentGiven AS
    (
        SELECT edge.ChildCode, edge.ParentCode, 1 AS rn
        FROM Cash.tbCategoryTotal AS edge
        WHERE edge.VersionId = @VersionId
          AND @ParentCode IS NOT NULL
          AND edge.ChildCode = @CategoryCode
          AND edge.ParentCode = @ParentCode
    ),
    ParentRank AS
    (
        SELECT
            edge.ChildCode,
            edge.ParentCode,
            ROW_NUMBER() OVER
            (
                PARTITION BY edge.ChildCode
                ORDER BY parent.DisplayOrder, parent.Category, parent.CategoryCode
            ) AS rn
        FROM Cash.tbCategoryTotal AS edge
        JOIN Cash.tbCategory AS parent
          ON parent.VersionId = edge.VersionId
         AND parent.CategoryCode = edge.ParentCode
        WHERE edge.VersionId = @VersionId
    ),
    ParentMap AS
    (
        SELECT ChildCode, ParentCode FROM ParentGiven
        UNION ALL
        SELECT ranked.ChildCode, ranked.ParentCode
        FROM ParentRank AS ranked
        WHERE ranked.rn = 1
          AND NOT EXISTS
          (
              SELECT 1 FROM ParentGiven AS given
              WHERE given.ChildCode = ranked.ChildCode
          )
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
