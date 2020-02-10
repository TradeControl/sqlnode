CREATE TABLE [Usr].[tbMenu] (
    [MenuId]     SMALLINT      IDENTITY (1, 1) NOT NULL,
    [MenuName]   NVARCHAR (50) NOT NULL,
    [InsertedOn] DATETIME      CONSTRAINT [DF_Usr_tbMenu_InsertedOn] DEFAULT (getdate()) NOT NULL,
    [InsertedBy] NVARCHAR (50) CONSTRAINT [DF_Usr_tbMenu_InsertedBy] DEFAULT (suser_sname()) NOT NULL,
    [RowVer]     ROWVERSION    NOT NULL,
    CONSTRAINT [PK_Usr_tbMenu] PRIMARY KEY CLUSTERED ([MenuId] ASC) WITH (FILLFACTOR = 90),
    CONSTRAINT [IX_Usr_tbMenu] UNIQUE NONCLUSTERED ([MenuName] ASC, [MenuId] ASC) WITH (FILLFACTOR = 90)
);

