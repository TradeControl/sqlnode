CREATE   PROCEDURE App.proc_EventLogCleardown
	@CutoffOn DATETIME,
	@DeletedCount INT OUTPUT
AS
	SET NOCOUNT, XACT_ABORT ON;

	BEGIN TRY
		DECLARE 
			@EventMessage nvarchar(max)
			, @EventTypeCode smallint = 2
			, @LogCode nvarchar(20)

		BEGIN TRANSACTION;

		DELETE FROM App.tbEventLog
		WHERE LoggedOn <= @CutoffOn;

		SET @DeletedCount = @@ROWCOUNT;
		SET @EventMessage = CONCAT
		(
			N'Event log entries permanently deleted through ',
			CONVERT(nvarchar(33), @CutoffOn, 126),
			N'. Deleted count: ',
			@DeletedCount,
			N'.'
		);
		
		EXECUTE App.proc_EventLog @EventMessage, @EventTypeCode, @LogCode OUTPUT

		COMMIT TRANSACTION;

	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
