CREATE TABLE [Subject].[tbAccountKey] (
    [CashAccountCode] NVARCHAR (10)       NOT NULL,
    [HDPath]          [sys].[hierarchyid] NOT NULL,
    [KeyName]         NVARCHAR (50)       NOT NULL,
    [HDLevel]         AS                  ([HDPath].[GetLevel]()),
    CONSTRAINT [PK_Subject_tbAccountKey] PRIMARY KEY NONCLUSTERED ([CashAccountCode] ASC, [HDPath] ASC),
    CONSTRAINT [FK_Subject_tbAccountKey_Subject_tbAccount] FOREIGN KEY ([CashAccountCode]) REFERENCES [Subject].[tbAccount] ([CashAccountCode]) ON DELETE CASCADE ON UPDATE CASCADE
);


GO
CREATE NONCLUSTERED INDEX [IX_Subject_tbAccountKey_HDLevel]
    ON [Subject].[tbAccountKey]([CashAccountCode] ASC, [HDLevel] ASC, [HDPath] ASC);


GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_Subject_tbAccountKey_KeyName]
    ON [Subject].[tbAccountKey]([CashAccountCode] ASC, [KeyName] ASC);

