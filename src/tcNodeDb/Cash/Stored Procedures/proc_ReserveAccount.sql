
CREATE   PROCEDURE Cash.proc_ReserveAccount(@CashAccountCode NVARCHAR(10) OUTPUT)
AS
	SET NOCOUNT, XACT_ABORT ON;
	BEGIN TRY
		SELECT  @CashAccountCode = Org.tbAccount.CashAccountCode
		FROM            Org.tbAccount LEFT OUTER JOIN
								 Cash.tbCode ON Org.tbAccount.CashCode = Cash.tbCode.CashCode 
		WHERE (Cash.tbCode.CashCode IS NULL) AND (Org.tbAccount.DummyAccount = 0);
	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
