﻿CREATE TABLE [App].[tbTemplate] (
    [TemplateName]    NVARCHAR (100) NOT NULL,
    [StoredProcedure] NVARCHAR (100) NOT NULL,
    CONSTRAINT [PK_App_tbTemplateName] PRIMARY KEY CLUSTERED ([TemplateName] ASC)
);

