CREATE TABLE [Cash].[tbReportingProfile]
(
    [SubjectCode] NVARCHAR(50) NOT NULL,
    [ReportingProfileCode] NVARCHAR(20) NOT NULL,
    [TaxSourceCode] NVARCHAR(20) NULL,
    [AuthorityCode] NVARCHAR(20) NOT NULL,
    [ReportingTypeCode] NVARCHAR(20) NOT NULL,
    [AuthorityReference] NVARCHAR(100) NULL,
    [ValidFrom] DATE NOT NULL,
    [ValidTo] DATE NULL,
    [StatusCode] SMALLINT NOT NULL CONSTRAINT [DF_Cash_tbReportingProfile_StatusCode] DEFAULT (0),
    [ValueSourceCode] NVARCHAR(10) NOT NULL,
    [IsReviewed] BIT NOT NULL CONSTRAINT [DF_Cash_tbReportingProfile_IsReviewed] DEFAULT (0),
    [InsertedBy] NVARCHAR(50) NOT NULL CONSTRAINT [DF_Cash_tbReportingProfile_InsertedBy] DEFAULT (suser_sname()),
    [InsertedOn] DATETIME NOT NULL CONSTRAINT [DF_Cash_tbReportingProfile_InsertedOn] DEFAULT (getdate()),
    [UpdatedBy] NVARCHAR(50) NOT NULL CONSTRAINT [DF_Cash_tbReportingProfile_UpdatedBy] DEFAULT (suser_sname()),
    [UpdatedOn] DATETIME NOT NULL CONSTRAINT [DF_Cash_tbReportingProfile_UpdatedOn] DEFAULT (getdate()),
    [RowVer] ROWVERSION NOT NULL,
    CONSTRAINT [PK_Cash_tbReportingProfile] PRIMARY KEY CLUSTERED ([SubjectCode], [ReportingProfileCode]),
    CONSTRAINT [CK_Cash_tbReportingProfile_Validity] CHECK ([ValidTo] IS NULL OR [ValidTo] >= [ValidFrom]),
    CONSTRAINT [FK_Cash_tbReportingProfile_Subject_tbSubject] FOREIGN KEY ([SubjectCode])
        REFERENCES [Subject].[tbSubject] ([SubjectCode]) ON UPDATE CASCADE,
    CONSTRAINT [FK_Cash_tbReportingProfile_Cash_tbTaxTagSource] FOREIGN KEY ([TaxSourceCode])
        REFERENCES [Cash].[tbTaxTagSource] ([TaxSourceCode]),
    CONSTRAINT [FK_Cash_tbReportingProfile_App_tbAuthority] FOREIGN KEY ([AuthorityCode])
        REFERENCES [App].[tbAuthority] ([AuthorityCode]),
    CONSTRAINT [FK_Cash_tbReportingProfile_App_tbReportingType] FOREIGN KEY ([ReportingTypeCode])
        REFERENCES [App].[tbReportingType] ([ReportingTypeCode]),
    CONSTRAINT [FK_Cash_tbReportingProfile_App_tbStatutoryStatus] FOREIGN KEY ([StatusCode])
        REFERENCES [App].[tbStatutoryStatus] ([StatusCode]),
    CONSTRAINT [FK_Cash_tbReportingProfile_App_tbValueSource] FOREIGN KEY ([ValueSourceCode])
        REFERENCES [App].[tbValueSource] ([ValueSourceCode])
);
GO
CREATE UNIQUE INDEX [UX_Cash_tbReportingProfile_AuthorityReference]
    ON [Cash].[tbReportingProfile] ([AuthorityCode], [AuthorityReference])
    WHERE [AuthorityReference] IS NOT NULL;
GO
CREATE INDEX [IX_Cash_tbReportingProfile_Resolver]
    ON [Cash].[tbReportingProfile] ([SubjectCode], [ReportingTypeCode], [TaxSourceCode], [ValidFrom], [ValidTo]);
GO
CREATE TRIGGER [Cash].[Cash_tbReportingProfile_TriggerIntegrity]
ON [Cash].[tbReportingProfile]
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS
    (
        SELECT 1
        FROM inserted candidate
        JOIN App.tbReportingType reportingType
            ON reportingType.ReportingTypeCode = candidate.ReportingTypeCode
        WHERE reportingType.AuthorityCode <> candidate.AuthorityCode
           OR (reportingType.RequiresTaxSource = 1 AND candidate.TaxSourceCode IS NULL)
    )
        THROW 51021, 'Reporting profile does not satisfy its reporting-type authority or Tax Source requirements.', 1;

    IF EXISTS
    (
        SELECT 1
        FROM inserted candidate
        JOIN App.tbStatutoryStatus candidateStatus
            ON candidateStatus.StatusCode = candidate.StatusCode
           AND candidateStatus.IsActive = 1
        JOIN Cash.tbReportingProfile existing
            ON existing.SubjectCode = candidate.SubjectCode
           AND existing.AuthorityCode = candidate.AuthorityCode
           AND existing.ReportingTypeCode = candidate.ReportingTypeCode
           AND ISNULL(existing.TaxSourceCode, N'') = ISNULL(candidate.TaxSourceCode, N'')
           AND existing.ReportingProfileCode <> candidate.ReportingProfileCode
        JOIN App.tbStatutoryStatus existingStatus
            ON existingStatus.StatusCode = existing.StatusCode
           AND existingStatus.IsActive = 1
        WHERE candidate.ValidFrom <= ISNULL(existing.ValidTo, CONVERT(date, '99991231'))
          AND existing.ValidFrom <= ISNULL(candidate.ValidTo, CONVERT(date, '99991231'))
    )
        THROW 51022, 'Reporting profile validity overlaps an active profile for the same reporting scope.', 1;
END;
