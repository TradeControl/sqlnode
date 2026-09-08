CREATE TABLE [App].[tbReportingType]
(
    [ReportingTypeCode] NVARCHAR(20) NOT NULL,
    [AuthorityCode] NVARCHAR(20) NOT NULL,
    [ReportingTypeName] NVARCHAR(100) NOT NULL,
    [RequiresTaxSource] BIT NOT NULL CONSTRAINT [DF_App_tbReportingType_RequiresTaxSource] DEFAULT (1),
    [IsEnabled] BIT NOT NULL CONSTRAINT [DF_App_tbReportingType_IsEnabled] DEFAULT (1),
    [RowVer] ROWVERSION NOT NULL,
    CONSTRAINT [PK_App_tbReportingType] PRIMARY KEY CLUSTERED ([ReportingTypeCode]),
    CONSTRAINT [AK_App_tbReportingType_AuthorityName] UNIQUE ([AuthorityCode], [ReportingTypeName]),
    CONSTRAINT [FK_App_tbReportingType_App_tbAuthority] FOREIGN KEY ([AuthorityCode])
        REFERENCES [App].[tbAuthority] ([AuthorityCode])
);
