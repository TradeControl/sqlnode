CREATE TABLE [Invoice].[tbItem] (
    [InvoiceNumber] NVARCHAR (20) NOT NULL,
    [CashCode]      NVARCHAR (50) NOT NULL,
    [TaxCode]       NVARCHAR (10) NULL,
    [TotalValue]    MONEY         CONSTRAINT [DF_Invoice_tbItem_TotalValue] DEFAULT ((0)) NOT NULL,
    [InvoiceValue]  MONEY         CONSTRAINT [DF_Invoice_tbItem_InvoiceValue] DEFAULT ((0)) NOT NULL,
    [TaxValue]      MONEY         CONSTRAINT [DF_Invoice_tbItem_TaxValue] DEFAULT ((0)) NOT NULL,
    [PaidValue]     MONEY         CONSTRAINT [DF_Invoice_tbItem_PaidValue] DEFAULT ((0)) NOT NULL,
    [PaidTaxValue]  MONEY         CONSTRAINT [DF_Invoice_tbItem_PaidTaxValue] DEFAULT ((0)) NOT NULL,
    [ItemReference] NTEXT         NULL,
    [RowVer]        ROWVERSION    NOT NULL,
    CONSTRAINT [PK_Invoice_tbItem] PRIMARY KEY CLUSTERED ([InvoiceNumber] ASC, [CashCode] ASC) WITH (FILLFACTOR = 90),
    CONSTRAINT [FK_Invoice_tbItem_App_tbTaxCode] FOREIGN KEY ([TaxCode]) REFERENCES [App].[tbTaxCode] ([TaxCode]),
    CONSTRAINT [FK_Invoice_tbItem_Cash_tbCode] FOREIGN KEY ([CashCode]) REFERENCES [Cash].[tbCode] ([CashCode]) ON UPDATE CASCADE,
    CONSTRAINT [FK_Invoice_tbItem_Invoice_tb] FOREIGN KEY ([InvoiceNumber]) REFERENCES [Invoice].[tbInvoice] ([InvoiceNumber]) ON DELETE CASCADE ON UPDATE CASCADE
);


GO
CREATE NONCLUSTERED INDEX [IX_Invoice_tbItem_CashCode]
    ON [Invoice].[tbItem]([CashCode] ASC, [InvoiceNumber] ASC) WITH (FILLFACTOR = 90);


GO
CREATE NONCLUSTERED INDEX [IX_Invoice_tbItem_Full]
    ON [Invoice].[tbItem]([InvoiceNumber] ASC, [CashCode] ASC, [InvoiceValue] ASC, [TaxValue] ASC, [TaxCode] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_Invoice_tbItem_InvoiceNumber_TaxCode]
    ON [Invoice].[tbItem]([InvoiceNumber] ASC, [TaxCode] ASC)
    INCLUDE([CashCode], [InvoiceValue], [TaxValue]);


GO
CREATE NONCLUSTERED INDEX [IX_Invoice_tbItem_TaxCode]
    ON [Invoice].[tbItem]([TaxCode] ASC)
    INCLUDE([InvoiceValue], [TaxValue]);


GO
CREATE   TRIGGER Invoice.Invoice_tbItem_TriggerInsert
ON Invoice.tbItem
FOR INSERT, UPDATE
AS
	SET NOCOUNT ON;

	BEGIN TRY

		UPDATE item
		SET InvoiceValue = ROUND(inserted.TotalValue / (1 + TaxRate), 2),
			TaxValue = inserted.TotalValue - ROUND(inserted.TotalValue / (1 + TaxRate), 2)				
		FROM inserted 
			INNER JOIN Invoice.tbItem item ON inserted.InvoiceNumber = item.InvoiceNumber 
					AND inserted.CashCode = item.CashCode
				INNER JOIN App.tbTaxCode ON inserted.TaxCode = App.tbTaxCode.TaxCode 
		WHERE inserted.TotalValue <> 0;

		UPDATE item
		SET TaxValue = CASE App.tbTaxCode.RoundingCode 
				WHEN 0 THEN ROUND(item.InvoiceValue * App.tbTaxCode.TaxRate, 2)
				WHEN 1 THEN ROUND( item.InvoiceValue * App.tbTaxCode.TaxRate, 2, 1) END
		FROM Invoice.tbItem item 
			INNER JOIN inserted ON inserted.InvoiceNumber = item.InvoiceNumber
					 AND inserted.CashCode = item.CashCode
				INNER JOIN App.tbTaxCode ON item.TaxCode = App.tbTaxCode.TaxCode
		WHERE inserted.TotalValue = 0; 

	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
