CREATE TABLE [App].[tbRegistrationScheme]
(
    [RegistrationSchemeCode] NVARCHAR(20) NOT NULL,
    [AuthorityCode] NVARCHAR(20) NOT NULL,
    [SchemeName] NVARCHAR(100) NOT NULL,
    [ValueTypeCode] NVARCHAR(10) NOT NULL,
    [ValidationPattern] NVARCHAR(255) NULL,
    [IsSensitive] BIT NOT NULL CONSTRAINT [DF_App_tbRegistrationScheme_IsSensitive] DEFAULT (0),
    [IsSingleValue] BIT NOT NULL CONSTRAINT [DF_App_tbRegistrationScheme_IsSingleValue] DEFAULT (1),
    [IsEnabled] BIT NOT NULL CONSTRAINT [DF_App_tbRegistrationScheme_IsEnabled] DEFAULT (1),
    [RowVer] ROWVERSION NOT NULL,
    CONSTRAINT [PK_App_tbRegistrationScheme] PRIMARY KEY CLUSTERED ([RegistrationSchemeCode]),
    CONSTRAINT [AK_App_tbRegistrationScheme_AuthorityName] UNIQUE ([AuthorityCode], [SchemeName]),
    CONSTRAINT [FK_App_tbRegistrationScheme_App_tbAuthority] FOREIGN KEY ([AuthorityCode])
        REFERENCES [App].[tbAuthority] ([AuthorityCode]),
    CONSTRAINT [FK_App_tbRegistrationScheme_App_tbValueType] FOREIGN KEY ([ValueTypeCode])
        REFERENCES [App].[tbValueType] ([ValueTypeCode])
);
