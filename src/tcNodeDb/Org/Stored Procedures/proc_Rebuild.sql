CREATE PROCEDURE Org.proc_Rebuild(@AccountCode NVARCHAR(10))
AS
  	SET NOCOUNT, XACT_ABORT ON;

	DECLARE @tbPartialInvoice TABLE (
			AccountCode NVARCHAR(10), 
			InvoiceNumber NVARCHAR(10),
			RefType SMALLINT,
			RefCode NVARCHAR(20),
			TotalPaidValue decimal(18, 5)
			);

	BEGIN TRY
		BEGIN TRANSACTION;
		--payments
		UPDATE Cash.tbPayment
		SET
			TaxInValue = PaidInValue - 
				CASE TaxRate WHEN 0 THEN PaidInValue
				ELSE
				(
					CASE App.tbTaxCode.RoundingCode 
						WHEN 0 THEN ROUND((PaidInValue / (1 + TaxRate)), Decimals)
						WHEN 1 THEN ROUND((PaidInValue / (1 + TaxRate)), Decimals, 1) 
					END
				)
				END, 
			TaxOutValue = PaidOutValue - 
				CASE TaxRate WHEN 0 THEN PaidOutValue
				ELSE
				(		
					CASE App.tbTaxCode.RoundingCode 
						WHEN 0 THEN ROUND((PaidOutValue / (1 + TaxRate)), Decimals)
						WHEN 1 THEN ROUND((PaidOutValue / (1 + TaxRate)), Decimals, 1) 
					END
				)
				END
		FROM  Cash.tbPayment 
			INNER JOIN App.tbTaxCode ON Cash.tbPayment.TaxCode = App.tbTaxCode.TaxCode
		WHERE AccountCode = @AccountCode;

		--invoices
		IF EXISTS(SELECT * FROM Cash.tbPayment WHERE AccountCode = @AccountCode)
		BEGIN
			UPDATE Invoice.tbItem
			SET TaxValue = 
					CASE WHEN TaxRate = 0 THEN 0
					ELSE
					(
						CASE App.tbTaxCode.RoundingCode 
							WHEN 0 THEN ROUND(Invoice.tbItem.InvoiceValue * App.tbTaxCode.TaxRate, Decimals)
							WHEN 1 THEN ROUND( Invoice.tbItem.InvoiceValue * App.tbTaxCode.TaxRate, Decimals, 1) 
						END
					)
					END,
				PaidValue = Invoice.tbItem.InvoiceValue, 
				PaidTaxValue = 
					CASE WHEN TaxRate = 0 THEN 0
					ELSE
					(		
						CASE App.tbTaxCode.RoundingCode 
							WHEN 0 THEN ROUND(Invoice.tbItem.InvoiceValue * App.tbTaxCode.TaxRate, Decimals)
							WHEN 1 THEN ROUND( Invoice.tbItem.InvoiceValue * App.tbTaxCode.TaxRate, Decimals, 1) 
						END
					)
					END
			FROM Invoice.tbItem 
				INNER JOIN App.tbTaxCode ON Invoice.tbItem.TaxCode = App.tbTaxCode.TaxCode 
				INNER JOIN Invoice.tbInvoice ON Invoice.tbItem.InvoiceNumber = Invoice.tbInvoice.InvoiceNumber
			WHERE (Invoice.tbInvoice.InvoiceStatusCode <> 0) 
				AND (AccountCode = @AccountCode);
                      
			UPDATE Invoice.tbTask
			SET TaxValue = 
					CASE WHEN TaxRate = 0 THEN 0
					ELSE
					(
						CASE App.tbTaxCode.RoundingCode 
							WHEN 0 THEN ROUND(Invoice.tbTask.InvoiceValue * App.tbTaxCode.TaxRate, Decimals)
							WHEN 1 THEN ROUND( Invoice.tbTask.InvoiceValue * App.tbTaxCode.TaxRate, Decimals, 1) 
						END
					)
					END,
				PaidValue = Invoice.tbTask.InvoiceValue,
				PaidTaxValue = 
					CASE WHEN TaxRate = 0 THEN 0
					ELSE
					(
						CASE App.tbTaxCode.RoundingCode 
							WHEN 0 THEN ROUND(Invoice.tbTask.InvoiceValue * App.tbTaxCode.TaxRate, Decimals)
							WHEN 1 THEN ROUND( Invoice.tbTask.InvoiceValue * App.tbTaxCode.TaxRate, Decimals, 1) 
						END
					)
					END
			FROM  Invoice.tbTask 
				INNER JOIN App.tbTaxCode ON Invoice.tbTask.TaxCode = App.tbTaxCode.TaxCode 
				INNER JOIN Invoice.tbInvoice ON Invoice.tbTask.InvoiceNumber = Invoice.tbInvoice.InvoiceNumber
			WHERE (Invoice.tbInvoice.InvoiceStatusCode <> 0) AND (AccountCode = @AccountCode);
		END
		ELSE
		BEGIN
			UPDATE Invoice.tbItem
			SET TaxValue = 
					CASE WHEN TaxRate = 0 THEN 0
					ELSE
					(			
						CASE App.tbTaxCode.RoundingCode 
							WHEN 0 THEN ROUND(Invoice.tbItem.InvoiceValue * App.tbTaxCode.TaxRate, Decimals)
							WHEN 1 THEN ROUND( Invoice.tbItem.InvoiceValue * App.tbTaxCode.TaxRate, Decimals, 1) 
						END
					)
					END,
				PaidValue = 0,
				PaidTaxValue = 0
			FROM         Invoice.tbItem INNER JOIN
									App.tbTaxCode ON Invoice.tbItem.TaxCode = App.tbTaxCode.TaxCode INNER JOIN
									Invoice.tbInvoice ON Invoice.tbItem.InvoiceNumber = Invoice.tbInvoice.InvoiceNumber
			WHERE     ( Invoice.tbInvoice.InvoiceStatusCode <> 0)
				AND (AccountCode = @AccountCode);
                      
			UPDATE Invoice.tbTask
			SET TaxValue = 
					CASE WHEN TaxRate = 0 THEN 0
					ELSE
					(		
						CASE App.tbTaxCode.RoundingCode 
								WHEN 0 THEN ROUND(Invoice.tbTask.InvoiceValue * App.tbTaxCode.TaxRate, Decimals)
								WHEN 1 THEN ROUND( Invoice.tbTask.InvoiceValue * App.tbTaxCode.TaxRate, Decimals, 1) 
						END
					)
					END,
				PaidValue = 0,
				PaidTaxValue = 0
			FROM         Invoice.tbTask INNER JOIN
									App.tbTaxCode ON Invoice.tbTask.TaxCode = App.tbTaxCode.TaxCode INNER JOIN
									Invoice.tbInvoice ON Invoice.tbTask.InvoiceNumber = Invoice.tbInvoice.InvoiceNumber
			WHERE     ( Invoice.tbInvoice.InvoiceStatusCode <> 0)
				AND (AccountCode = @AccountCode);		
		END	

		UPDATE Invoice.tbInvoice
		SET InvoiceValue = 0, TaxValue = 0, PaidValue = 0, PaidTaxValue = 0, InvoiceStatusCode = 1
		WHERE     ( Invoice.tbInvoice.InvoiceStatusCode <> 0)
			AND (AccountCode = @AccountCode);
	
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
								ON Invoice.tbInvoice.InvoiceNumber = items.InvoiceNumber
		WHERE (AccountCode = @AccountCode);


		WITH tasks AS
		(
			SELECT     Invoice.tbInvoice.InvoiceNumber, SUM( Invoice.tbTask.InvoiceValue) AS TotalInvoiceValue, SUM( Invoice.tbTask.TaxValue) AS TotalTaxValue
			FROM         Invoice.tbTask INNER JOIN
								Invoice.tbInvoice ON Invoice.tbTask.InvoiceNumber = Invoice.tbInvoice.InvoiceNumber
			WHERE   ( Invoice.tbInvoice.InvoiceStatusCode <> 0) AND (AccountCode = @AccountCode)
			GROUP BY Invoice.tbTask.InvoiceNumber, Invoice.tbInvoice.InvoiceNumber
		)
		UPDATE Invoice.tbInvoice
		SET InvoiceValue = InvoiceValue + tasks.TotalInvoiceValue, 
			TaxValue = TaxValue + tasks.TotalTaxValue
		FROM         Invoice.tbInvoice INNER JOIN tasks ON Invoice.tbInvoice.InvoiceNumber = tasks.InvoiceNumber;

		IF EXISTS(SELECT * FROM Cash.tbPayment WHERE AccountCode = @AccountCode)
			UPDATE    Invoice.tbInvoice
			SET              PaidValue = InvoiceValue, PaidTaxValue = TaxValue, InvoiceStatusCode = 3
			WHERE (AccountCode = @AccountCode);
			
		WITH paid_balance AS
		(
			SELECT  AccountCode, SUM(PaidInValue + (PaidOutValue * -1)) AS PaidBalance
			FROM         Cash.tbPayment
			WHERE     (PaymentStatusCode <> 0) AND (AccountCode = @AccountCode)
			GROUP BY AccountCode
		), invoice_balance AS
		(
			SELECT AccountCode, SUM(CASE Invoice.tbType.CashModeCode WHEN 0 THEN (InvoiceValue + TaxValue) * - 1 WHEN 1 THEN InvoiceValue + TaxValue ELSE 0 END) AS InvoicedBalance
			FROM         Invoice.tbInvoice INNER JOIN
								  Invoice.tbType ON Invoice.tbInvoice.InvoiceTypeCode = Invoice.tbType.InvoiceTypeCode
			WHERE (AccountCode = @AccountCode)
			GROUP BY AccountCode
		), account_balance AS
		(
			SELECT paid_balance.AccountCode, PaidBalance, InvoicedBalance, PaidBalance - InvoicedBalance AS CurrentBalance
			FROM paid_balance JOIN invoice_balance ON paid_balance.AccountCode = invoice_balance.AccountCode
		), current_balance AS
		(
			SELECT account_balance.AccountCode, 
				OpeningBalance + account_balance.CurrentBalance AS CurrentBalance
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

		--SELECT * FROM @tbPartialInvoice

		UPDATE task
		SET PaidValue = 0, PaidTaxValue = 0
		FROM @tbPartialInvoice unpaid_task
			JOIN Invoice.tbTask task ON unpaid_task.InvoiceNumber = task.InvoiceNumber
				AND unpaid_task.RefCode = task.TaskCode	
		WHERE unpaid_task.RefType = 1 AND unpaid_task.TotalPaidValue = 0;

		UPDATE task
		SET 
			PaidTaxValue = 
					CASE WHEN TaxRate = 0 THEN 0
					ELSE
					(
						CASE RoundingCode 
							WHEN 0 THEN ROUND((TotalPaidValue - (TotalPaidValue / (1 + TaxRate))), Decimals)
							WHEN 1 THEN ROUND((TotalPaidValue - (TotalPaidValue / (1 + TaxRate))), Decimals, 1)
						END
					)
					END,
			PaidValue = TotalPaidValue -
					CASE WHEN TaxRate = 0 THEN 0
					ELSE
					(
						CASE RoundingCode 
							WHEN 0 THEN ROUND((TotalPaidValue - (TotalPaidValue / (1 + TaxRate))), Decimals)
							WHEN 1 THEN ROUND((TotalPaidValue - (TotalPaidValue / (1 + TaxRate))), Decimals, 1)
						END
					)
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
		WHERE unpaid_task.RefType = 2 AND unpaid_task.TotalPaidValue = 0;

		UPDATE item
		SET 
			PaidTaxValue = 
					CASE WHEN TaxRate = 0 THEN 0
					ELSE
					(
						CASE RoundingCode 
							WHEN 0 THEN ROUND((TotalPaidValue - (TotalPaidValue / (1 + TaxRate))), Decimals)
							WHEN 1 THEN ROUND((TotalPaidValue - (TotalPaidValue / (1 + TaxRate))), Decimals, 1)
						END
					)
					END,
			PaidValue = TotalPaidValue -
					CASE WHEN TaxRate = 0 THEN 0
					ELSE
					(
						CASE RoundingCode 
							WHEN 0 THEN ROUND((TotalPaidValue - (TotalPaidValue / (1 + TaxRate))), Decimals)
							WHEN 1 THEN ROUND((TotalPaidValue - (TotalPaidValue / (1 + TaxRate))), Decimals, 1)
						END
					)
					END
		FROM @tbPartialInvoice unpaid_item
			JOIN Invoice.tbItem item ON unpaid_item.InvoiceNumber = item.InvoiceNumber
				AND unpaid_item.RefCode = item.CashCode	
			JOIN App.tbTaxCode tax ON tax.TaxCode = item.TaxCode
		WHERE unpaid_item.RefType = 2 AND unpaid_item.TotalPaidValue <> 0;

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

		COMMIT TRANSACTION

		--log successful rebuild
		DECLARE @Msg NVARCHAR(MAX);
		SELECT @Msg = CONCAT(@AccountCode, ' ', Message) FROM App.tbText WHERE TextId = 3006;
		EXEC App.proc_EventLog @EventMessage = @Msg, @EventTypeCode = 2;

  	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH

