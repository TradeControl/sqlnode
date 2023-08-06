CREATE   PROCEDURE Subject.proc_DefaultEmailAddress 
	(
	@AccountCode nvarchar(10),
	@EmailAddress nvarchar(255) OUTPUT
	)
  AS
   	SET NOCOUNT, XACT_ABORT ON;

	BEGIN TRY

	SELECT @EmailAddress = COALESCE(EmailAddress, '') FROM Subject.tbSubject WHERE AccountCode = @AccountCode;

	IF (LEN(@EmailAddress) = 0)
		SELECT @EmailAddress = EmailAddress
		FROM Subject.tbContact
		WHERE AccountCode = @AccountCode AND NOT (EmailAddress IS NULL);

	SET @EmailAddress = COALESCE(@EmailAddress, '');

  	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
