CREATE   PROCEDURE Cash.proc_PaymentPostPaidOut
	(
	@PaymentCode nvarchar(20),
	@PostValue decimal(18, 5)  
	)
 AS
  	SET NOCOUNT, XACT_ABORT ON;

	BEGIN TRY
		DECLARE 
			@InvoiceNumber nvarchar(20)	
			, @TaskCode nvarchar(20)
			, @TaxRate real
			, @ItemValue decimal(18, 5)
			, @RoundingCode smallint
			, @PaidValue decimal(18, 5)	
			, @PaidTaxValue decimal(18, 5)
			, @TaxInValue decimal(18, 5) = 0
			, @TaxOutValue decimal(18, 5) = 0
			, @CashCode nvarchar(50)	
			, @TaxCode nvarchar(10)
			, @Decimals smallint;


		DECLARE curPaidOut CURSOR LOCAL FOR
			SELECT     Invoice.vwOutstanding.InvoiceNumber, Invoice.vwOutstanding.TaskCode, Invoice.vwOutstanding.CashCode, Invoice.vwOutstanding.TaxCode, 
								  Invoice.vwOutstanding.TaxRate, Invoice.vwOutstanding.ItemValue, Invoice.vwOutstanding.RoundingCode, Invoice.vwOutstanding.Decimals
			FROM         Invoice.vwOutstanding INNER JOIN
								  Cash.tbPayment ON Invoice.vwOutstanding.AccountCode = Cash.tbPayment.AccountCode
			WHERE     ( Cash.tbPayment.PaymentCode = @PaymentCode)
			ORDER BY Invoice.vwOutstanding.CashModeCode DESC, Invoice.vwOutstanding.ExpectedOn

		OPEN curPaidOut
		FETCH NEXT FROM curPaidOut INTO @InvoiceNumber, @TaskCode, @CashCode, @TaxCode, @TaxRate, @ItemValue, @RoundingCode, @Decimals
		WHILE @@FETCH_STATUS = 0 and @PostValue > 0
			BEGIN
			IF (@PostValue + @ItemValue) < 0
				SET @ItemValue = @PostValue * -1

			SET @PaidTaxValue = 
				CASE @TaxRate WHEN 0 THEN 0
				ELSE
				(
					CASE @RoundingCode 
						WHEN 0 THEN ROUND(ABS(@ItemValue) - (ABS(@ItemValue) / (1 + @TaxRate)), @Decimals) 
						WHEN 1 THEN ROUND(ABS(@ItemValue) - (ABS(@ItemValue) / (1 + @TaxRate)), @Decimals, 1) 
					END
				)
				END

			SET @PaidValue = ABS(@ItemValue) - @PaidTaxValue
				
			SET @PostValue = @PostValue + @ItemValue
		
			IF LEN(ISNULL(@TaskCode, '')) = 0
				BEGIN
				UPDATE    Invoice.tbItem
				SET              PaidValue = PaidValue + @PaidValue, PaidTaxValue = PaidTaxValue + @PaidTaxValue
				WHERE     (InvoiceNumber = @InvoiceNumber) AND (CashCode = @CashCode)
				END
			ELSE
				BEGIN
				UPDATE   Invoice.tbTask
				SET              PaidValue = PaidValue + @PaidValue, PaidTaxValue = PaidTaxValue + @PaidTaxValue
				WHERE     (InvoiceNumber = @InvoiceNumber) AND (TaskCode = @TaskCode)				
				END

			EXEC Invoice.proc_Total @InvoiceNumber
		        		  
			SET @TaxInValue += CASE WHEN @ItemValue > 0 THEN @PaidTaxValue ELSE 0 END
			SET @TaxOutValue += CASE WHEN @ItemValue < 0 THEN @PaidTaxValue ELSE 0 END	
				
			FETCH NEXT FROM curPaidOut INTO @InvoiceNumber, @TaskCode, @CashCode, @TaxCode, @TaxRate, @ItemValue, @RoundingCode, @Decimals
			END
		
		CLOSE curPaidOut
		DEALLOCATE curPaidOut

		IF NOT @CashCode IS NULL
			BEGIN
			UPDATE    Cash.tbPayment
			SET      PaymentStatusCode = 1, TaxInValue = @TaxInValue, TaxOutValue = @TaxOutValue, 
				CashCode = ISNULL(@CashCode, Cash.tbPayment.CashCode), 
				TaxCode = ISNULL(@TaxCode, Cash.tbPayment.TaxCode)
			WHERE     (PaymentCode = @PaymentCode)
			END
	
  	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH

