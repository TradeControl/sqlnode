/**************************************************************************************
Trade Control
Upgrade script
Release: 3.31.1

Date: 6 January 2021
Author: IAM

Trade Control by Trade Control Ltd is licensed under GNU General Public License v3.0. 

You may obtain a copy of the License at

	https://www.gnu.org/licenses/gpl-3.0.en.html

Change log:

	https://github.com/tradecontrol/sqlnode

Instructions:
This script should be applied by the Node Configuration app.

***********************************************************************************/
go
ALTER FUNCTION Cash.fnTaxTypeDueDates(@TaxTypeCode smallint)
RETURNS @tbDueDate TABLE (PayOn datetime, PayFrom datetime, PayTo datetime)
 AS
	BEGIN
	DECLARE @MonthNumber smallint
			, @MonthInterval smallint
			, @StartOn datetime
	
		SELECT 
			@MonthNumber = MonthNumber, 
			@MonthInterval = CASE RecurrenceCode
								WHEN 0 THEN 1
								WHEN 1 THEN 1
								WHEN 2 THEN 3
								WHEN 3 THEN 6
								WHEN 4 THEN 12
							END
		FROM Cash.tbTaxType
		WHERE TaxTypeCode = @TaxTypeCode			

		SELECT   @StartOn = MIN(StartOn)
		FROM         App.tbYearPeriod
		WHERE     (MonthNumber = @MonthNumber)

		INSERT INTO @tbDueDate (PayOn) VALUES (@StartOn)
	
		SET @MonthNumber = CASE 			
			WHEN (@MonthNumber + @MonthInterval) <= 12 THEN @MonthNumber + @MonthInterval
			WHEN (@MonthNumber + @MonthInterval) % 12 = 0 THEN @MonthNumber
			ELSE (@MonthNumber + @MonthInterval) % 12
			END
	
		WHILE EXISTS(SELECT     *
					 FROM         App.tbYearPeriod
					 WHERE     (StartOn > @StartOn) AND (MonthNumber = @MonthNumber))
		BEGIN
			SELECT @StartOn = MIN(StartOn)
			FROM         App.tbYearPeriod
			WHERE     (StartOn > @StartOn) AND (MonthNumber = @MonthNumber)
			ORDER BY MIN(StartOn)		
			INSERT INTO @tbDueDate (PayOn) VALUES (@StartOn)
		
			SET @MonthNumber = CASE 
						WHEN (@MonthNumber + @MonthInterval) <= 12 THEN @MonthNumber + @MonthInterval
						WHEN (@MonthNumber + @MonthInterval) % 12 = 0 THEN @MonthNumber
						ELSE (@MonthNumber + @MonthInterval) % 12 
						END;	
		END;

		WITH dd AS
		(
			SELECT PayOn, LAG(PayOn) OVER (ORDER BY PayOn) AS PayFrom
			FROM @tbDueDate 
		)
		UPDATE @tbDueDate
		SET PayTo = dd.PayOn, PayFrom = dd.PayFrom
		FROM @tbDueDate tbDueDate JOIN dd ON tbDueDate.PayOn = dd.PayOn;

		UPDATE @tbDueDate
		SET PayFrom = DATEADD(MONTH, @MonthInterval * -1, PayTo)
		WHERE PayTo = (SELECT MIN(PayTo) FROM @tbDueDate);

		UPDATE @tbDueDate
		SET PayOn = DATEADD(DAY, (SELECT OffsetDays FROM Cash.tbTaxType WHERE TaxTypeCode = @TaxTypeCode), PayOn)

	RETURN	
	END
go
ALTER VIEW Invoice.vwStatusLive
AS
	WITH nonzero_balance_orgs AS
	(
		SELECT AccountCode, ABS(Balance) Balance, CASE WHEN Balance > 0 THEN 0 ELSE 1 END CashModeCode 
		FROM Org.vwCurrentBalance
	)
	, paid_invoices AS
	(
		SELECT AccountCode, InvoiceNumber, 3 InvoiceStatusCode, TotalPaid, TaxRate
		FROM nonzero_balance_orgs
			CROSS APPLY
				(
					SELECT InvoiceNumber,
						(InvoiceValue + TaxValue) TotalPaid,
						TaxValue / CASE InvoiceValue WHEN 0 THEN 1 ELSE InvoiceValue END TaxRate
					FROM Invoice.tbInvoice invoices
						INNER JOIN Invoice.tbType ON invoices.InvoiceTypeCode = Invoice.tbType.InvoiceTypeCode
					WHERE (AccountCode = nonzero_balance_orgs.AccountCode 
							AND Invoice.tbType.CashModeCode <> nonzero_balance_orgs.CashModeCode)
				) invoices
	), candidates_invoices AS
	(
		SELECT AccountCode, NULL InvoiceNumber, 0 RowNumber, Balance TotalCharge, 0 TaxRate
		FROM nonzero_balance_orgs
		UNION
		SELECT AccountCode, InvoiceNumber, RowNumber, TotalCharge, TaxRate
		FROM nonzero_balance_orgs
			CROSS APPLY
				(
					SELECT InvoiceNumber, ROW_NUMBER() OVER (ORDER BY InvoicedOn DESC) RowNumber,
							(InvoiceValue + TaxValue) * - 1  TotalCharge,
							TaxValue / CASE InvoiceValue WHEN 0 THEN 1 ELSE InvoiceValue END TaxRate
					FROM Invoice.tbInvoice invoices
						INNER JOIN Invoice.tbType ON invoices.InvoiceTypeCode = Invoice.tbType.InvoiceTypeCode
					WHERE AccountCode = nonzero_balance_orgs.AccountCode 
						AND Invoice.tbType.CashModeCode = nonzero_balance_orgs.CashModeCode
				) invoices
	)
	, candidate_balance AS
	(
		SELECT AccountCode, InvoiceNumber, TotalCharge, TaxRate,
			CAST(SUM(TotalCharge) OVER (PARTITION BY AccountCode ORDER BY RowNumber ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS float) AS Balance
		FROM candidates_invoices
	), candidate_status AS
	(
		SELECT AccountCode, InvoiceNumber,
			CASE 
				WHEN Balance >= 0 THEN 1 ELSE
				CASE WHEN TotalCharge < Balance THEN 2 ELSE 3 END
			END InvoiceStatusCode,
			CASE 
				WHEN Balance >= 0 THEN 0 ELSE
				CASE WHEN TotalCharge < Balance THEN ABS(Balance) ELSE ABS(TotalCharge) END
			END TotalPaid,
			TaxRate
		FROM candidate_balance
	), invoice_status AS
	(
		SELECT AccountCode, InvoiceNumber, InvoiceStatusCode, TotalPaid, TaxRate 
		FROM paid_invoices
		UNION
		SELECT AccountCode, InvoiceNumber, InvoiceStatusCode, TotalPaid, TaxRate 
		FROM candidate_status 
		WHERE NOT (InvoiceNumber IS NULL)
	)
	SELECT AccountCode, InvoiceNumber, InvoiceStatusCode, 
		TotalPaid / (1 + TaxRate) PaidValue,
		TotalPaid - (TotalPaid / (1 + TaxRate)) PaidTaxValue
	FROM invoice_status;
go
ALTER PROCEDURE Cash.proc_GeneratePeriods
AS
 	SET NOCOUNT, XACT_ABORT ON;

	BEGIN TRY
	DECLARE 
		@YearNumber smallint
		, @StartOn datetime
		, @PeriodStartOn datetime
		, @CashStatusCode smallint
		, @Period smallint
	
		DECLARE curYr cursor for	
			SELECT     YearNumber, CAST(CONCAT(FORMAT(YearNumber, '0000'), FORMAT(StartMonth, '00'), FORMAT(1, '00')) AS DATE) AS StartOn, CashStatusCode
			FROM         App.tbYear
			WHERE CashStatusCode < 2

		OPEN curYr
	
		FETCH NEXT FROM curYr INTO @YearNumber, @StartOn, @CashStatusCode
		WHILE @@FETCH_STATUS = 0
			BEGIN
			SET @PeriodStartOn = @StartOn
			SET @Period = 1
			WHILE @Period < 13
				BEGIN
				IF not EXISTS (SELECT MonthNumber FROM App.tbYearPeriod WHERE YearNumber = @YearNumber and MonthNumber = DATEPART(m, @PeriodStartOn))
					BEGIN
					INSERT INTO App.tbYearPeriod (YearNumber, StartOn, MonthNumber, CashStatusCode)
					VALUES (@YearNumber, @PeriodStartOn, DATEPART(m, @PeriodStartOn), 0)				
					END
				SET @PeriodStartOn = DATEADD(m, 1, @PeriodStartOn)	
				SET @Period = @Period + 1
				END		
				
			FETCH NEXT FROM curYr INTO @YearNumber, @StartOn, @CashStatusCode
			END
	
		CLOSE curYr
		DEALLOCATE curYr
	
		INSERT INTO Cash.tbPeriod
							  (CashCode, StartOn)
		SELECT     Cash.vwPeriods.CashCode, Cash.vwPeriods.StartOn
		FROM         Cash.vwPeriods LEFT OUTER JOIN
							  Cash.tbPeriod ON Cash.vwPeriods.CashCode = Cash.tbPeriod.CashCode AND Cash.vwPeriods.StartOn = Cash.tbPeriod.StartOn
		WHERE     ( Cash.tbPeriod.CashCode IS NULL)
		 
		UPDATE Cash.tbPeriod
		SET InvoiceValue = 0, InvoiceTax = 0;
		
		WITH invoice_entries AS
		(
			SELECT invoices.CashCode, invoices.StartOn, categories.CashModeCode, SUM(invoices.InvoiceValue) InvoiceValue, SUM(invoices.TaxValue) TaxValue
			FROM  Invoice.vwRegisterDetail invoices
				JOIN Cash.tbCode cash_codes ON invoices.CashCode = cash_codes.CashCode 
				JOIN Cash.tbCategory categories ON cash_codes.CategoryCode = categories .CategoryCode
			WHERE   (StartOn < (SELECT StartOn FROM App.fnActivePeriod()))
			GROUP BY invoices.CashCode, invoices.StartOn, categories.CashModeCode
		), invoice_summary AS
		(
			SELECT CashCode, StartOn,
				CASE CashModeCode 
					WHEN 0 THEN
						InvoiceValue * -1
					ELSE 
						InvoiceValue
				END AS InvoiceValue,
				CASE CashModeCode 
					WHEN 0 THEN
						TaxValue * -1
					ELSE 
						TaxValue
				END AS TaxValue						
			FROM invoice_entries
		)
		UPDATE Cash.tbPeriod
		SET InvoiceValue = invoice_summary.InvoiceValue, 
			InvoiceTax = invoice_summary.TaxValue
		FROM    Cash.tbPeriod 
			JOIN invoice_summary 
				ON Cash.tbPeriod.CashCode = invoice_summary.CashCode AND Cash.tbPeriod.StartOn = invoice_summary.StartOn;

		WITH asset_entries AS
		(
			SELECT payment.CashCode, 
				(SELECT TOP 1 StartOn FROM App.tbYearPeriod WHERE (StartOn <= payment.PaidOn) ORDER BY StartOn DESC) AS StartOn,
				CASE cash_category.CashModeCode
					WHEN 0 THEN (PaidInValue + (PaidOutValue * -1)) * -1
					WHEN 1 THEN PaidInValue + (PaidOutValue * -1)
				END AssetValue
			FROM Cash.tbPayment payment
				JOIN Org.tbAccount account ON payment.CashAccountCode = account.CashAccountCode
				JOIN Cash.tbCode cash_code ON account.CashCode = cash_code.CashCode
				JOIN Cash.tbCategory cash_category ON cash_code.CategoryCode = cash_category.CategoryCode
			WHERE account.AccountTypeCode = 2 AND payment.IsProfitAndLoss <> 0 AND PaidOn < (SELECT StartOn FROM App.fnActivePeriod())
		), asset_summary AS
		(
			SELECT CashCode, StartOn, SUM(AssetValue) AssetValue
			FROM asset_entries
			GROUP BY CashCode, StartOn
		)
		UPDATE Cash.tbPeriod
		SET InvoiceValue = AssetValue
		FROM  Cash.tbPeriod 
			JOIN asset_summary 
				ON Cash.tbPeriod.CashCode = asset_summary.CashCode AND Cash.tbPeriod.StartOn = asset_summary.StartOn;	

  	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
go
ALTER PROCEDURE App.proc_SystemRebuild
AS
  	SET NOCOUNT, XACT_ABORT ON;

	DECLARE @AccountCode nvarchar(10), @PaymentCode nvarchar(20);

	BEGIN TRY
		BEGIN TRANSACTION;

		UPDATE Task.tbFlow
		SET UsedOnQuantity = task.Quantity / parent_task.Quantity
		FROM            Task.tbFlow AS flow 
			JOIN Task.tbTask AS task ON flow.ChildTaskCode = task.TaskCode 
			JOIN Task.tbTask AS parent_task ON flow.ParentTaskCode = parent_task.TaskCode
			JOIN Cash.tbCode ON parent_task.CashCode = Cash.tbCode.CashCode
		WHERE        (flow.UsedOnQuantity <> 0) AND (task.Quantity <> 0) 
			AND (task.Quantity / parent_task.Quantity <> flow.UsedOnQuantity);

		WITH parent_task AS
		(
			SELECT        ParentTaskCode
			FROM            Task.tbFlow flow
				JOIN Task.tbTask task ON flow.ParentTaskCode = task.TaskCode
				JOIN Cash.tbCode cash ON task.CashCode = cash.CashCode
		), task_flow AS
		(
			SELECT        flow.ParentTaskCode, flow.StepNumber, task.ActionOn,
					LAG(task.ActionOn, 1, task.ActionOn) OVER (PARTITION BY flow.ParentTaskCode ORDER BY StepNumber) AS PrevActionOn
			FROM Task.tbFlow flow
				JOIN Task.tbTask task ON flow.ChildTaskCode = task.TaskCode
				JOIN parent_task ON flow.ParentTaskCode = parent_task.ParentTaskCode
		), step_disordered AS
		(
			SELECT ParentTaskCode 
			FROM task_flow
			WHERE ActionOn < PrevActionOn
			GROUP BY ParentTaskCode
		), step_ordered AS
		(
			SELECT flow.ParentTaskCode, flow.ChildTaskCode,
				ROW_NUMBER() OVER (PARTITION BY flow.ParentTaskCode ORDER BY task.ActionOn, flow.StepNumber) * 10 AS StepNumber 
			FROM step_disordered
				JOIN Task.tbFlow flow ON step_disordered.ParentTaskCode = flow.ParentTaskCode
				JOIN Task.tbTask task ON flow.ChildTaskCode = task.TaskCode
		)
		UPDATE flow
		SET
			StepNumber = step_ordered.StepNumber
		FROM Task.tbFlow flow
			JOIN step_ordered ON flow.ParentTaskCode = step_ordered.ParentTaskCode AND flow.ChildTaskCode = step_ordered.ChildTaskCode;

		--invoices	
		UPDATE Invoice.tbItem
		SET 
			InvoiceValue =  ROUND(Invoice.tbItem.TotalValue / (1 + App.tbTaxCode.TaxRate), Decimals)
		FROM         Invoice.tbItem INNER JOIN
								App.tbTaxCode ON Invoice.tbItem.TaxCode = App.tbTaxCode.TaxCode INNER JOIN
								Invoice.tbInvoice ON Invoice.tbItem.InvoiceNumber = Invoice.tbInvoice.InvoiceNumber
		WHERE     ( Invoice.tbInvoice.InvoiceStatusCode <> 0) AND Invoice.tbItem.TotalValue <> 0;

		UPDATE Invoice.tbItem
		SET TaxValue = CASE App.tbTaxCode.RoundingCode 
				WHEN 0 THEN ROUND(Invoice.tbItem.InvoiceValue * App.tbTaxCode.TaxRate, Decimals)
				WHEN 1 THEN ROUND( Invoice.tbItem.InvoiceValue * App.tbTaxCode.TaxRate, Decimals, 1) END
		FROM         Invoice.tbItem INNER JOIN
								App.tbTaxCode ON Invoice.tbItem.TaxCode = App.tbTaxCode.TaxCode 
								INNER JOIN Invoice.tbInvoice ON Invoice.tbItem.InvoiceNumber = Invoice.tbInvoice.InvoiceNumber
		WHERE     ( Invoice.tbInvoice.InvoiceStatusCode <> 0);
                   
		UPDATE Invoice.tbTask
		SET InvoiceValue =  ROUND(Invoice.tbTask.TotalValue / (1 + App.tbTaxCode.TaxRate), Decimals)
		FROM         Invoice.tbTask INNER JOIN
								App.tbTaxCode ON Invoice.tbTask.TaxCode = App.tbTaxCode.TaxCode INNER JOIN
								Invoice.tbInvoice ON Invoice.tbTask.InvoiceNumber = Invoice.tbInvoice.InvoiceNumber
		WHERE     ( Invoice.tbInvoice.InvoiceStatusCode <> 0) AND Invoice.tbTask.TotalValue <> 0;

		UPDATE Invoice.tbTask
		SET TaxValue = CASE App.tbTaxCode.RoundingCode 
				WHEN 0 THEN ROUND(Invoice.tbTask.InvoiceValue * App.tbTaxCode.TaxRate, Decimals)
				WHEN 1 THEN ROUND( Invoice.tbTask.InvoiceValue * App.tbTaxCode.TaxRate, Decimals, 1) END,
			InvoiceValue = CASE WHEN Invoice.tbTask.TotalValue = 0 
								THEN Invoice.tbTask.InvoiceValue 
								ELSE ROUND(Invoice.tbTask.TotalValue / (1 + App.tbTaxCode.TaxRate), Decimals) 
							END
		FROM         Invoice.tbTask INNER JOIN
								App.tbTaxCode ON Invoice.tbTask.TaxCode = App.tbTaxCode.TaxCode 
								INNER JOIN Invoice.tbInvoice ON Invoice.tbTask.InvoiceNumber = Invoice.tbInvoice.InvoiceNumber
		WHERE     ( Invoice.tbInvoice.InvoiceStatusCode <> 0);
						   	
	
		WITH items AS
		(
			SELECT     Invoice.tbInvoice.InvoiceNumber, SUM( Invoice.tbItem.InvoiceValue) AS TotalInvoiceValue, SUM( Invoice.tbItem.TaxValue) AS TotalTaxValue
			FROM         Invoice.tbItem INNER JOIN
								Invoice.tbInvoice ON Invoice.tbItem.InvoiceNumber = Invoice.tbInvoice.InvoiceNumber
			GROUP BY Invoice.tbInvoice.InvoiceNumber
		), tasks AS
		(
			SELECT     Invoice.tbInvoice.InvoiceNumber, SUM( Invoice.tbTask.InvoiceValue) AS TotalInvoiceValue, SUM( Invoice.tbTask.TaxValue) AS TotalTaxValue
			FROM         Invoice.tbTask INNER JOIN
								Invoice.tbInvoice ON Invoice.tbTask.InvoiceNumber = Invoice.tbInvoice.InvoiceNumber
			GROUP BY Invoice.tbInvoice.InvoiceNumber
		), invoice_totals AS
		(
			SELECT invoices.InvoiceNumber, 
				COALESCE(items.TotalInvoiceValue, 0) + COALESCE(tasks.TotalInvoiceValue, 0) TotalInvoiceValue,
				COALESCE(items.TotalTaxValue, 0) + COALESCE(tasks.TotalTaxValue, 0) TotalTaxValue
			FROM Invoice.tbInvoice invoices
				LEFT OUTER JOIN tasks ON invoices.InvoiceNumber = tasks.InvoiceNumber
				LEFT OUTER JOIN items ON invoices.InvoiceNumber = items.InvoiceNumber
			WHERE ( invoices.InvoiceStatusCode > 0)
		)
		UPDATE invoices
		SET InvoiceValue = TotalInvoiceValue, 
			TaxValue = TotalTaxValue
		FROM  Invoice.tbInvoice invoices 
			JOIN invoice_totals ON invoices.InvoiceNumber = invoice_totals.InvoiceNumber
		WHERE (InvoiceValue <> TotalInvoiceValue OR TaxValue <> TotalTaxValue);

		WITH invoice_status AS
		(
			SELECT InvoiceNumber, InvoiceStatusCode, PaidValue, PaidTaxValue
			FROM Invoice.vwStatusLive
		)
		UPDATE invoices
		SET 
			InvoiceStatusCode = invoice_status.InvoiceStatusCode,
			PaidValue = invoice_status.PaidValue,
			PaidTaxValue = invoice_status.PaidTaxValue
		FROM Invoice.tbInvoice invoices	
			JOIN invoice_status ON invoices.InvoiceNumber = invoice_status.InvoiceNumber
		WHERE 
			invoices.InvoiceStatusCode <> invoice_status.InvoiceStatusCode 
			OR invoices.PaidValue <> invoice_status.PaidValue 
			OR invoices.PaidTaxValue <> invoice_status.PaidTaxValue;		
		--cash accounts
		UPDATE Org.tbAccount
		SET CurrentBalance = Cash.vwAccountRebuild.CurrentBalance
		FROM         Cash.vwAccountRebuild INNER JOIN
							Org.tbAccount ON Cash.vwAccountRebuild.CashAccountCode = Org.tbAccount.CashAccountCode;
	
		UPDATE Org.tbAccount
		SET CurrentBalance = Org.tbAccount.OpeningBalance
		FROM         Cash.vwAccountRebuild RIGHT OUTER JOIN
							  Org.tbAccount ON Cash.vwAccountRebuild.CashAccountCode = Org.tbAccount.CashAccountCode
		WHERE     (Cash.vwAccountRebuild.CashAccountCode IS NULL);

		EXEC Cash.proc_GeneratePeriods;
	            
		COMMIT TRANSACTION

		DECLARE @Msg NVARCHAR(MAX);
		SELECT @Msg = Message FROM App.tbText WHERE TextId = 3006;
		EXEC App.proc_EventLog @EventMessage = @Msg, @EventTypeCode = 2;

  	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
go
ALTER PROCEDURE Cash.proc_PaymentPostInvoiced (@PaymentCode nvarchar(20))
AS
	SET NOCOUNT, XACT_ABORT ON;

	BEGIN TRY
		DECLARE 
			@AccountCode nvarchar(10)
			, @PostValue decimal(18, 5)
			, @CashCode nvarchar(50);

		SELECT   @PostValue = CASE WHEN PaidInValue = 0 THEN PaidOutValue ELSE PaidInValue * -1 END,
			@AccountCode = Org.tbOrg.AccountCode
		FROM         Cash.tbPayment INNER JOIN
							  Org.tbOrg ON Cash.tbPayment.AccountCode = Org.tbOrg.AccountCode
		WHERE     ( Cash.tbPayment.PaymentCode = @PaymentCode);

		IF NOT EXISTS (SELECT InvoiceNumber FROM Invoice.tbInvoice WHERE (InvoiceStatusCode = 1) AND (AccountCode = @AccountCode))
			RETURN;

		IF EXISTS (SELECT * FROM  Invoice.tbInvoice 
						INNER JOIN Invoice.tbTask ON Invoice.tbInvoice.InvoiceNumber = Invoice.tbTask.InvoiceNumber
					WHERE        (Invoice.tbInvoice.AccountCode = @AccountCode) AND (Invoice.tbInvoice.InvoiceStatusCode < 3))
		BEGIN
			SELECT  @CashCode = Invoice.tbTask.CashCode
			FROM  Invoice.tbInvoice 
				INNER JOIN Invoice.tbTask ON Invoice.tbInvoice.InvoiceNumber = Invoice.tbTask.InvoiceNumber
			WHERE        (Invoice.tbInvoice.AccountCode = @AccountCode) AND (Invoice.tbInvoice.InvoiceStatusCode < 3)
			GROUP BY Invoice.tbTask.CashCode;
		END
		ELSE IF EXISTS (SELECT * FROM Invoice.tbInvoice 
							INNER JOIN Invoice.tbItem ON Invoice.tbInvoice.InvoiceNumber = Invoice.tbItem.InvoiceNumber
						WHERE        (Invoice.tbInvoice.AccountCode = @AccountCode) AND (Invoice.tbInvoice.InvoiceStatusCode < 3)
						GROUP BY Invoice.tbItem.CashCode)
		BEGIN
			SELECT @CashCode = Invoice.tbItem.CashCode
			FROM  Invoice.tbInvoice 
				INNER JOIN Invoice.tbItem ON Invoice.tbInvoice.InvoiceNumber = Invoice.tbItem.InvoiceNumber
			WHERE        (Invoice.tbInvoice.AccountCode = @AccountCode) AND (Invoice.tbInvoice.InvoiceStatusCode < 3)
			GROUP BY Invoice.tbItem.CashCode;
		END

		BEGIN TRANSACTION;

		UPDATE Cash.tbPayment
		SET PaymentStatusCode = 1, CashCode = @CashCode
		WHERE (PaymentCode = @PaymentCode);
		
		WITH invoice_status AS
		(
			SELECT InvoiceNumber, InvoiceStatusCode, PaidValue, PaidTaxValue
			FROM Invoice.vwStatusLive
			WHERE AccountCode = @AccountCode
		)
		UPDATE invoices
		SET 
			InvoiceStatusCode = invoice_status.InvoiceStatusCode,
			PaidValue = invoice_status.PaidValue,
			PaidTaxValue = invoice_status.PaidTaxValue
		FROM Invoice.tbInvoice invoices	
			JOIN invoice_status ON invoices.InvoiceNumber = invoice_status.InvoiceNumber
		WHERE 
			invoices.InvoiceStatusCode <> invoice_status.InvoiceStatusCode 
			OR invoices.PaidValue <> invoice_status.PaidValue 
			OR invoices.PaidTaxValue <> invoice_status.PaidTaxValue;

		UPDATE  Org.tbAccount
		SET CurrentBalance = Org.tbAccount.CurrentBalance + (@PostValue * -1)
		FROM         Org.tbAccount INNER JOIN
							  Cash.tbPayment ON Org.tbAccount.CashAccountCode = Cash.tbPayment.CashAccountCode
		WHERE Cash.tbPayment.PaymentCode = @PaymentCode
		
		COMMIT TRANSACTION

  	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
go
CREATE OR ALTER VIEW Invoice.vwAccountsMode
AS
	SELECT Invoice.tbInvoice.InvoiceNumber, Invoice.tbInvoice.UserId, Invoice.tbInvoice.AccountCode, Invoice.tbInvoice.InvoiceTypeCode, Invoice.tbInvoice.InvoiceStatusCode, Invoice.tbInvoice.InvoicedOn, Invoice.tbInvoice.Notes, 
		   Invoice.tbItem.CashCode, Invoice.tbItem.TaxCode, Invoice.tbItem.ItemReference, Invoice.tbInvoice.RowVer AS InvoiceRowVer, Invoice.tbItem.RowVer AS ItemRowVer, Invoice.tbItem.TotalValue, Invoice.tbItem.InvoiceValue, Invoice.tbInvoice.PaidValue, Invoice.tbInvoice.PaidTaxValue
	FROM Invoice.tbInvoice 
		INNER JOIN Invoice.tbItem ON Invoice.tbInvoice.InvoiceNumber = Invoice.tbItem.InvoiceNumber;
go
CREATE TABLE Invoice.tbEntry (
    UserId NVARCHAR (10) NOT NULL,
    AccountCode NVARCHAR (10) NOT NULL,
	CashCode nvarchar(50) NOT NULL,
    InvoiceTypeCode SMALLINT NOT NULL,
    InvoicedOn DATETIME CONSTRAINT DF_Invoice_tbEntry_InvoicedOn DEFAULT (CONVERT(date,getdate())) NOT NULL,
    TaxCode NVARCHAR (10) NULL,
    ItemReference NTEXT NULL,
    TotalValue DECIMAL (18, 5) CONSTRAINT DF_Invoice_tbEntry_TotalValue DEFAULT ((0)) NOT NULL,
    InvoiceValue DECIMAL (18, 5) CONSTRAINT DF_Invoice_tbEntry_InvoiceValue DEFAULT ((0)) NOT NULL,
    RowVer ROWVERSION NOT NULL,
    CONSTRAINT PK_Invoice_tbEntry PRIMARY KEY CLUSTERED (AccountCode ASC, CashCode ASC) WITH (FILLFACTOR = 90),
    CONSTRAINT FK_Invoice_tbEntry_App_tbTaxCode FOREIGN KEY (TaxCode) REFERENCES App.tbTaxCode (TaxCode),
    CONSTRAINT FK_Invoice_tbEntry_Cash_tbCode FOREIGN KEY (CashCode) REFERENCES Cash.tbCode (CashCode) ON UPDATE CASCADE,
    CONSTRAINT FK_Invoice_tbEntry_Invoice_tbType FOREIGN KEY (InvoiceTypeCode) REFERENCES Invoice.tbType (InvoiceTypeCode),
    CONSTRAINT FK_Invoice_tbEntry_Org_tb FOREIGN KEY (AccountCode) REFERENCES Org.tbOrg (AccountCode),
    CONSTRAINT FK_Invoice_tbEntry_Usr_tb FOREIGN KEY (UserId) REFERENCES Usr.tbUser (UserId) ON UPDATE CASCADE
);
go
CREATE INDEX IX_Invoice_tbEntry_UserId ON Invoice.tbEntry (UserId);
go
ALTER PROCEDURE Org.proc_DefaultTaxCode 
	(
	@AccountCode nvarchar(10),
	@TaxCode nvarchar(10) OUTPUT
	)
  AS
   	SET NOCOUNT, XACT_ABORT ON;

	BEGIN TRY

		IF EXISTS (SELECT * FROM Org.tbOrg o JOIN App.tbTaxCode t ON o.TaxCode = t.TaxCode WHERE AccountCode = @AccountCode)
			SELECT @TaxCode = TaxCode FROM Org.tbOrg WHERE AccountCode = @AccountCode
		ELSE IF EXISTS(SELECT * FROM  Org.tbOrg JOIN App.tbOptions ON Org.tbOrg.AccountCode = App.tbOptions.AccountCode)
			SELECT @TaxCode = Org.tbOrg.TaxCode FROM  Org.tbOrg JOIN App.tbOptions ON Org.tbOrg.AccountCode = App.tbOptions.AccountCode		
		ELSE
			SET @TaxCode = ''

  	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
go
CREATE OR ALTER PROCEDURE Invoice.proc_PostEntries
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
go
ALTER VIEW Cash.vwPayments
AS
	SELECT        Cash.tbPayment.AccountCode, Cash.tbPayment.PaymentCode, Cash.tbPayment.UserId, Cash.tbPayment.PaymentStatusCode, Cash.tbPayment.CashAccountCode, Cash.tbPayment.CashCode, Cash.tbPayment.TaxCode, 
							 Cash.tbPayment.PaidOn, Cash.tbPayment.PaidInValue, Cash.tbPayment.PaidOutValue, Cash.tbPayment.PaymentReference, Cash.tbPayment.InsertedBy, Cash.tbPayment.InsertedOn, Cash.tbPayment.UpdatedBy, 
							 Cash.tbPayment.UpdatedOn, Usr.tbUser.UserName, App.tbTaxCode.TaxDescription, Org.tbAccount.CashAccountName, Cash.tbCode.CashDescription
	FROM            Cash.tbPayment INNER JOIN
							 Usr.tbUser ON Cash.tbPayment.UserId = Usr.tbUser.UserId INNER JOIN
							 Org.tbAccount ON Cash.tbPayment.CashAccountCode = Org.tbAccount.CashAccountCode LEFT OUTER JOIN
							 Cash.tbCode ON Cash.tbPayment.CashCode = Cash.tbCode.CashCode LEFT OUTER JOIN
							 App.tbTaxCode ON Cash.tbPayment.TaxCode = App.tbTaxCode.TaxCode
	WHERE        (Cash.tbPayment.PaymentStatusCode = 1);
go
ALTER PROCEDURE App.proc_BasicSetup
(	
	@FinancialMonth SMALLINT = 4,
	@CoinTypeCode SMALLINT,
	@GovAccountName NVARCHAR(255),
	@BankName NVARCHAR(255),
	@BankAddress NVARCHAR(MAX),
	@DummyAccount NVARCHAR(50), 
	@CurrentAccount NVARCHAR(50),
	@CA_SortCode NVARCHAR(10),
	@CA_AccountNumber NVARCHAR(20),
	@ReserveAccount NVARCHAR(50), 
	@RA_SortCode NVARCHAR(10),
	@RA_AccountNumber NVARCHAR(20)
)
AS
DECLARE 
	@FinancialYear SMALLINT = DATEPART(YEAR, CURRENT_TIMESTAMP);

	IF EXISTS (SELECT * FROM App.tbOptions WHERE UnitOfCharge <> 'BTC') AND (@CoinTypeCode <> 2)
		SET @CoinTypeCode = 2;

	IF DATEPART(MONTH, CURRENT_TIMESTAMP) < @FinancialMonth
		 SET @FinancialYear -= 1;

	DECLARE 
		@AccountCode NVARCHAR(10),
		@CashAccountCode NVARCHAR(10),
		@Year SMALLINT = @FinancialYear - 1;

	SET NOCOUNT, XACT_ABORT ON;


	BEGIN TRY
		BEGIN TRAN
		INSERT INTO [App].[tbBucket] ([Period], [BucketId], [BucketDescription], [AllowForecasts])
		VALUES (0, 'Overdue', 'Overdue Orders', 0)
		, (1, 'Current', 'Current Week', 0)
		, (2, 'Week 2', 'Week Two', 0)
		, (3, 'Week 3', 'Week Three', 0)
		, (4, 'Week 4', 'Week Four', 0)
		, (8, 'Next Month', 'Next Month', 0)
		, (16, '2 Months', '2 Months', 1)
		, (52, 'Forward', 'Forward Orders', 1)
		;
		INSERT INTO [App].[tbUom] ([UnitOfMeasure])
		VALUES ('copies')
		, ('days')
		, ('each')
		, ('hrs')
		, ('kilo')
		, ('miles')
		, ('mins')
		, ('pallets')
		, ('units')
		;

		DECLARE @Decimals smallint = CASE @CoinTypeCode WHEN 2 THEN 2 ELSE 3 END

		INSERT INTO [App].[tbTaxCode] ([TaxCode], [TaxRate], [TaxDescription], [TaxTypeCode], [RoundingCode], [Decimals])
		VALUES ('INT', 0, 'Interest Tax', 3, 0, @Decimals)
		, ('N/A', 0, 'Untaxed', 3, 0, @Decimals)
		, ('NI1', 0, 'Directors National Insurance', 2, 0, @Decimals)
		, ('NI2', 0.121, 'Employees National Insurance', 2, 0, @Decimals)
		, ('T0', 0, 'Zero Rated VAT', 1, 0, @Decimals)
		, ('T1', 0.2, 'Standard VAT Rate', 1, 0, @Decimals)
		, ('T9', 0, 'TBC', 1, 0, @Decimals)
		;

		INSERT INTO [Cash].[tbCategory] ([CategoryCode], [Category], [CategoryTypeCode], [CashModeCode], [CashTypeCode], [DisplayOrder], [IsEnabled])
		VALUES ('AS', 'Assets', 0, 1, 2, 70, 1)
		, ('BA', 'Bank Accounts', 0, 2, 2, 80, 1)
		, ('BP', 'Bank Payments', 0, 0, 0, 90, 1)
		, ('BR', 'Bank Receipts', 0, 1, 0, 100, 1)
		, ('DC', 'Direct Cost', 0, 0, 0, 20, 1)
		, ('DI', 'Dividends', 0, 0, 0, 110, -1)
		, ('DR', 'Drawings', 0, 2, 0, 150, 0)
		, ('IC', 'Indirect Cost', 0, 0, 0, 30, 1)
		, ('IP', 'Intercompany Payment', 0, 0, 2, 120, 1)
		, ('IR', 'Intercompany Receipt', 0, 1, 2, 130, 1)
		, ('IV', 'Investment', 0, 2, 0, 160, 1)
		, ('LI', 'Liabilities', 0, 0, 2, 71, 1)
		, ('SA', 'Sales', 0, 1, 0, 10, 1)
		, ('TA', 'Taxes', 0, 0, 1, 60, 1)
		, ('WA', 'Wages', 0, 0, 0, 50, 1)
		;

		INSERT INTO [Cash].[tbCategory] ([CategoryCode], [Category], [CategoryTypeCode], [CashModeCode], [CashTypeCode], [DisplayOrder], [IsEnabled])
		VALUES 
			('AL', 'Assets and Liabilities', 1, 2, 0, 2, 1)
			, ('EX', 'Expenses', 1, 2, 0, 1, 1)
			, ('FY', 'Profit/Loss for Financial Year', 1, 2, 0, 5, 1)
			, ('GP', 'Gross Profit', 1, 2, 0, 10, 1)
			, ('NP', 'Net Profit', 1, 2, 0, 20, 1)
			, ('PL', 'Profit/Loss Before Taxation', 1, 2, 0, 3, 1)
			, ('TO', 'Turnover', 1, 2, 0, 0, 1)
			, ('TOPL', 'Tax on Profit/Loss', 1, 2, 0, 4, 1)
			, ('VAT', 'Vat Cash Codes', 1, 2, 0, 100, 1)
			, ('WR', 'Wages Ratio', 2, 2, 0, 0, 1)
			, ('GM', 'Gross Margin', 2, 2, 0, 1, 1)
			;

		INSERT INTO [Cash].[tbCategoryTotal] ([ParentCode], [ChildCode])
		VALUES ('EX', 'BP')
		, ('EX', 'DC')
		, ('EX', 'IC')
		, ('EX', 'WA')
		, ('FY', 'PL')
		, ('FY', 'TOPL')
		, ('GP', 'DC')
		, ('GP', 'SA')
		, ('GP', 'WA')
		, ('NP', 'BP')
		, ('NP', 'BR')
		, ('NP', 'GP')
		, ('NP', 'IC')
		, ('NP', 'TA')
		, ('NP', 'AL')
		, ('PL', 'EX')
		, ('PL', 'TO')
		, ('PL', 'AL')
		, ('TO', 'BR')
		, ('TO', 'SA')
		, ('TOPL', 'TA')
		, ('VAT', 'DC')
		, ('VAT', 'IC')
		, ('VAT', 'SA')
		, ('AL', 'AS')
		, ('AL', 'LI')
		;

		INSERT INTO [Cash].[tbCategoryExp] ([CategoryCode], [Expression], [Format])
		VALUES ('WR', 'IF([Sales]=0,0,(ABS([Wages])/[Sales]))', '0%')
		, ('GM', 'IF([Sales]=0,0,([Gross Profit]/[Sales]))', '0%')
		;

		INSERT INTO [Cash].[tbCode] ([CashCode], [CashDescription], [CategoryCode], [TaxCode], [IsEnabled])
		VALUES ('101', 'Sales - Carriage', 'SA', 'T1', 1)
		, ('102', 'Sales - Export', 'SA', 'T1', 1)
		, ('103', 'Sales - Home', 'SA', 'T1', 1)
		, ('104', 'Sales - Consultancy', 'SA', 'T1', 1)
		, ('200', 'Direct Purchase', 'DC', 'T1', 1)
		, ('201', 'Company Administration', 'IC', 'T1', 1)
		, ('202', 'Communications', 'IC', 'T1', 1)
		, ('203', 'Entertaining', 'IC', 'N/A', 1)
		, ('204', 'Office Equipment', 'IC', 'T1', 1)
		, ('205', 'Office Rent', 'IC', 'T0', 1)
		, ('206', 'Professional Fees', 'IC', 'T1', 1)
		, ('207', 'Postage', 'IC', 'T1', 1)
		, ('208', 'Sundry', 'IC', 'T1', 1)
		, ('209', 'Stationery', 'IC', 'T1', 1)
		, ('210', 'Subcontracting', 'IC', 'T1', 1)
		, ('211', 'Systems', 'IC', 'T9', 1)
		, ('212', 'Travel - Car Mileage', 'IC', 'N/A', 1)
		, ('213', 'Travel - General', 'IC', 'N/A', 1)
		, ('214', 'Company Loan', 'IV', 'N/A', 1)
		, ('215', 'Directors Loan', 'IV', 'N/A', 1)
		, ('216', 'Directors Expenses reimbursement', 'IC', 'N/A', 1)
		, ('217', 'Office Expenses (General)', 'IC', 'N/A', 1)
		, ('218', 'Subsistence', 'IC', 'N/A', 1)
		, ('250', 'Commission', 'DC', 'T1', 1)
		, ('301', 'Company Cash', 'BA', 'N/A', 1)
		, ('302', 'Bank Charges', 'BP', 'N/A', 1)
		, ('303', 'Account Payment', 'IP', 'N/A', 1)
		, ('304', 'Bank Interest', 'BR', 'N/A', 1)
		, ('305', 'Transfer Receipt', 'IR', 'N/A', 1)
		, ('401', 'Dividends', 'DI', 'N/A', -1)
		, ('402', 'Salaries', 'WA', 'NI1', 1)
		, ('403', 'Pensions', 'WA', 'N/A', 1)
		, ('501', 'Charitable Donation', 'IC', 'N/A', 1)
		, ('601', 'VAT', 'TA', 'N/A', 1)
		, ('602', 'Taxes (General)', 'TA', 'N/A', 1)
		, ('603', 'Taxes (Corporation)', 'TA', 'N/A', 1)
		, ('604', 'Employers NI', 'TA', 'N/A', 1)
		, ('700', 'Stock Movement', 'AS', 'N/A', 0)
		, ('701', 'Depreciation', 'AS', 'N/A', 1)
		, ('702', 'Dept Repayment', 'LI', 'N/A', 1)
		;

		IF @CoinTypeCode < 2
		BEGIN
			INSERT INTO [Cash].[tbCode] ([CashCode], [CashDescription], [CategoryCode], [TaxCode], [IsEnabled])
			VALUES ('219', 'Miner Fees', 'IC', 'N/A', 1);
		
			UPDATE App.tbOptions
			SET MinerFeeCode = '219';
		END

		--ASSIGN NET PROFIT CALCULATION
		UPDATE App.tbOptions
		SET NetProfitCode = 'NP', VatCategoryCode = 'VAT';

		--SET HOME TAX CODE
		UPDATE Org.tbOrg
		SET TaxCode = 'T1'
		WHERE AccountCode = (SELECT AccountCode FROM App.tbOptions)

		--CREATE GOV
		EXEC Org.proc_DefaultAccountCode @AccountName = @GovAccountName, @AccountCode = @AccountCode OUTPUT
		INSERT INTO Org.tbOrg (AccountCode, AccountName, OrganisationStatusCode, OrganisationTypeCode, TaxCode)
			VALUES (@AccountCode, @GovAccountName, 1, 7, 'N/A');

		--BANK ACCOUNTS / WALLETS

		IF @CoinTypeCode = 2
		BEGIN
			--fiat
			EXEC Org.proc_DefaultAccountCode @AccountName = @BankName, @AccountCode = @AccountCode OUTPUT	
			INSERT INTO Org.tbOrg (AccountCode, AccountName, OrganisationStatusCode, OrganisationTypeCode, TaxCode)
			VALUES (@AccountCode, @BankName, 1, 5, 'T0');

			EXEC Org.proc_AddAddress @AccountCode = @AccountCode, @Address = @BankAddress;
		END
		ELSE
		BEGIN
			--crypto
			EXEC Org.proc_DefaultAccountCode @AccountName = 'BITCOIN MINER', @AccountCode = @AccountCode OUTPUT
			INSERT INTO Org.tbOrg (AccountCode, AccountName, OrganisationStatusCode, OrganisationTypeCode, TaxCode)
			VALUES (@AccountCode, 'BITCOIN MINER', 1, 7, 'N/A');

			UPDATE App.tbOptions
			SET MinerAccountCode = @AccountCode;

			SELECT @AccountCode = AccountCode FROM App.tbOptions 
		END

		EXEC Org.proc_DefaultAccountCode @AccountName = @CurrentAccount, @AccountCode = @CashAccountCode OUTPUT
		INSERT INTO Org.tbAccount (CashAccountCode, AccountCode, CashAccountName, OpeningBalance, SortCode, AccountNumber, CashCode)
		VALUES        (@CashAccountCode, @AccountCode, @CurrentAccount, 0, @CA_SortCode, @CA_AccountNumber, '301')

		IF (LEN(@ReserveAccount) > 0)
		BEGIN
			EXEC Org.proc_DefaultAccountCode @AccountName = @ReserveAccount, @AccountCode = @CashAccountCode OUTPUT
			INSERT INTO Org.tbAccount (CashAccountCode, AccountCode, CashAccountName, OpeningBalance, SortCode, AccountNumber)
			VALUES        (@CashAccountCode, @AccountCode, @ReserveAccount, 0, @RA_SortCode, @RA_AccountNumber)
		END

		SELECT @AccountCode = (SELECT AccountCode FROM App.tbOptions)

		IF (LEN(@DummyAccount) > 0)
		BEGIN
			EXEC Org.proc_DefaultAccountCode @AccountName = @DummyAccount, @AccountCode = @CashAccountCode OUTPUT
			INSERT INTO Org.tbAccount (CashAccountCode, AccountCode, CashAccountName, AccountTypeCode)
			VALUES        (@CashAccountCode, @AccountCode, @DummyAccount, 1)
		END

		--capital 
		DECLARE @CapitalAccount NVARCHAR(50);

		SET @CapitalAccount = 'PREMISES';
		EXEC Org.proc_DefaultAccountCode @AccountName = @CapitalAccount, @AccountCode = @CashAccountCode OUTPUT
		INSERT INTO Org.tbAccount (CashAccountCode, AccountCode, CashAccountName, AccountTypeCode, LiquidityLevel, CashCode, AccountClosed)
		VALUES        (@CashAccountCode, @AccountCode, @CapitalAccount, 2, 50, '701', 1)

		SET @CapitalAccount = 'FIXTURES AND FITTINGS';
		EXEC Org.proc_DefaultAccountCode @AccountName = @CapitalAccount, @AccountCode = @CashAccountCode OUTPUT
		INSERT INTO Org.tbAccount (CashAccountCode, AccountCode, CashAccountName, AccountTypeCode, LiquidityLevel, CashCode, AccountClosed)
		VALUES        (@CashAccountCode, @AccountCode, @CapitalAccount, 2, 40, '701', 1)

		SET @CapitalAccount = 'PLANT AND MACHINERY';
		EXEC Org.proc_DefaultAccountCode @AccountName = @CapitalAccount, @AccountCode = @CashAccountCode OUTPUT
		INSERT INTO Org.tbAccount (CashAccountCode, AccountCode, CashAccountName, AccountTypeCode, LiquidityLevel, CashCode, AccountClosed)
		VALUES        (@CashAccountCode, @AccountCode, @CapitalAccount, 2, 30, '701', 1)

		SET @CapitalAccount = 'VEHICLES';
		EXEC Org.proc_DefaultAccountCode @AccountName = @CapitalAccount, @AccountCode = @CashAccountCode OUTPUT
		INSERT INTO Org.tbAccount (CashAccountCode, AccountCode, CashAccountName, AccountTypeCode, LiquidityLevel, CashCode, AccountClosed)
		VALUES        (@CashAccountCode, @AccountCode, @CapitalAccount, 2, 20, '701', 1)

		SET @CapitalAccount = 'STOCK';
		EXEC Org.proc_DefaultAccountCode @AccountName = @CapitalAccount, @AccountCode = @CashAccountCode OUTPUT
		INSERT INTO Org.tbAccount (CashAccountCode, AccountCode, CashAccountName, AccountTypeCode, LiquidityLevel, CashCode, AccountClosed)
		VALUES        (@CashAccountCode, @AccountCode, @CapitalAccount, 2, 10, '700', 1)

		SET @CapitalAccount = 'LONGTERM LIABILITIES';
		EXEC Org.proc_DefaultAccountCode @AccountName = @CapitalAccount, @AccountCode = @CashAccountCode OUTPUT
		INSERT INTO Org.tbAccount (CashAccountCode, AccountCode, CashAccountName, AccountTypeCode, LiquidityLevel, CashCode, AccountClosed)
		VALUES        (@CashAccountCode, @AccountCode, @CapitalAccount, 2, 50, '702', 0)

		UPDATE App.tbOptions
		SET CoinTypeCode = @CoinTypeCode;

		--TIME PERIODS
		WHILE (@Year < DATEPART(YEAR, CURRENT_TIMESTAMP) + 2)
		BEGIN
		
			INSERT INTO App.tbYear (YearNumber, StartMonth, CashStatusCode, Description)
			VALUES (@Year, @FinancialMonth, 0, 
						CASE WHEN @FinancialMonth > 1 THEN CONCAT(@Year, '-', @Year - ROUND(@Year, -2) + 1) ELSE CONCAT(@Year, '.') END
					);
			SET @Year += 1;
		END

		EXEC Cash.proc_GeneratePeriods;

		UPDATE App.tbYearPeriod
		SET CorporationTaxRate = 0.2;

		UPDATE App.tbYearPeriod
		SET CashStatusCode = 2
		WHERE StartOn < DATEADD(MONTH, -1, CURRENT_TIMESTAMP)

		IF EXISTS(SELECT * FROM App.tbYearPeriod WHERE CashStatusCode = 3)
			WITH current_month AS
			(
				SELECT MAX(StartOn) AS StartOn
				FROM App.tbYearPeriod
				WHERE CashStatusCode = 2
			)
			UPDATE App.tbYearPeriod
			SET CashStatusCode = 1
			FROM App.tbYearPeriod JOIN current_month ON App.tbYearPeriod.StartOn = current_month.StartOn;	
		ELSE
			WITH current_month AS
			(
				SELECT MIN(StartOn) AS StartOn
				FROM App.tbYearPeriod
				WHERE CashStatusCode = 0
			)
			UPDATE App.tbYearPeriod
			SET CashStatusCode = 1
			FROM App.tbYearPeriod JOIN current_month ON App.tbYearPeriod.StartOn = current_month.StartOn;
	
	
		WITH current_month AS
		(
			SELECT YearNumber
			FROM App.tbYearPeriod
			WHERE CashStatusCode = 1
		)
		UPDATE App.tbYear
		SET CashStatusCode = 1
		FROM App.tbYear JOIN current_month ON App.tbYear.YearNumber = current_month.YearNumber;

		UPDATE App.tbYear
		SET CashStatusCode = 2
		WHERE YearNumber < 	(SELECT YearNumber FROM App.tbYear	WHERE CashStatusCode = 1);

		--ASSIGN CASH CODES AND GOV TO TAX TYPES
		UPDATE Cash.tbTaxType
		SET AccountCode = @AccountCode, CashCode = '603', MonthNumber = @FinancialMonth
		WHERE TaxTypeCode = 0;

		UPDATE Cash.tbTaxType
		SET AccountCode = @AccountCode, CashCode = '601', MonthNumber = @FinancialMonth
		WHERE TaxTypeCode = 1;

		UPDATE Cash.tbTaxType
		SET AccountCode = @AccountCode, CashCode = '604', MonthNumber = @FinancialMonth
		WHERE TaxTypeCode = 2;

		UPDATE Cash.tbTaxType
		SET AccountCode = @AccountCode, CashCode = '602', MonthNumber = @FinancialMonth
		WHERE TaxTypeCode = 3;
		COMMIT TRAN
	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog
	END CATCH
go

