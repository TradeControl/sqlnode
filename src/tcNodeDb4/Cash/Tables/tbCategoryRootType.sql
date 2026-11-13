CREATE TABLE [Cash].[tbCategoryRootType]
(
    [RootTypeCode] SMALLINT NOT NULL,
    [RootType] NVARCHAR(20) NOT NULL,
    CONSTRAINT [PK_Cash_tbCategoryRootType]
        PRIMARY KEY CLUSTERED ([RootTypeCode] ASC),
    CONSTRAINT [UQ_Cash_tbCategoryRootType_RootType]
        UNIQUE NONCLUSTERED ([RootType] ASC),
    CONSTRAINT [CK_Cash_tbCategoryRootType_Code]
        CHECK ([RootTypeCode] >= 0 AND [RootTypeCode] <= 2)
);
