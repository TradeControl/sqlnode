CREATE PROCEDURE Subject.proc_AddAddress 
	(
	@SubjectCode nvarchar(50),
	@Address nvarchar(max),
	@AddressTypeCode smallint = 0
	)
AS
	SET NOCOUNT, XACT_ABORT ON;

	BEGIN TRY
		DECLARE @AddressCode nvarchar(15);

		EXEC Subject.proc_NextAddressCode
			@SubjectCode = @SubjectCode,
			@AddressCode = @AddressCode OUTPUT;

		INSERT INTO Subject.tbAddress
		(
			AddressCode,
			SubjectCode,
			AddressTypeCode,
			Address
		)
		VALUES
		(
			@AddressCode,
			@SubjectCode,
			@AddressTypeCode,
			@Address
		);
  	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
GO
