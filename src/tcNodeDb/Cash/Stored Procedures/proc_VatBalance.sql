
CREATE   PROCEDURE Cash.proc_VatBalance(@Balance money output)
 AS
  	SET NOCOUNT, XACT_ABORT ON;

	BEGIN TRY
		SELECT TOP (1)  @Balance = Balance FROM Cash.vwTaxVatStatement ORDER BY StartOn DESC, VatDue DESC
  	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
