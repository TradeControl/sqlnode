CREATE PROCEDURE [Cash].[proc_CodeAdd]
(
    @VersionId NVARCHAR(10),
    @CashCode NVARCHAR(50),
    @CashDescription NVARCHAR(100),
    @CategoryCode NVARCHAR(10),
    @TaxCode NVARCHAR(10),
    @IsEnabled SMALLINT = 1
)
AS
BEGIN
    SET NOCOUNT, XACT_ABORT ON;

    BEGIN TRY
        BEGIN TRAN;

        IF NOT EXISTS
        (
            SELECT 1
            FROM App.tbOptions WITH (UPDLOCK, HOLDLOCK)
            WHERE CategoryVersionId = @VersionId
        )
            THROW 51106, 'A new Cash Code must be added to the active Category Tree version.', 1;

        IF NOT EXISTS
        (
            SELECT 1
            FROM Cash.tbCategoryVersion WITH (UPDLOCK, HOLDLOCK)
            WHERE VersionId = @VersionId
              AND VersionStatusCode = 1
        )
            THROW 51107, 'A new Cash Code requires an editable active Published Category Tree version.', 1;

        IF NOT EXISTS
        (
            SELECT 1
            FROM Cash.tbCategory
            WHERE VersionId = @VersionId
              AND CategoryCode = @CategoryCode
              AND CategoryTypeCode = 0
        )
            THROW 51108, 'A new Cash Code must map to a Nominal category in the active version.', 1;

        IF EXISTS (SELECT 1 FROM Cash.tbCode WHERE CashCode = @CashCode)
            OR EXISTS
               (
                   SELECT 1
                   FROM Cash.tbCategoryCodeMap
                   WHERE VersionId = @VersionId
                     AND CashCode = @CashCode
               )
            THROW 51109, 'The Cash Code or its active Category Tree mapping already exists.', 1;

        EXEC sys.sp_set_session_context
            @key = N'CategoryTreeExplicitMapping',
            @value = 1;

        INSERT INTO Cash.tbCode
        (
            CashCode,
            CashDescription,
            CategoryCode,
            TaxCode,
            IsEnabled
        )
        VALUES
        (
            @CashCode,
            @CashDescription,
            @CategoryCode,
            @TaxCode,
            @IsEnabled
        );

        INSERT INTO Cash.tbCategoryCodeMap
        (
            VersionId,
            CashCode,
            CategoryCode
        )
        VALUES
        (
            @VersionId,
            @CashCode,
            @CategoryCode
        );

        EXEC sys.sp_set_session_context
            @key = N'CategoryTreeExplicitMapping',
            @value = NULL;

        COMMIT TRAN;
    END TRY
    BEGIN CATCH
        EXEC sys.sp_set_session_context
            @key = N'CategoryTreeExplicitMapping',
            @value = NULL;

        IF XACT_STATE() <> 0 ROLLBACK TRAN;
        THROW;
    END CATCH
END;
