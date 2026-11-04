CREATE PROCEDURE [Cash].[proc_CategoryVersionValidate]
(
    @VersionId NVARCHAR(10),
    @CanonicalSha256 BINARY(32) = NULL OUTPUT,
    @CanonicalByteLength BIGINT = NULL OUTPUT
)
AS
BEGIN
    SET NOCOUNT, XACT_ABORT ON;

    DECLARE
        @VersionStatusCode SMALLINT,
        @UserId NVARCHAR(10),
        @UserName NVARCHAR(50);

    SELECT TOP (1) @UserId = UserId, @UserName = UserName
    FROM Usr.vwCredentials;

    IF @UserId IS NULL
        THROW 51110, 'Category Tree validation requires an enabled application user.', 1;

    BEGIN TRY
        BEGIN TRAN;

        SELECT @VersionStatusCode = VersionStatusCode
        FROM Cash.tbCategoryVersion WITH (UPDLOCK, HOLDLOCK)
        WHERE VersionId = @VersionId;

    IF @VersionStatusCode IS NULL
        THROW 51111, 'Category Tree validation requires a known version.', 1;

    IF @VersionStatusCode NOT IN (0, 1)
        THROW 51112, 'Only Draft or Published Category Tree versions can be validated.', 1;

    IF NOT EXISTS (SELECT 1 FROM Cash.tbCategory WHERE VersionId = @VersionId)
        THROW 51113, 'A Category Tree version must contain categories.', 1;

    IF EXISTS
    (
        SELECT 1
        FROM Cash.tbCategory
        WHERE VersionId = @VersionId
          AND (CashPolarityCode IS NULL OR CashTypeCode IS NULL)
    )
        THROW 51175, 'Every Category Tree category requires a Cash Polarity and Cash Type.', 1;

    IF EXISTS
    (
        SELECT 1
        FROM Cash.tbCategoryTotal AS edge
        JOIN Cash.tbCategory AS parent
          ON parent.VersionId = edge.VersionId
         AND parent.CategoryCode = edge.ParentCode
        WHERE edge.VersionId = @VersionId
          AND parent.CategoryTypeCode <> 1
    )
        THROW 51114, 'Every Category Tree parent must be a Total category.', 1;

    IF (SELECT COUNT(*) FROM Cash.tbCategoryRoot WHERE VersionId = @VersionId) <> 2
       OR EXISTS
          (
              SELECT required.RootTypeCode
              FROM (VALUES (CAST(0 AS SMALLINT)), (CAST(1 AS SMALLINT))) AS required (RootTypeCode)
              EXCEPT
              SELECT RootTypeCode
              FROM Cash.tbCategoryRoot
              WHERE VersionId = @VersionId
          )
        THROW 51115, 'A Category Tree version requires exactly the Net Profit and VAT roots.', 1;

    IF EXISTS
    (
        SELECT code.CashCode
        FROM Cash.tbCode AS code
        EXCEPT
        SELECT map.CashCode
        FROM Cash.tbCategoryCodeMap AS map
        WHERE map.VersionId = @VersionId
    )
        THROW 51116, 'Every persistent Cash Code requires a mapping in the Category Tree version.', 1;

    IF EXISTS
    (
        SELECT 1
        FROM Cash.tbCategoryCodeMap AS map
        LEFT JOIN Cash.tbCode AS code
          ON code.CashCode = map.CashCode
        JOIN Cash.tbCategory AS category
          ON category.VersionId = map.VersionId
         AND category.CategoryCode = map.CategoryCode
        WHERE map.VersionId = @VersionId
          AND (code.CashCode IS NULL OR category.CategoryTypeCode <> 0)
    )
        THROW 51117, 'Every mapping must reference a persistent Cash Code and a Nominal category.', 1;

    IF EXISTS
    (
        SELECT 1
        FROM Cash.tbTaxTagSource AS source
        CROSS APPLY Cash.fnTaxTagMapValidateByVersion(source.TaxSourceCode, @VersionId) AS validation
        WHERE validation.IsError = 1
    )
        THROW 51118, 'Tax Tag validation failed for the Category Tree version.', 1;

    EXEC Cash.proc_CategoryVersionCanonicalise
        @VersionId = @VersionId,
        @CanonicalSha256 = @CanonicalSha256 OUTPUT,
        @CanonicalByteLength = @CanonicalByteLength OUTPUT;

        INSERT INTO Cash.tbCategoryVersionEvent
        (
            VersionId, EventTypeCode, FromStatusCode, ToStatusCode,
            UserId, UserName, ChangeNote, ContentSha256
        )
        VALUES
        (
            @VersionId, 2, @VersionStatusCode, @VersionStatusCode,
            @UserId, @UserName, N'Category Tree validation passed.', @CanonicalSha256
        );

        COMMIT TRAN;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0 ROLLBACK TRAN;
        THROW;
    END CATCH;
END;
