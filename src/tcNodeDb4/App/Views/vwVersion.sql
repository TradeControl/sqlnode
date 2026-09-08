CREATE VIEW App.vwVersion
AS
	SELECT CONCAT(SQLDataVersion, '.', SQLRelease, '.', SQLBuild) AS VersionString,
		SQLDataVersion,
		SQLRelease,
		SQLBuild
	FROM App.tbInstall
	WHERE InstallId = (SELECT MAX(InstallId) FROM App.tbInstall)
