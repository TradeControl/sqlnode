﻿CREATE PROCEDURE Cash.proc_CurrentAccount(@AccountCode NVARCHAR(10) OUTPUT)
AS
	SET NOCOUNT, XACT_ABORT ON;
	BEGIN TRY
		SELECT  @AccountCode = AccountCode
		FROM Cash.vwCurrentAccount;
	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
