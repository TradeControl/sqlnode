CREATE TABLE [Usr].[tbTheme] (
    [ThemeCode] NVARCHAR (25)  NOT NULL,
    [ThemeName] NVARCHAR (50)  NOT NULL,
    [CssFile]   NVARCHAR (100) NOT NULL,
    [IsEnabled] BIT            CONSTRAINT [DF_Usr_tbTheme_IsEnabled] DEFAULT ((1)) NOT NULL,
    CONSTRAINT [PK_Usr_tbTheme] PRIMARY KEY CLUSTERED ([ThemeCode] ASC)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_Usr_tbTheme_ThemeName]
    ON [Usr].[tbTheme]([ThemeName] ASC);

