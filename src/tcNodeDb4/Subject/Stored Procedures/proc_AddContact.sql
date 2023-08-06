
CREATE   PROCEDURE Subject.proc_AddContact 
	(
	@AccountCode nvarchar(10),
	@ContactName nvarchar(100)	 
	)
  AS
   	SET NOCOUNT, XACT_ABORT ON;

	BEGIN TRY
	
		INSERT INTO Subject.tbContact
								(AccountCode, ContactName, PhoneNumber, EmailAddress)
		SELECT     AccountCode, @ContactName AS ContactName, PhoneNumber, EmailAddress
		FROM         Subject.tbSubject
		WHERE AccountCode = @AccountCode
	
  	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
