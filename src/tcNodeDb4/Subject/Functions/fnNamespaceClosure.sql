CREATE FUNCTION Subject.fnNamespaceClosure
(
    @SubjectCode nvarchar(50),
    @ParentSubjectCode nvarchar(50) = NULL
)
RETURNS TABLE
AS
RETURN
(
    WITH root_edge AS
    (
        SELECT
            CAST(@SubjectCode AS nvarchar(50)) AS SubjectCode,
            CAST(@ParentSubjectCode AS nvarchar(50)) AS ParentSubjectCode,
            0 AS Depth
        WHERE NULLIF(LTRIM(RTRIM(@SubjectCode)), N'') IS NOT NULL
          AND
          (
              (
                  @ParentSubjectCode IS NULL
                  AND EXISTS
                  (
                      SELECT 1
                      FROM Subject.tbSubject AS s
                      WHERE s.SubjectCode = @SubjectCode
                  )
              )
              OR EXISTS
              (
                  SELECT 1
                  FROM Subject.tbNamespace AS n
                  WHERE n.ParentSubjectCode = @ParentSubjectCode
                    AND n.ChildSubjectCode = @SubjectCode
              )
          )
    ),
    closure AS
    (
        SELECT
            SubjectCode,
            ParentSubjectCode,
            Depth
        FROM root_edge

        UNION ALL

        SELECT
            n.ChildSubjectCode AS SubjectCode,
            n.ParentSubjectCode,
            c.Depth + 1 AS Depth
        FROM closure AS c
            JOIN Subject.tbNamespace AS n
                ON n.ParentSubjectCode = c.SubjectCode
    )
    SELECT
        SubjectCode,
        ParentSubjectCode,
        MIN(Depth) AS Depth
    FROM closure
    GROUP BY
        SubjectCode,
        ParentSubjectCode
);
GO
