﻿CREATE   PROCEDURE Cash.proc_PaymentAdd(@AccountCode nvarchar(10), @CashAccountCode AS nvarchar(10), @CashCode nvarchar(50), @PaidOn datetime, @ToPay decimal(18, 5), @PaymentReference nvarchar(50) = null, @PaymentCode nvarchar(20) output)
AS
	SET NOCOUNT, XACT_ABORT ON;
	BEGIN TRY
		
		EXECUTE Cash.proc_NextPaymentCode  @PaymentCode OUTPUT

		INSERT INTO Cash.tbPayment (PaymentCode, UserId, PaymentStatusCode, AccountCode, CashAccountCode, CashCode, TaxCode, PaidOn, PaidInValue, PaidOutValue, TaxInValue, TaxOutValue, PaymentReference)
		SELECT   @PaymentCode AS PaymentCode, 
			(SELECT UserId FROM Usr.vwCredentials) AS UserId,
			0 AS PaymentStatusCode,
			@AccountCode AS AccountCode,
			@CashAccountCode AS CashAccountCode,
			@CashCode AS CashCode,
			Cash.tbCode.TaxCode,
			@PaidOn As PaidOn,
			CASE WHEN @ToPay > 0 THEN @ToPay ELSE 0 END AS PaidInValue,
			CASE WHEN @ToPay < 0 THEN ABS(@ToPay) ELSE 0 END AS PaidOutValue,
			CASE WHEN @ToPay > 0 THEN @ToPay * App.tbTaxCode.TaxRate ELSE 0 END AS TaxInValue,
			CASE WHEN @ToPay < 0 THEN ABS(@ToPay) * App.tbTaxCode.TaxRate ELSE 0 END AS TaxOutValue,
			@PaymentReference PaymentReference
		FROM            Cash.tbCode INNER JOIN
								 Cash.tbCategory ON Cash.tbCode.CategoryCode = Cash.tbCategory.CategoryCode INNER JOIN
								 App.tbTaxCode ON Cash.tbCode.TaxCode = App.tbTaxCode.TaxCode
		WHERE        (Cash.tbCode.CashCode = @CashCode)


	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
