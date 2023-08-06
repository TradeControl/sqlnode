
CREATE   PROCEDURE Cash.proc_AccountRebuild
	(
	@CashAccountCode nvarchar(10)
	)
  AS
	SET NOCOUNT, XACT_ABORT ON;

	BEGIN TRY
		
		UPDATE Subject.tbAccount
		SET CurrentBalance = Cash.vwAccountRebuild.CurrentBalance
		FROM         Cash.vwAccountRebuild INNER JOIN
							Subject.tbAccount ON Cash.vwAccountRebuild.CashAccountCode = Subject.tbAccount.CashAccountCode
		WHERE Cash.vwAccountRebuild.CashAccountCode = @CashAccountCode 

		UPDATE Subject.tbAccount
		SET CurrentBalance = 0
		FROM         Cash.vwAccountRebuild RIGHT OUTER JOIN
							  Subject.tbAccount ON Cash.vwAccountRebuild.CashAccountCode = Subject.tbAccount.CashAccountCode
		WHERE     (Cash.vwAccountRebuild.CashAccountCode IS NULL) AND Subject.tbAccount.CashAccountCode = @CashAccountCode
    END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH 
