CREATE   PROCEDURE Usr.proc_AddUser
(
	@UserName NVARCHAR(25), 
	@FullName NVARCHAR(100),
	@HomeAddress NVARCHAR(MAX),
	@EmailAddress NVARCHAR(255),
	@MobileNumber NVARCHAR(50),
	@CalendarCode NVARCHAR(10),
	@IsAdministrator BIT = 0
)
AS

	DECLARE @SQL NVARCHAR(MAX);
	DECLARE @ObjectName NVARCHAR(100);

	SET @SQL = CONCAT('CREATE USER [', @UserName, '] FOR LOGIN [', @UserName, '] WITH DEFAULT_SCHEMA=[dbo];');
	EXECUTE sys.sp_executesql @stmt = @SQL;

	SET @SQL = CONCAT('ALTER ROLE [db_datareader] ADD MEMBER [', @UserName, '];');
	EXECUTE sys.sp_executesql @stmt = @SQL;
	SET @SQL = CONCAT('ALTER ROLE [db_datawriter] ADD MEMBER [', @UserName, '];');
	EXECUTE sys.sp_executesql @stmt = @SQL;

	--Register with client
	DECLARE @UserId NVARCHAR(10) = CONCAT(LEFT(@FullName, 1), SUBSTRING(@FullName, CHARINDEX(' ', @FullName) + 1, 1)); 

	INSERT INTO Usr.tbUser (UserId, UserName, LogonName, IsAdministrator, IsEnabled, CalendarCode, EmailAddress, MobileNumber, [Address])
	VALUES (@UserId, @FullName, @UserName, @IsAdministrator, 1, @CalendarCode, @EmailAddress, @MobileNumber, @HomeAddress)

	INSERT INTO Usr.tbMenuUser (UserId, MenuId)
	SELECT @UserId AS UserId, (SELECT MenuId FROM Usr.tbMenu) AS MenuId;

	--protect system tables
	DECLARE tbs CURSOR FOR
		WITH tbnames AS
		(
			SELECT SCHEMA_NAME(schema_id) AS SchemaName, CONCAT(SCHEMA_NAME(schema_id), '.', [name]) AS TableName
			FROM sys.tables
			WHERE type = 'U' AND SCHEMA_NAME(schema_id) <> 'dbo' 
		)
		SELECT TableName
		FROM tbnames
		WHERE (TableName like '%Status%' or TableName like '%Type%')
			OR (TableName = 'App.tbDocClass')
			OR (TableName = 'App.tbEventLog')
			OR (TableName = 'App.tbInstall')
			OR (TableName = 'App.tbRecurrence')
			OR (TableName = 'App.tbRounding')
			OR (TableName = 'App.tbText')
			OR (TableName = 'Cash.tbMode')
			OR (TableName = 'App.tbEth');

		OPEN tbs
		FETCH NEXT FROM tbs INTO @ObjectName
		WHILE @@FETCH_STATUS = 0
		BEGIN
			SET @SQL = CONCAT('DENY DELETE ON ', DB_NAME(), '.', @ObjectName, ' TO [', @UserName, ']')
			EXECUTE sys.sp_executesql @stmt = @SQL
			SET @SQL = CONCAT('DENY INSERT ON ', DB_NAME(), '.', @ObjectName, ' TO [', @UserName, ']')
			EXECUTE sys.sp_executesql @stmt = @SQL
			SET @SQL = CONCAT('DENY UPDATE ON ', DB_NAME(), '.', @ObjectName, ' TO [', @UserName, ']')
			EXECUTE sys.sp_executesql @stmt = @SQL
			SET @SQL = CONCAT('GRANT SELECT ON ', DB_NAME(), '.', @ObjectName, ' TO [', @UserName, ']')
			EXECUTE sys.sp_executesql @stmt = @SQL
			 
			FETCH NEXT FROM tbs INTO @ObjectName
		END
		CLOSE tbs
		DEALLOCATE tbs

	--Deny non-administrators insert, delete and update permission on Usr schema tables
	IF @IsAdministrator = 0
	BEGIN
		DECLARE tbs CURSOR FOR
			WITH tbnames AS
			(
				SELECT SCHEMA_NAME(schema_id) AS SchemaName, CONCAT(SCHEMA_NAME(schema_id), '.', [name]) AS TableName
				FROM sys.tables
				WHERE type = 'U' AND SCHEMA_NAME(schema_id) <> 'dbo' 
			)
			SELECT TableName
			FROM tbnames
			WHERE (SchemaName = 'Usr');

			OPEN tbs
			FETCH NEXT FROM tbs INTO @ObjectName
			WHILE @@FETCH_STATUS = 0
			BEGIN
				SET @SQL = CONCAT('DENY DELETE ON ', DB_NAME(), '.', @ObjectName, ' TO [', @UserName, ']')
				EXECUTE sys.sp_executesql @stmt = @SQL
				SET @SQL = CONCAT('DENY INSERT ON ', DB_NAME(), '.', @ObjectName, ' TO [', @UserName, ']')
				EXECUTE sys.sp_executesql @stmt = @SQL
				SET @SQL = CONCAT('DENY UPDATE ON ', DB_NAME(), '.', @ObjectName, ' TO [', @UserName, ']')
				EXECUTE sys.sp_executesql @stmt = @SQL
				SET @SQL = CONCAT('GRANT SELECT ON ', DB_NAME(), '.', @ObjectName, ' TO [', @UserName, ']')
				EXECUTE sys.sp_executesql @stmt = @SQL
			 
				FETCH NEXT FROM tbs INTO @ObjectName
			END
			CLOSE tbs
			DEALLOCATE tbs
	END

	--Assign full read/write/execute permissions
	DECLARE procs CURSOR FOR
		SELECT CONCAT(SCHEMA_NAME([schema_id]), '.', name) AS proc_name
		FROM sys.procedures;
	
		OPEN procs
		FETCH NEXT FROM procs INTO @ObjectName
		WHILE @@FETCH_STATUS = 0
		BEGIN
			SET @SQL = CONCAT('GRANT EXECUTE ON ', DB_NAME(), '.', @ObjectName, ' TO [', @UserName, '];');
			EXECUTE sys.sp_executesql @stmt = @SQL 
			FETCH NEXT FROM procs INTO @ObjectName
		END
		CLOSE procs
		DEALLOCATE procs

	DECLARE funcs CURSOR FOR
		SELECT CONCAT(SCHEMA_NAME([schema_id]), '.', name), type 
		FROM sys.objects where type IN ('TF', 'IF', 'FN');

	DECLARE @Type CHAR(2);

		OPEN funcs
		FETCH NEXT FROM funcs INTO @ObjectName, @Type
		WHILE @@FETCH_STATUS = 0
		BEGIN
			IF @Type = 'FN'
				SET @SQL = CONCAT('GRANT EXECUTE ON ', DB_NAME(), '.', @ObjectName, ' TO [', @UserName, '];');
			ELSE
				SET @SQL = CONCAT('GRANT SELECT ON ', DB_NAME(), '.', @ObjectName, ' TO [', @UserName, '];');

			EXECUTE sys.sp_executesql @stmt = @SQL 

			FETCH NEXT FROM funcs INTO @ObjectName, @Type
		END
		CLOSE funcs
		DEALLOCATE funcs
