/**************************************************************************************
Trade Control
Upgrade script for ASP.NET Core interface
Release 3.34.7

Date: 14 July 2021
Author: IAM

Trade Control by Trade Control Ltd is licensed under GNU General Public License v3.0. 

You may obtain a copy of the License at

	https://www.gnu.org/licenses/gpl-3.0.en.html


***********************************************************************************/
go
CREATE PROCEDURE App.proc_TemplateCompanyHMRC2021
(
	@FinancialMonth SMALLINT = 4,
	@GovAccountName NVARCHAR(255),
	@BankName NVARCHAR(255) = null,
	@BankAddress NVARCHAR(MAX) = null,
	@DummyAccount NVARCHAR(50), 
	@CurrentAccount NVARCHAR(50) = null,
	@CA_SortCode NVARCHAR(10) = null,
	@CA_AccountNumber NVARCHAR(20) = null,
	@ReserveAccount NVARCHAR(50) = null, 
	@RA_SortCode NVARCHAR(10) = null,
	@RA_AccountNumber NVARCHAR(20) = null
)
AS
	SET NOCOUNT, XACT_ABORT ON;

	BEGIN TRY
		DECLARE
			@CoinTypeCode SMALLINT = (SELECT TOP (1) CoinTypeCode FROM App.tbOptions),
			@AccountCode NVARCHAR(10),
			@CashAccountCode NVARCHAR(10);

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
		VALUES ('each')
		, ('days')
		, ('hrs')
		, ('kilo')
		, ('miles')
		, ('mins')
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

		INSERT INTO [Cash].[tbCategory] ([CategoryCode], [Category], [CategoryTypeCode], [CashModeCode], [CashTypeCode], [DisplayOrder], [IsEnabled])
		VALUES ('AC12', 'Turnover', 1, 2, 0, 0, 1)
		, ('AC24', 'Income from Coronavirus business support grants', 1, 2, 0, 10, 1)
		, ('AC34', 'Tax On Profit', 1, 2, 0, 70, 1)
		, ('AC405', 'Other Income', 1, 2, 0, 20, 1)
		, ('AC410', 'Cost of raw material and consumables', 1, 2, 0, 30, 1)
		, ('AC415', 'Staff Costs', 1, 2, 0, 40, 1)
		, ('AC420', 'Depreciation and other amounts written off', 1, 2, 0, 50, 1)
		, ('AC425', 'Other Charges', 1, 2, 0, 60, 1)
		, ('AC435', 'Profit and Loss', 1, 2, 0, 90, 1)
		, ('CP14-39', 'CP Gross Profit or Loss', 1, 2, 1, 120, 1)
		, ('CP23', 'Rent and Rates', 0, 0, 0, 4, 1)
		, ('CP37', 'Sundry Costs', 0, 0, 0, 0, 1)
		, ('CP40', 'CP Total Expenses', 1, 2, 1, 130, 1)
		, ('CP44', 'CP Profit or losses before tax', 1, 2, 1, 150, 1)
		, ('CP500', 'CP Profit or losses before adjustments', 1, 2, 1, 140, 1)
		, ('CP511', 'CP Income from Property', 1, 2, 1, 180, 1)
		, ('CP54', 'CP Total Additions', 1, 2, 1, 160, 1)
		, ('CP59', 'CP Total Deductions', 1, 2, 1, 170, 1)
		, ('CP7', 'CP Turnover/Sales', 1, 2, 1, 100, 1)
		, ('CP8', 'CP Cost of Sales', 1, 2, 1, 110, 1)
		, ('TC-ADMIN', 'General Administrative Expenses', 0, 0, 0, 6, -1)
		, ('TC-ASSETAJ', 'Adjustments - Assets', 0, 0, 2, 12, -1)
		, ('TC-ASSETGP', 'Assets - Gross Profit', 0, 1, 2, 8, 1)
		, ('TC-ASSETNP', 'Assets - Net Profit', 0, 1, 2, 7, 1)
		, ('TC-BANK', 'Bank Accounts', 0, 2, 2, 9, 1)
		, ('TC-COSTAJ', 'Adjustments - Expenditure', 0, 0, 0, 13, 1)
		, ('TC-DIRECT', 'Direct Costs', 0, 0, 0, 1, 1)
		, ('TC-GRANTS', 'Business Grants', 0, 1, 0, 10, -1)
		, ('TC-INCOME', 'Additional Income', 0, 1, 0, 11, 1)
		, ('TC-INTERP', 'Intercompany Payment', 0, 0, 2, 0, 1)
		, ('TC-INTERR', 'Intercompany Receipt', 0, 1, 2, 0, 1)
		, ('TC-INVEST', 'Investment', 0, 2, 0, 0, 1)
		, ('TC-LIAB', 'Liabilities', 0, 0, 2, 0, 1)
		, ('TC-NP', 'Profit Before Tax', 1, 2, 0, 80, 1)
		, ('TC-PROPC', 'Expenses - property costs', 0, 0, 0, 5, 1)
		, ('TC-PROPE', 'Property - Expenditure', 0, 0, 0, 15, 1)
		, ('TC-PROPI', 'Property - Income', 0, 1, 0, 14, 1)
		, ('TC-SALES', 'Sales', 0, 1, 0, 0, 1)
		, ('TC-SALESAJ', 'Adjustments - Income', 0, 1, 0, 13, 1)
		, ('TC-SUBCON', 'Subcontractor Costs', 0, 1, 0, 3, 1)
		, ('TC-TAXCO', 'Tax On Company', 0, 0, 1, 101, 1)
		, ('TC-TAXGD', 'Tax On Goods', 0, 0, 1, 100, 1)
		, ('TC-VAT', 'VAT Cash Codes', 1, 2, 1, 900, 1)
		, ('TC-WAGES', 'Directors and Employee Wages', 0, 0, 0, 1, 1)
		;
		INSERT INTO [Cash].[tbCategoryTotal] ([ParentCode], [ChildCode])
		VALUES ('AC12', 'TC-INVEST')
		, ('AC12', 'TC-SALES')
		, ('AC24', 'TC-GRANTS')
		, ('AC34', 'TC-TAXCO')
		, ('AC405', 'TC-ASSETGP')
		, ('AC405', 'TC-INCOME')
		, ('AC405', 'TC-PROPI')
		, ('AC405', 'TC-SALESAJ')
		, ('AC410', 'TC-DIRECT')
		, ('AC415', 'TC-WAGES')
		, ('AC420', 'TC-ASSETAJ')
		, ('AC420', 'TC-ASSETNP')
		, ('AC420', 'TC-LIAB')
		, ('AC425', 'CP23')
		, ('AC425', 'CP37')
		, ('AC425', 'TC-ADMIN')
		, ('AC425', 'TC-COSTAJ')
		, ('AC425', 'TC-PROPC')
		, ('AC425', 'TC-PROPE')
		, ('AC435', 'AC34')
		, ('AC435', 'TC-NP')
		, ('CP14-39', 'CP7')
		, ('CP14-39', 'CP8')
		, ('CP40', 'CP23')
		, ('CP40', 'CP37')
		, ('CP40', 'TC-ADMIN')
		, ('CP40', 'TC-ASSETNP')
		, ('CP40', 'TC-PROPC')
		, ('CP40', 'TC-SUBCON')
		, ('CP40', 'TC-WAGES')
		, ('CP44', 'CP500')
		, ('CP44', 'TC-INCOME')
		, ('CP500', 'CP14-39')
		, ('CP500', 'CP40')
		, ('CP511', 'TC-PROPE')
		, ('CP511', 'TC-PROPI')
		, ('CP54', 'TC-ASSETAJ')
		, ('CP54', 'TC-SALESAJ')
		, ('CP59', 'TC-COSTAJ')
		, ('CP7', 'TC-INVEST')
		, ('CP7', 'TC-SALES')
		, ('CP8', 'TC-ASSETGP')
		, ('CP8', 'TC-DIRECT')
		, ('CP8', 'TC-TAXCO')
		, ('CP8', 'TC-LIAB')
		, ('TC-NP', 'AC12')
		, ('TC-NP', 'AC24')
		, ('TC-NP', 'AC405')
		, ('TC-NP', 'AC410')
		, ('TC-NP', 'AC415')
		, ('TC-NP', 'AC420')
		, ('TC-NP', 'AC425')
		, ('TC-VAT', 'TC-ADMIN')
		, ('TC-VAT', 'TC-COSTAJ')
		, ('TC-VAT', 'TC-DIRECT')
		, ('TC-VAT', 'TC-INCOME')
		, ('TC-VAT', 'TC-PROPC')
		, ('TC-VAT', 'TC-PROPE')
		, ('TC-VAT', 'TC-PROPI')
		, ('TC-VAT', 'TC-SALES')
		, ('TC-VAT', 'TC-SALESAJ')
		, ('TC-VAT', 'TC-SUBCON')
		, ('TC-VAT', 'CP37')
		;
		INSERT INTO [Cash].[tbCode] ([CashCode], [CashDescription], [CategoryCode], [TaxCode], [IsEnabled])
		VALUES ('CP130', 'Cornovirus (Covid-19) support', 'TC-GRANTS', 'N/A', -1)
		, ('CP15', 'Directors Pension', 'TC-WAGES', 'N/A', 1)
		, ('CP16', 'Directors Remuneration', 'TC-WAGES', 'N/A', 1)
		, ('CP17', 'Salaries and Wages', 'TC-WAGES', 'N/A', 1)
		, ('CP18', 'Subcon payments (construction ind. only)', 'TC-SUBCON', 'N/A', 0)
		, ('CP19', 'Accountancy and audit', 'TC-SUBCON', 'T1', 1)
		, ('CP20', 'Consultancy', 'TC-SUBCON', 'T1', 1)
		, ('CP21', 'Legal and professional charges', 'TC-SUBCON', 'T1', 1)
		, ('CP22', 'Light, heat and power', 'TC-PROPC', 'T1', 1)
		, ('CP24', 'Repairs, renewals and maintenance', 'TC-PROPC', 'T1', 1)
		, ('CP25', 'Advertising and promotion', 'TC-ADMIN', 'T1', 1)
		, ('CP26', 'Bad debts', 'TC-ADMIN', 'T1', 1)
		, ('CP27', 'Bank, credit card and other financial charges', 'TC-ADMIN', 'T0', 1)
		, ('CP28', 'Depreciation', 'TC-ASSETNP', 'N/A', 1)
		, ('CP29', 'Donations', 'TC-ADMIN', 'T0', 1)
		, ('CP30', 'Entertainment', 'TC-ADMIN', 'T1', 1)
		, ('CP31', 'Insurance', 'TC-ADMIN', 'T1', 1)
		, ('CP32', 'Interest paid', 'TC-ADMIN', 'T0', 1)
		, ('CP33', 'Profit/loss on disposal of assets', 'TC-ASSETNP', 'N/A', 0)
		, ('CP34', 'Travel and subsistence', 'TC-ADMIN', 'T1', 1)
		, ('CP35', 'Vehicle expenses', 'TC-ADMIN', 'T1', 1)
		, ('CP36', 'Administration and office expenses', 'TC-ADMIN', 'T1', 1)
		, ('CP43', 'Interest Received', 'TC-INCOME', 'T0', 1)
		, ('CP46', 'Depreciation Adjustrment', 'TC-ASSETAJ', 'N/A', -1)
		, ('CP47', 'Disallowable Entertainment', 'TC-SALESAJ', 'T1', 1)
		, ('CP48', 'Donations Received', 'TC-SALESAJ', 'T0', 1)
		, ('CP49', 'Legal and professional fees', 'TC-SALESAJ', 'T1', 0)
		, ('CP501', 'Gross income from property', 'TC-INCOME', 'T0', 0)
		, ('CP502', 'Ancillary Income', 'TC-INCOME', 'T0', 0)
		, ('CP503', 'Claimed expenses directly related to income from property', 'TC-SALESAJ', 'T0', 0)
		, ('CP507', 'Income from property', 'TC-PROPI', 'T0', 1)
		, ('CP508', 'Expenses directly related to income from property', 'TC-PROPE', 'T0', 1)
		, ('CP51', 'Net loss on sale of fixed assets', 'TC-SALESAJ', 'T0', 1)
		, ('CP510', 'Unallowable property expenses', 'TC-PROPI', 'T0', 1)
		, ('CP52', 'Penalties and fines', 'TC-SALESAJ', 'T1', 0)
		, ('CP53', 'Unpaid employees remuneration', 'TC-SALESAJ', 'N/A', 0)
		, ('CP55', 'Employees remuneration previously disallowed', 'TC-COSTAJ', 'N/A', 1)
		, ('CP57', 'Net profit on sale of fixed assets', 'TC-COSTAJ', 'N/A', 1)
		, ('CP58', 'Non-trade interest received', 'TC-COSTAJ', 'N/A', 1)
		, ('TC100', 'Sales - Home', 'TC-SALES', 'T1', 1)
		, ('TC101', 'Sales - Export', 'TC-SALES', 'T1', 1)
		, ('TC102', 'Sales - Carriage', 'TC-SALES', 'T1', 1)
		, ('TC103', 'Sales - Consultancy', 'TC-SALES', 'T1', 1)
		, ('TC200', 'Commission', 'TC-DIRECT', 'T1', 1)
		, ('TC201', 'Direct Purchase', 'TC-DIRECT', 'T1', 1)
		, ('TC202', 'Direct Purchase - Carriage', 'TC-DIRECT', 'T1', 1)
		, ('TC203', 'Direct Purchase - Materials', 'TC-DIRECT', 'T1', 1)
		, ('TC204', 'Direct Purchase - Sundry', 'TC-DIRECT', 'T1', 1)
		, ('TC205', 'Tooling', 'TC-DIRECT', 'T1', 1)
		, ('TC206', 'Sundry', 'CP37', 'T1', 1)
		, ('TC207', 'Post and Stationary', 'CP37', 'T1', 1)
		, ('TC208', 'Software', 'CP37', 'T1', 1)
		, ('TC209', 'Hardware', 'CP37', 'T1', 1)
		, ('TC210', 'Communications', 'CP37', 'T1', 1)
		, ('TC211', 'Machinery', 'CP37', 'T1', 1)
		, ('TC300', 'Company Cash', 'TC-BANK', 'N/A', 1)
		, ('TC301', 'Account Payment', 'TC-INTERP', 'N/A', 1)
		, ('TC302', 'Transfer Receipt', 'TC-INTERR', 'N/A', 1)
		, ('TC400', 'Rent', 'CP23', 'T0', -1)
		, ('TC401', 'Business Rates', 'CP23', 'N/A', -1)
		, ('TC500', 'Company Loan', 'TC-INVEST', 'N/A', 1)
		, ('TC501', 'Directors Loan', 'TC-INVEST', 'N/A', 1)
		, ('TC600', 'VAT', 'TC-TAXGD', 'N/A', 1)
		, ('TC601', 'Employers NI', 'TC-TAXCO', 'N/A', 1)
		, ('TC602', 'Taxes (Corporation)', 'TC-TAXGD', 'N/A', 1)
		, ('TC603', 'Taxes (General)', 'TC-TAXCO', 'N/A', 1)
		, ('TC900', 'Stock Movement', 'TC-ASSETGP', 'N/A', 1)
		, ('TC901', 'Share Capital', 'TC-LIAB', 'N/A', 1)
		, ('TC902', 'Debt Repayment', 'TC-LIAB', 'N/A', 1)
		;

		IF @CoinTypeCode < 2
		BEGIN
			INSERT INTO [Cash].[tbCode] ([CashCode], [CashDescription], [CategoryCode], [TaxCode], [IsEnabled])
			VALUES ('TC212', 'Miner Fees', 'TC-DIRECT', 'N/A', 1);
		
			UPDATE App.tbOptions
			SET MinerFeeCode = 'TC212';
		END

		--ASSIGN NET PROFIT CALCULATION
		UPDATE App.tbOptions
		SET NetProfitCode = 'AC435', VatCategoryCode = 'TC-VAT';

		--SET HOME TAX CODE
		UPDATE Org.tbOrg
		SET TaxCode = 'T1'
		WHERE AccountCode = (SELECT AccountCode FROM App.tbOptions)

		--CREATE GOV
		EXEC Org.proc_DefaultAccountCode @AccountName = @GovAccountName, @AccountCode = @AccountCode OUTPUT
		INSERT INTO Org.tbOrg (AccountCode, AccountName, OrganisationStatusCode, OrganisationTypeCode, TaxCode)
			VALUES (@AccountCode, @GovAccountName, 1, 7, 'N/A');

		--ASSIGN CASH CODES AND GOV TO TAX TYPES
		UPDATE Cash.tbTaxType
		SET AccountCode = @AccountCode, CashCode = 'TC602', MonthNumber = @FinancialMonth
		WHERE TaxTypeCode = 0;

		UPDATE Cash.tbTaxType
		SET AccountCode = @AccountCode, CashCode = 'TC600', MonthNumber = @FinancialMonth
		WHERE TaxTypeCode = 1;

		UPDATE Cash.tbTaxType
		SET AccountCode = @AccountCode, CashCode = 'TC601', MonthNumber = @FinancialMonth
		WHERE TaxTypeCode = 2;

		UPDATE Cash.tbTaxType
		SET AccountCode = @AccountCode, CashCode = 'TC603', MonthNumber = @FinancialMonth
		WHERE TaxTypeCode = 3;
		
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
		VALUES        (@CashAccountCode, @AccountCode, @CurrentAccount, 0, @CA_SortCode, @CA_AccountNumber, 'TC300')

		IF (LEN(COALESCE(@ReserveAccount, '')) > 0)
		BEGIN
			EXEC Org.proc_DefaultAccountCode @AccountName = @ReserveAccount, @AccountCode = @CashAccountCode OUTPUT
			INSERT INTO Org.tbAccount (CashAccountCode, AccountCode, CashAccountName, OpeningBalance, SortCode, AccountNumber)
			VALUES        (@CashAccountCode, @AccountCode, @ReserveAccount, 0, @RA_SortCode, @RA_AccountNumber)
		END

		SELECT @AccountCode = (SELECT AccountCode FROM App.tbOptions)

		IF (LEN(COALESCE(@DummyAccount, '')) > 0)
		BEGIN
			EXEC Org.proc_DefaultAccountCode @AccountName = @DummyAccount, @AccountCode = @CashAccountCode OUTPUT
			INSERT INTO Org.tbAccount (CashAccountCode, AccountCode, CashAccountName, AccountTypeCode, CashCode)
			VALUES        (@CashAccountCode, @AccountCode, @DummyAccount, 1, NULL);
		END

		--CAPITAL 
		DECLARE @CapitalAccount NVARCHAR(50);

		SET @CapitalAccount = 'LONGTERM LIABILITIES';
		EXEC Org.proc_DefaultAccountCode @AccountName = @CapitalAccount, @AccountCode = @CashAccountCode OUTPUT
		INSERT INTO Org.tbAccount (CashAccountCode, AccountCode, CashAccountName, AccountTypeCode, LiquidityLevel, CashCode, AccountClosed)
		VALUES        (@CashAccountCode, @AccountCode, @CapitalAccount, 2, 50, 'TC902', 0);

		SET @CapitalAccount = 'CALLED UP SHARE CAPITAL';
		EXEC Org.proc_DefaultAccountCode @AccountName = @CapitalAccount, @AccountCode = @CashAccountCode OUTPUT
		INSERT INTO Org.tbAccount (CashAccountCode, AccountCode, CashAccountName, AccountTypeCode, LiquidityLevel, CashCode, AccountClosed)
		VALUES        (@CashAccountCode, @AccountCode, @CapitalAccount, 2, 60, 'TC901', 0);

		SET @CapitalAccount = 'PLANT AND MACHINERY';
		EXEC Org.proc_DefaultAccountCode @AccountName = @CapitalAccount, @AccountCode = @CashAccountCode OUTPUT
		INSERT INTO Org.tbAccount (CashAccountCode, AccountCode, CashAccountName, AccountTypeCode, LiquidityLevel, CashCode, AccountClosed)
		VALUES        (@CashAccountCode, @AccountCode, @CapitalAccount, 2, 30, 'CP28', 1);

		SET @CapitalAccount = 'DEPRECIATION ADJUSTMENTS';
		EXEC Org.proc_DefaultAccountCode @AccountName = @CapitalAccount, @AccountCode = @CashAccountCode OUTPUT
		INSERT INTO Org.tbAccount (CashAccountCode, AccountCode, CashAccountName, AccountTypeCode, LiquidityLevel, CashCode, AccountClosed)
		VALUES        (@CashAccountCode, @AccountCode, @CapitalAccount, 2, 40, 'CP46', 1);

		SET @CapitalAccount = 'STOCK';
		EXEC Org.proc_DefaultAccountCode @AccountName = @CapitalAccount, @AccountCode = @CashAccountCode OUTPUT
		INSERT INTO Org.tbAccount (CashAccountCode, AccountCode, CashAccountName, AccountTypeCode, LiquidityLevel, CashCode, AccountClosed)
		VALUES        (@CashAccountCode, @AccountCode, @CapitalAccount, 2, 10, 'TC900', 1);

		SET @CapitalAccount = 'VEHICLES';
		EXEC Org.proc_DefaultAccountCode @AccountName = @CapitalAccount, @AccountCode = @CashAccountCode OUTPUT
		INSERT INTO Org.tbAccount (CashAccountCode, AccountCode, CashAccountName, AccountTypeCode, LiquidityLevel, CashCode, AccountClosed)
		VALUES        (@CashAccountCode, @AccountCode, @CapitalAccount, 2, 20, 'CP28', 1);

	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog
	END CATCH
go
IF NOT EXISTS (SELECT * FROM App.tbTemplate WHERE StoredProcedure = 'App.proc_TemplateCompanyHMRC2021')
	INSERT INTO App.tbTemplate (TemplateName, StoredProcedure) 
	VALUES ('HMRC Company Accounts 2020-21', 'App.proc_TemplateCompanyHMRC2021');

UPDATE App.tbTemplate
SET TemplateName = 'Basic Company Setup'
WHERE StoredProcedure = 'App.proc_TemplateCompanyGeneral';

UPDATE App.tbTemplate
SET TemplateName = 'MIS Tutorials'
WHERE StoredProcedure = 'App.proc_TemplateTutorials';

go
ALTER VIEW Cash.vwProfitAndLossData
AS
	WITH category_relations AS
	(
		SELECT Cash.tbCategoryTotal.ParentCode, Cash.tbCategoryTotal.ChildCode, 
			Cash.tbCategory.CategoryTypeCode, Cash.tbCode.CashCode, Cash.tbCategory.CashTypeCode, Cash.tbCategory.CashModeCode
		FROM  Cash.tbCategoryTotal 
			INNER JOIN Cash.tbCategory ON Cash.tbCategoryTotal.ChildCode = Cash.tbCategory.CategoryCode 
			LEFT OUTER JOIN Cash.tbCode ON Cash.tbCategory.CategoryCode = Cash.tbCode.CategoryCode
	), categories AS
	(
		SELECT CategoryCode, CashTypeCode
		FROM  Cash.tbCategory category 
		WHERE (CategoryTypeCode = 1)
			AND NOT EXISTS (SELECT * FROM App.tbOptions o WHERE o.VatCategoryCode = category.CategoryCode) 
			
	), cashcode_candidates AS
	(
		SELECT categories.CategoryCode, ChildCode, CashCode, CashModeCode
		FROM category_relations
			JOIN categories ON category_relations.ParentCode = categories.CategoryCode		

		UNION ALL

		SELECT  cashcode_candidates.CategoryCode, category_relations.ChildCode, category_relations.CashCode, category_relations.CashModeCode
		FROM  category_relations JOIN cashcode_candidates ON category_relations.ParentCode = cashcode_candidates.ChildCode
	), cashcode_selected AS
	(
		SELECT CategoryCode, CashCode, CashModeCode FROM cashcode_candidates
		UNION
		SELECT ParentCode CategoryCode, CashCode, CashModeCode FROM category_relations WHERE ParentCode = (SELECT NetProfitCode FROM App.tbOptions)
	), category_cash_codes AS
	(
		SELECT DISTINCT CategoryCode, CashCode, CashModeCode
		FROM cashcode_selected WHERE NOT CashCode IS NULL
	), active_periods AS
	(
		SELECT yr.YearNumber, pd.StartOn
		FROM App.tbYear yr
			JOIN App.tbYearPeriod pd ON yr.YearNumber = pd.YearNumber
		WHERE (yr.CashStatusCode BETWEEN 1 AND 2)
	), category_data AS
	(
		SELECT category_cash_codes.CategoryCode, CashTypeCode, periods.CashCode, periods.StartOn, 
			CASE category_cash_codes.CashModeCode WHEN 0 THEN periods.InvoiceValue * -1 ELSE InvoiceValue END InvoiceValue
		FROM category_cash_codes 
			JOIN Cash.tbCategory category ON category_cash_codes.CategoryCode = category.CategoryCode
			JOIN Cash.tbPeriod periods ON category_cash_codes.CashCode = periods.CashCode
			JOIN active_periods ON active_periods.StartOn = periods.StartOn
	)
	SELECT CategoryCode, CashTypeCode, StartOn, SUM(InvoiceValue) InvoiceValue
	FROM category_data
	GROUP BY CategoryCode, CashTypeCode, StartOn;
go
ALTER VIEW Cash.vwProfitAndLossByPeriod
AS
	SELECT category.CategoryCode, category.Category, category.CashTypeCode, periods.YearNumber, periods.MonthNumber, category.DisplayOrder, financial_year.Description,
		year_month.MonthName, profit_data.StartOn, profit_data.InvoiceValue
	FROM Cash.vwProfitAndLossData profit_data
		JOIN Cash.tbCategory category ON profit_data.CategoryCode = category.CategoryCode
		JOIN App.tbYearPeriod periods ON profit_data.StartOn = periods.StartOn
		JOIN App.tbYear financial_year ON periods.YearNumber = financial_year.YearNumber
		JOIN App.tbMonth year_month ON periods.MonthNumber = year_month.MonthNumber;
go
ALTER VIEW Cash.vwProfitAndLossByYear
AS
	SELECT financial_year.YearNumber, financial_year.Description, category.DisplayOrder, category.CategoryCode, category.Category, category.CashTypeCode, SUM(profit_data.InvoiceValue) InvoiceValue
	FROM Cash.vwProfitAndLossData profit_data
		JOIN Cash.tbCategory category ON profit_data.CategoryCode = category.CategoryCode
		JOIN App.tbYearPeriod periods ON profit_data.StartOn = periods.StartOn
		JOIN App.tbYear financial_year ON periods.YearNumber = financial_year.YearNumber
	GROUP BY financial_year.YearNumber, financial_year.Description, category.DisplayOrder, category.CategoryCode, category.Category, category.CashTypeCode;
go
CREATE VIEW Cash.vwTaxLossesCarriedForward
AS
	WITH tax_dates AS
	(
		SELECT PayFrom, PayTo FROM Cash.fnTaxTypeDueDates(0)
	), period_totals AS
	(
		SELECT (SELECT PayTo FROM tax_dates WHERE totals.StartOn >= PayFrom AND totals.StartOn < PayTo) AS StartOn, CorporationTax
		FROM Cash.vwTaxCorpTotalsByPeriod totals
	), tax_entries AS
	(
		SELECT StartOn, SUM(CorporationTax) AS TaxDue, 0 AS TaxPaid
		FROM period_totals
		WHERE NOT StartOn IS NULL
		GROUP BY StartOn
		
		UNION

		SELECT Cash.tbPayment.PaidOn AS StartOn, 0 As TaxDue, ( Cash.tbPayment.PaidOutValue * -1) + Cash.tbPayment.PaidInValue AS TaxPaid
		FROM Cash.tbPayment 
			JOIN Cash.tbTaxType tt ON Cash.tbPayment.CashCode = tt.CashCode
		WHERE (tt.TaxTypeCode = 0)

	), tax_statement AS
	(
		SELECT StartOn, TaxDue, TaxPaid,
			SUM(TaxDue + TaxPaid) OVER (ORDER BY StartOn, TaxDue ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS Balance
		FROM tax_entries
	), profit_statement AS
	(
		SELECT tax_statement.StartOn, CAST(TaxDue AS decimal(18, 5)) TaxDue, CAST(Balance AS decimal(18, 5)) TaxBalance,  
			CAST(Balance / CorporationTaxRate AS decimal(18, 5)) LossesCarriedForward
		FROM tax_statement 
			JOIN App.tbYearPeriod yp ON tax_statement.StartOn = yp.StartOn
		WHERE tax_statement.StartOn >= (SELECT MIN(StartOn) FROM App.tbYearPeriod p JOIN App.tbYear y ON p.YearNumber = y.YearNumber  WHERE y.CashStatusCode < 3)
	)
	SELECT CONCAT(y.[Description], ' ', mn.MonthName) YearEndDescription,
		profit_statement.StartOn, TaxDue, TaxBalance, 
		CASE WHEN LossesCarriedForward < 0 THEN ABS(LossesCarriedForward) ELSE 0 END LossesCarriedForward		
	FROM profit_statement
		JOIN App.tbYearPeriod yp ON profit_statement.StartOn = yp.StartOn
		JOIN App.tbYear y ON yp.YearNumber - 1 = y.YearNumber
		JOIN App.tbMonth mn ON yp.MonthNumber = mn.MonthNumber;
go
