CREATE TABLE [App].[tbDatabaseIdentity]
(
    [IdentityCode] TINYINT NOT NULL CONSTRAINT [PK_App_tbDatabaseIdentity] PRIMARY KEY,
    [DatabaseInstanceId] UNIQUEIDENTIFIER NOT NULL CONSTRAINT [DF_App_tbDatabaseIdentity_DatabaseInstanceId] DEFAULT (NEWID()),
    [CreatedAtUtc] DATETIME2(7) NOT NULL CONSTRAINT [DF_App_tbDatabaseIdentity_CreatedAtUtc] DEFAULT (SYSUTCDATETIME()),
    CONSTRAINT [CK_App_tbDatabaseIdentity_Singleton] CHECK ([IdentityCode] = 1),
    CONSTRAINT [AK_App_tbDatabaseIdentity_DatabaseInstanceId] UNIQUE ([DatabaseInstanceId])
);
GO
