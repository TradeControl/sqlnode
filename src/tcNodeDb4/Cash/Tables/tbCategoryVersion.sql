CREATE TABLE [Cash].[tbCategoryVersion]
(
    [VersionId] NVARCHAR(10) NOT NULL,
    [VersionStatusCode] SMALLINT NOT NULL,
    [Description] NVARCHAR(100) NOT NULL,
    [Notes] NVARCHAR(MAX) NULL,
    [PredecessorVersionId] NVARCHAR(10) NULL,
    [BaseContentSha256] BINARY(32) NULL,
    [CanonicalProfile] NVARCHAR(50) NOT NULL
        CONSTRAINT [DF_Cash_tbCategoryVersion_CanonicalProfile]
        DEFAULT (N'trade-control-category-tree-v1'),
    [CanonicalSha256] BINARY(32) NULL,
    [CanonicalByteLength] BIGINT NULL,
    [ContentChangedOn] DATETIME2(3) NOT NULL
        CONSTRAINT [DF_Cash_tbCategoryVersion_ContentChangedOn]
        DEFAULT (SYSUTCDATETIME()),
    [EffectiveFromOn] DATE NULL,
    [EffectiveToOn] DATE NULL,
    [CreatedOn] DATETIME2(3) NOT NULL
        CONSTRAINT [DF_Cash_tbCategoryVersion_CreatedOn]
        DEFAULT (SYSUTCDATETIME()),
    [CreatedByUserId] NVARCHAR(10) NOT NULL,
    [SubmissionLockReference] NVARCHAR(64) NULL,
    [SubmissionLockSha256] BINARY(32) NULL,
    [SubmissionLockedOn] DATETIME2(3) NULL,
    [RowVer] ROWVERSION NOT NULL,
    CONSTRAINT [PK_Cash_tbCategoryVersion]
        PRIMARY KEY CLUSTERED ([VersionId] ASC),
    CONSTRAINT [FK_Cash_tbCategoryVersion_Cash_tbCategoryVersionStatus]
        FOREIGN KEY ([VersionStatusCode])
        REFERENCES [Cash].[tbCategoryVersionStatus] ([VersionStatusCode]),
    CONSTRAINT [FK_Cash_tbCategoryVersion_Cash_tbCategoryVersion_Predecessor]
        FOREIGN KEY ([PredecessorVersionId])
        REFERENCES [Cash].[tbCategoryVersion] ([VersionId]),
    CONSTRAINT [FK_Cash_tbCategoryVersion_Usr_tbUser]
        FOREIGN KEY ([CreatedByUserId])
        REFERENCES [Usr].[tbUser] ([UserId]),
    CONSTRAINT [CK_Cash_tbCategoryVersion_VersionId]
        CHECK
        (
            LEN([VersionId]) = 10
            AND [VersionId] LIKE N'CV[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'
        ),
    CONSTRAINT [CK_Cash_tbCategoryVersion_Description]
        CHECK (LEN(LTRIM(RTRIM([Description]))) > 0),
    CONSTRAINT [CK_Cash_tbCategoryVersion_Predecessor]
        CHECK ([PredecessorVersionId] IS NULL OR [PredecessorVersionId] <> [VersionId]),
    CONSTRAINT [CK_Cash_tbCategoryVersion_PredecessorEvidence]
        CHECK
        (
            ([PredecessorVersionId] IS NULL AND [BaseContentSha256] IS NULL)
            OR
            ([PredecessorVersionId] IS NOT NULL AND [BaseContentSha256] IS NOT NULL)
        ),
    CONSTRAINT [CK_Cash_tbCategoryVersion_CanonicalProfile]
        CHECK (LEN(LTRIM(RTRIM([CanonicalProfile]))) > 0),
    CONSTRAINT [CK_Cash_tbCategoryVersion_CanonicalEvidence]
        CHECK
        (
            ([CanonicalSha256] IS NULL AND [CanonicalByteLength] IS NULL)
            OR
            ([CanonicalSha256] IS NOT NULL AND [CanonicalByteLength] >= 0)
        ),
    CONSTRAINT [CK_Cash_tbCategoryVersion_SubmissionLock]
        CHECK
        (
            ([SubmissionLockReference] IS NULL
                AND [SubmissionLockSha256] IS NULL
                AND [SubmissionLockedOn] IS NULL)
            OR
            (LEN(LTRIM(RTRIM([SubmissionLockReference]))) > 0
                AND [SubmissionLockSha256] IS NOT NULL
                AND [SubmissionLockedOn] IS NOT NULL)
        ),
    CONSTRAINT [CK_Cash_tbCategoryVersion_EffectiveInterval]
        CHECK
        (
            ([VersionStatusCode] = 0 AND [EffectiveToOn] IS NULL)
            OR
            ([VersionStatusCode] > 0 AND [VersionStatusCode] < 3
                AND [EffectiveFromOn] IS NOT NULL AND [EffectiveToOn] IS NULL)
            OR
            ([VersionStatusCode] = 3 AND [EffectiveFromOn] IS NOT NULL
                AND [EffectiveToOn] IS NOT NULL AND [EffectiveToOn] >= [EffectiveFromOn])
        )
);

GO

CREATE NONCLUSTERED INDEX [IX_Cash_tbCategoryVersion_StatusCreated]
    ON [Cash].[tbCategoryVersion] ([VersionStatusCode], [CreatedOn], [VersionId]);

GO

CREATE NONCLUSTERED INDEX [IX_Cash_tbCategoryVersion_EffectiveInterval]
    ON [Cash].[tbCategoryVersion] ([EffectiveFromOn], [EffectiveToOn], [VersionId]);

GO

CREATE TRIGGER [Cash].[Cash_tbCategoryVersion_TriggerActiveStatus]
ON [Cash].[tbCategoryVersion]
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS
    (
        SELECT 1
        FROM inserted AS version
        JOIN App.tbOptions AS options
          ON options.CategoryVersionId = version.VersionId
        WHERE version.VersionStatusCode NOT IN (1, 2)
    )
        THROW 51092, 'The options-selected Category Tree version must remain Published or Submitted.', 1;
END;
