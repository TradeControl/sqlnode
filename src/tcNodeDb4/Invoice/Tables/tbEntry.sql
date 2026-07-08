CREATE TABLE [Invoice].[tbEntry] (
    [EntryId]           NVARCHAR (20)   NOT NULL,
    [UserId]            NVARCHAR (10)   NOT NULL,
    [SubjectCode]       NVARCHAR (50)   NOT NULL,
    [ParentSubjectCode] NVARCHAR (50)   NULL,
    [CashCode]          NVARCHAR (50)   NOT NULL,
    [InvoiceTypeCode]   SMALLINT        NOT NULL,
    [InvoicedOn]        DATETIME        CONSTRAINT [DF_Invoice_tbEntry_InvoicedOn] DEFAULT (CONVERT([date],getdate())) NOT NULL,
    [TaxCode]           NVARCHAR (10)   NULL,
    [ItemReference]     NVARCHAR (MAX)  NULL,
    [TotalValue]        DECIMAL (18, 5) CONSTRAINT [DF_Invoice_tbEntry_TotalValue] DEFAULT ((0)) NOT NULL,
    [InvoiceValue]      DECIMAL (18, 5) CONSTRAINT [DF_Invoice_tbEntry_InvoiceValue] DEFAULT ((0)) NOT NULL,
    [RowVer]            ROWVERSION      NOT NULL,
    CONSTRAINT [PK_tbEntry_1] PRIMARY KEY CLUSTERED ([EntryId] ASC),
    CONSTRAINT [FK_Invoice_tbEntry_App_tbTaxCode] FOREIGN KEY ([TaxCode]) REFERENCES [App].[tbTaxCode] ([TaxCode]),
    CONSTRAINT [FK_Invoice_tbEntry_Cash_tbCode] FOREIGN KEY ([CashCode]) REFERENCES [Cash].[tbCode] ([CashCode]) ON UPDATE CASCADE,
    CONSTRAINT [FK_Invoice_tbEntry_Invoice_tbType] FOREIGN KEY ([InvoiceTypeCode]) REFERENCES [Invoice].[tbType] ([InvoiceTypeCode]),
    CONSTRAINT [FK_Invoice_tbEntry_Subject_tb] FOREIGN KEY ([SubjectCode]) REFERENCES [Subject].[tbSubject] ([SubjectCode]),
    CONSTRAINT [FK_Invoice_tbEntry_Subject_tbNamespace] FOREIGN KEY ([ParentSubjectCode], [SubjectCode]) REFERENCES [Subject].[tbNamespace] ([ParentSubjectCode], [ChildSubjectCode]),
    CONSTRAINT [FK_Invoice_tbEntry_Usr_tb] FOREIGN KEY ([UserId]) REFERENCES [Usr].[tbUser] ([UserId]) ON UPDATE CASCADE
);




GO


GO
CREATE NONCLUSTERED INDEX [IX_Invoice_tbEntry_UserId]
    ON [Invoice].[tbEntry]([UserId] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_Invoice_tbEntry_SubjectCode_CashCode]
    ON [Invoice].[tbEntry]([SubjectCode] ASC, [CashCode] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_Invoice_tbEntry_SubjectCode_InvoiceTypeCode]
    ON [Invoice].[tbEntry]([SubjectCode] ASC, [InvoiceTypeCode] ASC);
GO
