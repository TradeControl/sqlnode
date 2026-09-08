CREATE TABLE [App].[tbValueType]
(
    [ValueTypeCode] NVARCHAR(10) NOT NULL,
    [ValueTypeName] NVARCHAR(50) NOT NULL,
    CONSTRAINT [PK_App_tbValueType] PRIMARY KEY CLUSTERED ([ValueTypeCode]),
    CONSTRAINT [AK_App_tbValueType_ValueTypeName] UNIQUE ([ValueTypeName])
);
