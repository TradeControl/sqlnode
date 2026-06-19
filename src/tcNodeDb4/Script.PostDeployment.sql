/*
Post-Deployment Script Template							
--------------------------------------------------------------------------------------
 This file contains SQL statements that will be appended to the build script.		
 Use SQLCMD syntax to include a file in the post-deployment script.			
 Example:      :r .\myfile.sql								
 Use SQLCMD syntax to reference a variable in the post-deployment script.		
 Example:      :setvar TableName MyTable							
               SELECT * FROM [$(TableName)]					
--------------------------------------------------------------------------------------
*/

ALTER DATABASE [$(DatabaseName)] SET RECURSIVE_TRIGGERS OFF;

DECLARE
    @SQLDataVersion real = 4
    , @SqlRelease int = 1;

IF NOT EXISTS (SELECT 1 FROM App.tbInstall WHERE SQLDataVersion = @SQLDataVersion AND SQLRelease = @SqlRelease)
	INSERT INTO App.tbInstall
	(
		SQLDataVersion,
		SQLRelease
	)
	VALUES
	(
		@SQLDataVersion,
		@SqlRelease
	);
