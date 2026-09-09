CREATE TABLE [Subject].[tbRegistration]
(
    [SubjectCode] NVARCHAR(50) NOT NULL,
    [RegistrationCode] NVARCHAR(20) NOT NULL,
    [RegistrationSchemeCode] NVARCHAR(20) NOT NULL,
    [RegistrationValue] NVARCHAR(255) NOT NULL,
    [ValidFrom] DATE NOT NULL,
    [ValidTo] DATE NULL,
    [StatusCode] SMALLINT NOT NULL CONSTRAINT [DF_Subject_tbRegistration_StatusCode] DEFAULT (0),
    [ValueSourceCode] NVARCHAR(10) NOT NULL,
    [IsReviewed] BIT NOT NULL CONSTRAINT [DF_Subject_tbRegistration_IsReviewed] DEFAULT (0),
    [InsertedBy] NVARCHAR(50) NOT NULL CONSTRAINT [DF_Subject_tbRegistration_InsertedBy] DEFAULT (suser_sname()),
    [InsertedOn] DATETIME NOT NULL CONSTRAINT [DF_Subject_tbRegistration_InsertedOn] DEFAULT (getdate()),
    [UpdatedBy] NVARCHAR(50) NOT NULL CONSTRAINT [DF_Subject_tbRegistration_UpdatedBy] DEFAULT (suser_sname()),
    [UpdatedOn] DATETIME NOT NULL CONSTRAINT [DF_Subject_tbRegistration_UpdatedOn] DEFAULT (getdate()),
    [RowVer] ROWVERSION NOT NULL,
    CONSTRAINT [PK_Subject_tbRegistration] PRIMARY KEY CLUSTERED ([SubjectCode], [RegistrationCode]),
    CONSTRAINT [CK_Subject_tbRegistration_Validity] CHECK ([ValidTo] IS NULL OR [ValidTo] >= [ValidFrom]),
    CONSTRAINT [FK_Subject_tbRegistration_Subject_tbSubject] FOREIGN KEY ([SubjectCode])
        REFERENCES [Subject].[tbSubject] ([SubjectCode]) ON UPDATE CASCADE,
    CONSTRAINT [FK_Subject_tbRegistration_App_tbRegistrationScheme] FOREIGN KEY ([RegistrationSchemeCode])
        REFERENCES [App].[tbRegistrationScheme] ([RegistrationSchemeCode]),
    CONSTRAINT [FK_Subject_tbRegistration_App_tbStatutoryStatus] FOREIGN KEY ([StatusCode])
        REFERENCES [App].[tbStatutoryStatus] ([StatusCode]),
    CONSTRAINT [FK_Subject_tbRegistration_App_tbValueSource] FOREIGN KEY ([ValueSourceCode])
        REFERENCES [App].[tbValueSource] ([ValueSourceCode])
);
GO
CREATE INDEX [IX_Subject_tbRegistration_Resolver]
    ON [Subject].[tbRegistration] ([SubjectCode], [RegistrationSchemeCode], [ValidFrom], [ValidTo]);
GO
CREATE TRIGGER [Subject].[Subject_tbRegistration_TriggerIntegrity]
ON [Subject].[tbRegistration]
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS
    (
        SELECT 1
        FROM inserted candidate
        JOIN App.tbRegistrationScheme scheme
            ON scheme.RegistrationSchemeCode = candidate.RegistrationSchemeCode
           AND scheme.IsSingleValue = 1
        JOIN App.tbStatutoryStatus candidateStatus
            ON candidateStatus.StatusCode = candidate.StatusCode
           AND candidateStatus.IsActive = 1
        JOIN Subject.tbRegistration existing
            ON existing.SubjectCode = candidate.SubjectCode
           AND existing.RegistrationSchemeCode = candidate.RegistrationSchemeCode
           AND existing.RegistrationCode <> candidate.RegistrationCode
        JOIN App.tbStatutoryStatus existingStatus
            ON existingStatus.StatusCode = existing.StatusCode
           AND existingStatus.IsActive = 1
        WHERE candidate.ValidFrom <= ISNULL(existing.ValidTo, CONVERT(date, '99991231'))
          AND existing.ValidFrom <= ISNULL(candidate.ValidTo, CONVERT(date, '99991231'))
    )
        THROW 51020, 'Subject registration validity overlaps an active single-value registration.', 1;
END;
