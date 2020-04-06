CREATE TABLE [Invoice].[tbTask] (
    [InvoiceNumber] NVARCHAR (20) NOT NULL,
    [TaskCode]      NVARCHAR (20) NOT NULL,
    [Quantity]      DECIMAL    CONSTRAINT [DF_Invoice_tbTask_Quantity] DEFAULT ((0)) NOT NULL,
    [TotalValue]    MONEY         CONSTRAINT [DF_Invoice_tbTask_TotalValue] DEFAULT ((0)) NOT NULL,
    [InvoiceValue]  MONEY         CONSTRAINT [DF_Invoice_tbActivity_InvoiceValue] DEFAULT ((0)) NOT NULL,
    [TaxValue]      MONEY         CONSTRAINT [DF_Invoice_tbActivity_TaxValue] DEFAULT ((0)) NOT NULL,
    [PaidValue]     MONEY         CONSTRAINT [DF_Invoice_tbTask_PaidValue] DEFAULT ((0)) NOT NULL,
    [PaidTaxValue]  MONEY         CONSTRAINT [DF_Invoice_tbTask_PaidTaxValue] DEFAULT ((0)) NOT NULL,
    [CashCode]      NVARCHAR (50) NOT NULL,
    [TaxCode]       NVARCHAR (10) NULL,
    [RowVer]        ROWVERSION    NOT NULL,
    CONSTRAINT [PK_Invoice_tbTask] PRIMARY KEY CLUSTERED ([InvoiceNumber] ASC, [TaskCode] ASC) WITH (FILLFACTOR = 90),
    CONSTRAINT [FK_Invoice_tbTask_App_tbTaxCode] FOREIGN KEY ([TaxCode]) REFERENCES [App].[tbTaxCode] ([TaxCode]),
    CONSTRAINT [FK_Invoice_tbTask_Cash_tbCode] FOREIGN KEY ([CashCode]) REFERENCES [Cash].[tbCode] ([CashCode]),
    CONSTRAINT [FK_Invoice_tbTask_Invoice_tb] FOREIGN KEY ([InvoiceNumber]) REFERENCES [Invoice].[tbInvoice] ([InvoiceNumber]) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT [FK_Invoice_tbTask_Task_tb] FOREIGN KEY ([TaskCode]) REFERENCES [Task].[tbTask] ([TaskCode])
);


GO
CREATE NONCLUSTERED INDEX [IX_Invoice_tbTask_CashCode]
    ON [Invoice].[tbTask]([CashCode] ASC, [InvoiceNumber] ASC) WITH (FILLFACTOR = 90);


GO
CREATE NONCLUSTERED INDEX [IX_Invoice_tbTask_Full]
    ON [Invoice].[tbTask]([InvoiceNumber] ASC, [CashCode] ASC, [InvoiceValue] ASC, [TaxValue] ASC, [TaxCode] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_Invoice_tbTask_InvoiceNumber_TaxCode]
    ON [Invoice].[tbTask]([InvoiceNumber] ASC, [TaxCode] ASC)
    INCLUDE([CashCode], [InvoiceValue], [TaxValue]);


GO
CREATE NONCLUSTERED INDEX [IX_Invoice_tbTask_TaskCode]
    ON [Invoice].[tbTask]([TaskCode] ASC, [InvoiceNumber] ASC)
    INCLUDE([InvoiceValue], [TaxValue]);


GO
CREATE NONCLUSTERED INDEX [IX_Invoice_tbTask_TaxCode]
    ON [Invoice].[tbTask]([TaxCode] ASC)
    INCLUDE([InvoiceValue], [TaxValue]);


GO
CREATE   TRIGGER Invoice.Invoice_tbTask_TriggerDelete
ON Invoice.tbTask
FOR DELETE
AS
	SET NOCOUNT ON;

	BEGIN TRY
		UPDATE Task.tbTask
		SET TaskStatusCode = 2
		FROM deleted JOIN Task.tbTask ON deleted.TaskCode = Task.tbTask.TaskCode
		WHERE TaskStatusCode = 3;		
	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH

GO
CREATE   TRIGGER Invoice.Invoice_tbTask_TriggerInsert
ON Invoice.tbTask
FOR INSERT, UPDATE
AS
	SET NOCOUNT ON;

	BEGIN TRY

		UPDATE task
		SET InvoiceValue = ROUND(inserted.TotalValue / (1 + TaxRate), 2),
			TaxValue = inserted.TotalValue - ROUND(inserted.TotalValue / (1 + TaxRate), 2)	
		FROM inserted 
			INNER JOIN Invoice.tbTask task ON inserted.InvoiceNumber = task.InvoiceNumber 
					AND inserted.TaskCode = task.TaskCode
				INNER JOIN App.tbTaxCode ON inserted.TaxCode = App.tbTaxCode.TaxCode 
		WHERE inserted.TotalValue <> 0;

		UPDATE task
		SET TaxValue = CASE App.tbTaxCode.RoundingCode 
				WHEN 0 THEN ROUND(task.InvoiceValue * App.tbTaxCode.TaxRate, 2)
				WHEN 1 THEN ROUND( task.InvoiceValue * App.tbTaxCode.TaxRate, 2, 1) END
		FROM Invoice.tbTask task 
			INNER JOIN inserted ON inserted.InvoiceNumber = task.InvoiceNumber
					 AND inserted.TaskCode = task.TaskCode
				INNER JOIN App.tbTaxCode ON task.TaxCode = App.tbTaxCode.TaxCode
		WHERE inserted.TotalValue = 0; 

	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
