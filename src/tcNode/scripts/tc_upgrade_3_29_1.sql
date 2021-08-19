/**************************************************************************************
Trade Control
Upgrade script
Release: 3.29.1

Date: 14 August 2020
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
CREATE TABLE Org.tbAccountType
(
	AccountTypeCode smallint NOT NULL,
	AccountType nvarchar(20) NOT NULL,
	CONSTRAINT PK_Org_tbAccountType PRIMARY KEY CLUSTERED (AccountTypeCode)	
);
go
INSERT INTO Org.tbAccountType (AccountTypeCode, AccountType)
VALUES (0, 'CASH'), (1, 'DUMMY'), (2, 'ASSET');
go
ALTER TABLE Org.tbAccount WITH NOCHECK ADD
	AccountTypeCode smallint NOT NULL CONSTRAINT DF_Org_tbAccount_AccountTypeCode DEFAULT (0),
	LiquidityLevel smallint NOT NULL CONSTRAINT DF_Org_tbAccount_LiquidityLevel DEFAULT (0)
go
ALTER TABLE Org.tbAccount WITH CHECK ADD CONSTRAINT FK_Org_tbAccount_Org_tbAccountType FOREIGN KEY(AccountTypeCode)
REFERENCES Org.tbAccountType (AccountTypeCode)
go
CREATE NONCLUSTERED INDEX IX_tbAccount_AccountTypeCode ON Org.tbAccount (AccountTypeCode ASC, LiquidityLevel DESC, CashAccountCode ASC)
go
ALTER TRIGGER Org.Org_tbAccount_TriggerUpdate 
   ON  Org.tbAccount
   AFTER UPDATE, INSERT
AS 
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY
	DECLARE @Msg NVARCHAR(MAX);

		IF EXISTS (SELECT * FROM inserted i WHERE App.fnParsePrimaryKey(CashAccountCode) = 0)
			BEGIN		
			SELECT @Msg = Message FROM App.tbText WHERE TextId = 2004;
			RAISERROR (@Msg, 10, 1)
			ROLLBACK
			END
		ELSE IF EXISTS (SELECT * FROM inserted i JOIN Cash.tbCode c ON i.CashCode = c.CashCode WHERE AccountTypeCode = 1)
			BEGIN
			SELECT @Msg = Message FROM App.tbText WHERE TextId = 3015;
			RAISERROR (@Msg, 10, 1)
			ROLLBACK
			END
		ELSE
			BEGIN
			IF UPDATE(OpeningBalance)
			BEGIN
			
				WITH i AS
				(
					SELECT * FROM inserted WHERE AccountTypeCode = 0
				)
				UPDATE Org.tbAccount
				SET CurrentBalance = balance.CurrentBalance
				FROM Org.tbAccount 
					INNER JOIN i ON tbAccount.CashAccountCode = i.CashAccountCode
					INNER JOIN Cash.vwAccountRebuild balance ON balance.CashAccountCode = i.CashAccountCode;

				WITH i AS
				(
					SELECT * FROM inserted WHERE AccountTypeCode = 0
				)		
				UPDATE Org.tbAccount
				SET CurrentBalance = Org.tbAccount.OpeningBalance
				FROM  Cash.vwAccountRebuild 
					RIGHT OUTER JOIN Org.tbAccount ON Cash.vwAccountRebuild.CashAccountCode = Org.tbAccount.CashAccountCode
					JOIN i ON i.CashAccountCode = Org.tbAccount.CashAccountCode
				WHERE   (Cash.vwAccountRebuild.CashAccountCode IS NULL);
			END

			UPDATE Org.tbAccount
			SET UpdatedBy = SUSER_SNAME(), UpdatedOn = CURRENT_TIMESTAMP
			FROM Org.tbAccount INNER JOIN inserted AS i ON tbAccount.CashAccountCode = i.CashAccountCode;
			END
	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
END
go
UPDATE Org.tbAccount
SET AccountTypeCode = 1
WHERE DummyAccount <> 0;

UPDATE Cash.tbType
SET CashType = 'MONEY'
WHERE CashTypeCode = 2;

INSERT INTO App.tbText ([TextId], [Message], [Arguments])
VALUES (1225, 'Initialising <1>', 1)
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
	, invoices_unpaid_items AS
	(
		SELECT     Invoice.tbInvoice.AccountCode, Invoice.tbItem.CashCode, Invoice.tbInvoice.ExpectedOn AS TransactOn, 1 AS CashEntryTypeCode, Invoice.tbItem.InvoiceNumber AS ReferenceCode, 
							  SUM(CASE WHEN InvoiceTypeCode = 0 OR
							  InvoiceTypeCode = 3 THEN ( Invoice.tbItem.InvoiceValue + Invoice.tbItem.TaxValue) - ( Invoice.tbItem.PaidValue + Invoice.tbItem.PaidTaxValue) 
							  ELSE 0 END) AS PayIn, SUM(CASE WHEN InvoiceTypeCode = 1 OR
							  InvoiceTypeCode = 2 THEN ( Invoice.tbItem.InvoiceValue + Invoice.tbItem.TaxValue) - ( Invoice.tbItem.PaidValue + Invoice.tbItem.PaidTaxValue) 
							  ELSE 0 END) AS PayOut
		FROM         Invoice.tbItem INNER JOIN
							  Invoice.tbInvoice ON Invoice.tbItem.InvoiceNumber = Invoice.tbInvoice.InvoiceNumber INNER JOIN
							  Cash.tbCode ON Invoice.tbItem.CashCode = Cash.tbCode.CashCode INNER JOIN
							  Cash.tbCategory ON Cash.tbCode.CategoryCode = Cash.tbCategory.CategoryCode
		WHERE  (InvoiceStatusCode < 3) AND (( Invoice.tbItem.InvoiceValue + Invoice.tbItem.TaxValue) - ( Invoice.tbItem.PaidValue + Invoice.tbItem.PaidTaxValue) > 0)
		GROUP BY Invoice.tbItem.InvoiceNumber, Invoice.tbInvoice.AccountCode, Invoice.tbInvoice.ExpectedOn, Invoice.tbItem.CashCode
	), invoices_unpaid_tasks AS
	(
		SELECT     Invoice.tbInvoice.AccountCode, Invoice.tbTask.CashCode, Invoice.tbInvoice.ExpectedOn AS TransactOn, 1 AS CashEntryTypeCode, Invoice.tbTask.InvoiceNumber AS ReferenceCode, 
							  SUM(CASE WHEN InvoiceTypeCode = 0 OR
							  InvoiceTypeCode = 3 THEN ( Invoice.tbTask.InvoiceValue + Invoice.tbTask.TaxValue) - ( Invoice.tbTask.PaidValue + Invoice.tbTask.PaidTaxValue) 
							  ELSE 0 END) AS PayIn, SUM(CASE WHEN InvoiceTypeCode = 1 OR
							  InvoiceTypeCode = 2 THEN ( Invoice.tbTask.InvoiceValue + Invoice.tbTask.TaxValue) - ( Invoice.tbTask.PaidValue + Invoice.tbTask.PaidTaxValue) 
							  ELSE 0 END) AS PayOut
		FROM         Invoice.tbTask INNER JOIN
							  Invoice.tbInvoice ON Invoice.tbTask.InvoiceNumber = Invoice.tbInvoice.InvoiceNumber INNER JOIN
							  Cash.tbCode ON Invoice.tbTask.CashCode = Cash.tbCode.CashCode INNER JOIN
							  Cash.tbCategory ON Cash.tbCode.CategoryCode = Cash.tbCategory.CategoryCode
		WHERE  (InvoiceStatusCode < 3) AND  (( Invoice.tbTask.InvoiceValue + Invoice.tbTask.TaxValue) - ( Invoice.tbTask.PaidValue + Invoice.tbTask.PaidTaxValue) > 0)
		GROUP BY Invoice.tbTask.InvoiceNumber, Invoice.tbInvoice.AccountCode, Invoice.tbInvoice.ExpectedOn, Invoice.tbTask.CashCode
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
		SELECT AccountCode, CashCode, TransactOn, ReferenceCode, CashEntryTypeCode, PayIn, PayOut FROM invoices_unpaid_items
		UNION 
		SELECT AccountCode, CashCode, TransactOn, ReferenceCode, CashEntryTypeCode, PayIn, PayOut FROM invoices_unpaid_tasks
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
ALTER VIEW Cash.vwSummary
AS
	WITH company AS
	(
		SELECT 0 AS SummaryId, SUM( Org.tbAccount.CurrentBalance) AS CompanyBalance 
		FROM Org.tbAccount WHERE ( Org.tbAccount.AccountClosed = 0) AND (Org.tbAccount.AccountTypeCode = 0)
	), corp_tax_invoiced AS
	(
		SELECT TOP (1)  0 AS SummaryId, Balance AS CorpTaxBalance 
		FROM Cash.vwTaxCorpStatement 
		ORDER BY StartOn DESC
	), corp_tax_ordered AS
	(
		SELECT 0 AS SummaryId, SUM(TaxDue) AS CorpTaxBalance
		FROM Cash.vwTaxCorpAccruals
	), vat_invoiced AS
	(
		SELECT TOP (1)  0 AS SummaryId, Balance AS VatBalance 
		FROM Cash.vwTaxVatStatement 
		ORDER BY StartOn DESC, VatDue DESC
	), vat_accruals AS
	(
		SELECT 0 AS SummaryId, SUM(VatDue) AS VatBalance
		FROM Cash.vwTaxVatAccruals
	), invoices AS
	(
		SELECT     Invoice.tbInvoice.InvoiceNumber, CASE Invoice.tbInvoice.InvoiceTypeCode WHEN 0 THEN (InvoiceValue + TaxValue) - (PaidValue + PaidTaxValue) 
						  WHEN 3 THEN (InvoiceValue + TaxValue) - (PaidValue + PaidTaxValue) ELSE 0 END AS ToCollect, 
						  CASE Invoice.tbInvoice.InvoiceTypeCode WHEN 1 THEN (InvoiceValue + TaxValue) - (PaidValue + PaidTaxValue) WHEN 2 THEN (InvoiceValue + TaxValue) 
						  - (PaidValue + PaidTaxValue) ELSE 0 END AS ToPay, CASE Invoice.tbType.CashModeCode WHEN 0 THEN (TaxValue - PaidTaxValue) 
						  * - 1 WHEN 1 THEN TaxValue - PaidTaxValue END AS TaxValue
		FROM         Invoice.tbInvoice INNER JOIN
							  Invoice.tbType ON Invoice.tbInvoice.InvoiceTypeCode = Invoice.tbType.InvoiceTypeCode
		WHERE     (Invoice.tbInvoice.InvoiceStatusCode = 1) OR
						  (Invoice.tbInvoice.InvoiceStatusCode = 2)
	), invoice_totals AS
	(
		SELECT 0 AS SummaryId, ISNULL(SUM(ToCollect), 0) AS Collect, ISNULL(SUM(ToPay), 0) AS Pay, ISNULL(SUM(TaxValue), 0) AS TaxValue
		FROM  invoices
	), summary_base AS
	(
		SELECT Collect, Pay, TaxValue + vat_invoiced.VatBalance + vat_accruals.VatBalance + corp_tax_invoiced.CorpTaxBalance + corp_tax_ordered.CorpTaxBalance AS Tax, CompanyBalance
		FROM company 
				JOIN corp_tax_invoiced ON company.SummaryId = corp_tax_invoiced.SummaryId
				JOIN corp_tax_ordered ON company.SummaryId = corp_tax_ordered.SummaryId
				JOIN vat_invoiced ON company.SummaryId = vat_invoiced.SummaryId
				JOIN vat_accruals ON company.SummaryId = vat_accruals.SummaryId
				JOIN invoice_totals ON company.SummaryId = invoice_totals.SummaryId
	)
	SELECT CURRENT_TIMESTAMP AS Timestamp, Collect, Pay, Tax, CompanyBalance AS Cash, CompanyBalance + Collect - Pay - Tax AS Balance
	FROM    summary_base;
go
ALTER VIEW Cash.vwStatementReserves
AS
	WITH reserve_account AS
	(
		SELECT  Org.tbAccount.CashAccountCode, Org.tbAccount.CashAccountName, Org.tbAccount.CurrentBalance
		FROM            Org.tbAccount LEFT OUTER JOIN
								 Cash.tbCode ON Org.tbAccount.CashCode = Cash.tbCode.CashCode 
		WHERE        (Org.tbAccount.AccountCode <> (SELECT AccountCode FROM App.tbOptions))
			AND (Cash.tbCode.CashCode IS NULL) AND (Org.tbAccount.AccountTypeCode = 0)
	), last_payment AS
	(
		SELECT MAX( payments.PaidOn) AS TransactOn
		FROM reserve_account JOIN Cash.tbPayment payments 
						ON reserve_account.CashAccountCode = payments.CashAccountCode 
		WHERE payments.PaymentStatusCode = 1
	
	), opening_balance AS
	(
		SELECT 	
			(SELECT AccountCode FROM App.tbOptions) AS AccountCode,		
			(SELECT TransactOn FROM last_payment) AS TransactOn,
			0 AS CashEntryTypeCode,
			(SELECT CAST(Message AS NVARCHAR) FROM App.tbText WHERE TextId = 1219) AS ReferenceCode,
			CASE WHEN SUM(CurrentBalance) > 0 THEN SUM(CurrentBalance) ELSE 0 END AS PayIn, 
			CASE WHEN SUM(CurrentBalance) < 0 THEN SUM(CurrentBalance) ELSE 0 END  AS PayOut
		FROM reserve_account 

	), unbalanced_reserves AS
	(
		SELECT  0 AS RowNumber, org.AccountCode, org.AccountName, TransactOn, CashEntryTypeCode, ReferenceCode, 
					PayOut, PayIn, NULL AS CashCode, NULL AS CashDescription
		FROM opening_balance
			JOIN Org.tbOrg org ON opening_balance.AccountCode = org.AccountCode

		UNION
	
		SELECT ROW_NUMBER() OVER (ORDER BY payments.PaidOn) AS RowNumber, reserve_account.CashAccountCode AS AccountCode,
			reserve_account.CashAccountName AS AccountName,
			payments.PaidOn AS TransactOn, 6 AS CashEntryTypeCode, payments.PaymentCode AS ReferenceCode,  
			payments.PaidOutValue, payments.PaidInValue, payments.CashCode, cash_code.CashDescription 
		FROM reserve_account 
			JOIN Cash.tbPayment payments ON reserve_account.CashAccountCode = payments.CashAccountCode
			JOIN Cash.tbCode cash_code ON payments.CashCode = cash_code.CashCode
		WHERE payments.PaymentStatusCode = 2
	)
	SELECT RowNumber, TransactOn, entry_type.CashEntryTypeCode, entry_type.CashEntryType, ReferenceCode, unbalanced_reserves.AccountCode, unbalanced_reserves.AccountName,
		CAST(PayOut as float) PayOut, CAST(PayIn as float) PayIn,
		CAST(SUM(PayIn + (PayOut * -1)) OVER (ORDER BY RowNumber) as float) Balance,
		CashCode, CashDescription
	FROM unbalanced_reserves 
		JOIN Cash.tbEntryType entry_type ON unbalanced_reserves.CashEntryTypeCode = entry_type.CashEntryTypeCode
go
ALTER TABLE App.tbOptions WITH NOCHECK ADD
	CoinTypeCode smallint NOT NULL CONSTRAINT DF_App_tbOptions_CoinTypeCode DEFAULT (2)
go
ALTER TRIGGER App.App_tbOptions_TriggerUpdate 
   ON App.tbOptions
   AFTER UPDATE
AS 
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY
		UPDATE App.tbOptions
		SET UpdatedBy = SUSER_SNAME(), UpdatedOn = CURRENT_TIMESTAMP
		FROM App.tbOptions INNER JOIN inserted AS i ON tbOptions.Identifier = i.Identifier;

		IF UPDATE(CoinTypeCode)
		BEGIN
			UPDATE Org.tbAccount
			SET CoinTypeCode = (SELECT CoinTypeCode FROM inserted)
		END

	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
END
go
UPDATE App.tbOptions
SET CoinTypeCode = (SELECT MIN(CoinTypeCode) FROM Org.tbAccount);
go
ALTER TABLE App.tbOptions  WITH CHECK ADD CONSTRAINT FK_App_tbOptions_Cash_tbCoinType FOREIGN KEY(CoinTypeCode)
REFERENCES Cash.tbCoinType (CoinTypeCode)
go
ALTER VIEW Org.vwWallets
AS
	SELECT        Org.tbAccount.CashAccountCode, Org.tbAccount.CashAccountName, Org.tbAccount.CashCode, Org.tbAccount.CoinTypeCode
	FROM            Org.tbAccount INNER JOIN
							 App.tbOptions ON Org.tbAccount.AccountCode = App.tbOptions.AccountCode LEFT OUTER JOIN
							 Cash.tbCode ON Org.tbAccount.CashCode = Cash.tbCode.CashCode
	WHERE        (Org.tbAccount.AccountTypeCode = 0) AND Org.tbAccount.CoinTypeCode < 2;
go

ALTER TABLE Org.tbAccount
	DROP CONSTRAINT DF_Org_tbAccount_IsDummyAccount,
	COLUMN DummyAccount
go
DROP VIEW Org.vwCashAccounts
DROP VIEW Org.vwCashAccountsLive
go
ALTER PROCEDURE Cash.proc_CurrentAccount(@CashAccountCode NVARCHAR(10) OUTPUT)
AS
	SET NOCOUNT, XACT_ABORT ON;
	BEGIN TRY
		SELECT  @CashAccountCode = Org.tbAccount.CashAccountCode
		FROM Org.tbAccount 
			JOIN Cash.tbCode ON Org.tbAccount.CashCode = Cash.tbCode.CashCode 
			JOIN Cash.tbCategory ON Cash.tbCode.CategoryCode = Cash.tbCategory.CategoryCode
		WHERE (Cash.tbCategory.CashTypeCode = 2) AND (Org.tbAccount.AccountTypeCode = 0) AND (Org.tbAccount.AccountClosed = 0);

	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
go
ALTER PROCEDURE Cash.proc_ReserveAccount(@CashAccountCode NVARCHAR(10) OUTPUT)
AS
	SET NOCOUNT, XACT_ABORT ON;
	BEGIN TRY
		SELECT  @CashAccountCode = Org.tbAccount.CashAccountCode
		FROM            Org.tbAccount LEFT OUTER JOIN
								 Cash.tbCode ON Org.tbAccount.CashCode = Cash.tbCode.CashCode 
		WHERE (Cash.tbCode.CashCode IS NULL) AND (Org.tbAccount.AccountTypeCode = 0);
	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
go
ALTER VIEW Cash.vwBankAccounts
AS
	SELECT CashAccountCode, CashAccountName, OpeningBalance, CASE WHEN NOT CashCode IS NULL THEN 0 ELSE 1 END AS DisplayOrder
	FROM Org.tbAccount  
	WHERE AccountCode <> (SELECT AccountCode FROM App.vwHomeAccount) AND (AccountTypeCode = 0)
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
			CASE WHEN OpeningBalance< 0 THEN (SELECT TOP 1 CashCode FROM Cash.vwBankCashCodes WHERE CashModeCode = 0)
				WHEN OpeningBalance > 0 THEN  (SELECT TOP 1 CashCode FROM Cash.vwBankCashCodes WHERE CashModeCode = 1)
				ELSE 
					(SELECT TOP 1 CashCode FROM
						(SELECT CashCode 
						FROM Cash.vwBankCashCodes 
						WHERE CashModeCode = 2
						EXCEPT
						SELECT CashCode
						FROM Org.tbAccount
						WHERE AccountTypeCode <> 0) codes)
				END AS CashCode, 
			0 AS EntryNumber, 
			(SELECT CAST(Message AS NVARCHAR(30)) FROM App.tbText WHERE TextId = 3005) AS PaymentCode, 
			DATEADD(HOUR, - 1, (SELECT MIN(PaidOn) FROM Cash.tbPayment WHERE CashAccountCode = cash_account.CashAccountCode)) AS PaidOn, OpeningBalance AS Paid
		FROM            Org.tbAccount cash_account 								 
		WHERE        (AccountClosed = 0) AND (AccountTypeCode = 0)
	), running_balance AS
	(
		SELECT CashAccountCode, CashCode, EntryNumber, PaymentCode, PaidOn, 
			SUM(Paid) OVER (PARTITION BY CashAccountCode ORDER BY EntryNumber ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS PaidBalance
		FROM entries
	), payments AS
	(
		SELECT     Cash.tbPayment.PaymentCode, Cash.tbPayment.CashAccountCode, Usr.tbUser.UserName, Cash.tbPayment.AccountCode, 
							  Org.tbOrg.AccountName, Cash.tbPayment.CashCode, Cash.tbCode.CashDescription, App.tbTaxCode.TaxDescription, 
							  Cash.tbPayment.PaidInValue, Cash.tbPayment.PaidOutValue, Cash.tbPayment.TaxInValue, 
							  Cash.tbPayment.TaxOutValue, Cash.tbPayment.PaymentReference, Cash.tbPayment.InsertedBy, Cash.tbPayment.InsertedOn, 
							  Cash.tbPayment.UpdatedBy, Cash.tbPayment.UpdatedOn, Cash.tbPayment.TaxCode
		FROM         Cash.tbPayment INNER JOIN
							  Usr.tbUser ON Cash.tbPayment.UserId = Usr.tbUser.UserId INNER JOIN
							  Org.tbOrg ON Cash.tbPayment.AccountCode = Org.tbOrg.AccountCode LEFT OUTER JOIN
							  App.tbTaxCode ON Cash.tbPayment.TaxCode = App.tbTaxCode.TaxCode LEFT OUTER JOIN
							  Cash.tbCode ON Cash.tbPayment.CashCode = Cash.tbCode.CashCode
	)
	SELECT running_balance.CashAccountCode, (SELECT TOP 1 StartOn FROM App.tbYearPeriod	WHERE (StartOn <= running_balance.PaidOn) ORDER BY StartOn DESC) AS StartOn, 
							running_balance.EntryNumber, running_balance.PaymentCode, running_balance.PaidOn, 
							payments.AccountName, payments.PaymentReference, payments.PaidInValue, 
							payments.PaidOutValue, CAST(running_balance.PaidBalance as decimal(18,5)) PaidBalance, payments.TaxInValue, 
							payments.TaxOutValue, payments.CashCode, 
							payments.CashDescription, payments.TaxDescription, payments.UserName, 
							payments.AccountCode, payments.TaxCode
	FROM   running_balance LEFT OUTER JOIN
							payments ON running_balance.PaymentCode = payments.PaymentCode;	

go
ALTER VIEW Cash.vwTransferCodeLookup
AS
	SELECT        Cash.tbCode.CashCode, Cash.tbCode.CashDescription, Cash.tbCategory.Category, Cash.tbMode.CashMode, Cash.tbMode.CashModeCode
	FROM            Cash.tbCode INNER JOIN
							 Cash.tbCategory ON Cash.tbCode.CategoryCode = Cash.tbCategory.CategoryCode INNER JOIN
							 Cash.tbMode ON Cash.tbCategory.CashModeCode = Cash.tbMode.CashModeCode
	WHERE (Cash.tbCode.IsEnabled <> 0) AND (Cash.tbCategory.IsEnabled <> 0) AND (Cash.tbCategory.CashTypeCode = 2) AND (Cash.tbMode.CashModeCode < 2);
go
ALTER VIEW Usr.vwDoc
AS
	WITH bank AS 
	(
		SELECT TOP (1) (SELECT AccountCode FROM App.tbOptions) AS AccountCode, CONCAT(Org.tbOrg.AccountName, SPACE(1), Org.tbAccount.CashAccountName) AS BankAccount, Org.tbAccount.SortCode AS BankSortCode, Org.tbAccount.AccountNumber AS BankAccountNumber
		FROM Org.tbAccount 
			INNER JOIN Org.tbOrg ON Org.tbAccount.AccountCode = Org.tbOrg.AccountCode
		WHERE (NOT (Org.tbAccount.CashCode IS NULL)) AND (Org.tbAccount.AccountTypeCode = 0)
	)
    SELECT        TOP (1) company.AccountName AS CompanyName, Org.tbAddress.Address AS CompanyAddress, company.PhoneNumber AS CompanyPhoneNumber,  
                              company.EmailAddress AS CompanyEmailAddress, company.WebSite AS CompanyWebsite, company.CompanyNumber, company.VatNumber, company.Logo, bank_details.BankAccount, 
                              bank_details.BankAccountNumber, bank_details.BankSortCode
     FROM            Org.tbOrg AS company INNER JOIN
                              App.tbOptions ON company.AccountCode = App.tbOptions.AccountCode LEFT OUTER JOIN
                              bank AS bank_details ON company.AccountCode = bank_details.AccountCode LEFT OUTER JOIN
                              Org.tbAddress ON company.AddressCode = Org.tbAddress.AddressCode;
go
ALTER PROCEDURE Cash.proc_PaymentPost 
AS
    SET NOCOUNT, XACT_ABORT ON;

	BEGIN TRY
		DECLARE @PaymentCode nvarchar(20)

		DECLARE curMisc cursor local for
			SELECT        Cash.tbPayment.PaymentCode
			FROM            Cash.tbPayment 
				INNER JOIN Cash.tbCode ON Cash.tbPayment.CashCode = Cash.tbCode.CashCode 
				INNER JOIN Cash.tbCategory ON Cash.tbCode.CategoryCode = Cash.tbCategory.CategoryCode
				INNER JOIN Org.tbAccount ON Org.tbAccount.CashAccountCode = Cash.tbPayment.CashAccountCode
			WHERE (Org.tbAccount.AccountTypeCode < 2)
				AND (Cash.tbPayment.PaymentStatusCode = 0) 
				AND Cash.tbPayment.UserId = (SELECT UserId FROM Usr.vwCredentials)

			ORDER BY Cash.tbPayment.AccountCode, Cash.tbPayment.PaidOn

		DECLARE curInv cursor local for
			SELECT     PaymentCode
			FROM         Cash.tbPayment
			WHERE     (PaymentStatusCode = 0) AND (CashCode IS NULL)
				AND Cash.tbPayment.UserId = (SELECT UserId FROM Usr.vwCredentials)
			ORDER BY AccountCode, PaidOn
		
		BEGIN TRANSACTION

		OPEN curMisc
		FETCH NEXT FROM curMisc INTO @PaymentCode
		WHILE @@FETCH_STATUS = 0
			BEGIN
			EXEC Cash.proc_PaymentPostMisc @PaymentCode		
			FETCH NEXT FROM curMisc INTO @PaymentCode	
			END

		CLOSE curMisc
		DEALLOCATE curMisc
	
		OPEN curInv
		FETCH NEXT FROM curInv INTO @PaymentCode
		WHILE @@FETCH_STATUS = 0
			BEGIN
			EXEC Cash.proc_PaymentPostInvoiced @PaymentCode		
			FETCH NEXT FROM curInv INTO @PaymentCode	
			END

		CLOSE curInv
		DEALLOCATE curInv

		COMMIT TRANSACTION

  	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
go
CREATE VIEW Org.vwCashAccountAssets
AS
	SELECT        Org.tbAccount.CashAccountCode, Org.tbAccount.LiquidityLevel, Org.tbAccount.CashAccountName, Org.tbAccount.AccountCode, Cash.tbCode.CashCode, Cash.tbCode.TaxCode
	FROM            Org.tbAccount INNER JOIN
							 Cash.tbCode ON Org.tbAccount.CashCode = Cash.tbCode.CashCode
	WHERE        (Org.tbAccount.AccountTypeCode = 2);
go
UPDATE Cash.tbPaymentStatus
SET PaymentStatus = 'Posted'
WHERE PaymentStatusCode = 1
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
				SELECT account.CashAccountCode, SUM(PaidInValue + (PaidOutValue * -1)) CurrentBalance
				FROM Org.tbAccount account
					JOIN assets ON account.CashAccountCode = assets.CashAccountCode
					JOIN Cash.tbPayment payment ON account.CashAccountCode = payment.CashAccountCode
				WHERE payment.PaymentStatusCode = 1
				GROUP BY account.CashAccountCode
			)
			UPDATE account
			SET CurrentBalance = balance.CurrentBalance
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
		SET CurrentBalance = balance.CurrentBalance
		FROM Org.tbAccount account
			JOIN balance ON account.CashAccountCode = balance.CashAccountCode;

	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
go
CREATE TRIGGER Cash.Cash_tbPayment_TriggerDelete
ON Cash.tbPayment
FOR DELETE
AS
	SET NOCOUNT ON;
	BEGIN TRY

		WITH assets AS
		(
			SELECT account.CashAccountCode FROM deleted d
				JOIN Org.tbAccount account ON account.CashAccountCode = d.CashAccountCode
			WHERE AccountTypeCode > 1
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
		SET CurrentBalance = balance.CurrentBalance
		FROM Org.tbAccount account
			JOIN balance ON account.CashAccountCode = balance.CashAccountCode;

	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
go
ALTER VIEW Cash.vwPaymentCode
AS
	SELECT CONCAT(LEFT((SELECT UserId FROM Usr.vwCredentials), 2), '_', FORMAT(CURRENT_TIMESTAMP, 'yyMMdd_HHmmss'), '_', DATEPART(MILLISECOND, CURRENT_TIMESTAMP)) AS PaymentCode
go
WITH workflow AS
(
	SELECT MenuId, FolderId
	FROM Usr.tbMenuEntry
	WHERE ItemText = 'Maintenance' AND Command = '0'
), new_menu_item AS
(
	SELECT workflow.MenuId, workflow.FolderId, menu_entry.ProjectName, MAX(menu_entry.ItemId) + 1 ItemId
	FROM workflow
		JOIN Usr.tbMenuEntry menu_entry ON workflow.MenuId = menu_entry.MenuId AND workflow.FolderId = menu_entry.FolderId
	GROUP BY workflow.MenuId, workflow.FolderId, menu_entry.ProjectName
)
INSERT INTO Usr.tbMenuEntry (MenuId, FolderId, ItemId, ItemText, Command, ProjectName, Argument, OpenMode)
SELECT MenuId, FolderId, ItemId, 'Assets' ItemText, 4 Command, ProjectName, 'Cash_Assets' Argument, 0 OpenMode
FROM new_menu_item;
go
ALTER VIEW Org.vwStatement 
AS
	WITH payment_data AS
	(
		SELECT Cash.tbPayment.AccountCode, Cash.tbPayment.PaidOn AS TransactedOn, 2 AS OrderBy, 
							  Cash.tbPayment.PaymentReference AS Reference, Cash.tbPaymentStatus.PaymentStatus AS StatementType, 
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
		FROM         Invoice.tbInvoice INNER JOIN
							  Invoice.tbType ON Invoice.tbInvoice.InvoiceTypeCode = Invoice.tbType.InvoiceTypeCode
	), transactions_union AS
	(
		SELECT     AccountCode, TransactedOn, OrderBy, Reference, StatementType, Charge
		FROM         payments
		UNION
		SELECT     AccountCode, TransactedOn, OrderBy, Reference, StatementType, Charge
		FROM         invoices
	), transactions AS
	(
		SELECT AccountCode, ROW_NUMBER() OVER (PARTITION BY AccountCode ORDER BY TransactedOn, OrderBy) AS RowNumber, TransactedOn, OrderBy, Reference, StatementType, Charge 
		FROM transactions_union
	), opening_balance AS
	(
		SELECT AccountCode, 0 AS RowNumber, InsertedOn AS TransactedOn, 0 AS OrderBy, NULL AS Reference, 
			(SELECT CAST(Message AS NVARCHAR) FROM App.tbText WHERE TextId = 3005) AS StatementType, OpeningBalance AS Charge
		FROM Org.tbOrg org
	), statement_data AS
	( 
		SELECT AccountCode, RowNumber, TransactedOn, OrderBy, Reference, StatementType, Charge FROM transactions
		UNION
		SELECT AccountCode, RowNumber, TransactedOn, OrderBy, Reference, StatementType, Charge FROM opening_balance
	)
	SELECT AccountCode, CAST(RowNumber AS INT) AS RowNumber, TransactedOn, OrderBy, Reference, StatementType, CAST(Charge AS float) AS Charge,
		CAST(SUM(Charge) OVER (PARTITION BY AccountCode ORDER BY RowNumber ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS float) AS Balance
	FROM statement_data;
go
ALTER TABLE Cash.tbPayment WITH NOCHECK ADD
	IsProfitAndLoss BIT NOT NULL CONSTRAINT DF_Cash_tbPayment_IsProfitAndLoss DEFAULT (1)
go
ALTER VIEW Cash.vwPaymentsUnposted
AS
	SELECT        PaymentCode, UserId, PaymentStatusCode, AccountCode, CashAccountCode, CashCode, TaxCode, PaidOn, PaidInValue, PaidOutValue, TaxInValue, TaxOutValue, PaymentReference, IsProfitAndLoss, InsertedBy, InsertedOn, 
							 UpdatedBy, UpdatedOn, RowVer
	FROM            Cash.tbPayment
	WHERE        (PaymentStatusCode = 0);
go
ALTER PROCEDURE App.proc_SystemRebuild
AS
  	SET NOCOUNT, XACT_ABORT ON;

	DECLARE @tbPartialInvoice TABLE (
			AccountCode NVARCHAR(10), 
			InvoiceNumber NVARCHAR(10),
			RefType SMALLINT,
			RefCode NVARCHAR(20),
			TotalPaidValue MONEY
			);

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

		UPDATE Cash.tbPayment
		SET
			TaxInValue = PaidInValue - CASE App.tbTaxCode.RoundingCode 
				WHEN 0 THEN ROUND((PaidInValue / (1 + TaxRate)), 2)
				WHEN 1 THEN ROUND((PaidInValue / (1 + TaxRate)), 2, 1) END, 
			TaxOutValue = PaidOutValue - CASE App.tbTaxCode.RoundingCode 
				WHEN 0 THEN ROUND((PaidOutValue / (1 + TaxRate)), 2)
				WHEN 1 THEN ROUND((PaidOutValue / (1 + TaxRate)), 2, 1) END
		FROM         Cash.tbPayment INNER JOIN
								App.tbTaxCode ON Cash.tbPayment.TaxCode = App.tbTaxCode.TaxCode;

		--Invoice Items									
		UPDATE Invoice.tbItem
		SET InvoiceValue =  ROUND(Invoice.tbItem.TotalValue / (1 + App.tbTaxCode.TaxRate), 2),
			TaxValue = TotalValue - ROUND(Invoice.tbItem.TotalValue / (1 + App.tbTaxCode.TaxRate), 2)
		FROM         Invoice.tbItem INNER JOIN
								App.tbTaxCode ON Invoice.tbItem.TaxCode = App.tbTaxCode.TaxCode INNER JOIN
								Invoice.tbInvoice ON Invoice.tbItem.InvoiceNumber = Invoice.tbInvoice.InvoiceNumber
		WHERE     ( Invoice.tbInvoice.InvoiceStatusCode <> 0) AND Invoice.tbItem.TotalValue <> 0;

		UPDATE Invoice.tbItem
		SET TaxValue = CASE App.tbTaxCode.RoundingCode 
				WHEN 0 THEN ROUND(Invoice.tbItem.InvoiceValue * App.tbTaxCode.TaxRate, 2)
				WHEN 1 THEN ROUND( Invoice.tbItem.InvoiceValue * App.tbTaxCode.TaxRate, 2, 1) END,
			InvoiceValue = CASE WHEN Invoice.tbItem.TotalValue = 0 THEN Invoice.tbItem.InvoiceValue ELSE ROUND(Invoice.tbItem.TotalValue / (1 + App.tbTaxCode.TaxRate), 2) END
		FROM         Invoice.tbItem INNER JOIN
								App.tbTaxCode ON Invoice.tbItem.TaxCode = App.tbTaxCode.TaxCode 
								INNER JOIN Invoice.tbInvoice ON Invoice.tbItem.InvoiceNumber = Invoice.tbInvoice.InvoiceNumber
		WHERE     ( Invoice.tbInvoice.InvoiceStatusCode <> 0) AND Invoice.tbItem.TotalValue = 0;

		WITH accounts_paid AS
		(
			SELECT AccountCode
			FROM Cash.tbPayment
			GROUP BY AccountCode
		)
		UPDATE Invoice.tbItem
		SET PaidValue = Invoice.tbItem.InvoiceValue,
			PaidTaxValue = Invoice.tbItem.TaxValue
		FROM Invoice.tbItem 
			JOIN Invoice.tbInvoice ON Invoice.tbItem.InvoiceNumber = Invoice.tbInvoice.InvoiceNumber
			JOIN accounts_paid ON Invoice.tbInvoice.AccountCode = accounts_paid.AccountCode 
		WHERE     ( Invoice.tbInvoice.InvoiceStatusCode <> 0);

		WITH accounts_paid AS
		(
			SELECT AccountCode
			FROM Cash.tbPayment
			GROUP BY AccountCode
		)
		UPDATE Invoice.tbItem
		SET PaidValue = 0,
			PaidTaxValue = 0
		FROM Invoice.tbItem 
			JOIN Invoice.tbInvoice ON Invoice.tbItem.InvoiceNumber = Invoice.tbInvoice.InvoiceNumber
			LEFT OUTER JOIN accounts_paid ON Invoice.tbInvoice.AccountCode = accounts_paid.AccountCode 
		WHERE (Invoice.tbInvoice.InvoiceStatusCode <> 0)
			AND (accounts_paid.AccountCode IS NULL);
                   
		UPDATE Invoice.tbTask
		SET InvoiceValue =  ROUND(Invoice.tbTask.TotalValue / (1 + App.tbTaxCode.TaxRate), 2),
			TaxValue = TotalValue - ROUND(Invoice.tbTask.TotalValue / (1 + App.tbTaxCode.TaxRate), 2)
		FROM         Invoice.tbTask INNER JOIN
								App.tbTaxCode ON Invoice.tbTask.TaxCode = App.tbTaxCode.TaxCode INNER JOIN
								Invoice.tbInvoice ON Invoice.tbTask.InvoiceNumber = Invoice.tbInvoice.InvoiceNumber
		WHERE     ( Invoice.tbInvoice.InvoiceStatusCode <> 0) AND Invoice.tbTask.TotalValue <> 0;

		UPDATE Invoice.tbTask
		SET TaxValue = CASE App.tbTaxCode.RoundingCode 
				WHEN 0 THEN ROUND(Invoice.tbTask.InvoiceValue * App.tbTaxCode.TaxRate, 2)
				WHEN 1 THEN ROUND( Invoice.tbTask.InvoiceValue * App.tbTaxCode.TaxRate, 2, 1) END,
			InvoiceValue = CASE WHEN Invoice.tbTask.TotalValue = 0 THEN Invoice.tbTask.InvoiceValue ELSE ROUND(Invoice.tbTask.TotalValue / (1 + App.tbTaxCode.TaxRate), 2) END
		FROM         Invoice.tbTask INNER JOIN
								App.tbTaxCode ON Invoice.tbTask.TaxCode = App.tbTaxCode.TaxCode 
								INNER JOIN Invoice.tbInvoice ON Invoice.tbTask.InvoiceNumber = Invoice.tbInvoice.InvoiceNumber
		WHERE     ( Invoice.tbInvoice.InvoiceStatusCode <> 0) AND Invoice.tbTask.TotalValue = 0;

		WITH accounts_paid AS
		(
			SELECT AccountCode
			FROM Cash.tbPayment
			GROUP BY AccountCode
		)
		UPDATE Invoice.tbTask
		SET PaidValue = Invoice.tbTask.InvoiceValue,
			PaidTaxValue = Invoice.tbTask.TaxValue
		FROM Invoice.tbTask 
			JOIN Invoice.tbInvoice ON Invoice.tbTask.InvoiceNumber = Invoice.tbInvoice.InvoiceNumber
			JOIN accounts_paid ON Invoice.tbInvoice.AccountCode = accounts_paid.AccountCode 
		WHERE ( Invoice.tbInvoice.InvoiceStatusCode <> 0);
				
		WITH accounts_paid AS
		(
			SELECT AccountCode
			FROM Cash.tbPayment
			GROUP BY AccountCode
		)
		UPDATE Invoice.tbTask
		SET PaidValue = 0,
			PaidTaxValue = 0
		FROM Invoice.tbTask 
			JOIN Invoice.tbInvoice ON Invoice.tbTask.InvoiceNumber = Invoice.tbInvoice.InvoiceNumber
			LEFT OUTER JOIN accounts_paid ON Invoice.tbInvoice.AccountCode = accounts_paid.AccountCode 
		WHERE (Invoice.tbInvoice.InvoiceStatusCode <> 0)
			AND (accounts_paid.AccountCode IS NULL);				
				   	
		UPDATE Invoice.tbInvoice
		SET InvoiceValue = 0, TaxValue = 0, PaidValue = 0, PaidTaxValue = 0, InvoiceStatusCode = 1
		WHERE     ( Invoice.tbInvoice.InvoiceStatusCode <> 0);
	
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
								ON Invoice.tbInvoice.InvoiceNumber = items.InvoiceNumber;

		WITH tasks AS
		(
			SELECT     Invoice.tbInvoice.InvoiceNumber, SUM( Invoice.tbTask.InvoiceValue) AS TotalInvoiceValue, SUM( Invoice.tbTask.TaxValue) AS TotalTaxValue
			FROM         Invoice.tbTask INNER JOIN
								Invoice.tbInvoice ON Invoice.tbTask.InvoiceNumber = Invoice.tbInvoice.InvoiceNumber
			WHERE   ( Invoice.tbInvoice.InvoiceStatusCode <> 0)
			GROUP BY Invoice.tbTask.InvoiceNumber, Invoice.tbInvoice.InvoiceNumber
		)
		UPDATE Invoice.tbInvoice
		SET InvoiceValue = InvoiceValue + tasks.TotalInvoiceValue, 
			TaxValue = TaxValue + tasks.TotalTaxValue
		FROM         Invoice.tbInvoice INNER JOIN tasks ON Invoice.tbInvoice.InvoiceNumber = tasks.InvoiceNumber;

		WITH accounts_paid AS
		(
			SELECT AccountCode
			FROM Cash.tbPayment
			GROUP BY AccountCode
		)
		UPDATE invoice_header
		SET              
			PaidValue = InvoiceValue, PaidTaxValue = TaxValue, InvoiceStatusCode = 3
		FROM Invoice.tbInvoice invoice_header
			JOIN accounts_paid ON invoice_header.AccountCode = accounts_paid.AccountCode
		WHERE InvoiceStatusCode > 0;

		WITH accounts_paid AS
		(
			SELECT AccountCode
			FROM Cash.tbPayment
			GROUP BY AccountCode
		)
		UPDATE invoice_header
		SET     
			PaidValue = 0, PaidTaxValue = 0, InvoiceStatusCode = 1
		FROM Invoice.tbInvoice invoice_header
			LEFT OUTER JOIN accounts_paid ON invoice_header.AccountCode = accounts_paid.AccountCode
		WHERE accounts_paid.AccountCode IS NULL AND InvoiceStatusCode > 0;


		--unpaid invoices
		WITH paid_balance AS
		(
			SELECT  AccountCode, SUM(PaidInValue + (PaidOutValue * -1)) AS PaidBalance
			FROM         Cash.tbPayment
			WHERE     (PaymentStatusCode = 1)
			GROUP BY AccountCode
		), invoice_balance AS
		(
			SELECT AccountCode, SUM(CASE Invoice.tbType.CashModeCode WHEN 0 THEN (InvoiceValue + TaxValue) * - 1 WHEN 1 THEN InvoiceValue + TaxValue ELSE 0 END) AS InvoicedBalance
			FROM         Invoice.tbInvoice INNER JOIN
								  Invoice.tbType ON Invoice.tbInvoice.InvoiceTypeCode = Invoice.tbType.InvoiceTypeCode
			GROUP BY AccountCode
		), account_balance AS
		(
			SELECT paid_balance.AccountCode, PaidBalance, InvoicedBalance, PaidBalance - InvoicedBalance AS CurrentBalance
			FROM paid_balance JOIN invoice_balance ON paid_balance.AccountCode = invoice_balance.AccountCode
		), current_balance AS
		(
			SELECT account_balance.AccountCode, ROUND(OpeningBalance + account_balance.CurrentBalance, 2) AS CurrentBalance
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

		UPDATE task
		SET PaidValue = 0, PaidTaxValue = 0
		FROM @tbPartialInvoice unpaid_task
			JOIN Invoice.tbTask task ON unpaid_task.InvoiceNumber = task.InvoiceNumber
				AND unpaid_task.RefCode = task.TaskCode	
		WHERE unpaid_task.RefType = 1 AND unpaid_task.TotalPaidValue = 0;

		UPDATE task
		SET 
			PaidTaxValue = CASE RoundingCode 
								WHEN 0 THEN ROUND((TotalPaidValue - (TotalPaidValue / (1 + TaxRate))), 2)
								WHEN 1 THEN ROUND((TotalPaidValue - (TotalPaidValue / (1 + TaxRate))), 2, 1)
							END,
			PaidValue = TotalPaidValue -
							CASE RoundingCode 
								WHEN 0 THEN ROUND((TotalPaidValue - (TotalPaidValue / (1 + TaxRate))), 2)
								WHEN 1 THEN ROUND((TotalPaidValue - (TotalPaidValue / (1 + TaxRate))), 2, 1)
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
		WHERE unpaid_task.RefType = 1 AND unpaid_task.TotalPaidValue = 0;

		UPDATE item
		SET 
			PaidTaxValue = CASE RoundingCode 
								WHEN 0 THEN ROUND((TotalPaidValue - (TotalPaidValue / (1 + TaxRate))), 2)
								WHEN 1 THEN ROUND((TotalPaidValue - (TotalPaidValue / (1 + TaxRate))), 2, 1)
							END,
			PaidValue = TotalPaidValue -
							CASE RoundingCode 
								WHEN 0 THEN ROUND((TotalPaidValue - (TotalPaidValue / (1 + TaxRate))), 2)
								WHEN 1 THEN ROUND((TotalPaidValue - (TotalPaidValue / (1 + TaxRate))), 2, 1)
							END
		FROM @tbPartialInvoice unpaid_item
			JOIN Invoice.tbItem item ON unpaid_item.InvoiceNumber = item.InvoiceNumber
				AND unpaid_item.RefCode = item.CashCode	
			JOIN App.tbTaxCode tax ON tax.TaxCode = item.TaxCode
		WHERE unpaid_item.RefType = 1 AND unpaid_item.TotalPaidValue <> 0;

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
		
		WITH invoice_summary AS
		(
			SELECT        Invoice.vwRegisterDetail.CashCode, Invoice.vwRegisterDetail.StartOn, ABS(SUM(Invoice.vwRegisterDetail.InvoiceValue)) AS InvoiceValue, ABS(SUM(Invoice.vwRegisterDetail.TaxValue)) AS TaxValue
			FROM            Invoice.vwRegisterDetail INNER JOIN
									 Cash.tbCode ON Invoice.vwRegisterDetail.CashCode = Cash.tbCode.CashCode INNER JOIN
									 Cash.tbCategory ON Cash.tbCode.CategoryCode = Cash.tbCategory.CategoryCode
			WHERE Invoice.vwRegisterDetail.StartOn < (SELECT StartOn FROM App.fnActivePeriod())
			GROUP BY Invoice.vwRegisterDetail.StartOn, Invoice.vwRegisterDetail.CashCode
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
				PaidInValue + (PaidOutValue * -1) AssetValue
			FROM Cash.tbPayment payment
				JOIN Org.tbAccount account ON payment.CashAccountCode = account.CashAccountCode
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

		--log successful rebuild
		DECLARE @Msg NVARCHAR(MAX);
		SELECT @Msg = Message FROM App.tbText WHERE TextId = 3006;
		EXEC App.proc_EventLog @EventMessage = @Msg, @EventTypeCode = 2;

  	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
go
ALTER PROCEDURE App.proc_PeriodClose
AS
 	SET NOCOUNT, XACT_ABORT ON;

	BEGIN TRY
		IF EXISTS(SELECT * FROM App.fnActivePeriod())
			BEGIN
			DECLARE @StartOn datetime, @YearNumber smallint

			SELECT @StartOn = StartOn, @YearNumber = YearNumber
			FROM App.fnActivePeriod() fnSystemActivePeriod
		 	
			EXEC Cash.proc_GeneratePeriods

			BEGIN TRAN

			UPDATE       Cash.tbPeriod
			SET                InvoiceValue = 0, InvoiceTax = 0
			FROM            Cash.tbPeriod 
			WHERE        (Cash.tbPeriod.StartOn = @StartOn);

			WITH invoice_summary AS
			(
				SELECT        Invoice.vwRegisterDetail.CashCode, Invoice.vwRegisterDetail.StartOn, ABS(SUM(Invoice.vwRegisterDetail.InvoiceValue)) AS InvoiceValue, ABS(SUM(Invoice.vwRegisterDetail.TaxValue)) AS TaxValue
				FROM            Invoice.vwRegisterDetail 
						JOIN Cash.tbCode ON Invoice.vwRegisterDetail.CashCode = Cash.tbCode.CashCode 
						JOIN Cash.tbCategory ON Cash.tbCode.CategoryCode = Cash.tbCategory.CategoryCode
				WHERE Invoice.vwRegisterDetail.StartOn = @StartOn
				GROUP BY Invoice.vwRegisterDetail.StartOn, Invoice.vwRegisterDetail.CashCode
			)
			UPDATE Cash.tbPeriod
			SET InvoiceValue = invoice_summary.InvoiceValue, 
				InvoiceTax = invoice_summary.TaxValue
			FROM    Cash.tbPeriod 
				JOIN invoice_summary ON Cash.tbPeriod.CashCode = invoice_summary.CashCode AND Cash.tbPeriod.StartOn = invoice_summary.StartOn;

			WITH asset_entries AS
			(
				SELECT payment.CashCode, 
					(SELECT TOP 1 StartOn FROM App.tbYearPeriod WHERE (StartOn <= payment.PaidOn) ORDER BY StartOn DESC) AS StartOn,
					(PaidInValue - PaidOutValue) AssetValue
				FROM Cash.tbPayment payment
					JOIN Org.tbAccount account ON payment.CashAccountCode = account.CashAccountCode
				WHERE account.AccountTypeCode = 2 AND payment.IsProfitAndLoss <> 0 AND PaidOn >= @StartOn
			), asset_summary AS
			(
				SELECT CashCode, StartOn, SUM(AssetValue) AssetValue
				FROM asset_entries
				WHERE StartOn = @StartOn
				GROUP BY CashCode, StartOn				
			)
			UPDATE Cash.tbPeriod
			SET InvoiceValue = AssetValue
			FROM  Cash.tbPeriod 
				JOIN asset_summary 
					ON Cash.tbPeriod.CashCode = asset_summary.CashCode AND Cash.tbPeriod.StartOn = asset_summary.StartOn;		
	
			UPDATE App.tbYearPeriod
			SET CashStatusCode = 2
			WHERE StartOn = @StartOn			
		
			IF NOT EXISTS (SELECT     CashStatusCode
						FROM         App.tbYearPeriod
						WHERE     (YearNumber = @YearNumber) AND (CashStatusCode < 2)) 
				BEGIN
				UPDATE App.tbYear
				SET CashStatusCode = 2
				WHERE YearNumber = @YearNumber	
				END
			IF EXISTS(SELECT * FROM App.fnActivePeriod())
				BEGIN
				UPDATE App.tbYearPeriod
				SET CashStatusCode = 1
				FROM App.fnActivePeriod() fnSystemActivePeriod INNER JOIN
									App.tbYearPeriod ON fnSystemActivePeriod.YearNumber = App.tbYearPeriod.YearNumber AND fnSystemActivePeriod.MonthNumber = App.tbYearPeriod.MonthNumber
			
				END		
			IF EXISTS(SELECT * FROM App.fnActivePeriod())
				BEGIN
				UPDATE App.tbYear
				SET CashStatusCode = 1
				FROM App.fnActivePeriod() fnSystemActivePeriod INNER JOIN
									App.tbYear ON fnSystemActivePeriod.YearNumber = App.tbYear.YearNumber  
				END

			COMMIT TRAN

			END
					
  	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
go
CREATE TABLE Cash.tbAssetType
(
	AssetTypeCode smallint NOT NULL,
	AssetType nvarchar(20) NOT NULL,
	CONSTRAINT PK_Cash_tbAssetType PRIMARY KEY CLUSTERED (AssetTypeCode)	
);
go
INSERT INTO Cash.tbAssetType (AssetTypeCode, AssetType)
VALUES (0, 'DEBTORS'), (1, 'CREDITORS'), (2, 'BANK'), (3, 'CASH'), (4, 'CASH ACCOUNTS'), (5, 'CAPITAL');
go
ALTER FUNCTION Cash.fnFlowBankBalances (@CashAccountCode NVARCHAR(10))
RETURNS TABLE
AS
	RETURN
	WITH account_periods AS
	(
		SELECT    @CashAccountCode AS CashAccountCode, App.tbYear.YearNumber, App.tbYearPeriod.StartOn
		FROM            App.tbYearPeriod INNER JOIN
								 App.tbYear ON App.tbYearPeriod.YearNumber = App.tbYear.YearNumber
		WHERE        (App.tbYear.CashStatusCode BETWEEN 1 AND 2)
	), last_entries AS
	(
		SELECT account_statement.CashAccountCode, account_statement.StartOn, MAX(account_statement.EntryNumber) As EntryNumber
		FROM Cash.vwAccountStatement account_statement 
		WHERE account_statement.CashAccountCode = @CashAccountCode
		GROUP BY account_statement.CashAccountCode, account_statement.StartOn
	), closing_balance AS
	(
		SELECT account_statement.CashAccountCode,  account_statement.StartOn, account_statement.PaidBalance 
		FROM last_entries 
			JOIN Cash.vwAccountStatement account_statement ON last_entries.CashAccountCode = account_statement.CashAccountCode
				AND last_entries.EntryNumber = account_statement.EntryNumber
	), statement_ordered AS
	(
		SELECT 
			ROW_NUMBER() OVER (ORDER BY account_periods.StartOn) EntryNumber,
			account_periods.CashAccountCode, account_periods.YearNumber, account_periods.StartOn, CAST(COALESCE(closing_balance.PaidBalance, 0) as float) Balance,
			CASE WHEN closing_balance.CashAccountCode IS NULL THEN CAST(0 as bit) ELSE CAST(1 as bit) END IsEntry
		FROM account_periods
			LEFT OUTER JOIN closing_balance 
				ON account_periods.CashAccountCode = closing_balance.CashAccountCode AND account_periods.StartOn = closing_balance.StartOn
	), statement_ranked AS
	(
		SELECT *,
			RANK() OVER (ORDER BY EntryNumber) RNK
		FROM statement_ordered
	), statement_grouped AS
	(
		SELECT EntryNumber, CashAccountCode, YearNumber, StartOn, Balance, IsEntry,
			MAX(CASE IsEntry WHEN 0 THEN 0 ELSE RNK END) OVER (ORDER BY EntryNumber) RNK
		FROM statement_ranked
	)
	SELECT CashAccountCode, YearNumber, StartOn, 
		CASE IsEntry WHEN 0 THEN
			MAX(Balance) OVER (PARTITION BY RNK ORDER BY EntryNumber) +
			MIN(Balance) OVER (PARTITION BY RNK ORDER BY EntryNumber) 
		ELSE
			Balance
		END
		AS Balance		
	FROM statement_grouped;
go
ALTER VIEW Cash.vwFlowVatPeriodTotals
AS
	WITH active_periods AS
	(
		SELECT App.tbYear.YearNumber, App.tbYearPeriod.StartOn
		FROM            App.tbYearPeriod INNER JOIN
								 App.tbMonth ON App.tbYearPeriod.MonthNumber = App.tbMonth.MonthNumber INNER JOIN
								 App.tbYear ON App.tbYearPeriod.YearNumber = App.tbYear.YearNumber
		WHERE        (App.tbYear.CashStatusCode < 3)
	)
	SELECT     active_periods.YearNumber, active_periods.StartOn,	
		CAST(ISNULL(SUM(vat.HomeSales), 0) as decimal(18, 5)) AS HomeSales, 
		CAST(ISNULL(SUM(vat.HomePurchases), 0) as decimal(18, 5)) AS HomePurchases, 
		CAST(ISNULL(SUM(vat.ExportSales), 0) as decimal(18, 5)) AS ExportSales, 
		CAST(ISNULL(SUM(vat.ExportPurchases), 0) as decimal(18, 5)) AS ExportPurchases, 
		CAST(ISNULL(SUM(vat.HomeSalesVat), 0) as decimal(18, 5)) AS HomeSalesVat, 
		CAST(ISNULL(SUM(vat.HomePurchasesVat), 0) as decimal(18, 5)) AS HomePurchasesVat, 
		CAST(ISNULL(SUM(vat.ExportSalesVat), 0) as decimal(18, 5)) AS ExportSalesVat, 
		CAST(ISNULL(SUM(vat.ExportPurchasesVat), 0) as decimal(18, 5)) AS ExportPurchasesVat, 
		CAST(ISNULL(SUM(vat.VatDue), 0) as decimal(18, 5)) AS VatDue
	FROM            active_periods LEFT OUTER JOIN
							 Cash.vwTaxVatSummary AS vat ON active_periods.StartOn = vat.StartOn
	GROUP BY active_periods.YearNumber, active_periods.StartOn;
go
ALTER VIEW Cash.vwFlowVatRecurrence
AS
		WITH active_periods AS
	(
		SELECT App.tbYear.YearNumber, App.tbYearPeriod.StartOn
		FROM            App.tbYearPeriod INNER JOIN
								 App.tbMonth ON App.tbYearPeriod.MonthNumber = App.tbMonth.MonthNumber INNER JOIN
								 App.tbYear ON App.tbYearPeriod.YearNumber = App.tbYear.YearNumber
		WHERE        (App.tbYear.CashStatusCode < 3)
	)
	SELECT active_periods.YearNumber, active_periods.StartOn, 
		CAST(ISNULL(SUM(vat.HomeSales), 0) as decimal(18, 5)) AS HomeSales, 
		CAST(ISNULL(SUM(vat.HomePurchases), 0) as decimal(18, 5)) AS HomePurchases, 
		CAST(ISNULL(SUM(vat.ExportSales), 0) as decimal(18, 5)) AS ExportSales, 
		CAST(ISNULL(SUM(vat.ExportPurchases), 0) as decimal(18, 5)) AS ExportPurchases, 
		CAST(ISNULL(SUM(vat.HomeSalesVat), 0) as decimal(18, 5)) AS HomeSalesVat, 
		CAST(ISNULL(SUM(vat.HomePurchasesVat), 0) as decimal(18, 5)) AS HomePurchasesVat, 
		CAST(ISNULL(SUM(vat.ExportSalesVat), 0) as decimal(18, 5)) AS ExportSalesVat, 
		CAST(ISNULL(SUM(vat.ExportPurchasesVat), 0) as decimal(18, 5)) AS ExportPurchasesVat, 
		CAST(ISNULL(SUM(vat.VatAdjustment), 0) as decimal(18, 5)) AS VatAdjustment, 
		CAST(ISNULL(SUM(vat.VatDue), 0) as decimal(18, 5)) AS VatDue
	FROM active_periods LEFT OUTER JOIN
							 Cash.vwTaxVatTotals AS vat ON active_periods.StartOn = vat.StartOn
	GROUP BY active_periods.YearNumber, active_periods.StartOn;
go
CREATE VIEW Cash.vwCategoryCapital
AS
	SELECT DISTINCT category.CategoryCode, category.Category, category.DisplayOrder, cat_type.CategoryType, cash_type.CashType, cash_mode.CashMode,
		cat_type.CategoryTypeCode, cash_type.CashTypeCode, cash_mode.CashModeCode
	FROM Org.tbAccount account
		JOIN Cash.tbCode cash_code ON account.CashCode = cash_code.CashCode
		JOIN Cash.tbCategory category ON cash_code.CategoryCode = category.CategoryCode
		JOIN Cash.tbType cash_type ON category.CashTypeCode = cash_type.CashTypeCode
		JOIN Cash.tbCategoryType cat_type ON category.CategoryTypeCode = cat_type.CategoryTypeCode
		JOIN Cash.tbMode cash_mode ON category.CashModeCode = cash_mode.CashModeCode
	WHERE (AccountTypeCode = 2);
go
ALTER VIEW Cash.vwCategoryTotalCandidates
AS
	SELECT Cash.tbCategory.CategoryCode, Cash.tbCategory.Category, Cash.tbCategoryType.CategoryType, Cash.tbType.CashType, Cash.tbMode.CashMode
	FROM   Cash.tbCategory INNER JOIN
				Cash.tbCategoryType ON Cash.tbCategory.CategoryTypeCode = Cash.tbCategoryType.CategoryTypeCode INNER JOIN
				Cash.tbType ON Cash.tbCategory.CashTypeCode = Cash.tbType.CashTypeCode INNER JOIN
				Cash.tbMode ON Cash.tbCategory.CashModeCode = Cash.tbMode.CashModeCode
	WHERE        (Cash.tbCategory.CashTypeCode < 2) AND (Cash.tbCategory.IsEnabled <> 0)
	UNION
	SELECT CategoryCode, Category, CategoryType, CashType, CashMode
	FROM Cash.vwCategoryCapital
go
DROP FUNCTION Cash.fnFlowCategory
go
CREATE FUNCTION Cash.fnFlowCategory(@CashTypeCode smallint)
RETURNS @tbCategory TABLE (CategoryCode nvarchar(10), Category nvarchar(50), CashModeCode smallint, DisplayOrder smallint)
AS
BEGIN
	IF NOT EXISTS (SELECT * FROM Cash.vwCategoryCapital capital 
						JOIN Cash.tbCategory category ON capital.CategoryCode = category.CategoryCode 
						WHERE (category.CategoryTypeCode = 0) AND (category.CashTypeCode = @CashTypeCode) AND (category.IsEnabled <> 0))
	BEGIN
		INSERT INTO @tbCategory (CategoryCode, Category, CashModeCode, DisplayOrder)
		SELECT CategoryCode, Category, CashModeCode, DisplayOrder
		FROM Cash.tbCategory
		WHERE (CategoryTypeCode = 0) AND (CashTypeCode = @CashTypeCode) AND (IsEnabled <> 0)		
	END
	ELSE
	BEGIN
		INSERT INTO @tbCategory (CategoryCode, Category, CashModeCode, DisplayOrder)
		SELECT CategoryCode, Category, CashModeCode, DisplayOrder
		FROM Cash.vwCategoryCapital
	END

	RETURN
END
go
CREATE VIEW Cash.vwCurrentAccount
AS
	SELECT TOP 1 CashAccountCode, LiquidityLevel 
	FROM Org.tbAccount 
			JOIN Cash.tbCode ON Org.tbAccount.CashCode = Cash.tbCode.CashCode 
			JOIN Cash.tbCategory ON Cash.tbCode.CategoryCode = Cash.tbCategory.CategoryCode
	WHERE (Cash.tbCategory.CashTypeCode = 2) AND (Org.tbAccount.AccountTypeCode = 0) AND (Org.tbAccount.AccountClosed = 0)
	ORDER BY CashAccountCode
go
ALTER PROCEDURE Cash.proc_CurrentAccount(@CashAccountCode NVARCHAR(10) OUTPUT)
AS
	SET NOCOUNT, XACT_ABORT ON;
	BEGIN TRY
		SELECT  @CashAccountCode = CashAccountCode
		FROM Cash.vwCurrentAccount;
	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
go
CREATE VIEW Cash.vwReserveAccount
AS
	SELECT TOP 1 CashAccountCode, LiquidityLevel 
	FROM Org.tbAccount 
			LEFT OUTER JOIN Cash.tbCode ON Org.tbAccount.CashCode = Cash.tbCode.CashCode 
	WHERE (Cash.tbCode.CashCode) IS NULL AND (Org.tbAccount.AccountTypeCode = 0) AND (Org.tbAccount.AccountClosed = 0)
	ORDER BY CashAccountCode
go
ALTER PROCEDURE Cash.proc_ReserveAccount(@CashAccountCode NVARCHAR(10) OUTPUT)
AS
	SET NOCOUNT, XACT_ABORT ON;
	BEGIN TRY
		SELECT  @CashAccountCode = CashAccountCode
		FROM Cash.vwReserveAccount;
	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
go
ALTER VIEW Cash.vwBankAccounts
AS
	SELECT CashAccountCode, CashAccountName, OpeningBalance, CASE WHEN NOT CashCode IS NULL THEN 0 ELSE 1 END AS DisplayOrder
	FROM Org.tbAccount  
	WHERE (AccountTypeCode = 0)
go

CREATE VIEW Cash.vwBalanceSheetPeriods
AS
	WITH financial_periods AS
	(
		SELECT yr.YearNumber, pd.StartOn
		FROM App.tbYear yr
			JOIN App.tbYearPeriod pd ON yr.YearNumber = pd.YearNumber
		WHERE (yr.CashStatusCode BETWEEN 1 AND 2)
	), assets AS
	(
		SELECT CashAccountCode AssetCode, CashAccountName AssetName, LiquidityLevel, 4 AssetTypeCode, 
			category.CashModeCode,
			YearNumber, StartOn
		FROM Org.tbAccount account
			JOIN Cash.tbCode cash_code ON account.CashCode = cash_code.CashCode
			JOIN Cash.tbCategory category ON cash_code.CategoryCode = category.CategoryCode
			CROSS JOIN financial_periods
		WHERE (AccountTypeCode= 2) AND (AccountClosed = 0)
	), cash AS
	(
		SELECT CashAccountCode AssetCode, AssetType AssetName, LiquidityLevel, AssetTypeCode, 1 CashModeCode, YearNumber, StartOn
		FROM Cash.tbAssetType
			CROSS JOIN Cash.vwCurrentAccount 
			CROSS JOIN financial_periods
		WHERE AssetTypeCode = 3
	), bank AS
	(
		SELECT CashAccountCode AssetCode, AssetType AssetName, LiquidityLevel, AssetTypeCode, 1 CashModeCode, YearNumber, StartOn
		FROM Cash.tbAssetType
			CROSS JOIN Cash.vwReserveAccount 
			CROSS JOIN financial_periods
		WHERE AssetTypeCode = 2
	), orgs AS
	(
		SELECT CashAccountCode AssetCode, AssetType AssetName, LiquidityLevel, AssetTypeCode,
			CASE AssetTypeCode WHEN 0 THEN 1 ELSE 0 END CashModeCode,
			YearNumber, StartOn
		FROM Cash.tbAssetType
			CROSS JOIN Cash.vwCurrentAccount
			CROSS JOIN financial_periods
		WHERE AssetTypeCode BETWEEN 0 AND 1
	), asset_code_periods AS
	(
		SELECT AssetCode, AssetName, CashModeCode, LiquidityLevel, AssetTypeCode, YearNumber, StartOn FROM assets
		UNION 
		SELECT AssetCode, AssetName, CashModeCode, LiquidityLevel, AssetTypeCode, YearNumber, StartOn FROM cash
		UNION
		SELECT AssetCode, AssetName, CashModeCode, LiquidityLevel, AssetTypeCode, YearNumber, StartOn FROM bank
		UNION
		SELECT AssetCode, AssetName, CashModeCode, LiquidityLevel, AssetTypeCode, YearNumber, StartOn FROM orgs
	)
	SELECT AssetCode, AssetName, CashModeCode, LiquidityLevel, AssetTypeCode, YearNumber, StartOn, CAST(0 as bit) IsEntry
	FROM asset_code_periods;
go
CREATE VIEW Cash.vwBalanceStartOn
AS
	SELECT MIN(App.tbYearPeriod.StartOn) StartOn
	FROM  App.tbYearPeriod 
		JOIN App.tbYear ON App.tbYearPeriod.YearNumber = App.tbYear.YearNumber
	WHERE (App.tbYear.CashStatusCode < 3) AND (App.tbYearPeriod.CashStatusCode < 3)
go
CREATE VIEW Org.vwAssetStatement
AS
	WITH payment_data AS
	(
		SELECT Cash.tbPayment.AccountCode, Cash.tbPayment.PaidOn AS TransactedOn, 2 AS OrderBy, 
				CASE WHEN PaidInValue > 0 THEN PaidInValue - TaxInValue ELSE (PaidOutValue - TaxOutValue) * - 1 END AS Charge
		FROM Cash.tbPayment 
			JOIN Org.tbAccount ON Cash.tbPayment.CashAccountCode = Org.tbAccount.CashAccountCode
			JOIN Cash.tbPaymentStatus ON Cash.tbPayment.PaymentStatusCode = Cash.tbPaymentStatus.PaymentStatusCode
		WHERE Org.tbAccount.AccountTypeCode < 2
	), payments AS
	(
		SELECT     AccountCode, TransactedOn, OrderBy, SUM(Charge) AS Charge
		FROM     payment_data
		GROUP BY AccountCode, TransactedOn, OrderBy
	), invoices AS
	(
		SELECT Invoice.tbInvoice.AccountCode, Invoice.tbInvoice.InvoicedOn AS TransactedOn, 1 AS OrderBy, 
			CASE CashModeCode 
				WHEN 0 THEN Invoice.tbInvoice.InvoiceValue 
				WHEN 1 THEN Invoice.tbInvoice.InvoiceValue  * - 1 
			END AS Charge
		FROM         Invoice.tbInvoice INNER JOIN
							  Invoice.tbType ON Invoice.tbInvoice.InvoiceTypeCode = Invoice.tbType.InvoiceTypeCode
	), transactions_union AS
	(
		SELECT     AccountCode, TransactedOn, OrderBy, Charge
		FROM         payments
		UNION
		SELECT     AccountCode, TransactedOn, OrderBy, Charge
		FROM         invoices
	), transactions AS
	(
		SELECT AccountCode, ROW_NUMBER() OVER (PARTITION BY AccountCode ORDER BY TransactedOn, OrderBy) AS RowNumber, TransactedOn, OrderBy, Charge 
		FROM transactions_union
	), opening_balance AS
	(
		SELECT AccountCode, 0 AS RowNumber, InsertedOn AS TransactedOn, 0 AS OrderBy, OpeningBalance AS Charge
		FROM Org.tbOrg org
	), statement_data AS
	( 
		SELECT AccountCode, RowNumber, TransactedOn, OrderBy, Charge FROM transactions
		UNION
		SELECT AccountCode, RowNumber, TransactedOn, OrderBy, Charge FROM opening_balance
	)
	SELECT AccountCode, CAST(RowNumber AS INT) AS RowNumber, TransactedOn, OrderBy, CAST(Charge AS float) AS Charge,
		CAST(SUM(Charge) OVER (PARTITION BY AccountCode ORDER BY RowNumber ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS float) AS Balance
	FROM statement_data;
go
CREATE VIEW Cash.vwBalanceSheetOrgs
AS
	WITH financial_periods AS
	(
		SELECT pd.StartOn
		FROM App.tbYear yr
			JOIN App.tbYearPeriod pd ON yr.YearNumber = pd.YearNumber
		WHERE (yr.CashStatusCode BETWEEN 1 AND 2)
	), org_periods AS
	(
		SELECT AccountCode, StartOn, CashModeCode
		FROM Org.tbOrg orgs
			JOIN Org.tbType org_types ON orgs.OrganisationTypeCode = org_types.OrganisationTypeCode
			CROSS JOIN financial_periods	
	), org_statements AS
	(
		SELECT (SELECT TOP 1 StartOn FROM App.tbYearPeriod	WHERE (StartOn <= os.TransactedOn) ORDER BY StartOn DESC) AS StartOn, 
			AccountCode, os.RowNumber, TransactedOn, Balance
		FROM Org.vwAssetStatement os
		WHERE TransactedOn >= (SELECT StartOn FROM Cash.vwBalanceStartOn)
	), org_last_tx AS
	(
		SELECT AccountCode, MAX(RowNumber) RowNumber
		FROM org_statements
		GROUP BY AccountCode, StartOn
	), org_last_balance AS
	(
		SELECT org_statements.AccountCode, org_statements.StartOn, org_statements.Balance, t.CashModeCode
		FROM org_statements 
			JOIN org_last_tx ON org_statements.AccountCode = org_last_tx.AccountCode AND org_statements.RowNumber = org_last_tx.RowNumber
			JOIN Org.tbOrg o ON org_statements.AccountCode = o.AccountCode
			JOIN Org.tbType t ON o.OrganisationTypeCode = t.OrganisationTypeCode
	)
	, org_balances AS
	(
		SELECT AccountCode, StartOn, CashModeCode,
			CASE CashModeCode WHEN 0 THEN MIN(Balance) WHEN 1 THEN MAX(Balance) ELSE MIN(Balance) END Balance
		FROM org_last_balance
		GROUP BY AccountCode, StartOn, CashModeCode
	), org_ordered AS
	(
		SELECT ROW_NUMBER() OVER (ORDER BY org_periods.AccountCode, org_periods.StartOn) EntryNumber,
			org_periods.AccountCode, org_periods.StartOn, 
			CASE WHEN org_balances.CashModeCode IS NULL THEN org_periods.CashModeCode ELSE org_balances.CashModeCode END CashModeCode, 
			COALESCE(Balance, 0) Balance,
			CASE WHEN org_balances.StartOn IS NULL THEN 0 ELSE 1 END IsEntry
		FROM org_periods
			LEFT OUTER JOIN org_balances 
				ON org_periods.AccountCode = org_balances.AccountCode AND org_periods.StartOn = org_balances.StartOn
	), org_ranked AS
	(
		SELECT *,
			RANK() OVER (PARTITION BY AccountCode, CashModeCode, IsEntry ORDER BY EntryNumber) RNK
		FROM org_ordered
	), org_grouped AS
	(
		SELECT EntryNumber, AccountCode, StartOn, CashModeCode, IsEntry, Balance,
			MAX(CASE IsEntry WHEN 0 THEN 0 ELSE RNK END) OVER (PARTITION BY AccountCode, CashModeCode ORDER BY EntryNumber) RNK
		FROM org_ranked
	), org_projected AS
	(
		SELECT EntryNumber, AccountCode, StartOn, CashModeCode, IsEntry,
			CASE IsEntry WHEN 0 THEN
				MAX(Balance) OVER (PARTITION BY AccountCode, CashModeCode, RNK ORDER BY EntryNumber) +
				MIN(Balance) OVER (PARTITION BY AccountCode, CashModeCode, RNK ORDER BY EntryNumber) 
			ELSE
				Balance
			END
			AS Balance
		FROM org_grouped	
	), org_polarity AS
	(
		SELECT StartOn, SUM(Balance) * -1 Balance, CashModeCode
		FROM org_projected
		GROUP BY StartOn, CashModeCode
	), org_base AS
	(
		SELECT 			
			CashModeCode,
			CASE WHEN Balance >= 0 THEN 0 ELSE 1 END AssetTypeCode, StartOn, Balance
		FROM org_polarity
	)
	SELECT 
		(SELECT CashAccountCode FROM Cash.vwCurrentAccount) AssetCode,
		AssetType AssetName, CashModeCode, asset_type.AssetTypeCode, StartOn, Balance
	FROM org_base
		JOIN Cash.tbAssetType asset_type ON org_base.AssetTypeCode = asset_type.AssetTypeCode;
go
CREATE VIEW Cash.vwBalanceSheetAccounts
AS
	WITH account_statements AS
	(
		SELECT 
			account_statement.CashAccountCode, 
			StartOn, EntryNumber, PaidBalance
		FROM Cash.vwAccountStatement account_statement
			JOIN Org.tbAccount account ON account_statement.CashAccountCode = account.CashAccountCode
		WHERE StartOn >= (SELECT StartOn FROM Cash.vwBalanceStartOn) AND account.AccountTypeCode < 2
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
CREATE VIEW Cash.vwBalanceSheetAssets
AS
	WITH asset_statements AS
	(
		SELECT account_statement.CashAccountCode, StartOn, EntryNumber, PaidBalance
		FROM Cash.vwAccountStatement account_statement
			JOIN Org.tbAccount account ON account_statement.CashAccountCode = account.CashAccountCode
		WHERE StartOn >= (SELECT StartOn FROM Cash.vwBalanceStartOn) AND account.AccountTypeCode = 2
	), asset_last_tx AS
	(
		SELECT CashAccountCode, MAX(EntryNumber) EntryNumber
		FROM asset_statements
		GROUP BY CashAccountCode, StartOn
	), asset_polarity AS
	(
		SELECT asset_statements.CashAccountCode, asset_statements.StartOn, SUM(asset_statements.PaidBalance) Balance
		FROM asset_statements
			JOIN asset_last_tx ON asset_statements.CashAccountCode = asset_last_tx.CashAccountCode AND asset_statements.EntryNumber = asset_last_tx.EntryNumber
		GROUP BY asset_statements.CashAccountCode, asset_statements.StartOn
	), asset_base AS
	(
		SELECT CashAccountCode, asset_polarity.StartOn, asset_polarity.Balance, CASE WHEN Balance < 0 THEN 0 ELSE 1 END CashModeCode
		FROM asset_polarity
	)
	SELECT account.CashAccountCode AssetCode, account.CashAccountName AssetName, CashModeCode, 4 AssetTypeCode, StartOn, Balance
	FROM asset_base
		JOIN Org.tbAccount account ON asset_base.CashAccountCode = account.CashAccountCode;

go
CREATE VIEW Cash.vwBalanceSheet
AS
	WITH balance_sheets AS
	(
		SELECT AssetCode, AssetName, CashModeCode, AssetTypeCode, StartOn, Balance FROM Cash.vwBalanceSheetOrgs
		UNION
		SELECT AssetCode, AssetName, CashModeCode, AssetTypeCode, StartOn, Balance FROM Cash.vwBalanceSheetAccounts
		UNION 
		SELECT AssetCode, AssetName, CashModeCode, AssetTypeCode, StartOn, Balance FROM Cash.vwBalanceSheetAssets
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

