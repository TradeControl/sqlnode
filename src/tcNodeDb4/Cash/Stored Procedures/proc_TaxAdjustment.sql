CREATE   PROCEDURE [Cash].[proc_TaxAdjustment]
(
	@StartOn datetime,
	@TaxTypeCode smallint,
	@TaxAdjustment decimal(18, 5),
	@TaxAdjustmentNote nvarchar(max) = NULL
)
AS
	SET NOCOUNT, XACT_ABORT ON;

	BEGIN TRY
		SET @TaxAdjustmentNote = NULLIF(LTRIM(RTRIM(@TaxAdjustmentNote)), N'');

		IF @TaxAdjustment <> 0 AND @TaxAdjustmentNote IS NULL
			THROW 50000, 'An explanation is required for a non-zero tax adjustment.', 1;

		IF @TaxAdjustment = 0
			SET @TaxAdjustmentNote = NULL;

		DECLARE 		
			@PayTo datetime,
			@PayFrom datetime;

		SELECT 
			@PayFrom = PayFrom,
			@PayTo = PayTo 
		FROM Cash.fnTaxTypeDueDates(@TaxTypeCode, 0) due_dates 
		WHERE @StartOn >= due_dates.PayFrom AND @StartOn < due_dates.PayTo

		UPDATE App.tbYearPeriod
		SET 
			BusinessTaxAdjustment = CASE WHEN @TaxTypeCode IN (0, 4) THEN 0 ELSE BusinessTaxAdjustment END,
			BusinessTaxAdjustmentNote = CASE WHEN @TaxTypeCode IN (0, 4) THEN NULL ELSE BusinessTaxAdjustmentNote END,
			VatAdjustment = CASE @TaxTypeCode WHEN 1 THEN 0 ELSE VatAdjustment END,
			VatAdjustmentNote = CASE @TaxTypeCode WHEN 1 THEN NULL ELSE VatAdjustmentNote END
		WHERE StartOn >= @PayFrom AND StartOn < @PayTo;

		SELECT @StartOn = MAX(StartOn)
		FROM App.tbYearPeriod
		WHERE StartOn < @PayTo;

		UPDATE App.tbYearPeriod
		SET 
			BusinessTaxAdjustment = CASE WHEN @TaxTypeCode IN (0, 4) THEN @TaxAdjustment ELSE BusinessTaxAdjustment END,
			BusinessTaxAdjustmentNote = CASE WHEN @TaxTypeCode IN (0, 4) THEN @TaxAdjustmentNote ELSE BusinessTaxAdjustmentNote END,
			VatAdjustment = CASE @TaxTypeCode WHEN 1 THEN @TaxAdjustment ELSE VatAdjustment END,
			VatAdjustmentNote = CASE @TaxTypeCode WHEN 1 THEN @TaxAdjustmentNote ELSE VatAdjustmentNote END
		WHERE StartOn = @StartOn;
	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
