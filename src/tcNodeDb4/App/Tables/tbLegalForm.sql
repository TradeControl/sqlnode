CREATE TABLE [App].[tbLegalForm]
(
    [JurisdictionCode] NVARCHAR(10) NOT NULL,
    [LegalFormCode] NVARCHAR(20) NOT NULL,
    [LegalFormName] NVARCHAR(100) NOT NULL,
    [IsEnabled] BIT NOT NULL CONSTRAINT [DF_App_tbLegalForm_IsEnabled] DEFAULT (1),
    [RowVer] ROWVERSION NOT NULL,
    CONSTRAINT [PK_App_tbLegalForm] PRIMARY KEY CLUSTERED ([JurisdictionCode], [LegalFormCode]),
    CONSTRAINT [AK_App_tbLegalForm_Name] UNIQUE ([JurisdictionCode], [LegalFormName]),
    CONSTRAINT [FK_App_tbLegalForm_App_tbJurisdiction] FOREIGN KEY ([JurisdictionCode])
        REFERENCES [App].[tbJurisdiction] ([JurisdictionCode])
);
