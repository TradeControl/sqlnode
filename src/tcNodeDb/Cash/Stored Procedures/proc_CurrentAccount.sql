CREATE PROCEDURE Cash.proc_CurrentAccount(@CashAccountCode NVARCHAR(10) OUTPUT)
AS
	SET NOCOUNT, XACT_ABORT ON;
	BEGIN TRY
		SELECT  @CashAccountCode = Org.tbAccount.CashAccountCode
		FROM Org.tbAccount 
			JOIN Cash.tbCode ON Org.tbAccount.CashCode = Cash.tbCode.CashCode 
			JOIN Cash.tbCategory ON Cash.tbCode.CategoryCode = Cash.tbCategory.CategoryCode
		WHERE (Cash.tbCategory.CashTypeCode = 2);

	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
