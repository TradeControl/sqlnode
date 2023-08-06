﻿
CREATE   PROCEDURE Subject.proc_Statement (@AccountCode NVARCHAR(10))
AS
 	SET NOCOUNT, XACT_ABORT ON;

	BEGIN TRY

		SELECT *
		FROM Subject.vwStatement
		WHERE AccountCode = @AccountCode
		ORDER BY RowNumber DESC

	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog
	END CATCH
