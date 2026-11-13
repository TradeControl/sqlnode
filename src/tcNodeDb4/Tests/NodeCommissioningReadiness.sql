/*
    Derived node-commissioning regression.

    Run against a commissioned node. The fixture temporarily removes the
    active Category Tree pointer and always rolls the transaction back.
*/
SET NOCOUNT ON;
SET XACT_ABORT ON;

DECLARE
    @Identifier nvarchar(4),
    @CategoryVersionId nvarchar(10);

SELECT
    @Identifier = options.Identifier,
    @CategoryVersionId = options.CategoryVersionId
FROM App.tbOptions AS options
JOIN Cash.tbCategoryVersion AS version
  ON version.VersionId = options.CategoryVersionId
WHERE version.VersionStatusCode IN (1, 2);

IF @Identifier IS NULL OR @CategoryVersionId IS NULL
    THROW 52003, 'The fixture requires a commissioned node.', 1;

BEGIN TRY
    BEGIN TRANSACTION;

    UPDATE App.tbOptions
    SET CategoryVersionId = NULL
    WHERE Identifier = @Identifier;

    IF EXISTS
    (
        SELECT 1
        FROM App.tbOptions AS options
        JOIN Cash.tbCategoryVersion AS version
          ON version.VersionId = options.CategoryVersionId
        WHERE version.VersionStatusCode IN (1, 2)
    )
        THROW 52004, 'A node without an active Category Tree was classified as commissioned.', 1;

    UPDATE App.tbOptions
    SET CategoryVersionId = @CategoryVersionId
    WHERE Identifier = @Identifier;

    IF NOT EXISTS
    (
        SELECT 1
        FROM App.tbOptions AS options
        JOIN Cash.tbCategoryVersion AS version
          ON version.VersionId = options.CategoryVersionId
        WHERE version.VersionStatusCode IN (1, 2)
    )
        THROW 52005, 'A node with an active Published or Submitted Category Tree was not classified as commissioned.', 1;

    ROLLBACK TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    THROW;
END CATCH;

SELECT
    options.Identifier,
    options.CategoryVersionId,
    version.VersionStatusCode,
    IsCommissioned = CONVERT(bit, 1)
FROM App.tbOptions AS options
JOIN Cash.tbCategoryVersion AS version
  ON version.VersionId = options.CategoryVersionId
WHERE version.VersionStatusCode IN (1, 2);
