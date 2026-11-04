CREATE FUNCTION Cash.fnCategoryCodeResolveByVersion
(
    @CategoryVersionId nvarchar(10),
    @Token nvarchar(100)
)
RETURNS nvarchar(10)
AS
BEGIN
    RETURN
    (
        SELECT CASE
            WHEN EXISTS (SELECT 1 FROM Cash.tbCategory WHERE VersionId = @CategoryVersionId AND CategoryCode = @Token)
                THEN @Token
            WHEN EXISTS
            (
                SELECT 1
                FROM Cash.tbCategoryCodeMap AS category_code
                JOIN Cash.tbCode AS code ON code.CashCode = category_code.CashCode
                WHERE category_code.VersionId = @CategoryVersionId
                  AND category_code.CashCode = @Token
                  AND code.IsEnabled <> 0
            ) THEN @Token
            WHEN (SELECT COUNT(*) FROM Cash.tbCategory WHERE VersionId = @CategoryVersionId AND Category = @Token) = 1
                THEN (SELECT CategoryCode FROM Cash.tbCategory WHERE VersionId = @CategoryVersionId AND Category = @Token)
            WHEN NOT EXISTS (SELECT 1 FROM Cash.tbCategory WHERE VersionId = @CategoryVersionId AND Category = @Token)
             AND
             (
                SELECT COUNT(*)
                FROM Cash.tbCategoryCodeMap AS category_code
                JOIN Cash.tbCode AS code ON code.CashCode = category_code.CashCode
                WHERE category_code.VersionId = @CategoryVersionId
                  AND code.CashDescription = @Token
                  AND code.IsEnabled <> 0
             ) = 1
                THEN
                (
                    SELECT category_code.CashCode
                    FROM Cash.tbCategoryCodeMap AS category_code
                    JOIN Cash.tbCode AS code ON code.CashCode = category_code.CashCode
                    WHERE category_code.VersionId = @CategoryVersionId
                      AND code.CashDescription = @Token
                      AND code.IsEnabled <> 0
                )
            ELSE N''
        END
    );
END;
