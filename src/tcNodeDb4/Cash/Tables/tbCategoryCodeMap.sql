CREATE TABLE [Cash].[tbCategoryCodeMap]
(
    [VersionId] NVARCHAR(10) NOT NULL,
    [CashCode] NVARCHAR(50) NOT NULL,
    [CategoryCode] NVARCHAR(10) NOT NULL,
    [RowVer] ROWVERSION NOT NULL,
    CONSTRAINT [PK_Cash_tbCategoryCodeMap]
        PRIMARY KEY CLUSTERED ([VersionId] ASC, [CashCode] ASC),
    CONSTRAINT [FK_Cash_tbCategoryCodeMap_Cash_tbCategoryVersion]
        FOREIGN KEY ([VersionId])
        REFERENCES [Cash].[tbCategoryVersion] ([VersionId]),
    CONSTRAINT [FK_Cash_tbCategoryCodeMap_Cash_tbCategory]
        FOREIGN KEY ([VersionId], [CategoryCode])
        REFERENCES [Cash].[tbCategory] ([VersionId], [CategoryCode])
        ON UPDATE CASCADE
);

GO

CREATE NONCLUSTERED INDEX [IX_Cash_tbCategoryCodeMap_VersionCategoryCashCode]
    ON [Cash].[tbCategoryCodeMap] ([VersionId], [CategoryCode], [CashCode]);

GO

CREATE TRIGGER [Cash].[Cash_tbCategoryCodeMap_TriggerValidate]
ON [Cash].[tbCategoryCodeMap]
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS
    (
        SELECT 1
        FROM inserted AS i
        JOIN Cash.tbCategory AS c
          ON c.VersionId = i.VersionId
         AND c.CategoryCode = i.CategoryCode
        WHERE c.CategoryTypeCode <> 0
    )
        THROW 51073, 'A Cash Code mapping must target a Nominal category in the same version.', 1;

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
        THROW 51099, 'Submitted and Archived Category Tree Cash Code mappings are immutable.', 1;

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
