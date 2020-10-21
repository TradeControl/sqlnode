/**************************************************************************************
Trade Control
Upgrade script
Release: 3.30.5

Date: 12 October 2020
Author: IAM

Trade Control by Trade Control Ltd is licensed under GNU General Public License v3.0. 

You may obtain a copy of the License at

	https://www.gnu.org/licenses/gpl-3.0.en.html

Change log:

	https://github.com/tradecontrol/tc-nodecore

Instructions:
This script should be applied by the Node Configuration app.

***********************************************************************************/
go
ALTER VIEW Cash.vwBalanceSheetAssets
AS
	WITH asset_statements AS
	(
		SELECT account_statement.CashAccountCode, COALESCE(StartOn, (SELECT MIN(StartOn) FROM App.tbYearPeriod)) StartOn, EntryNumber, PaidBalance
		FROM Cash.vwAccountStatement account_statement
			JOIN Org.tbAccount account ON account_statement.CashAccountCode = account.CashAccountCode
		WHERE account.AccountTypeCode = 2 AND account.AccountClosed = 0 
	), asset_last_tx AS
	(
		SELECT CashAccountCode, MAX(EntryNumber) EntryNumber
		FROM asset_statements
		GROUP BY CashAccountCode, StartOn
	)
	, asset_polarity AS
	(
		SELECT asset_statements.CashAccountCode, asset_statements.StartOn, SUM(asset_statements.PaidBalance) Balance, CAST(1 as bit) IsEntry
		FROM asset_statements
			JOIN asset_last_tx ON asset_statements.CashAccountCode = asset_last_tx.CashAccountCode AND asset_statements.EntryNumber = asset_last_tx.EntryNumber
		GROUP BY asset_statements.CashAccountCode, asset_statements.StartOn
	), asset_periods AS
	(
		SELECT CashAccountCode, StartOn,  0 Balance, CAST(0 as bit) IsEntry
		FROM App.tbYearPeriod year_periods
			CROSS JOIN Org.tbAccount account
		WHERE account.AccountTypeCode = 2 AND account.AccountClosed = 0
	), asset_unordered AS
	(
		SELECT asset_periods.CashAccountCode, asset_periods.StartOn,
			CASE WHEN asset_polarity.CashAccountCode IS NULL THEN asset_periods.Balance ELSE asset_polarity.Balance END Balance,
			CASE WHEN asset_polarity.CashAccountCode IS NULL THEN asset_periods.IsEntry ELSE asset_polarity.IsEntry END IsEntry
		FROM asset_periods
			LEFT OUTER JOIN asset_polarity
				ON asset_periods.CashAccountCode = asset_polarity.CashAccountCode
					AND asset_periods.StartOn = asset_polarity.StartOn
	), asset_ordered AS
	(
		SELECT 
			ROW_NUMBER() OVER (ORDER BY CashAccountCode, StartOn) EntryNumber,
			CashAccountCode, StartOn, Balance, IsEntry
		FROM asset_unordered
	)
	, asset_ranked AS
	(
		SELECT *, 
		RANK() OVER (PARTITION BY CashAccountCode, IsEntry ORDER BY EntryNumber) RNK
		FROM asset_ordered
	)
	, asset_grouped AS
	(
		SELECT EntryNumber, CashAccountCode, StartOn, Balance, IsEntry,
		MAX(CASE IsEntry WHEN 0 THEN 0 ELSE RNK END) OVER (PARTITION BY CashAccountCode ORDER BY EntryNumber) RNK
		FROM asset_ranked
	), asset_base AS
	(
		SELECT EntryNumber, CashAccountCode, StartOn, IsEntry,
			CASE IsEntry WHEN 0 THEN
				MAX(Balance) OVER (PARTITION BY CashAccountCode, RNK ORDER BY EntryNumber) +
				MIN(Balance) OVER (PARTITION BY CashAccountCode, RNK ORDER BY EntryNumber) 
			ELSE
				Balance
			END AS Balance
		FROM asset_grouped
	), asset_accounts AS
	(
		SELECT CashAccountCode, CashAccountName, CashModeCode
		FROM Org.tbAccount accounts
			JOIN Cash.tbCode cash_code ON accounts.CashCode = cash_code.CashCode
			JOIN Cash.tbCategory cash_category ON cash_code.CategoryCode = cash_category.CategoryCode
		WHERE AccountTypeCode = 2 AND AccountClosed = 0
	)
	SELECT asset_accounts.CashAccountCode AssetCode, CashAccountName AssetName, CashModeCode, 4 AssetTypeCode, StartOn, Balance
	FROM asset_base
		JOIN asset_accounts ON asset_base.CashAccountCode = asset_accounts.CashAccountCode;
go
ALTER TRIGGER Cash.Cash_tbPayment_TriggerUpdate
ON Cash.tbPayment
FOR UPDATE
AS
	SET NOCOUNT ON;
	BEGIN TRY
		UPDATE Cash.tbPayment
		SET UpdatedBy = SUSER_SNAME(), UpdatedOn = CURRENT_TIMESTAMP
		FROM Cash.tbPayment INNER JOIN inserted AS i ON tbPayment.PaymentCode = i.PaymentCode;

		IF UPDATE(PaidInValue) OR UPDATE(PaidOutValue)
		BEGIN
			IF EXISTS (SELECT * FROM inserted i
					JOIN Org.tbAccount account ON i.CashAccountCode = account.CashAccountCode AND account.AccountTypeCode = 0
				WHERE i.PaymentStatusCode = 1)
			BEGIN
				DECLARE @AccountCode NVARCHAR(10)
				DECLARE org CURSOR LOCAL FOR 
					SELECT i.AccountCode 
					FROM inserted i
						JOIN Org.tbAccount account ON i.CashAccountCode = account.CashAccountCode AND account.AccountTypeCode = 0
					WHERE i.PaymentStatusCode = 1

				OPEN org
				FETCH NEXT FROM org INTO @AccountCode
				WHILE (@@FETCH_STATUS = 0)
					BEGIN		
					EXEC Org.proc_Rebuild @AccountCode
					FETCH NEXT FROM org INTO @AccountCode
				END

				CLOSE org
				DEALLOCATE org
			END
		END

		IF UPDATE(PaymentStatusCode) OR UPDATE(PaidInValue) OR UPDATE(PaidOutValue)
		BEGIN
			WITH assets AS
			(
				SELECT account.CashAccountCode FROM inserted i
					JOIN Org.tbAccount account ON account.CashAccountCode = i.CashAccountCode
				WHERE AccountTypeCode = 2
			), balance AS
			(
				SELECT account.CashAccountCode, SUM(PaidInValue + (PaidOutValue * -1)) AS CurrentBalance
				FROM Org.tbAccount account
					JOIN assets ON account.CashAccountCode = assets.CashAccountCode
					JOIN Cash.tbPayment payment ON account.CashAccountCode = payment.CashAccountCode
				WHERE payment.PaymentStatusCode = 1
				GROUP BY account.CashAccountCode
			)
			UPDATE account
			SET CurrentBalance = balance.CurrentBalance + OpeningBalance
			FROM Org.tbAccount account
				JOIN balance ON account.CashAccountCode = balance.CashAccountCode;
		END

	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
go
ALTER TRIGGER Cash.Cash_tbPayment_TriggerInsert
ON Cash.tbPayment
FOR INSERT
AS
	SET NOCOUNT ON;
	BEGIN TRY

		UPDATE payment
		SET PaymentStatusCode = 2
		FROM inserted
			JOIN Cash.tbPayment payment ON inserted.PaymentCode = payment.PaymentCode
			JOIN Org.tbAccount account ON payment.CashAccountCode = account.CashAccountCode
			JOIN Cash.tbCode ON inserted.CashCode = Cash.tbCode.CashCode 
			JOIN Cash.tbCategory category ON Cash.tbCode.CategoryCode = category.CategoryCode
		WHERE category.CashTypeCode = 2 AND inserted.PaymentStatusCode = 0 AND account.AccountTypeCode = 0;

		WITH assets AS
		(
			SELECT account.CashAccountCode FROM inserted i
				JOIN Org.tbAccount account ON account.CashAccountCode = i.CashAccountCode
			WHERE AccountTypeCode = 2 AND PaymentStatusCode = 1
		), balance AS
		(
			SELECT account.CashAccountCode, SUM(PaidInValue + (PaidOutValue * -1)) CurrentBalance
			FROM Org.tbAccount account
				JOIN assets ON account.CashAccountCode = assets.CashAccountCode
				JOIN Cash.tbPayment payment ON account.CashAccountCode = payment.CashAccountCode
			WHERE payment.PaymentStatusCode = 1
			GROUP BY account.CashAccountCode
		)
		UPDATE account
		SET CurrentBalance = balance.CurrentBalance + OpeningBalance
		FROM Org.tbAccount account
			JOIN balance ON account.CashAccountCode = balance.CashAccountCode;

	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
go
ALTER VIEW Org.vwStatement 
AS
	WITH payment_data AS
	(
		SELECT Cash.tbPayment.AccountCode, Cash.tbPayment.PaidOn AS TransactedOn, 2 AS OrderBy, 
						CASE WHEN LEN(COALESCE(Cash.tbPayment.PaymentReference, '')) = 0 THEN Cash.tbPayment.PaymentCode ELSE Cash.tbPayment.PaymentReference END AS Reference, 
						Cash.tbPaymentStatus.PaymentStatus AS StatementType, 
						CASE WHEN PaidInValue > 0 THEN PaidInValue ELSE PaidOutValue * - 1 END AS Charge
		FROM Cash.tbPayment 
			JOIN Org.tbAccount ON Cash.tbPayment.CashAccountCode = Org.tbAccount.CashAccountCode
			JOIN Cash.tbPaymentStatus ON Cash.tbPayment.PaymentStatusCode = Cash.tbPaymentStatus.PaymentStatusCode
		WHERE Org.tbAccount.AccountTypeCode < 2
	), payments AS
	(
		SELECT     AccountCode, TransactedOn, OrderBy, Reference, StatementType, SUM(Charge) AS Charge
		FROM     payment_data
		GROUP BY AccountCode, TransactedOn, OrderBy, Reference, StatementType
	), invoices AS
	(
		SELECT Invoice.tbInvoice.AccountCode, Invoice.tbInvoice.InvoicedOn AS TransactedOn, 1 AS OrderBy, Invoice.tbInvoice.InvoiceNumber AS Reference, Invoice.tbType.InvoiceType AS StatementType, 
			CASE CashModeCode 
				WHEN 0 THEN Invoice.tbInvoice.InvoiceValue + Invoice.tbInvoice.TaxValue 
				WHEN 1 THEN (Invoice.tbInvoice.InvoiceValue + Invoice.tbInvoice.TaxValue) * - 1 
			END AS Charge
		FROM Invoice.tbInvoice 
			JOIN Invoice.tbType ON Invoice.tbInvoice.InvoiceTypeCode = Invoice.tbType.InvoiceTypeCode
	), transactions_union AS
	(
		SELECT     AccountCode, TransactedOn, OrderBy, Reference, StatementType, Charge
		FROM         payments
		UNION ALL
		SELECT     AccountCode, TransactedOn, OrderBy, Reference, StatementType, Charge
		FROM         invoices
	), transactions AS
	(
		SELECT AccountCode, ROW_NUMBER() OVER (PARTITION BY AccountCode ORDER BY TransactedOn, OrderBy, Reference) AS RowNumber, 
			TransactedOn, Reference, StatementType, Charge
		FROM transactions_union
	), opening_balance AS
	(
		SELECT AccountCode, 0 AS RowNumber, InsertedOn AS TransactedOn, NULL AS Reference, 
			(SELECT CAST(Message AS NVARCHAR) FROM App.tbText WHERE TextId = 3005) AS StatementType, OpeningBalance AS Charge
		FROM Org.tbOrg org
	), statement_data AS
	( 
		SELECT AccountCode, RowNumber, TransactedOn, Reference, StatementType, Charge FROM transactions
		UNION
		SELECT AccountCode, RowNumber, TransactedOn, Reference, StatementType, Charge FROM opening_balance
	)
	SELECT AccountCode, CAST(RowNumber AS INT) AS RowNumber, 
		CASE RowNumber 
			WHEN 0 THEN 
				DATEADD(DAY, -1, COALESCE(LEAD(TransactedOn) OVER (PARTITION BY AccountCode ORDER BY RowNumber), 0)) 
			ELSE 
				TransactedOn 
		END TransactedOn, 
		Reference, StatementType, CAST(Charge as float) AS Charge, 
		CAST(SUM(Charge) OVER (PARTITION BY AccountCode ORDER BY RowNumber ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS float) AS Balance
	FROM statement_data;
go
ALTER VIEW Org.vwAssetBalances
AS
	WITH financial_periods AS
	(
		SELECT pd.StartOn
		FROM App.tbYear yr
			JOIN App.tbYearPeriod pd ON yr.YearNumber = pd.YearNumber
		WHERE (yr.CashStatusCode BETWEEN 1 AND 2)
	), org_periods AS
	(
		SELECT AccountCode, StartOn
		FROM Org.tbOrg orgs
			CROSS JOIN financial_periods	
	)
	, org_statements AS
	(
		SELECT StartOn, 
			AccountCode, os.RowNumber, TransactedOn, Balance,
			MAX(RowNumber) OVER (PARTITION BY AccountCode, StartOn ORDER BY StartOn) LastRowNumber 
		FROM Org.vwAssetStatement os
		WHERE TransactedOn >= (SELECT StartOn FROM Cash.vwBalanceStartOn)
	)
	, org_balances AS
	(
		SELECT AccountCode, StartOn, Balance
		FROM org_statements
		WHERE RowNumber = LastRowNumber
	)
	, org_ordered AS
	(
		SELECT ROW_NUMBER() OVER (ORDER BY org_periods.AccountCode, org_periods.StartOn) EntryNumber,
			org_periods.AccountCode, org_periods.StartOn, 
			COALESCE(Balance, 0) Balance,
			CASE WHEN org_balances.StartOn IS NULL THEN 0 ELSE 1 END IsEntry
		FROM org_periods
			LEFT OUTER JOIN org_balances 
				ON org_periods.AccountCode = org_balances.AccountCode AND org_periods.StartOn = org_balances.StartOn
	), org_ranked AS
	(
		SELECT *,
			RANK() OVER (PARTITION BY AccountCode, IsEntry ORDER BY EntryNumber) RNK
		FROM org_ordered
	), org_grouped AS
	(
		SELECT EntryNumber, AccountCode, StartOn, IsEntry, Balance,
			MAX(CASE IsEntry WHEN 0 THEN 0 ELSE RNK END) OVER (PARTITION BY AccountCode ORDER BY EntryNumber) RNK
		FROM org_ranked
	)
	, org_projected AS
	(
		SELECT EntryNumber, AccountCode, StartOn, IsEntry,
			CASE IsEntry WHEN 0 THEN
				MAX(Balance) OVER (PARTITION BY AccountCode, RNK ORDER BY EntryNumber) +
				MIN(Balance) OVER (PARTITION BY AccountCode, RNK ORDER BY EntryNumber) 
			ELSE
				Balance
			END
			AS Balance
		FROM org_grouped	
	), org_entries AS
	(
		SELECT AccountCode, EntryNumber, StartOn, Balance * -1 AS Balance,
			CASE 
				WHEN Balance < 0 THEN 0 
				ELSE 1
			END AS AssetTypeCode, 
			CASE WHEN Balance <> 0 THEN 1 ELSE IsEntry END AS IsEntry
		FROM org_projected
	)
	SELECT AccountCode, StartOn, Balance, 
		CASE 
			WHEN Balance <> 0 THEN AssetTypeCode 
			ELSE
				COALESCE(LAG(AssetTypeCode) OVER (PARTITION BY AccountCode ORDER BY EntryNumber), 0)
		END AssetTypeCode
	FROM org_entries WHERE IsEntry = 1;
go
ALTER TRIGGER Invoice.Invoice_tbInvoice_TriggerUpdate
ON Invoice.tbInvoice
FOR UPDATE
AS
	SET NOCOUNT ON;

	BEGIN TRY
		IF UPDATE(Spooled)
		BEGIN
			INSERT INTO App.tbDocSpool (DocTypeCode, DocumentNumber)
			SELECT     App.fnDocInvoiceType(i.InvoiceTypeCode) AS DocTypeCode, i.InvoiceNumber
			FROM         inserted i 
			WHERE     (i.Spooled <> 0)

			DELETE App.tbDocSpool
			FROM         inserted i INNER JOIN
								  App.tbDocSpool ON i.InvoiceNumber = App.tbDocSpool.DocumentNumber
			WHERE    (i.Spooled = 0) AND ( App.tbDocSpool.DocTypeCode > 3)
		END


		IF UPDATE(InvoicedOn) AND NOT UPDATE(DueOn)
		BEGIN
			UPDATE invoice
			SET DueOn = App.fnAdjustToCalendar(CASE WHEN org.PayDaysFromMonthEnd <> 0 
													THEN 
														DATEADD(d, -1, DATEADD(m, 1, CONCAT(FORMAT(DATEADD(d, org.PaymentDays, i.InvoicedOn), 'yyyyMM'), '01')))												
													ELSE
														DATEADD(d, org.PaymentDays, invoice.InvoicedOn)	
													END, 0)		
				FROM Invoice.tbInvoice invoice
					JOIN inserted i ON i.InvoiceNumber = invoice.InvoiceNumber
					JOIN Org.tbOrg org ON i.AccountCode = org.AccountCode
				WHERE i.InvoiceTypeCode = 0;
		END;	

		IF UPDATE(InvoicedOn) AND NOT UPDATE(ExpectedOn)
		BEGIN
			UPDATE invoice
			SET ExpectedOn = App.fnAdjustToCalendar(CASE WHEN org.PayDaysFromMonthEnd <> 0 
													THEN 
														DATEADD(d, -1, DATEADD(m, 1, CONCAT(FORMAT(DATEADD(d, org.PaymentDays + org.ExpectedDays, i.InvoicedOn), 'yyyyMM'), '01')))												
													ELSE
														DATEADD(d, org.PaymentDays + org.ExpectedDays, invoice.InvoicedOn)	
													END, 0)		
				FROM Invoice.tbInvoice invoice
					JOIN inserted i ON i.InvoiceNumber = invoice.InvoiceNumber
					JOIN Org.tbOrg org ON i.AccountCode = org.AccountCode
				WHERE i.InvoiceTypeCode = 0;
		END;	
		
		WITH invoices AS
		(
			SELECT inserted.InvoiceNumber, inserted.AccountCode, inserted.InvoiceStatusCode, inserted.DueOn, inserted.InvoiceValue, inserted.TaxValue, inserted.PaidValue, inserted.PaidTaxValue FROM inserted JOIN deleted ON inserted.InvoiceNumber = deleted.InvoiceNumber WHERE inserted.InvoiceStatusCode = 1 AND deleted.InvoiceStatusCode = 0
		)
		INSERT INTO Invoice.tbChangeLog (InvoiceNumber, TransmitStatusCode, InvoiceStatusCode, DueOn, InvoiceValue, TaxValue, PaidValue, PaidTaxValue)
		SELECT InvoiceNumber, orgs.TransmitStatusCode, InvoiceStatusCode, DueOn, InvoiceValue, TaxValue, PaidValue, PaidTaxValue
		FROM invoices JOIN Org.tbOrg orgs ON invoices.AccountCode = orgs.AccountCode;

		IF UPDATE(InvoiceStatusCode) OR UPDATE(DueOn) OR UPDATE(PaidValue) OR UPDATE(PaidTaxValue) OR UPDATE(InvoiceValue) OR UPDATE (TaxValue)
		BEGIN
			WITH candidates AS
			(
				SELECT InvoiceNumber, AccountCode, InvoiceStatusCode, DueOn, InvoiceValue, TaxValue, PaidValue, PaidTaxValue 
				FROM inserted
				WHERE EXISTS (SELECT * FROM Invoice.tbChangeLog WHERE InvoiceNumber = inserted.InvoiceNumber)
			)
			, logs AS
			(
				SELECT clog.LogId, clog.InvoiceNumber, clog.InvoiceStatusCode, clog.TransmitStatusCode, clog.DueOn, clog.InvoiceValue, clog.TaxValue, clog.PaidValue, clog.PaidTaxValue 
				FROM Invoice.tbChangeLog clog
				JOIN candidates ON clog.InvoiceNumber = candidates.InvoiceNumber AND LogId = (SELECT MAX(LogId) FROM Invoice.tbChangeLog WHERE InvoiceNumber = candidates.InvoiceNumber)		
			)
			INSERT INTO Invoice.tbChangeLog
									 (InvoiceNumber, TransmitStatusCode, InvoiceStatusCode, DueOn, InvoiceValue, TaxValue, PaidValue, PaidTaxValue)
			SELECT candidates.InvoiceNumber, CASE orgs.TransmitStatusCode WHEN 1 THEN 2 ELSE 0 END TransmitStatusCode, candidates.InvoiceStatusCode,
				candidates.DueOn, candidates.InvoiceValue, candidates.TaxValue, candidates.PaidValue, candidates.PaidTaxValue
			FROM candidates 
				JOIN Org.tbOrg orgs ON candidates.AccountCode = orgs.AccountCode 
				JOIN logs ON candidates.InvoiceNumber = logs.InvoiceNumber
			WHERE (logs.InvoiceStatusCode <> candidates.InvoiceStatusCode) 
				OR (logs.TransmitStatusCode < 2)
				OR (logs.DueOn <> candidates.DueOn) 
				OR ((logs.InvoiceValue + logs.TaxValue + logs.PaidValue + logs.PaidTaxValue) 
						<> (candidates.InvoiceValue + candidates.TaxValue + candidates.PaidValue + candidates.PaidTaxValue))
		END
	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
go


