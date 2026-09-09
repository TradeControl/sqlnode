CREATE TABLE [Subject].[tbLegalProfile]
(
    [SubjectCode] NVARCHAR(50) NOT NULL,
    [LegalFormJurisdictionCode] NVARCHAR(10) NOT NULL,
    [LegalFormCode] NVARCHAR(20) NOT NULL,
    [RegistryJurisdictionCode] NVARCHAR(10) NULL,
    [ValidFrom] DATE NOT NULL,
    [ValidTo] DATE NULL,
    [StatusCode] SMALLINT NOT NULL CONSTRAINT [DF_Subject_tbLegalProfile_StatusCode] DEFAULT (0),
    [ValueSourceCode] NVARCHAR(10) NOT NULL,
    [IsReviewed] BIT NOT NULL CONSTRAINT [DF_Subject_tbLegalProfile_IsReviewed] DEFAULT (0),
    [InsertedBy] NVARCHAR(50) NOT NULL CONSTRAINT [DF_Subject_tbLegalProfile_InsertedBy] DEFAULT (suser_sname()),
    [InsertedOn] DATETIME NOT NULL CONSTRAINT [DF_Subject_tbLegalProfile_InsertedOn] DEFAULT (getdate()),
    [UpdatedBy] NVARCHAR(50) NOT NULL CONSTRAINT [DF_Subject_tbLegalProfile_UpdatedBy] DEFAULT (suser_sname()),
    [UpdatedOn] DATETIME NOT NULL CONSTRAINT [DF_Subject_tbLegalProfile_UpdatedOn] DEFAULT (getdate()),
    [RowVer] ROWVERSION NOT NULL,
    CONSTRAINT [PK_Subject_tbLegalProfile] PRIMARY KEY CLUSTERED
        ([SubjectCode], [LegalFormJurisdictionCode], [LegalFormCode], [ValidFrom]),
    CONSTRAINT [CK_Subject_tbLegalProfile_Validity] CHECK ([ValidTo] IS NULL OR [ValidTo] >= [ValidFrom]),
    CONSTRAINT [FK_Subject_tbLegalProfile_Subject_tbSubject] FOREIGN KEY ([SubjectCode])
        REFERENCES [Subject].[tbSubject] ([SubjectCode]) ON UPDATE CASCADE,
    CONSTRAINT [FK_Subject_tbLegalProfile_App_tbLegalForm]
        FOREIGN KEY ([LegalFormJurisdictionCode], [LegalFormCode])
        REFERENCES [App].[tbLegalForm] ([JurisdictionCode], [LegalFormCode]),
    CONSTRAINT [FK_Subject_tbLegalProfile_App_tbJurisdiction] FOREIGN KEY ([RegistryJurisdictionCode])
        REFERENCES [App].[tbJurisdiction] ([JurisdictionCode]),
    CONSTRAINT [FK_Subject_tbLegalProfile_App_tbStatutoryStatus] FOREIGN KEY ([StatusCode])
        REFERENCES [App].[tbStatutoryStatus] ([StatusCode]),
    CONSTRAINT [FK_Subject_tbLegalProfile_App_tbValueSource] FOREIGN KEY ([ValueSourceCode])
        REFERENCES [App].[tbValueSource] ([ValueSourceCode])
);
GO
CREATE INDEX [IX_Subject_tbLegalProfile_Resolver]
    ON [Subject].[tbLegalProfile] ([SubjectCode], [ValidFrom], [ValidTo]);
GO
CREATE TRIGGER [Subject].[Subject_tbLegalProfile_TriggerIntegrity]
ON [Subject].[tbLegalProfile]
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS
    (
        SELECT 1
        FROM inserted candidate
        JOIN App.tbStatutoryStatus candidateStatus
          ON candidateStatus.StatusCode = candidate.StatusCode AND candidateStatus.IsActive = 1
        JOIN Subject.tbLegalProfile existing
          ON existing.SubjectCode = candidate.SubjectCode
         AND
         (
             existing.LegalFormJurisdictionCode <> candidate.LegalFormJurisdictionCode
             OR existing.LegalFormCode <> candidate.LegalFormCode
             OR existing.ValidFrom <> candidate.ValidFrom
         )
        JOIN App.tbStatutoryStatus existingStatus
          ON existingStatus.StatusCode = existing.StatusCode AND existingStatus.IsActive = 1
        WHERE candidate.ValidFrom <= ISNULL(existing.ValidTo, CONVERT(date, '99991231'))
          AND existing.ValidFrom <= ISNULL(candidate.ValidTo, CONVERT(date, '99991231'))
    )
        THROW 51026, 'Legal profile validity overlaps an active profile for the subject.', 1;

    UPDATE profile
    SET UpdatedBy = suser_sname(), UpdatedOn = current_timestamp
    FROM Subject.tbLegalProfile profile
    JOIN inserted i
      ON i.SubjectCode = profile.SubjectCode
     AND i.LegalFormJurisdictionCode = profile.LegalFormJurisdictionCode
     AND i.LegalFormCode = profile.LegalFormCode
     AND i.ValidFrom = profile.ValidFrom;
END;
