CREATE TABLE App.tbTemplate
(
	TemplateName nvarchar(100) NOT NULL,
	StoredProcedure nvarchar(100) NOT NULL,
	CONSTRAINT [PK_App_tbTemplateName] PRIMARY KEY CLUSTERED (TemplateName)
)