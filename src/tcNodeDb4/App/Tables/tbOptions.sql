CREATE TABLE [App].[tbOptions] (
    [Identifier]         NVARCHAR (4)   NOT NULL,
    [IsInitialised]      BIT            CONSTRAINT [DF_App_tbOptions_IsIntialised] DEFAULT ((0)) NOT NULL,
    [SubjectCode]        NVARCHAR (50)  NOT NULL,
    [RegisterName]       NVARCHAR (50)  NOT NULL,
    [CategoryVersionId]  NVARCHAR (10)  NULL,
    [DefaultPrintMode]   SMALLINT       CONSTRAINT [DF_App_tbOptions_DefaultPrintMode] DEFAULT ((2)) NOT NULL,
    [BucketTypeCode]     SMALLINT       CONSTRAINT [DF_App_tbOptions_BucketTypeCode] DEFAULT ((1)) NOT NULL,
    [BucketIntervalCode] SMALLINT       CONSTRAINT [DF_App_tbOptions_BucketIntervalCode] DEFAULT ((1)) NOT NULL,
    [TaxHorizon]         SMALLINT       CONSTRAINT [DF_App_tbOptions_TaxHorizon] DEFAULT ((90)) NOT NULL,
    [IsAutoOffsetDays]   BIT            CONSTRAINT [DF_App_tbOptions_IsAutoOffsetDays] DEFAULT ((0)) NOT NULL,
    [JurisdictionCode]   NVARCHAR (10)  NOT NULL,
    [UnitOfCharge]       NVARCHAR (5)   NULL,
    [MinerFeeCode]       NVARCHAR (50)  NULL,
    [MinerAccountCode]   NVARCHAR (50)  NULL,
    [CoinTypeCode]       SMALLINT       CONSTRAINT [DF_App_tbOptions_CoinTypeCode] DEFAULT ((2)) NOT NULL,
    [HostId]             INT            NULL,
    [SymmetricKey]       VARBINARY (32) NULL,
    [SymmetricIV]        VARBINARY (16) NULL,
    [SupportRequestTemplateId]      INT NULL,
    [UserRegistrationTemplateId]    INT NULL,
    [UserRegistrationConfirmTemplateId]     INT NULL,
    [UserRegistrationAdminNotifyTemplateId] INT NULL,
    [InsertedBy]         NVARCHAR (50)  CONSTRAINT [DF_App_tbOptions_InsertedBy] DEFAULT (Usr.fnUserName()) NOT NULL,
    [InsertedOn]         DATETIME       CONSTRAINT [DF_App_tbOptions_InsertedOn] DEFAULT (getdate()) NOT NULL,
    [UpdatedBy]          NVARCHAR (50)  CONSTRAINT [DF_App_tbOptions_UpdatedBy] DEFAULT (Usr.fnUserName()) NOT NULL,
    [UpdatedOn]          DATETIME       CONSTRAINT [DF_App_tbOptions_UpdatedOn] DEFAULT (getdate()) NOT NULL,
    [RowVer]             ROWVERSION     NOT NULL,
    CONSTRAINT [PK_App_tbOptions] PRIMARY KEY CLUSTERED ([Identifier] ASC) WITH (FILLFACTOR = 90),
    CONSTRAINT [FK_App_tbOptions_Cash_tbCategoryVersion] FOREIGN KEY ([CategoryVersionId]) REFERENCES [Cash].[tbCategoryVersion] ([VersionId]),
    CONSTRAINT [FK_App_tbOptions_App_tbBucketInterval] FOREIGN KEY ([BucketIntervalCode]) REFERENCES [App].[tbBucketInterval] ([BucketIntervalCode]),
    CONSTRAINT [FK_App_tbOptions_App_tbBucketType] FOREIGN KEY ([BucketTypeCode]) REFERENCES [App].[tbBucketType] ([BucketTypeCode]),
    CONSTRAINT [FK_App_tbOptions_App_tbHost] FOREIGN KEY ([HostId]) REFERENCES [App].[tbHost] ([HostId]),
    CONSTRAINT [FK_App_tbOptions_App_tbJurisdiction] FOREIGN KEY ([JurisdictionCode]) REFERENCES [App].[tbJurisdiction] ([JurisdictionCode]),
    CONSTRAINT [FK_App_tbOptions_App_tbRegister] FOREIGN KEY ([RegisterName]) REFERENCES [App].[tbRegister] ([RegisterName]) ON UPDATE CASCADE,
    CONSTRAINT [FK_App_tbOptions_Cash_tbCode] FOREIGN KEY ([MinerFeeCode]) REFERENCES [Cash].[tbCode] ([CashCode]),
    CONSTRAINT [FK_App_tbOptions_Cash_tbCoinType] FOREIGN KEY ([CoinTypeCode]) REFERENCES [Cash].[tbCoinType] ([CoinTypeCode]),
    CONSTRAINT [FK_App_tbOptions_Subject_tb] FOREIGN KEY ([SubjectCode]) REFERENCES [Subject].[tbSubject] ([SubjectCode]) ON UPDATE CASCADE,
    CONSTRAINT [FK_App_tbOptions_Subject_tbSubject] FOREIGN KEY ([MinerAccountCode]) REFERENCES [Subject].[tbSubject] ([SubjectCode]),
    CONSTRAINT [FK_App_tbUoc_UnitOfCharge] FOREIGN KEY ([UnitOfCharge]) REFERENCES [App].[tbUoc] ([UnitOfCharge]),
    CONSTRAINT [FK_App_tbOptions_Web_tbTemplate_SupportRequest]
        FOREIGN KEY ([SupportRequestTemplateId]) REFERENCES [Web].[tbTemplate] ([TemplateId]),
    CONSTRAINT [FK_App_tbOptions_Web_tbTemplate_UserRegistration]
        FOREIGN KEY ([UserRegistrationTemplateId]) REFERENCES [Web].[tbTemplate] ([TemplateId]),
    CONSTRAINT [FK_App_tbOptions_Web_tbTemplate_UserRegistrationConfirm]
        FOREIGN KEY ([UserRegistrationConfirmTemplateId]) REFERENCES [Web].[tbTemplate] ([TemplateId]),
    CONSTRAINT [FK_App_tbOptions_Web_tbTemplate_UserRegistrationAdminNotify]
        FOREIGN KEY ([UserRegistrationAdminNotifyTemplateId]) REFERENCES [Web].[tbTemplate] ([TemplateId])

);
GO
CREATE TRIGGER App.App_tbOptions_TriggerUpdate 
   ON App.tbOptions
   AFTER INSERT, UPDATE
AS 
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY
		IF (SELECT COUNT_BIG(*) FROM App.tbOptions WITH (TABLOCKX, HOLDLOCK)) > 1
			THROW 51089, 'App.tbOptions must contain no more than one row.', 1;

		IF EXISTS
		(
			SELECT 1
			FROM inserted AS i
			WHERE i.IsInitialised = 1
			  AND i.CategoryVersionId IS NULL
		)
			THROW 51090, 'An initialised node requires an active Category Tree version.', 1;

		IF EXISTS
		(
			SELECT 1
			FROM inserted AS i
			LEFT JOIN Cash.tbCategoryVersion AS version
			  ON version.VersionId = i.CategoryVersionId
			WHERE i.CategoryVersionId IS NOT NULL
			  AND (version.VersionId IS NULL OR version.VersionStatusCode NOT IN (1, 2))
		)
			THROW 51091, 'The active Category Tree pointer must reference a Published or Submitted version.', 1;

		UPDATE App.tbOptions
		SET UpdatedBy = Usr.fnUserName(), UpdatedOn = CURRENT_TIMESTAMP
		FROM App.tbOptions INNER JOIN inserted AS i ON tbOptions.Identifier = i.Identifier;

		IF UPDATE(CoinTypeCode)
		BEGIN
			UPDATE Subject.tbAccount
			SET CoinTypeCode = (SELECT CoinTypeCode FROM inserted)
		END
	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
END
