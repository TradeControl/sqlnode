CREATE TABLE [Cash].[tbCategoryTotal] (
    [VersionId] NVARCHAR (10) NOT NULL CONSTRAINT [DF_Cash_tbCategoryTotal_VersionId] DEFAULT ([Cash].[fnCategoryVersionDefault]()),
    [ParentCode] NVARCHAR (10) NOT NULL,
    [ChildCode]  NVARCHAR (10) NOT NULL,
    DisplayOrder  smallint     NOT NULL CONSTRAINT DF_Cash_tbCategoryTotal_DisplayOrder DEFAULT (0),
    [RowVer]     ROWVERSION    NOT NULL,
    CONSTRAINT [PK_Cash_tbCategoryTotal] PRIMARY KEY CLUSTERED ([VersionId] ASC, [ParentCode] ASC, [ChildCode] ASC) WITH (FILLFACTOR = 90),
    CONSTRAINT [FK_Cash_tbCategoryTotal_Cash_tbCategoryVersion] FOREIGN KEY ([VersionId]) REFERENCES [Cash].[tbCategoryVersion] ([VersionId]),
    CONSTRAINT [FK_Cash_tbCategoryTotal_Cash_tbCategory_ChildVersion] FOREIGN KEY ([VersionId], [ChildCode]) REFERENCES [Cash].[tbCategory] ([VersionId], [CategoryCode]),
    CONSTRAINT [FK_Cash_tbCategoryTotal_Cash_tbCategory_ParentVersion] FOREIGN KEY ([VersionId], [ParentCode]) REFERENCES [Cash].[tbCategory] ([VersionId], [CategoryCode])
);

GO

CREATE NONCLUSTERED INDEX [IX_Cash_tbCategoryTotal_VersionParentDisplayChild]
    ON [Cash].[tbCategoryTotal] ([VersionId], [ParentCode], [DisplayOrder], [ChildCode]);

GO

CREATE NONCLUSTERED INDEX [IX_Cash_tbCategoryTotal_VersionChildParent]
    ON [Cash].[tbCategoryTotal] ([VersionId], [ChildCode], [ParentCode]);


GO

CREATE TRIGGER [Cash].[Cash_tbCategoryTotal_Trigger_NoCycles]
ON [Cash].[tbCategoryTotal]
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (SELECT 1 FROM inserted WHERE ParentCode = ChildCode)
    BEGIN
        RAISERROR ('ParentCode cannot equal ChildCode.', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END

    IF EXISTS (
        SELECT 1
        FROM inserted i
        JOIN Cash.tbCategory p ON p.VersionId = i.VersionId AND p.CategoryCode = i.ParentCode
        WHERE ISNULL(p.CategoryTypeCode, -1) <> 1
    )
    BEGIN
        RAISERROR ('Invalid parent: only Total-type categories may be parents in Cash.tbCategoryTotal.', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END

    DECLARE @violations TABLE (ChildCode nvarchar(10), ParentCode nvarchar(10));

    ;WITH down_paths AS
    (
        SELECT i.VersionId, i.ChildCode AS StartChild, e.ChildCode AS Descendant
        FROM inserted i
        JOIN Cash.tbCategoryTotal e
          ON e.VersionId = i.VersionId
         AND e.ParentCode = i.ChildCode

        UNION ALL

        SELECT dp.VersionId, dp.StartChild, e.ChildCode
        FROM down_paths dp
        JOIN Cash.tbCategoryTotal e
          ON e.VersionId = dp.VersionId
         AND e.ParentCode = dp.Descendant
    )
    INSERT INTO @violations (ChildCode, ParentCode)
    SELECT DISTINCT i.ChildCode, i.ParentCode
    FROM inserted i
    JOIN down_paths dp
      ON dp.VersionId = i.VersionId
     AND dp.StartChild = i.ChildCode
     AND dp.Descendant = i.ParentCode
    OPTION (MAXRECURSION 1000);

    IF EXISTS (SELECT 1 FROM @violations)
    BEGIN
        RAISERROR ('Insert/Update would create a cyclic hierarchy in Cash.tbCategoryTotal.', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END

    IF EXISTS
    (
        SELECT 1
        FROM
        (
            SELECT VersionId FROM inserted
            UNION
            SELECT VersionId FROM deleted
        ) AS affected
        JOIN Cash.tbCategoryVersion AS version
          ON version.VersionId = affected.VersionId
        WHERE version.VersionStatusCode IN (2, 3)
    )
        THROW 51098, 'Submitted and Archived Category Tree totals are immutable.', 1;

    ;WITH affected AS
    (
        SELECT VersionId FROM inserted
        UNION
        SELECT VersionId FROM deleted
    )
    UPDATE version
    SET CanonicalSha256 = NULL,
        CanonicalByteLength = NULL,
        ContentChangedOn = SYSUTCDATETIME()
    FROM Cash.tbCategoryVersion AS version
    JOIN affected
      ON affected.VersionId = version.VersionId
    WHERE version.VersionStatusCode IN (0, 1);
END
