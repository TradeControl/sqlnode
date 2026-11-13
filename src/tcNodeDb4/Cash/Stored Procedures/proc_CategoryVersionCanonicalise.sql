CREATE PROCEDURE [Cash].[proc_CategoryVersionCanonicalise]
(
    @VersionId NVARCHAR(10),
    @CanonicalSha256 BINARY(32) = NULL OUTPUT,
    @CanonicalByteLength BIGINT = NULL OUTPUT,
    @CanonicalJson NVARCHAR(MAX) = NULL OUTPUT
)
AS
BEGIN
    SET NOCOUNT, XACT_ABORT ON;

    DECLARE @VersionStatusCode SMALLINT;

    SELECT @VersionStatusCode = VersionStatusCode
    FROM Cash.tbCategoryVersion WITH (UPDLOCK, HOLDLOCK)
    WHERE VersionId = @VersionId;

    IF @VersionStatusCode IS NULL
        THROW 51093, 'Category Tree canonicalisation requires a known version.', 1;

    IF @VersionStatusCode NOT IN (0, 1)
        THROW 51094, 'Submitted and Archived Category Tree versions cannot be recanonicalised.', 1;

    IF NOT EXISTS (SELECT 1 FROM Cash.tbCategory WHERE VersionId = @VersionId)
        THROW 51095, 'Category Tree canonicalisation requires at least one category.', 1;

    IF (SELECT COUNT(*) FROM Cash.tbCategoryRoot WHERE VersionId = @VersionId) NOT BETWEEN 2 AND 3
        OR EXISTS
        (
            SELECT required.RootTypeCode
            FROM (VALUES (CAST(0 AS SMALLINT)), (CAST(1 AS SMALLINT))) AS required (RootTypeCode)
            EXCEPT
            SELECT RootTypeCode
            FROM Cash.tbCategoryRoot
            WHERE VersionId = @VersionId
        )
        THROW 51096, 'The v1 Category Tree profile requires NET_PROFIT and VAT roots and permits DISTRIBUTIONS.', 1;

    DECLARE
        @Categories NVARCHAR(MAX),
        @Totals NVARCHAR(MAX),
        @CodeMap NVARCHAR(MAX),
        @Roots NVARCHAR(MAX);

    SELECT @Categories = STUFF
    (
        (
        SELECT
            N',' +
            CAST
        (
            N'{"categoryCode":"' + REPLACE(STRING_ESCAPE(CategoryCode, 'json'), N'\/', N'/')
            + N'","category":"' + REPLACE(STRING_ESCAPE(Category, 'json'), N'\/', N'/')
            + N'","categoryTypeCode":' + CONVERT(NVARCHAR(6), CategoryTypeCode)
            + N',"cashPolarityCode":' + COALESCE(CONVERT(NVARCHAR(6), CashPolarityCode), N'null')
            + N',"cashTypeCode":' + COALESCE(CONVERT(NVARCHAR(6), CashTypeCode), N'null')
            + N',"displayOrder":' + CONVERT(NVARCHAR(6), DisplayOrder)
            + N',"isEnabled":' + CASE WHEN IsEnabled = 0 THEN N'false' ELSE N'true' END
            + N'}'
            AS NVARCHAR(MAX)
        )
        FROM Cash.tbCategory
        WHERE VersionId = @VersionId
        ORDER BY CategoryCode COLLATE Latin1_General_100_BIN2
        FOR XML PATH(N''), TYPE
        ).value(N'.', N'nvarchar(max)'),
        1,
        1,
        N''
    );

    SELECT @Totals = COALESCE
    (
        STUFF
        (
            (
            SELECT
                N',' +
                CAST
            (
                N'{"parentCode":"' + REPLACE(STRING_ESCAPE(ParentCode, 'json'), N'\/', N'/')
                + N'","childCode":"' + REPLACE(STRING_ESCAPE(ChildCode, 'json'), N'\/', N'/')
                + N'","displayOrder":' + CONVERT(NVARCHAR(6), DisplayOrder)
                + N'}'
                AS NVARCHAR(MAX)
            )
            FROM Cash.tbCategoryTotal
            WHERE VersionId = @VersionId
            ORDER BY
                ParentCode COLLATE Latin1_General_100_BIN2,
                ChildCode COLLATE Latin1_General_100_BIN2
            FOR XML PATH(N''), TYPE
            ).value(N'.', N'nvarchar(max)'),
            1,
            1,
            N''
        ),
        N''
    );

    SELECT @CodeMap = COALESCE
    (
        STUFF
        (
            (
            SELECT
                N',' +
                CAST
            (
                N'{"cashCode":"' + REPLACE(STRING_ESCAPE(CashCode, 'json'), N'\/', N'/')
                + N'","categoryCode":"' + REPLACE(STRING_ESCAPE(CategoryCode, 'json'), N'\/', N'/')
                + N'"}'
                AS NVARCHAR(MAX)
            )
            FROM Cash.tbCategoryCodeMap
            WHERE VersionId = @VersionId
            ORDER BY CashCode COLLATE Latin1_General_100_BIN2
            FOR XML PATH(N''), TYPE
            ).value(N'.', N'nvarchar(max)'),
            1,
            1,
            N''
        ),
        N''
    );

    SELECT @Roots = STUFF
    (
        (
        SELECT
            N',' +
            CAST
        (
            N'{"rootType":"' + REPLACE(STRING_ESCAPE(root_type.RootType, 'json'), N'\/', N'/')
            + N'","categoryCode":"' + REPLACE(STRING_ESCAPE(root.CategoryCode, 'json'), N'\/', N'/')
            + N'"}'
            AS NVARCHAR(MAX)
        )
        FROM Cash.tbCategoryRoot AS root
        JOIN Cash.tbCategoryRootType AS root_type
          ON root_type.RootTypeCode = root.RootTypeCode
        WHERE root.VersionId = @VersionId
        ORDER BY root.RootTypeCode
        FOR XML PATH(N''), TYPE
        ).value(N'.', N'nvarchar(max)'),
        1,
        1,
        N''
    );

    SET @CanonicalJson =
        N'{"profile":"trade-control-category-tree-v1","categories":[' + @Categories
        + N'],"totals":[' + @Totals
        + N'],"codeMap":[' + @CodeMap
        + N'],"roots":[' + @Roots + N']}';

    DECLARE @CanonicalBytes VARBINARY(MAX) = CONVERT
    (
        VARBINARY(MAX),
        CONVERT(VARCHAR(MAX), @CanonicalJson COLLATE Latin1_General_100_BIN2_UTF8)
    );

    SET @CanonicalByteLength = DATALENGTH(@CanonicalBytes);
    SET @CanonicalSha256 = HASHBYTES('SHA2_256', @CanonicalBytes);

    UPDATE Cash.tbCategoryVersion
    SET CanonicalProfile = N'trade-control-category-tree-v1',
        CanonicalSha256 = @CanonicalSha256,
        CanonicalByteLength = @CanonicalByteLength,
        ContentChangedOn = SYSUTCDATETIME()
    WHERE VersionId = @VersionId;
END;
