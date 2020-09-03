CREATE PROCEDURE App.proc_PeriodClose
AS
 	SET NOCOUNT, XACT_ABORT ON;

	BEGIN TRY
		IF EXISTS(SELECT * FROM App.fnActivePeriod())
			BEGIN
			DECLARE @StartOn datetime, @YearNumber smallint

			SELECT @StartOn = StartOn, @YearNumber = YearNumber
			FROM App.fnActivePeriod() fnSystemActivePeriod
		 	
			EXEC Cash.proc_GeneratePeriods

			BEGIN TRAN

			UPDATE       Cash.tbPeriod
			SET                InvoiceValue = 0, InvoiceTax = 0
			FROM            Cash.tbPeriod 
			WHERE        (Cash.tbPeriod.StartOn = @StartOn);

			WITH invoice_summary AS
			(
				SELECT        Invoice.vwRegisterDetail.CashCode, Invoice.vwRegisterDetail.StartOn, ABS(SUM(Invoice.vwRegisterDetail.InvoiceValue)) AS InvoiceValue, ABS(SUM(Invoice.vwRegisterDetail.TaxValue)) AS TaxValue
				FROM            Invoice.vwRegisterDetail 
						JOIN Cash.tbCode ON Invoice.vwRegisterDetail.CashCode = Cash.tbCode.CashCode 
						JOIN Cash.tbCategory ON Cash.tbCode.CategoryCode = Cash.tbCategory.CategoryCode
				WHERE Invoice.vwRegisterDetail.StartOn = @StartOn
				GROUP BY Invoice.vwRegisterDetail.StartOn, Invoice.vwRegisterDetail.CashCode
			)
			UPDATE Cash.tbPeriod
			SET InvoiceValue = invoice_summary.InvoiceValue, 
				InvoiceTax = invoice_summary.TaxValue
			FROM    Cash.tbPeriod 
				JOIN invoice_summary ON Cash.tbPeriod.CashCode = invoice_summary.CashCode AND Cash.tbPeriod.StartOn = invoice_summary.StartOn;

			WITH asset_entries AS
			(
				SELECT payment.CashCode, 
					(SELECT TOP 1 StartOn FROM App.tbYearPeriod WHERE (StartOn <= payment.PaidOn) ORDER BY StartOn DESC) AS StartOn,
					(PaidInValue - PaidOutValue) AssetValue
				FROM Cash.tbPayment payment
					JOIN Org.tbAccount account ON payment.CashAccountCode = account.CashAccountCode
				WHERE account.AccountTypeCode = 2 AND payment.IsProfitAndLoss <> 0 AND PaidOn >= @StartOn
			), asset_summary AS
			(
				SELECT CashCode, StartOn, SUM(AssetValue) AssetValue
				FROM asset_entries
				WHERE StartOn = @StartOn
				GROUP BY CashCode, StartOn				
			)
			UPDATE Cash.tbPeriod
			SET InvoiceValue = AssetValue
			FROM  Cash.tbPeriod 
				JOIN asset_summary 
					ON Cash.tbPeriod.CashCode = asset_summary.CashCode AND Cash.tbPeriod.StartOn = asset_summary.StartOn;		
	
			UPDATE App.tbYearPeriod
			SET CashStatusCode = 2
			WHERE StartOn = @StartOn			
		
			IF NOT EXISTS (SELECT     CashStatusCode
						FROM         App.tbYearPeriod
						WHERE     (YearNumber = @YearNumber) AND (CashStatusCode < 2)) 
				BEGIN
				UPDATE App.tbYear
				SET CashStatusCode = 2
				WHERE YearNumber = @YearNumber	
				END
			IF EXISTS(SELECT * FROM App.fnActivePeriod())
				BEGIN
				UPDATE App.tbYearPeriod
				SET CashStatusCode = 1
				FROM App.fnActivePeriod() fnSystemActivePeriod INNER JOIN
									App.tbYearPeriod ON fnSystemActivePeriod.YearNumber = App.tbYearPeriod.YearNumber AND fnSystemActivePeriod.MonthNumber = App.tbYearPeriod.MonthNumber
			
				END		
			IF EXISTS(SELECT * FROM App.fnActivePeriod())
				BEGIN
				UPDATE App.tbYear
				SET CashStatusCode = 1
				FROM App.fnActivePeriod() fnSystemActivePeriod INNER JOIN
									App.tbYear ON fnSystemActivePeriod.YearNumber = App.tbYear.YearNumber  
				END

			COMMIT TRAN

			END
					
  	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
