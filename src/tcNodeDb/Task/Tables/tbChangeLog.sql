CREATE TABLE [Task].[tbChangeLog] (
    [LogId]              INT           IDENTITY (1, 1) NOT NULL,
    [TaskCode]           NVARCHAR (20) NOT NULL,
    [ChangedOn]          DATETIME      CONSTRAINT [DF_Task_tbChangeLog_ChangedOn] DEFAULT (dateadd(millisecond,datepart(millisecond,getdate())*(-1),getdate())) NOT NULL,
    [TransmitStatusCode] SMALLINT      CONSTRAINT [DF_Task_tbChangeLog_TransmissionStatusCode] DEFAULT ((0)) NOT NULL,
    [AccountCode]        NVARCHAR (10) NOT NULL,
    [ActivityCode]       NVARCHAR (50) NOT NULL,
    [TaskStatusCode]     SMALLINT      NOT NULL,
    [ActionOn]           DATETIME      NOT NULL,
    [Quantity]           FLOAT (53)    NOT NULL,
    [CashCode]           NVARCHAR (50) NULL,
    [TaxCode]            NVARCHAR (10) NULL,
    [UnitCharge]         FLOAT (53)    NOT NULL,
    [UpdatedBy]          NVARCHAR (50) CONSTRAINT [DF_Task_tbChangeLog_UpdatedBy] DEFAULT (suser_sname()) NOT NULL,
    [RowVer]             ROWVERSION    NOT NULL,
    CONSTRAINT [PK_Task_tbChangeLog] PRIMARY KEY CLUSTERED ([LogId] DESC),
    CONSTRAINT [FK_Task_tbChangeLog_TrasmitStatusCode] FOREIGN KEY ([TransmitStatusCode]) REFERENCES [Org].[tbTransmitStatus] ([TransmitStatusCode])
);


GO
CREATE NONCLUSTERED INDEX [IX_Task_tbChangeLog_TaskCode]
    ON [Task].[tbChangeLog]([TaskCode] ASC, [LogId] DESC);


GO
CREATE NONCLUSTERED INDEX [IX_Task_tbChangeLog_ChangedOn]
    ON [Task].[tbChangeLog]([ChangedOn] DESC);


GO
CREATE NONCLUSTERED INDEX [IX_Task_tbChangeLog_TransmitStatus]
    ON [Task].[tbChangeLog]([TransmitStatusCode] ASC, [ChangedOn] ASC);

