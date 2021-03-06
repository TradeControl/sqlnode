/**************************************************************************************
Trade Control
Upgrade script
Release: 3.34.5

Date: 7 June 2021
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
ALTER VIEW Cash.vwBalanceSheetAccounts
AS
	WITH account_statements AS
	(
		SELECT 
			account_statement.CashAccountCode, 
			StartOn, EntryNumber, PaidBalance
		FROM Cash.vwAccountStatement account_statement
			JOIN Org.tbAccount account ON account_statement.CashAccountCode = account.CashAccountCode
		WHERE StartOn >= (SELECT StartOn FROM Cash.vwBalanceStartOn) AND account.AccountTypeCode = 0
	)
	, account_last_tx AS
	(
		SELECT CashAccountCode, StartOn, MAX(EntryNumber) EntryNumber
		FROM account_statements
		GROUP BY CashAccountCode, StartOn
	)
	, account_balances AS
	(
		SELECT account_statements.CashAccountCode, account_statements.StartOn, account_statements.PaidBalance
		FROM account_statements
			JOIN account_last_tx ON account_statements.CashAccountCode = account_last_tx.CashAccountCode AND account_statements.EntryNumber = account_last_tx.EntryNumber
	)
	, account_polarity AS
	(
		SELECT CashCode, StartOn, SUM(PaidBalance) Balance
		FROM account_balances
			JOIN Org.tbAccount account ON account_balances.CashAccountCode = account.CashAccountCode
		GROUP BY CashCode, StartOn
	), account_base AS
	(
		SELECT 
			CASE WHEN NOT (CashCode IS NULL) 
				THEN (SELECT CashAccountCode FROM Cash.vwCurrentAccount) 
				ELSE (SELECT CashAccountCode FROM Cash.vwReserveAccount) 
			END AS AssetCode,
			1 CashModeCode,
			CASE WHEN (CashCode IS NULL) THEN 2 ELSE 3 END AssetTypeCode, StartOn, Balance
		FROM account_polarity
	)
	SELECT AssetCode, asset_type.AssetType AssetName, CashModeCode, asset_type.AssetTypeCode, StartOn, Balance
	FROM account_base
		JOIN Cash.tbAssetType asset_type ON account_base.AssetTypeCode = asset_type.AssetTypeCode;
go
DROP INDEX IX_Task_tb_ActivityStatusCode ON Task.tbTask
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
		WHERE Org.tbAccount.AccountTypeCode < 2 AND Cash.tbPayment.PaymentStatusCode = 1
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


