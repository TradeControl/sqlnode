CREATE   PROCEDURE Cash.proc_PaymentPostMisc
	(
	@PaymentCode nvarchar(20) 
	)
 AS
 	SET NOCOUNT, XACT_ABORT ON;

	BEGIN TRY
		DECLARE 
			@InvoiceNumber nvarchar(20), 
			@NextNumber int, 
			@InvoiceTypeCode smallint;

		IF NOT EXISTS (SELECT        Cash.tbPayment.PaymentCode
						FROM            Cash.tbPayment INNER JOIN
												 Cash.tbCode ON Cash.tbPayment.CashCode = Cash.tbCode.CashCode INNER JOIN
												 Cash.tbCategory ON Cash.tbCode.CategoryCode = Cash.tbCategory.CategoryCode
						WHERE        (Cash.tbPayment.PaymentStatusCode <> 1)  
							AND Cash.tbPayment.UserId = (SELECT UserId FROM Usr.vwCredentials))
			RETURN 

		SELECT @InvoiceTypeCode = CASE WHEN PaidInValue != 0 THEN 0 ELSE 2 END 
		FROM         Cash.tbPayment
		WHERE     (PaymentCode = @PaymentCode)
	
		SELECT @NextNumber = NextNumber
		FROM Invoice.tbType
		WHERE InvoiceTypeCode = @InvoiceTypeCode;
		
		SET @InvoiceNumber = FORMAT(@NextNumber, '000000') + '.' + (SELECT UserId FROM Usr.vwCredentials)

		WHILE EXISTS (SELECT     InvoiceNumber
					  FROM         Invoice.tbInvoice
					  WHERE     (InvoiceNumber = @InvoiceNumber))
			BEGIN
			SET @NextNumber += @NextNumber 
			SET @InvoiceNumber = FORMAT(@NextNumber, '000000') + '.' + (SELECT UserId FROM Usr.vwCredentials)
			END
		
		BEGIN TRANSACTION

		UPDATE    Invoice.tbType
		SET              NextNumber = @NextNumber + 1
		WHERE     (InvoiceTypeCode = @InvoiceTypeCode)

		UPDATE    Cash.tbPayment
		SET		PaymentStatusCode = 1,
			TaxInValue = 
				CASE TaxRate WHEN 0 THEN 0
				ELSE
				(
					CASE App.tbTaxCode.RoundingCode 
						WHEN 0 THEN ROUND(Cash.tbPayment.PaidInValue - ( Cash.tbPayment.PaidInValue / (1 + App.tbTaxCode.TaxRate)), Decimals) 
						WHEN 1 THEN ROUND(Cash.tbPayment.PaidInValue - ( Cash.tbPayment.PaidInValue / (1 + App.tbTaxCode.TaxRate)), Decimals, 1) 
					END
				)
				END, 
			TaxOutValue = 
				CASE TaxRate WHEN 0 THEN 0
				ELSE
				(
					CASE App.tbTaxCode.RoundingCode 
						WHEN 0 THEN ROUND(Cash.tbPayment.PaidOutValue - ( Cash.tbPayment.PaidOutValue / (1 + App.tbTaxCode.TaxRate)), Decimals) 
						WHEN 1 THEN ROUND(Cash.tbPayment.PaidOutValue - ( Cash.tbPayment.PaidOutValue / (1 + App.tbTaxCode.TaxRate)), Decimals, 1) 
					END
				)
				END
		FROM         Cash.tbPayment INNER JOIN
							  App.tbTaxCode ON Cash.tbPayment.TaxCode = App.tbTaxCode.TaxCode
		WHERE     (PaymentCode = @PaymentCode)

		INSERT INTO Invoice.tbInvoice
								 (InvoiceNumber, UserId, AccountCode, InvoiceTypeCode, InvoiceStatusCode, InvoicedOn, DueOn, ExpectedOn, InvoiceValue, TaxValue, PaidValue, PaidTaxValue, Printed)
		SELECT        @InvoiceNumber AS InvoiceNumber, Cash.tbPayment.UserId, Cash.tbPayment.AccountCode, @InvoiceTypeCode AS InvoiceTypeCode, 3 AS InvoiceStatusCode, 
								Cash.tbPayment.PaidOn, Cash.tbPayment.PaidOn AS DueOn, Cash.tbPayment.PaidOn AS ExpectedOn,
								CASE WHEN PaidInValue > 0 THEN PaidInValue - TaxInValue
									WHEN PaidOutValue > 0 THEN PaidOutValue - TaxOutValue
								END AS InvoiceValue, 
								CASE WHEN Cash.tbPayment.PaidInValue > 0 THEN Cash.tbPayment.TaxInValue 
									WHEN Cash.tbPayment.PaidOutValue > 0 THEN Cash.tbPayment.TaxOutValue
								END AS TaxValue, 
								CASE WHEN PaidInValue > 0 THEN PaidInValue - TaxInValue
									WHEN PaidOutValue > 0 THEN PaidOutValue - TaxOutValue
								END AS PaidValue, 
								CASE WHEN Cash.tbPayment.PaidInValue > 0 THEN Cash.tbPayment.TaxInValue 
									WHEN Cash.tbPayment.PaidOutValue > 0 THEN Cash.tbPayment.TaxOutValue
								END AS PaidTaxValue, 
								1 AS Printed
		FROM            Cash.tbPayment INNER JOIN
								 App.tbTaxCode ON Cash.tbPayment.TaxCode = App.tbTaxCode.TaxCode
		WHERE        ( Cash.tbPayment.PaymentCode = @PaymentCode)


		INSERT INTO Invoice.tbItem
							(InvoiceNumber, CashCode, InvoiceValue, TaxValue, PaidValue, PaidTaxValue, TaxCode)
		SELECT     @InvoiceNumber AS InvoiceNumber, Cash.tbPayment.CashCode, 
								CASE WHEN PaidInValue > 0 THEN PaidInValue - TaxInValue
									WHEN PaidOutValue > 0 THEN PaidOutValue - TaxOutValue
								END AS InvoiceValue, 
								CASE WHEN Cash.tbPayment.PaidInValue > 0 THEN Cash.tbPayment.TaxInValue 
									WHEN Cash.tbPayment.PaidOutValue > 0 THEN Cash.tbPayment.TaxOutValue
								END AS TaxValue, 
								CASE WHEN PaidInValue > 0 THEN PaidInValue - TaxInValue
									WHEN PaidOutValue > 0 THEN PaidOutValue - TaxOutValue
								END AS PaidValue, 
								CASE WHEN Cash.tbPayment.PaidInValue > 0 THEN Cash.tbPayment.TaxInValue 
									WHEN Cash.tbPayment.PaidOutValue > 0 THEN Cash.tbPayment.TaxOutValue
								END AS PaidTaxValue, 
							Cash.tbPayment.TaxCode
		FROM         Cash.tbPayment INNER JOIN
							  App.tbTaxCode ON Cash.tbPayment.TaxCode = App.tbTaxCode.TaxCode
		WHERE     ( Cash.tbPayment.PaymentCode = @PaymentCode)

		UPDATE Invoice.tbItem
		SET PaidValue = InvoiceValue, PaidTaxValue = TaxValue
		WHERE InvoiceNumber = @InvoiceNumber

		UPDATE  Org.tbAccount
		SET CurrentBalance = CASE WHEN PaidInValue > 0 THEN Org.tbAccount.CurrentBalance + PaidInValue ELSE Org.tbAccount.CurrentBalance - PaidOutValue END
		FROM         Org.tbAccount INNER JOIN
							  Cash.tbPayment ON Org.tbAccount.CashAccountCode = Cash.tbPayment.CashAccountCode
		WHERE Cash.tbPayment.PaymentCode = @PaymentCode

		COMMIT TRANSACTION

  	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH

