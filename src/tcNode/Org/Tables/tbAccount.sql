CREATE TABLE [Org].[tbAccount] (
    [CashAccountCode] NVARCHAR (10) NOT NULL,
    [AccountCode]     NVARCHAR (10) NOT NULL,
    [CashAccountName] NVARCHAR (50) NOT NULL,
    [OpeningBalance]  MONEY         CONSTRAINT [DF_Org_tbAccount_OpeningBalance] DEFAULT ((0)) NOT NULL,
    [CurrentBalance]  MONEY         CONSTRAINT [DF_Org_tbAccount_CurrentBalance] DEFAULT ((0)) NOT NULL,
    [SortCode]        NVARCHAR (10) NULL,
    [AccountNumber]   NVARCHAR (20) NULL,
    [CashCode]        NVARCHAR (50) NULL,
    [AccountClosed]   BIT           CONSTRAINT [DF_Org_tbAccount_AccountClosed] DEFAULT ((0)) NOT NULL,
    [DummyAccount]    BIT           CONSTRAINT [DF_Org_tbAccount_IsDummyAccount] DEFAULT ((0)) NOT NULL,
    [InsertedBy]      NVARCHAR (50) CONSTRAINT [DF_Org_tbAccount_InsertedBy] DEFAULT (suser_sname()) NOT NULL,
    [InsertedOn]      DATETIME      CONSTRAINT [DF_Org_tbAccount_InsertedOn] DEFAULT (getdate()) NOT NULL,
    [UpdatedBy]       NVARCHAR (50) CONSTRAINT [DF_Org_tbAccount_UpdatedBy] DEFAULT (suser_sname()) NOT NULL,
    [UpdatedOn]       DATETIME      CONSTRAINT [DF_Org_tbAccount_UpdatedOn] DEFAULT (getdate()) NOT NULL,
    [RowVer]          ROWVERSION    NOT NULL,
    CONSTRAINT [PK_Org_tbAccount] PRIMARY KEY CLUSTERED ([CashAccountCode] ASC) WITH (FILLFACTOR = 90),
    CONSTRAINT [FK_Org_tbAccount_Cash_tbCode] FOREIGN KEY ([CashCode]) REFERENCES [Cash].[tbCode] ([CashCode]),
    CONSTRAINT [FK_Org_tbAccount_Org_tb] FOREIGN KEY ([AccountCode]) REFERENCES [Org].[tbOrg] ([AccountCode]) ON UPDATE CASCADE
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_Org_tbAccount]
    ON [Org].[tbAccount]([AccountCode] ASC, [CashAccountCode] ASC) WITH (FILLFACTOR = 90);


GO
CREATE   TRIGGER Org.Org_tbAccount_TriggerUpdate 
   ON  Org.tbAccount
   AFTER UPDATE, INSERT
AS 
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY
	DECLARE @Msg NVARCHAR(MAX);

		IF EXISTS (SELECT * FROM inserted i WHERE App.fnParsePrimaryKey(CashAccountCode) = 0)
			BEGIN		
			SELECT @Msg = Message FROM App.tbText WHERE TextId = 2004;
			RAISERROR (@Msg, 10, 1)
			ROLLBACK
			END
		ELSE IF EXISTS (SELECT * FROM inserted i JOIN Cash.tbCode c ON i.CashCode = c.CashCode WHERE DummyAccount <> 0)
			BEGIN
			SELECT @Msg = Message FROM App.tbText WHERE TextId = 3015;
			RAISERROR (@Msg, 10, 1)
			ROLLBACK
			END
		ELSE
			BEGIN	
			UPDATE Org.tbAccount
			SET UpdatedBy = SUSER_SNAME(), UpdatedOn = CURRENT_TIMESTAMP
			FROM Org.tbAccount INNER JOIN inserted AS i ON tbAccount.CashAccountCode = i.CashAccountCode;
			END
	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
END
