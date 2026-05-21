CREATE PROCEDURE Cash.proc_AssetReversal
(
	@PaymentCode nvarchar(20),
	@Periods smallint = 5,
	@Months smallint = 12,
	@StartOn datetime = null,
	@PaymentReference nvarchar(50) = null
)
AS
	SET NOCOUNT, XACT_ABORT ON;

	BEGIN TRY
		DECLARE 
			@Period smallint = 1
			, @NewPaymentCode nvarchar(20)
			, @UserId nvarchar(10) = (SELECT UserId FROM Usr.vwCredentials)
			, @PaidValue decimal(18, 5)
			, @CashPolarityCode smallint
		;

		SELECT 
			@PaidValue = (PaidInValue + PaidOutValue) / @Periods,
			@CashPolarityCode = CASE WHEN p.PaidInValue = 0 THEN 0 ELSE 1 END,
			@StartOn = CASE WHEN @StartOn IS NULL THEN PaidOn ELSE @StartOn END,
			@PaymentReference = 
				CASE COALESCE(@PaymentReference, '') 
					WHEN '' THEN CONCAT('Write Off ', COALESCE(PaymentReference, '')) 
					ELSE @PaymentReference 
				END
		FROM Cash.tbPayment p
		WHERE p.PaymentCode = @PaymentCode

		BEGIN TRAN

		WHiLE @Period <= @Periods
		BEGIN
			EXEC Cash.proc_NextPaymentCode @NewPaymentCode OUTPUT;
			
			INSERT INTO Cash.tbPayment
			(
				PaymentCode, 
				UserId, 
				PaymentStatusCode, 
				SubjectCode, 
				ParentSubjectCode, 
				AccountCode, 
				CashCode,
				TaxCode,
				PaidOn,
				PaidInValue,
				PaidOutValue,
				PaymentReference
			)
			SELECT
			
				@NewPaymentCode,
				@UserId,
				0,
				SubjectCode,
				ParentSubjectCode, 
				AccountCode, 
				CashCode,
				TaxCode,
				DATEADD(MONTH, @Period * @Months, @StartOn),
				CASE @CashPolarityCode WHEN 0 THEN @PaidValue ELSE 0 END,
				CASE @CashPolarityCode WHEN 1 THEN @PaidValue ELSE 0 END,
				@PaymentReference
			FROM Cash.tbPayment p
			WHERE p.PaymentCode = @PaymentCode

			SET @Period += 1;
		END

		COMMIT TRAN
	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
GO
