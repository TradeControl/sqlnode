CREATE TABLE [Invoice].[tbMirrorItem] (
    [ContractAddress]   NVARCHAR (42)  NOT NULL,
    [ChargeCode]        NVARCHAR (50)  NOT NULL,
    [ChargeDescription] NVARCHAR (100) NULL,
    [InvoiceValue]      MONEY          NOT NULL,
    [TaxValue]          MONEY          NOT NULL,
    [TaxCode]           NVARCHAR (10)  NULL,
    [RowVer]            ROWVERSION     NOT NULL,
    CONSTRAINT [PK_Invoice_tbMirrorItem] PRIMARY KEY CLUSTERED ([ContractAddress] ASC, [ChargeCode] ASC),
    CONSTRAINT [FK_Invoice_tbMirrorItem_ContractAddress] FOREIGN KEY ([ContractAddress]) REFERENCES [Invoice].[tbMirror] ([ContractAddress]) ON DELETE CASCADE
);


GO
CREATE NONCLUSTERED INDEX [IX_Invoice_tbMirrorItem_InvoiceNumber]
    ON [Invoice].[tbMirrorItem]([ChargeCode] ASC, [ContractAddress] ASC);

