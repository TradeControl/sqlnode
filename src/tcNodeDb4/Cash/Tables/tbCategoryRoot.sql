CREATE TABLE [Cash].[tbCategoryRoot]
(
    [VersionId] NVARCHAR(10) NOT NULL,
    [RootTypeCode] SMALLINT NOT NULL,
    [CategoryCode] NVARCHAR(10) NOT NULL,
    [RowVer] ROWVERSION NOT NULL,
    CONSTRAINT [PK_Cash_tbCategoryRoot]
        PRIMARY KEY CLUSTERED ([VersionId] ASC, [RootTypeCode] ASC),
    CONSTRAINT [FK_Cash_tbCategoryRoot_Cash_tbCategoryVersion]
        FOREIGN KEY ([VersionId])
        REFERENCES [Cash].[tbCategoryVersion] ([VersionId]),
    CONSTRAINT [FK_Cash_tbCategoryRoot_Cash_tbCategoryRootType]
        FOREIGN KEY ([RootTypeCode])
        REFERENCES [Cash].[tbCategoryRootType] ([RootTypeCode]),
    CONSTRAINT [FK_Cash_tbCategoryRoot_Cash_tbCategory]
        FOREIGN KEY ([VersionId], [CategoryCode])
        REFERENCES [Cash].[tbCategory] ([VersionId], [CategoryCode])
);

GO

CREATE TRIGGER [Cash].[Cash_tbCategoryRoot_TriggerValidate]
ON [Cash].[tbCategoryRoot]
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS
    (
        SELECT 1
        FROM inserted AS i
        JOIN Cash.tbCategory AS category
          ON category.VersionId = i.VersionId
         AND category.CategoryCode = i.CategoryCode
        WHERE category.CategoryTypeCode <> 1
           OR category.IsEnabled = 0
           OR EXISTS
              (
                  SELECT 1
                  FROM Cash.tbCategoryTotal AS parent
                  WHERE parent.VersionId = i.VersionId
                    AND parent.ChildCode = i.CategoryCode
              )
           OR NOT EXISTS
              (
                  SELECT 1
                  FROM Cash.tbCategoryTotal AS child
                  WHERE child.VersionId = i.VersionId
                    AND child.ParentCode = i.CategoryCode
              )
    )
        THROW 51100, 'A Category Tree root must be an enabled Total category with children and no parent.', 1;

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
        THROW 51101, 'Submitted and Archived Category Tree roots are immutable.', 1;

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
END;
