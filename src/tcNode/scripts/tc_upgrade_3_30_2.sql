/**************************************************************************************
Trade Control
Upgrade script
Release: 3.30.2

Date: 24 September 2020
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
ALTER VIEW Cash.vwAccountStatementListing
AS
	SELECT        App.tbYear.YearNumber, Org.tbOrg.AccountName AS Bank, Org.tbAccount.CashAccountCode, Org.tbAccount.CashAccountName, Org.tbAccount.SortCode, Org.tbAccount.AccountNumber, CONCAT(App.tbYear.Description, SPACE(1), 
							 App.tbMonth.MonthName) AS PeriodName, Cash.vwAccountStatement.StartOn, CAST(Cash.vwAccountStatement.EntryNumber AS INT) EntryNumber, Cash.vwAccountStatement.PaymentCode, Cash.vwAccountStatement.PaidOn, 
							 Cash.vwAccountStatement.AccountName, Cash.vwAccountStatement.PaymentReference, Cash.vwAccountStatement.PaidInValue, Cash.vwAccountStatement.PaidOutValue, 
							 Cash.vwAccountStatement.PaidBalance, Cash.vwAccountStatement.CashCode, 
							 Cash.vwAccountStatement.CashDescription, Cash.vwAccountStatement.TaxDescription, Cash.vwAccountStatement.UserName, Cash.vwAccountStatement.AccountCode, 
							 Cash.vwAccountStatement.TaxCode
	FROM            App.tbYearPeriod INNER JOIN
							 App.tbMonth ON App.tbYearPeriod.MonthNumber = App.tbMonth.MonthNumber INNER JOIN
							 Cash.vwAccountStatement INNER JOIN
							 Org.tbAccount ON Cash.vwAccountStatement.CashAccountCode = Org.tbAccount.CashAccountCode INNER JOIN
							 Org.tbOrg ON Org.tbAccount.AccountCode = Org.tbOrg.AccountCode ON App.tbYearPeriod.StartOn = Cash.vwAccountStatement.StartOn INNER JOIN
							 App.tbYear ON App.tbYearPeriod.YearNumber = App.tbYear.YearNumber;
go
ALTER VIEW Org.vwStatusReport
AS
	SELECT        Org.vwDatasheet.AccountCode, Org.vwDatasheet.AccountName, Org.vwDatasheet.OrganisationType, Org.vwDatasheet.OrganisationStatus, Org.vwDatasheet.TaxDescription, Org.vwDatasheet.Address, 
							 Org.vwDatasheet.AreaCode, Org.vwDatasheet.PhoneNumber, Org.vwDatasheet.EmailAddress, Org.vwDatasheet.WebSite, Org.vwDatasheet.IndustrySector, 
							 Org.vwDatasheet.AccountSource, Org.vwDatasheet.PaymentTerms, Org.vwDatasheet.PaymentDays, Org.vwDatasheet.ExpectedDays, Org.vwDatasheet.NumberOfEmployees, Org.vwDatasheet.CompanyNumber, Org.vwDatasheet.VatNumber, 
							 Org.vwDatasheet.Turnover, Org.vwDatasheet.OpeningBalance, Org.vwDatasheet.EUJurisdiction, Org.vwDatasheet.BusinessDescription, 
							 Cash.tbPayment.PaymentCode, Usr.tbUser.UserName, App.tbTaxCode.TaxDescription AS PaymentTaxDescription, Org.tbAccount.CashAccountName, Cash.tbCode.CashDescription, Cash.tbPayment.UserId, 
							 Cash.tbPayment.CashAccountCode, Cash.tbPayment.CashCode, Cash.tbPayment.TaxCode, Cash.tbPayment.PaidOn, Cash.tbPayment.PaidInValue, Cash.tbPayment.PaidOutValue, 
							 Cash.tbPayment.InsertedBy, Cash.tbPayment.InsertedOn, Cash.tbPayment.UpdatedBy, Cash.tbPayment.UpdatedOn, Cash.tbPayment.PaymentReference
	FROM            Cash.tbPayment INNER JOIN
							 Usr.tbUser ON Cash.tbPayment.UserId = Usr.tbUser.UserId INNER JOIN
							 Org.tbAccount ON Cash.tbPayment.CashAccountCode = Org.tbAccount.CashAccountCode INNER JOIN
							 Cash.tbCode ON Cash.tbPayment.CashCode = Cash.tbCode.CashCode LEFT OUTER JOIN
							 App.tbTaxCode ON Cash.tbPayment.TaxCode = App.tbTaxCode.TaxCode INNER JOIN
							 Org.vwDatasheet ON Cash.tbPayment.AccountCode = Org.vwDatasheet.AccountCode
	WHERE        (Cash.tbPayment.PaymentStatusCode = 1);
go
ALTER VIEW Cash.vwTransfersUnposted
AS
	SELECT        PaymentCode, UserId, PaymentStatusCode, AccountCode, CashAccountCode, CashCode, TaxCode, PaidOn, PaidInValue, PaidOutValue, PaymentReference, InsertedBy, InsertedOn, 
							 UpdatedBy, UpdatedOn, RowVer
	FROM            Cash.tbPayment
	WHERE        (PaymentStatusCode = 2)
go
ALTER VIEW Cash.vwPayments
AS
	SELECT        Cash.tbPayment.AccountCode, Cash.tbPayment.PaymentCode, Cash.tbPayment.UserId, Cash.tbPayment.PaymentStatusCode, Cash.tbPayment.CashAccountCode, Cash.tbPayment.CashCode, Cash.tbPayment.TaxCode, 
							 Cash.tbPayment.PaidOn, Cash.tbPayment.PaidInValue, Cash.tbPayment.PaidOutValue, Cash.tbPayment.PaymentReference, Cash.tbPayment.InsertedBy, 
							 Cash.tbPayment.InsertedOn, Cash.tbPayment.UpdatedBy, Cash.tbPayment.UpdatedOn, Usr.tbUser.UserName, App.tbTaxCode.TaxDescription, Org.tbAccount.CashAccountName, Cash.tbCode.CashDescription
	FROM            Cash.tbPayment INNER JOIN
							 Usr.tbUser ON Cash.tbPayment.UserId = Usr.tbUser.UserId INNER JOIN
							 Org.tbAccount ON Cash.tbPayment.CashAccountCode = Org.tbAccount.CashAccountCode INNER JOIN
							 Cash.tbCode ON Cash.tbPayment.CashCode = Cash.tbCode.CashCode LEFT OUTER JOIN
							 App.tbTaxCode ON Cash.tbPayment.TaxCode = App.tbTaxCode.TaxCode
	WHERE        (Cash.tbPayment.PaymentStatusCode = 1);
go
ALTER VIEW Cash.vwPaymentsListing
AS
	SELECT Org.tbOrg.AccountCode, Org.tbOrg.AccountName, Org.tbType.OrganisationType, Org.tbStatus.OrganisationStatus, Cash.tbPayment.PaymentCode, Usr.tbUser.UserName, 
							 App.tbTaxCode.TaxDescription AS PaymentTaxDescription, Org.tbAccount.CashAccountName, Cash.tbCode.CashDescription, Cash.tbPayment.UserId, Cash.tbPayment.CashAccountCode, Cash.tbPayment.CashCode, 
							 Cash.tbPayment.TaxCode, CONCAT(YEAR(Cash.tbPayment.PaidOn), Format(MONTH(Cash.tbPayment.PaidOn), '00')) AS Period, Cash.tbPayment.PaidOn, Cash.tbPayment.PaidInValue, Cash.tbPayment.PaidOutValue, 
							 Cash.tbPayment.InsertedBy, Cash.tbPayment.InsertedOn, Cash.tbPayment.UpdatedBy, Cash.tbPayment.UpdatedOn, Cash.tbPayment.PaymentReference
	FROM            Cash.tbPayment INNER JOIN
							 Usr.tbUser ON Cash.tbPayment.UserId = Usr.tbUser.UserId INNER JOIN
							 Org.tbAccount ON Cash.tbPayment.CashAccountCode = Org.tbAccount.CashAccountCode INNER JOIN
							 Cash.tbCode ON Cash.tbPayment.CashCode = Cash.tbCode.CashCode LEFT OUTER JOIN
							 App.tbTaxCode ON Cash.tbPayment.TaxCode = App.tbTaxCode.TaxCode INNER JOIN
							 Org.tbOrg ON Cash.tbPayment.AccountCode = Org.tbOrg.AccountCode INNER JOIN
							 Org.tbType ON Org.tbOrg.OrganisationTypeCode = Org.tbType.OrganisationTypeCode INNER JOIN
							 Org.tbStatus ON Org.tbOrg.OrganisationStatusCode = Org.tbStatus.OrganisationStatusCode
	WHERE        (Cash.tbPayment.PaymentStatusCode = 1);
go
ALTER VIEW Cash.vwPaymentsUnposted
AS
	SELECT        PaymentCode, UserId, PaymentStatusCode, AccountCode, CashAccountCode, CashCode, TaxCode, PaidOn, PaidInValue, PaidOutValue, PaymentReference, IsProfitAndLoss, InsertedBy, InsertedOn, 
							 UpdatedBy, UpdatedOn, RowVer
	FROM            Cash.tbPayment
	WHERE        (PaymentStatusCode = 0);
go
CREATE OR ALTER VIEW Org.vwCurrentBalance
AS
	WITH current_balance AS
	(
		SELECT AccountCode, MAX(RowNumber) CurrentBalanceRow
		FROM Org.vwStatement
		GROUP BY AccountCode
	)
	SELECT org_statement.AccountCode, org_statement.Balance
	FROM Org.vwStatement org_statement
		JOIN current_balance ON org_statement.AccountCode = current_balance.AccountCode 
			AND org_statement.RowNumber = current_balance.CurrentBalanceRow
go
CREATE OR ALTER VIEW Invoice.vwStatusLive
AS
	WITH nonzero_balance_orgs AS
	(
		SELECT AccountCode, Balance, CASE WHEN Balance > 0 THEN 0 ELSE 1 END CashModeCode 
		FROM Org.vwCurrentBalance
	), invoice_statement AS
	(
		SELECT nonzero_balance_orgs.AccountCode, 
			RowNumber, InvoiceNumber, CashModeCode, TotalCharge, TaxValue,
			CASE RowNumber 
				WHEN 1 THEN nonzero_balance_orgs.Balance + TotalCharge
			ELSE TotalCharge 
			END Charge,
			CASE RowNumber 
				WHEN 1 THEN nonzero_balance_orgs.Balance 
				ELSE 0 END OpeningBalance, 
			CASE RowNumber
				WHEN 1 THEN 
					CASE CashModeCode 
						WHEN 0 THEN
							CASE WHEN TotalCharge > 0 THEN -1 ELSE 1 END
						WHEN 1 THEN
							CASE WHEN TotalCharge < 0 THEN -1 ELSE 1 END
					END
				ELSE 1
			END Multiplier
		FROM nonzero_balance_orgs
			CROSS APPLY
				(
					SELECT InvoiceNumber,
						ROW_NUMBER() OVER (ORDER BY InvoicedOn DESC) RowNumber,
						CASE CashModeCode 
							WHEN 0 THEN (InvoiceValue + TaxValue) * - 1  
							WHEN 1 THEN (InvoiceValue + TaxValue)
						END AS TotalCharge,
						TaxValue
					FROM Invoice.tbInvoice invoices
						INNER JOIN Invoice.tbType ON invoices.InvoiceTypeCode = Invoice.tbType.InvoiceTypeCode
					WHERE AccountCode = nonzero_balance_orgs.AccountCode AND InvoiceValue <> 0
				) invoices
	), invoice_multiplier AS
	(
		SELECT AccountCode, RowNumber, InvoiceNumber, CashModeCode, TotalCharge, TaxValue, OpeningBalance, Charge,
			MIN(Multiplier) OVER (PARTITION BY AccountCode ORDER BY RowNumber) Multiplier
		FROM invoice_statement
	), invoice_balances AS
	(
		SELECT  AccountCode, RowNumber, InvoiceNumber, CashModeCode, TotalCharge, TaxValue, OpeningBalance, Charge,
			CAST(SUM(Charge * Multiplier) OVER (PARTITION BY AccountCode ORDER BY RowNumber ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS float) AS Balance
		FROM invoice_multiplier
	), invoice_paid AS
	(
		SELECT AccountCode, RowNumber, InvoiceNumber, CashModeCode, TotalCharge,
			ABS(TotalCharge) - TaxValue InvoiceValue, TaxValue, TaxValue / ABS(TotalCharge) TaxRate, 
			OpeningBalance, Charge, Balance, 
			CASE CashModeCode 
				WHEN 0 THEN
					CASE 
						WHEN Balance >= 0 THEN 1
						WHEN TotalCharge < Balance THEN 2
						ELSE 3
					END 
				WHEN 1 THEN
					CASE 
						WHEN Balance <= 0 THEN 1
						WHEN TotalCharge > Balance THEN 2
						ELSE 3
					END 
			END InvoiceStatusCode,
			CASE CashModeCode 
				WHEN 0 THEN
					CASE 
						WHEN Balance >= 0 THEN 0
						WHEN TotalCharge < Balance THEN TotalCharge - Balance
						ELSE TotalCharge
					END 
				WHEN 1 THEN
					CASE 
						WHEN Balance <= 0 THEN 0
						WHEN TotalCharge > Balance THEN TotalCharge - Balance
						ELSE TotalCharge
					END 
			END TotalPaid		
		FROM invoice_balances
	)
	, invoice_status AS
	(
		SELECT AccountCode, RowNumber, InvoiceNumber, CashModeCode, TotalCharge, InvoiceValue, TaxValue, TaxRate, OpeningBalance, Charge, Balance, TotalPaid,
			MAX(InvoiceStatusCode) OVER (PARTITION BY AccountCode ORDER BY RowNumber) InvoiceStatusCode
		FROM invoice_paid
	)
	SELECT AccountCode, RowNumber, InvoiceNumber, CashModeCode, TotalCharge, InvoiceValue, TaxValue, TaxRate, OpeningBalance, Charge, Balance, TotalPaid,
		InvoiceStatusCode, 
		CASE CashModeCode 
			WHEN 0 THEN
				CASE InvoiceStatusCode
					WHEN 1 THEN 0
					WHEN 2 THEN InvoiceValue + (TotalPaid / (1 + TaxRate)) 
					ELSE InvoiceValue
				END
			WHEN 1 THEN
				CASE InvoiceStatusCode
					WHEN 1 THEN 0
					WHEN 2 THEN InvoiceValue - (TotalPaid / (1 + TaxRate)) 
					ELSE InvoiceValue
				END
		END PaidValue, 				
		CASE CashModeCode 
			WHEN 0 THEN
				CASE InvoiceStatusCode						
					WHEN 1 THEN 0
					WHEN 2 THEN TaxValue +	(TotalPaid - (TotalPaid / (1 + TaxRate))) 
					ELSE TaxValue
				END
			WHEN 1 THEN
				CASE InvoiceStatusCode						
					WHEN 1 THEN 0
					WHEN 2 THEN TaxValue -(TotalPaid - (TotalPaid / (1 + TaxRate))) 
					ELSE TaxValue
				END
		END PaidTaxValue
	FROM invoice_status;
go
ALTER PROCEDURE App.proc_DemoServices
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
			UNION
			SELECT MinerAccountCode FROM App.tbOptions opt JOIN Org.tbOrg miner ON opt.MinerAccountCode = miner.AccountCode
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
		, (CONCAT(@UserId, '_10007'), @UserId, 'CDCUST', 'Monthly Contract', 'CD Monthly Brochure', 'Ben Boyd', 'SO Brochure or Catalogue', 2, @UserId, '20190126', '20190126', '20190228', null, 5000, '103', 'T1', 0.4, 2000, 'CDCUST_001', 'CDCUST_002', 0, 0)
		, (CONCAT(@UserId, '_10008'), @UserId, 'CDCUST', 'Monthly Contract', 'CD Monthly Brochure', 'Ben Boyd', 'SO Brochure or Catalogue', 2, @UserId, '20190225', '20190225', '20190329', null, 5000, '103', 'T1', 0.4, 2000, 'CDCUST_001', 'CDCUST_002', 0, 0)
		, (CONCAT(@UserId, '_10009'), @UserId, 'CDCUST', 'Monthly Contract', 'CD Monthly Brochure', 'Ben Boyd', 'SO Brochure or Catalogue', 2, @UserId, '20190328', '20190328', '20190430', null, 5000, '103', 'T1', 0.4, 2000, 'CDCUST_001', 'CDCUST_002', 0, 0)
		, (CONCAT(@UserId, '_10010'), @UserId, 'CDCUST', 'Monthly Contract', 'CD Monthly Brochure', 'Ben Boyd', 'SO Brochure or Catalogue', 2, @UserId, '20190428', '20190428', '20190531', null, 5000, '103', 'T1', 0.4, 2000, 'CDCUST_001', 'CDCUST_002', 0, 0)
		, (CONCAT(@UserId, '_10011'), @UserId, 'CDCUST', 'Monthly Contract', 'CD Monthly Brochure', 'Ben Boyd', 'SO Brochure or Catalogue', 2, @UserId, '20190525', '20190525', '20190628', null, 5000, '103', 'T1', 0.4, 2000, 'CDCUST_001', 'CDCUST_002', 0, 0)
		, (CONCAT(@UserId, '_10012'), @UserId, 'CDCUST', 'Monthly Contract', 'CD Monthly Brochure', 'Ben Boyd', 'SO Brochure or Catalogue', 2, @UserId, '20190627', '20190822', '20190731', null, 5000, '103', 'T1', 0.4, 2000, 'CDCUST_001', 'CDCUST_002', 0, 0)
		, (CONCAT(@UserId, '_10013'), @UserId, 'CDCUST', 'Monthly Contract', 'CD Monthly Brochure', 'Ben Boyd', 'SO Brochure or Catalogue', 1, @UserId, '20190726', null, '20190830', null, 5000, '103', 'T1', 0.4, 2000, 'CDCUST_001', 'CDCUST_002', 0, 0)
		, (CONCAT(@UserId, '_10014'), @UserId, 'CDCUST', 'Monthly Contract', 'CD Monthly Brochure', 'Ben Boyd', 'SO Brochure or Catalogue', 1, @UserId, '20190828', null, '20190930', null, 5000, '103', 'T1', 0.4, 2000, 'CDCUST_001', 'CDCUST_002', 0, 0)
		, (CONCAT(@UserId, '_10015'), @UserId, 'EFCUST', 'PO12131', 'Outer Carton Ref X12-2', 'Christine Cook', 'SO Packaging', 1, @UserId, '20190917', null, '20190917', null, 1000, '103', 'T1', 0.62, 1240.0000, 'EFCUST_001', 'EFCUST_002', 0, 0)
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
		VALUES (CONCAT('010000.', @UserId), @UserId, 'CDCUST', 0, 1, '20190126', '20190228', '20190228', 2000, 400, 2000, 400, '30 days end of month following date of invoice', null, 0, 0)
		, (CONCAT('010001.', @UserId), @UserId, 'CDCUST', 0, 1, '20190225', '20190329', '20190329', 2000, 400, 2000, 400, '30 days end of month following date of invoice', null, 0, 0)
		, (CONCAT('010002.', @UserId), @UserId, 'CDCUST', 0, 1, '20190328', '20190430', '20190430', 2000, 400, 2000, 400, '30 days end of month following date of invoice', null, 0, 0)
		, (CONCAT('010003.', @UserId), @UserId, 'CDCUST', 0, 1, '20190428', '20190531', '20190531', 2000, 400, 2000, 400, '30 days end of month following date of invoice', null, 0, 0)
		, (CONCAT('010004.', @UserId), @UserId, 'CDCUST', 0, 1, '20190525', '20190628', '20190628', 2000, 400, 2000, 400, '30 days end of month following date of invoice', null, 0, 0)
		, (CONCAT('010005.', @UserId), @UserId, 'HOME', 0, 1, '20190101', '20190101', '20190101', 10000.0000, 0.0000, 10000.0000, 0.0000, null, null, 0, 0)
		, (CONCAT('010006.', @UserId), @UserId, 'EFCUST', 0, 1, '20190330', '20190514', '20190429', 18500.0000, 3700.0000, 18500.0000, 3700.0000, '30 days from date of invoice', null, 0, 0)
		, (CONCAT('010007.', @UserId), @UserId, 'HOME', 0, 1, '20190101', '20190101', '20190101', 15000.0000, 0.0000, 15000.0000, 0.0000, null, null, 0, 0)
		, (CONCAT('010008.', @UserId), @UserId, 'HOME', 0, 1, '20190415', '20190415', '20190415', 5000.0000, 0.0000, 5000.0000, 0.0000, null, null, 0, 0)
		, (CONCAT('010009.', @UserId), @UserId, 'HOME', 0, 1, '20190601', '20190531', '20190531', 5000.0000, 0.0000, 5000.0000, 0.0000, null, null, 0, 0)
		, (CONCAT('010010.', @UserId), @UserId, 'HOME', 0, 1, '20190731', '20190731', '20190731', 1000.0000, 0.0000, 1000.0000, 0.0000, null, null, 0, 0)
		, (CONCAT('010011.', @UserId), @UserId, 'CDCUST', 0, 1, '20190822', '20190930', '20190930', 2000, 400, 2000, 400, '30 days end of month following date of invoice', null, 0, 0)
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

		INSERT INTO Invoice.tbTask (InvoiceNumber, TaskCode, Quantity, TotalValue, InvoiceValue, TaxValue, CashCode, TaxCode)
		VALUES (CONCAT('010000.', @UserId), CONCAT(@UserId, '_10007'), 5000, 0.0000, 2000, 400, '103', 'T1')
		, (CONCAT('010001.', @UserId), CONCAT(@UserId, '_10008'), 5000, 0.0000, 2000, 400, '103', 'T1')
		, (CONCAT('010002.', @UserId), CONCAT(@UserId, '_10009'), 5000, 0.0000, 2000, 400, '103', 'T1')
		, (CONCAT('010003.', @UserId), CONCAT(@UserId, '_10010'), 5000, 0.0000, 2000, 400, '103', 'T1')
		, (CONCAT('010004.', @UserId), CONCAT(@UserId, '_10011'), 5000, 0.0000, 2000, 400, '103', 'T1')
		, (CONCAT('010006.', @UserId), CONCAT(@UserId, '_10017'), 5000000, 0.0000, 18500.0000, 3700.0000, '103', 'T1')
		, (CONCAT('010011.', @UserId), CONCAT(@UserId, '_10012'), 5000, 0.0000, 2000, 400, '103', 'T1')
		, (CONCAT('030000.', @UserId), CONCAT(@UserId, '_20010'), 5000, 0.0000, 650.0000, 0.0000, '200', 'T0')
		, (CONCAT('030001.', @UserId), CONCAT(@UserId, '_20011'), 2, 0.0000, 150.0000, 30.0000, '200', 'T1')
		, (CONCAT('030002.', @UserId), CONCAT(@UserId, '_20013'), 5000, 0.0000, 650.0000, 0.0000, '200', 'T0')
		, (CONCAT('030003.', @UserId), CONCAT(@UserId, '_20014'), 2, 0.0000, 150.0000, 30.0000, '200', 'T1')
		, (CONCAT('030004.', @UserId), CONCAT(@UserId, '_20015'), 5000, 0.0000, 650.0000, 0.0000, '200', 'T0')
		, (CONCAT('030005.', @UserId), CONCAT(@UserId, '_20016'), 2, 0.0000, 150.0000, 30.0000, '200', 'T1')
		, (CONCAT('030006.', @UserId), CONCAT(@UserId, '_20017'), 5000, 0.0000, 650.0000, 0.0000, '200', 'T0')
		, (CONCAT('030007.', @UserId), CONCAT(@UserId, '_20018'), 2, 0.0000, 150.0000, 30.0000, '200', 'T1')
		, (CONCAT('030008.', @UserId), CONCAT(@UserId, '_20019'), 5000, 0.0000, 650.0000, 0.0000, '200', 'T0')
		, (CONCAT('030009.', @UserId), CONCAT(@UserId, '_20020'), 2, 0.0000, 150.0000, 30.0000, '200', 'T1')
		, (CONCAT('030010.', @UserId), CONCAT(@UserId, '_40000'), 142, 0.0000, 63.9000, 0.0000, '212', 'T0')
		, (CONCAT('030010.', @UserId), CONCAT(@UserId, '_40003'), 1, 0.0000, 4.0000, 0.8000, '213', 'T1')
		, (CONCAT('030010.', @UserId), CONCAT(@UserId, '_40004'), 4, 0.0000, 16.0000, 0.0000, '205', 'T0')
		, (CONCAT('030011.', @UserId), CONCAT(@UserId, '_40005'), 1, 0.0000, 1000.0000, 0.0000, '402', 'NI1')
		, (CONCAT('030012.', @UserId), CONCAT(@UserId, '_40006'), 1, 0.0000, 1000.0000, 0.0000, '402', 'NI1')
		, (CONCAT('030013.', @UserId), CONCAT(@UserId, '_40007'), 1, 0.0000, 1000.0000, 0.0000, '402', 'NI1')
		, (CONCAT('030014.', @UserId), CONCAT(@UserId, '_40008'), 1, 0.0000, 1000.0000, 0.0000, '402', 'NI1')
		, (CONCAT('030015.', @UserId), CONCAT(@UserId, '_40009'), 1, 0.0000, 1000.0000, 0.0000, '402', 'NI1')
		, (CONCAT('030016.', @UserId), CONCAT(@UserId, '_40010'), 1, 0.0000, 1000.0000, 0.0000, '402', 'NI1')
		, (CONCAT('030017.', @UserId), CONCAT(@UserId, '_20031'), 5000000, 0.0000, 6000.0000, 1200.0000, '200', 'T1')
		, (CONCAT('030018.', @UserId), CONCAT(@UserId, '_20032'), 13, 0.0000, 9750.0000, 1950.0000, '200', 'T1')
		, (CONCAT('030019.', @UserId), CONCAT(@UserId, '_40017'), 185, 0.0000, 83.2500, 0.0000, '212', 'T0')
		, (CONCAT('030019.', @UserId), CONCAT(@UserId, '_40018'), 1, 0.0000, 19.2000, 0.0000, '207', 'T0')
		, (CONCAT('030019.', @UserId), CONCAT(@UserId, '_40019'), 1, 0.0000, 16.0000, 0.0000, '205', 'T0')
		, (CONCAT('030020.', @UserId), CONCAT(@UserId, '_40020'), 178, 0.0000, 80.1000, 0.0000, '212', 'T0')
		, (CONCAT('030020.', @UserId), CONCAT(@UserId, '_40021'), 1, 0.0000, 5.0000, 0.0000, '213', 'T0')
		, (CONCAT('030020.', @UserId), CONCAT(@UserId, '_40022'), 1, 0.0000, 20.0000, 0.0000, '205', 'T0')
		, (CONCAT('030022.', @UserId), CONCAT(@UserId, '_40023'), 340, 0.0000, 153.0000, 0.0000, '212', 'T0')
		, (CONCAT('030022.', @UserId), CONCAT(@UserId, '_40024'), 1, 0.0000, 16.0000, 0.0000, '205', 'T0')
		, (CONCAT('030023.', @UserId), CONCAT(@UserId, '_40025'), 395, 0.0000, 177.7500, 0.0000, '212', 'T0')
		, (CONCAT('030023.', @UserId), CONCAT(@UserId, '_40026'), 1, 0.0000, 18.0000, 3.6000, '209', 'T1')
		, (CONCAT('030023.', @UserId), CONCAT(@UserId, '_40027'), 1, 0.0000, 16.0000, 0.0000, '205', 'T0')
		, (CONCAT('030024.', @UserId), CONCAT(@UserId, '_40028'), 412, 0.0000, 185.4000, 0.0000, '212', 'T0')
		, (CONCAT('030024.', @UserId), CONCAT(@UserId, '_40029'), 1, 0.0000, 5.0000, 1.0000, '213', 'T1')
		, (CONCAT('030024.', @UserId), CONCAT(@UserId, '_40030'), 1, 0.0000, 12.0000, 0.0000, '205', 'T0')
		, (CONCAT('030026.', @UserId), CONCAT(@UserId, '_40031'), 1, 0.0000, 40.0000, 8.0000, '202', 'T1')
		, (CONCAT('030027.', @UserId), CONCAT(@UserId, '_40032'), 1, 0.0000, 39.6000, 7.9200, '202', 'T1')
		, (CONCAT('030028.', @UserId), CONCAT(@UserId, '_40033'), 1, 0.0000, 43.1200, 8.6200, '202', 'T1')
		, (CONCAT('030029.', @UserId), CONCAT(@UserId, '_40034'), 1, 0.0000, 43.5200, 8.7000, '202', 'T1')
		, (CONCAT('030030.', @UserId), CONCAT(@UserId, '_40035'), 1, 0.0000, 42.5200, 8.5000, '202', 'T1')
		, (CONCAT('030031.', @UserId), CONCAT(@UserId, '_40036'), 1, 0.0000, 41.1500, 8.2300, '202', 'T1')
		, (CONCAT('030033.', @UserId), CONCAT(@UserId, '_40037'), 1, 0.0000, 40.0000, 8.0000, '202', 'T1')
		, (CONCAT('030035.', @UserId), CONCAT(@UserId, '_40011'), 1, 0.0000, 1000.0000, 0.0000, '402', 'NI1')
		, (CONCAT('030036.', @UserId), CONCAT(@UserId, '_20021'), 5000, 0.0000, 650.0000, 0.0000, '200', 'T0')
		, (CONCAT('030037.', @UserId), CONCAT(@UserId, '_20022'), 2, 0.0000, 150.0000, 30.0000, '200', 'T1')
		, (CONCAT('030038.', @UserId), CONCAT(@UserId, '_40046'), 12, 0.0000, 54.0000, 10.8000, '209', 'T1')
		;
		INSERT INTO Invoice.tbItem (InvoiceNumber, CashCode, TaxCode, TotalValue, InvoiceValue, TaxValue, ItemReference)
		VALUES (CONCAT('010005.', @UserId), '305', 'N/A', 0.0000, 10000.0000, 0.0000, null)
		, (CONCAT('010007.', @UserId), '305', 'N/A', 0.0000, 15000.0000, 0.0000, null)
		, (CONCAT('010008.', @UserId), '305', 'N/A', 0.0000, 5000.0000, 0.0000, null)
		, (CONCAT('010009.', @UserId), '305', 'N/A', 0.0000, 5000.0000, 0.0000, null)
		, (CONCAT('010010.', @UserId), '305', 'N/A', 0.0000, 1000.0000, 0.0000, null)
		, (CONCAT('030021.', @UserId), '303', 'N/A', 0.0000, 5000.0000, 0.0000, null)
		, (CONCAT('030025.', @UserId), '303', 'N/A', 0.0000, 5000.0000, 0.0000, null)
		, (CONCAT('030034.', @UserId), '303', 'N/A', 0.0000, 1000.0000, 0.0000, null)
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

		DECLARE @CurrentAccount nvarchar(10), @ReserveAccount nvarchar(10);
		EXEC Cash.proc_CurrentAccount @CurrentAccount OUTPUT;
		EXEC Cash.proc_ReserveAccount @ReserveAccount OUTPUT;

		INSERT INTO Cash.tbPayment (PaymentCode, UserId, PaymentStatusCode, AccountCode, CashAccountCode, CashCode, TaxCode, PaidOn, PaidInValue, PaidOutValue, PaymentReference)
		VALUES (CONCAT(@UserId, '_20190008_120000'), @UserId, 1, 'CDCUST', @CurrentAccount, '103', 'T1', '20190228', 2400.0000, 0.0000, CONCAT('010000.', @UserId))
		, (CONCAT(@UserId, '_20190008_120001'), @UserId, 1, 'CDCUST', @CurrentAccount, '103', 'T1', '20190329', 2400.0000, 0.0000, CONCAT('010001.', @UserId))
		, (CONCAT(@UserId, '_20190008_120002'), @UserId, 1, 'CDCUST', @CurrentAccount, '103', 'T1', '20190430', 2400.0000, 0.0000, CONCAT('010002.', @UserId))
		, (CONCAT(@UserId, '_20190008_120003'), @UserId, 1, 'CDCUST', @CurrentAccount, '103', 'T1', '20190531', 2400.0000, 0.0000, CONCAT('010003.', @UserId))
		, (CONCAT(@UserId, '_20190008_120004'), @UserId, 1, 'CDCUST', @CurrentAccount, '103', 'T1', '20190628', 2400.0000, 0.0000, CONCAT('010004.', @UserId))
		, (CONCAT(@UserId, '_20190008_120005'), @UserId, 1, 'SUPTWO', @CurrentAccount, '200', 'T0', '20190228', 0.0000, 650.0000, CONCAT('030000.', @UserId))
		, (CONCAT(@UserId, '_20190008_120006'), @UserId, 1, 'TRACOM', @CurrentAccount, '200', 'T1', '20190228', 0.0000, 180.0000, CONCAT('030001.', @UserId))
		, (CONCAT(@UserId, '_20190008_120007'), @UserId, 1, 'SUPTWO', @CurrentAccount, '200', 'T0', '20190329', 0.0000, 650.0000, CONCAT('030002.', @UserId))
		, (CONCAT(@UserId, '_20190008_120008'), @UserId, 1, 'TRACOM', @CurrentAccount, '200', 'T1', '20190329', 0.0000, 180.0000, CONCAT('030003.', @UserId))
		, (CONCAT(@UserId, '_20190008_120009'), @UserId, 1, 'SUPTWO', @CurrentAccount, '200', 'T0', '20190430', 0.0000, 650.0000, CONCAT('030004.', @UserId))
		, (CONCAT(@UserId, '_20190008_120010'), @UserId, 1, 'TRACOM', @CurrentAccount, '200', 'T1', '20190430', 0.0000, 180.0000, CONCAT('030005.', @UserId))
		, (CONCAT(@UserId, '_20190008_120011'), @UserId, 1, 'SUPTWO', @CurrentAccount, '200', 'T0', '20190430', 0.0000, 650.0000, CONCAT('030006.', @UserId))
		, (CONCAT(@UserId, '_20190008_120012'), @UserId, 1, 'TRACOM', @CurrentAccount, '200', 'T1', '20190531', 0.0000, 180.0000, CONCAT('030007.', @UserId))
		, (CONCAT(@UserId, '_20190008_120013'), @UserId, 1, 'SUPTWO', @CurrentAccount, '200', 'T0', '20190628', 0.0000, 650.0000, CONCAT('030008.', @UserId))
		, (CONCAT(@UserId, '_20190008_120014'), @UserId, 1, 'TRACOM', @CurrentAccount, '200', 'T1', '20190628', 0.0000, 180.0000, CONCAT('030009.', @UserId))
		, (CONCAT(@UserId, '_20190008_120015'), @UserId, 1, 'BUSOWN', @CurrentAccount, '205', 'T0', '20190131', 0.0000, 84.7000, null)
		, (CONCAT(@UserId, '_20190008_120016'), @UserId, 1, 'BUSOWN', @CurrentAccount, '402', 'NI1', '20190131', 0.0000, 1000.0000, null)
		, (CONCAT(@UserId, '_20190008_120017'), @UserId, 1, 'BUSOWN', @CurrentAccount, '402', 'NI1', '20190228', 0.0000, 1000.0000, null)
		, (CONCAT(@UserId, '_20190008_120018'), @UserId, 1, 'BUSOWN', @CurrentAccount, '402', 'NI1', '20190329', 0.0000, 1000.0000, null)
		, (CONCAT(@UserId, '_20190008_120019'), @UserId, 1, 'BUSOWN', @CurrentAccount, '402', 'NI1', '20190430', 0.0000, 1000.0000, null)
		, (CONCAT(@UserId, '_20190008_120020'), @UserId, 1, 'BUSOWN', @CurrentAccount, '402', 'NI1', '20190531', 0.0000, 1000.0000, null)
		, (CONCAT(@UserId, '_20190008_120021'), @UserId, 1, 'BUSOWN', @CurrentAccount, '402', 'NI1', '20190628', 0.0000, 1000.0000, null)
		, (CONCAT(@UserId, '_20190008_120022'), @UserId, 1, 'BUSOWN', @CurrentAccount, '205', 'T0', '20190228', 0.0000, 118.4500, 'Monthly expenses')
		, (CONCAT(@UserId, '_20190008_120023'), @UserId, 1, 'BUSOWN', @CurrentAccount, '205', 'T0', '20190329', 0.0000, 105.1000, 'Monthly expenses')
		, (CONCAT(@UserId, '_20190008_120024'), @UserId, 1, 'SUPTWO', @CurrentAccount, '200', 'T1', '20190430', 0.0000, 7200.0000, CONCAT('030017.', @UserId))
		, (CONCAT(@UserId, '_20190008_120025'), @UserId, 1, 'BUSOWN', @CurrentAccount, '205', 'T0', '20190430', 0.0000, 169.0000, 'Monthly expenses')
		, (CONCAT(@UserId, '_20190008_120026'), @UserId, 1, 'EFCUST', @CurrentAccount, '103', 'T1', '20190518', 22200.0000, 0.0000, null)
		, (CONCAT(@UserId, '_20190008_120027'), @UserId, 1, 'THEPAP', @CurrentAccount, '200', 'T1', '20190518', 0.0000, 11700.0000, null)
		, (CONCAT(@UserId, '_20190008_120028'), @UserId, 1, 'BUSOWN', @CurrentAccount, '205', 'T0', '20190708', 0.0000, 215.3500, 'Monthly expenses')
		, (CONCAT(@UserId, '_20190008_120029'), @UserId, 1, 'BUSOWN', @CurrentAccount, '205', 'T0', '20190708', 0.0000, 203.4000, 'Monthly expenses')
		, (CONCAT(@UserId, '_20190019_120000'), @UserId, 1, 'TELPRO', @CurrentAccount, '202', 'T1', '20190125', 0.0000, 48.0000, CONCAT('030026.', @UserId))
		, (CONCAT(@UserId, '_20190019_120001'), @UserId, 1, 'TELPRO', @CurrentAccount, '202', 'T1', '20190226', 0.0000, 47.5200, CONCAT('030027.', @UserId))
		, (CONCAT(@UserId, '_20190019_120002'), @UserId, 1, 'TELPRO', @CurrentAccount, '202', 'T1', '20190326', 0.0000, 51.7400, CONCAT('030028.', @UserId))
		, (CONCAT(@UserId, '_20190019_120003'), @UserId, 1, 'TELPRO', @CurrentAccount, '202', 'T1', '20190426', 0.0000, 52.2200, CONCAT('030029.', @UserId))
		, (CONCAT(@UserId, '_20190019_120004'), @UserId, 1, 'TELPRO', @CurrentAccount, '202', 'T1', '20190526', 0.0000, 51.0200, CONCAT('030030.', @UserId))
		, (CONCAT(@UserId, '_20190019_120005'), @UserId, 1, 'TELPRO', @CurrentAccount, '202', 'T1', '20190626', 0.0000, 49.3800, CONCAT('030031.', @UserId))
		, (CONCAT(@UserId, '_20190022_120000'), @UserId, 1, 'TELPRO', @CurrentAccount, '202', 'T1', '20190726', 0.0000, 48.0000, CONCAT('030033.', @UserId))
		, (CONCAT(@UserId, '_20190022_120001'), @UserId, 1, 'BUSOWN', @CurrentAccount, '402', 'NI1', '20190731', 0.0000, 1000.0000, CONCAT('030035.', @UserId))
		, (CONCAT(@UserId, '_20190022_120002'), @UserId, 1, 'CDCUST', @CurrentAccount, '103', 'T1', '20190731', 2400.0000, 0.0000, CONCAT('010011.', @UserId))
		, (CONCAT(@UserId, '_20190022_120003'), @UserId, 1, 'SUPTWO', @CurrentAccount, '200', 'T0', '20190731', 0.0000, 650.0000, CONCAT('030036.', @UserId))
		, (CONCAT(@UserId, '_20190022_120004'), @UserId, 1, 'TRACOM', @CurrentAccount, '200', 'T1', '20190731', 0.0000, 180.0000, CONCAT('030037.', @UserId))
		, (CONCAT(@UserId, '_20190022_120005'), @UserId, 1, 'SUNSUP', @CurrentAccount, '209', 'T1', '20190702', 0.0000, 64.8000, null)
		, (CONCAT(@UserId, '_20190608_030639'), @UserId, 1, 'HOME', @ReserveAccount, '305', 'N/A', '20190101', 15000.0000, 0.0000, 'Opening balance')
		, (CONCAT(@UserId, '_20190708_030716'), @UserId, 1, 'HOME', @ReserveAccount, '303', 'N/A', '20190415', 0.0000, 5000.0000, 'Transfer to current account')
		, (CONCAT(@UserId, '_20190708_030747'), @UserId, 1, 'HOME', @CurrentAccount, '305', 'N/A', '20190415', 5000.0000, 0.0000, 'Transfer from Reserve Account')
		, (CONCAT(@UserId, '_20191822_121834'), @UserId, 2, 'HOME', @CurrentAccount, '303', 'N/A', '20190831', 0.0000, 5000.0000, 'Transfer to Reserve account')
		, (CONCAT(@UserId, '_20191822_121848'), @UserId, 2, 'HOME', @ReserveAccount, '305', 'N/A', '20190831', 5000.0000, 0.0000, 'Transfer from current account')
		, (CONCAT(@UserId, '_20192408_042438'), @UserId, 1, 'HOME', @CurrentAccount, '303', 'N/A', '20190601', 0.0000, 5000.0000, 'Transfer to Reserve Account')
		, (CONCAT(@UserId, '_20192508_042502'), @UserId, 1, 'HOME', @ReserveAccount, '305', 'N/A', '20190601', 5000.0000, 0.0000, 'Transfer from Current Account')
		, (CONCAT(@UserId, '_20194708_014729'), @UserId, 1, 'HOME', @CurrentAccount, '305', 'N/A', '20190101', 10000.0000, 0.0000, 'Opening Balance')
		, (CONCAT(@UserId, '_20195222_125225'), @UserId, 1, 'HOME', @CurrentAccount, '303', 'N/A', '20190731', 0.0000, 1000.0000, 'Transfer to Reserve account')
		, (CONCAT(@UserId, '_20195322_125307'), @UserId, 1, 'HOME', @ReserveAccount, '305', 'N/A', '20190731', 1000.0000, 0.0000, 'Transfer from current account')
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
ALTER PROCEDURE Cash.proc_PaymentAdd(@AccountCode nvarchar(10), @CashAccountCode AS nvarchar(10), @CashCode nvarchar(50), @PaidOn datetime, @ToPay decimal(18, 5), @PaymentReference nvarchar(50) = null, @PaymentCode nvarchar(20) output)
AS
	SET NOCOUNT, XACT_ABORT ON;
	BEGIN TRY
		
		EXECUTE Cash.proc_NextPaymentCode  @PaymentCode OUTPUT

		INSERT INTO Cash.tbPayment (PaymentCode, UserId, PaymentStatusCode, AccountCode, CashAccountCode, CashCode, TaxCode, PaidOn, PaidInValue, PaidOutValue, PaymentReference)
		SELECT   @PaymentCode AS PaymentCode, 
			(SELECT UserId FROM Usr.vwCredentials) AS UserId,
			0 AS PaymentStatusCode,
			@AccountCode AS AccountCode,
			@CashAccountCode AS CashAccountCode,
			@CashCode AS CashCode,
			Cash.tbCode.TaxCode,
			@PaidOn As PaidOn,
			CASE WHEN @ToPay > 0 THEN @ToPay ELSE 0 END AS PaidInValue,
			CASE WHEN @ToPay < 0 THEN ABS(@ToPay) ELSE 0 END AS PaidOutValue,
			@PaymentReference PaymentReference
		FROM Cash.tbCode 
			INNER JOIN Cash.tbCategory ON Cash.tbCode.CategoryCode = Cash.tbCategory.CategoryCode 
		WHERE        (Cash.tbCode.CashCode = @CashCode)


	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
go
ALTER PROCEDURE Cash.proc_PaymentPostMisc
	(
	@PaymentCode nvarchar(20) 
	)
 AS
 	SET NOCOUNT, XACT_ABORT ON;

	BEGIN TRY
		DECLARE 
			@InvoiceNumber nvarchar(20), 
			@NextNumber int, 
			@InvoiceTypeCode smallint;

		IF NOT EXISTS (SELECT        Cash.tbPayment.PaymentCode
						FROM            Cash.tbPayment INNER JOIN
												 Cash.tbCode ON Cash.tbPayment.CashCode = Cash.tbCode.CashCode INNER JOIN
												 Cash.tbCategory ON Cash.tbCode.CategoryCode = Cash.tbCategory.CategoryCode
						WHERE        (Cash.tbPayment.PaymentStatusCode <> 1)  
							AND Cash.tbPayment.UserId = (SELECT UserId FROM Usr.vwCredentials))
			RETURN 

		SELECT @InvoiceTypeCode = CASE WHEN PaidInValue != 0 THEN 0 ELSE 2 END 
		FROM         Cash.tbPayment
		WHERE     (PaymentCode = @PaymentCode)
	
		SELECT @NextNumber = NextNumber
		FROM Invoice.tbType
		WHERE InvoiceTypeCode = @InvoiceTypeCode;
		
		SET @InvoiceNumber = FORMAT(@NextNumber, '000000') + '.' + (SELECT UserId FROM Usr.vwCredentials)

		WHILE EXISTS (SELECT     InvoiceNumber
					  FROM         Invoice.tbInvoice
					  WHERE     (InvoiceNumber = @InvoiceNumber))
			BEGIN
			SET @NextNumber += @NextNumber 
			SET @InvoiceNumber = FORMAT(@NextNumber, '000000') + '.' + (SELECT UserId FROM Usr.vwCredentials)
			END
		
		BEGIN TRANSACTION

		UPDATE    Invoice.tbType
		SET              NextNumber = @NextNumber + 1
		WHERE     (InvoiceTypeCode = @InvoiceTypeCode);

		WITH payment AS
		(
			SELECT UserId, AccountCode, PaidOn, PaidInValue, PaidOutValue,
					CASE TaxRate WHEN 0 THEN 0
					ELSE
					(
						CASE App.tbTaxCode.RoundingCode 
							WHEN 0 THEN ROUND(Cash.tbPayment.PaidInValue - ( Cash.tbPayment.PaidInValue / (1 + App.tbTaxCode.TaxRate)), Decimals) 
							WHEN 1 THEN ROUND(Cash.tbPayment.PaidInValue - ( Cash.tbPayment.PaidInValue / (1 + App.tbTaxCode.TaxRate)), Decimals, 1) 
						END
					)
					END TaxInValue, 			 
					CASE TaxRate WHEN 0 THEN 0
					ELSE
					(
						CASE App.tbTaxCode.RoundingCode 
							WHEN 0 THEN ROUND(Cash.tbPayment.PaidOutValue - ( Cash.tbPayment.PaidOutValue / (1 + App.tbTaxCode.TaxRate)), Decimals) 
							WHEN 1 THEN ROUND(Cash.tbPayment.PaidOutValue - ( Cash.tbPayment.PaidOutValue / (1 + App.tbTaxCode.TaxRate)), Decimals, 1) 
						END
					)
					END TaxOutValue
			FROM Cash.tbPayment
				INNER JOIN App.tbTaxCode ON Cash.tbPayment.TaxCode = App.tbTaxCode.TaxCode
			WHERE     (PaymentCode = @PaymentCode)
		)
		INSERT INTO Invoice.tbInvoice
								 (InvoiceNumber, UserId, AccountCode, InvoiceTypeCode, InvoiceStatusCode, InvoicedOn, DueOn, ExpectedOn, InvoiceValue, TaxValue, PaidValue, PaidTaxValue, Printed)
		SELECT        @InvoiceNumber AS InvoiceNumber, payment.UserId, payment.AccountCode, @InvoiceTypeCode AS InvoiceTypeCode, 3 AS InvoiceStatusCode, 
								payment.PaidOn, payment.PaidOn AS DueOn, payment.PaidOn AS ExpectedOn,
								CASE WHEN PaidInValue > 0 THEN PaidInValue - TaxInValue
									WHEN PaidOutValue > 0 THEN PaidOutValue - TaxOutValue
								END AS InvoiceValue, 
								CASE WHEN payment.PaidInValue > 0 THEN payment.TaxInValue 
									WHEN payment.PaidOutValue > 0 THEN payment.TaxOutValue
								END AS TaxValue, 
								CASE WHEN PaidInValue > 0 THEN PaidInValue - TaxInValue
									WHEN PaidOutValue > 0 THEN PaidOutValue - TaxOutValue
								END AS PaidValue, 
								CASE WHEN payment.PaidInValue > 0 THEN payment.TaxInValue 
									WHEN payment.PaidOutValue > 0 THEN payment.TaxOutValue
								END AS PaidTaxValue, 
								1 AS Printed
		FROM payment;

		WITH payment AS
		(
			SELECT CashCode, TaxCode
			FROM Cash.tbPayment
			WHERE (Cash.tbPayment.PaymentCode = @PaymentCode)
		), invoice_header AS
		(
			SELECT InvoiceNumber, InvoiceValue, TaxValue
			FROM Invoice.tbInvoice
			WHERE InvoiceNumber = @InvoiceNumber
		)
		INSERT INTO Invoice.tbItem
							(InvoiceNumber, CashCode, InvoiceValue, TaxValue, TaxCode)
		SELECT TOP 1 InvoiceNumber, CashCode, InvoiceValue, TaxValue, TaxCode
		FROM payment
			CROSS JOIN invoice_header;

		UPDATE  Org.tbAccount
		SET CurrentBalance = CASE WHEN PaidInValue > 0 THEN Org.tbAccount.CurrentBalance + PaidInValue ELSE Org.tbAccount.CurrentBalance - PaidOutValue END
		FROM         Org.tbAccount INNER JOIN
							  Cash.tbPayment ON Org.tbAccount.CashAccountCode = Cash.tbPayment.CashAccountCode
		WHERE Cash.tbPayment.PaymentCode = @PaymentCode

		UPDATE Cash.tbPayment
		SET PaymentStatusCode = 1
		WHERE (PaymentCode = @PaymentCode)

		COMMIT TRANSACTION

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
			, @PostValue decimal(18, 5);

		SELECT   @PostValue = CASE WHEN PaidInValue = 0 THEN PaidOutValue ELSE PaidInValue * -1 END,
			@AccountCode = Org.tbOrg.AccountCode
		FROM         Cash.tbPayment INNER JOIN
							  Org.tbOrg ON Cash.tbPayment.AccountCode = Org.tbOrg.AccountCode
		WHERE     ( Cash.tbPayment.PaymentCode = @PaymentCode);

		BEGIN TRANSACTION;

		UPDATE Cash.tbPayment
		SET PaymentStatusCode = 1
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
DROP PROCEDURE IF EXISTS Cash.proc_PaymentPostPaidIn;
DROP PROCEDURE IF EXISTS Cash.proc_PaymentPostPaidOut;
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
go
ALTER PROCEDURE Org.proc_Rebuild(@AccountCode NVARCHAR(10))
AS
  	SET NOCOUNT, XACT_ABORT ON;

	DECLARE @PaymentCode nvarchar(20);

	BEGIN TRY
		BEGIN TRANSACTION;

		UPDATE Invoice.tbItem
		SET 
			InvoiceValue =  ROUND(Invoice.tbItem.TotalValue / (1 + App.tbTaxCode.TaxRate), Decimals)
		FROM         Invoice.tbItem INNER JOIN
								App.tbTaxCode ON Invoice.tbItem.TaxCode = App.tbTaxCode.TaxCode INNER JOIN
								Invoice.tbInvoice ON Invoice.tbItem.InvoiceNumber = Invoice.tbInvoice.InvoiceNumber
		WHERE     ( Invoice.tbInvoice.InvoiceStatusCode <> 0) AND Invoice.tbItem.TotalValue <> 0
			AND (Invoice.tbInvoice.AccountCode = @AccountCode);

		UPDATE Invoice.tbItem
		SET TaxValue = CASE App.tbTaxCode.RoundingCode 
				WHEN 0 THEN ROUND(Invoice.tbItem.InvoiceValue * App.tbTaxCode.TaxRate, Decimals)
				WHEN 1 THEN ROUND( Invoice.tbItem.InvoiceValue * App.tbTaxCode.TaxRate, Decimals, 1) END
		FROM         Invoice.tbItem INNER JOIN
								App.tbTaxCode ON Invoice.tbItem.TaxCode = App.tbTaxCode.TaxCode 
								INNER JOIN Invoice.tbInvoice ON Invoice.tbItem.InvoiceNumber = Invoice.tbInvoice.InvoiceNumber
		WHERE     ( Invoice.tbInvoice.InvoiceStatusCode <> 0)
			AND (Invoice.tbInvoice.AccountCode = @AccountCode);
                   
		UPDATE Invoice.tbTask
		SET InvoiceValue =  ROUND(Invoice.tbTask.TotalValue / (1 + App.tbTaxCode.TaxRate), Decimals)
		FROM         Invoice.tbTask INNER JOIN
								App.tbTaxCode ON Invoice.tbTask.TaxCode = App.tbTaxCode.TaxCode INNER JOIN
								Invoice.tbInvoice ON Invoice.tbTask.InvoiceNumber = Invoice.tbInvoice.InvoiceNumber
		WHERE     ( Invoice.tbInvoice.InvoiceStatusCode <> 0) AND Invoice.tbTask.TotalValue <> 0
			AND (Invoice.tbInvoice.AccountCode = @AccountCode);

		UPDATE Invoice.tbTask
		SET TaxValue = CASE App.tbTaxCode.RoundingCode 
				WHEN 0 THEN ROUND(Invoice.tbTask.InvoiceValue * App.tbTaxCode.TaxRate, Decimals)
				WHEN 1 THEN ROUND( Invoice.tbTask.InvoiceValue * App.tbTaxCode.TaxRate, Decimals, 1) END,
			InvoiceValue = CASE WHEN Invoice.tbTask.TotalValue = 0 
								THEN Invoice.tbTask.InvoiceValue 
								ELSE ROUND(Invoice.tbTask.TotalValue / (1 + App.tbTaxCode.TaxRate), 2) 
							END
		FROM         Invoice.tbTask INNER JOIN
								App.tbTaxCode ON Invoice.tbTask.TaxCode = App.tbTaxCode.TaxCode 
								INNER JOIN Invoice.tbInvoice ON Invoice.tbTask.InvoiceNumber = Invoice.tbInvoice.InvoiceNumber
		WHERE     ( Invoice.tbInvoice.InvoiceStatusCode <> 0)
			AND (Invoice.tbInvoice.AccountCode = @AccountCode);
						   	
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
		WHERE AccountCode = @AccountCode AND (InvoiceValue <> TotalInvoiceValue OR TaxValue <> TotalTaxValue);



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

		COMMIT TRANSACTION

		DECLARE @Msg NVARCHAR(MAX);
		SELECT @Msg = CONCAT(@AccountCode, ' ', Message) FROM App.tbText WHERE TextId = 3006;
		EXEC App.proc_EventLog @EventMessage = @Msg, @EventTypeCode = 2;

  	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
go
ALTER TRIGGER Invoice.Invoice_tbTask_TriggerInsert
ON Invoice.tbTask
FOR INSERT, UPDATE
AS
	SET NOCOUNT ON;

	BEGIN TRY

		UPDATE task
		SET InvoiceValue = inserted.TotalValue / (1 + TaxRate),
			TaxValue = inserted.TotalValue - inserted.TotalValue / (1 + TaxRate)
		FROM inserted 
			INNER JOIN Invoice.tbTask task ON inserted.InvoiceNumber = task.InvoiceNumber 
					AND inserted.TaskCode = task.TaskCode
				INNER JOIN App.tbTaxCode ON inserted.TaxCode = App.tbTaxCode.TaxCode 
		WHERE inserted.TotalValue <> 0;

		UPDATE task
		SET TaxValue = CASE App.tbTaxCode.RoundingCode 
				WHEN 0 THEN ROUND(task.InvoiceValue * App.tbTaxCode.TaxRate, Decimals)
				WHEN 1 THEN ROUND(task.InvoiceValue * App.tbTaxCode.TaxRate, Decimals, 1) 
			END
		FROM Invoice.tbTask task 
			INNER JOIN inserted ON inserted.InvoiceNumber = task.InvoiceNumber
					 AND inserted.TaskCode = task.TaskCode
				INNER JOIN App.tbTaxCode ON task.TaxCode = App.tbTaxCode.TaxCode
		WHERE inserted.TotalValue = 0; 

	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
go
ALTER TRIGGER Invoice.Invoice_tbItem_TriggerInsert
ON Invoice.tbItem
FOR INSERT, UPDATE
AS
	SET NOCOUNT ON;

	BEGIN TRY

		UPDATE item
		SET InvoiceValue = inserted.TotalValue / (1 + TaxRate),
			TaxValue = inserted.TotalValue - inserted.TotalValue / (1 + TaxRate)
		FROM inserted 
			INNER JOIN Invoice.tbItem item ON inserted.InvoiceNumber = item.InvoiceNumber 
					AND inserted.CashCode = item.CashCode
				INNER JOIN App.tbTaxCode ON inserted.TaxCode = App.tbTaxCode.TaxCode 
		WHERE inserted.TotalValue <> 0;

		UPDATE item
		SET TaxValue = CASE App.tbTaxCode.RoundingCode 
				WHEN 0 THEN ROUND(item.InvoiceValue * App.tbTaxCode.TaxRate, Decimals)
				WHEN 1 THEN ROUND(item.InvoiceValue * App.tbTaxCode.TaxRate, Decimals, 1) 
			END
		FROM Invoice.tbItem item 
			INNER JOIN inserted ON inserted.InvoiceNumber = item.InvoiceNumber
					 AND inserted.CashCode = item.CashCode
				INNER JOIN App.tbTaxCode ON item.TaxCode = App.tbTaxCode.TaxCode
		WHERE inserted.TotalValue = 0; 

	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
go
ALTER VIEW Invoice.vwRegisterItems
AS
	SELECT       (SELECT TOP (1) p.StartOn FROM App.tbYearPeriod p WHERE (p.StartOn <= Invoice.tbInvoice.InvoicedOn) ORDER BY p.StartOn DESC) AS StartOn,  
					Invoice.tbInvoice.InvoiceNumber, Invoice.tbItem.CashCode AS TaskCode, Cash.tbCode.CashCode, Cash.tbCode.CashDescription, 
							 Invoice.tbItem.TaxCode, App.tbTaxCode.TaxDescription, Invoice.tbInvoice.AccountCode, Invoice.tbInvoice.InvoiceTypeCode, Invoice.tbInvoice.InvoiceStatusCode, Invoice.tbInvoice.InvoicedOn, 
							 CASE WHEN Invoice.tbType.CashModeCode = 0 THEN Invoice.tbItem.InvoiceValue * - 1 ELSE Invoice.tbItem.InvoiceValue END AS InvoiceValue, 
							 CASE WHEN Invoice.tbType.CashModeCode = 0 THEN Invoice.tbItem.TaxValue * - 1 ELSE Invoice.tbItem.TaxValue END AS TaxValue, 
							 Invoice.tbInvoice.PaymentTerms, Invoice.tbInvoice.Printed, 
							 Org.tbOrg.AccountName, Usr.tbUser.UserName, Invoice.tbStatus.InvoiceStatus, Invoice.tbType.CashModeCode, Invoice.tbType.InvoiceType
	FROM            Invoice.tbInvoice INNER JOIN
							 Org.tbOrg ON Invoice.tbInvoice.AccountCode = Org.tbOrg.AccountCode INNER JOIN
							 Invoice.tbType ON Invoice.tbInvoice.InvoiceTypeCode = Invoice.tbType.InvoiceTypeCode INNER JOIN
							 Invoice.tbStatus ON Invoice.tbInvoice.InvoiceStatusCode = Invoice.tbStatus.InvoiceStatusCode INNER JOIN
							 Usr.tbUser ON Invoice.tbInvoice.UserId = Usr.tbUser.UserId INNER JOIN
							 Invoice.tbItem ON Invoice.tbInvoice.InvoiceNumber = Invoice.tbItem.InvoiceNumber INNER JOIN
							 Cash.tbCode ON Invoice.tbItem.CashCode = Cash.tbCode.CashCode LEFT OUTER JOIN
							 App.tbTaxCode ON Invoice.tbItem.TaxCode = App.tbTaxCode.TaxCode;
go
ALTER VIEW Invoice.vwRegisterTasks
AS
	SELECT (SELECT TOP (1) p.StartOn FROM App.tbYearPeriod p WHERE (p.StartOn <= Invoice.tbInvoice.InvoicedOn) ORDER BY p.StartOn DESC) AS StartOn,  
			Invoice.tbInvoice.InvoiceNumber, InvoiceTask.TaskCode, Task.TaskTitle, Cash.tbCode.CashCode, Cash.tbCode.CashDescription, 
							 InvoiceTask.TaxCode, App.tbTaxCode.TaxDescription, Invoice.tbInvoice.AccountCode, Invoice.tbInvoice.InvoiceTypeCode, Invoice.tbInvoice.InvoiceStatusCode, 
							 Invoice.tbInvoice.InvoicedOn, InvoiceTask.Quantity,
							 CASE WHEN Invoice.tbType.CashModeCode = 0 THEN InvoiceTask.InvoiceValue * - 1 ELSE InvoiceTask.InvoiceValue END AS InvoiceValue, 
							 CASE WHEN Invoice.tbType.CashModeCode = 0 THEN InvoiceTask.TaxValue * - 1 ELSE InvoiceTask.TaxValue END AS TaxValue, 
							 Invoice.tbInvoice.PaymentTerms, Invoice.tbInvoice.Printed, 
							 Org.tbOrg.AccountName, Usr.tbUser.UserName, Invoice.tbStatus.InvoiceStatus, Invoice.tbType.CashModeCode, Invoice.tbType.InvoiceType
	FROM            Invoice.tbInvoice INNER JOIN
							 Org.tbOrg ON Invoice.tbInvoice.AccountCode = Org.tbOrg.AccountCode INNER JOIN
							 Invoice.tbType ON Invoice.tbInvoice.InvoiceTypeCode = Invoice.tbType.InvoiceTypeCode INNER JOIN
							 Invoice.tbStatus ON Invoice.tbInvoice.InvoiceStatusCode = Invoice.tbStatus.InvoiceStatusCode INNER JOIN
							 Usr.tbUser ON Invoice.tbInvoice.UserId = Usr.tbUser.UserId INNER JOIN
							 Invoice.tbTask AS InvoiceTask ON Invoice.tbInvoice.InvoiceNumber = InvoiceTask.InvoiceNumber INNER JOIN
							 Cash.tbCode ON InvoiceTask.CashCode = Cash.tbCode.CashCode INNER JOIN
							 Task.tbTask AS Task ON InvoiceTask.TaskCode = Task.TaskCode AND InvoiceTask.TaskCode = Task.TaskCode LEFT OUTER JOIN
							 App.tbTaxCode ON InvoiceTask.TaxCode = App.tbTaxCode.TaxCode;
go
ALTER VIEW Invoice.vwRegisterDetail
AS
	WITH register AS
	(
		SELECT     StartOn, InvoiceNumber, TaskCode, CashCode, CashDescription, TaxCode, TaxDescription, AccountCode, InvoiceTypeCode, InvoiceStatusCode, 
							  InvoicedOn, Quantity, InvoiceValue, TaxValue, PaymentTerms, Printed, AccountName, UserName, InvoiceStatus, CashModeCode, 
							  InvoiceType
		FROM         Invoice.vwRegisterTasks
		UNION
		SELECT     StartOn, InvoiceNumber, TaskCode, CashCode, CashDescription, TaxCode, TaxDescription, AccountCode, InvoiceTypeCode, InvoiceStatusCode, 
							  InvoicedOn, 0 Quantity, InvoiceValue, TaxValue, PaymentTerms, Printed, AccountName, UserName, InvoiceStatus, CashModeCode, 
							  InvoiceType
		FROM         Invoice.vwRegisterItems
	)
	SELECT StartOn, InvoiceNumber, TaskCode, CashCode, CashDescription, TaxCode, TaxDescription, AccountCode, InvoiceTypeCode, InvoiceStatusCode, InvoicedOn, PaymentTerms, Printed, AccountName, UserName, InvoiceStatus, CashModeCode, InvoiceType,
		CAST(Quantity as float) Quantity, CAST(InvoiceValue as float) InvoiceValue, CAST(TaxValue as float) TaxValue
	FROM register;
go
ALTER VIEW Invoice.vwHistoryPurchaseItems
AS
	SELECT        CONCAT(App.tbMonth.MonthName, SPACE(1), YEAR(App.tbYearPeriod.StartOn)) AS PeriodName, App.tbYearPeriod.YearNumber, Invoice.vwRegisterDetail.StartOn, Invoice.vwRegisterDetail.InvoiceNumber, 
							 Invoice.vwRegisterDetail.TaskCode, Invoice.vwRegisterDetail.CashCode, Invoice.vwRegisterDetail.CashDescription, Invoice.vwRegisterDetail.TaxCode, Invoice.vwRegisterDetail.TaxDescription, 
							 Invoice.vwRegisterDetail.AccountCode, Invoice.vwRegisterDetail.InvoiceTypeCode, Invoice.vwRegisterDetail.InvoiceStatusCode, Invoice.vwRegisterDetail.InvoicedOn, Invoice.vwRegisterDetail.InvoiceValue, 
							 Invoice.vwRegisterDetail.TaxValue, Invoice.vwRegisterDetail.PaymentTerms, Invoice.vwRegisterDetail.Printed, 
							 Invoice.vwRegisterDetail.AccountName, Invoice.vwRegisterDetail.UserName, Invoice.vwRegisterDetail.InvoiceStatus, Invoice.vwRegisterDetail.CashModeCode, Invoice.vwRegisterDetail.InvoiceType
	FROM            Invoice.vwRegisterDetail INNER JOIN
							 App.tbYearPeriod ON Invoice.vwRegisterDetail.StartOn = App.tbYearPeriod.StartOn INNER JOIN
							 App.tbYear ON App.tbYearPeriod.YearNumber = App.tbYear.YearNumber INNER JOIN
							 App.tbMonth ON App.tbYearPeriod.MonthNumber = App.tbMonth.MonthNumber
	WHERE        (Invoice.vwRegisterDetail.InvoiceTypeCode > 1);
go
ALTER VIEW Invoice.vwHistorySalesItems
AS
	SELECT        App.tbYearPeriod.YearNumber, CONCAT(App.tbMonth.MonthName, SPACE(1), YEAR(App.tbYearPeriod.StartOn)) AS PeriodName, Invoice.vwRegisterDetail.StartOn, Invoice.vwRegisterDetail.InvoiceNumber, 
							 Invoice.vwRegisterDetail.TaskCode, Invoice.vwRegisterDetail.CashCode, Invoice.vwRegisterDetail.CashDescription, Invoice.vwRegisterDetail.TaxCode, Invoice.vwRegisterDetail.AccountCode, Invoice.vwRegisterDetail.InvoicedOn, 
							 Invoice.vwRegisterDetail.InvoiceValue, Invoice.vwRegisterDetail.TaxValue, Invoice.vwRegisterDetail.PaymentTerms, 
							 Invoice.vwRegisterDetail.AccountName, Invoice.vwRegisterDetail.InvoiceStatus, Invoice.vwRegisterDetail.InvoiceType, Invoice.vwRegisterDetail.InvoiceTypeCode, 
							 Invoice.vwRegisterDetail.InvoiceStatusCode
	FROM            Invoice.vwRegisterDetail INNER JOIN
							 App.tbYearPeriod ON Invoice.vwRegisterDetail.StartOn = App.tbYearPeriod.StartOn INNER JOIN
							 App.tbYear ON App.tbYearPeriod.YearNumber = App.tbYear.YearNumber INNER JOIN
							 App.tbMonth ON App.tbYearPeriod.MonthNumber = App.tbMonth.MonthNumber
	WHERE        (Invoice.vwRegisterDetail.InvoiceTypeCode < 2);
go
ALTER VIEW Invoice.vwRegisterPurchaseTasks
AS
	SELECT        StartOn, InvoiceNumber, TaskCode, CashCode, CashDescription, TaxCode, TaxDescription, AccountCode, InvoiceTypeCode, InvoiceStatusCode, InvoicedOn, InvoiceValue, TaxValue
							 PaymentTerms, Printed, AccountName, UserName, InvoiceStatus, CashModeCode, InvoiceType
	FROM            Invoice.vwRegisterDetail
	WHERE        (InvoiceTypeCode > 1);
go
ALTER VIEW Invoice.vwRegisterSaleTasks
AS
	SELECT        StartOn, InvoiceNumber, TaskCode, CashCode, CashDescription, TaxCode, TaxDescription, AccountCode, InvoiceTypeCode, InvoiceStatusCode, InvoicedOn, InvoiceValue, TaxValue
							 PaymentTerms, Printed, AccountName, UserName, InvoiceStatus, CashModeCode, InvoiceType
	FROM            Invoice.vwRegisterDetail
	WHERE        (InvoiceTypeCode < 2);
go
ALTER VIEW Org.vwSalesInvoices
AS
	SELECT        Invoice.tbInvoice.AccountCode, tbInvoiceTask.InvoiceNumber, tbInvoiceTask.TaskCode, Task.tbTask.ContactName, Invoice.tbInvoice.InvoicedOn, tbInvoiceTask.Quantity, tbInvoiceTask.InvoiceValue, tbInvoiceTask.TaxValue, 
							 tbInvoiceTask.CashCode, tbInvoiceTask.TaxCode, Invoice.tbStatus.InvoiceStatus, Task.tbTask.TaskNotes, Cash.tbCode.CashDescription, Invoice.tbInvoice.InvoiceStatusCode, Task.tbTask.TaskTitle, Org.tbOrg.AccountName, 
							 Invoice.tbInvoice.InvoiceTypeCode, Invoice.tbType.InvoiceType, Invoice.tbInvoice.PaidTaxValue, Invoice.tbInvoice.PaidValue
	FROM            Invoice.tbInvoice INNER JOIN
							 Invoice.tbTask AS tbInvoiceTask ON Invoice.tbInvoice.InvoiceNumber = tbInvoiceTask.InvoiceNumber INNER JOIN
							 Task.tbTask ON tbInvoiceTask.TaskCode = Task.tbTask.TaskCode INNER JOIN
							 Cash.tbCode ON tbInvoiceTask.CashCode = Cash.tbCode.CashCode INNER JOIN
							 Invoice.tbStatus ON Invoice.tbInvoice.InvoiceStatusCode = Invoice.tbStatus.InvoiceStatusCode INNER JOIN
							 Org.tbOrg ON Invoice.tbInvoice.AccountCode = Org.tbOrg.AccountCode INNER JOIN
							 Invoice.tbType ON Invoice.tbInvoice.InvoiceTypeCode = Invoice.tbType.InvoiceTypeCode
	WHERE        (Invoice.tbInvoice.InvoiceStatusCode > 0) AND (Invoice.tbInvoice.InvoiceTypeCode = 0)
go
ALTER VIEW Org.vwPurchaseInvoices
AS
	SELECT        Invoice.tbInvoice.AccountCode, tbInvoiceTask.InvoiceNumber, tbInvoiceTask.TaskCode, Task.tbTask.ContactName, Invoice.tbInvoice.InvoicedOn, tbInvoiceTask.Quantity, tbInvoiceTask.InvoiceValue, tbInvoiceTask.TaxValue, 
							 tbInvoiceTask.CashCode, tbInvoiceTask.TaxCode, Invoice.tbStatus.InvoiceStatus, Task.tbTask.TaskNotes, Cash.tbCode.CashDescription, Invoice.tbInvoice.InvoiceStatusCode, Task.tbTask.TaskTitle, Org.tbOrg.AccountName, 
							 Invoice.tbInvoice.InvoiceTypeCode, Invoice.tbType.InvoiceType, Invoice.tbInvoice.PaidValue, Invoice.tbInvoice.PaidTaxValue
	FROM            Invoice.tbInvoice INNER JOIN
							 Invoice.tbTask AS tbInvoiceTask ON Invoice.tbInvoice.InvoiceNumber = tbInvoiceTask.InvoiceNumber INNER JOIN
							 Task.tbTask ON tbInvoiceTask.TaskCode = Task.tbTask.TaskCode INNER JOIN
							 Cash.tbCode ON tbInvoiceTask.CashCode = Cash.tbCode.CashCode INNER JOIN
							 Invoice.tbStatus ON Invoice.tbInvoice.InvoiceStatusCode = Invoice.tbStatus.InvoiceStatusCode INNER JOIN
							 Org.tbOrg ON Invoice.tbInvoice.AccountCode = Org.tbOrg.AccountCode INNER JOIN
							 Invoice.tbType ON Invoice.tbInvoice.InvoiceTypeCode = Invoice.tbType.InvoiceTypeCode
	WHERE        (Invoice.tbInvoice.InvoiceStatusCode > 0) AND (Invoice.tbInvoice.InvoiceTypeCode > 1)
go
ALTER VIEW Org.vwInvoiceItems
AS
SELECT        Invoice.tbInvoice.AccountCode, Invoice.tbItem.InvoiceNumber, Invoice.tbItem.CashCode, Invoice.tbInvoice.InvoicedOn, Invoice.tbInvoice.InvoiceTypeCode, Invoice.tbStatus.InvoiceStatus, 
                         Cash.tbCode.CashDescription, Org.tbOrg.AccountName, Invoice.tbInvoice.InvoiceStatusCode, Invoice.tbType.InvoiceType, Invoice.tbItem.TaxCode, Invoice.tbItem.TaxValue, 
                         Invoice.tbItem.InvoiceValue, Invoice.tbInvoice.PaidValue, Invoice.tbInvoice.PaidTaxValue, Invoice.tbItem.ItemReference
FROM            Invoice.tbInvoice INNER JOIN
                         Invoice.tbStatus ON Invoice.tbInvoice.InvoiceStatusCode = Invoice.tbStatus.InvoiceStatusCode INNER JOIN
                         Org.tbOrg ON Invoice.tbInvoice.AccountCode = Org.tbOrg.AccountCode INNER JOIN
                         Invoice.tbType ON Invoice.tbInvoice.InvoiceTypeCode = Invoice.tbType.InvoiceTypeCode INNER JOIN
                         Invoice.tbItem ON Invoice.tbInvoice.InvoiceNumber = Invoice.tbItem.InvoiceNumber INNER JOIN
                         Cash.tbCode ON Invoice.tbItem.CashCode = Cash.tbCode.CashCode
WHERE        (Invoice.tbInvoice.InvoiceStatusCode > 0);
go
ALTER VIEW Invoice.vwRegisterExpenses
 AS
	SELECT     Invoice.vwRegisterTasks.StartOn, Invoice.vwRegisterTasks.InvoiceNumber, Invoice.vwRegisterTasks.TaskCode, App.tbYearPeriod.YearNumber, 
						  App.tbYear.Description, App.tbMonth.MonthName + ' ' + LTRIM(STR(YEAR( App.tbYearPeriod.StartOn))) AS Period, Invoice.vwRegisterTasks.TaskTitle, 
						  Invoice.vwRegisterTasks.CashCode, Invoice.vwRegisterTasks.CashDescription, Invoice.vwRegisterTasks.TaxCode, Invoice.vwRegisterTasks.TaxDescription, 
						  Invoice.vwRegisterTasks.AccountCode, Invoice.vwRegisterTasks.InvoiceTypeCode, Invoice.vwRegisterTasks.InvoiceStatusCode, Invoice.vwRegisterTasks.InvoicedOn, 
						  Invoice.vwRegisterTasks.InvoiceValue, Invoice.vwRegisterTasks.TaxValue, 
						  Invoice.vwRegisterTasks.PaymentTerms, Invoice.vwRegisterTasks.Printed, Invoice.vwRegisterTasks.AccountName, Invoice.vwRegisterTasks.UserName, 
						  Invoice.vwRegisterTasks.InvoiceStatus, Invoice.vwRegisterTasks.CashModeCode, Invoice.vwRegisterTasks.InvoiceType
	FROM         Invoice.vwRegisterTasks INNER JOIN
						  App.tbYearPeriod ON Invoice.vwRegisterTasks.StartOn = App.tbYearPeriod.StartOn INNER JOIN
						  App.tbYear ON App.tbYearPeriod.YearNumber = App.tbYear.YearNumber INNER JOIN
						  App.tbMonth ON App.tbYearPeriod.MonthNumber = App.tbMonth.MonthNumber
	WHERE     (Task.fnIsExpense(Invoice.vwRegisterTasks.TaskCode) = 1)
go
ALTER VIEW Invoice.vwNetworkDeploymentItems
AS
	SELECT Invoice.tbItem.InvoiceNumber, Invoice.tbItem.CashCode ChargeCode, 
		CASE WHEN LEN(COALESCE(CAST(Invoice.tbItem.ItemReference AS NVARCHAR), '')) > 0 THEN Invoice.tbItem.ItemReference ELSE Cash.tbCode.CashDescription END ChargeDescription, 
			Invoice.tbItem.InvoiceValue, Invoice.tbItem.TaxValue, 0 AS InvoiceQuantity, Invoice.tbItem.TaxCode
	FROM  Invoice.tbItem 
		INNER JOIN Cash.tbCode ON Invoice.tbItem.CashCode = Cash.tbCode.CashCode;
go
ALTER PROCEDURE Invoice.proc_Total 
	(
	@InvoiceNumber nvarchar(20)
	)
  AS
   	SET NOCOUNT, XACT_ABORT ON;

	BEGIN TRY

		WITH totals AS
		(
			SELECT InvoiceNumber, SUM(InvoiceValue) AS InvoiceValue, 
				SUM(TaxValue) AS TaxValue
			FROM         Invoice.tbTask
			GROUP BY InvoiceNumber
			HAVING      (InvoiceNumber = @InvoiceNumber)
			UNION
			SELECT InvoiceNumber, SUM(InvoiceValue) AS InvoiceValue, 
				SUM(TaxValue) AS TaxValue
			FROM         Invoice.tbItem
			GROUP BY InvoiceNumber
			HAVING      (InvoiceNumber = @InvoiceNumber)
		), grand_total AS
		(
			SELECT InvoiceNumber, ISNULL(SUM(InvoiceValue), 0) AS InvoiceValue, 
				ISNULL(SUM(TaxValue), 0) AS TaxValue
			FROM totals
			GROUP BY InvoiceNumber
		) 
		UPDATE    Invoice.tbInvoice
		SET InvoiceValue = grand_total.InvoiceValue, TaxValue = grand_total.TaxValue
		FROM Invoice.tbInvoice INNER JOIN grand_total ON Invoice.tbInvoice.InvoiceNumber = grand_total.InvoiceNumber;
		
  	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
go
ALTER VIEW Cash.vwStatement
AS
	--invoiced taxes
	WITH corp_taxcode AS
	(
		SELECT TOP (1) AccountCode, CashCode 
		FROM Cash.tbTaxType WHERE (TaxTypeCode = 0)
	), corptax_invoiced_entries AS
	(
		SELECT AccountCode, CashCode, StartOn, TaxDue, Balance,
			ROW_NUMBER() OVER (ORDER BY StartOn) AS RowNumber 
		FROM Cash.vwTaxCorpStatement CROSS JOIN corp_taxcode
		WHERE (Balance <> 0) AND (StartOn >= (SELECT MIN(StartOn) FROM App.tbYearPeriod WHERE CashStatusCode < 2)) --AND (TaxDue > 0) 
	), corptax_invoiced_owing AS
	(
		SELECT AccountCode, CashCode, StartOn AS TransactOn, 4 AS CashEntryTypeCode, 
			(SELECT CAST(Message AS NVARCHAR) FROM App.tbText WHERE TextId = 1214) ReferenceCode, 0 AS PayIn,
			CASE RowNumber WHEN 1 THEN Balance ELSE TaxDue END AS PayOut
		FROM corptax_invoiced_entries
	), vat_taxcode AS
	(
		SELECT TOP (1) AccountCode, CashCode 
		FROM Cash.tbTaxType WHERE (TaxTypeCode = 1)
	), vat_totals AS
	(
		SELECT ROW_NUMBER() OVER (ORDER BY RowNumber DESC) AS Id, StartOn AS TransactOn, VatDue,
			CASE WHEN VatPaid  < 0 OR Balance <= 0 THEN NULL ELSE 1 END IsLive
		FROM Cash.vwTaxVatStatement
		--WHERE VatDue <> 0
	), vat_invoiced_owing AS
	(
		SELECT AccountCode, CashCode, TransactOn, 5 AS CashEntryTypeCode, 
			(SELECT CAST(Message AS NVARCHAR) FROM App.tbText WHERE TextId = 1214) ReferenceCode, 
			CASE WHEN VatDue < 0 THEN ABS(VatDue) ELSE 0 END AS PayIn,
			CASE WHEN VatDue >= 0 THEN VatDue ELSE 0 END AS PayOut
		FROM vat_totals CROSS JOIN vat_taxcode
		WHERE Id <  COALESCE((SELECT TOP 1 t.Id FROM vat_totals t WHERE t.IsLive IS NULL ORDER BY Id), (SELECT MIN(Id) + 1 FROM vat_totals))
		--(SELECT TOP 1 t.Id FROM vat_totals t WHERE t.IsLive IS NULL ORDER BY Id)
	)
	--uninvoiced taxes
	,  corptax_dates AS
	(
		SELECT PayOn, PayFrom, PayTo FROM Cash.fnTaxTypeDueDates(0)
	), corptax_accrual_entries AS
	(
		SELECT StartOn, SUM(TaxDue) AS TaxDue
		FROM Cash.vwTaxCorpAccruals
		GROUP BY StartOn
	), corptax_accrual_candidates AS
	(
			SELECT (SELECT PayOn FROM corptax_dates WHERE corptax_accrual_entries.StartOn >= PayFrom AND corptax_accrual_entries.StartOn < PayTo) AS TransactOn, TaxDue			
		FROM corptax_accrual_entries 
	), corptax_accrual_totals AS
	(
		SELECT TransactOn, SUM(TaxDue) AS TaxDue
		FROM corptax_accrual_candidates
		GROUP BY TransactOn
	)	
	, corptax_accruals AS
	(	
		SELECT AccountCode, CashCode, TransactOn, 4 AS CashEntryTypeCode, 
				(SELECT CAST(Message AS NVARCHAR) FROM App.tbText WHERE TextId = 1215) ReferenceCode, 
				CASE WHEN TaxDue < 0 THEN ABS(TaxDue) ELSE 0 END AS PayIn,
				CASE WHEN TaxDue >= 0 THEN TaxDue ELSE 0 END AS PayOut
		FROM corptax_accrual_totals CROSS JOIN corp_taxcode
	), vat_dates AS
	(
		SELECT PayOn, PayFrom, PayTo FROM Cash.fnTaxTypeDueDates(1)
	), vat_accrual_entries AS
	(
		SELECT StartOn, SUM(VatDue) AS TaxDue 
		FROM Cash.vwTaxVatAccruals vat_audit
		WHERE vat_audit.VatDue <> 0
		GROUP BY StartOn
	), vat_accrual_candidates AS
	(
		SELECT (SELECT PayOn FROM vat_dates WHERE vat_accrual_entries.StartOn >= PayFrom AND vat_accrual_entries.StartOn < PayTo) AS TransactOn, TaxDue			
		FROM vat_accrual_entries 
	), vat_accrual_totals AS
	(
		SELECT TransactOn, SUM(TaxDue) AS TaxDue
		FROM vat_accrual_candidates
		GROUP BY TransactOn
	), vat_accruals AS
	(
		SELECT vat_taxcode.AccountCode, vat_taxcode.CashCode, TransactOn, 5 AS CashEntryTypeCode, 
				(SELECT CAST(Message AS NVARCHAR) FROM App.tbText WHERE TextId = 1215) ReferenceCode,
				CASE WHEN TaxDue < 0 THEN ABS(TaxDue) ELSE 0 END AS PayIn,
				CASE WHEN TaxDue >= 0 THEN TaxDue ELSE 0 END AS PayOut
		FROM vat_accrual_totals
			CROSS JOIN vat_taxcode
	)
	--unpaid invoices
	, candidate_cash_codes AS
	(
		SELECT invoice_tasks.InvoiceNumber, 0 OrderBy, 
			FIRST_VALUE(CashCode) OVER (PARTITION BY invoice_tasks.InvoiceNumber ORDER BY CashCode) CashCode
		FROM Invoice.tbTask invoice_tasks 
			JOIN Invoice.tbInvoice invoices ON invoices.InvoiceNumber = invoice_tasks.InvoiceNumber
		WHERE  (InvoiceStatusCode < 3)
		UNION
		SELECT invoice_items.InvoiceNumber, 1 OrderBy, 
			FIRST_VALUE(CashCode) OVER (PARTITION BY invoice_items.InvoiceNumber ORDER BY CashCode) CashCode
		FROM Invoice.tbItem invoice_items 
			JOIN Invoice.tbInvoice invoices ON invoices.InvoiceNumber = invoice_items.InvoiceNumber
		WHERE  (InvoiceStatusCode < 3)
	), cash_codes AS
	(
		SELECT InvoiceNumber,
			FIRST_VALUE(CashCode) OVER (PARTITION BY InvoiceNumber ORDER BY OrderBy) CashCode
		FROM candidate_cash_codes
	), invoices_outstanding AS
	(
		SELECT  invoices.AccountCode, cash_codes.CashCode CashCode, invoices.ExpectedOn AS TransactOn, 1 AS CashEntryTypeCode, invoices.InvoiceNumber AS ReferenceCode, 
					CASE CashModeCode WHEN 1 THEN InvoiceValue + TaxValue - (PaidValue + PaidTaxValue) ELSE 0 END AS PayIn, 
					CASE CashModeCode WHEN 0 THEN (InvoiceValue + TaxValue) - (PaidValue + PaidTaxValue) ELSE 0 END AS PayOut
		FROM  Invoice.tbInvoice invoices
			JOIN Invoice.tbType invoice_type ON invoices.InvoiceTypeCode = invoice_type.InvoiceTypeCode
			JOIN cash_codes ON invoices.InvoiceNumber = cash_codes.InvoiceNumber
		WHERE  (InvoiceStatusCode < 3) AND ((InvoiceValue + TaxValue - PaidValue + PaidTaxValue) > 0)
	), task_invoiced_quantity AS
	(
		SELECT        Invoice.tbTask.TaskCode, SUM(Invoice.tbTask.Quantity) AS InvoiceQuantity
		FROM            Invoice.tbTask INNER JOIN
								 Invoice.tbInvoice ON Invoice.tbTask.InvoiceNumber = Invoice.tbInvoice.InvoiceNumber
		WHERE        (Invoice.tbInvoice.InvoiceTypeCode = 0) OR
								 (Invoice.tbInvoice.InvoiceTypeCode = 2)
		GROUP BY Invoice.tbTask.TaskCode
	), tasks_confirmed AS
	(
		SELECT        TOP (100) PERCENT Task.tbTask.TaskCode AS ReferenceCode, Task.tbTask.AccountCode, Task.tbTask.PaymentOn AS TransactOn, Task.tbTask.PaymentOn, 2 AS CashEntryTypeCode, 
								 CASE WHEN Cash.tbCategory.CashModeCode = 0 THEN (Task.tbTask.UnitCharge + Task.tbTask.UnitCharge * App.tbTaxCode.TaxRate) * (Task.tbTask.Quantity - ISNULL(task_invoiced_quantity.InvoiceQuantity, 
								 0)) ELSE 0 END AS PayOut, CASE WHEN Cash.tbCategory.CashModeCode = 1 THEN (Task.tbTask.UnitCharge + Task.tbTask.UnitCharge * App.tbTaxCode.TaxRate) 
								 * (Task.tbTask.Quantity - ISNULL(task_invoiced_quantity.InvoiceQuantity, 0)) ELSE 0 END AS PayIn, Cash.tbCode.CashCode
		FROM            App.tbTaxCode INNER JOIN
								 Task.tbTask ON App.tbTaxCode.TaxCode = Task.tbTask.TaxCode INNER JOIN
								 Cash.tbCode ON Task.tbTask.CashCode = Cash.tbCode.CashCode INNER JOIN
								 Cash.tbCategory ON Cash.tbCode.CategoryCode = Cash.tbCategory.CategoryCode LEFT OUTER JOIN
								 task_invoiced_quantity ON Task.tbTask.TaskCode = task_invoiced_quantity.TaskCode
		WHERE        (Task.tbTask.TaskStatusCode > 0) AND (Task.tbTask.TaskStatusCode < 3) AND (Task.tbTask.Quantity - ISNULL(task_invoiced_quantity.InvoiceQuantity, 0) > 0)
	)
	--interbank transfers
	, transfer_current_account AS
	(
		SELECT        Org.tbAccount.CashAccountCode
		FROM            Org.tbAccount INNER JOIN
								 Cash.tbCode ON Org.tbAccount.CashCode = Cash.tbCode.CashCode INNER JOIN
								 Cash.tbCategory ON Cash.tbCode.CategoryCode = Cash.tbCategory.CategoryCode AND Cash.tbCode.CategoryCode = Cash.tbCategory.CategoryCode
		WHERE        (Cash.tbCategory.CashTypeCode = 2)
	), transfer_accruals AS
	(
		SELECT        Cash.tbPayment.AccountCode, Cash.tbPayment.CashCode, Cash.tbPayment.PaidOn AS TransactOn, Cash.tbPayment.PaymentCode AS ReferenceCode, 
			6 AS CashEntryTypeCode, Cash.tbPayment.PaidInValue AS PayIn, Cash.tbPayment.PaidOutValue AS PayOut
		FROM            transfer_current_account INNER JOIN
								 Cash.tbPayment ON transfer_current_account.CashAccountCode = Cash.tbPayment.CashAccountCode
		WHERE        (Cash.tbPayment.PaymentStatusCode = 2)
	)
	, statement_unsorted AS
	(
		SELECT AccountCode, CashCode, TransactOn, ReferenceCode, CashEntryTypeCode, PayIn, PayOut FROM corptax_invoiced_owing
		UNION
		SELECT AccountCode, CashCode, TransactOn, ReferenceCode, CashEntryTypeCode, PayIn, PayOut FROM vat_invoiced_owing
		UNION
		SELECT AccountCode, CashCode, TransactOn, ReferenceCode, CashEntryTypeCode, PayIn, PayOut FROM corptax_accruals
		UNION
		SELECT AccountCode, CashCode, TransactOn, ReferenceCode, CashEntryTypeCode, PayIn, PayOut FROM vat_accruals
		UNION
		SELECT AccountCode, CashCode, TransactOn, ReferenceCode, CashEntryTypeCode, PayIn, PayOut FROM invoices_outstanding
		UNION 
		SELECT AccountCode, CashCode, TransactOn, ReferenceCode, CashEntryTypeCode, PayIn, PayOut FROM tasks_confirmed
		UNION
		SELECT AccountCode, CashCode, TransactOn, ReferenceCode, CashEntryTypeCode, PayIn, PayOut FROM transfer_accruals
	), statement_sorted AS
	(
		SELECT ROW_NUMBER() OVER(ORDER BY TransactOn, CashEntryTypeCode DESC) AS RowNumber,
		 AccountCode, CashCode, TransactOn, ReferenceCode, CashEntryTypeCode, PayIn, PayOut FROM statement_unsorted			
	), opening_balance AS
	(	
		SELECT SUM( Org.tbAccount.CurrentBalance) AS OpeningBalance
		FROM         Org.tbAccount INNER JOIN
							  Cash.tbCode ON Org.tbAccount.CashCode = Cash.tbCode.CashCode
		WHERE     ( Org.tbAccount.AccountClosed = 0) AND (Org.tbAccount.AccountTypeCode = 0)
	), statement_data AS
	(
		SELECT 
			0 AS RowNumber,
			(SELECT TOP (1) AccountCode FROM App.tbOptions) AS AccountCode,
			NULL AS CashCode,
			NULL AS TransactOn,    
			(SELECT CAST(Message AS NVARCHAR) FROM App.tbText WHERE TextId = 3013) AS ReferenceCode,	
			1 AS CashEntryTypeCode,
			PayIn = (SELECT OpeningBalance FROM opening_balance),
			0 AS PayOut
		UNION 
		SELECT RowNumber, AccountCode, CashCode, TransactOn, ReferenceCode, CashEntryTypeCode, PayIn, PayOut FROM statement_sorted
	), company_statement AS
	(
		SELECT RowNumber, AccountCode, CashCode, TransactOn, ReferenceCode, CashEntryTypeCode, PayIn, PayOut,
			SUM(PayIn + (PayOut * -1)) OVER (ORDER BY RowNumber ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS Balance
		FROM statement_data
	)
	SELECT RowNumber, cs.AccountCode, org.AccountName, cs.CashCode, cc.CashDescription,
			TransactOn, ReferenceCode, cs.CashEntryTypeCode, et.CashEntryType, CAST(PayIn AS decimal(18, 5)) PayIn, CAST(PayOut AS decimal(18, 5)) PayOut, CAST(Balance AS decimal(18, 5)) Balance
	FROM company_statement cs 
		JOIN Org.tbOrg org ON cs.AccountCode = org.AccountCode
		JOIN Cash.tbEntryType et ON cs.CashEntryTypeCode = et.CashEntryTypeCode
		LEFT OUTER JOIN Cash.tbCode cc ON cs.CashCode = cc.CashCode;
go
ALTER VIEW Task.vwProfit 
AS
	WITH orders AS
	(
		SELECT        task.TaskCode, task.Quantity, task.UnitCharge,
									 (SELECT        TOP (1) StartOn
									   FROM            App.tbYearPeriod AS p
									   WHERE        (StartOn <= task.ActionOn)
									   ORDER BY StartOn DESC) AS StartOn
		FROM            Task.tbFlow RIGHT OUTER JOIN
								 Task.tbTask ON Task.tbFlow.ParentTaskCode = Task.tbTask.TaskCode AND Task.tbFlow.ParentTaskCode = Task.tbTask.TaskCode AND Task.tbFlow.ParentTaskCode = Task.tbTask.TaskCode RIGHT OUTER JOIN
								 Task.tbTask AS task INNER JOIN
								 Cash.tbCode AS cashcode ON task.CashCode = cashcode.CashCode INNER JOIN
								 Cash.tbCategory AS category ON category.CategoryCode = cashcode.CategoryCode ON Task.tbFlow.ChildTaskCode = task.TaskCode AND Task.tbFlow.ChildTaskCode = task.TaskCode
		WHERE        (category.CashModeCode = 1) AND (task.TaskStatusCode BETWEEN 1 AND 3) AND 
			(task.ActionOn >= (SELECT        MIN(StartOn)
											FROM            App.tbYearPeriod p JOIN
																	  App.tbYear y ON p.YearNumber = y.YearNumber
											WHERE        y.CashStatusCode < 3)) AND	
			((Task.tbFlow.ParentTaskCode IS NULL) OR (Task.tbTask.CashCode IS NULL))

	), invoices AS
	(
		SELECT tasks.TaskCode, ISNULL(invoice.InvoiceValue, 0) AS InvoiceValue, ISNULL(invoice.InvoicePaid, 0) AS InvoicePaid 
		FROM Task.tbTask tasks LEFT OUTER JOIN 
			(
				SELECT Invoice.tbTask.TaskCode, 
					SUM(CASE CashModeCode WHEN 0 THEN Invoice.tbTask.InvoiceValue * -1 ELSE Invoice.tbTask.InvoiceValue END) AS InvoiceValue, 
					CASE InvoiceStatusCode WHEN 3 THEN 
						SUM(CASE CashModeCode WHEN 0 THEN Invoice.tbTask.InvoiceValue * -1 ELSE Invoice.tbTask.InvoiceValue END)
					ELSE 0
					END AS InvoicePaid
				FROM Invoice.tbTask 
					INNER JOIN Invoice.tbInvoice ON Invoice.tbTask.InvoiceNumber = Invoice.tbInvoice.InvoiceNumber
					INNER JOIN Invoice.tbType ON Invoice.tbType.InvoiceTypeCode = Invoice.tbInvoice.InvoiceTypeCode 
				GROUP BY Invoice.tbTask.TaskCode, Invoice.tbInvoice.InvoiceStatusCode
			) invoice 
		ON tasks.TaskCode = invoice.TaskCode
	), task_flow AS
	(
		SELECT orders.TaskCode, child.ParentTaskCode, child.ChildTaskCode, 
			CASE WHEN child.UsedOnQuantity <> 0 THEN CAST(orders.Quantity * child.UsedOnQuantity AS decimal(18, 4)) ELSE task.Quantity END AS Quantity
		FROM Task.tbFlow child 
			JOIN orders ON child.ParentTaskCode = orders.TaskCode
			JOIN Task.tbTask task ON child.ChildTaskCode = task.TaskCode

		UNION ALL

		SELECT parent.TaskCode, child.ParentTaskCode, child.ChildTaskCode, 
			CASE WHEN child.UsedOnQuantity <> 0 THEN CAST(parent.Quantity * child.UsedOnQuantity AS decimal(18, 4)) ELSE task.Quantity END AS Quantity
		FROM Task.tbFlow child 
			JOIN task_flow parent ON child.ParentTaskCode = parent.ChildTaskCode
			JOIN Task.tbTask task ON child.ChildTaskCode = task.TaskCode

	), tasks AS
	(
		SELECT task_flow.TaskCode, task.Quantity,
				CASE category.CashModeCode 
					WHEN NULL THEN 0 
					WHEN 0 THEN task.UnitCharge * -1 
					ELSE task.UnitCharge 
				END AS UnitCharge,
				invoices.InvoiceValue, invoices.InvoicePaid
		FROM task_flow
			JOIN Task.tbTask task ON task_flow.ChildTaskCode = task.TaskCode
			JOIN invoices ON invoices.TaskCode = task.TaskCode
			LEFT OUTER JOIN Cash.tbCode cashcode ON cashcode.CashCode = task.CashCode 
			LEFT OUTER JOIN Cash.tbCategory category ON category.CategoryCode = cashcode.CategoryCode
	)
	, task_costs AS
	(
		SELECT TaskCode, ROUND(SUM(Quantity * UnitCharge), 2) AS TotalCost, 
				ROUND(SUM(InvoiceValue), 2) AS InvoicedCost, ROUND(SUM(InvoicePaid), 2) AS InvoicedCostPaid
		FROM tasks
		GROUP BY TaskCode
		UNION
		SELECT TaskCode, 0 AS TotalCost, 0 AS InvoicedCost, 0 AS InvoicedCostPaid
		FROM orders LEFT OUTER JOIN Task.tbFlow AS flow ON orders.TaskCode = flow.ParentTaskCode
		WHERE (flow.ParentTaskCode IS NULL)
	), profits AS
	(
		SELECT orders.StartOn, task.AccountCode, orders.TaskCode, 
			yearperiod.YearNumber, yr.Description, 
			CONCAT(mn.MonthName, ' ', YEAR(yearperiod.StartOn)) AS Period,
			task.ActivityCode, cashcode.CashCode, task.TaskTitle, org.AccountName, cashcode.CashDescription,
			taskstatus.TaskStatus, task.TotalCharge, invoices.InvoiceValue AS InvoicedCharge,
			invoices.InvoicePaid AS InvoicedChargePaid,
			task_costs.TotalCost, task_costs.InvoicedCost, task_costs.InvoicedCostPaid,
			task.TotalCharge + task_costs.TotalCost AS Profit,
			task.TotalCharge - invoices.InvoiceValue AS UninvoicedCharge,
			invoices.InvoiceValue - invoices.InvoicePaid AS UnpaidCharge,
			task_costs.TotalCost - task_costs.InvoicedCost AS UninvoicedCost,
			task_costs.InvoicedCost - task_costs.InvoicedCostPaid AS UnpaidCost,
			task.ActionOn, task.ActionedOn, task.PaymentOn
		FROM orders 
			JOIN Task.tbTask task ON task.TaskCode = orders.TaskCode
			JOIN invoices ON invoices.TaskCode = task.TaskCode
			JOIN task_costs ON orders.TaskCode = task_costs.TaskCode	
			JOIN Cash.tbCode cashcode ON task.CashCode = cashcode.CashCode
			JOIN Task.tbStatus taskstatus ON taskstatus.TaskStatusCode = task.TaskStatusCode
			JOIN Org.tbOrg org ON org.AccountCode = task.AccountCode
			JOIN App.tbYearPeriod yearperiod ON yearperiod.StartOn = orders.StartOn
			JOIN App.tbYear yr ON yr.YearNumber = yearperiod.YearNumber
			JOIN App.tbMonth mn ON mn.MonthNumber = yearperiod.MonthNumber
		)
		SELECT StartOn, AccountCode, TaskCode, YearNumber, [Description], [Period], ActivityCode, CashCode,
			TaskTitle, AccountName, CashDescription, TaskStatus, CAST(TotalCharge as float) TotalCharge, CAST(InvoicedCharge as float) InvoicedCharge, CAST(InvoicedChargePaid as float) InvoicedChargePaid,
			CAST(TotalCost AS float) TotalCost, CAST(InvoicedCost as float) InvoicedCost, CAST(InvoicedCostPaid as float) InvoicedCostPaid, CAST(Profit AS float) Profit,
			CAST(UninvoicedCharge AS float) UninvoicedCharge, CAST(UnpaidCharge AS float) UnpaidCharge,
			CAST(UninvoicedCost AS float) UninvoicedCost, CAST(UnpaidCost AS float) UnpaidCost,
			ActionOn, ActionedOn, PaymentOn
		FROM profits;
go
DROP VIEW IF EXISTS Invoice.vwOutstanding;
go
ALTER TABLE Cash.tbPayment DROP 
	CONSTRAINT DF_Cash_tbPayment_TaxInValue, DF_Cash_tbPayment_TaxOutValue,
	COLUMN TaxInValue, TaxOutValue
go
ALTER TABLE Invoice.tbItem DROP
	CONSTRAINT DF_Invoice_tbItem_PaidValue, DF_Invoice_tbItem_PaidTaxValue,
	COLUMN PaidValue, PaidTaxValue
go
ALTER TABLE Invoice.tbTask DROP
	CONSTRAINT DF_Invoice_tbTask_PaidValue, DF_Invoice_tbTask_PaidTaxValue,
	COLUMN PaidValue, PaidTaxValue
go

