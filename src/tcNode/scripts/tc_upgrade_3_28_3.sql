/**************************************************************************************
Trade Control
Upgrade script
Release: 3.28.3

Date: 01 July 2020
Author: IAM

Trade Control by Trade Control Ltd is licensed under GNU General Public License v3.0. 

You may obtain a copy of the License at

	https://www.gnu.org/licenses/gpl-3.0.en.html

Change log:

	https://github.com/tradecontrol/tc-nodecore

Instructions:
This script should be applied by the TC Node Configuration app.
It inserts the upgade into App.tbInstall.


***********************************************************************************/
go
CREATE OR ALTER PROCEDURE App.proc_NodeInitialisation
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
		, (2, 'BANK');

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
		, (3017, 'Cash codes must be of catagory type BANK', 0)
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
		, (1, 66, 6, 9, 'Audit Accruals - Corporation Tax', 5, 'Trader', 'Cash_CorpTaxAuditAccruals', 4)
		, (1, 67, 6, 8, 'Audit Accruals - VAT', 5, 'Trader', 'Cash_VatAuditAccruals', 4)
		, (1, 68, 5, 7, 'Network Allocations', 4, 'Trader', 'Task_Allocation', 0)
		, (1, 69, 5, 8, 'Network Invoices', 4, 'Trader', 'Invoice_Mirror', 0)
		;

		IF @UnitOfCharge <> 'BTC'
		BEGIN
			INSERT INTO Usr.tbMenuEntry (MenuId, EntryId, FolderId, ItemId, ItemText, Command, ProjectName, Argument, OpenMode)
			VALUES 
				(1, 39, 5, 4, 'Payment Entry', 4, 'Trader', 'Cash_PaymentEntry', 0)
				, (1, 54, 5, 5, 'Transfers', 4, 'Trader', 'Cash_Transfer', 0)
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
CREATE OR ALTER PROCEDURE App.proc_BasicSetup
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
		SET @CoinTypeCode = 2
	ELSE IF @CoinTypeCode = 2
		SET @CoinTypeCode = 1;

	IF DATEPART(MONTH, CURRENT_TIMESTAMP) < @FinancialMonth
		 SET @FinancialYear -= 1;

	DECLARE 
		@AccountCode NVARCHAR(10),
		@CashAccountCode NVARCHAR(10),
		@Year SMALLINT = @FinancialYear;

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
		VALUES ('BA', 'Bank Accounts', 0, 2, 2, 8, 1)
		, ('BP', 'Bank Payments', 0, 0, 0, 9, 1)
		, ('BR', 'Bank Receipts', 0, 1, 0, 10, 1)
		, ('DC', 'Direct Cost', 0, 0, 0, 2, 1)
		, ('DI', 'Dividends', 0, 0, 0, 11, -1)
		, ('DR', 'Drawings', 0, 2, 0, 15, 0)
		, ('IC', 'Indirect Cost', 0, 0, 0, 3, 1)
		, ('IP', 'Intercompany Payment', 0, 0, 2, 12, 1)
		, ('IR', 'Intercompany Receipt', 0, 1, 2, 13, 1)
		, ('IV', 'Investment', 0, 2, 0, 16, 0)
		, ('SA', 'Sales', 0, 1, 0, 1, 1)
		, ('SI', 'Startup Investment', 0, 1, 0, 17, 1)
		, ('TA', 'Taxes', 0, 0, 1, 6, 1)
		, ('WA', 'Wages', 0, 0, 0, 5, 1)
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
		INSERT INTO Org.tbAccount (CashAccountCode, AccountCode, CashAccountName, OpeningBalance, SortCode, AccountNumber, CashCode, CoinTypeCode)
		VALUES        (@CashAccountCode, @AccountCode, @CurrentAccount, 0, @CA_SortCode, @CA_AccountNumber, '301', @CoinTypeCode)

		IF (LEN(@ReserveAccount) > 0)
		BEGIN
			EXEC Org.proc_DefaultAccountCode @AccountName = @ReserveAccount, @AccountCode = @CashAccountCode OUTPUT
			INSERT INTO Org.tbAccount (CashAccountCode, AccountCode, CashAccountName, OpeningBalance, SortCode, AccountNumber, CoinTypeCode)
			VALUES        (@CashAccountCode, @AccountCode, @ReserveAccount, 0, @RA_SortCode, @RA_AccountNumber, @CoinTypeCode)
		END

		IF (LEN(@DummyAccount) > 0)
		BEGIN
			SELECT @AccountCode = (SELECT AccountCode FROM App.tbOptions)
			EXEC Org.proc_DefaultAccountCode @AccountName = @DummyAccount, @AccountCode = @CashAccountCode OUTPUT
			INSERT INTO Org.tbAccount (CashAccountCode, AccountCode, CashAccountName, DummyAccount, CoinTypeCode)
			VALUES        (@CashAccountCode, @AccountCode, @DummyAccount, 1, @CoinTypeCode)
		END

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
		SET AccountCode = @AccountCode, CashCode = '603', MonthNumber = (SELECT DATEPART(MONTH, DATEADD(MONTH, 8, MIN(StartOn))) FROM App.tbYear JOIN App.tbYearPeriod ON App.tbYear.YearNumber = App.tbYearPeriod.YearNumber WHERE App.tbYear.CashStatusCode = 1)
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
CREATE OR ALTER PROCEDURE App.proc_DemoBom
(
	@CreateOrders BIT = 0,
	@InvoiceOrders BIT = 0,
	@PayInvoices BIT = 0
)
AS
	 SET NOCOUNT, XACT_ABORT ON;
	 
	 BEGIN TRY
	
		IF NOT EXISTS (SELECT * FROM Usr.vwCredentials WHERE IsAdministrator <> 0)
		BEGIN
			DECLARE @Msg NVARCHAR(100) = CONCAT('Access Denied: User ', SUSER_SNAME(), ' is not an administrsator');
			RAISERROR ('%s', 13, 1, @Msg);
		END
	
		DECLARE @ExchangeRate float = CASE (SELECT UnitOfCharge FROM App.tbOptions) 
										WHEN 'BTC' THEN 0.135 
										ELSE 1 
										END				

		BEGIN TRAN

		-->>>>>>>>>>>>> RESET >>>>>>>>>>>>>>>>>>>>>>>>>>>
		DELETE FROM Cash.tbPayment;
		DELETE FROM Invoice.tbInvoice;
		DELETE FROM Task.tbFlow;
		DELETE FROM Task.tbTask;
		DELETE FROM Activity.tbFlow;
		DELETE FROM Activity.tbActivity;

		--WITH sys_accounts AS
		--(
		--	SELECT AccountCode FROM App.tbOptions
		--	UNION
		--	SELECT DISTINCT AccountCode FROM Org.tbAccount
		--	UNION
		--	SELECT DISTINCT AccountCode FROM Cash.tbTaxType
		--), candidates AS
		--(
		--	SELECT AccountCode
		--	FROM Org.tbOrg
		--	EXCEPT
		--	SELECT AccountCode 
		--	FROM sys_accounts
		--)
		--DELETE Org.tbOrg 
		--FROM Org.tbOrg JOIN candidates ON Org.tbOrg.AccountCode = candidates.AccountCode;
		
		UPDATE App.tbOptions
		SET IsAutoOffsetDays = 0;

		EXEC App.proc_SystemRebuild;
		--<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

		IF NOT EXISTS( SELECT * FROM App.tbRegister WHERE RegisterName = 'Works Order')
			INSERT INTO App.tbRegister (RegisterName, NextNumber)
			SELECT 'Works Order', (SELECT MAX(NextNumber) + 10000 FROM App.tbRegister) AS NextNumber;

		INSERT INTO Activity.tbActivity (ActivityCode, TaskStatusCode, ActivityDescription, UnitOfMeasure, CashCode, UnitCharge, Printed, RegisterName)
		VALUES ('M/00/70/00', 1, 'PIGEON HOLE SHELF ASSEMBLY CLEAR', 'each', '103', 1.67 * @ExchangeRate, 1, 'Sales Order')
		, ('M/100/70/00', 1, 'PIGEON HOLE SUB SHELF CLEAR', 'each', NULL, 0.0000, 0, 'Works Order')
		, ('M/101/70/00', 1, 'PIGEON HOLE BACK DIVIDER', 'each', NULL, 0.0000, 0, 'Works Order')
		, ('M/97/70/00', 1, 'SHELF DIVIDER (WIDE FOOT)', 'each', NULL, 0.0000, 0, 'Works Order')
		, ('M/99/70/00', 1, 'SHELF DIVIDER (NARROW FOOT)', 'each', NULL, 0.0000, 0, 'Works Order')
		, ('PALLET/01', 1, 'EURO 3 1200 x 800 4 WAY', 'each', '200', 2.4 * @ExchangeRate, 1, 'Purchase Order')
		, ('BOX/41', 1, 'PIGEON ASSY 125KTB S WALL 404x220x90', 'each', '200', 0.05 * @ExchangeRate, 1, 'Purchase Order')
		, ('BOX/99', 1, 'INTERNAL USE ANY BLACK,BLUE,RED ANY', 'each', NULL, 0.0000, 0, 'Works Order')
		, ('PC/999', 1, 'CALIBRE 303EP CLEAR UL94-V2', 'kilo', '200', 0.22 * @ExchangeRate, 1, 'Purchase Order')
		, ('INSERT/09', 1, 'HEAT-LOK SHK B M3.5 HEADED BRASS 8620035-80', 'each', '200', 0.005 * @ExchangeRate, 1, 'Purchase Order')
		, ('PROJECT', 0, NULL, 'each', NULL, 0, 0, 'Works Order')
		, ('DELIVERY', 1, NULL, 'each', '200', 0, 1, 'Purchase Order')
		;
		INSERT INTO Activity.tbAttribute (ActivityCode, Attribute, PrintOrder, AttributeTypeCode, DefaultText)
		VALUES ('M/00/70/00', 'Colour', 20, 0, 'CLEAR')
		, ('M/00/70/00', 'Colour Number', 10, 0, '-')
		, ('M/00/70/00', 'Count Type', 50, 0, 'Weigh Count')
		, ('M/00/70/00', 'Drawing Issue', 40, 0, '1')
		, ('M/00/70/00', 'Drawing Number', 30, 0, '321554')
		, ('M/00/70/00', 'Label Type', 70, 0, 'Assembly Card')
		, ('M/00/70/00', 'Mould Tool Specification', 110, 1, NULL)
		, ('M/00/70/00', 'Pack Type', 60, 0, 'Despatched')
		, ('M/00/70/00', 'Quantity/Box', 80, 0, '100')
		, ('M/100/70/00', 'Cavities', 170, 0, '1')
		, ('M/100/70/00', 'Colour', 20, 0, 'CLEAR')
		, ('M/100/70/00', 'Colour Number', 10, 0, '-')
		, ('M/100/70/00', 'Count Type', 50, 0, 'Weigh Count')
		, ('M/100/70/00', 'Drawing Issue', 40, 0, '1')
		, ('M/100/70/00', 'Drawing Number', 30, 0, '321554-01')
		, ('M/100/70/00', 'Impressions', 180, 0, '1')
		, ('M/100/70/00', 'Label Type', 70, 0, 'Route Card')
		, ('M/100/70/00', 'Location', 150, 0, 'STORES')
		, ('M/100/70/00', 'Pack Type', 60, 0, 'Assembled')
		, ('M/100/70/00', 'Part Weight', 160, 0, '175g')
		, ('M/100/70/00', 'Quantity/Box', 80, 0, '100')
		, ('M/100/70/00', 'Tool Number', 190, 0, '1437')
		, ('M/101/70/00', 'Cavities', 170, 0, '2')
		, ('M/101/70/00', 'Colour', 20, 0, 'CLEAR')
		, ('M/101/70/00', 'Colour Number', 10, 0, '-')
		, ('M/101/70/00', 'Count Type', 50, 0, 'Weigh Count')
		, ('M/101/70/00', 'Drawing Issue', 40, 0, '1')
		, ('M/101/70/00', 'Drawing Number', 30, 0, '321554-02')
		, ('M/101/70/00', 'Impressions', 180, 0, '2')
		, ('M/101/70/00', 'Label Type', 70, 0, 'Route Card')
		, ('M/101/70/00', 'Location', 150, 0, 'STORES')
		, ('M/101/70/00', 'Pack Type', 60, 0, 'Assembled')
		, ('M/101/70/00', 'Part Weight', 160, 0, '61g')
		, ('M/101/70/00', 'Quantity/Box', 80, 0, '100')
		, ('M/101/70/00', 'Tool Number', 190, 0, '1439')
		, ('M/97/70/00', 'Cavities', 170, 0, '4')
		, ('M/97/70/00', 'Colour', 20, 0, 'CLEAR')
		, ('M/97/70/00', 'Colour Number', 10, 0, '-')
		, ('M/97/70/00', 'Count Type', 50, 0, 'Weigh Count')
		, ('M/97/70/00', 'Drawing Issue', 40, 0, '1')
		, ('M/97/70/00', 'Drawing Number', 30, 0, '321554A')
		, ('M/97/70/00', 'Impressions', 180, 0, '4')
		, ('M/97/70/00', 'Label Type', 70, 0, 'Route Card')
		, ('M/97/70/00', 'Location', 150, 0, 'STORES')
		, ('M/97/70/00', 'Pack Type', 60, 0, 'Assembled')
		, ('M/97/70/00', 'Part Weight', 160, 0, '171g')
		, ('M/97/70/00', 'Quantity/Box', 80, 0, '100')
		, ('M/97/70/00', 'Tool Number', 190, 0, '1440')
		, ('M/99/70/00', 'Cavities', 170, 0, '1')
		, ('M/99/70/00', 'Colour', 20, 0, 'CLEAR')
		, ('M/99/70/00', 'Colour Number', 10, 0, '-')
		, ('M/99/70/00', 'Count Type', 50, 0, 'Weigh Count')
		, ('M/99/70/00', 'Drawing Issue', 40, 0, '1')
		, ('M/99/70/00', 'Drawing Number', 30, 0, '321554A')
		, ('M/99/70/00', 'Impressions', 180, 0, '1')
		, ('M/99/70/00', 'Label Type', 70, 0, 'Route Card')
		, ('M/99/70/00', 'Location', 150, 0, 'STORES')
		, ('M/99/70/00', 'Pack Type', 60, 0, 'Assembled')
		, ('M/99/70/00', 'Part Weight', 160, 0, '171g')
		, ('M/99/70/00', 'Quantity/Box', 80, 0, '100')
		, ('M/99/70/00', 'Tool Number', 190, 0, '1441')
		, ('PC/999', 'Colour', 50, 0, 'CLEAR')
		, ('PC/999', 'Grade', 20, 0, '303EP')
		, ('PC/999', 'Location', 60, 0, 'R2123-9')
		, ('PC/999', 'Material Type', 10, 0, 'PC')
		, ('PC/999', 'Name', 30, 0, 'Calibre')
		, ('PC/999', 'SG', 40, 0, '1.21')
		;
		INSERT INTO Activity.tbOp (ActivityCode, OperationNumber, SyncTypeCode, Operation, Duration, OffsetDays)
		VALUES ('M/00/70/00', 10, 0, 'ASSEMBLE', 0.5, 3)
		, ('M/00/70/00', 20, 0, 'QUALITY CHECK', 0, 0)
		, ('M/00/70/00', 30, 0, 'PACK', 0, 1)
		, ('M/00/70/00', 40, 2, 'DELIVER', 0, 1)
		, ('M/100/70/00', 10, 0, 'MOULD', 10, 2)
		, ('M/100/70/00', 20, 1, 'INSERTS', 0, 0)
		, ('M/100/70/00', 30, 0, 'QUALITY CHECK', 0, 0)
		, ('M/101/70/00', 10, 0, 'MOULD', 10, 0)
		, ('M/101/70/00', 20, 0, 'QUALITY CHECK', 0, 0)
		, ('M/97/70/00', 10, 0, 'MOULD', 10, 2)
		, ('M/97/70/00', 20, 0, 'QUALITY CHECK', 0, 0)
		, ('M/99/70/00', 10, 0, 'MOULD', 0, 2)
		, ('M/99/70/00', 20, 0, 'QUALITY CHECK', 0, 0)
		;
		INSERT INTO Activity.tbFlow (ParentCode, StepNumber, ChildCode, SyncTypeCode, OffsetDays, UsedOnQuantity)
		VALUES ('M/00/70/00', 10, 'M/100/70/00', 1, 0, 8)
		, ('M/00/70/00', 20, 'M/101/70/00', 1, 0, 4)
		, ('M/00/70/00', 30, 'M/97/70/00', 1, 0, 3)
		, ('M/00/70/00', 40, 'M/99/70/00', 0, 0, 2)
		, ('M/00/70/00', 50, 'BOX/41', 1, 0, 1)
		, ('M/00/70/00', 60, 'PALLET/01', 1, 0, 0.01)
		, ('M/00/70/00', 70, 'DELIVERY', 2, 1, 0)
		, ('M/100/70/00', 10, 'BOX/99', 1, 0, 0.01)
		, ('M/100/70/00', 20, 'PC/999', 1, 0, 0.175)
		, ('M/101/70/00', 10, 'BOX/99', 1, 0, 0.01)
		, ('M/101/70/00', 20, 'PC/999', 1, 0, 0.061)
		, ('M/97/70/00', 10, 'BOX/99', 1, 0, 0.01)
		, ('M/97/70/00', 20, 'PC/999', 1, 0, 0.172)
		, ('M/99/70/00', 10, 'BOX/99', 1, 0, 0.01)
		, ('M/99/70/00', 20, 'PC/999', 1, 0, 0.171)
		, ('M/100/70/00', 30, 'INSERT/09', 1, 0, 2)
		;

		IF (NOT EXISTS(SELECT * FROM Org.tbOrg WHERE AccountCode = 'TFCSPE'))
		BEGIN
			INSERT INTO Org.tbOrg (AccountCode, AccountName, OrganisationTypeCode, OrganisationStatusCode, TaxCode, AddressCode, PaymentTerms, ExpectedDays, PaymentDays, PayDaysFromMonthEnd, PayBalance, NumberOfEmployees, CompanyNumber, VatNumber, Turnover, OpeningBalance, EUJurisdiction)
			VALUES 
			  ('PACSER', 'PACKING SERVICES', 8, 1, 'T1', 'PACSER_001', 'EOM', 10, 30, 1, 1, 0, NULL, NULL, 0.0000, 0.0000, 0)
			, ('PALSUP', 'PALLET SUPPLIER', 8, 1, 'T1', 'PALSUP_001', 'COD', 0, -10, 0, 1, 0, NULL, NULL, 0.0000, 0.0000, 0)
			, ('PLAPRO', 'PLASTICS PROVIDER', 8, 1, 'T1', 'PLAPRO_001', '30 days from invoice', 15, 30, 0, 1, 0, NULL, NULL, 0.0000, 0.0000, 0)
			, ('TFCSPE', 'FASTENER SPECIALIST', 8, 1, 'T1', 'TFCSPE_001', 'EOM', 0, 30, 1, 1, 0, NULL, NULL, 0.0000, 0.0000, 0)
			, ('STOBOX', 'STORAGE BOXES', 1, 1, 'T1', 'STOBOX_001', '60 days from invoice', 5, 60, 0, 1, 0, NULL, NULL, 0.0000, 0.0000, 0)
			, ('HAULOG', 'HAULIER LOGISTICS', 8, 1, 'T1', 'HAULOG_001', 'EOM', 0, 30, 1, 1, 0, NULL, NULL, 0.0000, 0.0000, 0)
			;
			INSERT INTO Org.tbAddress (AddressCode, AccountCode, Address)
			VALUES ('STOBOX_001', 'STOBOX', 'SURREY GU24 9BJ')
			, ('PACSER_001', 'PACSER', 'FAREHAM, HAMPSHIRE	PO15 5RZ')
			, ('PLAPRO_001', 'PLAPRO', 'WARRINGTON, CHESHIRE WA1 4RA')
			, ('PALSUP_001', 'PALSUP', 'HAMPSHIRE PO13 9NY')
			, ('TFCSPE_001', 'TFCSPE', 'ESSEX CO4 9TZ')
			, ('HAULOG_001', 'HAULOG', 'BERKSHIRE SL3 0BH')
			;
		END

		-- ***************************************************************************
		IF @CreateOrders = 0
			GOTO CommitTran;
		-- ***************************************************************************

		DECLARE @UserId NVARCHAR(10) = (SELECT UserId FROM Usr.vwCredentials),
			@TaskCode NVARCHAR(20),
			@ParentTaskCode NVARCHAR(20), 
			@ToTaskCode NVARCHAR(20),
			@Quantity DECIMAL(18, 4) = 100;

		EXEC Task.proc_NextCode 'PROJECT', @ParentTaskCode OUTPUT
		INSERT INTO Task.tbTask
								 (TaskCode, UserId, AccountCode, TaskTitle, ActivityCode, TaskStatusCode, ActionById)
		VALUES        (@ParentTaskCode,@UserId, 'STOBOX', N'PIGEON HOLE SHELF ASSEMBLY', N'PROJECT', 0,@UserId)
	
		EXEC Task.proc_NextCode 'M/00/70/00', @TaskCode OUTPUT
		
		INSERT INTO Task.tbTask
				(TaskCode, UserId, AccountCode, TaskTitle, ContactName, ActivityCode, TaskStatusCode, ActionById, TaskNotes, Quantity, CashCode, TaxCode, UnitCharge, AddressCodeFrom, AddressCodeTo, SecondReference, Printed)
		SELECT @TaskCode,@UserId, 'STOBOX', ActivityDescription, 'Francis Brown', ActivityCode, 1,@UserId, ActivityDescription, @Quantity, '103', 'T1', UnitCharge, 'STOBOX_001', 'STOBOX_001', N'12354/2', 0		
		FROM Activity.tbActivity
		WHERE ActivityCode = 'M/00/70/00';

		EXEC Task.proc_Configure @TaskCode;
		EXEC Task.proc_AssignToParent @TaskCode, @ParentTaskCode;

	
		UPDATE Task.tbTask
		SET AccountCode = 'PACSER', ContactName = 'John OGroats', AddressCodeFrom = 'PACSER_001', AddressCodeTo = 'PACSER_001'
		WHERE ActivityCode = 'BOX/41';

		UPDATE Task.tbTask
		SET AccountCode = 'TFCSPE', ContactName = 'Gary Granger', AddressCodeFrom = 'TFCSPE_001', AddressCodeTo = 'TFCSPE_001'
		WHERE ActivityCode = 'INSERT/09';

		UPDATE Task.tbTask
		SET AccountCode = 'PALSUP', ContactName = 'Allan Rain', AddressCodeFrom = 'PALSUP_001', AddressCodeTo = 'PALSUP_001', CashCode = NULL, UnitCharge = 0
		WHERE ActivityCode = 'PALLET/01';

		UPDATE Task.tbTask
		SET AccountCode = 'PLAPRO', ContactName = 'Kim Burnell', AddressCodeFrom = 'PLAPRO_001', AddressCodeTo = 'PLAPRO_001'
		WHERE ActivityCode = 'PC/999';
		
		UPDATE Task.tbTask
		SET AccountCode = 'HAULOG', ContactName = 'John Iron',  AddressCodeFrom = 'HOME_001', AddressCodeTo = 'STOBOX_001', Quantity = 1, UnitCharge = 25.0 * @ExchangeRate, TotalCharge = 25.0 * @ExchangeRate
		WHERE ActivityCode = 'DELIVERY';

		UPDATE Task.tbTask
		SET AccountCode = (SELECT AccountCode FROM App.tbOptions), ContactName = (SELECT UserName FROM Usr.vwCredentials)
		WHERE (CashCode IS NULL) AND (AccountCode <> 'PALSUP');

		EXEC Task.proc_Schedule @TaskCode;

		--forward orders
		DECLARE @Month SMALLINT = 1;

		WHILE (@Month < 5)
		BEGIN

			EXEC Task.proc_Copy @FromTaskCode = @TaskCode, 
					@ToTaskCode = @ToTaskCode OUTPUT;

			UPDATE Task.tbTask
			SET ActionOn = DATEADD(MONTH, @Month, ActionOn)
			WHERE TaskCode = @ToTaskCode;

			EXEC Task.proc_Schedule @ToTaskCode;

			SET @TaskCode = @ToTaskCode;
			SET @Month += 1;
		END

		--order the pallets
		EXEC Task.proc_NextCode 'PALLET/01', @TaskCode OUTPUT
		
		INSERT INTO Task.tbTask
				(TaskCode, UserId, AccountCode, TaskTitle, ActivityCode, TaskStatusCode, ActionById)
		VALUES        (@TaskCode,@UserId, 'PALSUP', N'PALLETS', 'PALLET/01', 1, @UserId);

		WITH demand AS
		(
			SELECT ActivityCode, ROUND(SUM(Quantity), -1) AS Quantity, MIN(ActionOn) AS ActionOn
			FROM Task.tbTask project 
			WHERE ActivityCode = 'PALLET/01' AND TaskCode <> @TaskCode
			GROUP BY ActivityCode
		)
		UPDATE task
		SET 
			TaskNotes = activity.ActivityDescription, 
			Quantity = demand.Quantity,
			ActionOn = demand.ActionOn,
			CashCode = activity.CashCode, 
			TaxCode = org.TaxCode, 
			UnitCharge = activity.UnitCharge, 
			AddressCodeFrom = org.AddressCode, 
			AddressCodeTo = org.AddressCode, 
			Printed = activity.Printed
		FROM Task.tbTask task
			JOIN Org.tbOrg org ON task.AccountCode = org.AccountCode
			JOIN Activity.tbActivity activity ON task.ActivityCode = activity.ActivityCode
			JOIN demand ON task.ActivityCode = demand.ActivityCode
		WHERE TaskCode = @TaskCode;

		EXEC Task.proc_Configure @TaskCode;
		EXEC Task.proc_AssignToParent @TaskCode, @ParentTaskCode;

		UPDATE Task.tbFlow
		SET StepNumber = 0
		WHERE (ChildTaskCode = @TaskCode);

		--identify ordered boms
		WITH unique_id AS
		(
			SELECT TaskCode, ActivityCode, ROW_NUMBER() OVER (PARTITION BY ActivityCode ORDER BY ActionOn) AS RowNo
			FROM Task.tbTask
		)
		UPDATE task
		SET 
			TaskTitle = CONCAT(TaskTitle, ' ', unique_id.RowNo)
		FROM Task.tbTask task
			JOIN unique_id ON task.TaskCode = unique_id.TaskCode
		WHERE task.ActivityCode = 'M/00/70/00';

		--borrow some money
		UPDATE Cash.tbCategory
		SET IsEnabled = 1
		WHERE CategoryCode = 'IV';

		UPDATE Cash.tbCode
		SET IsEnabled = 1
		WHERE CashCode = '214';


		IF @ExchangeRate = 1
		BEGIN
			DECLARE @PaymentCode NVARCHAR(20);
			EXEC Cash.proc_NextPaymentCode @PaymentCode OUTPUT
			INSERT INTO Cash.tbPayment (CashAccountCode, PaymentCode, UserId, AccountCode, CashCode, TaxCode, PaidInValue)
			SELECT DISTINCT
				CashAccountCode,
				@PaymentCode AS PaymentCode, 
				@UserId AS UserId,
				AccountCode,
				'214' AS CashCode,
				'T0' AS TaxCode,
				(SELECT ABS(ROUND(MIN(Balance), -3)) + 1000	FROM Cash.vwStatement) AS PaidInValue
			FROM Org.tbAccount WHERE NOT CashCode IS NULL

			EXEC Cash.proc_PaymentPost;
		END

		-- ***************************************************************************
		IF @InvoiceOrders = 0
			GOTO CommitTran;
		-- ***************************************************************************
		
		DECLARE 
			@InvoiceTypeCode SMALLINT,
			@InvoiceNumber NVARCHAR(10),
			@InvoicedOn DATETIME = CAST(CURRENT_TIMESTAMP AS DATE);

		DECLARE cur_tasks CURSOR LOCAL FOR
			WITH parent AS
			(
				SELECT DISTINCT FIRST_VALUE(TaskCode) OVER (PARTITION BY ActivityCode ORDER BY ActionOn) AS TaskCode
				FROM Task.tbTask task
				WHERE task.ActivityCode = 'M/00/70/00'
			), candidates AS
			(
				SELECT child.ParentTaskCode, child.ChildTaskCode
					, 1 AS Depth
				FROM Task.tbFlow child 
					JOIN parent ON child.ParentTaskCode = parent.TaskCode
					JOIN Task.tbTask task ON child.ChildTaskCode = task.TaskCode

				UNION ALL

				SELECT child.ParentTaskCode, child.ChildTaskCode
					, parent.Depth + 1 AS Depth
				FROM Task.tbFlow child 
					JOIN candidates parent ON child.ParentTaskCode = parent.ChildTaskCode
					JOIN Task.tbTask task ON child.ChildTaskCode = task.TaskCode
			), selected AS
			(
				SELECT TaskCode
				FROM parent

				UNION

				SELECT ChildTaskCode AS TaskCode
				FROM candidates

				UNION

				SELECT TaskCode
				FROM Task.tbTask 
				WHERE ActivityCode = 'PALLET/01'
			)
			SELECT task.TaskCode, CASE category.CashModeCode WHEN 0 THEN 2 ELSE 0 END AS InvoiceTypeCode
			FROM selected
				JOIN Task.tbTask task ON selected.TaskCode = task.TaskCode
				JOIN Cash.tbCode cash_code ON task.CashCode = cash_code.CashCode
				JOIN Cash.tbCategory category ON cash_code.CategoryCode = category.CategoryCode;

		OPEN cur_tasks
		FETCH NEXT FROM cur_tasks INTO @TaskCode, @InvoiceTypeCode;

		WHILE @@FETCH_STATUS = 0
		BEGIN
			IF @PayInvoices = 0
			BEGIN
				EXEC Invoice.proc_Raise @TaskCode = @TaskCode, @InvoiceTypeCode = @InvoiceTypeCode, @InvoicedOn = @InvoicedOn, @InvoiceNumber = @InvoiceNumber OUTPUT
				EXEC Invoice.proc_Accept @InvoiceNumber;
			END
			ELSE
				EXEC Task.proc_Pay @TaskCode = @TaskCode, @Post = 1, @PaymentCode = @PaymentCode OUTPUT;

			FETCH NEXT FROM cur_tasks INTO @TaskCode, @InvoiceTypeCode;
		END

		CLOSE cur_tasks;
		DEALLOCATE cur_tasks;

CommitTran:
			
		COMMIT TRAN;

	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
go
CREATE OR ALTER PROCEDURE App.proc_DemoServices
(
	@CreateOrders BIT = 0,
	@InvoiceOrders BIT = 0,
	@PayInvoices BIT = 0
)
AS
	 SET NOCOUNT, XACT_ABORT ON;

	 BEGIN TRY
	
		IF NOT EXISTS (SELECT * FROM Usr.vwCredentials WHERE IsAdministrator <> 0)
		BEGIN
			DECLARE @Msg NVARCHAR(100) = CONCAT('Access Denied: User ', SUSER_SNAME(), ' is not an administrsator');
			RAISERROR ('%s', 13, 1, @Msg);
		END
				
		BEGIN TRAN

		-->>>>>>>>>>>>> RESET >>>>>>>>>>>>>>>>>>>>>>>>>>>
		DELETE FROM Cash.tbPayment;
		DELETE FROM Invoice.tbInvoice;
		DELETE FROM Task.tbFlow;
		DELETE FROM Task.tbTask;
		DELETE FROM Activity.tbFlow;
		DELETE FROM Activity.tbActivity;

		WITH sys_accounts AS
		(
			SELECT AccountCode FROM App.tbOptions
			UNION
			SELECT DISTINCT AccountCode FROM Org.tbAccount
			UNION
			SELECT DISTINCT AccountCode FROM Cash.tbTaxType
		), candidates AS
		(
			SELECT AccountCode
			FROM Org.tbOrg
			EXCEPT
			SELECT AccountCode 
			FROM sys_accounts
		)
		DELETE Org.tbOrg 
		FROM Org.tbOrg JOIN candidates ON Org.tbOrg.AccountCode = candidates.AccountCode;

		UPDATE App.tbOptions
		SET IsAutoOffsetDays = 0;

		EXEC App.proc_SystemRebuild;		
		--<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

		DECLARE @UserId NVARCHAR(10) = (SELECT UserId FROM Usr.vwCredentials);

		UPDATE App.tbYear SET CashStatusCode = 2 WHERE CashStatusCode = 3;
		UPDATE App.tbYearPeriod SET CashStatusCode = 2 WHERE CashStatusCode = 3;

		INSERT INTO App.tbRegister (RegisterName, NextNumber)
		SELECT 'Dividends', (SELECT MAX(NextNumber) + 10000 FROM App.tbRegister)
		WHERE NOT EXISTS (SELECT * FROM App.tbRegister WHERE RegisterName = 'Dividends');

		INSERT INTO Activity.tbActivity (ActivityCode, TaskStatusCode, ActivityDescription, UnitOfMeasure, CashCode, UnitCharge, Printed, RegisterName)
		VALUES ('Car Parking / Tolls', 3, '', 'each', '213', 0.0000, 0, 'Expenses')
		, ('Communications monthly charge', 3, '', 'each', '202', 0.0000, 0, 'Expenses')
		, ('Company Administration', 3, '', 'each', '201', 0.0000, 0, 'Expenses')
		, ('Directors Dividend Accrual', 2, '', 'each', '401', 0.0000, 0, 'Dividends')
		, ('Employee Transport', 3, '', 'miles', '212', 0.4500, 0, 'Expenses')
		, ('Mobile phone charges', 3, '', 'each', '202', 0.0000, 0, 'Expenses')
		, ('Office Equipment', 3, '', 'each', '204', 0.0000, 0, 'Expenses')
		, ('Office Rent', 3, '', 'each', '205', 0.0000, 0, 'Expenses')
		, ('PO Book', 1, '', 'copies', '200', 0.0000, 1, 'Purchase Order')
		, ('PO Brochure or Catalogue', 1, '', 'copies', '200', 0.0000, 1, 'Purchase Order')
		, ('PO Card', 1, '', 'copies', '200', 0.0000, 1, 'Purchase Order')
		, ('PO Design', 1, '', 'each', '200', 0.0000, 1, 'Purchase Order')
		, ('PO Finishing', 1, '', 'copies', '200', 0.0000, 1, 'Purchase Order')
		, ('PO Leaflet', 1, '', 'copies', '200', 0.0000, 1, 'Purchase Order')
		, ('PO Packaging', 1, '', 'copies', '200', 0.0000, 1, 'Purchase Order')
		, ('PO POS', 1, '', 'copies', '200', 0.0000, 1, 'Purchase Order')
		, ('PO Poster', 1, '', 'copies', '200', 0.0000, 1, 'Purchase Order')
		, ('PO Promotional', 1, '', 'copies', '200', 0.0000, 1, 'Purchase Order')
		, ('PO Stationery', 1, '', 'copies', '200', 0.0000, 1, 'Purchase Order')
		, ('PO Transport', 1, '', 'each', '200', 0.0000, 1, 'Purchase Order')
		, ('Postage', 3, '', 'each', '207', 0.0000, 0, 'Expenses')
		, ('Project', 1, '', 'each', null, 0.0000, 0, 'Project')
		, ('SO Book', 1, '', 'copies', '103', 0.0000, 1, 'Sales Order')
		, ('SO Brochure or Catalogue', 1, '', 'copies', '103', 0.0000, 1, 'Sales Order')
		, ('SO Card', 1, '', 'copies', '103', 0.0000, 1, 'Sales Order')
		, ('SO Consultancy', 1, '', 'days', '104', 0.0000, 1, 'Sales Order')
		, ('SO Design', 1, '', 'each', '103', 0.0000, 1, 'Sales Order')
		, ('SO Leaflet', 1, '', 'copies', '103', 0.0000, 1, 'Sales Order')
		, ('SO Mailing and Fulfilment', 1, '', 'copies', '103', 0.0000, 1, 'Sales Order')
		, ('SO Packaging', 1, '', 'copies', '103', 0.0000, 1, 'Sales Order')
		, ('SO POS', 1, '', 'copies', '103', 0.0000, 1, 'Sales Order')
		, ('SO Promotional', 1, '', 'copies', '103', 0.0000, 1, 'Sales Order')
		, ('SO Stationery', 1, '', 'copies', '103', 0.0000, 1, 'Sales Order')
		, ('SO Transport', 1, '', 'each', '103', 0.0000, 1, 'Sales Order')
		, ('Stationery - General', 3, '', 'each', '209', 0.0000, 0, 'Expenses')
		, ('Stationery - Office Printer Paper', 3, '', 'each', '209', 0.0000, 0, 'Expenses')
		, ('Subsistence', 3, '', 'each', '218', 0.0000, 0, 'Expenses')
		, ('Sundry (Indirect)', 3, '', 'each', '208', 0.0000, 0, 'Expenses')
		, ('Train/Tube fares', 3, '', 'each', '213', 0.0000, 0, 'Expenses')
		, ('Travel (Flights etc)', 3, '', 'each', '213', 0.0000, 0, 'Expenses')
		, ('Wages monthly payment', 2, '', 'each', '402', 0.0000, 0, 'Expenses')
		;
		INSERT INTO Activity.tbAttribute (ActivityCode, Attribute, PrintOrder, AttributeTypeCode, DefaultText)
		VALUES ('PO Book', 'Extent', 20, 0, '')
		, ('PO Book', 'Finishing', 70, 0, '')
		, ('PO Book', 'Origination', 30, 0, '')
		, ('PO Book', 'Packing', 80, 0, '')
		, ('PO Book', 'Paper', 60, 0, '')
		, ('PO Book', 'Printing', 50, 0, '')
		, ('PO Book', 'Proofs', 40, 0, '')
		, ('PO Book', 'Text Size', 10, 0, '')
		, ('PO Brochure or Catalogue', 'Delivery #1', 155, 0, '')
		, ('PO Brochure or Catalogue', 'File Copies', 160, 0, '')
		, ('PO Brochure or Catalogue', 'Finishing', 90, 0, '')
		, ('PO Brochure or Catalogue', 'Note', 150, 0, '')
		, ('PO Brochure or Catalogue', 'Origination', 40, 0, '')
		, ('PO Brochure or Catalogue', 'Packing', 100, 0, '')
		, ('PO Brochure or Catalogue', 'Pagination', 20, 0, '')
		, ('PO Brochure or Catalogue', 'Paper', 80, 0, '')
		, ('PO Brochure or Catalogue', 'Printing', 60, 0, '')
		, ('PO Brochure or Catalogue', 'Proofing', 50, 0, '')
		, ('PO Brochure or Catalogue', 'Trim Size', 30, 0, '')
		, ('PO Brochure or Catalogue', 'UV Varnish', 70, 0, '')
		, ('PO Card', 'File Copies', 200, 0, '')
		, ('PO Card', 'Finishing', 90, 0, '')
		, ('PO Card', 'Origination', 40, 0, '')
		, ('PO Card', 'Packing', 100, 0, '')
		, ('PO Card', 'Pagination', 20, 0, '')
		, ('PO Card', 'Paper', 80, 0, '')
		, ('PO Card', 'Printing', 60, 0, '')
		, ('PO Card', 'Proofing', 50, 0, '')
		, ('PO Card', 'Trim Size', 30, 0, '')
		, ('PO Card', 'Versions', 10, 0, '')
		, ('PO Design', 'Autojoy', 10, 0, '')
		, ('PO Design', 'RVS', 30, 0, '')
		, ('PO Design', 'WVS', 20, 0, '')
		, ('PO Finishing', 'Advance sample', 210, 1, '')
		, ('PO Finishing', 'Extent', 20, 0, '')
		, ('PO Finishing', 'File Copies', 200, 0, '')
		, ('PO Finishing', 'Finishing', 100, 0, '')
		, ('PO Finishing', 'Paper', 70, 0, '')
		, ('PO Finishing', 'Printing', 60, 0, '')
		, ('PO Finishing', 'Size', 30, 0, '')
		, ('PO Leaflet', 'File Copies', 120, 0, '')
		, ('PO Leaflet', 'Finishing', 90, 0, '')
		, ('PO Leaflet', 'Labelling', 110, 0, '')
		, ('PO Leaflet', 'Lamination', 70, 0, '')
		, ('PO Leaflet', 'Origination', 40, 0, '')
		, ('PO Leaflet', 'Packing', 100, 0, '')
		, ('PO Leaflet', 'Pagination', 20, 0, '')
		, ('PO Leaflet', 'Paper', 80, 0, '')
		, ('PO Leaflet', 'Printing', 60, 0, '')
		, ('PO Leaflet', 'Proofing', 50, 0, '')
		, ('PO Leaflet', 'Trim Size', 30, 0, '')
		, ('PO Packaging', '10 Litre labels', 20, 0, '')
		, ('PO Packaging', '5 Litre labels', 15, 0, '')
		, ('PO Packaging', 'File Copies', 100, 0, '')
		, ('PO Packaging', 'Finishing', 80, 0, '')
		, ('PO Packaging', 'Material', 60, 0, '')
		, ('PO Packaging', 'Origination', 30, 0, '')
		, ('PO Packaging', 'Packing', 90, 0, '')
		, ('PO Packaging', 'Printing', 50, 0, '')
		, ('PO Packaging', 'Proofing', 40, 0, '')
		, ('PO Packaging', 'Size', 25, 0, '')
		, ('PO POS', 'File Copies', 70, 0, '')
		, ('PO POS', 'Finishing', 60, 0, '')
		, ('PO POS', 'Origination', 20, 0, '')
		, ('PO POS', 'Paper', 50, 0, '')
		, ('PO POS', 'Printing', 40, 0, '')
		, ('PO POS', 'Proofing', 30, 0, '')
		, ('PO POS', 'Size', 10, 0, '')
		, ('PO Poster', 'Extent', 20, 0, '')
		, ('PO Poster', 'File Copies', 90, 0, '')
		, ('PO Poster', 'Finishing', 70, 0, '')
		, ('PO Poster', 'Flat sheets', 50, 0, '')
		, ('PO Poster', 'Packing', 80, 0, '')
		, ('PO Poster', 'Paper', 60, 0, '')
		, ('PO Poster', 'Size', 10, 0, '')
		, ('PO Promotional', 'Delivery Note', 90, 0, '')
		, ('PO Promotional', 'Description', 10, 0, '')
		, ('PO Promotional', 'File Copies', 100, 0, '')
		, ('PO Promotional', 'Finishing', 70, 0, '')
		, ('PO Promotional', 'Material', 60, 0, '')
		, ('PO Promotional', 'Origination', 30, 0, '')
		, ('PO Promotional', 'Packing', 80, 0, '')
		, ('PO Promotional', 'Printing', 50, 0, '')
		, ('PO Promotional', 'Proofing', 40, 0, '')
		, ('PO Promotional', 'Size', 20, 0, '')
		, ('PO Stationery', 'File Copies', 110, 0, '')
		, ('PO Stationery', 'Finishing', 90, 0, '')
		, ('PO Stationery', 'Lamination', 70, 0, '')
		, ('PO Stationery', 'Material', 80, 0, '')
		, ('PO Stationery', 'Origination', 40, 0, '')
		, ('PO Stationery', 'Packing', 100, 0, '')
		, ('PO Stationery', 'Prices', 20, 0, '')
		, ('PO Stationery', 'Printing', 60, 0, '')
		, ('PO Stationery', 'Proofing', 50, 0, '')
		, ('PO Stationery', 'Qty Splits', 10, 0, '')
		, ('PO Stationery', 'Trim Sizes', 30, 0, '')
		, ('PO Transport', 'Collection', 20, 0, '')
		, ('PO Transport', 'Description', 10, 0, '')
		, ('PO Transport', 'Note', 30, 1, '')
		, ('SO Book', 'Binder Size', 15, 0, '')
		, ('SO Book', 'Extent', 20, 0, '')
		, ('SO Book', 'Finishing', 70, 0, '')
		, ('SO Book', 'Origination', 30, 0, '')
		, ('SO Book', 'Packing', 80, 0, '')
		, ('SO Book', 'Paper', 60, 0, '')
		, ('SO Book', 'Printing', 50, 0, '')
		, ('SO Book', 'Proofs', 40, 0, '')
		, ('SO Book', 'Ring Binder', 75, 0, '')
		, ('SO Book', 'Text Size', 10, 0, '')
		, ('SO Brochure or Catalogue', 'Delivery #1', 160, 0, '')
		, ('SO Brochure or Catalogue', 'Finishing', 90, 0, '')
		, ('SO Brochure or Catalogue', 'Note', 150, 0, '')
		, ('SO Brochure or Catalogue', 'Origination', 40, 0, '')
		, ('SO Brochure or Catalogue', 'Packing', 100, 0, '')
		, ('SO Brochure or Catalogue', 'Pagination', 20, 0, '')
		, ('SO Brochure or Catalogue', 'Paper', 80, 0, '')
		, ('SO Brochure or Catalogue', 'Printing', 60, 0, '')
		, ('SO Brochure or Catalogue', 'Proofing', 50, 0, '')
		, ('SO Brochure or Catalogue', 'Trim Size', 30, 0, '')
		, ('SO Brochure or Catalogue', 'UV Varnish', 70, 0, '')
		, ('SO Card', 'Changes', 70, 0, '')
		, ('SO Card', 'Envelopes', 110, 1, '')
		, ('SO Card', 'Finishing', 90, 0, '')
		, ('SO Card', 'Origination', 40, 0, '')
		, ('SO Card', 'Pagination', 20, 0, '')
		, ('SO Card', 'Paper', 80, 0, '')
		, ('SO Card', 'Printing', 60, 0, '')
		, ('SO Card', 'Proofing', 50, 0, '')
		, ('SO Card', 'Trim Size', 30, 0, '')
		, ('SO Consultancy', 'Description', 10, 0, '')
		, ('SO Design', 'Autojoy', 10, 0, '')
		, ('SO Design', 'RVS', 30, 0, '')
		, ('SO Design', 'WVS', 20, 0, '')
		, ('SO Leaflet', 'Extent', 20, 0, '')
		, ('SO Leaflet', 'Finishing', 70, 0, '')
		, ('SO Leaflet', 'Origination', 30, 0, '')
		, ('SO Leaflet', 'Packing', 80, 0, '')
		, ('SO Leaflet', 'Paper', 60, 0, '')
		, ('SO Leaflet', 'Printing', 50, 0, '')
		, ('SO Leaflet', 'Proofing', 40, 0, '')
		, ('SO Leaflet', 'Size', 10, 0, '')
		, ('SO Mailing and Fulfilment', 'Call-off #1', 40, 0, '')
		, ('SO Mailing and Fulfilment', 'Call-off #2', 50, 0, '')
		, ('SO Mailing and Fulfilment', 'Call-off #3', 60, 0, '')
		, ('SO Mailing and Fulfilment', 'Call-off #4', 70, 0, '')
		, ('SO Mailing and Fulfilment', 'Call-off #5', 80, 0, '')
		, ('SO Mailing and Fulfilment', 'Call-off #6', 90, 0, '')
		, ('SO Mailing and Fulfilment', 'Call-off #7', 100, 0, '')
		, ('SO Mailing and Fulfilment', 'Call-off #8', 110, 0, '')
		, ('SO Mailing and Fulfilment', 'Scale prices', 5, 0, '')
		, ('SO Mailing and Fulfilment', 'Storage', 30, 0, '')
		, ('SO Packaging', 'Description', 10, 0, '')
		, ('SO Packaging', 'Finishing', 90, 0, '')
		, ('SO Packaging', 'Lamination', 70, 0, '')
		, ('SO Packaging', 'Material', 80, 0, '')
		, ('SO Packaging', 'Origination', 40, 0, '')
		, ('SO Packaging', 'Packing', 100, 0, '')
		, ('SO Packaging', 'Printing', 60, 0, '')
		, ('SO Packaging', 'Proofing', 50, 0, '')
		, ('SO Packaging', 'Tolerance', 110, 0, '')
		, ('SO Packaging', 'Trim Size', 30, 0, '')
		, ('SO POS', 'Finishing', 60, 0, '')
		, ('SO POS', 'Origination', 20, 0, '')
		, ('SO POS', 'Paper', 50, 0, '')
		, ('SO POS', 'Printing', 40, 0, '')
		, ('SO POS', 'Proofing', 30, 0, '')
		, ('SO POS', 'Size', 10, 0, '')
		, ('SO Promotional', 'Description', 60, 0, '')
		, ('SO Promotional', 'Embroidery', 140, 0, '')
		, ('SO Promotional', 'FOTL Mens Polo', 100, 0, '')
		, ('SO Promotional', 'Gildan Mens Polo', 80, 0, '')
		, ('SO Promotional', 'Henbury Mens Polo', 110, 0, '')
		, ('SO Promotional', 'Note', 150, 0, '')
		, ('SO Promotional', 'Purple Womans T', 70, 0, '')
		, ('SO Promotional', 'Result Fleece', 130, 0, '')
		, ('SO Promotional', 'Uneek Mens Polo', 90, 0, '')
		, ('SO Promotional', 'Womens Polo', 120, 0, '')
		, ('SO Stationery', 'Finishing', 90, 0, '')
		, ('SO Stationery', 'Origination', 40, 0, '')
		, ('SO Stationery', 'Packing', 100, 0, '')
		, ('SO Stationery', 'Pagination', 20, 0, '')
		, ('SO Stationery', 'Paper', 80, 0, '')
		, ('SO Stationery', 'Printing', 60, 0, '')
		, ('SO Stationery', 'Proofing', 50, 0, '')
		, ('SO Stationery', 'Trim Size', 30, 0, '')
		, ('SO Transport', 'Call-off #1', 40, 0, '')
		, ('SO Transport', 'Call-off #2', 50, 0, '')
		, ('SO Transport', 'Scale prices', 5, 0, '')
		, ('SO Transport', 'Storage', 30, 0, '')
		;
		INSERT INTO Activity.tbFlow (ParentCode, StepNumber, ChildCode, SyncTypeCode, OffsetDays, UsedOnQuantity)
		VALUES ('SO Book', 10, 'PO Book', 0, 0, 0)
		, ('SO Book', 20, 'PO Transport', 0, 0, 0)
		, ('SO Brochure or Catalogue', 10, 'PO Brochure or Catalogue', 0, 0, 0)
		, ('SO Brochure or Catalogue', 20, 'PO Transport', 0, 0, 0)
		, ('SO Card', 20, 'PO Card', 0, 0, 0)
		, ('SO Card', 10, 'PO Design', 0, 0, 0)
		, ('SO Design', 10, 'PO Design', 0, 0, 0)
		, ('SO Leaflet', 10, 'PO Leaflet', 0, 0, 0)
		, ('SO Leaflet', 20, 'PO Poster', 0, 0, 0)
		, ('SO Packaging', 20, 'PO Design', 0, 0, 0)
		, ('SO Packaging', 10, 'PO Packaging', 0, 0, 0)
		, ('SO POS', 10, 'PO POS', 0, 0, 0)
		, ('SO Promotional', 10, 'PO Card', 0, 0, 0)
		, ('SO Stationery', 10, 'PO Stationery', 0, 0, 0)
		, ('SO Transport', 10, 'PO Transport', 0, 0, 0)
		;
		INSERT INTO Activity.tbOp (ActivityCode, OperationNumber, SyncTypeCode, Operation, Duration, OffsetDays)
		VALUES ('PO Book', 10, 0, 'Artwork', 0, 0)
		, ('PO Book', 20, 0, 'Proofs', 0, 0)
		, ('PO Book', 30, 0, 'Approval', 0, 0)
		, ('PO Book', 40, 2, 'Delivery', 0, 0)
		, ('PO Brochure or Catalogue', 10, 0, 'Artwork', 0, 0)
		, ('PO Brochure or Catalogue', 20, 0, 'Proofs', 0, 0)
		, ('PO Brochure or Catalogue', 30, 0, 'Approval', 0, 0)
		, ('PO Brochure or Catalogue', 50, 2, 'Delivery', 0, 0)
		, ('PO Card', 10, 0, 'Artwork', 0, 0)
		, ('PO Card', 20, 0, 'Proofs', 0, 0)
		, ('PO Card', 30, 0, 'Approval', 0, 0)
		, ('PO Card', 40, 2, 'Delivery', 0, 0)
		, ('PO Design', 10, 0, 'Completion', 0, 0)
		, ('PO Finishing', 10, 0, 'Advance sample', 0, 0)
		, ('PO Finishing', 20, 0, 'Flat sheets', 0, 0)
		, ('PO Finishing', 30, 2, 'Delivery', 0, 0)
		, ('PO Leaflet', 10, 0, 'Artwork', 0, 0)
		, ('PO Leaflet', 20, 0, 'Proofs', 0, 0)
		, ('PO Leaflet', 30, 0, 'Approval', 0, 0)
		, ('PO Leaflet', 40, 2, 'Delivery', 0, 0)
		, ('PO Packaging', 10, 0, 'Flat sheets', 0, 0)
		, ('PO Packaging', 20, 2, 'Delivery', 0, 0)
		, ('PO Poster', 30, 0, 'Flat sheets', 0, 0)
		, ('PO Poster', 40, 2, 'Delivery', 0, 0)
		, ('PO Promotional', 10, 2, 'Delivery', 0, 0)
		, ('PO Transport', 10, 0, 'Despatch', 0, 0)
		, ('PO Transport', 20, 2, 'Delivery', 0, 0)
		, ('SO Book', 20, 0, 'Artwork', 0, 0)
		, ('SO Book', 30, 0, 'Proofs', 0, 0)
		, ('SO Book', 40, 0, 'Approval', 0, 0)
		, ('SO Book', 70, 2, 'Delivery', 0, 0)
		, ('SO Brochure or Catalogue', 10, 0, 'Artwork', 0, 0)
		, ('SO Brochure or Catalogue', 20, 0, 'Proofs', 0, 2)
		, ('SO Brochure or Catalogue', 30, 0, 'Approval', 0, 3)
		, ('SO Brochure or Catalogue', 40, 2, 'Delivery', 0, 5)
		, ('SO Card', 10, 0, 'Artwork', 0, 0)
		, ('SO Card', 20, 0, 'Proofs', 0, 2)
		, ('SO Card', 30, 0, 'Approval', 0, 3)
		, ('SO Card', 40, 2, 'Delivery', 0, 5)
		, ('SO Design', 10, 0, 'Completion', 0, 0)
		, ('SO Leaflet', 40, 0, 'Artwork', 0, 0)
		, ('SO Leaflet', 60, 0, 'PDF Proofs', 0, 0)
		, ('SO Leaflet', 70, 0, 'Approval', 0, 0)
		, ('SO Leaflet', 80, 2, 'Delivery', 0, 0)
		, ('SO Mailing and Fulfilment', 10, 2, 'Completion', 0, 0)
		, ('SO Packaging', 10, 0, 'Artwork', 0, 0)
		, ('SO Packaging', 20, 0, 'Proofs', 0, 0)
		, ('SO Packaging', 30, 0, 'Approval', 0, 0)
		, ('SO Packaging', 40, 2, 'Delivery', 0, 5)
		, ('SO POS', 40, 2, 'Delivery', 0, 0)
		, ('SO Promotional', 10, 0, 'Copy', 0, 0)
		, ('SO Promotional', 20, 0, 'Proofs', 0, 0)
		, ('SO Promotional', 30, 0, 'Approval', 0, 0)
		, ('SO Promotional', 40, 2, 'Delivery', 0, 0)
		, ('SO Stationery', 10, 0, 'Proofs', 0, 0)
		, ('SO Stationery', 20, 0, 'Approval', 0, 0)
		, ('SO Stationery', 40, 2, 'Delivery', 0, 5)
		, ('SO Transport', 10, 0, 'Despatch', 0, 0)
		, ('SO Transport', 20, 2, 'Delivery', 0, 0)
		, ('Stationery - General', 10, 0, 'Artwork', 0, 0)
		, ('Stationery - General', 20, 0, 'Proofs', 0, 2)
		, ('Stationery - General', 30, 0, 'Approval', 0, 3)
		, ('Stationery - General', 40, 2, 'Delivery', 0, 5)
		;

		IF (@CreateOrders = 0)
			GOTO CommitTran;

		INSERT INTO Org.tbOrg (AccountCode, AccountName, OrganisationTypeCode, OrganisationStatusCode, TaxCode, AddressCode, AreaCode, PhoneNumber, EmailAddress, WebSite, AccountSource, PaymentTerms, ExpectedDays, PaymentDays, PayDaysFromMonthEnd, PayBalance)
		VALUES ('ABCUST', 'AB Customer', 1, 1, 'T1', 'ABCUST_001', null, '+1234 56789', 'email@abcus.com', null, null, '30 days from date of invoice', 0, 30, 0, 0)
		, ('CDCUST', 'CD Customer', 1, 1, 'T0', 'CDCUST_001', null, '+1234 123456', 'admin@cdcus.com', 'www.cdcus.com#http://www.cdcus.com#', null, '30 days end of month following date of invoice', 0, 30, 1, 0)
		, ('EFCUST', 'EF Customer', 1, 1, 'T0', 'EFCUST_001', null, '01234 654321', 'accounts@efcust.net', 'www.efcust.net#http://www.efcust.net#', null, '30 days from date of invoice', 15, 30, 0, 1)
		, ('SUPONE', 'Supplier One Ltd', 8, 1, 'T1', 'SUPONE_001', null, '0102 030405', 'contact@supplierone.co.uk', null, null, '30 days end of month following date of invoice', 0, 30, 1, 0)
		, ('EXWORK', 'Ex Works', 7, 1, 'T0', 'EXWORK_001', null, null, null, null, null, null, 0, 0, 0, 1)
		, ('TRACOM', 'Transport Company Ltd', 0, 1, 'T1', 'TRACOM_001', null, '01112 333444', 'bookings@transportco.biz', 'www.transportco.biz#http://www.transportco.biz#', null, '30 days end of month following date of invoice', 0, 30, 1, 0)
		, ('BUSOWN', 'Business Owner', 9, 1, 'T0', null, null, null, null, null, null, 'Expenses paid end of month', 0, 0, 1, 1)
		, ('TELPRO', 'Telecom Provider', 0, 1, 'T1', null, null, '09876 54312', null, null, null, 'Paid with order', 0, 0, 0, 0)
		, ('SUNSUP', 'Sundry Supplier', 1, 1, 'T0', null, null, null, null, null, null, 'Paid with order', 0, 0, 0, 1)
		, ('SUPTWO', 'Supplier Two', 8, 1, 'T0', 'SUPTWO_001', null, '0987 454545', 'info@suptwo.com', null, null, '30 days end of month following date of invoice', 0, 30, 1, 0)
		, ('SUPTHR', 'Supplier Three Cartons Ltd', 0, 1, 'T1', 'SUPTHR_001', null, '0505 505050', 'sales@supplierthree.ltd', null, null, '30 days end of month following date of invoice', 0, 30, 1, 0)
		, ('THEPAP', 'The Paper Supplier', 8, 1, 'T1', 'THEPAP_001', null, '01254 400000', 'adam@papersupplier.eu', 'www.papersupplier.eu#http://www.papersupplier.eu#', null, '30 days from date of invoice', 30, 0, 0, 1)
		, ('BRICRA', 'British Crafts', 1, 1, 'T0', 'BRICRA_001', null, '1234 987654', 'ed@britishcrafts.org.uk', null, null, '30 days end of month following date of invoice', 10, 30, 1, 1)
		;
		INSERT INTO Org.tbAddress (AddressCode, AccountCode, Address)
		VALUES ('ABCUST_001', 'ABCUST', '1 The Street
		Anytown
		AT1 100')
		, ('ABCUST_002', 'ABCUST', 'AB Customer, 1 The Street, Anytown AT1 100 Contact: Andy Brass  T:07177 897897')
		, ('BRICRA_001', 'BRICRA', 'The Farm
		Farmtown
		FM1 1AA')
		, ('BRICRA_002', 'BRICRA', 'British Crafts, The Farm, Farmtown FM1 1AA Contact: Ed Shire M:07854 00001')
		, ('CDCUST_001', 'CDCUST', '1 The Avenue
		Othertown
		OT1 100')
		, ('CDCUST_002', 'CDCUST', 'CD Customer, 1 The Avenue, Othertown, OT1 100 Attn. Ben Boyd Tel:+1234 123456')
		, ('EFCUST_001', 'EFCUST', '9 The Road
		Greentown
		GT1 2AR')
		, ('EFCUST_002', 'EFCUST', 'EF Customer, 9 The Road, Greentown GT1 2AR')
		, ('EXWORK_001', 'EXWORK', 'Ex Works - carriage cost extra if required')
		, ('SUPONE_001', 'SUPONE', 'Palm Close
		Forest Trading Estate
		Treetown
		TT1 1TT')
		, ('SUPONE_002', 'SUPONE', 'Supplier One Ltd, Palm Close, Forest Trading Estate, Treetown TT1 1TT Tel:0102 030405 (deliveries/pickups only accepted between 8am-4pm Monday-Friday)')
		, ('SUPTHR_001', 'SUPTHR', 'Acacia Avenue
		Brownton
		BR1 098')
		, ('SUPTHR_002', 'SUPTHR', 'Acacia Avenue, Brownton BR1 098 Attn. Goods-In Supervisor T:0505 505050')
		, ('SUPTWO_001', 'SUPTWO', 'The Trading Centre
		High Street
		Nothiston
		NO1 1NO')
		, ('SUPTWO_002', 'SUPTWO', 'Supplier Two, The Trading Centre, High Street, Nothiston NO1 1NO')
		, ('THEPAP_001', 'THEPAP', 'Paper House
		Paper Mill Lane
		Stoneleigh
		ST1 1PP')
		, ('TRACOM_001', 'TRACOM', 'The Transport Company
		Haulage Way
		ThisTown
		ThatCounty
		TT1 1CC')
		;
		INSERT INTO Org.tbContact (AccountCode, ContactName, FileAs, OnMailingList, NameTitle, NickName, JobTitle, PhoneNumber, MobileNumber, EmailAddress)
		VALUES ('ABCUST', 'Andy Brass', 'Brass, Andy', 1, null, 'Andy', null, null, '07177 897897', 'andy@abcus.com')
		, ('CDCUST', 'Ben Boyd', 'Boyd, Ben', 1, null, 'Ben', null, null, '07177 777566', 'ben@cdcus.com')
		, ('EFCUST', 'Christine Cook', 'Cook, Christine', 1, null, 'Chrissie', null, null, '07891 123456', 'chrissie@efcust.net')
		, ('SUPONE', 'Diane Durrel', 'Durrel, Diane', 1, null, 'Di', null, null, null, 'di@supplierone.co.uk')
		, ('SUPONE', 'Andy Brass', 'Brass, Andy', 1, null, 'Andy', null, null, null, null)
		, ('TRACOM', 'Dave Gomez', 'Gomez, Dave', 1, null, 'Dave', null, '01112 333452', '07755 5411000', 'daveg@transportco.biz')
		, ('THEPAP', 'Adam Jones', 'Jones, Adam', 1, null, 'Adam', null, null, null, 'adam@papersupplier.eu')
		, ('TRACOM', 'Andy Brass', 'Brass, Andy', 1, null, 'Andy', null, '01112 333444', null, 'bookings@transportco.biz')
		, ('SUPTHR', 'Andy Brass', 'Brass, Andy', 1, null, 'Andy', null, null, null, null)
		, ('BRICRA', 'Ed Shire', 'Shire, Ed', 1, null, 'Ed', null, null, '07854 00001', 'ed@britishcrafts.org.uk')
		, ('SUPTWO', 'Fred Flint', 'Flint, Fred', 1, null, 'Fred', null, null, null, 'fred@@suptwo.com')
		, ('SUPTHR', 'Georgia Onmymind', 'Onmymind, Georgia', 1, null, 'Georgia', null, null, null, 'gonmy@supplierthree.ltd')
		, ('ABCUST', 'Ted Baker', 'Baker, Ted', 1, null, 'Ted', 'Accounts/Payments', null, null, 'ted@abcus.com')
		;

		INSERT INTO Task.tbTask (TaskCode, UserId, AccountCode, SecondReference, TaskTitle, ContactName, ActivityCode, TaskStatusCode, ActionById, ActionOn, ActionedOn, PaymentOn, TaskNotes, Quantity, CashCode, TaxCode, UnitCharge, TotalCharge, AddressCodeFrom, AddressCodeTo, Spooled, Printed)
		VALUES (CONCAT(@UserId, '_10000'), @UserId, 'ABCUST', 'Order No. 12345', 'One-Off Book Order', 'Andy Brass', 'SO Book', 1, @UserId, '20190910', null, '20190910', null, 50, '103', 'T0', 9, 450.0000, 'ABCUST_001', 'ABCUST_002', 0, 0)
		, (CONCAT(@UserId, '_10007'), @UserId, 'CDCUST', 'Monthly Contract', 'CD Monthly Brochure', 'Ben Boyd', 'SO Brochure or Catalogue', 2, @UserId, '20190126', '20190126', '20190228', null, 5000, '103', 'T1', 0.2, 1000.0000, 'CDCUST_001', 'CDCUST_002', 0, 0)
		, (CONCAT(@UserId, '_10008'), @UserId, 'CDCUST', 'Monthly Contract', 'CD Monthly Brochure', 'Ben Boyd', 'SO Brochure or Catalogue', 2, @UserId, '20190225', '20190225', '20190329', null, 5000, '103', 'T1', 0.2, 1000.0000, 'CDCUST_001', 'CDCUST_002', 0, 0)
		, (CONCAT(@UserId, '_10009'), @UserId, 'CDCUST', 'Monthly Contract', 'CD Monthly Brochure', 'Ben Boyd', 'SO Brochure or Catalogue', 2, @UserId, '20190328', '20190328', '20190430', null, 5000, '103', 'T1', 0.2, 1000.0000, 'CDCUST_001', 'CDCUST_002', 0, 0)
		, (CONCAT(@UserId, '_10010'), @UserId, 'CDCUST', 'Monthly Contract', 'CD Monthly Brochure', 'Ben Boyd', 'SO Brochure or Catalogue', 2, @UserId, '20190428', '20190428', '20190531', null, 5000, '103', 'T1', 0.2, 1000.0000, 'CDCUST_001', 'CDCUST_002', 0, 0)
		, (CONCAT(@UserId, '_10011'), @UserId, 'CDCUST', 'Monthly Contract', 'CD Monthly Brochure', 'Ben Boyd', 'SO Brochure or Catalogue', 2, @UserId, '20190525', '20190525', '20190628', null, 5000, '103', 'T1', 0.2, 1000.0000, 'CDCUST_001', 'CDCUST_002', 0, 0)
		, (CONCAT(@UserId, '_10012'), @UserId, 'CDCUST', 'Monthly Contract', 'CD Monthly Brochure', 'Ben Boyd', 'SO Brochure or Catalogue', 2, @UserId, '20190627', '20190822', '20190731', null, 5000, '103', 'T1', 0.2, 1000.0000, 'CDCUST_001', 'CDCUST_002', 0, 0)
		, (CONCAT(@UserId, '_10013'), @UserId, 'CDCUST', 'Monthly Contract', 'CD Monthly Brochure', 'Ben Boyd', 'SO Brochure or Catalogue', 1, @UserId, '20190726', null, '20190830', null, 5000, '103', 'T1', 0.2, 1000.0000, 'CDCUST_001', 'CDCUST_002', 0, 0)
		, (CONCAT(@UserId, '_10014'), @UserId, 'CDCUST', 'Monthly Contract', 'CD Monthly Brochure', 'Ben Boyd', 'SO Brochure or Catalogue', 1, @UserId, '20190828', null, '20190930', null, 5000, '103', 'T1', 0.2, 1000.0000, 'CDCUST_001', 'CDCUST_002', 0, 0)
		, (CONCAT(@UserId, '_10015'), @UserId, 'EFCUST', 'PO12131', 'Outer Carton Ref X12-2', 'Christine Cook', 'SO Packaging', 1, @UserId, '20190917', null, '20190917', null, 2000, '103', 'T1', 0.62, 1240.0000, 'EFCUST_001', 'EFCUST_002', 0, 0)
		, (CONCAT(@UserId, '_10017'), @UserId, 'EFCUST', 'Ref B123234', 'McBurger Scratchcards', 'Christine Cook', 'SO Promotional', 2, @UserId, '20190331', '20190708', '20190515', null, 5000000, '103', 'T1', 0.0037, 18500.0000, 'EFCUST_001', 'EFCUST_002', 0, 0)
		, (CONCAT(@UserId, '_10018'), @UserId, 'ABCUST', 'PO 15550', 'Test Book Order', 'Andy Brass', 'SO Book', 1, @UserId, '20190903', null, '20190903', 'Call Andy 24 hours before delivery and send him 2 file copies

		The colour of the logo on the back cover must match previous orders', 50, '103', 'T1', 15.9, 795.0000, 'ABCUST_001', 'ABCUST_002', 0, 0)
		, (CONCAT(@UserId, '_10019'), @UserId, 'ABCUST', 'PO 15595', 'Main Book Order', 'Andy Brass', 'SO Book', 1, @UserId, '20191027', null, '20191126', 'Call Andy 24 hours before delivery and send him 2 file copies

		The colour of the logo on the back cover must match previous orders', 1000, '103', 'T1', 9.5, 9500.0000, 'ABCUST_001', 'ABCUST_002', 0, 0)
		, (CONCAT(@UserId, '_20000'), @UserId, 'SUPONE', 'Estimate 95456', 'One-Off Book Order', 'Andy Brass', 'PO Book', 1, @UserId, '20190725', null, '20190830', null, 50, '200', 'T0', 7.5, 375.0000, 'SUPONE_001', 'ABCUST_002', 0, 0)
		, (CONCAT(@UserId, '_20010'), @UserId, 'SUPTWO', 'Quote 12345A', 'CD Monthly Brochure', 'Fred Flint', 'PO Brochure or Catalogue', 2, @UserId, '20190125', '20190125', '20190228', null, 5000, '200', 'T0', 0.13, 650.0000, 'SUPTWO_001', 'EXWORK_001', 0, 0)
		, (CONCAT(@UserId, '_20011'), @UserId, 'TRACOM', 'Pallet scale rate', 'CD Monthly Brochure - Transport', 'Dave Gomez', 'PO Transport', 2, @UserId, '20190126', '20190126', '20190228', null, 2, '200', 'T1', 75, 150.0000, 'SUPTWO_002', 'CDCUST_002', 0, 0)
		, (CONCAT(@UserId, '_20013'), @UserId, 'SUPTWO', 'Quote 12345A', 'CD Monthly Brochure', 'Fred Flint', 'PO Brochure or Catalogue', 2, @UserId, '20190224', '20190224', '20190329', null, 5000, '200', 'T0', 0.13, 650.0000, 'SUPTWO_001', 'EXWORK_001', 0, 0)
		, (CONCAT(@UserId, '_20014'), @UserId, 'TRACOM', 'Pallet scale rate', 'CD Monthly Brochure - Transport', 'Dave Gomez', 'PO Transport', 2, @UserId, '20190225', '20190225', '20190329', null, 2, '200', 'T1', 75, 150.0000, 'SUPTWO_002', 'CDCUST_002', 0, 0)
		, (CONCAT(@UserId, '_20015'), @UserId, 'SUPTWO', 'Quote 12345A', 'CD Monthly Brochure', 'Fred Flint', 'PO Brochure or Catalogue', 2, @UserId, '20190327', '20190327', '20190430', null, 5000, '200', 'T0', 0.13, 650.0000, 'SUPTWO_001', 'EXWORK_001', 0, 0)
		, (CONCAT(@UserId, '_20016'), @UserId, 'TRACOM', 'Pallet scale rate', 'CD Monthly Brochure - Transport', 'Dave Gomez', 'PO Transport', 2, @UserId, '20190328', '20190328', '20190430', null, 2, '200', 'T1', 75, 150.0000, 'SUPTWO_002', 'CDCUST_002', 0, 0)
		, (CONCAT(@UserId, '_20017'), @UserId, 'SUPTWO', 'Quote 12345A', 'CD Monthly Brochure', 'Fred Flint', 'PO Brochure or Catalogue', 2, @UserId, '20190427', '20190427', '20190531', null, 5000, '200', 'T0', 0.13, 650.0000, 'SUPTWO_001', 'EXWORK_001', 0, 0)
		, (CONCAT(@UserId, '_20018'), @UserId, 'TRACOM', 'Pallet scale rate', 'CD Monthly Brochure - Transport', 'Dave Gomez', 'PO Transport', 2, @UserId, '20190428', '20190428', '20190531', null, 2, '200', 'T1', 75, 150.0000, 'SUPTWO_002', 'CDCUST_002', 0, 0)
		, (CONCAT(@UserId, '_20019'), @UserId, 'SUPTWO', 'Quote 12345A', 'CD Monthly Brochure', 'Fred Flint', 'PO Brochure or Catalogue', 2, @UserId, '20190524', '20190524', '20190628', null, 5000, '200', 'T0', 0.13, 650.0000, 'SUPTWO_001', 'EXWORK_001', 0, 0)
		, (CONCAT(@UserId, '_20020'), @UserId, 'TRACOM', 'Pallet scale rate', 'CD Monthly Brochure - Transport', 'Dave Gomez', 'PO Transport', 2, @UserId, '20190525', '20190525', '20190628', null, 2, '200', 'T1', 75, 150.0000, 'SUPTWO_002', 'CDCUST_002', 0, 0)
		, (CONCAT(@UserId, '_20021'), @UserId, 'SUPTWO', 'Quote 12345A', 'CD Monthly Brochure', 'Fred Flint', 'PO Brochure or Catalogue', 2, @UserId, '20190626', '20190822', '20190731', null, 5000, '200', 'T0', 0.13, 650.0000, 'SUPTWO_001', 'EXWORK_001', 0, 0)
		, (CONCAT(@UserId, '_20022'), @UserId, 'TRACOM', 'Pallet scale rate', 'CD Monthly Brochure - Transport', 'Dave Gomez', 'PO Transport', 2, @UserId, '20190626', '20190822', '20190731', null, 2, '200', 'T1', 75, 150.0000, 'SUPTWO_002', 'CDCUST_002', 0, 0)
		, (CONCAT(@UserId, '_20025'), @UserId, 'SUPTWO', 'Quote 12345A', 'CD Monthly Brochure', 'Fred Flint', 'PO Brochure or Catalogue', 1, @UserId, '20190725', null, '20190830', null, 5000, '200', 'T0', 0.13, 650.0000, 'SUPTWO_001', 'EXWORK_001', 0, 0)
		, (CONCAT(@UserId, '_20026'), @UserId, 'TRACOM', 'Pallet scale rate', 'CD Monthly Brochure - Transport', 'Dave Gomez', 'PO Transport', 1, @UserId, '20190726', null, '20190830', null, 2, '200', 'T1', 75, 150.0000, 'SUPTWO_002', 'CDCUST_002', 0, 0)
		, (CONCAT(@UserId, '_20027'), @UserId, 'SUPTWO', 'Quote 12345A', 'CD Monthly Brochure', 'Fred Flint', 'PO Brochure or Catalogue', 1, @UserId, '20190827', null, '20190930', null, 5000, '200', 'T0', 0.13, 650.0000, 'SUPTWO_001', 'EXWORK_001', 0, 0)
		, (CONCAT(@UserId, '_20028'), @UserId, 'TRACOM', 'Pallet scale rate', 'CD Monthly Brochure - Transport', 'Dave Gomez', 'PO Transport', 0, @UserId, '20190828', null, '20190930', null, 2, '200', 'T1', 75, 150.0000, 'SUPTWO_002', 'CDCUST_002', 0, 0)
		, (CONCAT(@UserId, '_20029'), @UserId, 'SUPTHR', 'Estimate B115536', 'Outer Carton Ref X12', 'Georgia Onmymind', 'PO Packaging', 1, @UserId, '20190708', null, '20190830', null, 2000, '200', 'T1', 0.48, 960.0000, 'SUPTHR_001', 'EFCUST_002', 0, 0)
		, (CONCAT(@UserId, '_20031'), @UserId, 'SUPTWO', null, 'McBurger Scratchcards', 'Fred Flint', 'PO Promotional', 2, @UserId, '20190330', '20190708', '20190430', null, 5000000, '200', 'T1', 0.0012, 6000.0000, 'SUPTWO_001', 'SUPTWO_001', 0, 0)
		, (CONCAT(@UserId, '_20032'), @UserId, 'THEPAP', null, 'McBurger Scratchcards', 'Adam Jones', 'PO Packaging', 2, @UserId, '20190316', '20190708', '20190415', null, 13, '200', 'T1', 750, 9750.0000, 'THEPAP_001', 'SUPTWO_002', 0, 0)
		, (CONCAT(@UserId, '_20034'), @UserId, 'SUPONE', 'Scale rates', 'Test Book Order', 'Andy Brass', 'PO Book', 1, @UserId, '20190721', null, '20190830', null, 50, '200', 'T1', 11.9, 595.0000, 'ABCUST_001', 'ABCUST_001', 0, 0)
		, (CONCAT(@UserId, '_20035'), @UserId, 'TRACOM', null, 'Test Book Order', 'Andy Brass', 'PO Transport', 1, @UserId, '20190722', null, '20190830', null, 1, '200', 'T1', 75, 75.0000, 'SUPONE_002', 'ABCUST_002', 0, 0)
		, (CONCAT(@UserId, '_20037'), @UserId, 'SUPONE', 'Scale rates', 'Main Book Order', 'Andy Brass', 'PO Book', 1, @UserId, '20191026', null, '20191129', null, 1000, '200', 'T1', 7.95, 7950.0000, 'ABCUST_001', 'ABCUST_001', 0, 0)
		, (CONCAT(@UserId, '_20038'), @UserId, 'TRACOM', null, 'Main Book Order - Transport', 'Andy Brass', 'PO Transport', 1, @UserId, '20191027', null, '20191129', null, 8, '200', 'T1', 55, 440.0000, 'SUPONE_002', 'ABCUST_002', 0, 0)
		, (CONCAT(@UserId, '_30000'), @UserId, 'CDCUST', null, 'Monthly Brochures', null, 'Project', 0, @UserId, '20190101', null, '20190131', null, 1, null, null, 0, 0.0000, 'CDCUST_001', 'CDCUST_001', 0, 1)
		, (CONCAT(@UserId, '_30001'), @UserId, 'BUSOWN', null, 'Salaries', null, 'Project', 0, @UserId, '20191231', null, '20191231', null, 1, null, null, 0, 0.0000, 'CDCUST_001', 'CDCUST_001', 0, 1)
		, (CONCAT(@UserId, '_30002'), @UserId, 'TELPRO', null, 'Monthly Telecom Charges', null, 'Project', 0, @UserId, '20191231', null, '20191231', null, 1, null, null, 0, 0.0000, 'CDCUST_001', 'CDCUST_001', 0, 1)
		, (CONCAT(@UserId, '_40000'), @UserId, 'BUSOWN', null, '142 miles travel Client visit', null, 'Employee Transport', 2, @UserId, '20190110', '20190708', '20190131', null, 142, '212', 'T0', 0.45, 63.9000, null, null, 0, 1)
		, (CONCAT(@UserId, '_40003'), @UserId, 'BUSOWN', null, 'Car parking Client visit 10/1', null, 'Car Parking / Tolls', 2, @UserId, '20190110', '20190708', '20190131', null, 1, '213', 'T1', 4, 4.0000, null, null, 0, 1)
		, (CONCAT(@UserId, '_40004'), @UserId, 'BUSOWN', null, 'Rental for Home Office use £4/week x 4 weeks', null, 'Office Rent', 2, @UserId, '20190131', '20190708', '20190131', null, 4, '205', 'T0', 4, 16.0000, null, null, 0, 1)
		, (CONCAT(@UserId, '_40005'), @UserId, 'BUSOWN', null, 'Wages', null, 'Wages monthly payment', 2, @UserId, '20190131', '20190708', '20190131', null, 1, '402', 'NI1', 1000, 1000.0000, null, null, 0, 1)
		, (CONCAT(@UserId, '_40006'), @UserId, 'BUSOWN', null, 'Wages', null, 'Wages monthly payment', 2, @UserId, '20190228', '20190708', '20190228', null, 1, '402', 'NI1', 1000, 1000.0000, null, null, 0, 1)
		, (CONCAT(@UserId, '_40007'), @UserId, 'BUSOWN', null, 'Wages', null, 'Wages monthly payment', 2, @UserId, '20190329', '20190708', '20190329', null, 1, '402', 'NI1', 1000, 1000.0000, null, null, 0, 1)
		, (CONCAT(@UserId, '_40008'), @UserId, 'BUSOWN', null, 'Wages', null, 'Wages monthly payment', 2, @UserId, '20190430', '20190708', '20190430', null, 1, '402', 'NI1', 1000, 1000.0000, null, null, 0, 1)
		, (CONCAT(@UserId, '_40009'), @UserId, 'BUSOWN', null, 'Wages', null, 'Wages monthly payment', 2, @UserId, '20190531', '20190708', '20190531', null, 1, '402', 'NI1', 1000, 1000.0000, null, null, 0, 1)
		, (CONCAT(@UserId, '_40010'), @UserId, 'BUSOWN', null, 'Wages', null, 'Wages monthly payment', 2, @UserId, '20190628', '20190708', '20190628', null, 1, '402', 'NI1', 1000, 1000.0000, null, null, 0, 1)
		, (CONCAT(@UserId, '_40011'), @UserId, 'BUSOWN', null, 'Wages', null, 'Wages monthly payment', 2, @UserId, '20190731', '20190822', '20190731', null, 1, '402', 'NI1', 1000, 1000.0000, null, null, 0, 1)
		, (CONCAT(@UserId, '_40012'), @UserId, 'BUSOWN', null, 'Wages', null, 'Wages monthly payment', 1, @UserId, '20190830', null, '20190830', null, 1, '402', 'NI1', 1000, 1000.0000, null, null, 0, 1)
		, (CONCAT(@UserId, '_40013'), @UserId, 'BUSOWN', null, 'Wages', null, 'Wages monthly payment', 1, @UserId, '20190930', null, '20190930', null, 1, '402', 'NI1', 1000, 1000.0000, null, null, 0, 1)
		, (CONCAT(@UserId, '_40014'), @UserId, 'BUSOWN', null, 'Wages', null, 'Wages monthly payment', 0, @UserId, '20191031', null, '20191031', null, 1, '402', 'NI1', 1000, 1000.0000, null, null, 0, 1)
		, (CONCAT(@UserId, '_40015'), @UserId, 'BUSOWN', null, 'Wages', null, 'Wages monthly payment', 0, @UserId, '20191129', null, '20191129', null, 1, '402', 'NI1', 1000, 1000.0000, null, null, 0, 1)
		, (CONCAT(@UserId, '_40016'), @UserId, 'BUSOWN', null, 'Wages', null, 'Wages monthly payment', 0, @UserId, '20191231', null, '20191231', null, 1, '402', 'NI1', 1000, 1000.0000, null, null, 0, 1)
		, (CONCAT(@UserId, '_40017'), @UserId, 'BUSOWN', null, '185 miles press pass book sections', null, 'Employee Transport', 2, @UserId, '20190215', '20190708', '20190228', null, 185, '212', 'T0', 0.45, 83.2500, null, null, 0, 1)
		, (CONCAT(@UserId, '_40018'), @UserId, 'BUSOWN', null, '24 First Class postage stamps', null, 'Postage', 2, @UserId, '20190208', '20190708', '20190228', null, 1, '207', 'T0', 19.2, 19.2000, null, null, 0, 1)
		, (CONCAT(@UserId, '_40019'), @UserId, 'BUSOWN', null, 'Rental for Home Office use £4/week x 4 weeks', null, 'Office Rent', 2, @UserId, '20190228', '20190708', '20190228', null, 1, '205', 'T0', 16, 16.0000, null, null, 0, 1)
		, (CONCAT(@UserId, '_40020'), @UserId, 'BUSOWN', null, '178 miles visiting AB Ltd', null, 'Employee Transport', 2, @UserId, '20190302', '20190708', '20190329', null, 178, '212', 'T0', 0.45, 80.1000, null, null, 0, 1)
		, (CONCAT(@UserId, '_40021'), @UserId, 'BUSOWN', null, 'Dartford Crossing x 2', null, 'Car Parking / Tolls', 2, @UserId, '20190302', '20190708', '20190329', null, 1, '213', 'T0', 5, 5.0000, null, null, 0, 1)
		, (CONCAT(@UserId, '_40022'), @UserId, 'BUSOWN', null, 'Rental for Home Office use £4/week x 5 weeks', null, 'Office Rent', 2, @UserId, '20190329', '20190708', '20190329', null, 1, '205', 'T0', 20, 20.0000, null, null, 0, 1)
		, (CONCAT(@UserId, '_40023'), @UserId, 'BUSOWN', null, 'Business mileage April 19 total 340 miles', null, 'Employee Transport', 2, @UserId, '20190430', '20190708', '20190430', null, 340, '212', 'T0', 0.45, 153.0000, null, null, 0, 1)
		, (CONCAT(@UserId, '_40024'), @UserId, 'BUSOWN', null, 'Rental for Home Office use £4/week x 4 weeks', null, 'Office Rent', 2, @UserId, '20190430', '20190708', '20190430', null, 1, '205', 'T0', 16, 16.0000, null, null, 0, 1)
		, (CONCAT(@UserId, '_40025'), @UserId, 'BUSOWN', null, 'Business mileage May 19 total 395 miles', null, 'Employee Transport', 2, @UserId, '20190531', '20190708', '20190531', null, 395, '212', 'T0', 0.45, 177.7500, null, null, 0, 1)
		, (CONCAT(@UserId, '_40026'), @UserId, 'BUSOWN', null, '6 reams of office paper', null, 'Stationery - General', 2, @UserId, '20190531', '20190708', '20190531', null, 1, '209', 'T1', 18, 18.0000, null, null, 0, 1)
		, (CONCAT(@UserId, '_40027'), @UserId, 'BUSOWN', null, 'Rental for Home Office use £4/week x 4 weeks', null, 'Office Rent', 2, @UserId, '20190531', '20190708', '20190531', null, 1, '205', 'T0', 16, 16.0000, null, null, 0, 1)
		, (CONCAT(@UserId, '_40028'), @UserId, 'BUSOWN', null, 'Business mileage June 19 412miles', null, 'Employee Transport', 2, @UserId, '20190628', '20190708', '20190628', null, 412, '212', 'T0', 0.45, 185.4000, null, null, 0, 1)
		, (CONCAT(@UserId, '_40029'), @UserId, 'BUSOWN', null, 'Car parking Client visit 10/6', null, 'Car Parking / Tolls', 2, @UserId, '20190610', '20190708', '20190628', null, 1, '213', 'T1', 5, 5.0000, null, null, 0, 1)
		, (CONCAT(@UserId, '_40030'), @UserId, 'BUSOWN', null, 'Rental for Home Office use £4/week x 4 weeks', null, 'Office Rent', 2, @UserId, '20190628', '20190708', '20190628', null, 1, '205', 'T0', 12, 12.0000, null, null, 0, 1)
		, (CONCAT(@UserId, '_40031'), @UserId, 'TELPRO', null, 'Telecom Charge', null, 'Communications monthly charge', 2, @UserId, '20190125', '20190125', '20190125', null, 1, '202', 'T1', 40, 40.0000, null, null, 0, 1)
		, (CONCAT(@UserId, '_40032'), @UserId, 'TELPRO', null, 'Telecom Charge', null, 'Communications monthly charge', 2, @UserId, '20190226', '20190226', '20190226', null, 1, '202', 'T1', 39.6, 39.6000, null, null, 0, 1)
		, (CONCAT(@UserId, '_40033'), @UserId, 'TELPRO', null, 'Telecom Charge', null, 'Communications monthly charge', 2, @UserId, '20190326', '20190326', '20190326', null, 1, '202', 'T1', 43.12, 43.1200, null, null, 0, 1)
		, (CONCAT(@UserId, '_40034'), @UserId, 'TELPRO', null, 'Telecom Charge', null, 'Communications monthly charge', 2, @UserId, '20190426', '20190326', '20190426', null, 1, '202', 'T1', 43.52, 43.5200, null, null, 0, 1)
		, (CONCAT(@UserId, '_40035'), @UserId, 'TELPRO', null, 'Telecom Charge', null, 'Communications monthly charge', 2, @UserId, '20190524', '20190524', '20190524', null, 1, '202', 'T1', 42.52, 42.5200, null, null, 0, 1)
		, (CONCAT(@UserId, '_40036'), @UserId, 'TELPRO', null, 'Telecom Charge', null, 'Communications monthly charge', 2, @UserId, '20190626', '20190626', '20190626', null, 1, '202', 'T1', 41.15, 41.1500, null, null, 0, 1)
		, (CONCAT(@UserId, '_40037'), @UserId, 'TELPRO', null, 'Telecom Charge', null, 'Communications monthly charge', 2, @UserId, '20190726', '20190822', '20190726', null, 1, '202', 'T1', 40, 40.0000, null, null, 0, 1)
		, (CONCAT(@UserId, '_40038'), @UserId, 'TELPRO', null, 'Telecom Charge', null, 'Communications monthly charge', 1, @UserId, '20190826', null, '20190826', null, 1, '202', 'T1', 40, 40.0000, null, null, 0, 1)
		, (CONCAT(@UserId, '_40039'), @UserId, 'TELPRO', null, 'Telecom Charge', null, 'Communications monthly charge', 1, @UserId, '20190926', null, '20190926', null, 1, '202', 'T1', 40, 40.0000, null, null, 0, 1)
		, (CONCAT(@UserId, '_40040'), @UserId, 'TELPRO', null, 'Telecom Charge', null, 'Communications monthly charge', 0, @UserId, '20191025', null, '20191025', null, 1, '202', 'T1', 40, 40.0000, null, null, 0, 1)
		, (CONCAT(@UserId, '_40041'), @UserId, 'TELPRO', null, 'Telecom Charge', null, 'Communications monthly charge', 0, @UserId, '20191126', null, '20191126', null, 1, '202', 'T1', 40, 40.0000, null, null, 0, 1)
		, (CONCAT(@UserId, '_40042'), @UserId, 'TELPRO', null, 'Telecom Charge', null, 'Communications monthly charge', 0, @UserId, '20191224', null, '20191224', null, 1, '202', 'T1', 40, 40.0000, null, null, 0, 1)
		, (CONCAT(@UserId, '_40044'), @UserId, 'BUSOWN', null, 'Subsistence for NEC Show', null, 'Subsistence', 2, @UserId, '20190801', '20190801', '20190830', null, 1, '218', 'T0', 8.5, 8.5000, null, null, 0, 1)
		, (CONCAT(@UserId, '_40045'), @UserId, 'BUSOWN', null, '320 miles travel to NEC Show', null, 'Employee Transport', 1, @UserId, '20190801', null, '20190830', null, 212, '212', 'T0', 0.45, 95.4000, null, null, 0, 1)
		, (CONCAT(@UserId, '_40046'), @UserId, 'SUNSUP', null, 'Ring Binders x 12 from local shop', null, 'Stationery - General', 2, @UserId, '20190702', '20190722', '20190702', null, 12, '209', 'T1', 4.5, 54.0000, null, null, 0, 1)
		;
		INSERT INTO Task.tbFlow (ParentTaskCode, StepNumber, ChildTaskCode, SyncTypeCode, UsedOnQuantity, OffsetDays)
		VALUES (CONCAT(@UserId, '_10000'), 10, CONCAT(@UserId, '_20000'), 0, 0, 0)
		, (CONCAT(@UserId, '_10007'), 10, CONCAT(@UserId, '_20010'), 0, 0, 7)
		, (CONCAT(@UserId, '_10007'), 20, CONCAT(@UserId, '_20011'), 0, 0, -7)
		, (CONCAT(@UserId, '_10008'), 10, CONCAT(@UserId, '_20013'), 0, 0, -2)
		, (CONCAT(@UserId, '_10008'), 20, CONCAT(@UserId, '_20014'), 0, 0, 0)
		, (CONCAT(@UserId, '_10009'), 10, CONCAT(@UserId, '_20015'), 0, 0, 11)
		, (CONCAT(@UserId, '_10009'), 20, CONCAT(@UserId, '_20016'), 0, 0, 56)
		, (CONCAT(@UserId, '_10010'), 10, CONCAT(@UserId, '_20017'), 0, 0, 0)
		, (CONCAT(@UserId, '_10010'), 20, CONCAT(@UserId, '_20018'), 0, 0, 0)
		, (CONCAT(@UserId, '_10011'), 10, CONCAT(@UserId, '_20019'), 0, 0, -10)
		, (CONCAT(@UserId, '_10011'), 20, CONCAT(@UserId, '_20020'), 0, 0, 0)
		, (CONCAT(@UserId, '_10012'), 10, CONCAT(@UserId, '_20022'), 0, 0, 0)
		, (CONCAT(@UserId, '_10012'), 20, CONCAT(@UserId, '_20021'), 0, 0, 1)
		, (CONCAT(@UserId, '_10013'), 10, CONCAT(@UserId, '_20025'), 0, 0, 1)
		, (CONCAT(@UserId, '_10013'), 30, CONCAT(@UserId, '_20026'), 0, 0, 0)
		, (CONCAT(@UserId, '_10014'), 10, CONCAT(@UserId, '_20027'), 0, 0, 1)
		, (CONCAT(@UserId, '_10014'), 30, CONCAT(@UserId, '_20028'), 0, 0, 0)
		, (CONCAT(@UserId, '_10015'), 10, CONCAT(@UserId, '_20029'), 0, 0, 0)
		, (CONCAT(@UserId, '_10017'), 10, CONCAT(@UserId, '_20032'), 0, 0, 10)
		, (CONCAT(@UserId, '_10017'), 20, CONCAT(@UserId, '_20031'), 0, 0, 0)
		, (CONCAT(@UserId, '_10018'), 10, CONCAT(@UserId, '_20034'), 0, 0, 1)
		, (CONCAT(@UserId, '_10018'), 20, CONCAT(@UserId, '_20035'), 0, 0, 0)
		, (CONCAT(@UserId, '_10019'), 10, CONCAT(@UserId, '_20037'), 0, 0, 0)
		, (CONCAT(@UserId, '_10019'), 20, CONCAT(@UserId, '_20038'), 0, 0, 0)
		, (CONCAT(@UserId, '_30000'), 10, CONCAT(@UserId, '_10007'), 0, 0, 0)
		, (CONCAT(@UserId, '_30000'), 20, CONCAT(@UserId, '_10008'), 0, 0, 0)
		, (CONCAT(@UserId, '_30000'), 30, CONCAT(@UserId, '_10009'), 0, 0, 0)
		, (CONCAT(@UserId, '_30000'), 40, CONCAT(@UserId, '_10010'), 0, 0, 0)
		, (CONCAT(@UserId, '_30000'), 50, CONCAT(@UserId, '_10011'), 0, 0, 0)
		, (CONCAT(@UserId, '_30000'), 60, CONCAT(@UserId, '_10012'), 0, 0, 0)
		, (CONCAT(@UserId, '_30000'), 70, CONCAT(@UserId, '_10013'), 0, 0, 0)
		, (CONCAT(@UserId, '_30000'), 80, CONCAT(@UserId, '_10014'), 0, 0, 0)
		, (CONCAT(@UserId, '_30001'), 10, CONCAT(@UserId, '_40005'), 0, 0, 0)
		, (CONCAT(@UserId, '_30001'), 20, CONCAT(@UserId, '_40006'), 0, 0, 0)
		, (CONCAT(@UserId, '_30001'), 30, CONCAT(@UserId, '_40007'), 0, 0, 0)
		, (CONCAT(@UserId, '_30001'), 40, CONCAT(@UserId, '_40008'), 0, 0, 0)
		, (CONCAT(@UserId, '_30001'), 50, CONCAT(@UserId, '_40009'), 0, 0, 0)
		, (CONCAT(@UserId, '_30001'), 60, CONCAT(@UserId, '_40010'), 0, 0, 0)
		, (CONCAT(@UserId, '_30001'), 70, CONCAT(@UserId, '_40011'), 0, 0, 0)
		, (CONCAT(@UserId, '_30001'), 80, CONCAT(@UserId, '_40012'), 0, 0, 0)
		, (CONCAT(@UserId, '_30001'), 90, CONCAT(@UserId, '_40013'), 0, 0, 0)
		, (CONCAT(@UserId, '_30001'), 100, CONCAT(@UserId, '_40014'), 0, 0, 0)
		, (CONCAT(@UserId, '_30001'), 110, CONCAT(@UserId, '_40015'), 0, 0, 0)
		, (CONCAT(@UserId, '_30001'), 120, CONCAT(@UserId, '_40016'), 0, 0, 0)
		, (CONCAT(@UserId, '_30002'), 10, CONCAT(@UserId, '_40031'), 0, 0, 0)
		, (CONCAT(@UserId, '_30002'), 20, CONCAT(@UserId, '_40032'), 0, 0, 0)
		, (CONCAT(@UserId, '_30002'), 30, CONCAT(@UserId, '_40033'), 0, 0, 0)
		, (CONCAT(@UserId, '_30002'), 40, CONCAT(@UserId, '_40034'), 0, 0, 0)
		, (CONCAT(@UserId, '_30002'), 50, CONCAT(@UserId, '_40035'), 0, 0, 0)
		, (CONCAT(@UserId, '_30002'), 60, CONCAT(@UserId, '_40036'), 0, 0, 0)
		, (CONCAT(@UserId, '_30002'), 70, CONCAT(@UserId, '_40037'), 0, 0, 0)
		, (CONCAT(@UserId, '_30002'), 80, CONCAT(@UserId, '_40038'), 0, 0, 0)
		, (CONCAT(@UserId, '_30002'), 90, CONCAT(@UserId, '_40039'), 0, 0, 0)
		, (CONCAT(@UserId, '_30002'), 100, CONCAT(@UserId, '_40040'), 0, 0, 0)
		, (CONCAT(@UserId, '_30002'), 110, CONCAT(@UserId, '_40041'), 0, 0, 0)
		, (CONCAT(@UserId, '_30002'), 120, CONCAT(@UserId, '_40042'), 0, 0, 0)
		;
		INSERT INTO Task.tbOp (TaskCode, OperationNumber, SyncTypeCode, OpStatusCode, UserId, Operation, Note, StartOn, EndOn, Duration, OffsetDays)
		VALUES (CONCAT(@UserId, '_10000'), 10, 0, 1, @UserId, 'Artwork', null, '20190718', '20190718', 0, 0)
		, (CONCAT(@UserId, '_10000'), 20, 0, 0, @UserId, 'Proofs', null, '20190718', '20190718', 0, 0)
		, (CONCAT(@UserId, '_10000'), 30, 0, 0, @UserId, 'Approval', null, '20190717', '20190717', 0, 0)
		, (CONCAT(@UserId, '_10000'), 40, 2, 0, @UserId, 'Delivery', null, '20190725', '20190910', 0, 0)
		, (CONCAT(@UserId, '_10007'), 10, 0, 2, @UserId, 'Artwork', 'by 5pm', '20190118', '20190120', 0, 0)
		, (CONCAT(@UserId, '_10007'), 20, 0, 2, @UserId, 'Proofs', 'by noon', '20190117', '20190121', 0, 2)
		, (CONCAT(@UserId, '_10007'), 30, 0, 2, @UserId, 'Approval', 'by 4pm', '20190116', '20190121', 0, 3)
		, (CONCAT(@UserId, '_10007'), 40, 2, 2, @UserId, 'Delivery', null, '20190118', '20190126', 0, 1)
		, (CONCAT(@UserId, '_10008'), 10, 0, 2, @UserId, 'Artwork', 'by 5pm', '20190219', '20190219', 0, 0)
		, (CONCAT(@UserId, '_10008'), 20, 0, 2, @UserId, 'Proofs', 'by noon', '20190218', '20190220', 0, 2)
		, (CONCAT(@UserId, '_10008'), 30, 0, 2, @UserId, 'Approval', 'by 4pm', '20190215', '20190220', 0, 3)
		, (CONCAT(@UserId, '_10008'), 40, 2, 2, @UserId, 'Delivery', null, '20190218', '20190225', 0, 1)
		, (CONCAT(@UserId, '_10009'), 10, 0, 2, @UserId, 'Artwork', 'by 5pm', '20190322', '20190323', 0, 0)
		, (CONCAT(@UserId, '_10009'), 20, 0, 2, @UserId, 'Proofs', 'by noon', '20190320', '20190324', 0, 2)
		, (CONCAT(@UserId, '_10009'), 30, 0, 2, @UserId, 'Approval', 'by 4pm', '20190319', '20190324', 0, 3)
		, (CONCAT(@UserId, '_10009'), 40, 2, 2, @UserId, 'Delivery', null, '20190321', '20190328', 0, 1)
		, (CONCAT(@UserId, '_10010'), 10, 0, 2, @UserId, 'Artwork', 'by 5pm', '20190423', '20190423', 0, 0)
		, (CONCAT(@UserId, '_10010'), 20, 0, 2, @UserId, 'Proofs', 'by noon', '20190422', '20190424', 0, 2)
		, (CONCAT(@UserId, '_10010'), 30, 0, 2, @UserId, 'Approval', 'by 4pm', '20190419', '20190424', 0, 3)
		, (CONCAT(@UserId, '_10010'), 40, 2, 2, @UserId, 'Delivery', null, '20190419', '20190428', 0, 1)
		, (CONCAT(@UserId, '_10011'), 10, 0, 2, @UserId, 'Artwork', 'by 5pm', '20190517', '20190519', 0, 0)
		, (CONCAT(@UserId, '_10011'), 20, 0, 2, @UserId, 'Proofs', 'by noon', '20190516', '20190520', 0, 2)
		, (CONCAT(@UserId, '_10011'), 30, 0, 2, @UserId, 'Approval', 'by 4pm', '20190515', '20190520', 0, 3)
		, (CONCAT(@UserId, '_10011'), 40, 2, 2, @UserId, 'Delivery', null, '20190517', '20190525', 0, 5)
		, (CONCAT(@UserId, '_10012'), 10, 0, 2, @UserId, 'Artwork', 'by 5pm', '20190620', '20190620', 0, 0)
		, (CONCAT(@UserId, '_10012'), 20, 0, 2, @UserId, 'Proofs', 'by noon', '20190619', '20190621', 0, 2)
		, (CONCAT(@UserId, '_10012'), 30, 0, 2, @UserId, 'Approval', 'by 4pm', '20190618', '20190621', 0, 3)
		, (CONCAT(@UserId, '_10012'), 40, 2, 2, @UserId, 'Delivery', null, '20190620', '20190627', 0, 5)
		, (CONCAT(@UserId, '_10013'), 10, 0, 1, @UserId, 'Artwork', 'by 5pm', '20190719', '20190719', 0, 0)
		, (CONCAT(@UserId, '_10013'), 20, 0, 0, @UserId, 'Proofs', 'by noon', '20190718', '20190722', 0, 2)
		, (CONCAT(@UserId, '_10013'), 30, 0, 0, @UserId, 'Approval', 'by 4pm', '20190717', '20190722', 0, 3)
		, (CONCAT(@UserId, '_10013'), 40, 2, 0, @UserId, 'Delivery', null, '20190719', '20190726', 0, 5)
		, (CONCAT(@UserId, '_10014'), 10, 0, 1, @UserId, 'Artwork', 'by 5pm', '20190819', '20190819', 0, 0)
		, (CONCAT(@UserId, '_10014'), 20, 0, 0, @UserId, 'Proofs', 'by noon', '20190816', '20190820', 0, 2)
		, (CONCAT(@UserId, '_10014'), 30, 0, 0, @UserId, 'Approval', 'by 4pm', '20190815', '20190820', 0, 3)
		, (CONCAT(@UserId, '_10014'), 40, 2, 0, @UserId, 'Delivery', null, '20190821', '20190828', 0, 5)
		, (CONCAT(@UserId, '_10015'), 40, 2, 0, @UserId, 'Delivery', null, '20190701', '20190917', 0, 5)
		, (CONCAT(@UserId, '_10017'), 10, 0, 2, @UserId, 'Artwork', null, '20190308', '20190308', 0, 0)
		, (CONCAT(@UserId, '_10017'), 20, 0, 2, @UserId, 'Proofs', null, '20190310', '20190310', 0, 0)
		, (CONCAT(@UserId, '_10017'), 30, 0, 2, @UserId, 'Approval', null, '20190311', '20190311', 0, 0)
		, (CONCAT(@UserId, '_10017'), 40, 0, 2, @UserId, 'Delivery', null, '20190331', '20190331', 0, 0)
		, (CONCAT(@UserId, '_10018'), 10, 0, 1, @UserId, 'Artwork', null, '20190708', '20190708', 0, 0)
		, (CONCAT(@UserId, '_10018'), 20, 0, 0, @UserId, 'Proofs', null, '20190708', '20190709', 0, 1)
		, (CONCAT(@UserId, '_10018'), 30, 0, 0, @UserId, 'Approval', null, '20190709', '20190711', 0, 2)
		, (CONCAT(@UserId, '_10018'), 40, 2, 0, @UserId, 'Delivery', null, '20190711', '20190903', 0, 1)
		, (CONCAT(@UserId, '_10019'), 10, 0, 1, @UserId, 'Artwork', null, '20191008', '20191008', 0, 0)
		, (CONCAT(@UserId, '_10019'), 20, 0, 0, @UserId, 'Proofs', null, '20191008', '20191009', 0, 1)
		, (CONCAT(@UserId, '_10019'), 30, 0, 0, @UserId, 'Approval', null, '20191008', '20191010', 0, 2)
		, (CONCAT(@UserId, '_10019'), 40, 2, 0, @UserId, 'Delivery', null, '20191004', '20191027', 0, 1)
		, (CONCAT(@UserId, '_20010'), 10, 0, 2, @UserId, 'Artwork', 'by 5pm', '20190118', '20190120', 0, 0)
		, (CONCAT(@UserId, '_20010'), 20, 0, 2, @UserId, 'Proofs', 'by noon', '20190121', '20190121', 0, 0)
		, (CONCAT(@UserId, '_20010'), 30, 0, 2, @UserId, 'Approval', 'by 4pm', '20190121', '20190121', 0, 0)
		, (CONCAT(@UserId, '_20010'), 50, 2, 2, @UserId, 'Collection', 'from 10am', '20190125', '20190125', 0, 0)
		, (CONCAT(@UserId, '_20011'), 10, 0, 2, @UserId, 'Collect', 'after 10am', '20190125', '20190125', 0, 0)
		, (CONCAT(@UserId, '_20011'), 20, 2, 2, @UserId, 'Delivery', null, '20190125', '20190126', 0, 0)
		, (CONCAT(@UserId, '_20013'), 10, 0, 2, @UserId, 'Artwork', 'by 5pm', '20190219', '20190219', 0, 0)
		, (CONCAT(@UserId, '_20013'), 20, 0, 2, @UserId, 'Proofs', 'by noon', '20190220', '20190220', 0, 0)
		, (CONCAT(@UserId, '_20013'), 30, 0, 2, @UserId, 'Approval', 'by 4pm', '20190220', '20190220', 0, 0)
		, (CONCAT(@UserId, '_20013'), 50, 2, 2, @UserId, 'Collection', 'from 10am', '20190222', '20190224', 0, 0)
		, (CONCAT(@UserId, '_20014'), 10, 0, 2, @UserId, 'Collect', 'after 10am', '20190222', '20190224', 0, 0)
		, (CONCAT(@UserId, '_20014'), 20, 2, 2, @UserId, 'Delivery', null, '20190225', '20190225', 0, 0)
		, (CONCAT(@UserId, '_20015'), 10, 0, 2, @UserId, 'Artwork', 'by 5pm', '20190322', '20190323', 0, 0)
		, (CONCAT(@UserId, '_20015'), 20, 0, 2, @UserId, 'Proofs', 'by noon', '20190322', '20190324', 0, 0)
		, (CONCAT(@UserId, '_20015'), 30, 0, 2, @UserId, 'Approval', 'by 4pm', '20190322', '20190324', 0, 0)
		, (CONCAT(@UserId, '_20015'), 50, 2, 2, @UserId, 'Collection', 'from 10am', '20190327', '20190327', 0, 0)
		, (CONCAT(@UserId, '_20016'), 10, 0, 2, @UserId, 'Collect', 'after 10am', '20190327', '20190327', 0, 0)
		, (CONCAT(@UserId, '_20016'), 20, 2, 2, @UserId, 'Delivery', null, '20190328', '20190328', 0, 0)
		, (CONCAT(@UserId, '_20017'), 10, 0, 2, @UserId, 'Artwork', 'by 5pm', '20190423', '20190423', 0, 0)
		, (CONCAT(@UserId, '_20017'), 20, 0, 2, @UserId, 'Proofs', 'by noon', '20190424', '20190424', 0, 0)
		, (CONCAT(@UserId, '_20017'), 30, 0, 2, @UserId, 'Approval', 'by 4pm', '20190424', '20190424', 0, 0)
		, (CONCAT(@UserId, '_20017'), 50, 2, 2, @UserId, 'Collection', 'from 10am', '20190426', '20190427', 0, 0)
		, (CONCAT(@UserId, '_20018'), 10, 0, 2, @UserId, 'Collect', 'after 10am', '20190426', '20190427', 0, 0)
		, (CONCAT(@UserId, '_20018'), 20, 2, 2, @UserId, 'Delivery', null, '20190426', '20190428', 0, 0)
		, (CONCAT(@UserId, '_20019'), 10, 0, 2, @UserId, 'Artwork', 'by 5pm', '20190517', '20190519', 0, 0)
		, (CONCAT(@UserId, '_20019'), 20, 0, 2, @UserId, 'Proofs', 'by noon', '20190520', '20190520', 0, 0)
		, (CONCAT(@UserId, '_20019'), 30, 0, 2, @UserId, 'Approval', 'by 4pm', '20190520', '20190520', 0, 0)
		, (CONCAT(@UserId, '_20019'), 50, 2, 2, @UserId, 'Collection', 'from 10am', '20190524', '20190524', 0, 0)
		, (CONCAT(@UserId, '_20020'), 10, 0, 2, @UserId, 'Collect', 'after 10am', '20190524', '20190524', 0, 0)
		, (CONCAT(@UserId, '_20020'), 20, 2, 2, @UserId, 'Delivery', null, '20190524', '20190525', 0, 0)
		, (CONCAT(@UserId, '_20021'), 10, 0, 2, @UserId, 'Artwork', 'by 5pm', '20190620', '20190620', 0, 0)
		, (CONCAT(@UserId, '_20021'), 20, 0, 2, @UserId, 'Proofs', 'by noon', '20190621', '20190621', 0, 0)
		, (CONCAT(@UserId, '_20021'), 30, 0, 2, @UserId, 'Approval', 'by 4pm', '20190621', '20190621', 0, 0)
		, (CONCAT(@UserId, '_20021'), 50, 2, 2, @UserId, 'Collection', 'from 10am', '20190626', '20190626', 0, 0)
		, (CONCAT(@UserId, '_20022'), 10, 0, 2, @UserId, 'Collect', 'after 10am', '20190625', '20190625', 0, 0)
		, (CONCAT(@UserId, '_20022'), 20, 2, 2, @UserId, 'Delivery', null, '20190626', '20190626', 0, 0)
		, (CONCAT(@UserId, '_20025'), 10, 0, 1, @UserId, 'Artwork', 'by 5pm', '20190719', '20190719', 0, 0)
		, (CONCAT(@UserId, '_20025'), 20, 0, 0, @UserId, 'Proofs', 'by noon', '20190722', '20190722', 0, 0)
		, (CONCAT(@UserId, '_20025'), 30, 0, 0, @UserId, 'Approval', 'by 4pm', '20190722', '20190722', 0, 0)
		, (CONCAT(@UserId, '_20025'), 50, 2, 0, @UserId, 'Collection', 'from 10am', '20190725', '20190725', 0, 0)
		, (CONCAT(@UserId, '_20026'), 10, 0, 1, @UserId, 'Collect', 'after 10am', '20190725', '20190725', 0, 0)
		, (CONCAT(@UserId, '_20026'), 20, 2, 0, @UserId, 'Delivery', null, '20190726', '20190726', 0, 0)
		, (CONCAT(@UserId, '_20027'), 10, 0, 1, @UserId, 'Artwork', 'by 5pm', '20190819', '20190819', 0, 0)
		, (CONCAT(@UserId, '_20027'), 20, 0, 0, @UserId, 'Proofs', 'by noon', '20190820', '20190820', 0, 0)
		, (CONCAT(@UserId, '_20027'), 30, 0, 0, @UserId, 'Approval', 'by 4pm', '20190820', '20190820', 0, 0)
		, (CONCAT(@UserId, '_20027'), 50, 2, 0, @UserId, 'Collection', 'from 10am', '20190827', '20190827', 0, 0)
		, (CONCAT(@UserId, '_20028'), 10, 0, 1, @UserId, 'Collect', 'after 10am', '20190827', '20190827', 0, 0)
		, (CONCAT(@UserId, '_20028'), 20, 2, 0, @UserId, 'Delivery', null, '20190828', '20190828', 0, 0)
		, (CONCAT(@UserId, '_20031'), 10, 0, 2, @UserId, 'Artwork', null, '20190308', '20190308', 0, 0)
		, (CONCAT(@UserId, '_20031'), 20, 0, 2, @UserId, 'Proofs', null, '20190308', '20190310', 0, 0)
		, (CONCAT(@UserId, '_20031'), 30, 0, 2, @UserId, 'Approval', null, '20190311', '20190311', 0, 0)
		, (CONCAT(@UserId, '_20031'), 35, 0, 2, @UserId, 'Paper In', null, '20190316', '20190316', 0, 0)
		, (CONCAT(@UserId, '_20031'), 40, 0, 2, @UserId, 'Delivery', null, '20190328', '20190328', 0, 0)
		, (CONCAT(@UserId, '_20032'), 10, 0, 2, @UserId, 'Delivery', null, '20190316', '20190316', 0, 0)
		, (CONCAT(@UserId, '_20034'), 10, 0, 0, @UserId, 'Artwork', null, '20190708', '20190708', 0, 0)
		, (CONCAT(@UserId, '_20034'), 20, 0, 0, @UserId, 'Proofs', null, '20190709', '20190709', 0, 0)
		, (CONCAT(@UserId, '_20034'), 30, 0, 0, @UserId, 'Approval', null, '20190711', '20190711', 0, 0)
		, (CONCAT(@UserId, '_20034'), 40, 0, 0, @UserId, 'Collection', 'between 10am - 4pm', '20190721', '20190721', 0, 0)
		, (CONCAT(@UserId, '_20035'), 10, 0, 1, @UserId, 'Collection', null, '20190719', '20190721', 0, 0)
		, (CONCAT(@UserId, '_20035'), 20, 2, 0, @UserId, 'Delivery', null, '20190722', '20190722', 0, 0)
		, (CONCAT(@UserId, '_20037'), 10, 0, 1, @UserId, 'Artwork', null, '20190808', '20190808', 0, 0)
		, (CONCAT(@UserId, '_20037'), 20, 0, 0, @UserId, 'Proofs', null, '20190808', '20190808', 0, 0)
		, (CONCAT(@UserId, '_20037'), 30, 0, 0, @UserId, 'Approval', null, '20190808', '20190808', 0, 0)
		, (CONCAT(@UserId, '_20037'), 40, 0, 0, @UserId, 'Collection', 'between 10am - 4pm', '20190808', '20190808', 0, 0)
		, (CONCAT(@UserId, '_20038'), 10, 0, 1, @UserId, 'Collection', null, '20191025', '20191026', 0, 0)
		, (CONCAT(@UserId, '_20038'), 20, 2, 0, @UserId, 'Delivery', null, '20191025', '20191027', 0, 0)
		, (CONCAT(@UserId, '_40026'), 10, 0, 2, @UserId, 'Artwork', null, '20190624', '20190624', 0, 0)
		, (CONCAT(@UserId, '_40026'), 20, 0, 2, @UserId, 'Proofs', null, '20190624', '20190626', 0, 2)
		, (CONCAT(@UserId, '_40026'), 30, 0, 2, @UserId, 'Approval', null, '20190626', '20190701', 0, 3)
		, (CONCAT(@UserId, '_40026'), 40, 2, 2, @UserId, 'Delivery', null, '20190701', '20190708', 0, 1)
		;
		INSERT INTO Task.tbQuote (TaskCode, Quantity, TotalPrice, RunOnQuantity, RunOnPrice, RunBackQuantity, RunBackPrice)
		VALUES (CONCAT(@UserId, '_10014'), 5000, 1000.0000, 1000, 50.0000, 1000, 45)
		, (CONCAT(@UserId, '_10014'), 10000, 1400.0000, 1000, 48.0000, 1000, 43)
		, (CONCAT(@UserId, '_10014'), 20000, 2200.0000, 1000, 45.0000, 1000, 42)
		;
		INSERT INTO Task.tbAttribute (TaskCode, Attribute, PrintOrder, AttributeTypeCode, AttributeDescription)
		VALUES (CONCAT(@UserId, '_10000'), 'Extent', 20, 0, '180')
		, (CONCAT(@UserId, '_10000'), 'Finishing', 70, 0, 'Perfect bind with cover drawn on, glued with 6mm hinge, trim flush')
		, (CONCAT(@UserId, '_10000'), 'Origination', 30, 0, 'Complete print ready single page PDFs to be supplied')
		, (CONCAT(@UserId, '_10000'), 'Packing', 80, 0, 'Carton in suitable quantities not to exceed 12kg per carton')
		, (CONCAT(@UserId, '_10000'), 'Paper', 60, 0, 'Cover: 350gsm FSC Silk Coated Board
		Text: 100gsm FSC Smooth Uncoated')
		, (CONCAT(@UserId, '_10000'), 'Printing', 50, 0, 'Cover: Full colour digital printed outer only
		Text: Black only throughout')
		, (CONCAT(@UserId, '_10000'), 'Proofs', 40, 0, 'PDF proofs to be emailed for approval prior to production')
		, (CONCAT(@UserId, '_10000'), 'Size', 10, 0, '210 x 148mm A5 Portrait')
		, (CONCAT(@UserId, '_10007'), 'Finishing', 90, 0, 'Fold, saddlestitch 2 wires and trim flush')
		, (CONCAT(@UserId, '_10007'), 'Note', 150, 0, 'Ensure masthead matches previous issue')
		, (CONCAT(@UserId, '_10007'), 'Origination', 40, 0, 'Complete print ready single page PDFs to be supplied')
		, (CONCAT(@UserId, '_10007'), 'Packing', 100, 0, 'Carton pack in suitable quantities not to exceed 12kg')
		, (CONCAT(@UserId, '_10007'), 'Pagination', 20, 0, '16 pages self cover')
		, (CONCAT(@UserId, '_10007'), 'Paper', 80, 0, '130gsm FSC Silk Coated')
		, (CONCAT(@UserId, '_10007'), 'Printing', 60, 0, '4 colour process throughout')
		, (CONCAT(@UserId, '_10007'), 'Proofing', 50, 0, 'PDF proofs to be emailed for approval')
		, (CONCAT(@UserId, '_10007'), 'Trim Size', 30, 0, '297 x 210mm A4 Portrait')
		, (CONCAT(@UserId, '_10008'), 'Finishing', 90, 0, 'Fold, saddlestitch 2 wires and trim flush')
		, (CONCAT(@UserId, '_10008'), 'Note', 150, 0, 'Ensure masthead matches previous issue')
		, (CONCAT(@UserId, '_10008'), 'Origination', 40, 0, 'Complete print ready single page PDFs to be supplied')
		, (CONCAT(@UserId, '_10008'), 'Packing', 100, 0, 'Carton pack in suitable quantities not to exceed 12kg')
		, (CONCAT(@UserId, '_10008'), 'Pagination', 20, 0, '16 pages self cover')
		, (CONCAT(@UserId, '_10008'), 'Paper', 80, 0, '130gsm FSC Silk Coated')
		, (CONCAT(@UserId, '_10008'), 'Printing', 60, 0, '4 colour process throughout')
		, (CONCAT(@UserId, '_10008'), 'Proofing', 50, 0, 'PDF proofs to be emailed for approval')
		, (CONCAT(@UserId, '_10008'), 'Trim Size', 30, 0, '297 x 210mm A4 Portrait')
		, (CONCAT(@UserId, '_10009'), 'Finishing', 90, 0, 'Fold, saddlestitch 2 wires and trim flush')
		, (CONCAT(@UserId, '_10009'), 'Note', 150, 0, 'Ensure masthead matches previous issue')
		, (CONCAT(@UserId, '_10009'), 'Origination', 40, 0, 'Complete print ready single page PDFs to be supplied')
		, (CONCAT(@UserId, '_10009'), 'Packing', 100, 0, 'Carton pack in suitable quantities not to exceed 12kg')
		, (CONCAT(@UserId, '_10009'), 'Pagination', 20, 0, '16 pages self cover')
		, (CONCAT(@UserId, '_10009'), 'Paper', 80, 0, '130gsm FSC Silk Coated')
		, (CONCAT(@UserId, '_10009'), 'Printing', 60, 0, '4 colour process throughout')
		, (CONCAT(@UserId, '_10009'), 'Proofing', 50, 0, 'PDF proofs to be emailed for approval')
		, (CONCAT(@UserId, '_10009'), 'Trim Size', 30, 0, '297 x 210mm A4 Portrait')
		, (CONCAT(@UserId, '_10010'), 'Finishing', 90, 0, 'Fold, saddlestitch 2 wires and trim flush')
		, (CONCAT(@UserId, '_10010'), 'Note', 150, 0, 'Ensure masthead matches previous issue')
		, (CONCAT(@UserId, '_10010'), 'Origination', 40, 0, 'Complete print ready single page PDFs to be supplied')
		, (CONCAT(@UserId, '_10010'), 'Packing', 100, 0, 'Carton pack in suitable quantities not to exceed 12kg')
		, (CONCAT(@UserId, '_10010'), 'Pagination', 20, 0, '16 pages self cover')
		, (CONCAT(@UserId, '_10010'), 'Paper', 80, 0, '130gsm FSC Silk Coated')
		, (CONCAT(@UserId, '_10010'), 'Printing', 60, 0, '4 colour process throughout')
		, (CONCAT(@UserId, '_10010'), 'Proofing', 50, 0, 'PDF proofs to be emailed for approval')
		, (CONCAT(@UserId, '_10010'), 'Trim Size', 30, 0, '297 x 210mm A4 Portrait')
		, (CONCAT(@UserId, '_10011'), 'Finishing', 90, 0, 'Fold, saddlestitch 2 wires and trim flush')
		, (CONCAT(@UserId, '_10011'), 'Note', 150, 0, 'Ensure masthead matches previous issue')
		, (CONCAT(@UserId, '_10011'), 'Origination', 40, 0, 'Complete print ready single page PDFs to be supplied')
		, (CONCAT(@UserId, '_10011'), 'Packing', 100, 0, 'Carton pack in suitable quantities not to exceed 12kg')
		, (CONCAT(@UserId, '_10011'), 'Pagination', 20, 0, '16 pages self cover')
		, (CONCAT(@UserId, '_10011'), 'Paper', 80, 0, '130gsm FSC Silk Coated')
		, (CONCAT(@UserId, '_10011'), 'Printing', 60, 0, '4 colour process throughout')
		, (CONCAT(@UserId, '_10011'), 'Proofing', 50, 0, 'PDF proofs to be emailed for approval')
		, (CONCAT(@UserId, '_10011'), 'Trim Size', 30, 0, '297 x 210mm A4 Portrait')
		, (CONCAT(@UserId, '_10012'), 'Finishing', 90, 0, 'Fold, saddlestitch 2 wires and trim flush')
		, (CONCAT(@UserId, '_10012'), 'Note', 150, 0, 'Ensure masthead matches previous issue')
		, (CONCAT(@UserId, '_10012'), 'Origination', 40, 0, 'Complete print ready single page PDFs to be supplied')
		, (CONCAT(@UserId, '_10012'), 'Packing', 100, 0, 'Carton pack in suitable quantities not to exceed 12kg')
		, (CONCAT(@UserId, '_10012'), 'Pagination', 20, 0, '16 pages self cover')
		, (CONCAT(@UserId, '_10012'), 'Paper', 80, 0, '130gsm FSC Silk Coated')
		, (CONCAT(@UserId, '_10012'), 'Printing', 60, 0, '4 colour process throughout')
		, (CONCAT(@UserId, '_10012'), 'Proofing', 50, 0, 'PDF proofs to be emailed for approval')
		, (CONCAT(@UserId, '_10012'), 'Trim Size', 30, 0, '297 x 210mm A4 Portrait')
		, (CONCAT(@UserId, '_10013'), 'Finishing', 90, 0, 'Fold, saddlestitch 2 wires and trim flush')
		, (CONCAT(@UserId, '_10013'), 'Note', 150, 0, 'Ensure masthead matches previous issue')
		, (CONCAT(@UserId, '_10013'), 'Origination', 40, 0, 'Complete print ready single page PDFs to be supplied')
		, (CONCAT(@UserId, '_10013'), 'Packing', 100, 0, 'Carton pack in suitable quantities not to exceed 12kg')
		, (CONCAT(@UserId, '_10013'), 'Pagination', 20, 0, '16 pages self cover')
		, (CONCAT(@UserId, '_10013'), 'Paper', 80, 0, '130gsm FSC Silk Coated')
		, (CONCAT(@UserId, '_10013'), 'Printing', 60, 0, '4 colour process throughout')
		, (CONCAT(@UserId, '_10013'), 'Proofing', 50, 0, 'PDF proofs to be emailed for approval')
		, (CONCAT(@UserId, '_10013'), 'Trim Size', 30, 0, '297 x 210mm A4 Portrait')
		, (CONCAT(@UserId, '_10014'), 'Finishing', 90, 0, 'Fold, saddlestitch 2 wires and trim flush')
		, (CONCAT(@UserId, '_10014'), 'Note', 150, 0, 'Ensure masthead matches previous issue')
		, (CONCAT(@UserId, '_10014'), 'Origination', 40, 0, 'Complete print ready single page PDFs to be supplied')
		, (CONCAT(@UserId, '_10014'), 'Packing', 100, 0, 'Carton pack in suitable quantities not to exceed 12kg')
		, (CONCAT(@UserId, '_10014'), 'Pagination', 20, 0, '16 pages self cover')
		, (CONCAT(@UserId, '_10014'), 'Paper', 80, 0, '130gsm FSC Silk Coated')
		, (CONCAT(@UserId, '_10014'), 'Printing', 60, 0, '4 colour process throughout')
		, (CONCAT(@UserId, '_10014'), 'Proofing', 50, 0, 'PDF proofs to be emailed for approval')
		, (CONCAT(@UserId, '_10014'), 'Trim Size', 30, 0, '297 x 210mm A4 Portrait')
		, (CONCAT(@UserId, '_10015'), 'Description', 10, 0, 'Outer carton 0201 Glued')
		, (CONCAT(@UserId, '_10015'), 'Finishing', 90, 0, 'Die cut, glue and form as flat carton')
		, (CONCAT(@UserId, '_10015'), 'Material', 80, 0, 'B150K150T corrugated single walled')
		, (CONCAT(@UserId, '_10015'), 'Packing', 100, 0, 'Bundle in 10s, palletise in 250s')
		, (CONCAT(@UserId, '_10015'), 'Printing', 60, 0, 'Plain unprinted cartons')
		, (CONCAT(@UserId, '_10015'), 'Tolerance', 110, 0, '+/-10% tolerance applies, quantity delivered will be invoiced at the agreed unit rate')
		, (CONCAT(@UserId, '_10015'), 'Trim Size', 30, 0, 'Internal dimensions: Height 140 x Width 170 x Length 200mm')
		, (CONCAT(@UserId, '_10017'), 'Finishing', 70, 0, 'Seed prize sheets into bulk master sheets, trim to size and pack into cartons in 1,000s.')
		, (CONCAT(@UserId, '_10017'), 'Labelling', 80, 0, 'Apply timestamped label to short end of each carton')
		, (CONCAT(@UserId, '_10017'), 'Latexing', 50, 0, 'Screen print silver latex in 9 positions, common to all variants')
		, (CONCAT(@UserId, '_10017'), 'Litho Printing', 40, 0, 'Print four colour process to face with slip plate for black text changes to create 40 variants (split as spreadsheet supplied). Reverse print black line only. Apply inline slip varnish to face only.')
		, (CONCAT(@UserId, '_10017'), 'Origination', 20, 0, 'PDFs supplied for 40 variants')
		, (CONCAT(@UserId, '_10017'), 'Paper', 60, 0, '280gsm 1-sided gloss coated card as sampled')
		, (CONCAT(@UserId, '_10017'), 'Proofing', 30, 0, 'Proof master sheet with single PDFs of other 39 variants')
		, (CONCAT(@UserId, '_10017'), 'Trim Size', 10, 0, '100 x 75mm')
		, (CONCAT(@UserId, '_10018'), 'Cover Finish', 70, 0, 'Matt UV varnish')
		, (CONCAT(@UserId, '_10018'), 'Finishing', 90, 0, 'Fold text, threadsew in 16pp sections, case-in with printed paper case')
		, (CONCAT(@UserId, '_10018'), 'Material', 80, 0, 'Cover: 150gsm FSC Silk over 2000 micron smooth greyboard
		Text: 150gsm FSC Silk')
		, (CONCAT(@UserId, '_10018'), 'Origination', 40, 0, 'PDFs supplied as single pages to our specification')
		, (CONCAT(@UserId, '_10018'), 'Packing', 100, 0, 'Carton pack in suitable quantities not to exceed 12kg')
		, (CONCAT(@UserId, '_10018'), 'Pagination', 20, 0, '72pp text + 4pp cover')
		, (CONCAT(@UserId, '_10018'), 'Printing', 60, 0, 'Cover: 4 colour process to outer only
		Text: 4 colour process throughout')
		, (CONCAT(@UserId, '_10018'), 'Proofing', 50, 0, 'Ripped PDFs to be emailed for approval prior to printing')
		, (CONCAT(@UserId, '_10018'), 'Trim Size', 30, 0, '297 x 210mm A4 Portrait')
		, (CONCAT(@UserId, '_10019'), 'Cover Finish', 70, 0, 'Matt UV varnish')
		, (CONCAT(@UserId, '_10019'), 'Finishing', 90, 0, 'Fold text, threadsew in 16pp sections, case-in with printed paper case')
		, (CONCAT(@UserId, '_10019'), 'Material', 80, 0, 'Cover: 150gsm FSC Silk over 2000 micron smooth greyboard
		Text: 150gsm FSC Silk')
		, (CONCAT(@UserId, '_10019'), 'Origination', 40, 0, 'Straight reprint from July 19 order')
		, (CONCAT(@UserId, '_10019'), 'Packing', 100, 0, 'Carton pack in suitable quantities not to exceed 12kg')
		, (CONCAT(@UserId, '_10019'), 'Pagination', 20, 0, '72pp text + 4pp cover')
		, (CONCAT(@UserId, '_10019'), 'Printing', 60, 0, 'Cover: 4 colour process to outer only
		Text: 4 colour process throughout')
		, (CONCAT(@UserId, '_10019'), 'Proofing', 50, 0, 'None required')
		, (CONCAT(@UserId, '_10019'), 'Trim Size', 30, 0, '297 x 210mm A4 Portrait')
		, (CONCAT(@UserId, '_20000'), 'Extent', 20, 0, '180')
		, (CONCAT(@UserId, '_20000'), 'File Copies', 90, 0, 'One file copy to be sent to us by First Class post on despatch of main order')
		, (CONCAT(@UserId, '_20000'), 'Finishing', 70, 0, 'Perfect bind with cover drawn on, glued with 6mm hinge, trim flush')
		, (CONCAT(@UserId, '_20000'), 'Origination', 30, 0, 'Complete print ready single page PDFs to be supplied')
		, (CONCAT(@UserId, '_20000'), 'Packing', 80, 0, 'Carton in suitable quantities not to exceed 12kg per carton')
		, (CONCAT(@UserId, '_20000'), 'Paper', 60, 0, 'Cover: 350gsm FSC Silk Coated Board
		Text: 100gsm FSC Smooth Uncoated')
		, (CONCAT(@UserId, '_20000'), 'Printing', 50, 0, 'Cover: Full colour digital printed outer only
		Text: Black only throughout')
		, (CONCAT(@UserId, '_20000'), 'Proofs', 40, 0, 'PDF proofs to be emailed for approval prior to production')
		, (CONCAT(@UserId, '_20000'), 'Size', 10, 0, '210 x 148mm A5 Portrait')
		, (CONCAT(@UserId, '_20010'), 'File Copies', 160, 0, 'Post 3 file copies by First Class post on completion of order')
		, (CONCAT(@UserId, '_20010'), 'Finishing', 90, 0, 'Fold, saddlestitch 2 wires and trim flush')
		, (CONCAT(@UserId, '_20010'), 'Note', 150, 0, 'Ensure masthead matches previous issue')
		, (CONCAT(@UserId, '_20010'), 'Origination', 40, 0, 'Complete print ready single page PDFs to be supplied')
		, (CONCAT(@UserId, '_20010'), 'Packing', 100, 0, 'Carton pack in suitable quantities not to exceed 12kg')
		, (CONCAT(@UserId, '_20010'), 'Pagination', 20, 0, '16 pages self cover')
		, (CONCAT(@UserId, '_20010'), 'Paper', 80, 0, '130gsm FSC Silk Coated')
		, (CONCAT(@UserId, '_20010'), 'Printing', 60, 0, '4 colour process throughout')
		, (CONCAT(@UserId, '_20010'), 'Proofing', 50, 0, 'PDF proofs to be emailed for approval')
		, (CONCAT(@UserId, '_20010'), 'Trim Size', 30, 0, '297 x 210mm A4 Portrait')
		, (CONCAT(@UserId, '_20011'), 'Description', 10, 0, '2 pallets x 350kg per pallet, overnight delivery')
		, (CONCAT(@UserId, '_20013'), 'File Copies', 160, 0, 'Post 3 file copies by First Class post on completion of order')
		, (CONCAT(@UserId, '_20013'), 'Finishing', 90, 0, 'Fold, saddlestitch 2 wires and trim flush')
		, (CONCAT(@UserId, '_20013'), 'Note', 150, 0, 'Ensure masthead matches previous issue')
		, (CONCAT(@UserId, '_20013'), 'Origination', 40, 0, 'Complete print ready single page PDFs to be supplied')
		, (CONCAT(@UserId, '_20013'), 'Packing', 100, 0, 'Carton pack in suitable quantities not to exceed 12kg')
		, (CONCAT(@UserId, '_20013'), 'Pagination', 20, 0, '16 pages self cover')
		, (CONCAT(@UserId, '_20013'), 'Paper', 80, 0, '130gsm FSC Silk Coated')
		, (CONCAT(@UserId, '_20013'), 'Printing', 60, 0, '4 colour process throughout')
		, (CONCAT(@UserId, '_20013'), 'Proofing', 50, 0, 'PDF proofs to be emailed for approval')
		, (CONCAT(@UserId, '_20013'), 'Trim Size', 30, 0, '297 x 210mm A4 Portrait')
		, (CONCAT(@UserId, '_20014'), 'Description', 10, 0, '2 pallets x 350kg per pallet, overnight delivery')
		, (CONCAT(@UserId, '_20015'), 'File Copies', 160, 0, 'Post 3 file copies by First Class post on completion of order')
		, (CONCAT(@UserId, '_20015'), 'Finishing', 90, 0, 'Fold, saddlestitch 2 wires and trim flush')
		, (CONCAT(@UserId, '_20015'), 'Note', 150, 0, 'Ensure masthead matches previous issue')
		, (CONCAT(@UserId, '_20015'), 'Origination', 40, 0, 'Complete print ready single page PDFs to be supplied')
		, (CONCAT(@UserId, '_20015'), 'Packing', 100, 0, 'Carton pack in suitable quantities not to exceed 12kg')
		, (CONCAT(@UserId, '_20015'), 'Pagination', 20, 0, '16 pages self cover')
		, (CONCAT(@UserId, '_20015'), 'Paper', 80, 0, '130gsm FSC Silk Coated')
		, (CONCAT(@UserId, '_20015'), 'Printing', 60, 0, '4 colour process throughout')
		, (CONCAT(@UserId, '_20015'), 'Proofing', 50, 0, 'PDF proofs to be emailed for approval')
		, (CONCAT(@UserId, '_20015'), 'Trim Size', 30, 0, '297 x 210mm A4 Portrait')
		, (CONCAT(@UserId, '_20016'), 'Description', 10, 0, '2 pallets x 350kg per pallet, overnight delivery')
		, (CONCAT(@UserId, '_20017'), 'File Copies', 160, 0, 'Post 3 file copies by First Class post on completion of order')
		, (CONCAT(@UserId, '_20017'), 'Finishing', 90, 0, 'Fold, saddlestitch 2 wires and trim flush')
		, (CONCAT(@UserId, '_20017'), 'Note', 150, 0, 'Ensure masthead matches previous issue')
		, (CONCAT(@UserId, '_20017'), 'Origination', 40, 0, 'Complete print ready single page PDFs to be supplied')
		, (CONCAT(@UserId, '_20017'), 'Packing', 100, 0, 'Carton pack in suitable quantities not to exceed 12kg')
		, (CONCAT(@UserId, '_20017'), 'Pagination', 20, 0, '16 pages self cover')
		, (CONCAT(@UserId, '_20017'), 'Paper', 80, 0, '130gsm FSC Silk Coated')
		, (CONCAT(@UserId, '_20017'), 'Printing', 60, 0, '4 colour process throughout')
		, (CONCAT(@UserId, '_20017'), 'Proofing', 50, 0, 'PDF proofs to be emailed for approval')
		, (CONCAT(@UserId, '_20017'), 'Trim Size', 30, 0, '297 x 210mm A4 Portrait')
		, (CONCAT(@UserId, '_20018'), 'Description', 10, 0, '2 pallets x 350kg per pallet, overnight delivery')
		, (CONCAT(@UserId, '_20019'), 'File Copies', 160, 0, 'Post 3 file copies by First Class post on completion of order')
		, (CONCAT(@UserId, '_20019'), 'Finishing', 90, 0, 'Fold, saddlestitch 2 wires and trim flush')
		, (CONCAT(@UserId, '_20019'), 'Note', 150, 0, 'Ensure masthead matches previous issue')
		, (CONCAT(@UserId, '_20019'), 'Origination', 40, 0, 'Complete print ready single page PDFs to be supplied')
		, (CONCAT(@UserId, '_20019'), 'Packing', 100, 0, 'Carton pack in suitable quantities not to exceed 12kg')
		, (CONCAT(@UserId, '_20019'), 'Pagination', 20, 0, '16 pages self cover')
		, (CONCAT(@UserId, '_20019'), 'Paper', 80, 0, '130gsm FSC Silk Coated')
		, (CONCAT(@UserId, '_20019'), 'Printing', 60, 0, '4 colour process throughout')
		, (CONCAT(@UserId, '_20019'), 'Proofing', 50, 0, 'PDF proofs to be emailed for approval')
		, (CONCAT(@UserId, '_20019'), 'Trim Size', 30, 0, '297 x 210mm A4 Portrait')
		, (CONCAT(@UserId, '_20020'), 'Description', 10, 0, '2 pallets x 350kg per pallet, overnight delivery')
		, (CONCAT(@UserId, '_20021'), 'File Copies', 160, 0, 'Post 3 file copies by First Class post on completion of order')
		, (CONCAT(@UserId, '_20021'), 'Finishing', 90, 0, 'Fold, saddlestitch 2 wires and trim flush')
		, (CONCAT(@UserId, '_20021'), 'Note', 150, 0, 'Ensure masthead matches previous issue')
		, (CONCAT(@UserId, '_20021'), 'Origination', 40, 0, 'Complete print ready single page PDFs to be supplied')
		, (CONCAT(@UserId, '_20021'), 'Packing', 100, 0, 'Carton pack in suitable quantities not to exceed 12kg')
		, (CONCAT(@UserId, '_20021'), 'Pagination', 20, 0, '16 pages self cover')
		, (CONCAT(@UserId, '_20021'), 'Paper', 80, 0, '130gsm FSC Silk Coated')
		, (CONCAT(@UserId, '_20021'), 'Printing', 60, 0, '4 colour process throughout')
		, (CONCAT(@UserId, '_20021'), 'Proofing', 50, 0, 'PDF proofs to be emailed for approval')
		, (CONCAT(@UserId, '_20021'), 'Trim Size', 30, 0, '297 x 210mm A4 Portrait')
		, (CONCAT(@UserId, '_20022'), 'Description', 10, 0, '2 pallets x 350kg per pallet, overnight delivery')
		, (CONCAT(@UserId, '_20025'), 'File Copies', 160, 0, 'Post 3 file copies by First Class post on completion of order')
		, (CONCAT(@UserId, '_20025'), 'Finishing', 90, 0, 'Fold, saddlestitch 2 wires and trim flush')
		, (CONCAT(@UserId, '_20025'), 'Note', 150, 0, 'Ensure masthead matches previous issue')
		, (CONCAT(@UserId, '_20025'), 'Origination', 40, 0, 'Complete print ready single page PDFs to be supplied')
		, (CONCAT(@UserId, '_20025'), 'Packing', 100, 0, 'Carton pack in suitable quantities not to exceed 12kg')
		, (CONCAT(@UserId, '_20025'), 'Pagination', 20, 0, '16 pages self cover')
		, (CONCAT(@UserId, '_20025'), 'Paper', 80, 0, '130gsm FSC Silk Coated')
		, (CONCAT(@UserId, '_20025'), 'Printing', 60, 0, '4 colour process throughout')
		, (CONCAT(@UserId, '_20025'), 'Proofing', 50, 0, 'PDF proofs to be emailed for approval')
		, (CONCAT(@UserId, '_20025'), 'Trim Size', 30, 0, '297 x 210mm A4 Portrait')
		, (CONCAT(@UserId, '_20026'), 'Description', 10, 0, '2 pallets x 350kg per pallet, overnight delivery')
		, (CONCAT(@UserId, '_20027'), 'File Copies', 160, 0, 'Post 3 file copies by First Class post on completion of order')
		, (CONCAT(@UserId, '_20027'), 'Finishing', 90, 0, 'Fold, saddlestitch 2 wires and trim flush')
		, (CONCAT(@UserId, '_20027'), 'Note', 150, 0, 'Ensure masthead matches previous issue')
		, (CONCAT(@UserId, '_20027'), 'Origination', 40, 0, 'Complete print ready single page PDFs to be supplied')
		, (CONCAT(@UserId, '_20027'), 'Packing', 100, 0, 'Carton pack in suitable quantities not to exceed 12kg')
		, (CONCAT(@UserId, '_20027'), 'Pagination', 20, 0, '16 pages self cover')
		, (CONCAT(@UserId, '_20027'), 'Paper', 80, 0, '130gsm FSC Silk Coated')
		, (CONCAT(@UserId, '_20027'), 'Printing', 60, 0, '4 colour process throughout')
		, (CONCAT(@UserId, '_20027'), 'Proofing', 50, 0, 'PDF proofs to be emailed for approval')
		, (CONCAT(@UserId, '_20027'), 'Trim Size', 30, 0, '297 x 210mm A4 Portrait')
		, (CONCAT(@UserId, '_20028'), 'Description', 10, 0, '2 pallets x 350kg per pallet, overnight delivery')
		, (CONCAT(@UserId, '_20029'), 'Description', 10, 0, 'Outer carton 0201 Glued')
		, (CONCAT(@UserId, '_20029'), 'Finishing', 90, 0, 'Die cut, glue and form as flat carton')
		, (CONCAT(@UserId, '_20029'), 'Material', 80, 0, 'B150K150T corrugated single walled')
		, (CONCAT(@UserId, '_20029'), 'Packing', 100, 0, 'Bundle in 10s, palletise in 250s')
		, (CONCAT(@UserId, '_20029'), 'Printing', 60, 0, 'Plain unprinted cartons')
		, (CONCAT(@UserId, '_20029'), 'Tolerance', 110, 0, '+/-10% tolerance applies, quantity delivered will be invoiced at the agreed unit rate')
		, (CONCAT(@UserId, '_20029'), 'Trim Size', 30, 0, 'Internal dimensions: Height 140 x Width 170 x Length 200mm')
		, (CONCAT(@UserId, '_20031'), 'Delivery Note', 90, 0, 'Please ensure that you use our delivery note supplied')
		, (CONCAT(@UserId, '_20031'), 'File Copies', 100, 0, '2 complete Voided sets of cards x 40 variants to be sent to us on completion of order')
		, (CONCAT(@UserId, '_20031'), 'Finishing', 70, 0, 'Seed prize sheets into bulk master sheets, trim to size and pack into cartons in 1,000s.')
		, (CONCAT(@UserId, '_20031'), 'Labelling', 80, 0, 'Apply timestamped label to short end of each carton')
		, (CONCAT(@UserId, '_20031'), 'Latexing', 50, 0, 'Screen print silver latex in 9 positions, common to all variants')
		, (CONCAT(@UserId, '_20031'), 'Litho Printing', 40, 0, 'Print four colour process to face with slip plate for black text changes to create 40 variants (split as spreadsheet supplied). Reverse print black line only. Apply inline slip varnish to face only.')
		, (CONCAT(@UserId, '_20031'), 'Origination', 20, 0, 'PDFs supplied for 40 variants')
		, (CONCAT(@UserId, '_20031'), 'Paper', 60, 0, '280gsm 1-sided gloss coated card supplied - 13 tonnes in sheet size 640 x 900mm')
		, (CONCAT(@UserId, '_20031'), 'Proofing', 30, 0, 'Proof master sheet with single PDFs of other 39 variants')
		, (CONCAT(@UserId, '_20031'), 'Trim Size', 10, 0, '100 x 75mm')
		, (CONCAT(@UserId, '_20032'), 'Paper', 60, 0, '280gsm 1-sided Special gloss coated card - 13 tonnes in sheet size 640 x 900mm (80,600 ssheets)')
		, (CONCAT(@UserId, '_20034'), 'Cover Finish', 70, 0, 'Matt UV varnish')
		, (CONCAT(@UserId, '_20034'), 'File Copies', 200, 0, '2 file copies to be posted to us on completion of order')
		, (CONCAT(@UserId, '_20034'), 'Finishing', 90, 0, 'Fold text, threadsew in 16pp sections, case-in with printed paper case')
		, (CONCAT(@UserId, '_20034'), 'Material', 80, 0, 'Cover: 150gsm FSC Silk over 2000 micron smooth greyboard
		Text: 150gsm FSC Silk')
		, (CONCAT(@UserId, '_20034'), 'Origination', 40, 0, 'PDFs supplied as single pages to our specification')
		, (CONCAT(@UserId, '_20034'), 'Packing', 100, 0, 'Carton pack in suitable quantities not to exceed 12kg')
		, (CONCAT(@UserId, '_20034'), 'Pagination', 20, 0, '72pp text + 4pp cover')
		, (CONCAT(@UserId, '_20034'), 'Printing', 60, 0, 'Cover: 4 colour process to outer only
		Text: 4 colour process throughout')
		, (CONCAT(@UserId, '_20034'), 'Proofing', 50, 0, 'Ripped PDFs to be emailed for approval prior to printing')
		, (CONCAT(@UserId, '_20034'), 'Trim Size', 30, 0, '297 x 210mm A4 Portrait')
		, (CONCAT(@UserId, '_20035'), 'Collection', 20, 0, 'Between 10am - 4pm')
		, (CONCAT(@UserId, '_20035'), 'Description', 10, 0, '1 overnight pallet')
		, (CONCAT(@UserId, '_20035'), 'Note', 30, 1, 'Please call warehouse on 0785 456756 on arrival to enable access')
		, (CONCAT(@UserId, '_20037'), 'Cover Finish', 70, 0, 'Matt UV varnish')
		, (CONCAT(@UserId, '_20037'), 'File Copies', 200, 0, '2 file copies to be posted to us on completion of order')
		, (CONCAT(@UserId, '_20037'), 'Finishing', 90, 0, 'Fold text, threadsew in 16pp sections, case-in with printed paper case')
		, (CONCAT(@UserId, '_20037'), 'Material', 80, 0, 'Cover: 150gsm FSC Silk over 2000 micron smooth greyboard
		Text: 150gsm FSC Silk')
		, (CONCAT(@UserId, '_20037'), 'Origination', 40, 0, 'Straight reprint from July 19 order')
		, (CONCAT(@UserId, '_20037'), 'Packing', 100, 0, 'Carton pack in suitable quantities not to exceed 12kg')
		, (CONCAT(@UserId, '_20037'), 'Pagination', 20, 0, '72pp text + 4pp cover')
		, (CONCAT(@UserId, '_20037'), 'Printing', 60, 0, 'Cover: 4 colour process to outer only
		Text: 4 colour process throughout')
		, (CONCAT(@UserId, '_20037'), 'Proofing', 50, 0, 'None required')
		, (CONCAT(@UserId, '_20037'), 'Trim Size', 30, 0, '297 x 210mm A4 Portrait')
		, (CONCAT(@UserId, '_20038'), 'Collection', 20, 0, 'Between 10am - 4pm')
		, (CONCAT(@UserId, '_20038'), 'Description', 10, 0, '8 pallets')
		, (CONCAT(@UserId, '_20038'), 'Note', 30, 1, 'Please call warehouse on 0785 456756 on arrival to enable access')
		, (CONCAT(@UserId, '_40005'), 'Description', 10, 0, 'Monthly wages')
		, (CONCAT(@UserId, '_40006'), 'Description', 10, 0, 'Monthly wages')
		, (CONCAT(@UserId, '_40007'), 'Description', 10, 0, 'Monthly wages')
		, (CONCAT(@UserId, '_40008'), 'Description', 10, 0, 'Monthly wages')
		, (CONCAT(@UserId, '_40009'), 'Description', 10, 0, 'Monthly wages')
		, (CONCAT(@UserId, '_40010'), 'Description', 10, 0, 'Monthly wages')
		, (CONCAT(@UserId, '_40011'), 'Description', 10, 0, 'Monthly wages')
		, (CONCAT(@UserId, '_40012'), 'Description', 10, 0, 'Monthly wages')
		, (CONCAT(@UserId, '_40013'), 'Description', 10, 0, 'Monthly wages')
		, (CONCAT(@UserId, '_40014'), 'Description', 10, 0, 'Monthly wages')
		, (CONCAT(@UserId, '_40015'), 'Description', 10, 0, 'Monthly wages')
		, (CONCAT(@UserId, '_40016'), 'Description', 10, 0, 'Monthly wages')
		;

		UPDATE App.tbRegister SET NextNumber = 40047 WHERE RegisterName = 'Expenses';
		UPDATE App.tbRegister SET NextNumber = 30003 WHERE RegisterName = 'Project';
		UPDATE App.tbRegister SET NextNumber = 20039 WHERE RegisterName = 'Purchase Order';
		UPDATE App.tbRegister SET NextNumber = 10020 WHERE RegisterName = 'Sales Order';

		DECLARE @OffsetMonth INT = (SELECT DATEDIFF(MONTH, '20190801', CURRENT_TIMESTAMP));

		UPDATE Task.tbTask SET ActionOn = App.fnAdjustToCalendar(DATEADD(MONTH, @OffsetMonth, ActionOn), 0);
		UPDATE Task.tbTask SET ActionedOn = ActionOn;

		DECLARE @TaskCode NVARCHAR(10);
		DECLARE live_tasks CURSOR FOR
			SELECT  Task.tbTask.TaskCode
			FROM Task.tbTask INNER JOIN
				Cash.tbCode ON Task.tbTask.CashCode = Cash.tbCode.CashCode INNER JOIN
				Cash.tbCategory ON Cash.tbCode.CategoryCode = Cash.tbCategory.CategoryCode
			WHERE        (Cash.tbCategory.CashModeCode = 1) AND (Task.tbTask.TaskStatusCode = 1);

		OPEN live_tasks;
		FETCH NEXT FROM live_tasks INTO @TaskCode;
		WHILE @@FETCH_STATUS = 0
		BEGIN
			EXEC Task.proc_Schedule @ParentTaskCode=@TaskCode;
			FETCH NEXT FROM live_tasks INTO @TaskCode;
		END

		CLOSE live_tasks;
		DEALLOCATE live_tasks;

		IF (@InvoiceOrders = 0)
			GOTO CommitTran;

		INSERT INTO Invoice.tbInvoice (InvoiceNumber, UserId, AccountCode, InvoiceTypeCode, InvoiceStatusCode, InvoicedOn, ExpectedOn, DueOn, InvoiceValue, TaxValue, PaidValue, PaidTaxValue, PaymentTerms, Notes, Printed, Spooled)
		VALUES (CONCAT('010000.', @UserId), @UserId, 'CDCUST', 0, 1, '20190126', '20190228', '20190228', 1000.0000, 200.0000, 1000.0000, 200.0000, '30 days end of month following date of invoice', null, 0, 0)
		, (CONCAT('010001.', @UserId), @UserId, 'CDCUST', 0, 1, '20190225', '20190329', '20190329', 1000.0000, 200.0000, 1000.0000, 200.0000, '30 days end of month following date of invoice', null, 0, 0)
		, (CONCAT('010002.', @UserId), @UserId, 'CDCUST', 0, 1, '20190328', '20190430', '20190430', 1000.0000, 200.0000, 1000.0000, 200.0000, '30 days end of month following date of invoice', null, 0, 0)
		, (CONCAT('010003.', @UserId), @UserId, 'CDCUST', 0, 1, '20190428', '20190531', '20190531', 1000.0000, 200.0000, 1000.0000, 200.0000, '30 days end of month following date of invoice', null, 0, 0)
		, (CONCAT('010004.', @UserId), @UserId, 'CDCUST', 0, 1, '20190525', '20190628', '20190628', 1000.0000, 200.0000, 1000.0000, 200.0000, '30 days end of month following date of invoice', null, 0, 0)
		, (CONCAT('010005.', @UserId), @UserId, 'HOME', 0, 1, '20190101', '20190101', '20190101', 10000.0000, 0.0000, 10000.0000, 0.0000, null, null, 0, 0)
		, (CONCAT('010006.', @UserId), @UserId, 'EFCUST', 0, 1, '20190330', '20190514', '20190429', 18500.0000, 3700.0000, 18500.0000, 3700.0000, '30 days from date of invoice', null, 0, 0)
		, (CONCAT('010007.', @UserId), @UserId, 'HOME', 0, 1, '20190101', '20190101', '20190101', 15000.0000, 0.0000, 15000.0000, 0.0000, null, null, 0, 0)
		, (CONCAT('010008.', @UserId), @UserId, 'HOME', 0, 1, '20190415', '20190415', '20190415', 5000.0000, 0.0000, 5000.0000, 0.0000, null, null, 0, 0)
		, (CONCAT('010009.', @UserId), @UserId, 'HOME', 0, 1, '20190601', '20190531', '20190531', 5000.0000, 0.0000, 5000.0000, 0.0000, null, null, 0, 0)
		, (CONCAT('010010.', @UserId), @UserId, 'HOME', 0, 1, '20190731', '20190731', '20190731', 1000.0000, 0.0000, 1000.0000, 0.0000, null, null, 0, 0)
		, (CONCAT('010011.', @UserId), @UserId, 'CDCUST', 0, 1, '20190822', '20190930', '20190930', 1000.0000, 200.0000, 1000.0000, 200.0000, '30 days end of month following date of invoice', null, 0, 0)
		, (CONCAT('030000.', @UserId), @UserId, 'SUPTWO', 2, 1, '20190125', '20190228', '20190228', 650.0000, 0.0000, 650.0000, 0.0000, '30 days end of month following date of invoice', 'Invoice 122112', 0, 0)
		, (CONCAT('030001.', @UserId), @UserId, 'TRACOM', 2, 1, '20190126', '20190228', '20190228', 150.0000, 30.0000, 150.0000, 30.0000, '30 days end of month following date of invoice', 'Invoice INV122222', 0, 0)
		, (CONCAT('030002.', @UserId), @UserId, 'SUPTWO', 2, 1, '20190224', '20190329', '20190329', 650.0000, 0.0000, 650.0000, 0.0000, '30 days end of month following date of invoice', 'Invoice 122250', 0, 0)
		, (CONCAT('030003.', @UserId), @UserId, 'TRACOM', 2, 1, '20190225', '20190329', '20190329', 150.0000, 30.0000, 150.0000, 30.0000, '30 days end of month following date of invoice', 'Invoice INV123456', 0, 0)
		, (CONCAT('030004.', @UserId), @UserId, 'SUPTWO', 2, 1, '20190327', '20190430', '20190430', 650.0000, 0.0000, 650.0000, 0.0000, '30 days end of month following date of invoice', 'Invoice 122501', 0, 0)
		, (CONCAT('030005.', @UserId), @UserId, 'TRACOM', 2, 1, '20190328', '20190430', '20190430', 150.0000, 30.0000, 150.0000, 30.0000, '30 days end of month following date of invoice', 'Invoice INV124555', 0, 0)
		, (CONCAT('030006.', @UserId), @UserId, 'SUPTWO', 2, 1, '20190427', '20190531', '20190531', 650.0000, 0.0000, 650.0000, 0.0000, '30 days end of month following date of invoice', 'Invoice 123011', 0, 0)
		, (CONCAT('030007.', @UserId), @UserId, 'TRACOM', 2, 1, '20190428', '20190531', '20190531', 150.0000, 30.0000, 150.0000, 30.0000, '30 days end of month following date of invoice', 'Invoice INV124212', 0, 0)
		, (CONCAT('030008.', @UserId), @UserId, 'SUPTWO', 2, 1, '20190524', '20190628', '20190628', 650.0000, 0.0000, 650.0000, 0.0000, '30 days end of month following date of invoice', 'Invoice 124100', 0, 0)
		, (CONCAT('030009.', @UserId), @UserId, 'TRACOM', 2, 1, '20190525', '20190628', '20190628', 150.0000, 30.0000, 150.0000, 30.0000, '30 days end of month following date of invoice', 'Invoice INV190112', 0, 0)
		, (CONCAT('030010.', @UserId), @UserId, 'BUSOWN', 2, 1, '20190131', '20190131', '20190131', 83.9000, 0.8000, 83.9000, 0.8000, 'Expenses paid end of month', null, 0, 0)
		, (CONCAT('030011.', @UserId), @UserId, 'BUSOWN', 2, 1, '20190708', '20190731', '20190731', 1000.0000, 0.0000, 1000.0000, 0.0000, 'Expenses paid end of month', null, 0, 0)
		, (CONCAT('030012.', @UserId), @UserId, 'BUSOWN', 2, 1, '20190708', '20190731', '20190731', 1000.0000, 0.0000, 1000.0000, 0.0000, 'Expenses paid end of month', null, 0, 0)
		, (CONCAT('030013.', @UserId), @UserId, 'BUSOWN', 2, 1, '20190708', '20190731', '20190731', 1000.0000, 0.0000, 1000.0000, 0.0000, 'Expenses paid end of month', null, 0, 0)
		, (CONCAT('030014.', @UserId), @UserId, 'BUSOWN', 2, 1, '20190708', '20190731', '20190731', 1000.0000, 0.0000, 1000.0000, 0.0000, 'Expenses paid end of month', null, 0, 0)
		, (CONCAT('030015.', @UserId), @UserId, 'BUSOWN', 2, 1, '20190708', '20190731', '20190731', 1000.0000, 0.0000, 1000.0000, 0.0000, 'Expenses paid end of month', null, 0, 0)
		, (CONCAT('030016.', @UserId), @UserId, 'BUSOWN', 2, 1, '20190708', '20190731', '20190731', 1000.0000, 0.0000, 1000.0000, 0.0000, 'Expenses paid end of month', null, 0, 0)
		, (CONCAT('030017.', @UserId), @UserId, 'SUPTWO', 2, 1, '20190329', '20190430', '20190430', 6000.0000, 1200.0000, 6000.0000, 1200.0000, '30 days end of month following date of invoice', null, 0, 0)
		, (CONCAT('030018.', @UserId), @UserId, 'THEPAP', 2, 1, '20190416', '20190516', '20190416', 9750.0000, 1950.0000, 9750.0000, 1950.0000, '30 days from date of invoice', null, 0, 0)
		, (CONCAT('030019.', @UserId), @UserId, 'BUSOWN', 2, 1, '20190228', '20190228', '20190228', 118.4500, 0.0000, 118.4500, 0.0000, 'Expenses paid end of month', null, 0, 0)
		, (CONCAT('030020.', @UserId), @UserId, 'BUSOWN', 2, 1, '20190329', '20190329', '20190329', 105.1000, 0.0000, 105.1000, 0.0000, 'Expenses paid end of month', null, 0, 0)
		, (CONCAT('030021.', @UserId), @UserId, 'HOME', 2, 1, '20190415', '20190415', '20190415', 5000.0000, 0.0000, 5000.0000, 0.0000, null, null, 0, 0)
		, (CONCAT('030022.', @UserId), @UserId, 'BUSOWN', 2, 1, '20190430', '20190430', '20190430', 169.0000, 0.0000, 169.0000, 0.0000, 'Expenses paid end of month', null, 0, 0)
		, (CONCAT('030023.', @UserId), @UserId, 'BUSOWN', 2, 1, '20190531', '20190531', '20190531', 211.7500, 3.6000, 211.7500, 3.6000, 'Expenses paid end of month', null, 0, 0)
		, (CONCAT('030024.', @UserId), @UserId, 'BUSOWN', 2, 1, '20190628', '20190628', '20190628', 202.4000, 1.0000, 202.4000, 1.0000, 'Expenses paid end of month', null, 0, 0)
		, (CONCAT('030025.', @UserId), @UserId, 'HOME', 2, 1, '20190601', '20190531', '20190531', 5000.0000, 0.0000, 5000.0000, 0.0000, null, null, 0, 0)
		, (CONCAT('030026.', @UserId), @UserId, 'TELPRO', 2, 1, '20190719', '20190719', '20190719', 40.0000, 8.0000, 40.0000, 8.0000, 'Paid with order', null, 0, 0)
		, (CONCAT('030027.', @UserId), @UserId, 'TELPRO', 2, 1, '20190719', '20190719', '20190719', 39.6000, 7.9200, 39.6000, 7.9200, 'Paid with order', null, 0, 0)
		, (CONCAT('030028.', @UserId), @UserId, 'TELPRO', 2, 1, '20190719', '20190719', '20190719', 43.1200, 8.6200, 43.1200, 8.6200, 'Paid with order', null, 0, 0)
		, (CONCAT('030029.', @UserId), @UserId, 'TELPRO', 2, 1, '20190719', '20190719', '20190719', 43.5200, 8.7000, 43.5200, 8.7000, 'Paid with order', null, 0, 0)
		, (CONCAT('030030.', @UserId), @UserId, 'TELPRO', 2, 1, '20190719', '20190719', '20190719', 42.5200, 8.5000, 42.5200, 8.5000, 'Paid with order', null, 0, 0)
		, (CONCAT('030031.', @UserId), @UserId, 'TELPRO', 2, 1, '20190719', '20190719', '20190719', 41.1500, 8.2300, 41.1500, 8.2300, 'Paid with order', null, 0, 0)
		, (CONCAT('030033.', @UserId), @UserId, 'TELPRO', 2, 1, '20190822', '20190822', '20190822', 40.0000, 8.0000, 40.0000, 8.0000, 'Paid with order', null, 0, 0)
		, (CONCAT('030034.', @UserId), @UserId, 'HOME', 2, 1, '20190731', '20190731', '20190731', 1000.0000, 0.0000, 1000.0000, 0.0000, null, null, 0, 0)
		, (CONCAT('030035.', @UserId), @UserId, 'BUSOWN', 2, 1, '20190731', '20190731', '20190731', 1000.0000, 0.0000, 1000.0000, 0.0000, 'Expenses paid end of month', null, 0, 0)
		, (CONCAT('030036.', @UserId), @UserId, 'SUPTWO', 2, 1, '20190822', '20190930', '20190930', 650.0000, 0.0000, 650.0000, 0.0000, '30 days end of month following date of invoice', null, 0, 0)
		, (CONCAT('030037.', @UserId), @UserId, 'TRACOM', 2, 1, '20190822', '20190930', '20190930', 150.0000, 30.0000, 150.0000, 30.0000, '30 days end of month following date of invoice', null, 0, 0)
		, (CONCAT('030038.', @UserId), @UserId, 'SUNSUP', 2, 1, '20190722', '20190722', '20190722', 54.0000, 10.8000, 54.0000, 10.8000, 'Paid with order', null, 0, 0)
		;

		INSERT INTO Invoice.tbTask (InvoiceNumber, TaskCode, Quantity, TotalValue, InvoiceValue, TaxValue, PaidValue, PaidTaxValue, CashCode, TaxCode)
		VALUES (CONCAT('010000.', @UserId), CONCAT(@UserId, '_10007'), 5000, 0.0000, 1000.0000, 200.0000, 1000.0000, 200.0000, '103', 'T1')
		, (CONCAT('010001.', @UserId), CONCAT(@UserId, '_10008'), 5000, 0.0000, 1000.0000, 200.0000, 1000.0000, 200.0000, '103', 'T1')
		, (CONCAT('010002.', @UserId), CONCAT(@UserId, '_10009'), 5000, 0.0000, 1000.0000, 200.0000, 1000.0000, 200.0000, '103', 'T1')
		, (CONCAT('010003.', @UserId), CONCAT(@UserId, '_10010'), 5000, 0.0000, 1000.0000, 200.0000, 1000.0000, 200.0000, '103', 'T1')
		, (CONCAT('010004.', @UserId), CONCAT(@UserId, '_10011'), 5000, 0.0000, 1000.0000, 200.0000, 1000.0000, 200.0000, '103', 'T1')
		, (CONCAT('010006.', @UserId), CONCAT(@UserId, '_10017'), 5000000, 0.0000, 18500.0000, 3700.0000, 18500.0000, 3700.0000, '103', 'T1')
		, (CONCAT('010011.', @UserId), CONCAT(@UserId, '_10012'), 5000, 0.0000, 1000.0000, 200.0000, 1000.0000, 200.0000, '103', 'T1')
		, (CONCAT('030000.', @UserId), CONCAT(@UserId, '_20010'), 5000, 0.0000, 650.0000, 0.0000, 650.0000, 0.0000, '200', 'T0')
		, (CONCAT('030001.', @UserId), CONCAT(@UserId, '_20011'), 2, 0.0000, 150.0000, 30.0000, 150.0000, 30.0000, '200', 'T1')
		, (CONCAT('030002.', @UserId), CONCAT(@UserId, '_20013'), 5000, 0.0000, 650.0000, 0.0000, 650.0000, 0.0000, '200', 'T0')
		, (CONCAT('030003.', @UserId), CONCAT(@UserId, '_20014'), 2, 0.0000, 150.0000, 30.0000, 150.0000, 30.0000, '200', 'T1')
		, (CONCAT('030004.', @UserId), CONCAT(@UserId, '_20015'), 5000, 0.0000, 650.0000, 0.0000, 650.0000, 0.0000, '200', 'T0')
		, (CONCAT('030005.', @UserId), CONCAT(@UserId, '_20016'), 2, 0.0000, 150.0000, 30.0000, 150.0000, 30.0000, '200', 'T1')
		, (CONCAT('030006.', @UserId), CONCAT(@UserId, '_20017'), 5000, 0.0000, 650.0000, 0.0000, 650.0000, 0.0000, '200', 'T0')
		, (CONCAT('030007.', @UserId), CONCAT(@UserId, '_20018'), 2, 0.0000, 150.0000, 30.0000, 150.0000, 30.0000, '200', 'T1')
		, (CONCAT('030008.', @UserId), CONCAT(@UserId, '_20019'), 5000, 0.0000, 650.0000, 0.0000, 650.0000, 0.0000, '200', 'T0')
		, (CONCAT('030009.', @UserId), CONCAT(@UserId, '_20020'), 2, 0.0000, 150.0000, 30.0000, 150.0000, 30.0000, '200', 'T1')
		, (CONCAT('030010.', @UserId), CONCAT(@UserId, '_40000'), 142, 0.0000, 63.9000, 0.0000, 63.9000, 0.0000, '212', 'T0')
		, (CONCAT('030010.', @UserId), CONCAT(@UserId, '_40003'), 1, 0.0000, 4.0000, 0.8000, 4.0000, 0.8000, '213', 'T1')
		, (CONCAT('030010.', @UserId), CONCAT(@UserId, '_40004'), 4, 0.0000, 16.0000, 0.0000, 16.0000, 0.0000, '205', 'T0')
		, (CONCAT('030011.', @UserId), CONCAT(@UserId, '_40005'), 1, 0.0000, 1000.0000, 0.0000, 1000.0000, 0.0000, '402', 'NI1')
		, (CONCAT('030012.', @UserId), CONCAT(@UserId, '_40006'), 1, 0.0000, 1000.0000, 0.0000, 1000.0000, 0.0000, '402', 'NI1')
		, (CONCAT('030013.', @UserId), CONCAT(@UserId, '_40007'), 1, 0.0000, 1000.0000, 0.0000, 1000.0000, 0.0000, '402', 'NI1')
		, (CONCAT('030014.', @UserId), CONCAT(@UserId, '_40008'), 1, 0.0000, 1000.0000, 0.0000, 1000.0000, 0.0000, '402', 'NI1')
		, (CONCAT('030015.', @UserId), CONCAT(@UserId, '_40009'), 1, 0.0000, 1000.0000, 0.0000, 1000.0000, 0.0000, '402', 'NI1')
		, (CONCAT('030016.', @UserId), CONCAT(@UserId, '_40010'), 1, 0.0000, 1000.0000, 0.0000, 1000.0000, 0.0000, '402', 'NI1')
		, (CONCAT('030017.', @UserId), CONCAT(@UserId, '_20031'), 5000000, 0.0000, 6000.0000, 1200.0000, 6000.0000, 1200.0000, '200', 'T1')
		, (CONCAT('030018.', @UserId), CONCAT(@UserId, '_20032'), 13, 0.0000, 9750.0000, 1950.0000, 9750.0000, 1950.0000, '200', 'T1')
		, (CONCAT('030019.', @UserId), CONCAT(@UserId, '_40017'), 185, 0.0000, 83.2500, 0.0000, 83.2500, 0.0000, '212', 'T0')
		, (CONCAT('030019.', @UserId), CONCAT(@UserId, '_40018'), 1, 0.0000, 19.2000, 0.0000, 19.2000, 0.0000, '207', 'T0')
		, (CONCAT('030019.', @UserId), CONCAT(@UserId, '_40019'), 1, 0.0000, 16.0000, 0.0000, 16.0000, 0.0000, '205', 'T0')
		, (CONCAT('030020.', @UserId), CONCAT(@UserId, '_40020'), 178, 0.0000, 80.1000, 0.0000, 80.1000, 0.0000, '212', 'T0')
		, (CONCAT('030020.', @UserId), CONCAT(@UserId, '_40021'), 1, 0.0000, 5.0000, 0.0000, 5.0000, 0.0000, '213', 'T0')
		, (CONCAT('030020.', @UserId), CONCAT(@UserId, '_40022'), 1, 0.0000, 20.0000, 0.0000, 20.0000, 0.0000, '205', 'T0')
		, (CONCAT('030022.', @UserId), CONCAT(@UserId, '_40023'), 340, 0.0000, 153.0000, 0.0000, 153.0000, 0.0000, '212', 'T0')
		, (CONCAT('030022.', @UserId), CONCAT(@UserId, '_40024'), 1, 0.0000, 16.0000, 0.0000, 16.0000, 0.0000, '205', 'T0')
		, (CONCAT('030023.', @UserId), CONCAT(@UserId, '_40025'), 395, 0.0000, 177.7500, 0.0000, 177.7500, 0.0000, '212', 'T0')
		, (CONCAT('030023.', @UserId), CONCAT(@UserId, '_40026'), 1, 0.0000, 18.0000, 3.6000, 18.0000, 3.6000, '209', 'T1')
		, (CONCAT('030023.', @UserId), CONCAT(@UserId, '_40027'), 1, 0.0000, 16.0000, 0.0000, 16.0000, 0.0000, '205', 'T0')
		, (CONCAT('030024.', @UserId), CONCAT(@UserId, '_40028'), 412, 0.0000, 185.4000, 0.0000, 185.4000, 0.0000, '212', 'T0')
		, (CONCAT('030024.', @UserId), CONCAT(@UserId, '_40029'), 1, 0.0000, 5.0000, 1.0000, 5.0000, 1.0000, '213', 'T1')
		, (CONCAT('030024.', @UserId), CONCAT(@UserId, '_40030'), 1, 0.0000, 12.0000, 0.0000, 12.0000, 0.0000, '205', 'T0')
		, (CONCAT('030026.', @UserId), CONCAT(@UserId, '_40031'), 1, 0.0000, 40.0000, 8.0000, 40.0000, 8.0000, '202', 'T1')
		, (CONCAT('030027.', @UserId), CONCAT(@UserId, '_40032'), 1, 0.0000, 39.6000, 7.9200, 39.6000, 7.9200, '202', 'T1')
		, (CONCAT('030028.', @UserId), CONCAT(@UserId, '_40033'), 1, 0.0000, 43.1200, 8.6200, 43.1200, 8.6200, '202', 'T1')
		, (CONCAT('030029.', @UserId), CONCAT(@UserId, '_40034'), 1, 0.0000, 43.5200, 8.7000, 43.5200, 8.7000, '202', 'T1')
		, (CONCAT('030030.', @UserId), CONCAT(@UserId, '_40035'), 1, 0.0000, 42.5200, 8.5000, 42.5200, 8.5000, '202', 'T1')
		, (CONCAT('030031.', @UserId), CONCAT(@UserId, '_40036'), 1, 0.0000, 41.1500, 8.2300, 41.1500, 8.2300, '202', 'T1')
		, (CONCAT('030033.', @UserId), CONCAT(@UserId, '_40037'), 1, 0.0000, 40.0000, 8.0000, 40.0000, 8.0000, '202', 'T1')
		, (CONCAT('030035.', @UserId), CONCAT(@UserId, '_40011'), 1, 0.0000, 1000.0000, 0.0000, 1000.0000, 0.0000, '402', 'NI1')
		, (CONCAT('030036.', @UserId), CONCAT(@UserId, '_20021'), 5000, 0.0000, 650.0000, 0.0000, 650.0000, 0.0000, '200', 'T0')
		, (CONCAT('030037.', @UserId), CONCAT(@UserId, '_20022'), 2, 0.0000, 150.0000, 30.0000, 150.0000, 30.0000, '200', 'T1')
		, (CONCAT('030038.', @UserId), CONCAT(@UserId, '_40046'), 12, 0.0000, 54.0000, 10.8000, 54.0000, 10.8000, '209', 'T1')
		;
		INSERT INTO Invoice.tbItem (InvoiceNumber, CashCode, TaxCode, TotalValue, InvoiceValue, TaxValue, PaidValue, PaidTaxValue, ItemReference)
		VALUES (CONCAT('010005.', @UserId), '305', 'N/A', 0.0000, 10000.0000, 0.0000, 10000.0000, 0.0000, null)
		, (CONCAT('010007.', @UserId), '305', 'N/A', 0.0000, 15000.0000, 0.0000, 15000.0000, 0.0000, null)
		, (CONCAT('010008.', @UserId), '305', 'N/A', 0.0000, 5000.0000, 0.0000, 5000.0000, 0.0000, null)
		, (CONCAT('010009.', @UserId), '305', 'N/A', 0.0000, 5000.0000, 0.0000, 5000.0000, 0.0000, null)
		, (CONCAT('010010.', @UserId), '305', 'N/A', 0.0000, 1000.0000, 0.0000, 1000.0000, 0.0000, null)
		, (CONCAT('030021.', @UserId), '303', 'N/A', 0.0000, 5000.0000, 0.0000, 5000.0000, 0.0000, null)
		, (CONCAT('030025.', @UserId), '303', 'N/A', 0.0000, 5000.0000, 0.0000, 5000.0000, 0.0000, null)
		, (CONCAT('030034.', @UserId), '303', 'N/A', 0.0000, 1000.0000, 0.0000, 1000.0000, 0.0000, null)
		;

		UPDATE Task.tbTask SET TaskStatusCode = 3 WHERE TaskCode = CONCAT(@UserId, '_10007');
		UPDATE Task.tbTask SET TaskStatusCode = 3 WHERE TaskCode = CONCAT(@UserId, '_10008');
		UPDATE Task.tbTask SET TaskStatusCode = 3 WHERE TaskCode = CONCAT(@UserId, '_10009');
		UPDATE Task.tbTask SET TaskStatusCode = 3 WHERE TaskCode = CONCAT(@UserId, '_10010');
		UPDATE Task.tbTask SET TaskStatusCode = 3 WHERE TaskCode = CONCAT(@UserId, '_10011');
		UPDATE Task.tbTask SET TaskStatusCode = 3 WHERE TaskCode = CONCAT(@UserId, '_10012');
		UPDATE Task.tbTask SET TaskStatusCode = 3 WHERE TaskCode = CONCAT(@UserId, '_10017');
		UPDATE Task.tbTask SET TaskStatusCode = 3 WHERE TaskCode = CONCAT(@UserId, '_20010');
		UPDATE Task.tbTask SET TaskStatusCode = 3 WHERE TaskCode = CONCAT(@UserId, '_20011');
		UPDATE Task.tbTask SET TaskStatusCode = 3 WHERE TaskCode = CONCAT(@UserId, '_20013');
		UPDATE Task.tbTask SET TaskStatusCode = 3 WHERE TaskCode = CONCAT(@UserId, '_20014');
		UPDATE Task.tbTask SET TaskStatusCode = 3 WHERE TaskCode = CONCAT(@UserId, '_20015');
		UPDATE Task.tbTask SET TaskStatusCode = 3 WHERE TaskCode = CONCAT(@UserId, '_20016');
		UPDATE Task.tbTask SET TaskStatusCode = 3 WHERE TaskCode = CONCAT(@UserId, '_20017');
		UPDATE Task.tbTask SET TaskStatusCode = 3 WHERE TaskCode = CONCAT(@UserId, '_20018');
		UPDATE Task.tbTask SET TaskStatusCode = 3 WHERE TaskCode = CONCAT(@UserId, '_20019');
		UPDATE Task.tbTask SET TaskStatusCode = 3 WHERE TaskCode = CONCAT(@UserId, '_20020');
		UPDATE Task.tbTask SET TaskStatusCode = 3 WHERE TaskCode = CONCAT(@UserId, '_20021');
		UPDATE Task.tbTask SET TaskStatusCode = 3 WHERE TaskCode = CONCAT(@UserId, '_20022');
		UPDATE Task.tbTask SET TaskStatusCode = 3 WHERE TaskCode = CONCAT(@UserId, '_20031');
		UPDATE Task.tbTask SET TaskStatusCode = 3 WHERE TaskCode = CONCAT(@UserId, '_20032');
		UPDATE Task.tbTask SET TaskStatusCode = 3 WHERE TaskCode = CONCAT(@UserId, '_40000');
		UPDATE Task.tbTask SET TaskStatusCode = 3 WHERE TaskCode = CONCAT(@UserId, '_40003');
		UPDATE Task.tbTask SET TaskStatusCode = 3 WHERE TaskCode = CONCAT(@UserId, '_40004');
		UPDATE Task.tbTask SET TaskStatusCode = 3 WHERE TaskCode = CONCAT(@UserId, '_40005');
		UPDATE Task.tbTask SET TaskStatusCode = 3 WHERE TaskCode = CONCAT(@UserId, '_40006');
		UPDATE Task.tbTask SET TaskStatusCode = 3 WHERE TaskCode = CONCAT(@UserId, '_40007');
		UPDATE Task.tbTask SET TaskStatusCode = 3 WHERE TaskCode = CONCAT(@UserId, '_40008');
		UPDATE Task.tbTask SET TaskStatusCode = 3 WHERE TaskCode = CONCAT(@UserId, '_40009');
		UPDATE Task.tbTask SET TaskStatusCode = 3 WHERE TaskCode = CONCAT(@UserId, '_40010');
		UPDATE Task.tbTask SET TaskStatusCode = 3 WHERE TaskCode = CONCAT(@UserId, '_40011');
		UPDATE Task.tbTask SET TaskStatusCode = 3 WHERE TaskCode = CONCAT(@UserId, '_40017');
		UPDATE Task.tbTask SET TaskStatusCode = 3 WHERE TaskCode = CONCAT(@UserId, '_40018');
		UPDATE Task.tbTask SET TaskStatusCode = 3 WHERE TaskCode = CONCAT(@UserId, '_40019');
		UPDATE Task.tbTask SET TaskStatusCode = 3 WHERE TaskCode = CONCAT(@UserId, '_40020');
		UPDATE Task.tbTask SET TaskStatusCode = 3 WHERE TaskCode = CONCAT(@UserId, '_40021');
		UPDATE Task.tbTask SET TaskStatusCode = 3 WHERE TaskCode = CONCAT(@UserId, '_40022');
		UPDATE Task.tbTask SET TaskStatusCode = 3 WHERE TaskCode = CONCAT(@UserId, '_40023');
		UPDATE Task.tbTask SET TaskStatusCode = 3 WHERE TaskCode = CONCAT(@UserId, '_40024');
		UPDATE Task.tbTask SET TaskStatusCode = 3 WHERE TaskCode = CONCAT(@UserId, '_40025');
		UPDATE Task.tbTask SET TaskStatusCode = 3 WHERE TaskCode = CONCAT(@UserId, '_40026');
		UPDATE Task.tbTask SET TaskStatusCode = 3 WHERE TaskCode = CONCAT(@UserId, '_40027');
		UPDATE Task.tbTask SET TaskStatusCode = 3 WHERE TaskCode = CONCAT(@UserId, '_40028');
		UPDATE Task.tbTask SET TaskStatusCode = 3 WHERE TaskCode = CONCAT(@UserId, '_40029');
		UPDATE Task.tbTask SET TaskStatusCode = 3 WHERE TaskCode = CONCAT(@UserId, '_40030');
		UPDATE Task.tbTask SET TaskStatusCode = 3 WHERE TaskCode = CONCAT(@UserId, '_40031');
		UPDATE Task.tbTask SET TaskStatusCode = 3 WHERE TaskCode = CONCAT(@UserId, '_40032');
		UPDATE Task.tbTask SET TaskStatusCode = 3 WHERE TaskCode = CONCAT(@UserId, '_40033');
		UPDATE Task.tbTask SET TaskStatusCode = 3 WHERE TaskCode = CONCAT(@UserId, '_40034');
		UPDATE Task.tbTask SET TaskStatusCode = 3 WHERE TaskCode = CONCAT(@UserId, '_40035');
		UPDATE Task.tbTask SET TaskStatusCode = 3 WHERE TaskCode = CONCAT(@UserId, '_40036');
		UPDATE Task.tbTask SET TaskStatusCode = 3 WHERE TaskCode = CONCAT(@UserId, '_40037');
		UPDATE Task.tbTask SET TaskStatusCode = 3 WHERE TaskCode = CONCAT(@UserId, '_40046');

		UPDATE       Invoice.tbInvoice
		SET                InvoicedOn = task.ActionedOn
		FROM            Invoice.tbTask AS taskinvoice INNER JOIN
								 Task.tbTask AS task ON taskinvoice.TaskCode = task.TaskCode INNER JOIN
								 Invoice.tbInvoice ON taskinvoice.InvoiceNumber = Invoice.tbInvoice.InvoiceNumber;

		WITH invoice_items AS
		(
			SELECT        Invoice.tbInvoice.InvoiceNumber
			FROM            Invoice.tbInvoice INNER JOIN
									 Invoice.tbItem ON Invoice.tbInvoice.InvoiceNumber = Invoice.tbItem.InvoiceNumber
			EXCEPT
			SELECT        Invoice.tbInvoice.InvoiceNumber
			FROM            Invoice.tbInvoice INNER JOIN
									 Invoice.tbTask ON Invoice.tbInvoice.InvoiceNumber = Invoice.tbTask.InvoiceNumber
		)
		UPDATE invoices
		SET InvoicedOn = DATEADD(MONTH, @OffsetMonth, App.fnAdjustToCalendar(InvoicedOn, 0))
		FROM Invoice.tbInvoice invoices
			JOIN invoice_items ON invoices.InvoiceNumber = invoice_items.InvoiceNumber;

		IF (@PayInvoices = 0)
			GOTO CommitTran;

		INSERT INTO Cash.tbPayment (PaymentCode, UserId, PaymentStatusCode, AccountCode, CashAccountCode, CashCode, TaxCode, PaidOn, PaidInValue, PaidOutValue, TaxInValue, TaxOutValue, PaymentReference)
		VALUES (CONCAT(@UserId, '_20190008_120000'), @UserId, 1, 'CDCUST', 'CURACC', '103', 'T1', '20190228', 1200.0000, 0.0000, 200.0000, 0.0000, CONCAT('010000.', @UserId))
		, (CONCAT(@UserId, '_20190008_120001'), @UserId, 1, 'CDCUST', 'CURACC', '103', 'T1', '20190329', 1200.0000, 0.0000, 200.0000, 0.0000, CONCAT('010001.', @UserId))
		, (CONCAT(@UserId, '_20190008_120002'), @UserId, 1, 'CDCUST', 'CURACC', '103', 'T1', '20190430', 1200.0000, 0.0000, 200.0000, 0.0000, CONCAT('010002.', @UserId))
		, (CONCAT(@UserId, '_20190008_120003'), @UserId, 1, 'CDCUST', 'CURACC', '103', 'T1', '20190531', 1200.0000, 0.0000, 200.0000, 0.0000, CONCAT('010003.', @UserId))
		, (CONCAT(@UserId, '_20190008_120004'), @UserId, 1, 'CDCUST', 'CURACC', '103', 'T1', '20190628', 1200.0000, 0.0000, 200.0000, 0.0000, CONCAT('010004.', @UserId))
		, (CONCAT(@UserId, '_20190008_120005'), @UserId, 1, 'SUPTWO', 'CURACC', '200', 'T0', '20190228', 0.0000, 650.0000, 0.0000, 0.0000, CONCAT('030000.', @UserId))
		, (CONCAT(@UserId, '_20190008_120006'), @UserId, 1, 'TRACOM', 'CURACC', '200', 'T1', '20190228', 0.0000, 180.0000, 0.0000, 30.0000, CONCAT('030001.', @UserId))
		, (CONCAT(@UserId, '_20190008_120007'), @UserId, 1, 'SUPTWO', 'CURACC', '200', 'T0', '20190329', 0.0000, 650.0000, 0.0000, 0.0000, CONCAT('030002.', @UserId))
		, (CONCAT(@UserId, '_20190008_120008'), @UserId, 1, 'TRACOM', 'CURACC', '200', 'T1', '20190329', 0.0000, 180.0000, 0.0000, 30.0000, CONCAT('030003.', @UserId))
		, (CONCAT(@UserId, '_20190008_120009'), @UserId, 1, 'SUPTWO', 'CURACC', '200', 'T0', '20190430', 0.0000, 650.0000, 0.0000, 0.0000, CONCAT('030004.', @UserId))
		, (CONCAT(@UserId, '_20190008_120010'), @UserId, 1, 'TRACOM', 'CURACC', '200', 'T1', '20190430', 0.0000, 180.0000, 0.0000, 30.0000, CONCAT('030005.', @UserId))
		, (CONCAT(@UserId, '_20190008_120011'), @UserId, 1, 'SUPTWO', 'CURACC', '200', 'T0', '20190430', 0.0000, 650.0000, 0.0000, 0.0000, CONCAT('030006.', @UserId))
		, (CONCAT(@UserId, '_20190008_120012'), @UserId, 1, 'TRACOM', 'CURACC', '200', 'T1', '20190531', 0.0000, 180.0000, 0.0000, 30.0000, CONCAT('030007.', @UserId))
		, (CONCAT(@UserId, '_20190008_120013'), @UserId, 1, 'SUPTWO', 'CURACC', '200', 'T0', '20190628', 0.0000, 650.0000, 0.0000, 0.0000, CONCAT('030008.', @UserId))
		, (CONCAT(@UserId, '_20190008_120014'), @UserId, 1, 'TRACOM', 'CURACC', '200', 'T1', '20190628', 0.0000, 180.0000, 0.0000, 30.0000, CONCAT('030009.', @UserId))
		, (CONCAT(@UserId, '_20190008_120015'), @UserId, 1, 'BUSOWN', 'CURACC', '205', 'T0', '20190131', 0.0000, 84.7000, 0.0000, 0.8000, null)
		, (CONCAT(@UserId, '_20190008_120016'), @UserId, 1, 'BUSOWN', 'CURACC', '402', 'NI1', '20190131', 0.0000, 1000.0000, 0.0000, 0.0000, null)
		, (CONCAT(@UserId, '_20190008_120017'), @UserId, 1, 'BUSOWN', 'CURACC', '402', 'NI1', '20190228', 0.0000, 1000.0000, 0.0000, 0.0000, null)
		, (CONCAT(@UserId, '_20190008_120018'), @UserId, 1, 'BUSOWN', 'CURACC', '402', 'NI1', '20190329', 0.0000, 1000.0000, 0.0000, 0.0000, null)
		, (CONCAT(@UserId, '_20190008_120019'), @UserId, 1, 'BUSOWN', 'CURACC', '402', 'NI1', '20190430', 0.0000, 1000.0000, 0.0000, 0.0000, null)
		, (CONCAT(@UserId, '_20190008_120020'), @UserId, 1, 'BUSOWN', 'CURACC', '402', 'NI1', '20190531', 0.0000, 1000.0000, 0.0000, 0.0000, null)
		, (CONCAT(@UserId, '_20190008_120021'), @UserId, 1, 'BUSOWN', 'CURACC', '402', 'NI1', '20190628', 0.0000, 1000.0000, 0.0000, 0.0000, null)
		, (CONCAT(@UserId, '_20190008_120022'), @UserId, 1, 'BUSOWN', 'CURACC', '205', 'T0', '20190228', 0.0000, 118.4500, 0.0000, 0.0000, 'Monthly expenses')
		, (CONCAT(@UserId, '_20190008_120023'), @UserId, 1, 'BUSOWN', 'CURACC', '205', 'T0', '20190329', 0.0000, 105.1000, 0.0000, 0.0000, 'Monthly expenses')
		, (CONCAT(@UserId, '_20190008_120024'), @UserId, 1, 'SUPTWO', 'CURACC', '200', 'T1', '20190430', 0.0000, 7200.0000, 0.0000, 1200.0000, CONCAT('030017.', @UserId))
		, (CONCAT(@UserId, '_20190008_120025'), @UserId, 1, 'BUSOWN', 'CURACC', '205', 'T0', '20190430', 0.0000, 169.0000, 0.0000, 0.0000, 'Monthly expenses')
		, (CONCAT(@UserId, '_20190008_120026'), @UserId, 1, 'EFCUST', 'CURACC', '103', 'T1', '20190518', 22200.0000, 0.0000, 3700.0000, 0.0000, null)
		, (CONCAT(@UserId, '_20190008_120027'), @UserId, 1, 'THEPAP', 'CURACC', '200', 'T1', '20190518', 0.0000, 11700.0000, 0.0000, 1950.0000, null)
		, (CONCAT(@UserId, '_20190008_120028'), @UserId, 1, 'BUSOWN', 'CURACC', '205', 'T0', '20190708', 0.0000, 215.3500, 0.0000, 3.6000, 'Monthly expenses')
		, (CONCAT(@UserId, '_20190008_120029'), @UserId, 1, 'BUSOWN', 'CURACC', '205', 'T0', '20190708', 0.0000, 203.4000, 0.0000, 1.0000, 'Monthly expenses')
		, (CONCAT(@UserId, '_20190019_120000'), @UserId, 1, 'TELPRO', 'CURACC', '202', 'T1', '20190125', 0.0000, 48.0000, 0.0000, 8.0000, CONCAT('030026.', @UserId))
		, (CONCAT(@UserId, '_20190019_120001'), @UserId, 1, 'TELPRO', 'CURACC', '202', 'T1', '20190226', 0.0000, 47.5200, 0.0000, 7.9200, CONCAT('030027.', @UserId))
		, (CONCAT(@UserId, '_20190019_120002'), @UserId, 1, 'TELPRO', 'CURACC', '202', 'T1', '20190326', 0.0000, 51.7400, 0.0000, 8.6200, CONCAT('030028.', @UserId))
		, (CONCAT(@UserId, '_20190019_120003'), @UserId, 1, 'TELPRO', 'CURACC', '202', 'T1', '20190426', 0.0000, 52.2200, 0.0000, 8.7000, CONCAT('030029.', @UserId))
		, (CONCAT(@UserId, '_20190019_120004'), @UserId, 1, 'TELPRO', 'CURACC', '202', 'T1', '20190526', 0.0000, 51.0200, 0.0000, 8.5000, CONCAT('030030.', @UserId))
		, (CONCAT(@UserId, '_20190019_120005'), @UserId, 1, 'TELPRO', 'CURACC', '202', 'T1', '20190626', 0.0000, 49.3800, 0.0000, 8.2300, CONCAT('030031.', @UserId))
		, (CONCAT(@UserId, '_20190022_120000'), @UserId, 1, 'TELPRO', 'CURACC', '202', 'T1', '20190726', 0.0000, 48.0000, 0.0000, 8.0000, CONCAT('030033.', @UserId))
		, (CONCAT(@UserId, '_20190022_120001'), @UserId, 1, 'BUSOWN', 'CURACC', '402', 'NI1', '20190731', 0.0000, 1000.0000, 0.0000, 0.0000, CONCAT('030035.', @UserId))
		, (CONCAT(@UserId, '_20190022_120002'), @UserId, 1, 'CDCUST', 'CURACC', '103', 'T1', '20190731', 1200.0000, 0.0000, 200.0000, 0.0000, CONCAT('010011.', @UserId))
		, (CONCAT(@UserId, '_20190022_120003'), @UserId, 1, 'SUPTWO', 'CURACC', '200', 'T0', '20190731', 0.0000, 650.0000, 0.0000, 0.0000, CONCAT('030036.', @UserId))
		, (CONCAT(@UserId, '_20190022_120004'), @UserId, 1, 'TRACOM', 'CURACC', '200', 'T1', '20190731', 0.0000, 180.0000, 0.0000, 30.0000, CONCAT('030037.', @UserId))
		, (CONCAT(@UserId, '_20190022_120005'), @UserId, 1, 'SUNSUP', 'CURACC', '209', 'T1', '20190702', 0.0000, 64.8000, 0.0000, 10.8000, null)
		, (CONCAT(@UserId, '_20190608_030639'), @UserId, 1, 'HOME', 'RESACC', '305', 'N/A', '20190101', 15000.0000, 0.0000, 0.0000, 0.0000, 'Opening balance')
		, (CONCAT(@UserId, '_20190708_030716'), @UserId, 1, 'HOME', 'RESACC', '303', 'N/A', '20190415', 0.0000, 5000.0000, 0.0000, 0.0000, 'Transfer to current account')
		, (CONCAT(@UserId, '_20190708_030747'), @UserId, 1, 'HOME', 'CURACC', '305', 'N/A', '20190415', 5000.0000, 0.0000, 0.0000, 0.0000, 'Transfer from Reserve Account')
		, (CONCAT(@UserId, '_20191822_121834'), @UserId, 2, 'HOME', 'CURACC', '303', 'N/A', '20190831', 0.0000, 5000.0000, 0.0000, 0.0000, 'Transfer to Reserve account')
		, (CONCAT(@UserId, '_20191822_121848'), @UserId, 2, 'HOME', 'RESACC', '305', 'N/A', '20190831', 5000.0000, 0.0000, 0.0000, 0.0000, 'Transfer from current account')
		, (CONCAT(@UserId, '_20192408_042438'), @UserId, 1, 'HOME', 'CURACC', '303', 'N/A', '20190601', 0.0000, 5000.0000, 0.0000, 0.0000, 'Transfer to Reserve Account')
		, (CONCAT(@UserId, '_20192508_042502'), @UserId, 1, 'HOME', 'RESACC', '305', 'N/A', '20190601', 5000.0000, 0.0000, 0.0000, 0.0000, 'Transfer from Current Account')
		, (CONCAT(@UserId, '_20194708_014729'), @UserId, 1, 'HOME', 'CURACC', '305', 'N/A', '20190101', 10000.0000, 0.0000, 0.0000, 0.0000, 'Opening Balance')
		, (CONCAT(@UserId, '_20195222_125225'), @UserId, 1, 'HOME', 'CURACC', '303', 'N/A', '20190731', 0.0000, 1000.0000, 0.0000, 0.0000, 'Transfer to Reserve account')
		, (CONCAT(@UserId, '_20195322_125307'), @UserId, 1, 'HOME', 'RESACC', '305', 'N/A', '20190731', 1000.0000, 0.0000, 0.0000, 0.0000, 'Transfer from current account')
		;

		UPDATE Invoice.tbInvoice
		SET InvoiceStatusCode = 3;

		UPDATE Cash.tbPayment
		SET PaidOn = DATEADD(MONTH, @OffsetMonth, App.fnAdjustToCalendar(PaidOn, 0));

CommitTran:
		EXEC App.proc_SystemRebuild;
		COMMIT TRAN;

	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH

go




