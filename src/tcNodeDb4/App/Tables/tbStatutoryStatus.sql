CREATE TABLE [App].[tbStatutoryStatus]
(
    [StatusCode] SMALLINT NOT NULL,
    [StatusName] NVARCHAR(50) NOT NULL,
    [IsActive] BIT NOT NULL CONSTRAINT [DF_App_tbStatutoryStatus_IsActive] DEFAULT (0),
    CONSTRAINT [PK_App_tbStatutoryStatus] PRIMARY KEY CLUSTERED ([StatusCode]),
    CONSTRAINT [AK_App_tbStatutoryStatus_StatusName] UNIQUE ([StatusName])
);
