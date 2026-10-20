CREATE TABLE [App].[tbDocOpenMode] (
    [OpenMode]            SMALLINT      CONSTRAINT [DF_App_tbDocOpenMode_OpenMode] DEFAULT ((0)) NOT NULL,
    [OpenModeDescription] NVARCHAR (20) NULL,
    CONSTRAINT [PK_App_tbDocOpenMode] PRIMARY KEY CLUSTERED ([OpenMode] ASC) WITH (FILLFACTOR = 90)
);
