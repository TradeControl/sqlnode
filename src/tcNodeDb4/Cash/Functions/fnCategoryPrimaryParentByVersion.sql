CREATE FUNCTION [Cash].[fnCategoryPrimaryParentByVersion]
(
    @VersionId NVARCHAR(10)
)
RETURNS TABLE
AS
RETURN
(
    WITH roots AS
    (
        SELECT
            root.CategoryCode AS RootCode,
            CASE root.RootTypeCode
                WHEN 0 THEN CAST(N'Profit' AS NVARCHAR(10))
                WHEN 1 THEN CAST(N'VAT' AS NVARCHAR(10))
            END AS PrimaryKind
        FROM Cash.tbCategoryRoot AS root
        WHERE root.VersionId = @VersionId
          AND root.RootTypeCode IN (0, 1)
    ),
    paths AS
    (
        SELECT
            root.RootCode,
            root.PrimaryKind,
            edge.ParentCode,
            edge.ChildCode,
            1 AS Depth
        FROM roots AS root
        JOIN Cash.tbCategoryTotal AS edge
          ON edge.VersionId = @VersionId
         AND edge.ParentCode = root.RootCode

        UNION ALL

        SELECT
            path.RootCode,
            path.PrimaryKind,
            edge.ParentCode,
            edge.ChildCode,
            path.Depth + 1
        FROM paths AS path
        JOIN Cash.tbCategoryTotal AS edge
          ON edge.VersionId = @VersionId
         AND edge.ParentCode = path.ChildCode
    ),
    ranked AS
    (
        SELECT
            path.ChildCode,
            path.ParentCode,
            path.RootCode,
            path.PrimaryKind,
            path.Depth,
            ROW_NUMBER() OVER
            (
                PARTITION BY path.ChildCode
                ORDER BY path.Depth, parent.DisplayOrder, parent.Category, parent.CategoryCode
            ) AS rn
        FROM paths AS path
        JOIN Cash.tbCategory AS parent
          ON parent.VersionId = @VersionId
         AND parent.CategoryCode = path.ParentCode
    ),
    parent_aggregate AS
    (
        SELECT edge.ChildCode, COUNT(*) AS ParentCount
        FROM Cash.tbCategoryTotal AS edge
        WHERE edge.VersionId = @VersionId
        GROUP BY edge.ChildCode
    )
    SELECT
        ranked.ChildCode,
        ranked.ParentCode,
        ranked.RootCode,
        ranked.PrimaryKind,
        ranked.Depth,
        ranked.rn,
        parent_aggregate.ParentCount
    FROM ranked
    LEFT JOIN parent_aggregate
      ON parent_aggregate.ChildCode = ranked.ChildCode
);
