CREATE FUNCTION Cash.fnCategoryExpressionsByVersion
(
    @CategoryVersionId nvarchar(10)
)
RETURNS TABLE
AS
RETURN
(
    SELECT category.DisplayOrder,
           category.CategoryCode,
           category.Category,
           expression.Expression,
           CASE COALESCE(template.Template, N'')
               WHEN N'' THEN expression.Format
               ELSE template.Template
           END AS Format
    FROM Cash.tbCategory AS category
    JOIN Cash.tbCategoryExp AS expression
      ON expression.CategoryCode = category.CategoryCode
    LEFT JOIN Cash.tbCategoryExprFormat AS template
      ON template.TemplateCode = expression.Format
    WHERE category.VersionId = @CategoryVersionId
      AND category.CategoryTypeCode = 2
      AND category.IsEnabled <> 0
      AND expression.SyntaxTypeCode IN (0, 2)
);
