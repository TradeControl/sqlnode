CREATE PROCEDURE App.proc_SystemRebuild
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

		--CASH FLOW Initialize all
		EXEC Cash.proc_GeneratePeriods;

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
            

		COMMIT TRANSACTION

		DECLARE @Msg NVARCHAR(MAX);
		SELECT @Msg = Message FROM App.tbText WHERE TextId = 3006;
		EXEC App.proc_EventLog @EventMessage = @Msg, @EventTypeCode = 2;

  	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
