/**************************************************************************************
Trade Control
Upgrade script
Release: 3.30.1

Date: 18 September 2020
Author: IAM

Trade Control by Trade Control Ltd is licensed under GNU General Public License v3.0. 

You may obtain a copy of the License at

	https://www.gnu.org/licenses/gpl-3.0.en.html

Change log:

	https://github.com/tradecontrol/sqlnode

Instructions:
This script should be applied by the TC Node Configuration app.
It inserts the upgade into App.tbInstall.

***********************************************************************************/
go
ALTER VIEW Cash.vwAccountStatement
  AS
	WITH entries AS
	(
		SELECT  payment.CashAccountCode, payment.CashCode, ROW_NUMBER() OVER (PARTITION BY payment.CashAccountCode ORDER BY PaidOn) AS EntryNumber, PaymentCode, PaidOn, 
			CASE WHEN PaidInValue > 0 THEN PaidInValue ELSE PaidOutValue * - 1 END AS Paid
		FROM         Cash.tbPayment payment INNER JOIN Org.tbAccount ON payment.CashAccountCode = Org.tbAccount.CashAccountCode
		WHERE     (PaymentStatusCode = 1) AND (AccountClosed = 0)	
		UNION
		SELECT        
			CashAccountCode, 
			COALESCE(CashCode, (SELECT TOP 1 CashCode FROM Cash.vwBankCashCodes WHERE CashModeCode = 2)) CashCode,
			0 AS EntryNumber, 
			(SELECT CAST(Message AS NVARCHAR(30)) FROM App.tbText WHERE TextId = 3005) AS PaymentCode, 
			DATEADD(HOUR, - 1, (SELECT MIN(PaidOn) FROM Cash.tbPayment WHERE CashAccountCode = cash_account.CashAccountCode)) AS PaidOn, OpeningBalance AS Paid
		FROM            Org.tbAccount cash_account 								 
		WHERE        (AccountClosed = 0) 
	), running_balance AS
	(
		SELECT CashAccountCode, CashCode, EntryNumber, PaymentCode, PaidOn, 
			SUM(Paid) OVER (PARTITION BY CashAccountCode ORDER BY EntryNumber ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS PaidBalance
		FROM entries
	), payments AS
	(
		SELECT     Cash.tbPayment.PaymentCode, Cash.tbPayment.CashAccountCode, Usr.tbUser.UserName, Cash.tbPayment.AccountCode, 
							  Org.tbOrg.AccountName, Cash.tbPayment.CashCode, Cash.tbCode.CashDescription, App.tbTaxCode.TaxDescription, 
							  Cash.tbPayment.PaidInValue, Cash.tbPayment.PaidOutValue, 
							  Cash.tbPayment.PaymentReference, Cash.tbPayment.InsertedBy, Cash.tbPayment.InsertedOn, 
							  Cash.tbPayment.UpdatedBy, Cash.tbPayment.UpdatedOn, Cash.tbPayment.TaxCode
		FROM         Cash.tbPayment INNER JOIN
							  Usr.tbUser ON Cash.tbPayment.UserId = Usr.tbUser.UserId INNER JOIN
							  Org.tbOrg ON Cash.tbPayment.AccountCode = Org.tbOrg.AccountCode LEFT OUTER JOIN
							  App.tbTaxCode ON Cash.tbPayment.TaxCode = App.tbTaxCode.TaxCode LEFT OUTER JOIN
							  Cash.tbCode ON Cash.tbPayment.CashCode = Cash.tbCode.CashCode
	)
	SELECT running_balance.CashAccountCode, (SELECT TOP 1 StartOn FROM App.tbYearPeriod	WHERE (StartOn <= running_balance.PaidOn) ORDER BY StartOn DESC) AS StartOn, 
							running_balance.EntryNumber, running_balance.PaymentCode, running_balance.PaidOn, 
							payments.AccountName, payments.PaymentReference, COALESCE(payments.PaidInValue, 0) PaidInValue, 
							COALESCE(payments.PaidOutValue, 0) PaidOutValue, CAST(running_balance.PaidBalance as decimal(18,5)) PaidBalance, 
							payments.CashCode, payments.CashDescription, payments.TaxDescription, payments.UserName, 
							payments.AccountCode, payments.TaxCode
	FROM   running_balance LEFT OUTER JOIN
							payments ON running_balance.PaymentCode = payments.PaymentCode;	
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
	SELECT AccountCode, CAST(RowNumber AS INT) AS RowNumber, TransactedOn, Reference, StatementType, CAST(Charge as float) AS Charge, 
		CAST(SUM(Charge) OVER (PARTITION BY AccountCode ORDER BY RowNumber ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS float) AS Balance
	FROM statement_data;
go
ALTER VIEW Org.vwAssetStatement
AS
	SELECT (SELECT TOP 1 StartOn FROM App.tbYearPeriod	WHERE (StartOn <= TransactedOn) ORDER BY StartOn DESC) AS StartOn, *
	FROM Org.vwStatement
go
CREATE VIEW Org.vwAssetBalances
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
	), org_statements AS
	(
		SELECT StartOn, 
			AccountCode, os.RowNumber, TransactedOn, Balance,
			MAX(RowNumber) OVER (PARTITION BY AccountCode, StartOn ORDER BY StartOn) LastRowNumber 
		FROM Org.vwAssetStatement os
		WHERE TransactedOn >= (SELECT StartOn FROM Cash.vwBalanceStartOn)
	), org_balances AS
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
	)
	SELECT AccountCode, StartOn, Balance * -1 AS Balance,
		CASE WHEN Balance <= 0 THEN 0 ELSE 1 END AS AssetTypeCode
	FROM org_projected;
go
ALTER VIEW Cash.vwBalanceSheetOrgs
AS
	WITH asset_balances AS
	(
		SELECT AssetTypeCode, StartOn, SUM(Balance) Balance
		FROM Org.vwAssetBalances
		GROUP BY AssetTypeCode, StartOn
	)
	SELECT (SELECT CashAccountCode FROM Cash.vwCurrentAccount) AssetCode, asset_type.AssetType AssetName, 
		asset_type.AssetTypeCode,
		CASE asset_type.AssetTypeCode WHEN 0 THEN 1 ELSE 0 END CashModeCode,
		StartOn, Balance
	FROM asset_balances
		JOIN Cash.tbAssetType asset_type ON asset_balances.AssetTypeCode = asset_type.AssetTypeCode;
go
CREATE VIEW Org.vwBalanceSheetAudit
AS
	SELECT        App.tbYear.YearNumber, App.tbYear.Description, App.tbMonth.MonthName, Org.tbOrg.AccountCode, Org.tbOrg.AccountName, Org.tbType.OrganisationType, Cash.tbMode.CashMode, Cash.tbAssetType.AssetTypeCode, 
							 Cash.tbAssetType.AssetType, Org.vwAssetBalances.StartOn, Org.vwAssetBalances.Balance
	FROM            Org.vwAssetBalances INNER JOIN
							 Cash.tbAssetType ON Org.vwAssetBalances.AssetTypeCode = Cash.tbAssetType.AssetTypeCode INNER JOIN
							 Org.tbOrg ON Org.vwAssetBalances.AccountCode = Org.tbOrg.AccountCode INNER JOIN
							 App.tbYearPeriod ON Org.vwAssetBalances.StartOn = App.tbYearPeriod.StartOn INNER JOIN
							 Org.tbType ON Org.tbOrg.OrganisationTypeCode = Org.tbType.OrganisationTypeCode AND Org.tbOrg.OrganisationTypeCode = Org.tbType.OrganisationTypeCode INNER JOIN
							 Cash.tbMode ON Org.tbType.CashModeCode = Cash.tbMode.CashModeCode AND Org.tbType.CashModeCode = Cash.tbMode.CashModeCode INNER JOIN
							 App.tbYear ON App.tbYearPeriod.YearNumber = App.tbYear.YearNumber AND App.tbYearPeriod.YearNumber = App.tbYear.YearNumber AND App.tbYearPeriod.YearNumber = App.tbYear.YearNumber AND 
							 App.tbYearPeriod.YearNumber = App.tbYear.YearNumber INNER JOIN
							 App.tbMonth ON App.tbYearPeriod.MonthNumber = App.tbMonth.MonthNumber
	WHERE        (Org.vwAssetBalances.Balance <> 0) AND (Org.vwAssetBalances.StartOn <= (SELECT TOP (1) StartOn FROM App.vwActivePeriod));
go
CREATE VIEW Org.vwAssetStatementAudit
AS
	SELECT App.tbYear.YearNumber, App.tbYear.Description, App.tbMonth.MonthName, App.tbYearPeriod.StartOn, asset_statement.AccountCode, account.AccountName, asset_statement.RowNumber, asset_statement.TransactedOn, asset_statement.Charge, asset_statement.Balance
	FROM  Org.vwAssetStatement AS asset_statement INNER JOIN
			Org.tbOrg AS account ON asset_statement.AccountCode = account.AccountCode INNER JOIN
			App.tbYearPeriod ON asset_statement.StartOn = App.tbYearPeriod.StartOn INNER JOIN
			App.tbYear ON App.tbYearPeriod.YearNumber = App.tbYear.YearNumber INNER JOIN
			App.tbMonth ON App.tbYearPeriod.MonthNumber = App.tbMonth.MonthNumber;
go
CREATE VIEW Org.vwStatementReport
AS
	SELECT  asset.AccountCode, o.AccountName, asset.RowNumber, App.tbYear.YearNumber, App.tbYear.Description, App.tbMonth.MonthName, asset.StartOn, asset.TransactedOn, asset.Reference, asset.StatementType, asset.Charge, asset.Balance
	FROM            Org.vwAssetStatement AS asset INNER JOIN
							 Org.tbOrg AS o ON o.AccountCode = asset.AccountCode INNER JOIN
							 App.tbYearPeriod ON asset.StartOn = App.tbYearPeriod.StartOn INNER JOIN
							 App.tbYear ON App.tbYearPeriod.YearNumber = App.tbYear.YearNumber AND App.tbYearPeriod.YearNumber = App.tbYear.YearNumber AND App.tbYearPeriod.YearNumber = App.tbYear.YearNumber AND 
							 App.tbYearPeriod.YearNumber = App.tbYear.YearNumber INNER JOIN
							 App.tbMonth ON App.tbYearPeriod.MonthNumber = App.tbMonth.MonthNumber;
go
IF NOT EXISTS (SELECT * FROM Usr.tbMenuEntry WHERE Argument = 'Org_BalanceSheetAudit')
BEGIN
	WITH workflow AS
	(
		SELECT MenuId, FolderId
		FROM Usr.tbMenuEntry
		WHERE ItemText = 'Information' AND Command = '0'
	), new_menu_item AS
	(
		SELECT workflow.MenuId, workflow.FolderId, menu_entry.ProjectName, MAX(menu_entry.ItemId) + 1 ItemId
		FROM workflow
			JOIN Usr.tbMenuEntry menu_entry ON workflow.MenuId = menu_entry.MenuId AND workflow.FolderId = menu_entry.FolderId
		GROUP BY workflow.MenuId, workflow.FolderId, menu_entry.ProjectName
	)
	INSERT INTO Usr.tbMenuEntry (MenuId, FolderId, ItemId, ItemText, Command, ProjectName, Argument, OpenMode)
	SELECT MenuId, FolderId, ItemId, 'Audit Balance Sheet - Orgs' ItemText, 5 Command, ProjectName, 'Org_BalanceSheetAudit' Argument, 4 OpenMode
	FROM new_menu_item;
END
go
ALTER PROCEDURE App.proc_NodeInitialisation
(
	@AccountCode NVARCHAR(10),
	@BusinessName NVARCHAR(255),
	@FullName NVARCHAR(100),
	@BusinessAddress NVARCHAR(MAX),
	@EmailAddress NVARCHAR(255),
	@PhoneNumber NVARCHAR(50),
	@CompanyNumber NVARCHAR(20),
	@VatNumber NVARCHAR(20),
	@CalendarCode NVARCHAR(10),
	@UnitOfCharge NVARCHAR(5)
)
AS
   	SET NOCOUNT, XACT_ABORT ON;

	BEGIN TRY

		BEGIN TRAN

		/***************** CONTROL DATA *****************************************/
		INSERT INTO App.tbEventType (EventTypeCode, EventType)
		VALUES (0, 'Error')
		, (1, 'Warning')
		, (2, 'Information');
	
		INSERT INTO Activity.tbAttributeType (AttributeTypeCode, AttributeType)
		VALUES (0, 'Order')
		, (1, 'Quote');

		INSERT INTO Activity.tbSyncType (SyncTypeCode, SyncType)
		VALUES (0, 'SYNC')
		, (1, 'ASYNC')
		, (2, 'CALL-OFF');

		INSERT INTO App.tbBucketInterval (BucketIntervalCode, BucketInterval)
		VALUES (0, 'Day')
		, (1, 'Week')
		, (2, 'Month');

		INSERT INTO App.tbBucketType (BucketTypeCode, BucketType)
		VALUES (0, 'Default')
		, (1, 'Sunday')
		, (2, 'Monday')
		, (3, 'Tuesday')
		, (4, 'Wednesday')
		, (5, 'Thursday')
		, (6, 'Friday')
		, (7, 'Saturday')
		, (8, 'Month');

		INSERT INTO App.tbCodeExclusion (ExcludedTag)
		VALUES ('Limited')
		, ('Ltd')
		, ('PLC');

		INSERT INTO App.tbDocClass (DocClassCode, DocClass)
		VALUES (0, 'Product')
		, (1, 'Money');

		INSERT INTO App.tbDocType (DocTypeCode, DocType, DocClassCode)
		VALUES (0, 'Quotation', 0)
		, (1, 'Sales Order', 0)
		, (2, 'Enquiry', 0)
		, (3, 'Purchase Order', 0)
		, (4, 'Sales Invoice', 1)
		, (5, 'Credit Note', 1)
		, (6, 'Debit Note', 1);

		INSERT INTO App.tbMonth (MonthNumber, MonthName)
		VALUES (1, 'JAN')
		, (2, 'FEB')
		, (3, 'MAR')
		, (4, 'APR')
		, (5, 'MAY')
		, (6, 'JUN')
		, (7, 'JUL')
		, (8, 'AUG')
		, (9, 'SEP')
		, (10, 'OCT')
		, (11, 'NOV')
		, (12, 'DEC');

		INSERT INTO App.tbRecurrence (RecurrenceCode, Recurrence)
		VALUES (0, 'On Demand')
		, (1, 'Monthly')
		, (2, 'Quarterly')
		, (3, 'Bi-annual')
		, (4, 'Yearly');

		INSERT INTO App.tbRounding (RoundingCode, Rounding)
		VALUES (0, 'Round')
		, (1, 'Truncate');


		INSERT INTO Cash.tbCategoryType (CategoryTypeCode, CategoryType)
		VALUES (0, 'Cash Code')
		, (1, 'Total')
		, (2, 'Expression');

		INSERT INTO Cash.tbEntryType (CashEntryTypeCode, CashEntryType)
		VALUES (0, 'Payment')
		, (1, 'Invoice')
		, (2, 'Order')
		, (3, 'Quote')
		, (4, 'Corporation Tax')
		, (5, 'Vat')
		, (6, 'Forecast');

		INSERT INTO Cash.tbMode (CashModeCode, CashMode)
		VALUES (0, 'Expense')
		, (1, 'Income')
		, (2, 'Neutral');

		INSERT INTO Cash.tbStatus (CashStatusCode, CashStatus)
		VALUES (0, 'Forecast')
		, (1, 'Current')
		, (2, 'Closed')
		, (3, 'Archived');

		INSERT INTO Cash.tbTaxType (TaxTypeCode, TaxType, MonthNumber, RecurrenceCode, OffsetDays)
		VALUES (0, 'Corporation Tax', 12, 4, 0)
		, (1, 'Vat', 4, 2, 31)
		, (2, 'N.I.', 4, 1, 0)
		, (3, 'General', 4, 0, 0);

		INSERT INTO Cash.tbType (CashTypeCode, CashType)
		VALUES (0, 'TRADE')
		, (1, 'EXTERNAL')
		, (2, 'MONEY');

		INSERT INTO Invoice.tbStatus (InvoiceStatusCode, InvoiceStatus)
		VALUES (1, 'Invoiced')
		, (2, 'Partially Paid')
		, (3, 'Paid')
		, (0, 'Pending');

		INSERT INTO Invoice.tbType (InvoiceTypeCode, InvoiceType, CashModeCode, NextNumber)
		VALUES (0, 'Sales Invoice', 1, 10000)
		, (1, 'Credit Note', 0, 20000)
		, (2, 'Purchase Invoice', 0, 30000)
		, (3, 'Debit Note', 1, 40000);

		IF NOT EXISTS (SELECT * FROM Cash.tbPaymentStatus)
		BEGIN
			INSERT INTO Cash.tbPaymentStatus (PaymentStatusCode, PaymentStatus)
			VALUES (0, 'Unposted')
			, (1, 'Payment')
			, (2, 'Transfer');
		END

		INSERT INTO Org.tbStatus (OrganisationStatusCode, OrganisationStatus)
		VALUES (0, 'Pending')
		, (1, 'Active')
		, (2, 'Hot')
		, (3, 'Dead');

		INSERT INTO Task.tbOpStatus (OpStatusCode, OpStatus)
		VALUES (0, 'Pending')
		, (1, 'In-progress')
		, (2, 'Complete');

		INSERT INTO Task.tbStatus (TaskStatusCode, TaskStatus)
		VALUES (0, 'Pending')
		, (1, 'Open')
		, (2, 'Closed')
		, (3, 'Charged')
		, (4, 'Cancelled')
		, (5, 'Archive');

		INSERT INTO Usr.tbMenuCommand (Command, CommandText)
		VALUES (0, 'Folder')
		, (1, 'Link')
		, (2, 'Form In Read Mode')
		, (3, 'Form In Add Mode')
		, (4, 'Form In Edit Mode')
		, (5, 'Report');

		INSERT INTO Usr.tbMenuOpenMode (OpenMode, OpenModeDescription)
		VALUES (0, 'Normal')
		, (1, 'Datasheet')
		, (2, 'Default Printing')
		, (3, 'Direct Printing')
		, (4, 'Print Preview')
		, (5, 'Email RTF')
		, (6, 'Email HTML')
		, (7, 'Email Snapshot')
		, (8, 'Email PDF');

		INSERT INTO App.tbRegister (RegisterName, NextNumber)
		VALUES ('Expenses', 40000)
		, ('Event Log', 1)
		, ('Project', 30000)
		, ('Purchase Order', 20000)
		, ('Sales Order', 10000);

		INSERT INTO App.tbDoc (DocTypeCode, ReportName, OpenMode, Description)
		VALUES (0, 'Task_QuotationStandard', 2, 'Standard Quotation')
		, (0, 'Task_QuotationTextual', 2, 'Textual Quotation')
		, (1, 'Task_SalesOrder', 2, 'Standard Sales Order')
		, (2, 'Task_PurchaseEnquiryDeliveryStandard', 2, 'Standard Transport Enquiry')
		, (2, 'Task_PurchaseEnquiryDeliveryTextual', 2, 'Textual Transport Enquiry')
		, (2, 'Task_PurchaseEnquiryStandard', 2, 'Standard Purchase Enquiry')
		, (2, 'Task_PurchaseEnquiryTextual', 2, 'Textual Purchase Enquiry')
		, (3, 'Task_PurchaseOrder', 2, 'Standard Purchase Order')
		, (3, 'Task_PurchaseOrderDelivery', 2, 'Purchase Order for Delivery')
		, (4, 'Invoice_Sales', 2, 'Standard Sales Invoice')
		, (4, 'Invoice_SalesLetterhead', 2, 'Sales Invoice for Letterhead Paper')
		, (5, 'Invoice_CreditNote', 2, 'Standard Credit Note')
		, (5, 'Invoice_CreditNoteLetterhead', 2, 'Credit Note for Letterhead Paper')
		, (6, 'Invoice_DebitNote', 2, 'Standard Debit Note')
		, (6, 'Invoice_DebitNoteLetterhead', 2, 'Debit Note for Letterhead Paper');

		INSERT INTO Org.tbType (OrganisationTypeCode, CashModeCode, OrganisationType)
		VALUES (0, 0, 'Non-Approved Supplier')
		, (1, 1, 'Customer')
		, (2, 1, 'Prospect')
		, (4, 1, 'Company')
		, (5, 0, 'Bank')
		, (7, 0, 'Other')
		, (8, 0, 'Approved Supplier')
		, (9, 0, 'Employee');

		INSERT INTO App.tbText (TextId, Message, Arguments)
		VALUES (1003, 'Enter new menu name', 0)
		, (1004, 'Team Menu', 0)
		, (1005, 'Ok to delete <1>', 1)
		, (1006, 'Documents cannot be converted into folders. Either delete the document or create a new folder elsewhere on the menu. Press esc key to undo changes.', 0)
		, (1007, '<Menu Item Text>', 0)
		, (1008, 'Documents cannot have other menu items added to them. Please select a folder then try again.', 0)
		, (1009, 'The root cannot be deleted. Please modify the text or remove the menu itself.', 0)
		, (1189, 'Error <1>', 1)
		, (1190, '<1> Source: <2>  (err <3>) <4>', 4)
		, (1192, 'Server error listing:', 0)
		, (1193, 'days', 0)
		, (1194, 'Ok to delete the selected task and all tasks upon which it depends?', 0)
		, (1208, 'A/No: <3>, Ref.: <2>, Title: <4>, Status: <6>. Dear <1>, <5> <7>', 7)
		, (1209, 'Yours sincerely, <1> <2> T: <3> M: <4> W: <5>', 5)
		, (1210, 'Okay to cancel invoice <1>?', 1)
		, (1211, 'Invoice <1> cannot be cancelled because there are payments assigned to it.  Use the debit/credit facility if this account is not properly reconciled.', 1)
		, (1212, 'Invoices are outstanding against account <1>.	By specifying a cash code, invoices will not be matched. Cash codes should only be entered for miscellaneous charges.', 1)
		, (1213, 'Account <1> has no invoices outstanding for this payment and therefore cannot be posted. Please specify a cash code so that one can be automatically generated.', 1)
		, (1214, 'Invoiced', 0)
		, (1215, 'Ordered', 0)
		, (1217, 'Order charge differs from the invoice. Reconcile <1>?', 1)
		, (1218, 'Raise invoice and pay expenses now?', 0)
		, (1219, 'Reserve Balance', 0)
		, (2002, 'Only administrators have access to the system configuration features of this application.', 0)
		, (2003, 'You are not a registered user of this system. Please contact the Administrator if you believe you should have access.', 0)
		, (2004, 'The primary key you have entered contains invalid characters. Digits and letters should be used for these keys. Please amend accordingly or press Esc to cancel.', 0)
		, (2136, 'You have attempted to execute an Application.Run command with an invalid string. The run string is <1>. The error is <2>', 2)
		, (2188, '<1>', 1)
		, (2206, 'Reminder: You are due for a period end close down.  Please follow the relevant procedures to complete this task. Once all financial data has been consolidated, use the Administrator to move onto the next period.', 0)
		, (2312, 'The system is not setup correctly. Make sure you have completed the initialisation procedures then try again.', 0)
		, (3002, 'Periods not generated successfully. Contact support.', 0)
		, (3003, 'Okay to close down the active period? Before proceeding make sure that you have entered and checked your cash details. All invoices and cash transactions will be transferred into the Cash Flow analysis module.', 0)
		, (3004, 'Margin', 0)
		, (3005, 'Opening Balance', 0)
		, (3006, 'Rebuild executed successfully', 0)
		, (3007, 'Ok to rebuild cash accounts? Make sure no transactions are being processed, as this will re-set and update all your invoices.', 0)
		, (3009, 'Charged', 0)
		, (3010, 'Service', 0)
		, (3011, 'Ok to rebuild cash flow history for account <1>? This would normally be required when payments or invoices have been retrospectively revised, or opening balances altered.', 1)
		, (3012, 'Ok to raise an invoice for this task? Use the Invoicing program to create specific invoice types with multiple tasks and additional charges.', 0)
		, (3013, 'Current Balance', 0)
		, (3014, 'This entry cannot be rescheduled', 0)
		, (3015, 'Dummy accounts should not be assigned a cash code', 0)
		, (3016, 'Operations cannot end before they have been started', 0)
		, (3017, 'Cash codes must be of catagory type MONEY', 0)
		, (3018, 'The balance for this account is zero. Check for unposted payments.', 0);

		/***************** BUSINESS DATA *****************************************/

		INSERT INTO Org.tbOrg (AccountCode, AccountName, OrganisationTypeCode, OrganisationStatusCode, PhoneNumber, EmailAddress, CompanyNumber, VatNumber)
		VALUES (@AccountCode, @BusinessName, 4, 1, @PhoneNumber, @EmailAddress, @CompanyNumber, @VatNumber);

		EXEC Org.proc_AddContact @AccountCode = @AccountCode, @ContactName = @FullName;
		EXEC Org.proc_AddAddress @AccountCode = @AccountCode, @Address = @BusinessAddress;

		INSERT INTO App.tbCalendar (CalendarCode, Monday, Tuesday, Wednesday, Thursday, Friday, Saturday, Sunday)
		VALUES (@CalendarCode, 1, 1, 1, 1, 1, 0, 0)
		;

		INSERT INTO Usr.tbUser (UserId, UserName, LogonName, IsAdministrator, IsEnabled, CalendarCode, EmailAddress, PhoneNumber)
		VALUES (CONCAT(LEFT(@FullName, 1), SUBSTRING(@FullName, CHARINDEX(' ', @FullName) + 1, 1)), @FullName, 
			SUSER_NAME() , 1, 1, @CalendarCode, @EmailAddress, @PhoneNumber)

		INSERT INTO App.tbOptions (Identifier, IsInitialised, AccountCode, RegisterName, DefaultPrintMode, BucketIntervalCode, BucketTypeCode, TaxHorizon, IsAutoOffsetDays, UnitOfCharge)
		VALUES ('TC', 0, @AccountCode, 'Event Log', 2, 1, 1, 730, 0, @UnitOfCharge);

		SET IDENTITY_INSERT Usr.tbMenu ON;
		INSERT INTO Usr.tbMenu (MenuId, MenuName)
		VALUES (1, 'Administrator')
		SET IDENTITY_INSERT Usr.tbMenu OFF;

		SET IDENTITY_INSERT Usr.tbMenuEntry ON;
		INSERT INTO Usr.tbMenuEntry (MenuId, EntryId, FolderId, ItemId, ItemText, Command, ProjectName, Argument, OpenMode)
		VALUES (1, 1, 1, 0, 'Administrator', 0, '', 'Root', 0)
		, (1, 2, 2, 0, 'Settings', 0, 'Trader', '', 0)
		, (1, 4, 2, 1, 'Administration', 4, 'Trader', 'App_Admin', 0)
		, (1, 5, 2, 2, 'SQL Connect', 4, 'Trader', 'Sys_SQLConnect', 0)
		, (1, 16, 2, 5, 'Definitions', 4, 'Trader', 'App_Definition', 0)
		, (1, 23, 4, 0, 'Maintenance', 0, 'Trader', '', 0)
		, (1, 25, 4, 1, 'Organisations', 4, 'Trader', 'Org_Maintenance', 0)
		, (1, 29, 4, 2, 'Activities', 4, 'Trader', 'Activity_Edit', 0)
		, (1, 30, 5, 0, 'Work Flow', 0, 'Trader', '', 0)
		, (1, 32, 5, 1, 'Task Explorer', 4, 'Trader', 'Task_Explorer', 0)
		, (1, 33, 5, 2, 'Document Manager', 4, 'Trader', 'App_DocManager', 0)
		, (1, 34, 5, 3, 'Raise Invoices', 4, 'Trader', 'Invoice_Raise', 0)
		, (1, 35, 6, 0, 'Information', 0, 'Trader', '', 0)
		, (1, 37, 6, 1, 'Organisation Enquiry', 2, 'Trader', 'Org_Enquiry', 0)
		, (1, 38, 6, 2, 'Invoice Register', 4, 'Trader', 'Invoice_Register', 0)
		, (1, 40, 6, 3, 'Cash Statements', 4, 'Trader', 'Org_PaymentAccount', 0)
		, (1, 41, 6, 4, 'Data Warehouse', 4, 'Trader', 'App_Warehouse', 0)
		, (1, 42, 6, 5, 'Company Statement', 4, 'Trader', 'Cash_Statement', 0)
		, (1, 43, 4, 3, 'Organisation Datasheet', 4, 'Trader', 'Org_Maintenance', 1)
		, (1, 44, 6, 6, 'Job Profit Status by Month', 4, 'Trader', 'Task_ProfitStatus', 0)
		, (1, 46, 5, 6, 'Expenses', 3, 'Trader', 'Task_Expenses', 0)
		, (1, 47, 1, 1, 'Settings', 1, '', '2', 0)
		, (1, 49, 1, 3, 'Maintenance', 1, '', '4', 0)
		, (1, 50, 1, 4, 'Work Flow', 1, '', '5', 0)
		, (1, 51, 1, 5, 'Information', 1, '', '6', 0)
		, (1, 52, 6, 7, 'Status Graphs', 4, 'Trader', 'Cash_StatusGraphs', 0)
		, (1, 53, 2, 4, 'Service Event Log', 2, 'Trader', 'App_EventLog', 1)
		, (1, 55, 4, 4, 'Budget', 4, 'Trader', 'Cash_Budget', 0)
		, (1, 62, 4, 5, 'Assets', 4, 'Trader', 'Cash_Assets', 0)
		, (1, 66, 6, 9, 'Audit Accruals - Corporation Tax', 5, 'Trader', 'Cash_CorpTaxAuditAccruals', 4)
		, (1, 67, 6, 8, 'Audit Accruals - VAT', 5, 'Trader', 'Cash_VatAuditAccruals', 4)
		, (1, 68, 5, 7, 'Network Allocations', 4, 'Trader', 'Task_Allocation', 0)
		, (1, 69, 5, 8, 'Network Invoices', 4, 'Trader', 'Invoice_Mirror', 0)
		, (1, 70, 6, 10, 'Audit Balance Sheet - Orgs', 5, 'Trader', 'Org_BalanceSheetAudit', 4)
		;

		IF @UnitOfCharge <> 'BTC'
		BEGIN
			INSERT INTO Usr.tbMenuEntry (MenuId, EntryId, FolderId, ItemId, ItemText, Command, ProjectName, Argument, OpenMode)
			VALUES 
				(1, 54, 5, 5, 'Transfers', 4, 'Trader', 'Cash_Transfer', 0)
				, (1, 39, 5, 4, 'Payment Entry', 4, 'Trader', 'Cash_PaymentEntry', 0)
		END

		SET IDENTITY_INSERT Usr.tbMenuEntry OFF;

		INSERT INTO Usr.tbMenuUser (UserId, MenuId)
		SELECT (SELECT UserId FROM Usr.tbUser) AS UserId, (SELECT MenuId FROM Usr.tbMenu) AS MenuId;

		COMMIT TRAN
  	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
go
CREATE VIEW Cash.vwBalanceSheetTax
AS
	SELECT tax_type.AssetCode, tax_type.AssetName, 
		CAST(0 as smallint) CashModeCode,  
		CAST(1 as smallint) AssetTypeCode,  
		DATEADD(MONTH, 1, DATEADD(DAY, (DATEPART(DAY, StartOn) * -1) + 1, StartOn)) StartOn, 		
		Balance * -1 Balance 
	FROM Cash.vwTaxCorpStatement
		CROSS JOIN
		(
			SELECT UPPER(LEFT(TaxType, 3)) AssetCode, UPPER(TaxType) AssetName
			FROM Cash.tbTaxType
			WHERE TaxTypeCode = 0
		) tax_type;
go
CREATE VIEW Cash.vwBalanceSheetVat
AS
	SELECT tax_type.AssetCode, tax_type.AssetName, 
		CAST(0 as smallint) CashModeCode,  
		CAST(1 as smallint) AssetTypeCode,  
		DATEADD(MONTH, 1, DATEADD(DAY, (DATEPART(DAY, StartOn) * -1) + 1, StartOn)) StartOn, 		
		Balance * -1 Balance 
	FROM Cash.vwTaxVatStatement
		CROSS JOIN
		(
			SELECT UPPER(LEFT(TaxType, 3)) AssetCode, UPPER(TaxType) AssetName
			FROM Cash.tbTaxType
			WHERE TaxTypeCode = 1
		) tax_type;
go
ALTER VIEW Cash.vwBalanceSheetPeriods
AS
	WITH financial_periods AS
	(
		SELECT yr.YearNumber, pd.StartOn
		FROM App.tbYear yr
			JOIN App.tbYearPeriod pd ON yr.YearNumber = pd.YearNumber
		WHERE (yr.CashStatusCode BETWEEN 1 AND 2)
	), assets AS
	(
		SELECT CashAccountCode AssetCode, CashAccountName AssetName, LiquidityLevel, CAST(4 as smallint) AssetTypeCode, 
			category.CashModeCode,
			YearNumber, StartOn
		FROM Org.tbAccount account
			JOIN Cash.tbCode cash_code ON account.CashCode = cash_code.CashCode
			JOIN Cash.tbCategory category ON cash_code.CategoryCode = category.CategoryCode
			CROSS JOIN financial_periods
		WHERE (AccountTypeCode= 2) AND (AccountClosed = 0)
	), cash AS
	(
		SELECT CashAccountCode AssetCode, AssetType AssetName, LiquidityLevel, AssetTypeCode, CAST(1 as smallint) CashModeCode, YearNumber, StartOn
		FROM Cash.tbAssetType
			CROSS JOIN Cash.vwCurrentAccount 
			CROSS JOIN financial_periods
		WHERE AssetTypeCode = 3
	), bank AS
	(
		SELECT CashAccountCode AssetCode, AssetType AssetName, LiquidityLevel, AssetTypeCode, CAST(1 as smallint) CashModeCode, YearNumber, StartOn
		FROM Cash.tbAssetType
			CROSS JOIN Cash.vwReserveAccount 
			CROSS JOIN financial_periods
		WHERE AssetTypeCode = 2
	), orgs AS
	(
		SELECT CashAccountCode AssetCode, AssetType AssetName, LiquidityLevel, AssetTypeCode,
			CAST(CASE AssetTypeCode WHEN 0 THEN 1 ELSE 0 END as smallint) CashModeCode,
			YearNumber, StartOn
		FROM Cash.tbAssetType
			CROSS JOIN Cash.vwCurrentAccount
			CROSS JOIN financial_periods
		WHERE AssetTypeCode BETWEEN 0 AND 1
	), tax AS
	(
		SELECT UPPER(LEFT(TaxType, 3)) AssetCode, UPPER(TaxType) AssetName, CAST(1 as smallint) LiquidityLevel, CAST(1 as smallint) AssetTypeCode, CAST(0 as smallint) CashModeCode,
			YearNumber, StartOn
		FROM Cash.tbTaxType
			CROSS JOIN financial_periods
		WHERE TaxTypeCode BETWEEN 0 AND 1

	), asset_code_periods AS
	(
		SELECT AssetCode, AssetName, CashModeCode, LiquidityLevel, AssetTypeCode, YearNumber, StartOn FROM assets
		UNION 
		SELECT AssetCode, AssetName, CashModeCode, LiquidityLevel, AssetTypeCode, YearNumber, StartOn FROM cash
		UNION
		SELECT AssetCode, AssetName, CashModeCode, LiquidityLevel, AssetTypeCode, YearNumber, StartOn FROM bank
		UNION
		SELECT AssetCode, AssetName, CashModeCode, LiquidityLevel, AssetTypeCode, YearNumber, StartOn FROM orgs
		UNION
		SELECT AssetCode, AssetName, CashModeCode, LiquidityLevel, AssetTypeCode, YearNumber, StartOn FROM tax
	)
	SELECT AssetCode, AssetName, CashModeCode, LiquidityLevel, AssetTypeCode, YearNumber, StartOn, CAST(0 as bit) IsEntry
	FROM asset_code_periods;
go
ALTER VIEW Cash.vwBalanceSheet
AS
	WITH balance_sheets AS
	(

		SELECT AssetCode, AssetName, CashModeCode, AssetTypeCode, StartOn, Balance FROM Cash.vwBalanceSheetOrgs
		UNION
		SELECT AssetCode, AssetName, CashModeCode, AssetTypeCode, StartOn, Balance FROM Cash.vwBalanceSheetAccounts
		UNION 
		SELECT AssetCode, AssetName, CashModeCode, AssetTypeCode, StartOn, Balance FROM Cash.vwBalanceSheetAssets
		UNION 
		SELECT AssetCode, AssetName, CashModeCode, AssetTypeCode, StartOn, Balance FROM Cash.vwBalanceSheetTax
		UNION
		SELECT AssetCode, AssetName, CashModeCode, AssetTypeCode, StartOn, Balance FROM Cash.vwBalanceSheetVat

	), balance_sheet_unordered AS
	(
		SELECT 
			balance_sheet_periods.AssetCode, balance_sheet_periods.AssetName,
			CASE WHEN balance_sheets.AssetCode IS NULL 
				THEN balance_sheet_periods.CashModeCode 
				ELSE balance_sheets.CashModeCode 
			END CashModeCode, LiquidityLevel,
			balance_sheet_periods.StartOn,
			CASE WHEN balance_sheets.AssetCode IS NULL 
				THEN 0 
				ELSE balance_sheets.Balance 
			END Balance,
			CASE WHEN balance_sheets.AssetCode IS NULL 
				THEN balance_sheet_periods.IsEntry 
				ELSE CAST(1 as bit) 
			END IsEntry
		FROM Cash.vwBalanceSheetPeriods balance_sheet_periods
			LEFT OUTER JOIN balance_sheets
				ON balance_sheet_periods.AssetCode = balance_sheets.AssetCode
					AND balance_sheet_periods.AssetName = balance_sheets.AssetName
					AND balance_sheet_periods.CashModeCode = balance_sheets.CashModeCode
					AND balance_sheet_periods.StartOn = balance_sheets.StartOn
	), balance_sheet_ordered AS
	(
		SELECT 
			ROW_NUMBER() OVER (ORDER BY CashModeCode desc, LiquidityLevel desc, AssetName, StartOn) EntryNumber,
			AssetCode, AssetName, CashModeCode, LiquidityLevel, StartOn, Balance, IsEntry
		FROM balance_sheet_unordered
	), balance_sheet_ranked AS
	(
		SELECT *, 
		RANK() OVER (PARTITION BY AssetName, CashModeCode, IsEntry ORDER BY EntryNumber) RNK
		FROM balance_sheet_ordered
	), balance_sheet_grouped AS
	(
		SELECT EntryNumber, AssetCode, AssetName, CashModeCode, LiquidityLevel, StartOn, Balance, IsEntry,
		MAX(CASE IsEntry WHEN 0 THEN 0 ELSE RNK END) OVER (PARTITION BY AssetName, CashModeCode ORDER BY EntryNumber) RNK
		FROM balance_sheet_ranked
	)
	SELECT EntryNumber, AssetCode, AssetName, CashModeCode, LiquidityLevel, StartOn, IsEntry,
		CASE IsEntry WHEN 0 THEN
			MAX(Balance) OVER (PARTITION BY AssetName, CashModeCode, RNK ORDER BY EntryNumber) +
			MIN(Balance) OVER (PARTITION BY AssetName, CashModeCode, RNK ORDER BY EntryNumber) 
		ELSE
			Balance
		END AS Balance
	FROM balance_sheet_grouped

go
