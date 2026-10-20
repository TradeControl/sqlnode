CREATE   PROCEDURE App.proc_EventLog (@EventMessage NVARCHAR(MAX), @EventTypeCode SMALLINT = 0, @LogCode NVARCHAR(20) = NULL OUTPUT)
AS
	SET XACT_ABORT, NOCOUNT ON;

	BEGIN TRY
		IF NULLIF(LTRIM(RTRIM(@EventMessage)), N'') IS NULL
		BEGIN
			SET @EventTypeCode = 1;
			SET @EventMessage = CONCAT
			(
				N'Event message was not supplied. Application=', APP_NAME(),
				N'; Host=', HOST_NAME(),
				N'; Login=', ORIGINAL_LOGIN(),
				N'; Session=', @@SPID
			);
		END;

		DECLARE 
			@UserId nvarchar(10)
			, @LogNumber INT
			, @RegisterName nvarchar(50) = (SELECT RegisterName FROM App.tbOptions);
	
		SET @UserId = (SELECT TOP 1 Usr.tbUser.UserId FROM Usr.vwCredentials c INNER JOIN
								Usr.tbUser ON c.UserId = Usr.tbUser.UserId);

		IF @RegisterName IS NULL OR @UserId IS NULL
		BEGIN
			SET @LogCode = LEFT(REPLACE(CONVERT(nvarchar(36), NEWID()), '-', ''), 20);

			INSERT INTO App.tbEventLog (LogCode, EventTypeCode, EventMessage, InsertedBy)
			VALUES (@LogCode, @EventTypeCode, @EventMessage, Usr.fnUserName());

			RETURN;
		END;

		BEGIN TRANSACTION;
		
		WHILE (1 = 1)
			BEGIN
			SET @LogNumber = FORMAT((SELECT TOP 1 r.NextNumber
						FROM App.tbRegister r
						WHERE r.RegisterName = @RegisterName), '00000');
				
			UPDATE App.tbRegister
			SET NextNumber += 1
			WHERE RegisterName = @RegisterName;

			SET @LogCode = CONCAT(@UserId, @LogNumber);

			IF NOT EXISTS (SELECT * FROM App.tbEventLog WHERE LogCode = @LogCode)
				BREAK;
			END

		INSERT INTO App.tbEventLog (LogCode, EventTypeCode, EventMessage, InsertedBy)
		VALUES (@LogCode, @EventTypeCode, @EventMessage, LEFT(COALESCE(@UserId, Usr.fnUserName()), 50));

		COMMIT TRANSACTION;

		RETURN;
					
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0 
			ROLLBACK TRANSACTION;
		THROW;
	END CATCH

