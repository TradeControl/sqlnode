
CREATE   PROCEDURE Org.proc_DefaultTaxCode 
	(
	@AccountCode nvarchar(10),
	@TaxCode nvarchar(10) OUTPUT
	)
  AS
   	SET NOCOUNT, XACT_ABORT ON;

	BEGIN TRY
		IF EXISTS(SELECT     Org.tbOrg.AccountCode
				  FROM         Org.tbOrg INNER JOIN
										App.tbOptions ON Org.tbOrg.AccountCode = App.tbOptions.AccountCode)
			BEGIN
			SELECT @TaxCode = Org.tbOrg.TaxCode
				  FROM         Org.tbOrg INNER JOIN
										App.tbOptions ON Org.tbOrg.AccountCode = App.tbOptions.AccountCode
		
			END	                              

  	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
