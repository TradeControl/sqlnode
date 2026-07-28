CREATE TABLE [Subject].[tbExportType] (
    [ExportTypeCode] TINYINT NOT NULL,
    [ExportType] NVARCHAR(50) NOT NULL,
    CONSTRAINT [PK_Subject_tbExportType] PRIMARY KEY CLUSTERED ([ExportTypeCode] ASC)
);
GO
