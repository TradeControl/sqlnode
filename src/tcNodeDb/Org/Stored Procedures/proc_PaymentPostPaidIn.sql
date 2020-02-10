
CREATE   PROCEDURE Org.proc_PaymentPostPaidIn
	(
	@PaymentCode nvarchar(20),
	@PostValue money  
	)
 AS
  	SET NOCOUNT, XACT_ABORT ON;

	BEGIN TRY
		DECLARE 
			@InvoiceNumber nvarchar(20)
			, @TaskCode nvarchar(20)
			, @TaxRate real
			, @ItemValue money
			, @RoundingCode smallint
			, @PaidValue money	
			, @PaidTaxValue money
			, @TaxInValue money = 0
			, @TaxOutValue money = 0
			, @CashCode nvarchar(50)	
			, @TaxCode nvarchar(10)

	
		DECLARE curPaidIn CURSOR LOCAL FOR
			SELECT     Invoice.vwOutstanding.InvoiceNumber, Invoice.vwOutstanding.TaskCode, Invoice.vwOutstanding.CashCode, Invoice.vwOutstanding.TaxCode, 
								  Invoice.vwOutstanding.TaxRate, Invoice.vwOutstanding.ItemValue, Invoice.vwOutstanding.RoundingCode
			FROM         Invoice.vwOutstanding INNER JOIN
								  Org.tbPayment ON Invoice.vwOutstanding.AccountCode = Org.tbPayment.AccountCode
			WHERE     ( Org.tbPayment.PaymentCode = @PaymentCode)
			ORDER BY Invoice.vwOutstanding.CashModeCode, Invoice.vwOutstanding.ExpectedOn

		OPEN curPaidIn
		FETCH NEXT FROM curPaidIn INTO @InvoiceNumber, @TaskCode, @CashCode, @TaxCode, @TaxRate, @ItemValue, @RoundingCode
		WHILE @@FETCH_STATUS = 0 and @PostValue < 0
			BEGIN
			IF (@PostValue + @ItemValue) > 0
				SET @ItemValue = @PostValue * -1

			SET @PaidTaxValue = (CASE @RoundingCode WHEN 0 THEN ROUND(ABS(@ItemValue) - (ABS(@ItemValue) / (1 + @TaxRate)), 2) WHEN 1 THEN ROUND(ABS(@ItemValue) - (ABS(@ItemValue) / (1 + @TaxRate)), 2, 1) END)
			SET @PaidValue = ABS(@ItemValue) - @PaidTaxValue
				
			SET @PostValue = @PostValue + @ItemValue
		
			IF @TaskCode IS NULL
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
				
			FETCH NEXT FROM curPaidIn INTO @InvoiceNumber, @TaskCode, @CashCode, @TaxCode, @TaxRate, @ItemValue, @RoundingCode
			END
	
		CLOSE curPaidIn
		DEALLOCATE curPaidIn
	
	
		IF NOT @CashCode IS NULL
			BEGIN
			UPDATE    Org.tbPayment
			SET      PaymentStatusCode = 1, TaxInValue = @TaxInValue, TaxOutValue = @TaxOutValue, 
				CashCode = ISNULL(@CashCode, Org.tbPayment.CashCode), 
				TaxCode = ISNULL(@TaxCode, Org.tbPayment.TaxCode)
			WHERE     (PaymentCode = @PaymentCode)
			END	
			
  	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
