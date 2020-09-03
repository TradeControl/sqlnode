CREATE PROCEDURE App.proc_SystemRebuild
AS
  	SET NOCOUNT, XACT_ABORT ON;

	DECLARE @tbPartialInvoice TABLE (
			AccountCode NVARCHAR(10), 
			InvoiceNumber NVARCHAR(10),
			RefType SMALLINT,
			RefCode NVARCHAR(20),
			TotalPaidValue MONEY
			);

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

		UPDATE Cash.tbPayment
		SET
			TaxInValue = PaidInValue - CASE App.tbTaxCode.RoundingCode 
				WHEN 0 THEN ROUND((PaidInValue / (1 + TaxRate)), 2)
				WHEN 1 THEN ROUND((PaidInValue / (1 + TaxRate)), 2, 1) END, 
			TaxOutValue = PaidOutValue - CASE App.tbTaxCode.RoundingCode 
				WHEN 0 THEN ROUND((PaidOutValue / (1 + TaxRate)), 2)
				WHEN 1 THEN ROUND((PaidOutValue / (1 + TaxRate)), 2, 1) END
		FROM         Cash.tbPayment INNER JOIN
								App.tbTaxCode ON Cash.tbPayment.TaxCode = App.tbTaxCode.TaxCode;

		--Invoice Items									
		UPDATE Invoice.tbItem
		SET InvoiceValue =  ROUND(Invoice.tbItem.TotalValue / (1 + App.tbTaxCode.TaxRate), 2),
			TaxValue = TotalValue - ROUND(Invoice.tbItem.TotalValue / (1 + App.tbTaxCode.TaxRate), 2)
		FROM         Invoice.tbItem INNER JOIN
								App.tbTaxCode ON Invoice.tbItem.TaxCode = App.tbTaxCode.TaxCode INNER JOIN
								Invoice.tbInvoice ON Invoice.tbItem.InvoiceNumber = Invoice.tbInvoice.InvoiceNumber
		WHERE     ( Invoice.tbInvoice.InvoiceStatusCode <> 0) AND Invoice.tbItem.TotalValue <> 0;

		UPDATE Invoice.tbItem
		SET TaxValue = CASE App.tbTaxCode.RoundingCode 
				WHEN 0 THEN ROUND(Invoice.tbItem.InvoiceValue * App.tbTaxCode.TaxRate, 2)
				WHEN 1 THEN ROUND( Invoice.tbItem.InvoiceValue * App.tbTaxCode.TaxRate, 2, 1) END,
			InvoiceValue = CASE WHEN Invoice.tbItem.TotalValue = 0 THEN Invoice.tbItem.InvoiceValue ELSE ROUND(Invoice.tbItem.TotalValue / (1 + App.tbTaxCode.TaxRate), 2) END
		FROM         Invoice.tbItem INNER JOIN
								App.tbTaxCode ON Invoice.tbItem.TaxCode = App.tbTaxCode.TaxCode 
								INNER JOIN Invoice.tbInvoice ON Invoice.tbItem.InvoiceNumber = Invoice.tbInvoice.InvoiceNumber
		WHERE     ( Invoice.tbInvoice.InvoiceStatusCode <> 0) AND Invoice.tbItem.TotalValue = 0;

		WITH accounts_paid AS
		(
			SELECT AccountCode
			FROM Cash.tbPayment
			GROUP BY AccountCode
		)
		UPDATE Invoice.tbItem
		SET PaidValue = Invoice.tbItem.InvoiceValue,
			PaidTaxValue = Invoice.tbItem.TaxValue
		FROM Invoice.tbItem 
			JOIN Invoice.tbInvoice ON Invoice.tbItem.InvoiceNumber = Invoice.tbInvoice.InvoiceNumber
			JOIN accounts_paid ON Invoice.tbInvoice.AccountCode = accounts_paid.AccountCode 
		WHERE     ( Invoice.tbInvoice.InvoiceStatusCode <> 0);

		WITH accounts_paid AS
		(
			SELECT AccountCode
			FROM Cash.tbPayment
			GROUP BY AccountCode
		)
		UPDATE Invoice.tbItem
		SET PaidValue = 0,
			PaidTaxValue = 0
		FROM Invoice.tbItem 
			JOIN Invoice.tbInvoice ON Invoice.tbItem.InvoiceNumber = Invoice.tbInvoice.InvoiceNumber
			LEFT OUTER JOIN accounts_paid ON Invoice.tbInvoice.AccountCode = accounts_paid.AccountCode 
		WHERE (Invoice.tbInvoice.InvoiceStatusCode <> 0)
			AND (accounts_paid.AccountCode IS NULL);
                   
		UPDATE Invoice.tbTask
		SET InvoiceValue =  ROUND(Invoice.tbTask.TotalValue / (1 + App.tbTaxCode.TaxRate), 2),
			TaxValue = TotalValue - ROUND(Invoice.tbTask.TotalValue / (1 + App.tbTaxCode.TaxRate), 2)
		FROM         Invoice.tbTask INNER JOIN
								App.tbTaxCode ON Invoice.tbTask.TaxCode = App.tbTaxCode.TaxCode INNER JOIN
								Invoice.tbInvoice ON Invoice.tbTask.InvoiceNumber = Invoice.tbInvoice.InvoiceNumber
		WHERE     ( Invoice.tbInvoice.InvoiceStatusCode <> 0) AND Invoice.tbTask.TotalValue <> 0;

		UPDATE Invoice.tbTask
		SET TaxValue = CASE App.tbTaxCode.RoundingCode 
				WHEN 0 THEN ROUND(Invoice.tbTask.InvoiceValue * App.tbTaxCode.TaxRate, 2)
				WHEN 1 THEN ROUND( Invoice.tbTask.InvoiceValue * App.tbTaxCode.TaxRate, 2, 1) END,
			InvoiceValue = CASE WHEN Invoice.tbTask.TotalValue = 0 THEN Invoice.tbTask.InvoiceValue ELSE ROUND(Invoice.tbTask.TotalValue / (1 + App.tbTaxCode.TaxRate), 2) END
		FROM         Invoice.tbTask INNER JOIN
								App.tbTaxCode ON Invoice.tbTask.TaxCode = App.tbTaxCode.TaxCode 
								INNER JOIN Invoice.tbInvoice ON Invoice.tbTask.InvoiceNumber = Invoice.tbInvoice.InvoiceNumber
		WHERE     ( Invoice.tbInvoice.InvoiceStatusCode <> 0) AND Invoice.tbTask.TotalValue = 0;

		WITH accounts_paid AS
		(
			SELECT AccountCode
			FROM Cash.tbPayment
			GROUP BY AccountCode
		)
		UPDATE Invoice.tbTask
		SET PaidValue = Invoice.tbTask.InvoiceValue,
			PaidTaxValue = Invoice.tbTask.TaxValue
		FROM Invoice.tbTask 
			JOIN Invoice.tbInvoice ON Invoice.tbTask.InvoiceNumber = Invoice.tbInvoice.InvoiceNumber
			JOIN accounts_paid ON Invoice.tbInvoice.AccountCode = accounts_paid.AccountCode 
		WHERE ( Invoice.tbInvoice.InvoiceStatusCode <> 0);
				
		WITH accounts_paid AS
		(
			SELECT AccountCode
			FROM Cash.tbPayment
			GROUP BY AccountCode
		)
		UPDATE Invoice.tbTask
		SET PaidValue = 0,
			PaidTaxValue = 0
		FROM Invoice.tbTask 
			JOIN Invoice.tbInvoice ON Invoice.tbTask.InvoiceNumber = Invoice.tbInvoice.InvoiceNumber
			LEFT OUTER JOIN accounts_paid ON Invoice.tbInvoice.AccountCode = accounts_paid.AccountCode 
		WHERE (Invoice.tbInvoice.InvoiceStatusCode <> 0)
			AND (accounts_paid.AccountCode IS NULL);				
				   	
		UPDATE Invoice.tbInvoice
		SET InvoiceValue = 0, TaxValue = 0, PaidValue = 0, PaidTaxValue = 0, InvoiceStatusCode = 1
		WHERE     ( Invoice.tbInvoice.InvoiceStatusCode <> 0);
	
		WITH items AS
		(
			SELECT     Invoice.tbInvoice.InvoiceNumber, SUM( Invoice.tbItem.InvoiceValue) AS TotalInvoiceValue, SUM( Invoice.tbItem.TaxValue) AS TotalTaxValue
			FROM         Invoice.tbItem INNER JOIN
								Invoice.tbInvoice ON Invoice.tbItem.InvoiceNumber = Invoice.tbInvoice.InvoiceNumber
			WHERE     ( Invoice.tbInvoice.InvoiceStatusCode <> 0)
			GROUP BY Invoice.tbItem.InvoiceNumber, Invoice.tbInvoice.InvoiceNumber
		)
		UPDATE Invoice.tbInvoice
		SET InvoiceValue = items.TotalInvoiceValue, 
			TaxValue = items.TotalTaxValue
		FROM         Invoice.tbInvoice INNER JOIN items 
								ON Invoice.tbInvoice.InvoiceNumber = items.InvoiceNumber;

		WITH tasks AS
		(
			SELECT     Invoice.tbInvoice.InvoiceNumber, SUM( Invoice.tbTask.InvoiceValue) AS TotalInvoiceValue, SUM( Invoice.tbTask.TaxValue) AS TotalTaxValue
			FROM         Invoice.tbTask INNER JOIN
								Invoice.tbInvoice ON Invoice.tbTask.InvoiceNumber = Invoice.tbInvoice.InvoiceNumber
			WHERE   ( Invoice.tbInvoice.InvoiceStatusCode <> 0)
			GROUP BY Invoice.tbTask.InvoiceNumber, Invoice.tbInvoice.InvoiceNumber
		)
		UPDATE Invoice.tbInvoice
		SET InvoiceValue = InvoiceValue + tasks.TotalInvoiceValue, 
			TaxValue = TaxValue + tasks.TotalTaxValue
		FROM         Invoice.tbInvoice INNER JOIN tasks ON Invoice.tbInvoice.InvoiceNumber = tasks.InvoiceNumber;

		WITH accounts_paid AS
		(
			SELECT AccountCode
			FROM Cash.tbPayment
			GROUP BY AccountCode
		)
		UPDATE invoice_header
		SET              
			PaidValue = InvoiceValue, PaidTaxValue = TaxValue, InvoiceStatusCode = 3
		FROM Invoice.tbInvoice invoice_header
			JOIN accounts_paid ON invoice_header.AccountCode = accounts_paid.AccountCode
		WHERE InvoiceStatusCode > 0;

		WITH accounts_paid AS
		(
			SELECT AccountCode
			FROM Cash.tbPayment
			GROUP BY AccountCode
		)
		UPDATE invoice_header
		SET     
			PaidValue = 0, PaidTaxValue = 0, InvoiceStatusCode = 1
		FROM Invoice.tbInvoice invoice_header
			LEFT OUTER JOIN accounts_paid ON invoice_header.AccountCode = accounts_paid.AccountCode
		WHERE accounts_paid.AccountCode IS NULL AND InvoiceStatusCode > 0;


		--unpaid invoices
		WITH paid_balance AS
		(
			SELECT  AccountCode, SUM(PaidInValue + (PaidOutValue * -1)) AS PaidBalance
			FROM         Cash.tbPayment
			WHERE     (PaymentStatusCode = 1)
			GROUP BY AccountCode
		), invoice_balance AS
		(
			SELECT AccountCode, SUM(CASE Invoice.tbType.CashModeCode WHEN 0 THEN (InvoiceValue + TaxValue) * - 1 WHEN 1 THEN InvoiceValue + TaxValue ELSE 0 END) AS InvoicedBalance
			FROM         Invoice.tbInvoice INNER JOIN
								  Invoice.tbType ON Invoice.tbInvoice.InvoiceTypeCode = Invoice.tbType.InvoiceTypeCode
			GROUP BY AccountCode
		), account_balance AS
		(
			SELECT paid_balance.AccountCode, PaidBalance, InvoicedBalance, PaidBalance - InvoicedBalance AS CurrentBalance
			FROM paid_balance JOIN invoice_balance ON paid_balance.AccountCode = invoice_balance.AccountCode
		), current_balance AS
		(
			SELECT account_balance.AccountCode, ROUND(OpeningBalance + account_balance.CurrentBalance, 2) AS CurrentBalance
			FROM Org.tbOrg JOIN
				account_balance ON Org.tbOrg.AccountCode = account_balance.AccountCode
		), closing_balance AS
		(
			SELECT AccountCode, 0 AS RowNumber,
				CurrentBalance,
					CASE WHEN CurrentBalance < 0 THEN 0 
						WHEN CurrentBalance > 0 THEN 1
						ELSE 2 END AS CashModeCode
			FROM current_balance
			WHERE ROUND(CurrentBalance, 0) <> 0 
		), invoice_entries AS
		(
			SELECT        Invoice.tbInvoice.AccountCode, Invoice.tbInvoice.ExpectedOn, Invoice.tbInvoice.InvoiceNumber, Invoice.tbTask.TaskCode AS RefCode, 1 AS RefType, 
				CASE WHEN Invoice.tbType.CashModeCode = 0 THEN Invoice.tbTask.InvoiceValue * -1 ELSE Invoice.tbTask.InvoiceValue END AS InvoiceValue, 
				CASE WHEN Invoice.tbType.CashModeCode = 0 THEN Invoice.tbTask.TaxValue * -1 ELSE Invoice.tbTask.TaxValue END AS TaxValue, Invoice.tbType.CashModeCode
			FROM   closing_balance JOIN Invoice.tbInvoice ON closing_balance.AccountCode = Invoice.tbInvoice.AccountCode
				JOIN  Invoice.tbTask ON Invoice.tbTask.InvoiceNumber = Invoice.tbInvoice.InvoiceNumber
				JOIN Invoice.tbType ON Invoice.tbInvoice.InvoiceTypeCode = Invoice.tbType.InvoiceTypeCode
			UNION
			SELECT        Invoice.tbInvoice.AccountCode, Invoice.tbInvoice.ExpectedOn, Invoice.tbInvoice.InvoiceNumber, CashCode AS RefCode, 2 AS RefType,
				CASE WHEN Invoice.tbType.CashModeCode = 0 THEN Invoice.tbItem.InvoiceValue * -1 ELSE Invoice.tbItem.InvoiceValue END AS InvoiceValue, 
				CASE WHEN Invoice.tbType.CashModeCode = 0 THEN Invoice.tbItem.TaxValue * -1 ELSE Invoice.tbItem.TaxValue END AS TaxValue, Invoice.tbType.CashModeCode
			FROM   closing_balance JOIN Invoice.tbInvoice ON closing_balance.AccountCode = Invoice.tbInvoice.AccountCode
				JOIN Invoice.tbItem ON Invoice.tbItem.InvoiceNumber = Invoice.tbInvoice.InvoiceNumber
				JOIN Invoice.tbType ON Invoice.tbInvoice.InvoiceTypeCode = Invoice.tbType.InvoiceTypeCode
		), invoices AS
		(
			SELECT AccountCode, ROW_NUMBER() OVER (PARTITION BY AccountCode ORDER BY ExpectedOn DESC, CashModeCode DESC) AS RowNumber, 
				InvoiceNumber, RefCode, RefType, (InvoiceValue + TaxValue) AS ValueToPay
			FROM invoice_entries
		), invoices_and_cb AS
		( 
			SELECT AccountCode, RowNumber, '' AS InvoiceNumber, '' AS RefCode, 0 AS RefType, CurrentBalance AS ValueToPay
			FROM closing_balance
			UNION
			SELECT AccountCode, RowNumber, InvoiceNumber, RefCode, RefType, ValueToPay
			FROM invoices	
		), unbalanced_cashmode AS
		(
			SELECT invoices_and_cb.AccountCode, invoices_and_cb.RowNumber, invoices_and_cb.InvoiceNumber, invoices_and_cb.RefCode, 
				invoices_and_cb.RefType, invoices_and_cb.ValueToPay, closing_balance.CashModeCode
			FROM invoices_and_cb JOIN closing_balance ON invoices_and_cb.AccountCode = closing_balance.AccountCode
		), invoice_balances AS
		(
			SELECT AccountCode, RowNumber, InvoiceNumber, RefCode, RefType, ValueToPay, CashModeCode, 
				SUM(ValueToPay) OVER (PARTITION BY AccountCode ORDER BY RowNumber ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS Balance
			FROM unbalanced_cashmode
		), selected_row AS
		(
			SELECT AccountCode, MIN(RowNumber) AS RowNumber
			FROM invoice_balances
			WHERE (CashModeCode = 0 AND Balance >= 0) OR (CashModeCode = 1 AND Balance <= 0)
			GROUP BY AccountCode
		), result_set AS
		(
			SELECT invoice_unpaid.AccountCode, invoice_unpaid.InvoiceNumber, invoice_unpaid.RefType, invoice_unpaid.RefCode, 
				CASE WHEN CashModeCode = 0 THEN
						CASE WHEN Balance < 0 THEN 0 ELSE Balance END
					WHEN CashModeCode = 1 THEN
						CASE WHEN Balance > 0 THEN 0 ELSE ABS(Balance) END
					END AS TotalPaidValue
			FROM selected_row
				CROSS APPLY (SELECT invoice_balances.*
							FROM invoice_balances
							WHERE invoice_balances.AccountCode = selected_row.AccountCode
								AND invoice_balances.RowNumber <= selected_row.RowNumber
								AND invoice_balances.RefType > 0) AS invoice_unpaid
		)
		INSERT INTO @tbPartialInvoice
			(AccountCode, InvoiceNumber, RefType, RefCode, TotalPaidValue)
		SELECT AccountCode, InvoiceNumber, RefType, RefCode, TotalPaidValue
		FROM result_set;

		UPDATE task
		SET PaidValue = 0, PaidTaxValue = 0
		FROM @tbPartialInvoice unpaid_task
			JOIN Invoice.tbTask task ON unpaid_task.InvoiceNumber = task.InvoiceNumber
				AND unpaid_task.RefCode = task.TaskCode	
		WHERE unpaid_task.RefType = 1 AND unpaid_task.TotalPaidValue = 0;

		UPDATE task
		SET 
			PaidTaxValue = CASE RoundingCode 
								WHEN 0 THEN ROUND((TotalPaidValue - (TotalPaidValue / (1 + TaxRate))), 2)
								WHEN 1 THEN ROUND((TotalPaidValue - (TotalPaidValue / (1 + TaxRate))), 2, 1)
							END,
			PaidValue = TotalPaidValue -
							CASE RoundingCode 
								WHEN 0 THEN ROUND((TotalPaidValue - (TotalPaidValue / (1 + TaxRate))), 2)
								WHEN 1 THEN ROUND((TotalPaidValue - (TotalPaidValue / (1 + TaxRate))), 2, 1)
							END
		FROM @tbPartialInvoice unpaid_task
			JOIN Invoice.tbTask task ON unpaid_task.InvoiceNumber = task.InvoiceNumber
				AND unpaid_task.RefCode = task.TaskCode	
			JOIN App.tbTaxCode tax ON tax.TaxCode = task.TaxCode
		WHERE unpaid_task.RefType = 1 AND unpaid_task.TotalPaidValue <> 0;

		UPDATE item
		SET PaidValue = 0, PaidTaxValue = 0
		FROM @tbPartialInvoice unpaid_task
			JOIN Invoice.tbItem item ON unpaid_task.InvoiceNumber = item.InvoiceNumber
				AND unpaid_task.RefCode = item.CashCode
		WHERE unpaid_task.RefType = 1 AND unpaid_task.TotalPaidValue = 0;

		UPDATE item
		SET 
			PaidTaxValue = CASE RoundingCode 
								WHEN 0 THEN ROUND((TotalPaidValue - (TotalPaidValue / (1 + TaxRate))), 2)
								WHEN 1 THEN ROUND((TotalPaidValue - (TotalPaidValue / (1 + TaxRate))), 2, 1)
							END,
			PaidValue = TotalPaidValue -
							CASE RoundingCode 
								WHEN 0 THEN ROUND((TotalPaidValue - (TotalPaidValue / (1 + TaxRate))), 2)
								WHEN 1 THEN ROUND((TotalPaidValue - (TotalPaidValue / (1 + TaxRate))), 2, 1)
							END
		FROM @tbPartialInvoice unpaid_item
			JOIN Invoice.tbItem item ON unpaid_item.InvoiceNumber = item.InvoiceNumber
				AND unpaid_item.RefCode = item.CashCode	
			JOIN App.tbTaxCode tax ON tax.TaxCode = item.TaxCode
		WHERE unpaid_item.RefType = 1 AND unpaid_item.TotalPaidValue <> 0;

		WITH invoices AS
		(
			SELECT        task.InvoiceNumber, InvoiceValue, TaxValue, PaidValue, PaidTaxValue
			FROM       @tbPartialInvoice unpaid_task
			JOIN Invoice.tbTask task ON unpaid_task.InvoiceNumber = task.InvoiceNumber
				AND unpaid_task.RefCode = task.TaskCode	
			UNION
			SELECT        item.InvoiceNumber, InvoiceValue, TaxValue, PaidValue, PaidTaxValue
			FROM @tbPartialInvoice unpaid_item
				JOIN Invoice.tbItem item ON unpaid_item.InvoiceNumber = item.InvoiceNumber
					AND unpaid_item.RefCode = item.CashCode
		), totals AS
		(
			SELECT        InvoiceNumber, SUM(InvoiceValue) AS TotalInvoiceValue, SUM(TaxValue) AS TotalTaxValue, SUM(PaidValue) AS TotalPaidValue, SUM(PaidTaxValue) AS TotalPaidTaxValue
			FROM            invoices
			GROUP BY InvoiceNumber
		), selected AS
		(
			SELECT InvoiceNumber, 		
				TotalInvoiceValue, TotalTaxValue, TotalPaidValue, TotalPaidTaxValue, 
				(TotalPaidValue + TotalPaidTaxValue) AS TotalPaid
			FROM totals
			WHERE (TotalInvoiceValue + TotalTaxValue) > (TotalPaidValue + TotalPaidTaxValue)
		)
		UPDATE Invoice.tbInvoice
		SET InvoiceStatusCode = CASE WHEN TotalPaid > 0 THEN 2 ELSE 1 END,
			PaidValue = selected.TotalPaidValue, 
			PaidTaxValue = selected.TotalPaidTaxValue
		FROM         Invoice.tbInvoice INNER JOIN
							selected ON Invoice.tbInvoice.InvoiceNumber = selected.InvoiceNumber;

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
		
		WITH invoice_summary AS
		(
			SELECT        Invoice.vwRegisterDetail.CashCode, Invoice.vwRegisterDetail.StartOn, ABS(SUM(Invoice.vwRegisterDetail.InvoiceValue)) AS InvoiceValue, ABS(SUM(Invoice.vwRegisterDetail.TaxValue)) AS TaxValue
			FROM            Invoice.vwRegisterDetail INNER JOIN
									 Cash.tbCode ON Invoice.vwRegisterDetail.CashCode = Cash.tbCode.CashCode INNER JOIN
									 Cash.tbCategory ON Cash.tbCode.CategoryCode = Cash.tbCategory.CategoryCode
			WHERE Invoice.vwRegisterDetail.StartOn < (SELECT StartOn FROM App.fnActivePeriod())
			GROUP BY Invoice.vwRegisterDetail.StartOn, Invoice.vwRegisterDetail.CashCode
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
				PaidInValue + (PaidOutValue * -1) AssetValue
			FROM Cash.tbPayment payment
				JOIN Org.tbAccount account ON payment.CashAccountCode = account.CashAccountCode
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

		--log successful rebuild
		DECLARE @Msg NVARCHAR(MAX);
		SELECT @Msg = Message FROM App.tbText WHERE TextId = 3006;
		EXEC App.proc_EventLog @EventMessage = @Msg, @EventTypeCode = 2;

  	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
