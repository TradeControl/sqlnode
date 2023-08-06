CREATE TABLE [Subject].[tbAccount] (
    [CashAccountCode] NVARCHAR (10)   NOT NULL,
    [AccountCode]     NVARCHAR (10)   NOT NULL,
    [CashAccountName] NVARCHAR (50)   NOT NULL,
    [SortCode]        NVARCHAR (10)   NULL,
    [AccountNumber]   NVARCHAR (20)   NULL,
    [CashCode]        NVARCHAR (50)   NULL,
    [AccountClosed]   BIT             CONSTRAINT [DF_Subject_tbAccount_AccountClosed] DEFAULT ((0)) NOT NULL,
    [InsertedBy]      NVARCHAR (50)   CONSTRAINT [DF_Subject_tbAccount_InsertedBy] DEFAULT (suser_sname()) NOT NULL,
    [InsertedOn]      DATETIME        CONSTRAINT [DF_Subject_tbAccount_InsertedOn] DEFAULT (getdate()) NOT NULL,
    [UpdatedBy]       NVARCHAR (50)   CONSTRAINT [DF_Subject_tbAccount_UpdatedBy] DEFAULT (suser_sname()) NOT NULL,
    [UpdatedOn]       DATETIME        CONSTRAINT [DF_Subject_tbAccount_UpdatedOn] DEFAULT (getdate()) NOT NULL,
    [RowVer]          ROWVERSION      NOT NULL,
    [OpeningBalance]  DECIMAL (18, 5) CONSTRAINT [DF_Subject_tbAccount_OpeningBalance] DEFAULT ((0)) NOT NULL,
    [CurrentBalance]  DECIMAL (18, 5) CONSTRAINT [DF_Subject_tbAccount_CurrentBalance] DEFAULT ((0)) NOT NULL,
    [CoinTypeCode]    SMALLINT        CONSTRAINT [DF_Subject_tbAccount_CoinTypeCode] DEFAULT ((2)) NOT NULL,
    [AccountTypeCode] SMALLINT        CONSTRAINT [DF_Subject_tbAccount_AccountTypeCode] DEFAULT ((0)) NOT NULL,
    [LiquidityLevel]  SMALLINT        CONSTRAINT [DF_Subject_tbAccount_LiquidityLevel] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_Subject_tbAccount] PRIMARY KEY CLUSTERED ([CashAccountCode] ASC) WITH (FILLFACTOR = 90),
    CONSTRAINT [FK_Subject_tbAccount_Cash_tbCode] FOREIGN KEY ([CashCode]) REFERENCES [Cash].[tbCode] ([CashCode]),
    CONSTRAINT [FK_Subject_tbAccount_Cash_tbCoinType] FOREIGN KEY ([CoinTypeCode]) REFERENCES [Cash].[tbCoinType] ([CoinTypeCode]),
    CONSTRAINT [FK_Subject_tbAccount_Subject_tb] FOREIGN KEY ([AccountCode]) REFERENCES [Subject].[tbSubject] ([AccountCode]) ON UPDATE CASCADE,
    CONSTRAINT [FK_Subject_tbAccount_Subject_tbAccountType] FOREIGN KEY ([AccountTypeCode]) REFERENCES [Subject].[tbAccountType] ([AccountTypeCode])
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_Subject_tbAccount]
    ON [Subject].[tbAccount]([AccountCode] ASC, [CashAccountCode] ASC) WITH (FILLFACTOR = 90);


GO
CREATE NONCLUSTERED INDEX [IX_tbAccount_AccountTypeCode]
    ON [Subject].[tbAccount]([AccountTypeCode] ASC, [LiquidityLevel] DESC, [CashAccountCode] ASC);


GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_Subject_tbAccount_CashAccountName]
    ON [Subject].[tbAccount]([CashAccountName] ASC);


GO
CREATE TRIGGER Subject.Subject_tbAccount_TriggerUpdate 
   ON  Subject.tbAccount
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
		ELSE IF EXISTS (SELECT * FROM inserted i JOIN Cash.tbCode c ON i.CashCode = c.CashCode WHERE AccountTypeCode = 1)
			BEGIN
			SELECT @Msg = Message FROM App.tbText WHERE TextId = 3015;
			RAISERROR (@Msg, 10, 1)
			ROLLBACK
			END
		ELSE
			BEGIN
			IF UPDATE(OpeningBalance)
			BEGIN
			
				WITH i AS
				(
					SELECT * FROM inserted WHERE AccountTypeCode = 0
				)
				UPDATE Subject.tbAccount
				SET CurrentBalance = balance.CurrentBalance
				FROM Subject.tbAccount 
					INNER JOIN i ON tbAccount.CashAccountCode = i.CashAccountCode
					INNER JOIN Cash.vwAccountRebuild balance ON balance.CashAccountCode = i.CashAccountCode;

				WITH i AS
				(
					SELECT * FROM inserted WHERE AccountTypeCode = 0
				)		
				UPDATE Subject.tbAccount
				SET CurrentBalance = Subject.tbAccount.OpeningBalance
				FROM  Cash.vwAccountRebuild 
					RIGHT OUTER JOIN Subject.tbAccount ON Cash.vwAccountRebuild.CashAccountCode = Subject.tbAccount.CashAccountCode
					JOIN i ON i.CashAccountCode = Subject.tbAccount.CashAccountCode
				WHERE   (Cash.vwAccountRebuild.CashAccountCode IS NULL);
			END

			UPDATE Subject.tbAccount
			SET UpdatedBy = SUSER_SNAME(), UpdatedOn = CURRENT_TIMESTAMP
			FROM Subject.tbAccount INNER JOIN inserted AS i ON tbAccount.CashAccountCode = i.CashAccountCode;
			END
	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
END
