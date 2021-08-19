/**************************************************************************************
Trade Control
Upgrade script
Release: 3.32.1

Date: 20 January 2021
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
CREATE VIEW Invoice.vwCreditSpoolByItem
AS
	SELECT        credit_note.InvoiceNumber, Invoice.tbType.InvoiceType, credit_note.InvoiceStatusCode, Usr.tbUser.UserName, credit_note.AccountCode, Org.tbOrg.AccountName, Invoice.tbStatus.InvoiceStatus, credit_note.InvoicedOn, 
							 credit_note.InvoiceValue AS InvoiceValueTotal, credit_note.TaxValue AS TaxValueTotal, credit_note.PaymentTerms, credit_note.DueOn, credit_note.Notes, Org.tbOrg.EmailAddress, Org.tbAddress.Address AS InvoiceAddress, 
							 tbInvoiceItem.CashCode, Cash.tbCode.CashDescription, tbInvoiceItem.ItemReference, tbInvoiceItem.TaxCode, tbInvoiceItem.InvoiceValue, tbInvoiceItem.TaxValue
	FROM            Invoice.tbInvoice AS credit_note INNER JOIN
							 Invoice.tbStatus ON credit_note.InvoiceStatusCode = Invoice.tbStatus.InvoiceStatusCode INNER JOIN
							 Org.tbOrg ON credit_note.AccountCode = Org.tbOrg.AccountCode INNER JOIN
							 Usr.tbUser ON credit_note.UserId = Usr.tbUser.UserId LEFT OUTER JOIN
							 Org.tbAddress ON Org.tbOrg.AddressCode = Org.tbAddress.AddressCode INNER JOIN
							 Invoice.tbItem AS tbInvoiceItem ON credit_note.InvoiceNumber = tbInvoiceItem.InvoiceNumber INNER JOIN
							 Invoice.tbType ON credit_note.InvoiceTypeCode = Invoice.tbType.InvoiceTypeCode INNER JOIN
							 Cash.tbCode ON tbInvoiceItem.CashCode = Cash.tbCode.CashCode
	WHERE        (credit_note.InvoiceTypeCode = 1 OR
							 credit_note.InvoiceTypeCode = 3) AND EXISTS
								 (SELECT * FROM  App.tbDocSpool AS doc
								   WHERE (DocTypeCode BETWEEN 5 AND 6) AND (UserName = SUSER_SNAME()) AND (credit_note.InvoiceNumber = DocumentNumber))
							   
go
ALTER PROCEDURE Cash.proc_PaymentPostInvoiced (@PaymentCode nvarchar(20))
AS
	SET NOCOUNT, XACT_ABORT ON;

	BEGIN TRY
		DECLARE 
			@AccountCode nvarchar(10)
			, @PostValue decimal(18, 5)
			, @CashCode nvarchar(50);

		SELECT   @PostValue = CASE WHEN PaidInValue = 0 THEN PaidOutValue ELSE PaidInValue * -1 END,
			@AccountCode = Org.tbOrg.AccountCode
		FROM         Cash.tbPayment INNER JOIN
							  Org.tbOrg ON Cash.tbPayment.AccountCode = Org.tbOrg.AccountCode
		WHERE     ( Cash.tbPayment.PaymentCode = @PaymentCode);

		IF NOT EXISTS (SELECT InvoiceNumber FROM Invoice.tbInvoice WHERE (InvoiceStatusCode BETWEEN 1 AND 2) AND (AccountCode = @AccountCode))
			RETURN;

		IF EXISTS (SELECT * FROM  Invoice.tbInvoice 
						INNER JOIN Invoice.tbTask ON Invoice.tbInvoice.InvoiceNumber = Invoice.tbTask.InvoiceNumber
					WHERE        (Invoice.tbInvoice.AccountCode = @AccountCode) AND (Invoice.tbInvoice.InvoiceStatusCode < 3))
		BEGIN
			SELECT  @CashCode = Invoice.tbTask.CashCode
			FROM  Invoice.tbInvoice 
				INNER JOIN Invoice.tbTask ON Invoice.tbInvoice.InvoiceNumber = Invoice.tbTask.InvoiceNumber
			WHERE        (Invoice.tbInvoice.AccountCode = @AccountCode) AND (Invoice.tbInvoice.InvoiceStatusCode < 3)
			GROUP BY Invoice.tbTask.CashCode;
		END
		ELSE IF EXISTS (SELECT * FROM Invoice.tbInvoice 
							INNER JOIN Invoice.tbItem ON Invoice.tbInvoice.InvoiceNumber = Invoice.tbItem.InvoiceNumber
						WHERE        (Invoice.tbInvoice.AccountCode = @AccountCode) AND (Invoice.tbInvoice.InvoiceStatusCode < 3)
						GROUP BY Invoice.tbItem.CashCode)
		BEGIN
			SELECT @CashCode = Invoice.tbItem.CashCode
			FROM  Invoice.tbInvoice 
				INNER JOIN Invoice.tbItem ON Invoice.tbInvoice.InvoiceNumber = Invoice.tbItem.InvoiceNumber
			WHERE        (Invoice.tbInvoice.AccountCode = @AccountCode) AND (Invoice.tbInvoice.InvoiceStatusCode < 3)
			GROUP BY Invoice.tbItem.CashCode;
		END

		BEGIN TRANSACTION;

		UPDATE Cash.tbPayment
		SET PaymentStatusCode = 1, CashCode = @CashCode
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
		VALUES ('AS', 'Assets', 0, 1, 2, 70, 1)
		, ('BA', 'Bank Accounts', 0, 2, 2, 80, 1)
		, ('BP', 'Bank Payments', 0, 0, 0, 90, 1)
		, ('BR', 'Bank Receipts', 0, 1, 0, 100, 1)
		, ('DC', 'Direct Cost', 0, 0, 0, 20, 1)
		, ('DI', 'Dividends', 0, 0, 0, 110, -1)
		, ('DR', 'Drawings', 0, 2, 0, 150, 0)
		, ('IC', 'Indirect Cost', 0, 0, 0, 30, 1)
		, ('IP', 'Intercompany Payment', 0, 0, 2, 120, 1)
		, ('IR', 'Intercompany Receipt', 0, 1, 2, 130, 1)
		, ('IV', 'Investment', 0, 2, 0, 160, 1)
		, ('LI', 'Liabilities', 0, 0, 2, 71, 1)
		, ('SA', 'Sales', 0, 1, 0, 10, 1)
		, ('TA', 'Taxes', 0, 0, 1, 60, 1)
		, ('WA', 'Wages', 0, 0, 0, 50, 1)
		;

		INSERT INTO [Cash].[tbCategory] ([CategoryCode], [Category], [CategoryTypeCode], [CashModeCode], [CashTypeCode], [DisplayOrder], [IsEnabled])
		VALUES 
			('TO', 'Turnover', 1, 2, 0, 0, 1)			
			, ('EX', 'Expenses', 1, 2, 0, 1, 1)
			, ('AL', 'Assets and Liabilities', 1, 2, 0, 2, 1)
			, ('PL', 'Profit Before Taxation', 1, 2, 0, 3, 1)			
			, ('TP', 'Tax on Profit', 1, 2, 0, 4, 1)
			, ('FY', 'Profit for Financial Year', 1, 2, 0, 5, 1)
			, ('VAT', 'Vat Cash Codes', 1, 2, 0, 100, 1)
			, ('WR', 'Wages Ratio', 2, 2, 0, 0, 1)
			;

		INSERT INTO [Cash].[tbCategoryTotal] ([ParentCode], [ChildCode])
		VALUES ('EX', 'BP')
		, ('EX', 'DC')
		, ('EX', 'IC')
		, ('EX', 'WA')
		, ('FY', 'PL')
		, ('FY', 'TP')
		, ('PL', 'EX')
		, ('PL', 'TO')
		, ('PL', 'AL')
		, ('TO', 'BR')
		, ('TO', 'SA')
		, ('TO', 'IV')
		, ('TP', 'TA')
		, ('VAT', 'DC')
		, ('VAT', 'IC')
		, ('VAT', 'SA')
		, ('AL', 'AS')
		, ('AL', 'LI')
		;

		INSERT INTO [Cash].[tbCategoryExp] ([CategoryCode], [Expression], [Format])
		VALUES ('WR', 'IF([Sales]=0,0,(ABS([Wages])/[Sales]))', '0%');

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
		, ('701', 'Depreciation', 'AS', 'N/A', 1)
		, ('702', 'Dept Repayment', 'LI', 'N/A', 1)
		, ('703', 'Share Capital', 'LI', 'N/A', 1)
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
		SET NetProfitCode = 'FY', VatCategoryCode = 'VAT';

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
			VALUES        (@CashAccountCode, @AccountCode, @DummyAccount, 1);
		END

		--capital 
		DECLARE @CapitalAccount NVARCHAR(50);

		SET @CapitalAccount = 'PREMISES';
		EXEC Org.proc_DefaultAccountCode @AccountName = @CapitalAccount, @AccountCode = @CashAccountCode OUTPUT
		INSERT INTO Org.tbAccount (CashAccountCode, AccountCode, CashAccountName, AccountTypeCode, LiquidityLevel, CashCode, AccountClosed)
		VALUES        (@CashAccountCode, @AccountCode, @CapitalAccount, 2, 50, '701', 1);

		SET @CapitalAccount = 'FIXTURES AND FITTINGS';
		EXEC Org.proc_DefaultAccountCode @AccountName = @CapitalAccount, @AccountCode = @CashAccountCode OUTPUT
		INSERT INTO Org.tbAccount (CashAccountCode, AccountCode, CashAccountName, AccountTypeCode, LiquidityLevel, CashCode, AccountClosed)
		VALUES        (@CashAccountCode, @AccountCode, @CapitalAccount, 2, 40, '701', 1);

		SET @CapitalAccount = 'PLANT AND MACHINERY';
		EXEC Org.proc_DefaultAccountCode @AccountName = @CapitalAccount, @AccountCode = @CashAccountCode OUTPUT
		INSERT INTO Org.tbAccount (CashAccountCode, AccountCode, CashAccountName, AccountTypeCode, LiquidityLevel, CashCode, AccountClosed)
		VALUES        (@CashAccountCode, @AccountCode, @CapitalAccount, 2, 30, '701', 1);

		SET @CapitalAccount = 'VEHICLES';
		EXEC Org.proc_DefaultAccountCode @AccountName = @CapitalAccount, @AccountCode = @CashAccountCode OUTPUT
		INSERT INTO Org.tbAccount (CashAccountCode, AccountCode, CashAccountName, AccountTypeCode, LiquidityLevel, CashCode, AccountClosed)
		VALUES        (@CashAccountCode, @AccountCode, @CapitalAccount, 2, 20, '701', 1);

		SET @CapitalAccount = 'STOCK';
		EXEC Org.proc_DefaultAccountCode @AccountName = @CapitalAccount, @AccountCode = @CashAccountCode OUTPUT
		INSERT INTO Org.tbAccount (CashAccountCode, AccountCode, CashAccountName, AccountTypeCode, LiquidityLevel, CashCode, AccountClosed)
		VALUES        (@CashAccountCode, @AccountCode, @CapitalAccount, 2, 10, '700', 1)

		SET @CapitalAccount = 'LONGTERM LIABILITIES';
		EXEC Org.proc_DefaultAccountCode @AccountName = @CapitalAccount, @AccountCode = @CashAccountCode OUTPUT
		INSERT INTO Org.tbAccount (CashAccountCode, AccountCode, CashAccountName, AccountTypeCode, LiquidityLevel, CashCode, AccountClosed)
		VALUES        (@CashAccountCode, @AccountCode, @CapitalAccount, 2, 50, '702', 0);

		SET @CapitalAccount = 'CALLED UP SHARE CAPITAL';
		EXEC Org.proc_DefaultAccountCode @AccountName = @CapitalAccount, @AccountCode = @CashAccountCode OUTPUT
		INSERT INTO Org.tbAccount (CashAccountCode, AccountCode, CashAccountName, AccountTypeCode, LiquidityLevel, CashCode, AccountClosed)
		VALUES        (@CashAccountCode, @AccountCode, @CapitalAccount, 2, 60, '703', 0);

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
		SET CorporationTaxRate = 0.19;

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

