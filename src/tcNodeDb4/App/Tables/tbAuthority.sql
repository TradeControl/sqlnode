CREATE TABLE [App].[tbAuthority]
(
    [AuthorityCode] NVARCHAR(20) NOT NULL,
    [JurisdictionCode] NVARCHAR(10) NOT NULL,
    [AuthorityName] NVARCHAR(100) NOT NULL,
    [IsEnabled] BIT NOT NULL CONSTRAINT [DF_App_tbAuthority_IsEnabled] DEFAULT (1),
    [RowVer] ROWVERSION NOT NULL,
    CONSTRAINT [PK_App_tbAuthority] PRIMARY KEY CLUSTERED ([AuthorityCode]),
    CONSTRAINT [AK_App_tbAuthority_JurisdictionName] UNIQUE ([JurisdictionCode], [AuthorityName]),
    CONSTRAINT [FK_App_tbAuthority_App_tbJurisdiction] FOREIGN KEY ([JurisdictionCode])
        REFERENCES [App].[tbJurisdiction] ([JurisdictionCode])
);
