CREATE TABLE [Cash].[tbReportingProfileSetting]
(
    [ReportingProfileSettingId] INT IDENTITY(1,1) NOT NULL,
    [ReportingProfileId] INT NOT NULL,
    [SettingCode] NVARCHAR(30) NOT NULL,
    [EffectiveFrom] DATE NOT NULL,
    [EffectiveTo] DATE NULL,
    [TextValue] NVARCHAR(4000) NULL,
    [IntegerValue] BIGINT NULL,
    [DecimalValue] DECIMAL(28,9) NULL,
    [DateValue] DATE NULL,
    [BooleanValue] BIT NULL,
    [StatusCode] SMALLINT NOT NULL CONSTRAINT [DF_Cash_tbReportingProfileSetting_StatusCode] DEFAULT (0),
    [ValueSourceCode] NVARCHAR(10) NOT NULL,
    [IsReviewed] BIT NOT NULL CONSTRAINT [DF_Cash_tbReportingProfileSetting_IsReviewed] DEFAULT (0),
    [InsertedBy] NVARCHAR(50) NOT NULL CONSTRAINT [DF_Cash_tbReportingProfileSetting_InsertedBy] DEFAULT (suser_sname()),
    [InsertedOn] DATETIME NOT NULL CONSTRAINT [DF_Cash_tbReportingProfileSetting_InsertedOn] DEFAULT (getdate()),
    [UpdatedBy] NVARCHAR(50) NOT NULL CONSTRAINT [DF_Cash_tbReportingProfileSetting_UpdatedBy] DEFAULT (suser_sname()),
    [UpdatedOn] DATETIME NOT NULL CONSTRAINT [DF_Cash_tbReportingProfileSetting_UpdatedOn] DEFAULT (getdate()),
    [RowVer] ROWVERSION NOT NULL,
    CONSTRAINT [PK_Cash_tbReportingProfileSetting] PRIMARY KEY CLUSTERED ([ReportingProfileSettingId]),
    CONSTRAINT [CK_Cash_tbReportingProfileSetting_Validity] CHECK ([EffectiveTo] IS NULL OR [EffectiveTo] >= [EffectiveFrom]),
    CONSTRAINT [CK_Cash_tbReportingProfileSetting_OneValue] CHECK
    (
        (CASE WHEN [TextValue] IS NULL THEN 0 ELSE 1 END) +
        (CASE WHEN [IntegerValue] IS NULL THEN 0 ELSE 1 END) +
        (CASE WHEN [DecimalValue] IS NULL THEN 0 ELSE 1 END) +
        (CASE WHEN [DateValue] IS NULL THEN 0 ELSE 1 END) +
        (CASE WHEN [BooleanValue] IS NULL THEN 0 ELSE 1 END) = 1
    ),
    CONSTRAINT [FK_Cash_tbReportingProfileSetting_Cash_tbReportingProfile] FOREIGN KEY ([ReportingProfileId])
        REFERENCES [Cash].[tbReportingProfile] ([ReportingProfileId]) ON DELETE CASCADE,
    CONSTRAINT [FK_Cash_tbReportingProfileSetting_App_tbSettingDefinition] FOREIGN KEY ([SettingCode])
        REFERENCES [App].[tbSettingDefinition] ([SettingCode]),
    CONSTRAINT [FK_Cash_tbReportingProfileSetting_App_tbStatutoryStatus] FOREIGN KEY ([StatusCode])
        REFERENCES [App].[tbStatutoryStatus] ([StatusCode]),
    CONSTRAINT [FK_Cash_tbReportingProfileSetting_App_tbValueSource] FOREIGN KEY ([ValueSourceCode])
        REFERENCES [App].[tbValueSource] ([ValueSourceCode])
);
GO
CREATE INDEX [IX_Cash_tbReportingProfileSetting_Resolver]
    ON [Cash].[tbReportingProfileSetting] ([ReportingProfileId], [SettingCode], [EffectiveFrom], [EffectiveTo]);
GO
CREATE TRIGGER [Cash].[Cash_tbReportingProfileSetting_TriggerIntegrity]
ON [Cash].[tbReportingProfileSetting]
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS
    (
        SELECT 1
        FROM inserted candidate
        JOIN App.tbSettingDefinition definition ON definition.SettingCode = candidate.SettingCode
        JOIN Cash.tbReportingProfile profile ON profile.ReportingProfileId = candidate.ReportingProfileId
        JOIN App.tbAuthority authority ON authority.AuthorityCode = profile.AuthorityCode
        WHERE (definition.JurisdictionCode IS NOT NULL AND definition.JurisdictionCode <> authority.JurisdictionCode)
           OR (definition.AuthorityCode IS NOT NULL AND definition.AuthorityCode <> profile.AuthorityCode)
           OR (definition.ReportingTypeCode IS NOT NULL AND definition.ReportingTypeCode <> profile.ReportingTypeCode)
           OR (definition.ValueTypeCode = N'TEXT' AND candidate.TextValue IS NULL)
           OR (definition.ValueTypeCode = N'INTEGER' AND candidate.IntegerValue IS NULL)
           OR (definition.ValueTypeCode = N'DECIMAL' AND candidate.DecimalValue IS NULL)
           OR (definition.ValueTypeCode = N'DATE' AND candidate.DateValue IS NULL)
           OR (definition.ValueTypeCode = N'BOOLEAN' AND candidate.BooleanValue IS NULL)
           OR
           (
               definition.AllowedValues IS NOT NULL
               AND NOT EXISTS
               (
                   SELECT 1
                   FROM OPENJSON(definition.AllowedValues) allowed
                   WHERE allowed.[value] = CASE definition.ValueTypeCode
                       WHEN N'TEXT' THEN candidate.TextValue
                       WHEN N'INTEGER' THEN CONVERT(nvarchar(100), candidate.IntegerValue)
                       WHEN N'DECIMAL' THEN CONVERT(nvarchar(100), candidate.DecimalValue)
                       WHEN N'DATE' THEN CONVERT(nvarchar(10), candidate.DateValue, 23)
                       WHEN N'BOOLEAN' THEN CASE candidate.BooleanValue WHEN 1 THEN N'true' WHEN 0 THEN N'false' END
                   END
               )
           )
    )
        THROW 51023, 'Reporting profile setting value type or scope does not match its definition.', 1;

    IF EXISTS
    (
        SELECT 1
        FROM inserted candidate
        JOIN App.tbStatutoryStatus candidateStatus
            ON candidateStatus.StatusCode = candidate.StatusCode
           AND candidateStatus.IsActive = 1
        JOIN Cash.tbReportingProfileSetting existing
            ON existing.ReportingProfileId = candidate.ReportingProfileId
           AND existing.SettingCode = candidate.SettingCode
           AND existing.ReportingProfileSettingId <> candidate.ReportingProfileSettingId
        JOIN App.tbStatutoryStatus existingStatus
            ON existingStatus.StatusCode = existing.StatusCode
           AND existingStatus.IsActive = 1
        WHERE candidate.EffectiveFrom <= ISNULL(existing.EffectiveTo, CONVERT(date, '99991231'))
          AND existing.EffectiveFrom <= ISNULL(candidate.EffectiveTo, CONVERT(date, '99991231'))
    )
        THROW 51024, 'Reporting profile setting validity overlaps an active value.', 1;
END;
