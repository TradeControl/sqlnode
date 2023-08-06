CREATE   PROCEDURE Object.proc_Mirror(@ObjectCode nvarchar(50), @AccountCode nvarchar(10), @AllocationCode nvarchar(50))
AS
	SET NOCOUNT, XACT_ABORT ON;

	BEGIN TRY
		IF NOT EXISTS (SELECT * FROM Object.tbMirror WHERE ObjectCode = @ObjectCode AND AccountCode = @AccountCode AND AllocationCode = @AllocationCode)
		BEGIN
			INSERT INTO Object.tbMirror (ObjectCode, AccountCode, AllocationCode)
			VALUES (@ObjectCode, @AccountCode, @AllocationCode);
		END
	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
