SET NOCOUNT, XACT_ABORT ON;
GO

DECLARE
    @NamespacePath nvarchar(255) = N'External.Buyer',
    @SubjectTypeCode smallint = 1,      -- 1 = buyer/customer; change to 0 if you want supplier semantics
    @SubjectPrefix nvarchar(50) = N'Buyer ',
    @ContactPrefix nvarchar(50) = N'Contact ',
    @TargetCount int = 10000;

DECLARE @RootSubjectCode nvarchar(50);

;WITH NamespacePaths AS
(
    SELECT
        s.SubjectCode,
        CAST(s.SubjectCode AS nvarchar(4000)) AS NamespacePath
    FROM Subject.tbSubject AS s
    WHERE NOT EXISTS
    (
        SELECT 1
        FROM Subject.tbNamespace AS n
        WHERE n.ChildSubjectCode = s.SubjectCode
    )

    UNION ALL

    SELECT
        c.SubjectCode,
        CAST(CONCAT(p.NamespacePath, N'.', c.SubjectCode) AS nvarchar(4000)) AS NamespacePath
    FROM NamespacePaths AS p
    INNER JOIN Subject.tbNamespace AS n
        ON n.ParentSubjectCode = p.SubjectCode
    INNER JOIN Subject.tbSubject AS c
        ON c.SubjectCode = n.ChildSubjectCode
)
SELECT @RootSubjectCode = SubjectCode
FROM NamespacePaths
WHERE NamespacePath = @NamespacePath
OPTION (MAXRECURSION 32767);

IF @RootSubjectCode IS NULL
    THROW 52001, 'Load-test namespace path was not found: External.Buyers', 1;

DECLARE
    @i int = 1,
    @BuyerName nvarchar(100),
    @ContactName nvarchar(100),
    @BuyerSubjectCode nvarchar(50);

WHILE @i <= @TargetCount
BEGIN
    SET @BuyerName = CONCAT(@SubjectPrefix, CONVERT(nvarchar(20), @i));
    SET @ContactName = CONCAT(@ContactPrefix, CONVERT(nvarchar(20), @i));
    SET @BuyerSubjectCode = NULL;

    EXEC Subject.proc_AddNamespace
        @RootSubjectCode = @RootSubjectCode,
        @SubjectName = @BuyerName,
        @SubjectTypeCode = @SubjectTypeCode,
        @SubjectCode = @BuyerSubjectCode OUTPUT;

    EXEC Subject.proc_AddContact
        @SubjectCode = @BuyerSubjectCode,
        @ContactName = @ContactName;

    IF @i % 500 = 0
        RAISERROR(N'Created or verified %d buyers', 10, 1, @i) WITH NOWAIT;

    SET @i += 1;
END
GO
;WITH NamespacePaths AS
(
    SELECT
        s.SubjectCode,
        CAST(s.SubjectCode AS nvarchar(4000)) AS NamespacePath
    FROM Subject.tbSubject AS s
    WHERE NOT EXISTS
    (
        SELECT 1
        FROM Subject.tbNamespace AS n
        WHERE n.ChildSubjectCode = s.SubjectCode
    )

    UNION ALL

    SELECT
        c.SubjectCode,
        CAST(CONCAT(p.NamespacePath, N'.', c.SubjectCode) AS nvarchar(4000)) AS NamespacePath
    FROM NamespacePaths AS p
    INNER JOIN Subject.tbNamespace AS n
        ON n.ParentSubjectCode = p.SubjectCode
    INNER JOIN Subject.tbSubject AS c
        ON c.SubjectCode = n.ChildSubjectCode
)
SELECT COUNT(*) AS BuyerCount
FROM NamespacePaths
WHERE NamespacePath LIKE N'External.Buyer.Buyer%'
  AND NamespacePath NOT LIKE N'External.Buyer.Buyer%.Contact%'
OPTION (MAXRECURSION 32767);

;WITH NamespacePaths AS
(
    SELECT
        s.SubjectCode,
        CAST(s.SubjectCode AS nvarchar(4000)) AS NamespacePath
    FROM Subject.tbSubject AS s
    WHERE NOT EXISTS
    (
        SELECT 1
        FROM Subject.tbNamespace AS n
        WHERE n.ChildSubjectCode = s.SubjectCode
    )

    UNION ALL

    SELECT
        c.SubjectCode,
        CAST(CONCAT(p.NamespacePath, N'.', c.SubjectCode) AS nvarchar(4000)) AS NamespacePath
    FROM NamespacePaths AS p
    INNER JOIN Subject.tbNamespace AS n
        ON n.ParentSubjectCode = p.SubjectCode
    INNER JOIN Subject.tbSubject AS c
        ON c.SubjectCode = n.ChildSubjectCode
)
SELECT COUNT(*) AS ContactCount
FROM NamespacePaths
WHERE NamespacePath LIKE N'External.Buyer.Buyer%.Contact%'
OPTION (MAXRECURSION 32767);
GO
