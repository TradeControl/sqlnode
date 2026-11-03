CREATE FUNCTION [Cash].[fnTaxTagMapValidate]
(
    @TaxSourceCode NVARCHAR(20)
)
RETURNS TABLE
AS
RETURN
(
    SELECT validation.*
    FROM App.tbOptions AS options
    CROSS APPLY Cash.fnTaxTagMapValidateByVersion
    (
        @TaxSourceCode,
        COALESCE
        (
            options.CategoryVersionId,
            CASE WHEN options.IsInitialised = 0 THEN
                (
                    SELECT MIN(version.VersionId)
                    FROM Cash.tbCategoryVersion AS version
                    HAVING COUNT(*) = 1
                )
            END
        )
    ) AS validation
);
