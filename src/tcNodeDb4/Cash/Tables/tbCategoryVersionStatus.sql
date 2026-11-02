CREATE TABLE [Cash].[tbCategoryVersionStatus]
(
    [VersionStatusCode] SMALLINT NOT NULL,
    [VersionStatus] NVARCHAR(20) NOT NULL,
    CONSTRAINT [PK_Cash_tbCategoryVersionStatus]
        PRIMARY KEY CLUSTERED ([VersionStatusCode] ASC),
    CONSTRAINT [UQ_Cash_tbCategoryVersionStatus_VersionStatus]
        UNIQUE NONCLUSTERED ([VersionStatus] ASC),
    CONSTRAINT [CK_Cash_tbCategoryVersionStatus_Code]
        CHECK ([VersionStatusCode] >= 0 AND [VersionStatusCode] <= 3)
);
