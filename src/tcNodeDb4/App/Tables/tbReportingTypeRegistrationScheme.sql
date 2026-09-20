CREATE TABLE [App].[tbReportingTypeRegistrationScheme]
(
    [ReportingTypeCode] NVARCHAR(20) NOT NULL,
    [RegistrationSchemeCode] NVARCHAR(20) NOT NULL,
    CONSTRAINT [PK_App_tbReportingTypeRegistrationScheme] PRIMARY KEY CLUSTERED
        ([ReportingTypeCode], [RegistrationSchemeCode]),
    CONSTRAINT [FK_App_tbReportingTypeRegistrationScheme_App_tbReportingType] FOREIGN KEY ([ReportingTypeCode])
        REFERENCES [App].[tbReportingType] ([ReportingTypeCode]),
    CONSTRAINT [FK_App_tbReportingTypeRegistrationScheme_App_tbRegistrationScheme] FOREIGN KEY ([RegistrationSchemeCode])
        REFERENCES [App].[tbRegistrationScheme] ([RegistrationSchemeCode])
);
