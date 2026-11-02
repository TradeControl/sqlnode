CREATE TABLE [Cash].[tbCategoryVersionEvent]
(
    [VersionEventId] BIGINT IDENTITY(1, 1) NOT NULL,
    [VersionId] NVARCHAR(10) NOT NULL,
    -- 0 Create, 1 Edit, 2 Validate, 3 Publish, 4 Submit, 5 Archive, 6 Refresh/Rebase.
    [EventTypeCode] SMALLINT NOT NULL,
    [FromStatusCode] SMALLINT NULL,
    [ToStatusCode] SMALLINT NULL,
    [EventOn] DATETIME2(3) NOT NULL
        CONSTRAINT [DF_Cash_tbCategoryVersionEvent_EventOn]
        DEFAULT (SYSUTCDATETIME()),
    [UserId] NVARCHAR(10) NOT NULL,
    [UserName] NVARCHAR(50) NOT NULL,
    [ChangeNote] NVARCHAR(MAX) NULL,
    [ContentSha256] BINARY(32) NULL,
    CONSTRAINT [PK_Cash_tbCategoryVersionEvent]
        PRIMARY KEY CLUSTERED ([VersionEventId] ASC),
    CONSTRAINT [FK_Cash_tbCategoryVersionEvent_Cash_tbCategoryVersion]
        FOREIGN KEY ([VersionId])
        REFERENCES [Cash].[tbCategoryVersion] ([VersionId])
        ON DELETE CASCADE,
    CONSTRAINT [FK_Cash_tbCategoryVersionEvent_Cash_tbCategoryVersionStatus_From]
        FOREIGN KEY ([FromStatusCode])
        REFERENCES [Cash].[tbCategoryVersionStatus] ([VersionStatusCode]),
    CONSTRAINT [FK_Cash_tbCategoryVersionEvent_Cash_tbCategoryVersionStatus_To]
        FOREIGN KEY ([ToStatusCode])
        REFERENCES [Cash].[tbCategoryVersionStatus] ([VersionStatusCode]),
    CONSTRAINT [FK_Cash_tbCategoryVersionEvent_Usr_tbUser]
        FOREIGN KEY ([UserId])
        REFERENCES [Usr].[tbUser] ([UserId]),
    CONSTRAINT [CK_Cash_tbCategoryVersionEvent_EventTypeCode]
        CHECK ([EventTypeCode] >= 0 AND [EventTypeCode] <= 6)
);

GO

CREATE NONCLUSTERED INDEX [IX_Cash_tbCategoryVersionEvent_VersionEventOn]
    ON [Cash].[tbCategoryVersionEvent] ([VersionId], [EventOn], [VersionEventId]);
