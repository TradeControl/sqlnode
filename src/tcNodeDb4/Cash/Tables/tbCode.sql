CREATE TABLE [Cash].[tbCode] (
    [CashCode]        NVARCHAR (50)  NOT NULL,
    [CashDescription] NVARCHAR (100) NOT NULL,
    [CategoryCode]    NVARCHAR (10)  NOT NULL,
    [TaxCode]         NVARCHAR (10)  NOT NULL,
    [IsEnabled]       SMALLINT       CONSTRAINT [DF_Cash_tbCode_IsEnabled] DEFAULT ((1)) NOT NULL,
    [InsertedBy]      NVARCHAR (50)  CONSTRAINT [DF_Cash_tbCode_InsertedBy] DEFAULT (Usr.fnUserName()) NOT NULL,
    [InsertedOn]      DATETIME       CONSTRAINT [DF_Cash_tbCode_InsertedOn] DEFAULT (getdate()) NOT NULL,
    [UpdatedBy]       NVARCHAR (50)  CONSTRAINT [DF_Cash_tbCode_UpdatedBy] DEFAULT (Usr.fnUserName()) NOT NULL,
    [UpdatedOn]       DATETIME       CONSTRAINT [DF_Cash_tbCode_UpdatedOn] DEFAULT (getdate()) NOT NULL,
    [RowVer]          ROWVERSION     NOT NULL,
    CONSTRAINT [PK_Cash_tbCode] PRIMARY KEY CLUSTERED ([CashCode] ASC) WITH (FILLFACTOR = 90),
    CONSTRAINT [FK_Cash_tbCode_App_tbTaxCode] FOREIGN KEY ([TaxCode]) REFERENCES [App].[tbTaxCode] ([TaxCode]),
    CONSTRAINT [FK_Cash_tbCode_Cash_tbCategory1] FOREIGN KEY ([CategoryCode]) REFERENCES [Cash].[tbCategory] ([CategoryCode]) ON UPDATE CASCADE,
    CONSTRAINT [IX_Cash_tbCodeDescription] UNIQUE NONCLUSTERED ([CashDescription] ASC) WITH (FILLFACTOR = 90)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_Cash_tbCode_Category_IsEnabled_Code]
    ON [Cash].[tbCode]([CategoryCode] ASC, [IsEnabled] ASC, [CashCode] ASC);


GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_Cash_tbCode_IsEnabled_Code]
    ON [Cash].[tbCode]([IsEnabled] ASC, [CashCode] ASC);


GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_Cash_tbCode_IsEnabled_Description]
    ON [Cash].[tbCode]([IsEnabled] ASC, [CashDescription] ASC);


GO
CREATE TRIGGER Cash.Cash_tbCode_TriggerUpdate
   ON  Cash.tbCode
   AFTER UPDATE, INSERT
AS 
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY	
		IF EXISTS (SELECT * FROM inserted i WHERE App.fnParsePrimaryKey(CashCode) = 0)
			BEGIN
			DECLARE @Msg NVARCHAR(MAX);
			SELECT @Msg = Message FROM App.tbText WHERE TextId = 2004;
			RAISERROR (@Msg, 10, 1);
			ROLLBACK
			END
		ELSE IF NOT UPDATE(UpdatedBy)
			BEGIN
			UPDATE Cash.tbCode
			SET UpdatedBy = Usr.fnUserName(), UpdatedOn = CURRENT_TIMESTAMP
			FROM Cash.tbCode INNER JOIN inserted AS i ON tbCode.CashCode = i.CashCode;
			END
	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
END

GO

CREATE TRIGGER [Cash].[Cash_tbCode_TriggerCategoryVersionShadow]
ON [Cash].[tbCode]
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT, XACT_ABORT ON;

    IF TRY_CONVERT(BIT, SESSION_CONTEXT(N'CategoryTreeExplicitMapping')) = 1
        RETURN;

    DECLARE @VersionId NVARCHAR(10) =
    (
        SELECT CategoryVersionId
        FROM App.tbOptions
    );

    -- Commissioning supplies its Draft VersionId explicitly. Once a version is
    -- active, this compatibility trigger keeps legacy Cash Code writers mapped.
    IF @VersionId IS NULL
        RETURN;

    DELETE map
    FROM Cash.tbCategoryCodeMap AS map
    JOIN deleted AS d
      ON d.CashCode = map.CashCode
    LEFT JOIN inserted AS i
      ON i.CashCode = d.CashCode
    WHERE map.VersionId = @VersionId
      AND i.CashCode IS NULL;

    UPDATE map
    SET CategoryCode = i.CategoryCode
    FROM Cash.tbCategoryCodeMap AS map
    JOIN inserted AS i
      ON i.CashCode = map.CashCode
    WHERE map.VersionId = @VersionId
      AND map.CategoryCode <> i.CategoryCode;

    INSERT INTO Cash.tbCategoryCodeMap (VersionId, CashCode, CategoryCode)
    SELECT @VersionId, i.CashCode, i.CategoryCode
    FROM inserted AS i
    WHERE NOT EXISTS
    (
        SELECT 1
        FROM Cash.tbCategoryCodeMap AS map
        WHERE map.VersionId = @VersionId
          AND map.CashCode = i.CashCode
    );
END;
