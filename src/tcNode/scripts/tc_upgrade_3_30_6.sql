/**************************************************************************************
Trade Control
Upgrade script
Release: 3.30.6

Date: 5 Novemeber 2020
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
			CASE WHEN Balance < 0 THEN 0 ELSE 1 END CashModeCode,
			CASE WHEN (CashCode IS NULL) THEN 2 ELSE 3 END AssetTypeCode, StartOn, Balance
		FROM account_polarity
	)
	SELECT AssetCode, asset_type.AssetType AssetName, CashModeCode, asset_type.AssetTypeCode, StartOn, Balance
	FROM account_base
		JOIN Cash.tbAssetType asset_type ON account_base.AssetTypeCode = asset_type.AssetTypeCode;

go
ALTER VIEW Cash.vwTaxCorpTotalsByPeriod
AS
	WITH invoiced_tasks AS
	(
		SELECT (SELECT TOP (1) StartOn FROM App.tbYearPeriod WHERE (StartOn <= Invoice.tbInvoice.InvoicedOn) ORDER BY StartOn DESC) AS StartOn,  
								 CASE WHEN Invoice.tbType.CashModeCode = 0 THEN Invoice.tbTask.InvoiceValue * - 1 ELSE Invoice.tbTask.InvoiceValue END AS InvoiceValue
		FROM            Invoice.tbTask INNER JOIN
								 App.vwCorpTaxCashCodes CashCodes  ON Invoice.tbTask.CashCode = CashCodes.CashCode INNER JOIN
								 Invoice.tbInvoice ON Invoice.tbTask.InvoiceNumber = Invoice.tbInvoice.InvoiceNumber INNER JOIN
								 Invoice.tbType ON Invoice.tbInvoice.InvoiceTypeCode = Invoice.tbType.InvoiceTypeCode
		WHERE CashTypeCode < 3
	), invoiced_items AS
	(
		SELECT (SELECT TOP (1) StartOn FROM App.tbYearPeriod WHERE (StartOn <= Invoice.tbInvoice.InvoicedOn) ORDER BY StartOn DESC) AS StartOn,  
							  CASE WHEN Invoice.tbType.CashModeCode = 0 THEN Invoice.tbItem.InvoiceValue * - 1 ELSE Invoice.tbItem.InvoiceValue END AS InvoiceValue
		FROM         Invoice.tbItem INNER JOIN
							  App.vwCorpTaxCashCodes CashCodes ON Invoice.tbItem.CashCode = CashCodes.CashCode INNER JOIN
							  Invoice.tbInvoice ON Invoice.tbItem.InvoiceNumber = Invoice.tbInvoice.InvoiceNumber INNER JOIN
							  Invoice.tbType ON Invoice.tbInvoice.InvoiceTypeCode = Invoice.tbType.InvoiceTypeCode
		WHERE CashTypeCode < 3
	), assets AS
	(
		SELECT cash_codes.CashCode, financial_periods.StartOn, 
			CASE cash_codes.CashModeCode WHEN 0 THEN financial_periods.InvoiceValue * -1 ELSE financial_periods.InvoiceValue END AssetValue
		FROM App.vwCorpTaxCashCodes cash_codes
			JOIN Cash.tbPeriod financial_periods
				ON cash_codes.CashCode = financial_periods.CashCode
		WHERE cash_codes.CashTypeCode = 2
	), netprofits AS	
	(
		SELECT StartOn, SUM(InvoiceValue) NetProfit 
		FROM invoiced_tasks 
		GROUP BY StartOn
		
		UNION
		
		SELECT StartOn, SUM(InvoiceValue) NetProfit 
		FROM invoiced_items 
		GROUP BY StartOn

		UNION

		SELECT StartOn, SUM(AssetValue) NetProfit
		FROM assets
		GROUP BY StartOn
	)
	, netprofit_consolidated AS
	(
		SELECT StartOn, SUM(NetProfit) AS NetProfit FROM netprofits GROUP BY StartOn
	)
	SELECT App.tbYearPeriod.StartOn, netprofit_consolidated.NetProfit, 
							netprofit_consolidated.NetProfit * App.tbYearPeriod.CorporationTaxRate + App.tbYearPeriod.TaxAdjustment AS CorporationTax, 
							App.tbYearPeriod.TaxAdjustment
	FROM         netprofit_consolidated INNER JOIN
							App.tbYearPeriod ON netprofit_consolidated.StartOn = App.tbYearPeriod.StartOn;

go

