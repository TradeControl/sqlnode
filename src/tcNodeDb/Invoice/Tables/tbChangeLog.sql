CREATE TABLE [Invoice].[tbChangeLog] (
    [LogId]              INT           IDENTITY (1, 1) NOT NULL,
    [InvoiceNumber]      NVARCHAR (20) NOT NULL,
    [ChangedOn]          DATETIME      CONSTRAINT [DF_Invoice_tbChangeLog_ChangedOn] DEFAULT (dateadd(millisecond,datepart(millisecond,getdate())*(-1),getdate())) NOT NULL,
    [TransmitStatusCode] SMALLINT      CONSTRAINT [DF_Invoice_tbChangeLog_TransmissionStatusCode] DEFAULT ((0)) NOT NULL,
    [InvoiceStatusCode]  SMALLINT      NOT NULL,
    [DueOn]              DATETIME      NOT NULL,
    [InvoiceValue]       MONEY         CONSTRAINT [DF_Invoice_tbChangeLog_InvoiceValue] DEFAULT ((0)) NOT NULL,
    [TaxValue]           MONEY         CONSTRAINT [DF_Invoice_tbChangeLogTaxValue] DEFAULT ((0)) NOT NULL,
    [PaidValue]          MONEY         CONSTRAINT [DF_Invoice_tbChangeLog_PaidValue] DEFAULT ((0)) NOT NULL,
    [PaidTaxValue]       MONEY         CONSTRAINT [DF_Invoice_tbChangeLog_PaidTaxValue] DEFAULT ((0)) NOT NULL,
    [UpdatedBy]          NVARCHAR (50) CONSTRAINT [DF_Invoice_tbChangeLog_UpdatedBy] DEFAULT (suser_sname()) NOT NULL,
    [RowVer]             ROWVERSION    NOT NULL,
    CONSTRAINT [PK_Invoice_tbChangeLog] PRIMARY KEY CLUSTERED ([LogId] DESC),
    CONSTRAINT [FK_Invoice_tbChangeLog_TrasmitStatusCode] FOREIGN KEY ([TransmitStatusCode]) REFERENCES [Org].[tbTransmitStatus] ([TransmitStatusCode])
);


GO
CREATE NONCLUSTERED INDEX [IX_Invoice_tbChangeLog_InvoiceCode]
    ON [Invoice].[tbChangeLog]([InvoiceNumber] ASC, [LogId] DESC);


GO
CREATE NONCLUSTERED INDEX [IX_Invoice_tbChangeLog_ChangedOn]
    ON [Invoice].[tbChangeLog]([ChangedOn] DESC);


GO
CREATE NONCLUSTERED INDEX [IX_Invoice_tbChangeLog_TransmitStatus]
    ON [Invoice].[tbChangeLog]([TransmitStatusCode] ASC, [ChangedOn] ASC);

