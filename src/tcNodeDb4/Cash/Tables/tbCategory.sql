CREATE TABLE [Cash].[tbCategory] (
    [VersionId]        NVARCHAR (10) NOT NULL CONSTRAINT [DF_Cash_tbCategory_VersionId] DEFAULT ([Cash].[fnCategoryVersionDefault]()),
    [CategoryCode]     NVARCHAR (10) NOT NULL,
    [Category]         NVARCHAR (50) NOT NULL,
    [CategoryTypeCode] SMALLINT      CONSTRAINT [DF_Cash_tbCategory_CategoryTypeCode] DEFAULT ((1)) NOT NULL,
    [CashPolarityCode] SMALLINT      CONSTRAINT [DF_Cash_tbCategory_CashPolarityCode] DEFAULT ((1)) NOT NULL,
    [CashTypeCode]     SMALLINT      CONSTRAINT [DF_Cash_tbCategory_CashTypeCode] DEFAULT ((0)) NOT NULL,
    [DisplayOrder]     SMALLINT      CONSTRAINT [DF_Cash_tbCategory_DisplayOrder] DEFAULT ((0)) NOT NULL,
    [IsEnabled]        SMALLINT      CONSTRAINT [DF_Cash_tbCategory_IsEnabled] DEFAULT ((1)) NOT NULL,
    [InsertedBy]       NVARCHAR (50) CONSTRAINT [DF_Cash_tbCategory_InsertedBy] DEFAULT (Usr.fnUserName()) NOT NULL,
    [InsertedOn]       DATETIME      CONSTRAINT [DF_Cash_tbCategory_InsertedOn] DEFAULT (getdate()) NOT NULL,
    [UpdatedBy]        NVARCHAR (50) CONSTRAINT [DF_Cash_tbCategory_UpdatedBy] DEFAULT (Usr.fnUserName()) NOT NULL,
    [UpdatedOn]        DATETIME      CONSTRAINT [DF_Cash_tbCategory_UpdatedOn] DEFAULT (getdate()) NOT NULL,
    [RowVer]           ROWVERSION    NOT NULL,
    CONSTRAINT [PK_Cash_tbCategory] PRIMARY KEY CLUSTERED ([VersionId] ASC, [CategoryCode] ASC) WITH (FILLFACTOR = 90),
    CONSTRAINT [FK_Cash_tbCategory_Cash_tbCategoryVersion] FOREIGN KEY ([VersionId]) REFERENCES [Cash].[tbCategoryVersion] ([VersionId]),
    CONSTRAINT [FK_Cash_tbCategory_Cash_tbCategoryType] FOREIGN KEY ([CategoryTypeCode]) REFERENCES [Cash].[tbCategoryType] ([CategoryTypeCode]),
    CONSTRAINT [FK_Cash_tbCategory_Cash_tbPolarity] FOREIGN KEY ([CashPolarityCode]) REFERENCES [Cash].[tbPolarity] ([CashPolarityCode]),
    CONSTRAINT [FK_Cash_tbCategory_Cash_tbType] FOREIGN KEY ([CashTypeCode]) REFERENCES [Cash].[tbType] ([CashTypeCode])
);


GO
CREATE NONCLUSTERED INDEX [IX_Cash_tbCategory_DisplayOrder]
    ON [Cash].[tbCategory]([VersionId] ASC, [DisplayOrder] ASC, [Category] ASC) WITH (FILLFACTOR = 90);


GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_Cash_tbCategory_IsEnabled_Category]
    ON [Cash].[tbCategory]([VersionId] ASC, [IsEnabled] ASC, [Category] ASC);


GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_Cash_tbCategory_IsEnabled_CategoryCode]
    ON [Cash].[tbCategory]([VersionId] ASC, [IsEnabled] ASC, [CategoryCode] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_Cash_tbCategory_Name]
    ON [Cash].[tbCategory]([VersionId] ASC, [Category] ASC) WITH (FILLFACTOR = 90);


GO
CREATE NONCLUSTERED INDEX [IX_Cash_tbCategory_TypeCategory]
    ON [Cash].[tbCategory]([VersionId] ASC, [CategoryTypeCode] ASC, [Category] ASC) WITH (FILLFACTOR = 90);


GO
CREATE NONCLUSTERED INDEX [IX_Cash_tbCategory_TypeOrderCategory]
    ON [Cash].[tbCategory]([VersionId] ASC, [CategoryTypeCode] ASC, [DisplayOrder] ASC, [Category] ASC) WITH (FILLFACTOR = 90);


GO
CREATE TRIGGER Cash.Cash_tbCategory_TriggerUpdate 
   ON  Cash.tbCategory
   AFTER UPDATE, INSERT
AS 
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY	
		IF EXISTS (SELECT * FROM inserted i WHERE App.fnParsePrimaryKey(CategoryCode) = 0)
		BEGIN
			DECLARE @Msg NVARCHAR(MAX);
			SELECT @Msg = Message FROM App.tbText WHERE TextId = 2004;
			RAISERROR (@Msg, 10, 1)
			ROLLBACK
		END

		IF NOT UPDATE(UpdatedBy)
		BEGIN
			UPDATE Cash.tbCategory
			SET UpdatedBy = Usr.fnUserName(), UpdatedOn = CURRENT_TIMESTAMP
			FROM Cash.tbCategory
			INNER JOIN inserted AS i
				ON tbCategory.VersionId = i.VersionId
				AND tbCategory.CategoryCode = i.CategoryCode;
		END

	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
END

GO

CREATE TRIGGER [Cash].[Cash_tbCategory_TriggerVersionGuard]
ON [Cash].[tbCategory]
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
	SET NOCOUNT ON;

	IF EXISTS
	(
		SELECT 1
		FROM
		(
			SELECT VersionId FROM inserted
			UNION
			SELECT VersionId FROM deleted
		) AS affected
		JOIN Cash.tbCategoryVersion AS version
		  ON version.VersionId = affected.VersionId
		WHERE version.VersionStatusCode IN (2, 3)
	)
		THROW 51097, 'Submitted and Archived Category Tree categories are immutable.', 1;

	;WITH affected AS
	(
		SELECT VersionId FROM inserted
		UNION
		SELECT VersionId FROM deleted
	)
	UPDATE version
	SET CanonicalSha256 = NULL,
		CanonicalByteLength = NULL,
		ContentChangedOn = SYSUTCDATETIME()
	FROM Cash.tbCategoryVersion AS version
	JOIN affected
	  ON affected.VersionId = version.VersionId
	WHERE version.VersionStatusCode IN (0, 1);
END;
