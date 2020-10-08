/**************************************************************************************
Trade Control
Upgrade script
Release: 3.30.4

Date: 8 October 2020
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
ALTER VIEW Cash.vwBalanceSheetTax
AS
	WITH tax_dates AS
	(
		SELECT (SELECT TOP 1 StartOn FROM App.tbYearPeriod WHERE StartOn < PayTo ORDER BY StartOn DESC) PayOn, 
			PayFrom, PayTo FROM Cash.fnTaxTypeDueDates(0)
	), period_totals AS
	(
		SELECT (SELECT PayOn FROM tax_dates WHERE totals.StartOn >= PayFrom AND totals.StartOn < PayTo) AS StartOn, CorporationTax
		FROM Cash.vwTaxCorpTotalsByPeriod totals
	), tax_entries AS
	(
		SELECT StartOn, SUM(CorporationTax) AS TaxDue, 0 AS TaxPaid
		FROM period_totals
		WHERE NOT StartOn IS NULL
		GROUP BY StartOn
		
		UNION

		SELECT (SELECT TOP (1) StartOn FROM App.tbYearPeriod WHERE (StartOn <= Cash.tbPayment.PaidOn) ORDER BY StartOn DESC) AS StartOn, 
			0 As TaxDue, ( Cash.tbPayment.PaidOutValue * -1) + Cash.tbPayment.PaidInValue AS TaxPaid
		FROM Cash.tbPayment 
			JOIN Cash.tbTaxType tt ON Cash.tbPayment.CashCode = tt.CashCode
		WHERE (tt.TaxTypeCode = 0)

	)
	, tax_balances AS
	(
		SELECT StartOn, TaxDue, TaxPaid,
			SUM(TaxDue + TaxPaid) OVER (ORDER BY StartOn, TaxDue ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS Balance
		FROM tax_entries
	), tax_statement AS
	(
		SELECT StartOn, CAST(TaxDue AS decimal(18, 5)) TaxDue, CAST(TaxPaid AS decimal(18, 5)) TaxPaid, CAST(Balance AS decimal(18, 5)) Balance FROM tax_balances 
		WHERE StartOn >= (SELECT MIN(StartOn) FROM App.tbYearPeriod p JOIN App.tbYear y ON p.YearNumber = y.YearNumber  WHERE y.CashStatusCode < 3)
	)
	SELECT tax_type.AssetCode, tax_type.AssetName, 
		CAST(0 as smallint) CashModeCode,  
		CAST(1 as smallint) AssetTypeCode,  
		StartOn, 		
		CASE WHEN Balance < 0 THEN 0 ELSE Balance * -1 END Balance 
	FROM tax_statement
		CROSS JOIN
		(
			SELECT UPPER(LEFT(TaxType, 3)) AssetCode, UPPER(TaxType) AssetName
			FROM Cash.tbTaxType
			WHERE TaxTypeCode = 0
		) tax_type;
go
ALTER VIEW Cash.vwBalanceSheetVat
AS
	WITH vat_due AS 
	(	
		SELECT StartOn, SUM(VatDue) AS VatDue
		FROM Cash.vwTaxVatSummary 
		GROUP BY StartOn
	), vat_paid AS
	(
		SELECT vat_due.StartOn, VatDue - VatAdjustment VatDue, 0 VatPaid
		FROM vat_due
			JOIN App.tbYearPeriod year_period ON vat_due.StartOn = year_period.StartOn

		UNION

		SELECT (SELECT TOP (1) StartOn FROM App.tbYearPeriod WHERE (StartOn <= Cash.tbPayment.PaidOn) ORDER BY StartOn DESC) AS StartOn, 
			0 As VatDue, ( Cash.tbPayment.PaidOutValue * -1) + Cash.tbPayment.PaidInValue AS VatPaid
		FROM Cash.tbPayment 
			JOIN Cash.tbTaxType vat_codes ON Cash.tbPayment.CashCode = vat_codes.CashCode	
		WHERE (vat_codes.TaxTypeCode = 1)
	), vat_unordered AS
	(
		SELECT StartOn, SUM(VatDue) VatDue, SUM(VatPaid) VatPaid
		FROM vat_paid
		GROUP BY StartOn
	), vat_ordered AS
	(
		SELECT ROW_NUMBER() OVER (ORDER BY StartOn, VatDue) AS RowNumber,
			StartOn, VatDue, VatPaid
		FROM vat_unordered
	), vat_balance AS
	(
		SELECT RowNumber, StartOn, VatDue, VatPaid,
			SUM(VatDue+VatPaid) OVER (ORDER BY RowNumber ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS Balance
		FROM vat_ordered
	), vat_statement AS
	(
		SELECT RowNumber, StartOn, CAST(VatDue as float) VatDue, CAST(VatPaid as float) VatPaid, CAST(Balance as decimal(18,5)) Balance
		FROM vat_balance
		WHERE StartOn >= (SELECT MIN(StartOn) FROM App.tbYearPeriod p JOIN App.tbYear y ON p.YearNumber = y.YearNumber  WHERE y.CashStatusCode < 3)
	)
	SELECT tax_type.AssetCode, tax_type.AssetName, 
		CAST(0 as smallint) CashModeCode,  
		CAST(1 as smallint) AssetTypeCode,  
		StartOn, 
		CASE WHEN Balance < 0 THEN 0 ELSE Balance * -1 END Balance 
	FROM vat_statement
		CROSS JOIN
		(
			SELECT UPPER(LEFT(TaxType, 3)) AssetCode, UPPER(TaxType) AssetName
			FROM Cash.tbTaxType
			WHERE TaxTypeCode = 1
		) tax_type;
go
ALTER VIEW Cash.vwTaxVatStatement
AS
	WITH vat_dates AS
	(
		SELECT PayOn, PayFrom, PayTo FROM Cash.fnTaxTypeDueDates(1)
	), vatPeriod AS
	(
		SELECT        StartOn, 
			(SELECT PayTo FROM vat_dates WHERE StartOn >= PayFrom AND StartOn < PayTo) AS VatStartOn, VatAdjustment
		FROM            App.tbYearPeriod 
	), vat_codes AS
	(
		SELECT     CashCode
		FROM         Cash.tbTaxType
		WHERE     (TaxTypeCode = 1)
	)
	, vat_results AS
	(
		SELECT VatStartOn AS StartOn, SUM(VatDue) AS VatDue
		FROM Cash.vwTaxVatSummary vatCodeDue JOIN vatPeriod ON vatCodeDue.StartOn = vatPeriod.StartOn
		GROUP BY VatStartOn
	), vat_adjustments AS
	(
		SELECT VatStartOn AS StartOn, SUM(VatAdjustment) AS VatAdjustment
		FROM vatPeriod
		GROUP BY VatStartOn
	), vat_unordered AS
	(
		SELECT vat_dates.PayOn AS StartOn, VatDue - a.VatAdjustment AS VatDue, 0 As VatPaid		
		FROM vat_results r JOIN vat_adjustments a ON r.StartOn = a.StartOn
			JOIN vat_dates ON r.StartOn = vat_dates.PayTo
			UNION
		SELECT     Cash.tbPayment.PaidOn AS StartOn, 0 As VatDue, ( Cash.tbPayment.PaidOutValue * -1) + Cash.tbPayment.PaidInValue AS VatPaid
		FROM         Cash.tbPayment INNER JOIN
							  vat_codes ON Cash.tbPayment.CashCode = vat_codes.CashCode	
	), vat_ordered AS
	(
		SELECT ROW_NUMBER() OVER (ORDER BY StartOn, VatDue) AS RowNumber,
			StartOn, VatDue, VatPaid
		FROM vat_unordered
	), vat_statement AS
	(
		SELECT RowNumber, StartOn, VatDue, VatPaid,
			SUM(VatDue+VatPaid) OVER (ORDER BY RowNumber ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS Balance
		FROM vat_ordered
	)
	SELECT RowNumber, StartOn, CAST(VatDue as float) VatDue, CAST(VatPaid as float) VatPaid, CAST(Balance as decimal(18,5)) Balance
	FROM vat_statement
	WHERE StartOn >= (SELECT MIN(StartOn) FROM App.tbYearPeriod p JOIN App.tbYear y ON p.YearNumber = y.YearNumber  WHERE y.CashStatusCode < 3);
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
		VALUES (0, 'Corporation Tax', 12, 4, 275)
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
		VALUES ('AS', 'Assets', 0, 1, 2, 70, 0)
		, ('BA', 'Bank Accounts', 0, 2, 2, 80, 1)
		, ('BP', 'Bank Payments', 0, 0, 0, 90, 1)
		, ('BR', 'Bank Receipts', 0, 1, 0, 100, 1)
		, ('DC', 'Direct Cost', 0, 0, 0, 20, 1)
		, ('DI', 'Dividends', 0, 0, 0, 110, -1)
		, ('DR', 'Drawings', 0, 2, 0, 150, 0)
		, ('IC', 'Indirect Cost', 0, 0, 0, 30, 1)
		, ('IP', 'Intercompany Payment', 0, 0, 2, 120, 1)
		, ('IR', 'Intercompany Receipt', 0, 1, 2, 130, 1)
		, ('IV', 'Investment', 0, 2, 0, 160, 0)
		, ('LI', 'Liabilities', 0, 0, 2, 71, 0)
		, ('SA', 'Sales', 0, 1, 0, 10, 1)
		, ('TA', 'Taxes', 0, 0, 1, 60, 1)
		, ('WA', 'Wages', 0, 0, 0, 50, 1)
		;

		INSERT INTO [Cash].[tbCategory] ([CategoryCode], [Category], [CategoryTypeCode], [CashModeCode], [CashTypeCode], [DisplayOrder], [IsEnabled])
		VALUES ('GP', 'Gross Profit', 1, 2, 0, 1, 1)
		, ('NP', 'Net Profit', 1, 2, 0, 2, 1)
		, ('VAT', 'Vat Cash Codes', 1, 2, 0, 3, 1)
		, ('WR', 'Wages Ratio', 2, 2, 0, 0, 1)
		, ('GM', 'Gross Margin', 2, 2, 0, 1, 1)

		INSERT INTO [Cash].[tbCategoryExp] ([CategoryCode], [Expression], [Format])
		VALUES ('WR', 'IF([Sales]=0,0,(ABS([Wages])/[Sales]))', '0%')
		, ('GM', 'IF([Sales]=0,0,([Gross Profit]/[Sales]))', '0%')
		;
		INSERT INTO [Cash].[tbCategoryTotal] ([ParentCode], [ChildCode])
		VALUES ('GP', 'DC')
		, ('GP', 'SA')
		, ('GP', 'WA')
		, ('NP', 'GP')
		, ('NP', 'IC')
		, ('VAT', 'DC')
		, ('VAT', 'IC')
		, ('VAT', 'SA')
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
		, ('701', 'Depreciation', 'AS', 'N/A', 0)
		, ('702', 'Dept Repayment', 'LI', 'N/A', 0)
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
		VALUES        (@CashAccountCode, @AccountCode, @CapitalAccount, 2, 50, '702', 1)

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

