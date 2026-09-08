CREATE TABLE [App].[tbSettingDefinition]
(
    [SettingCode] NVARCHAR(30) NOT NULL,
    [SettingName] NVARCHAR(100) NOT NULL,
    [JurisdictionCode] NVARCHAR(10) NULL,
    [AuthorityCode] NVARCHAR(20) NULL,
    [ReportingTypeCode] NVARCHAR(20) NULL,
    [ValueTypeCode] NVARCHAR(10) NOT NULL,
    [AllowedValues] NVARCHAR(MAX) NULL,
    [ValidationPattern] NVARCHAR(255) NULL,
    [IsSensitive] BIT NOT NULL CONSTRAINT [DF_App_tbSettingDefinition_IsSensitive] DEFAULT (0),
    [IsEnabled] BIT NOT NULL CONSTRAINT [DF_App_tbSettingDefinition_IsEnabled] DEFAULT (1),
    [RowVer] ROWVERSION NOT NULL,
    CONSTRAINT [PK_App_tbSettingDefinition] PRIMARY KEY CLUSTERED ([SettingCode]),
    CONSTRAINT [AK_App_tbSettingDefinition_SettingName] UNIQUE ([SettingName]),
    CONSTRAINT [CK_App_tbSettingDefinition_Scope] CHECK ([JurisdictionCode] IS NOT NULL OR [AuthorityCode] IS NOT NULL),
    CONSTRAINT [CK_App_tbSettingDefinition_AllowedValues] CHECK ([AllowedValues] IS NULL OR ISJSON([AllowedValues]) = 1),
    CONSTRAINT [FK_App_tbSettingDefinition_App_tbJurisdiction] FOREIGN KEY ([JurisdictionCode])
        REFERENCES [App].[tbJurisdiction] ([JurisdictionCode]),
    CONSTRAINT [FK_App_tbSettingDefinition_App_tbAuthority] FOREIGN KEY ([AuthorityCode])
        REFERENCES [App].[tbAuthority] ([AuthorityCode]),
    CONSTRAINT [FK_App_tbSettingDefinition_App_tbReportingType] FOREIGN KEY ([ReportingTypeCode])
        REFERENCES [App].[tbReportingType] ([ReportingTypeCode]),
    CONSTRAINT [FK_App_tbSettingDefinition_App_tbValueType] FOREIGN KEY ([ValueTypeCode])
        REFERENCES [App].[tbValueType] ([ValueTypeCode])
);
