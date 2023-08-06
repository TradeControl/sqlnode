
CREATE   PROCEDURE Subject.proc_AddAddress 
	(
	@AccountCode nvarchar(10),
	@Address ntext
	)
AS
 	SET NOCOUNT, XACT_ABORT ON;

	BEGIN TRY
		DECLARE @AddressCode nvarchar(15)
	
		EXECUTE Subject.proc_NextAddressCode @AccountCode, @AddressCode OUTPUT
	
		INSERT INTO Subject.tbAddress
							  (AddressCode, AccountCode, Address)
		VALUES     (@AddressCode, @AccountCode, @Address)
	
		IF NOT EXISTS (SELECT * FROM Subject.tbSubject Subject JOIN Subject.tbAddress Subject_addr ON Subject.AddressCode = Subject_addr.AddressCode WHERE Subject.AccountCode = @AccountCode)
		BEGIN
			UPDATE Subject.tbSubject
			SET AddressCode = @AddressCode
			WHERE Subject.tbSubject.AccountCode = @AccountCode
		END

  	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
