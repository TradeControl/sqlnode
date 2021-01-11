CREATE PROCEDURE Invoice.proc_PostEntries
AS
   	SET NOCOUNT, XACT_ABORT ON;

	BEGIN TRY
		DECLARE 
			@AccountCode nvarchar(10)
			, @CashCode nvarchar(50)
			, @InvoiceTypeCode smallint
			, @InvoiceNumber nvarchar(20);
			
		DECLARE c1 CURSOR LOCAL FOR
			SELECT AccountCode, CashCode, InvoiceTypeCode
			FROM Invoice.tbEntry
			WHERE UserId = (SELECT UserId FROM Usr.vwCredentials);

		OPEN c1;

		BEGIN TRAN;

		FETCH NEXT FROM c1 INTO @AccountCode, @CashCode, @InvoiceTypeCode;
		
		WHILE (@@FETCH_STATUS = 0)
		BEGIN
			EXEC Invoice.proc_RaiseBlank @AccountCode, @InvoiceTypeCode, @InvoiceNumber output;

			WITH invoice_entry AS
			(
				SELECT @InvoiceNumber InvoiceNumber, InvoicedOn
				FROM Invoice.tbEntry
				WHERE AccountCode = @AccountCode AND CashCode = @CashCode
			)
			UPDATE Invoice.tbInvoice
			SET InvoicedOn = invoice_entry.InvoicedOn
			FROM Invoice.tbInvoice invoice_header 
				JOIN invoice_entry ON invoice_header.InvoiceNumber = invoice_entry.InvoiceNumber;


			INSERT INTO Invoice.tbItem (InvoiceNumber, CashCode, TaxCode, ItemReference, TotalValue, InvoiceValue)
			SELECT @InvoiceNumber InvoiceNumber, CashCode, TaxCode, ItemReference, TotalValue, InvoiceValue
			FROM Invoice.tbEntry
			WHERE AccountCode = @AccountCode AND CashCode = @CashCode

			EXEC Invoice.proc_Accept @InvoiceNumber;

			FETCH NEXT FROM c1 INTO @AccountCode, @CashCode, @InvoiceTypeCode;
		END

		DELETE FROM Invoice.tbEntry
		WHERE UserId = (SELECT UserId FROM Usr.vwCredentials);

		COMMIT TRAN;

		CLOSE c1;
		DEALLOCATE c1;

  	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH