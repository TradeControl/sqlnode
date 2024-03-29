/**************************************************************************************
Trade Control
Upgrade script for ASP.NET Core interface
Release 3.34.6

Date: 22 June 2021
Author: IAM

Trade Control by Trade Control Ltd is licensed under GNU General Public License v3.0. 

You may obtain a copy of the License at

	https://www.gnu.org/licenses/gpl-3.0.en.html


***********************************************************************************/
go
CREATE PROCEDURE Cash.proc_PaymentPostById(@UserId nvarchar(10)) 
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
				AND (Cash.tbPayment.UserId = @UserId)

			ORDER BY Cash.tbPayment.AccountCode, Cash.tbPayment.PaidOn

		DECLARE curInv cursor local for
			SELECT     PaymentCode
			FROM         Cash.tbPayment
			WHERE     (PaymentStatusCode = 0) AND (CashCode IS NULL)
				AND (Cash.tbPayment.UserId = @UserId)
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
ALTER PROCEDURE Cash.proc_PaymentPost
AS
	DECLARE @UserId nvarchar(10) = (SELECT UserId FROM Usr.vwCredentials);
	EXECUTE Cash.proc_PaymentPostById @UserId;
go
CREATE VIEW Org.vwCashAccounts
	AS
	SELECT        Org.tbAccount.CashAccountCode, Org.tbOrg.AccountCode, Org.tbAccount.CashAccountName, Org.tbOrg.AccountName, Org.tbType.OrganisationType, Org.tbAccount.OpeningBalance, Org.tbAccount.CurrentBalance, 
							 Org.tbAccount.SortCode, Org.tbAccount.AccountNumber, Org.tbAccount.AccountClosed, Org.tbAccountType.AccountType
	FROM            Org.tbOrg INNER JOIN
							 Org.tbAccount ON Org.tbOrg.AccountCode = Org.tbAccount.AccountCode INNER JOIN
							 Org.tbType ON Org.tbOrg.OrganisationTypeCode = Org.tbType.OrganisationTypeCode INNER JOIN
							 Org.tbAccountType ON Org.tbAccount.AccountTypeCode = Org.tbAccountType.AccountTypeCode;
go
IF EXISTS(SELECT * FROM sys.indexes WHERE [name] = 'IX_Org_tbAccount_CashAccountName')
	DROP INDEX IX_Org_tbAccount_CashAccountName ON Org.tbAccount;
go
CREATE UNIQUE NONCLUSTERED INDEX IX_Org_tbAccount_CashAccountName ON Org.tbAccount (CashAccountName ASC);
go
ALTER VIEW Cash.vwTransferCodeLookup
AS
	SELECT        Cash.tbCode.CashCode, Cash.tbCode.CashDescription, Cash.tbCategory.Category, Cash.tbMode.CashMode, Cash.tbMode.CashModeCode
	FROM            Cash.tbCode INNER JOIN
							 Cash.tbCategory ON Cash.tbCode.CategoryCode = Cash.tbCategory.CategoryCode INNER JOIN
							 Cash.tbMode ON Cash.tbCategory.CashModeCode = Cash.tbMode.CashModeCode LEFT OUTER JOIN
							 Org.tbAccount ON Cash.tbCode.CashCode = Org.tbAccount.CashCode
	WHERE        (Cash.tbCode.IsEnabled <> 0) AND (Cash.tbCategory.IsEnabled <> 0) AND (Cash.tbCategory.CashTypeCode = 2) AND (Cash.tbMode.CashModeCode < 2) AND (Org.tbAccount.CashAccountCode IS NULL)
go
ALTER VIEW Org.vwCashAccounts
AS
	SELECT        Org.tbAccount.CashAccountCode, Org.tbOrg.AccountCode, Org.tbAccount.CashAccountName, Org.tbOrg.AccountName, Org.tbType.OrganisationType, Org.tbAccount.OpeningBalance, Org.tbAccount.CurrentBalance, 
							 Org.tbAccount.SortCode, Org.tbAccount.AccountNumber, Org.tbAccount.AccountClosed, Org.tbAccountType.AccountType, Org.tbAccount.CashCode, Cash.tbCode.CashDescription, Org.tbAccount.InsertedBy, 
							 Org.tbAccount.InsertedOn, Org.tbAccount.LiquidityLevel
	FROM            Org.tbOrg INNER JOIN
							 Org.tbAccount ON Org.tbOrg.AccountCode = Org.tbAccount.AccountCode INNER JOIN
							 Org.tbType ON Org.tbOrg.OrganisationTypeCode = Org.tbType.OrganisationTypeCode INNER JOIN
							 Org.tbAccountType ON Org.tbAccount.AccountTypeCode = Org.tbAccountType.AccountTypeCode LEFT OUTER JOIN
							 Cash.tbCode ON Org.tbAccount.CashCode = Cash.tbCode.CashCode AND Org.tbAccount.CashCode = Cash.tbCode.CashCode AND Org.tbAccount.CashCode = Cash.tbCode.CashCode
go
ALTER VIEW Cash.vwBankCashCodes
AS
	SELECT        Cash.tbCode.CashCode, Cash.tbCode.CashDescription, Cash.tbCode.TaxCode, Cash.tbCategory.CashModeCode
	FROM            Cash.tbCode INNER JOIN
							 Cash.tbCategory ON Cash.tbCode.CategoryCode = Cash.tbCategory.CategoryCode LEFT OUTER JOIN
							 Cash.vwTransferCodeLookup ON Cash.tbCode.CashCode = Cash.vwTransferCodeLookup.CashCode
	WHERE        (Cash.tbCategory.CashTypeCode = 2) AND (Cash.vwTransferCodeLookup.CashCode IS NULL)
go
ALTER VIEW Org.vwCashAccountAssets
AS
	SELECT        Org.tbAccount.CashAccountCode, Org.tbAccount.LiquidityLevel, Org.tbAccount.CashAccountName, Org.tbAccount.AccountCode, Cash.tbCode.CashCode, Cash.tbCode.TaxCode, Org.tbAccount.AccountClosed
	FROM            Org.tbAccount INNER JOIN
							 Cash.tbCode ON Org.tbAccount.CashCode = Cash.tbCode.CashCode
	WHERE        (Org.tbAccount.AccountTypeCode = 2);
go
CREATE VIEW Org.vwAddressList
AS
	SELECT        Org.tbOrg.AccountCode, Org.tbAddress.AddressCode, Org.tbOrg.AccountName, Org.tbStatus.OrganisationStatusCode, Org.tbStatus.OrganisationStatus, Org.tbType.OrganisationTypeCode, Org.tbType.OrganisationType, 
							 Org.tbAddress.Address, Org.tbAddress.InsertedBy, Org.tbAddress.InsertedOn, CAST(CASE WHEN Org.tbAddress.AddressCode = Org.tbOrg.AddressCode THEN 1 ELSE 0 END AS bit) AS IsAdminAddress
	FROM            Org.tbOrg INNER JOIN
							 Org.tbAddress ON Org.tbOrg.AccountCode = Org.tbAddress.AccountCode INNER JOIN
							 Org.tbStatus ON Org.tbOrg.OrganisationStatusCode = Org.tbStatus.OrganisationStatusCode INNER JOIN
							 Org.tbType ON Org.tbOrg.OrganisationTypeCode = Org.tbType.OrganisationTypeCode
go
CREATE VIEW Org.vwAccountLookupAll
AS
	SELECT Org.tbOrg.AccountCode, Org.tbOrg.AccountName, Org.tbOrg.OrganisationTypeCode, Org.tbType.OrganisationType, Cash.tbMode.CashMode, Cash.tbMode.CashModeCode, Org.tbOrg.OrganisationStatusCode, Org.tbStatus.OrganisationStatus
	FROM Org.tbOrg 
		JOIN Org.tbType ON Org.tbOrg.OrganisationTypeCode = Org.tbType.OrganisationTypeCode
		JOIN Cash.tbMode ON Org.tbType.CashModeCode = Cash.tbMode.CashModeCode 
		JOIN Org.tbStatus ON Org.tbOrg.OrganisationStatusCode = Org.tbStatus.OrganisationStatusCode;

go
ALTER VIEW Org.vwContacts
AS
	WITH ContactCount AS 
	(
		SELECT ContactName, COUNT(TaskCode) AS Tasks
        FROM Task.tbTask
        WHERE (TaskStatusCode < 2)
        GROUP BY ContactName
        HAVING (ContactName IS NOT NULL)
	)
    SELECT Org.tbContact.ContactName, Org.tbOrg.AccountCode, COALESCE(ContactCount.Tasks, 0) Tasks, Org.tbContact.PhoneNumber, Org.tbContact.HomeNumber, Org.tbContact.MobileNumber,  
                              Org.tbContact.EmailAddress, Org.tbOrg.AccountName, Org.tbType.OrganisationType, Org.tbStatus.OrganisationStatus, Org.tbContact.NameTitle, Org.tbContact.NickName, Org.tbContact.JobTitle, 
                              Org.tbContact.Department, Org.tbContact.Information, Org.tbContact.InsertedBy, Org.tbContact.InsertedOn
     FROM            Org.tbOrg INNER JOIN
                              Org.tbType ON Org.tbOrg.OrganisationTypeCode = Org.tbType.OrganisationTypeCode INNER JOIN
                              Org.tbStatus ON Org.tbOrg.OrganisationStatusCode = Org.tbStatus.OrganisationStatusCode INNER JOIN
                              Org.tbContact ON Org.tbOrg.AccountCode = Org.tbContact.AccountCode LEFT OUTER JOIN
                              ContactCount ON Org.tbContact.ContactName = ContactCount.ContactName
     WHERE        (Org.tbOrg.OrganisationStatusCode < 3);
go
CREATE VIEW Invoice.vwEntry
AS
	SELECT        Invoice.tbEntry.UserId, Usr.tbUser.UserName, Invoice.tbEntry.AccountCode, Org.tbOrg.AccountName, Invoice.tbEntry.CashCode, Cash.tbCode.CashDescription, Invoice.tbEntry.InvoiceTypeCode, Invoice.tbType.InvoiceType, 
							 Invoice.tbEntry.InvoicedOn, Invoice.tbEntry.TaxCode, App.tbTaxCode.TaxDescription, Cash.tbTaxType.TaxType, Invoice.tbEntry.ItemReference, Invoice.tbEntry.TotalValue, Invoice.tbEntry.InvoiceValue, 
							 Invoice.tbEntry.InvoiceValue + Invoice.tbEntry.TotalValue AS EntryValue
	FROM            Invoice.tbEntry INNER JOIN
							 Org.tbOrg ON Invoice.tbEntry.AccountCode = Org.tbOrg.AccountCode INNER JOIN
							 Cash.tbCode ON Invoice.tbEntry.CashCode = Cash.tbCode.CashCode INNER JOIN
							 Invoice.tbType ON Invoice.tbEntry.InvoiceTypeCode = Invoice.tbType.InvoiceTypeCode INNER JOIN
							 Usr.tbUser ON Invoice.tbEntry.UserId = Usr.tbUser.UserId INNER JOIN
							 App.tbTaxCode ON Invoice.tbEntry.TaxCode = App.tbTaxCode.TaxCode INNER JOIN
							 Cash.tbTaxType ON App.tbTaxCode.TaxTypeCode = Cash.tbTaxType.TaxTypeCode AND App.tbTaxCode.TaxTypeCode = Cash.tbTaxType.TaxTypeCode AND App.tbTaxCode.TaxTypeCode = Cash.tbTaxType.TaxTypeCode AND 
							 App.tbTaxCode.TaxTypeCode = Cash.tbTaxType.TaxTypeCode AND App.tbTaxCode.TaxTypeCode = Cash.tbTaxType.TaxTypeCode
go
CREATE PROCEDURE Invoice.proc_PostEntriesById(@UserId nvarchar(10))
AS
   	SET NOCOUNT, XACT_ABORT ON;

	BEGIN TRY
		DECLARE 
			@AccountCode nvarchar(10)
			, @InvoiceTypeCode smallint
			, @InvoiceNumber nvarchar(20);
			
		DECLARE c1 CURSOR LOCAL FOR
			SELECT AccountCode, InvoiceTypeCode
			FROM Invoice.tbEntry
			WHERE UserId = @UserId
			GROUP BY AccountCode, InvoiceTypeCode;

		OPEN c1;

		BEGIN TRAN;

		FETCH NEXT FROM c1 INTO @AccountCode, @InvoiceTypeCode;
		
		WHILE (@@FETCH_STATUS = 0)
		BEGIN
			EXEC Invoice.proc_RaiseBlank @AccountCode, @InvoiceTypeCode, @InvoiceNumber output;

			WITH invoice_entry AS
			(
				SELECT @InvoiceNumber InvoiceNumber, MIN(InvoicedOn) InvoicedOn
				FROM Invoice.tbEntry
				WHERE AccountCode = @AccountCode AND InvoiceTypeCode = @InvoiceTypeCode
			)
			UPDATE Invoice.tbInvoice
			SET 
				UserId = @UserId,
				InvoicedOn = invoice_entry.InvoicedOn,
				Printed = CASE WHEN  @InvoiceTypeCode < 2 THEN 0 ELSE 1 END
			FROM Invoice.tbInvoice invoice_header 
				JOIN invoice_entry ON invoice_header.InvoiceNumber = invoice_entry.InvoiceNumber;

			INSERT INTO Invoice.tbItem (InvoiceNumber, CashCode, TaxCode, ItemReference, TotalValue, InvoiceValue)
			SELECT @InvoiceNumber InvoiceNumber, CashCode, TaxCode, ItemReference, TotalValue, InvoiceValue
			FROM Invoice.tbEntry
			WHERE AccountCode = @AccountCode AND InvoiceTypeCode = @InvoiceTypeCode

			EXEC Invoice.proc_Accept @InvoiceNumber;

			FETCH NEXT FROM c1 INTO @AccountCode, @InvoiceTypeCode;
		END

		DELETE FROM Invoice.tbEntry
		WHERE UserId = @UserId;

		COMMIT TRAN;

		CLOSE c1;
		DEALLOCATE c1;

  	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
go
ALTER PROCEDURE Invoice.proc_PostEntries
AS
	DECLARE @UserId nvarchar(10) = (SELECT UserId FROM Usr.vwCredentials);
	EXECUTE Invoice.proc_PostEntriesById @UserId;
go
ALTER VIEW Invoice.vwRegisterTasks
AS
	SELECT (SELECT TOP (1) p.StartOn FROM App.tbYearPeriod p WHERE (p.StartOn <= Invoice.tbInvoice.InvoicedOn) ORDER BY p.StartOn DESC) AS StartOn,  
			Invoice.tbInvoice.InvoiceNumber, InvoiceTask.TaskCode, Task.TaskTitle, Cash.tbCode.CashCode, Cash.tbCode.CashDescription, 
							 InvoiceTask.TaxCode, App.tbTaxCode.TaxDescription, Invoice.tbInvoice.AccountCode, Invoice.tbInvoice.InvoiceTypeCode, Invoice.tbInvoice.InvoiceStatusCode, 
							 Invoice.tbInvoice.InvoicedOn,  Invoice.tbInvoice.DueOn, Invoice.tbInvoice.ExpectedOn, InvoiceTask.Quantity,
							 CASE WHEN Invoice.tbType.CashModeCode = 0 THEN InvoiceTask.InvoiceValue * - 1 ELSE InvoiceTask.InvoiceValue END AS InvoiceValue, 
							 CASE WHEN Invoice.tbType.CashModeCode = 0 THEN InvoiceTask.TaxValue * - 1 ELSE InvoiceTask.TaxValue END AS TaxValue, 
							 Invoice.tbInvoice.PaymentTerms, Invoice.tbInvoice.Printed, 
							 Org.tbOrg.AccountName, Usr.tbUser.UserName, Invoice.tbInvoice.UserId, Invoice.tbStatus.InvoiceStatus, Invoice.tbType.CashModeCode, Invoice.tbType.InvoiceType
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
ALTER VIEW Invoice.vwRegisterItems
AS
	SELECT       (SELECT TOP (1) p.StartOn FROM App.tbYearPeriod p WHERE (p.StartOn <= Invoice.tbInvoice.InvoicedOn) ORDER BY p.StartOn DESC) AS StartOn,  
					Invoice.tbInvoice.InvoiceNumber, Invoice.tbItem.CashCode AS TaskCode, Cash.tbCode.CashCode, Cash.tbCode.CashDescription, 
							 Invoice.tbItem.TaxCode, App.tbTaxCode.TaxDescription, Invoice.tbInvoice.AccountCode, Invoice.tbInvoice.InvoiceTypeCode, Invoice.tbInvoice.InvoiceStatusCode, 
							 Invoice.tbInvoice.InvoicedOn, Invoice.tbInvoice.DueOn, Invoice.tbInvoice.ExpectedOn,
							 CASE WHEN Invoice.tbType.CashModeCode = 0 THEN Invoice.tbItem.InvoiceValue * - 1 ELSE Invoice.tbItem.InvoiceValue END AS InvoiceValue, 
							 CASE WHEN Invoice.tbType.CashModeCode = 0 THEN Invoice.tbItem.TaxValue * - 1 ELSE Invoice.tbItem.TaxValue END AS TaxValue, 
							 CAST(Invoice.tbItem.ItemReference as nvarchar(100)) ItemReference, Invoice.tbInvoice.PaymentTerms, Invoice.tbInvoice.Printed, 
							 Org.tbOrg.AccountName, Usr.tbUser.UserName, Invoice.tbInvoice.UserId, Invoice.tbStatus.InvoiceStatus, Invoice.tbType.CashModeCode, Invoice.tbType.InvoiceType
	FROM            Invoice.tbInvoice INNER JOIN
							 Org.tbOrg ON Invoice.tbInvoice.AccountCode = Org.tbOrg.AccountCode INNER JOIN
							 Invoice.tbType ON Invoice.tbInvoice.InvoiceTypeCode = Invoice.tbType.InvoiceTypeCode INNER JOIN
							 Invoice.tbStatus ON Invoice.tbInvoice.InvoiceStatusCode = Invoice.tbStatus.InvoiceStatusCode INNER JOIN
							 Usr.tbUser ON Invoice.tbInvoice.UserId = Usr.tbUser.UserId INNER JOIN
							 Invoice.tbItem ON Invoice.tbInvoice.InvoiceNumber = Invoice.tbItem.InvoiceNumber INNER JOIN
							 Cash.tbCode ON Invoice.tbItem.CashCode = Cash.tbCode.CashCode LEFT OUTER JOIN
							 App.tbTaxCode ON Invoice.tbItem.TaxCode = App.tbTaxCode.TaxCode;
go
ALTER VIEW Invoice.vwRegisterDetail
AS
	WITH register AS
	(
		SELECT     StartOn, InvoiceNumber, TaskCode, CashCode, CashDescription, TaxCode, TaxDescription, AccountCode, InvoiceTypeCode, InvoiceStatusCode, 
							  InvoicedOn, DueOn, ExpectedOn, CAST(Quantity as float) Quantity, CAST(InvoiceValue as float) InvoiceValue, CAST(TaxValue as float) TaxValue, PaymentTerms, Printed, AccountName, UserName, UserId, InvoiceStatus, CashModeCode, 
							  InvoiceType, CAST(1 as bit) IsTask, NULL ItemReference
		FROM         Invoice.vwRegisterTasks
		UNION
		SELECT     StartOn, InvoiceNumber, TaskCode, CashCode, CashDescription, TaxCode, TaxDescription, AccountCode, InvoiceTypeCode, InvoiceStatusCode, 
							  InvoicedOn, DueOn, ExpectedOn, CAST(0 as float) Quantity, CAST(InvoiceValue as float) InvoiceValue, CAST(TaxValue as float) TaxValue, PaymentTerms, Printed, AccountName, UserName, UserId, InvoiceStatus, CashModeCode, 
							  InvoiceType, CAST(0 as bit) IsTask, ItemReference
		FROM         Invoice.vwRegisterItems
	)
	SELECT StartOn, InvoiceNumber, TaskCode, CashCode, CashDescription, TaxCode, TaxDescription, AccountCode, InvoiceTypeCode, InvoiceStatusCode, 
		InvoicedOn, DueOn, ExpectedOn, PaymentTerms, Printed, AccountName, UserName, UserId, InvoiceStatus, CashModeCode, InvoiceType,
		Quantity, InvoiceValue, TaxValue, (InvoiceValue + TaxValue) TotalValue, IsTask, ItemReference
	FROM register;
go
ALTER VIEW Invoice.vwRegister
AS
	WITH register AS 
	(
		SELECT       (SELECT TOP (1) p.StartOn FROM App.tbYearPeriod p WHERE (p.StartOn <= Invoice.tbInvoice.InvoicedOn) ORDER BY p.StartOn DESC) AS StartOn,  
				Invoice.tbInvoice.InvoiceNumber, Invoice.tbInvoice.AccountCode, Invoice.tbInvoice.InvoiceTypeCode, Invoice.tbInvoice.InvoiceStatusCode, 
								 Invoice.tbInvoice.InvoicedOn, Invoice.tbInvoice.DueOn, Invoice.tbInvoice.ExpectedOn, CASE WHEN Invoice.tbType.CashModeCode = 0 THEN Invoice.tbInvoice.InvoiceValue * - 1 ELSE Invoice.tbInvoice.InvoiceValue END AS InvoiceValue, 
								 CASE WHEN Invoice.tbType.CashModeCode = 0 THEN Invoice.tbInvoice.TaxValue * - 1 ELSE Invoice.tbInvoice.TaxValue END AS TaxValue, 
								 CASE WHEN Invoice.tbType.CashModeCode = 0 THEN Invoice.tbInvoice.PaidValue * - 1 ELSE Invoice.tbInvoice.PaidValue END AS PaidValue, 
								 CASE WHEN Invoice.tbType.CashModeCode = 0 THEN Invoice.tbInvoice.PaidTaxValue * - 1 ELSE Invoice.tbInvoice.PaidTaxValue END AS PaidTaxValue, Invoice.tbInvoice.PaymentTerms, Invoice.tbInvoice.Notes, 
								 Invoice.tbInvoice.Printed, Org.tbOrg.AccountName, Usr.tbUser.UserName, Invoice.tbInvoice.UserId, Invoice.tbStatus.InvoiceStatus, Invoice.tbType.CashModeCode, Invoice.tbType.InvoiceType
		FROM            Invoice.tbInvoice INNER JOIN
								 Org.tbOrg ON Invoice.tbInvoice.AccountCode = Org.tbOrg.AccountCode INNER JOIN
								 Invoice.tbType ON Invoice.tbInvoice.InvoiceTypeCode = Invoice.tbType.InvoiceTypeCode INNER JOIN
								 Invoice.tbStatus ON Invoice.tbInvoice.InvoiceStatusCode = Invoice.tbStatus.InvoiceStatusCode INNER JOIN
								 Usr.tbUser ON Invoice.tbInvoice.UserId = Usr.tbUser.UserId
	)
	SELECT COALESCE(StartOn, CAST(getdate() as date)) StartOn, InvoiceNumber, AccountCode, InvoiceTypeCode, InvoiceStatusCode, InvoicedOn, DueOn, ExpectedOn,
		CAST(InvoiceValue as float) InvoiceValue, CAST(TaxValue as float) TaxValue, CAST((InvoiceValue + TaxValue) as float) TotalInvoiceValue, 
		CAST(PaidValue as float) PaidValue, CAST(PaidTaxValue as float) PaidTaxValue, CAST((PaidValue + PaidTaxValue) as float) TotalPaidValue,
		PaymentTerms, Notes, Printed, AccountName, UserName, UserId, InvoiceStatus, CashModeCode, InvoiceType
	FROM register;
go
DROP VIEW Invoice.vwRegisterSales
go
CREATE VIEW Invoice.vwRegisterSales
AS
SELECT        StartOn, InvoiceNumber, AccountCode, InvoiceTypeCode, InvoiceStatusCode, InvoicedOn, InvoiceValue, TaxValue, PaidValue, PaidTaxValue, PaymentTerms, Notes, Printed, AccountName, UserName, 
                         InvoiceStatus, CashModeCode, InvoiceType, (InvoiceValue + TaxValue) - (PaidValue + PaidTaxValue) AS UnpaidValue
FROM            Invoice.vwRegister
WHERE        (InvoiceTypeCode < 2);
go
DROP VIEW Invoice.vwRegisterPurchases
go
CREATE VIEW Invoice.vwRegisterPurchases
AS
SELECT        StartOn, InvoiceNumber, AccountCode, InvoiceTypeCode, InvoiceStatusCode, InvoicedOn, InvoiceValue, TaxValue, PaidValue, PaidTaxValue, PaymentTerms, Notes, Printed, AccountName, UserName, 
                         InvoiceStatus, CashModeCode, InvoiceType, (InvoiceValue + TaxValue) - (PaidValue + PaidTaxValue) AS UnpaidValue
FROM            Invoice.vwRegister
WHERE        (InvoiceTypeCode > 1);
go
DROP VIEW Invoice.vwHistoryPurchases
go
CREATE VIEW Invoice.vwHistoryPurchases
AS
SELECT        App.tbYearPeriod.YearNumber, App.tbYear.Description, CONCAT(App.tbMonth.MonthName, SPACE(1), YEAR(App.tbYearPeriod.StartOn)) AS PeriodName, Invoice.vwRegister.StartOn, 
                         Invoice.vwRegister.InvoiceNumber, Invoice.vwRegister.AccountCode, Invoice.vwRegister.InvoiceTypeCode, Invoice.vwRegister.InvoiceStatusCode, Invoice.vwRegister.InvoicedOn, 
                         Invoice.vwRegister.InvoiceValue, Invoice.vwRegister.TaxValue, Invoice.vwRegister.PaidValue, Invoice.vwRegister.PaidTaxValue, Invoice.vwRegister.PaymentTerms, Invoice.vwRegister.Notes, 
                         Invoice.vwRegister.Printed, Invoice.vwRegister.AccountName, Invoice.vwRegister.UserName, Invoice.vwRegister.InvoiceStatus, Invoice.vwRegister.CashModeCode, Invoice.vwRegister.InvoiceType, 
                         (Invoice.vwRegister.InvoiceValue + Invoice.vwRegister.TaxValue) - (Invoice.vwRegister.PaidValue + Invoice.vwRegister.PaidTaxValue) AS UnpaidValue
FROM            App.tbYearPeriod INNER JOIN
                         App.tbMonth ON App.tbYearPeriod.MonthNumber = App.tbMonth.MonthNumber INNER JOIN
                         App.tbYear ON App.tbYearPeriod.YearNumber = App.tbYear.YearNumber INNER JOIN
                         Invoice.vwRegister ON App.tbYearPeriod.StartOn = Invoice.vwRegister.StartOn
WHERE        (Invoice.vwRegister.InvoiceTypeCode > 1);
go
DROP VIEW Invoice.vwHistorySales
go
CREATE VIEW Invoice.vwHistorySales
AS
SELECT        App.tbYearPeriod.YearNumber, CONCAT(App.tbMonth.MonthName, SPACE(1), YEAR(App.tbYearPeriod.StartOn)) AS PeriodName, Invoice.vwRegister.StartOn, 
                         Invoice.vwRegister.InvoiceNumber, Invoice.vwRegister.AccountCode, Invoice.vwRegister.InvoiceTypeCode, Invoice.vwRegister.InvoiceStatusCode, Invoice.vwRegister.InvoicedOn, 
                         Invoice.vwRegister.InvoiceValue, Invoice.vwRegister.TaxValue, Invoice.vwRegister.PaidValue, Invoice.vwRegister.PaidTaxValue, Invoice.vwRegister.PaymentTerms, Invoice.vwRegister.Notes, 
                         Invoice.vwRegister.Printed, Invoice.vwRegister.AccountName, Invoice.vwRegister.UserName, Invoice.vwRegister.InvoiceStatus, Invoice.vwRegister.CashModeCode, Invoice.vwRegister.InvoiceType, 
                         (Invoice.vwRegister.InvoiceValue + Invoice.vwRegister.TaxValue) - (Invoice.vwRegister.PaidValue + Invoice.vwRegister.PaidTaxValue) AS UnpaidValue
FROM            App.tbYearPeriod INNER JOIN
                         App.tbMonth ON App.tbYearPeriod.MonthNumber = App.tbMonth.MonthNumber INNER JOIN
                         App.tbYear ON App.tbYearPeriod.YearNumber = App.tbYear.YearNumber INNER JOIN
                         Invoice.vwRegister ON App.tbYearPeriod.StartOn = Invoice.vwRegister.StartOn
WHERE        (Invoice.vwRegister.InvoiceTypeCode < 2);
go
ALTER VIEW Invoice.vwRegisterCashCodes
AS
	WITH cash_codes AS
	(
		SELECT StartOn, CashCode, CashDescription, CashModeCode, CAST(SUM(InvoiceValue) as float) AS TotalInvoiceValue, CAST(SUM(TaxValue) as float) AS TotalTaxValue
		FROM            Invoice.vwRegisterDetail
		GROUP BY StartOn, CashCode, CashDescription, CashModeCode	
	)
	SELECT cash_codes.StartOn, CONCAT(financial_year.[Description], ' ', app_month.MonthName) PeriodName, CashMode,
		CashCode, CashDescription, TotalInvoiceValue, TotalTaxValue, TotalInvoiceValue + TotalTaxValue as TotalValue		
	FROM cash_codes
		JOIN Cash.tbMode cash_mode ON cash_codes.CashModeCode = cash_mode.CashModeCode
		JOIN App.tbYearPeriod year_period ON cash_codes.StartOn = year_period.StartOn
		JOIN App.tbMonth app_month ON year_period.MonthNumber = app_month.MonthNumber
		JOIN App.tbYear financial_year ON year_period.YearNumber = financial_year.YearNumber;
go
CREATE VIEW Invoice.vwRegisterOverdue
AS
	SELECT Invoice.tbInvoice.InvoiceNumber, Invoice.tbInvoice.AccountCode, Org.tbOrg.AccountName, Invoice.tbInvoice.InvoiceTypeCode, Invoice.tbInvoice.InvoiceStatusCode, Invoice.tbStatus.InvoiceStatus, 
							 Invoice.tbType.InvoiceType, DATEDIFF(DD, CURRENT_TIMESTAMP, Invoice.tbInvoice.InvoicedOn) AS UnpaidDays, Invoice.tbInvoice.InvoicedOn, Invoice.tbInvoice.DueOn, Invoice.tbInvoice.ExpectedOn, 
							 CASE Invoice.tbType.CashModeCode WHEN 0 THEN Invoice.tbInvoice.InvoiceValue ELSE Invoice.tbInvoice.InvoiceValue * - 1 END AS InvoiceValue, 
							 CASE Invoice.tbType.CashModeCode WHEN 0 THEN Invoice.tbInvoice.TaxValue ELSE Invoice.tbInvoice.TaxValue * - 1 END AS TaxValue, 
							 CASE Invoice.tbType.CashModeCode WHEN 0 THEN (Invoice.tbInvoice.InvoiceValue + Invoice.tbInvoice.TaxValue) - (Invoice.tbInvoice.PaidValue + Invoice.tbInvoice.PaidTaxValue) 
							 ELSE ((Invoice.tbInvoice.InvoiceValue + Invoice.tbInvoice.TaxValue) - (Invoice.tbInvoice.PaidValue + Invoice.tbInvoice.PaidTaxValue)) * - 1 END AS UnpaidValue, 
							 Invoice.tbInvoice.PaymentTerms, Invoice.tbInvoice.Notes
	FROM            Invoice.tbInvoice INNER JOIN
							 Invoice.tbStatus ON Invoice.tbInvoice.InvoiceStatusCode = Invoice.tbStatus.InvoiceStatusCode INNER JOIN
							 Invoice.tbType ON Invoice.tbInvoice.InvoiceTypeCode = Invoice.tbType.InvoiceTypeCode INNER JOIN
							 Org.tbOrg ON Invoice.tbInvoice.AccountCode = Org.tbOrg.AccountCode
	WHERE    (Invoice.tbInvoice.InvoiceStatusCode < 3);
go
CREATE PROCEDURE App.proc_DocDespoolAll
AS
	SET NOCOUNT, XACT_ABORT ON;

	BEGIN TRY
		BEGIN TRAN
		UPDATE Task.tbTask
		SET Spooled = 0, Printed = 1;

		UPDATE  Invoice.tbInvoice
		SET  Spooled = 0, Printed = 1;
		COMMIT TRAN
	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
go
CREATE PROCEDURE Invoice.proc_CancelById(@UserId nvarchar(10))
AS
  	SET NOCOUNT, XACT_ABORT ON;

	BEGIN TRY

		BEGIN TRAN

		UPDATE       Task
		SET                TaskStatusCode = 2
		FROM            Task.tbTask AS Task INNER JOIN
								 Invoice.tbTask AS InvoiceTask ON Task.TaskCode = InvoiceTask.TaskCode AND Task.TaskCode = InvoiceTask.TaskCode INNER JOIN
								 Invoice.tbInvoice ON InvoiceTask.InvoiceNumber = Invoice.tbInvoice.InvoiceNumber 
		WHERE        (Invoice.tbInvoice.InvoiceTypeCode = 0 OR Invoice.tbInvoice.InvoiceTypeCode = 2) 
			AND (Invoice.tbInvoice.InvoiceStatusCode = 0) AND (Task.TaskStatusCode = 3) AND (Invoice.tbInvoice.UserId = @UserId)
	                      
		DELETE Invoice.tbInvoice
		FROM         Invoice.tbInvoice INNER JOIN
							  Usr.vwCredentials ON Invoice.tbInvoice.UserId = Usr.vwCredentials.UserId
		WHERE     ( Invoice.tbInvoice.InvoiceStatusCode = 0) AND (Invoice.tbInvoice.UserId = @UserId)
		
		COMMIT TRAN

  	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
go
ALTER PROCEDURE Invoice.proc_Cancel
AS
  	SET NOCOUNT, XACT_ABORT ON;

	BEGIN TRY
		
		DECLARE @UserId nvarchar(10) = (SELECT TOP 1 UserId FROM Usr.vwCredentials)
		EXEC Invoice.proc_CancelById @UserId

  	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
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


		IF UPDATE(InvoicedOn) AND EXISTS (
				SELECT * FROM inserted JOIN deleted 
					ON inserted.InvoiceNumber = deleted.InvoiceNumber AND inserted.DueOn = deleted.DueOn)
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

		IF UPDATE(InvoicedOn) AND EXISTS (
				SELECT * FROM inserted JOIN deleted 
					ON inserted.InvoiceNumber = deleted.InvoiceNumber AND inserted.ExpectedOn = deleted.ExpectedOn)
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
CREATE PROCEDURE Cash.proc_TaxAdjustment (@StartOn datetime, @TaxTypeCode smallint, @TaxAdjustment decimal(18, 5))
AS
	SET NOCOUNT, XACT_ABORT ON;

	BEGIN TRY

		DECLARE 		
			@PayTo datetime,
			@PayFrom datetime;

		SELECT 
			@PayFrom = PayFrom,
			@PayTo = PayTo 
		FROM Cash.fnTaxTypeDueDates(@TaxTypeCode) due_dates 
		WHERE @StartOn >= due_dates.PayFrom AND @StartOn < due_dates.PayTo

		UPDATE App.tbYearPeriod
		SET 
			TaxAdjustment = CASE @TaxTypeCode WHEN 0 THEN 0 ELSE TaxAdjustment END,
			VatAdjustment = CASE @TaxTypeCode WHEN 1 THEN 0 ELSE VatAdjustment END
		WHERE StartOn >= @PayFrom AND StartOn < @PayTo;

		SELECT @StartOn = MAX(StartOn)
		FROM App.tbYearPeriod
		WHERE StartOn < @PayTo;

		UPDATE App.tbYearPeriod
		SET 
			TaxAdjustment = CASE @TaxTypeCode WHEN 0 THEN @TaxAdjustment ELSE TaxAdjustment END,
			VatAdjustment = CASE @TaxTypeCode WHEN 1 THEN @TaxAdjustment ELSE VatAdjustment END
		WHERE StartOn = @StartOn;
	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
go
ALTER VIEW Cash.vwTaxCorpTotals
AS
	WITH totals AS
	(
		SELECT App.tbYearPeriod.YearNumber, netprofit_totals.StartOn, YEAR(App.tbYearPeriod.StartOn) AS PeriodYear, App.tbYear.Description, 
						  App.tbMonth.MonthName + ' ' + LTRIM(STR(YEAR(App.tbYearPeriod.StartOn))) AS Period, App.tbYearPeriod.CorporationTaxRate, 
						  App.tbYearPeriod.TaxAdjustment, SUM(netprofit_totals.NetProfit) AS NetProfit, SUM(netprofit_totals.CorporationTax) AS CorporationTax
		FROM       Cash.vwTaxCorpTotalsByPeriod  netprofit_totals INNER JOIN
							  App.tbYearPeriod ON netprofit_totals.StartOn = App.tbYearPeriod.StartOn INNER JOIN
							  App.tbYear ON App.tbYearPeriod.YearNumber = App.tbYear.YearNumber INNER JOIN
							  App.tbMonth ON App.tbYearPeriod.MonthNumber = App.tbMonth.MonthNumber
		WHERE     (App.tbYear.CashStatusCode BETWEEN 1 AND 2)
		GROUP BY App.tbYearPeriod.YearNumber, App.tbYear.Description, App.tbMonth.MonthName, netprofit_totals.StartOn, YEAR(App.tbYearPeriod.StartOn), 
							  App.tbYearPeriod.CorporationTaxRate, App.tbYearPeriod.TaxAdjustment
	)
	SELECT YearNumber, StartOn, PeriodYear, Description, Period, CorporationTaxRate, TaxAdjustment, CAST(NetProfit AS decimal(18, 5)) NetProfit, CAST(CorporationTax AS decimal(18, 5)) CorporationTax
	FROM totals;

go
CREATE PROCEDURE App.proc_TaxRates(@StartOn datetime, @EndOn datetime, @CorporationTaxRate real)
AS
    SET NOCOUNT, XACT_ABORT ON;

	BEGIN TRY	
		UPDATE App.tbYearPeriod
		SET CorporationTaxRate = @CorporationTaxRate
		WHERE StartOn >= @StartOn AND StartOn <= @EndOn;
	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
go
ALTER VIEW App.vwTaxCodes
AS
	SELECT        App.tbTaxCode.TaxCode, App.tbTaxCode.TaxDescription, Cash.tbTaxType.TaxType, App.tbTaxCode.TaxTypeCode, App.tbTaxCode.RoundingCode, App.tbRounding.Rounding, App.tbTaxCode.TaxRate, App.tbTaxCode.Decimals, 
							 App.tbTaxCode.UpdatedBy, App.tbTaxCode.UpdatedOn
	FROM            App.tbTaxCode INNER JOIN
							 Cash.tbTaxType ON App.tbTaxCode.TaxTypeCode = Cash.tbTaxType.TaxTypeCode INNER JOIN
							 App.tbRounding ON App.tbTaxCode.RoundingCode = App.tbRounding.RoundingCode

go

ALTER TRIGGER App.App_tbTaxCode_TriggerUpdate ON App.tbTaxCode AFTER UPDATE, INSERT
AS 
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY
		IF EXISTS (SELECT * FROM inserted i WHERE App.fnParsePrimaryKey(TaxCode) = 0)
		BEGIN
			DECLARE @Msg NVARCHAR(MAX);
			SELECT @Msg = Message FROM App.tbText WHERE TextId = 2004;
			RAISERROR (@Msg, 10, 1);
			ROLLBACK TRANSACTION;
		END
		ELSE IF NOT UPDATE(UpdatedBy)
		BEGIN
			UPDATE App.tbTaxCode
			SET UpdatedBy = SUSER_SNAME(), UpdatedOn = CURRENT_TIMESTAMP
			FROM App.tbTaxCode INNER JOIN inserted AS i ON tbTaxCode.TaxCode = i.TaxCode;
		END
		
	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
END
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
	SELECT EntryNumber, AssetCode, AssetName, CashModeCode, LiquidityLevel, balance_sheet_grouped.StartOn, 
		year_period.YearNumber, year_period.MonthNumber, IsEntry,
		CASE IsEntry WHEN 0 THEN
			MAX(Balance) OVER (PARTITION BY AssetName, CashModeCode, RNK ORDER BY EntryNumber) +
			MIN(Balance) OVER (PARTITION BY AssetName, CashModeCode, RNK ORDER BY EntryNumber) 
		ELSE
			Balance
		END AS Balance
	FROM balance_sheet_grouped
		JOIN App.tbYearPeriod year_period ON balance_sheet_grouped.StartOn = year_period.StartOn;

go
ALTER VIEW App.vwPeriods
AS
	SELECT TOP (100) PERCENT App.tbYear.YearNumber, App.tbYearPeriod.MonthNumber, App.tbYearPeriod.StartOn, App.tbYear.Description + SPACE(1) + App.tbMonth.MonthName AS Description, App.tbYearPeriod.RowVer
	FROM            App.tbYearPeriod INNER JOIN
							 App.tbMonth ON App.tbYearPeriod.MonthNumber = App.tbMonth.MonthNumber INNER JOIN
							 App.tbYear ON App.tbYearPeriod.YearNumber = App.tbYear.YearNumber
	WHERE        (App.tbYear.CashStatusCode < 3) AND (App.tbYearPeriod.CashStatusCode < 3)
go
CREATE VIEW Cash.vwProfitAndLossData
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
		SELECT CategoryCode
		FROM  Cash.tbCategory category 
		WHERE ( CashTypeCode = 0) AND (CategoryTypeCode = 1)
			AND NOT EXISTS (SELECT * FROM App.tbOptions o WHERE o.VatCategoryCode = category.CategoryCode) 
			
	), cashcode_candidates AS
	(
		SELECT   categories.CategoryCode, ChildCode, CashCode, CashTypeCode, CashModeCode
		FROM category_relations
			JOIN categories ON category_relations.ParentCode = categories.CategoryCode		

		UNION ALL

		SELECT  cashcode_candidates.CategoryCode, category_relations.ChildCode, category_relations.CashCode, category_relations.CashTypeCode, category_relations.CashModeCode
		FROM  category_relations JOIN cashcode_candidates ON category_relations.ParentCode = cashcode_candidates.ChildCode
	), cashcode_selected AS
	(
		SELECT CategoryCode, CashCode, CashTypeCode, CashModeCode FROM cashcode_candidates
		UNION
		SELECT ParentCode CategoryCode, CashCode, CashTypeCode, CashModeCode FROM category_relations WHERE ParentCode = (SELECT NetProfitCode FROM App.tbOptions)
	), category_cash_codes AS
	(
		SELECT DISTINCT CategoryCode, CashCode, CashTypeCode, CashModeCode
		FROM cashcode_selected WHERE NOT CashCode IS NULL
	), active_periods AS
	(
		SELECT yr.YearNumber, pd.StartOn
		FROM App.tbYear yr
			JOIN App.tbYearPeriod pd ON yr.YearNumber = pd.YearNumber
		WHERE (yr.CashStatusCode BETWEEN 1 AND 2)
	), category_data AS
	(
		SELECT category_cash_codes.CategoryCode, periods.CashCode, periods.StartOn, 
			CASE category_cash_codes.CashModeCode WHEN 0 THEN periods.InvoiceValue * -1 ELSE InvoiceValue END InvoiceValue
		FROM category_cash_codes 
			JOIN Cash.tbPeriod periods ON category_cash_codes.CashCode = periods.CashCode
			JOIN active_periods ON active_periods.StartOn = periods.StartOn
	)
	SELECT CategoryCode, StartOn, SUM(InvoiceValue) InvoiceValue
	FROM category_data
	GROUP BY CategoryCode, StartOn;
go
CREATE VIEW Cash.vwProfitAndLossByPeriod
AS
	SELECT category.CategoryCode, category.Category, periods.YearNumber, periods.MonthNumber, category.DisplayOrder, financial_year.Description,
		year_month.MonthName, profit_data.StartOn, profit_data.InvoiceValue
	FROM Cash.vwProfitAndLossData profit_data
		JOIN Cash.tbCategory category ON profit_data.CategoryCode = category.CategoryCode
		JOIN App.tbYearPeriod periods ON profit_data.StartOn = periods.StartOn
		JOIN App.tbYear financial_year ON periods.YearNumber = financial_year.YearNumber
		JOIN App.tbMonth year_month ON periods.MonthNumber = year_month.MonthNumber;
go
CREATE VIEW Cash.vwProfitAndLossByYear
AS
	SELECT financial_year.YearNumber, financial_year.Description, category.DisplayOrder, category.CategoryCode, category.Category, SUM(profit_data.InvoiceValue) InvoiceValue
	FROM Cash.vwProfitAndLossData profit_data
		JOIN Cash.tbCategory category ON profit_data.CategoryCode = category.CategoryCode
		JOIN App.tbYearPeriod periods ON profit_data.StartOn = periods.StartOn
		JOIN App.tbYear financial_year ON periods.YearNumber = financial_year.YearNumber
	GROUP BY financial_year.YearNumber, financial_year.Description, category.DisplayOrder, category.CategoryCode, category.Category;
go
ALTER VIEW Org.vwCashAccounts
AS
SELECT        Org.tbAccount.CashAccountCode, Org.tbOrg.AccountCode, Org.tbAccount.CashAccountName, Org.tbOrg.AccountName, Org.tbType.OrganisationType, Org.tbAccount.OpeningBalance, Org.tbAccount.CurrentBalance, 
                         Org.tbAccount.SortCode, Org.tbAccount.AccountNumber, Org.tbAccount.AccountClosed, Org.tbAccount.AccountTypeCode, Org.tbAccountType.AccountType, Org.tbAccount.CashCode, Cash.tbCode.CashDescription, 
                         Org.tbAccount.InsertedBy, Org.tbAccount.InsertedOn, Org.tbAccount.LiquidityLevel
FROM            Org.tbOrg INNER JOIN
                         Org.tbAccount ON Org.tbOrg.AccountCode = Org.tbAccount.AccountCode INNER JOIN
                         Org.tbType ON Org.tbOrg.OrganisationTypeCode = Org.tbType.OrganisationTypeCode INNER JOIN
                         Org.tbAccountType ON Org.tbAccount.AccountTypeCode = Org.tbAccountType.AccountTypeCode LEFT OUTER JOIN
                         Cash.tbCode ON Org.tbAccount.CashCode = Cash.tbCode.CashCode AND Org.tbAccount.CashCode = Cash.tbCode.CashCode AND Org.tbAccount.CashCode = Cash.tbCode.CashCode
go
CREATE VIEW Cash.vwFlowCategories
AS
	WITH trade_type AS
	(
		SELECT CashTypeCode, CashType FROM Cash.tbType
		WHERE CashTypeCode = 0
	), trade_cat AS
	(
		SELECT trade_type.CashTypeCode, trade_type.CashType, cats.CategoryCode, cats.Category, cats.CashModeCode, cats.DisplayOrder 
		FROM trade_type
			CROSS APPLY 
			(
				SELECT cat.* FROM Cash.fnFlowCategory(trade_type.CashTypeCode) cat
			) cats
	), cash_type AS
	(
		SELECT CashTypeCode, CashType FROM Cash.tbType
		WHERE CashTypeCode = 2
	), cash_cat AS
	(
		SELECT cash_type.CashTypeCode, 
		cash_type.CashType, cats.CategoryCode, cats.Category, cats.CashModeCode, cats.DisplayOrder
		FROM cash_type
			CROSS APPLY 
			(
				SELECT cat.* FROM Cash.fnFlowCategory(cash_type.CashTypeCode) cat
			) cats
	),  tax_type AS
	(
		SELECT CashTypeCode, CashType FROM Cash.tbType
		WHERE CashTypeCode = 1
	), tax_cat AS
	(
		SELECT tax_type.CashTypeCode, 
		tax_type.CashType, cats.CategoryCode, cats.Category, cats.CashModeCode, cats.DisplayOrder
		FROM tax_type
			CROSS APPLY 
			(
				SELECT cat.* FROM Cash.fnFlowCategory(tax_type.CashTypeCode) cat
			) cats
	), catagories_unsorted AS
	(
		SELECT CashTypeCode, DisplayOrder, CashType, CategoryCode, Category, CashModeCode 
		FROM trade_cat
		UNION
		SELECT 1 CashTypeCode, DisplayOrder, CashType, CategoryCode, Category, CashModeCode 
		FROM cash_cat
		UNION
		SELECT 2 CashTypeCode, DisplayOrder, CashType, CategoryCode, Category, CashModeCode 
		FROM tax_cat
	)
	SELECT CashTypeCode, ROW_NUMBER() OVER (ORDER BY CashTypeCode, DisplayOrder) EntryId,
		CashType, CategoryCode, Category, CashModeCode
	FROM catagories_unsorted;
go
CREATE VIEW Cash.vwFlowCategoryByPeriod
AS
	SELECT cats.CategoryCode, cash_codes.CashCode, cash_codes.CashDescription,	
		YearNumber, year_period.StartOn, year_period.MonthNumber, CASE cats.CashModeCode WHEN 0 THEN InvoiceValue * -1 ELSE InvoiceValue END InvoiceValue
	FROM Cash.tbCategory cats
		JOIN Cash.tbCode cash_codes ON cats.CategoryCode = cash_codes.CategoryCode
		JOIN Cash.tbPeriod cash_periods ON cash_codes.CashCode = cash_periods.CashCode
		JOIN App.tbYearPeriod year_period ON cash_periods.StartOn = year_period.StartOn
	WHERE cash_codes.IsEnabled <> 0
go
CREATE VIEW Cash.vwFlowCategoryByYear
AS
	SELECT CategoryCode, CashCode, YearNumber, SUM(InvoiceValue) InvoiceValue
	FROM Cash.vwFlowCategoryByPeriod
	GROUP BY CategoryCode, CashCode, YearNumber
go
ALTER TRIGGER Cash.Cash_tbCategory_TriggerUpdate 
   ON  Cash.tbCategory
   AFTER UPDATE, INSERT
AS 
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY	
		IF EXISTS (SELECT * FROM inserted i WHERE App.fnParsePrimaryKey(CategoryCode) = 0)
		BEGIN
			DECLARE @Msg NVARCHAR(MAX);
			SELECT @Msg = Message FROM App.tbText WHERE TextId = 2004;
			RAISERROR (@Msg, 10, 1)
			ROLLBACK
		END

		IF UPDATE (IsEnabled)
		BEGIN
			UPDATE  Cash.tbCode
			SET     IsEnabled = 0
			FROM        inserted INNER JOIN
										Cash.tbCode ON inserted.CategoryCode = Cash.tbCode.CategoryCode
			WHERE        (inserted.IsEnabled = 0) AND (Cash.tbCode.IsEnabled <> 0);
		END

		IF NOT UPDATE(UpdatedBy)
		BEGIN
			UPDATE Cash.tbCategory
			SET UpdatedBy = SUSER_SNAME(), UpdatedOn = CURRENT_TIMESTAMP
			FROM Cash.tbCategory INNER JOIN inserted AS i ON tbCategory.CategoryCode = i.CategoryCode;
		END

	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
END
go
CREATE VIEW Cash.vwCode
AS
	SELECT        Cash.tbCode.CashCode, Cash.tbCode.CashDescription, Cash.tbCode.CategoryCode, Cash.tbCategory.Category, Cash.tbMode.CashModeCode, Cash.tbMode.CashMode, App.tbTaxCode.TaxDescription, 
							 Cash.tbCategory.CashTypeCode, Cash.tbType.CashType, CAST(Cash.tbCode.IsEnabled AS bit) AS IsCashEnabled, CAST(Cash.tbCategory.IsEnabled AS bit) AS IsCategoryEnabled, Cash.tbCode.InsertedBy, 
							 Cash.tbCode.InsertedOn, Cash.tbCode.UpdatedBy, Cash.tbCode.UpdatedOn
	FROM            Cash.tbCode INNER JOIN
							 Cash.tbCategory ON Cash.tbCode.CategoryCode = Cash.tbCategory.CategoryCode INNER JOIN
							 Cash.tbMode ON Cash.tbCategory.CashModeCode = Cash.tbMode.CashModeCode INNER JOIN
							 Cash.tbType ON Cash.tbCategory.CashTypeCode = Cash.tbType.CashTypeCode INNER JOIN
							 App.tbTaxCode ON Cash.tbCode.TaxCode = App.tbTaxCode.TaxCode
go
ALTER TRIGGER Cash.Cash_tbCode_TriggerUpdate
   ON  Cash.tbCode
   AFTER UPDATE, INSERT
AS 
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY	
		IF EXISTS (SELECT * FROM inserted i WHERE App.fnParsePrimaryKey(CashCode) = 0)
			BEGIN
			DECLARE @Msg NVARCHAR(MAX);
			SELECT @Msg = Message FROM App.tbText WHERE TextId = 2004;
			RAISERROR (@Msg, 10, 1);
			ROLLBACK
			END
		ELSE IF NOT UPDATE(UpdatedBy)
			BEGIN
			UPDATE Cash.tbCode
			SET UpdatedBy = SUSER_SNAME(), UpdatedOn = CURRENT_TIMESTAMP
			FROM Cash.tbCode INNER JOIN inserted AS i ON tbCode.CashCode = i.CashCode;
			END
	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
END
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
		SELECT running_balance.CashAccountCode, 
			COALESCE((SELECT TOP 1 StartOn FROM App.tbYearPeriod WHERE (StartOn <= running_balance.PaidOn) ORDER BY StartOn DESC), 
				(SELECT MIN(StartOn) FROM App.tbYearPeriod) ) AS StartOn, 
			running_balance.EntryNumber, running_balance.PaymentCode, running_balance.PaidOn, 
			payments.AccountName, payments.PaymentReference, COALESCE(payments.PaidInValue, 0) PaidInValue, 
			COALESCE(payments.PaidOutValue, 0) PaidOutValue, CAST(running_balance.PaidBalance as decimal(18,5)) PaidBalance, 
			payments.CashCode, payments.CashDescription, payments.TaxDescription, payments.UserName, 
			payments.AccountCode, payments.TaxCode
		FROM   running_balance LEFT OUTER JOIN
								payments ON running_balance.PaymentCode = payments.PaymentCode

go
CREATE VIEW Cash.vwTaxTypes
AS
	SELECT        Cash.tbTaxType.TaxTypeCode, Cash.tbTaxType.TaxType, Cash.tbTaxType.CashCode, Cash.tbCode.CashDescription, Cash.tbTaxType.MonthNumber, App.tbMonth.[MonthName], Cash.tbTaxType.RecurrenceCode, 
							 App.tbRecurrence.Recurrence, Cash.tbTaxType.AccountCode, Org.tbOrg.AccountName, Cash.tbTaxType.OffsetDays
	FROM            Cash.tbTaxType INNER JOIN
							 Cash.tbCode ON Cash.tbTaxType.CashCode = Cash.tbCode.CashCode INNER JOIN
							 App.tbMonth ON Cash.tbTaxType.MonthNumber = App.tbMonth.MonthNumber INNER JOIN
							 App.tbRecurrence ON Cash.tbTaxType.RecurrenceCode = App.tbRecurrence.RecurrenceCode INNER JOIN
							 Org.tbOrg ON Cash.tbTaxType.AccountCode = Org.tbOrg.AccountCode;
go
CREATE VIEW Invoice.vwTypes
AS
	SELECT Invoice.tbType.InvoiceTypeCode, Invoice.tbType.InvoiceType, Invoice.tbType.CashModeCode, Cash.tbMode.CashMode, Invoice.tbType.NextNumber
	FROM Invoice.tbType 
		JOIN Cash.tbMode ON Invoice.tbType.CashModeCode = Cash.tbMode.CashModeCode;
go
CREATE VIEW App.vwYears
AS
	SELECT App.tbYear.YearNumber, CONCAT(App.tbMonth.MonthName, ' ', App.tbYear.YearNumber) StartMonth, App.tbYear.CashStatusCode, Cash.tbStatus.CashStatus, App.tbYear.Description, App.tbYear.InsertedBy, App.tbYear.InsertedOn
	FROM App.tbYear 
		JOIN Cash.tbStatus ON App.tbYear.CashStatusCode = Cash.tbStatus.CashStatusCode 
		JOIN App.tbMonth ON App.tbYear.StartMonth = App.tbMonth.MonthNumber AND App.tbYear.StartMonth = App.tbMonth.MonthNumber;
go
ALTER VIEW App.vwYearPeriod
AS
	SELECT App.tbYear.Description, App.tbMonth.MonthName, App.tbYearPeriod.CashStatusCode, Cash.tbStatus.CashStatus, App.tbYearPeriod.YearNumber, App.tbYearPeriod.MonthNumber, App.tbYearPeriod.StartOn, App.tbYearPeriod.RowVer
	FROM App.tbYearPeriod INNER JOIN
		App.tbMonth ON App.tbYearPeriod.MonthNumber = App.tbMonth.MonthNumber INNER JOIN
		App.tbYear ON App.tbYearPeriod.YearNumber = App.tbYear.YearNumber INNER JOIN
		Cash.tbStatus ON App.tbYearPeriod.CashStatusCode = Cash.tbStatus.CashStatusCode;
go
ALTER VIEW Usr.vwDoc
AS
	WITH bank AS 
	(
		SELECT TOP (1) (SELECT AccountCode FROM App.tbOptions) AS AccountCode, 
			Org.tbOrg.AccountName AS BankName,
			Org.tbAccount.CashAccountName AS CurrentAccountName,
			CONCAT(Org.tbOrg.AccountName, SPACE(1), Org.tbAccount.CashAccountName) AS BankAccount, 
			Org.tbAccount.SortCode AS BankSortCode, Org.tbAccount.AccountNumber AS BankAccountNumber
		FROM Org.tbAccount 
			INNER JOIN Org.tbOrg ON Org.tbAccount.AccountCode = Org.tbOrg.AccountCode
		WHERE (NOT (Org.tbAccount.CashCode IS NULL)) AND (Org.tbAccount.AccountTypeCode = 0)
	)
    SELECT        TOP (1) company.AccountName AS CompanyName, Org.tbAddress.Address AS CompanyAddress, company.PhoneNumber AS CompanyPhoneNumber,  
                              company.EmailAddress AS CompanyEmailAddress, company.WebSite AS CompanyWebsite, company.CompanyNumber, company.VatNumber, company.Logo, 
							  bank_details.BankName, bank_details.CurrentAccountName,
							  bank_details.BankAccount, bank_details.BankAccountNumber, bank_details.BankSortCode
     FROM            Org.tbOrg AS company INNER JOIN
                              App.tbOptions ON company.AccountCode = App.tbOptions.AccountCode LEFT OUTER JOIN
                              bank AS bank_details ON company.AccountCode = bank_details.AccountCode LEFT OUTER JOIN
                              Org.tbAddress ON company.AddressCode = Org.tbAddress.AddressCode;

go
IF NOT EXISTS (select CONCAT(SCHEMA_NAME(schema_id), '.', [name]) table_name  from sys.tables where [name] = 'tbHost')
BEGIN
	CREATE TABLE App.tbHost
	(
		HostId INT NOT NULL IDENTITY,
		HostDescription nvarchar(50) NOT NULL,
		EmailAddress varchar(256) NOT NULL,
		EmailPassword nvarchar(50) NOT NULL,
		HostName nvarchar(256) NOT NULL,
		HostPort int,
		InsertedBy nvarchar(50) NOT NULL CONSTRAINT DF_App_tbHost_InsertedBy DEFAULT (SUSER_SNAME()),
		InsertedOn datetime NOT NULL CONSTRAINT DF_App_tbHost_InsertedOn DEFAULT (GETDATE()),
		CONSTRAINT PK_App_tbHost PRIMARY KEY NONCLUSTERED (HostId)
	);
	
	CREATE UNIQUE NONCLUSTERED INDEX IX_App_tbHost_HostDescription ON App.tbHost(HostDescription ASC);

	ALTER TABLE App.tbOptions WITH NOCHECK ADD
		HostId int NULL;

	ALTER TABLE App.tbOptions WITH CHECK ADD  
		CONSTRAINT FK_App_tbOptions_App_tbHost FOREIGN KEY(HostId)
		REFERENCES App.tbHost (HostId);

	ALTER TABLE App.tbOptions CHECK CONSTRAINT FK_App_tbOptions_App_tbHost;
	
END
go
CREATE VIEW App.vwHost
AS
	SELECT App.tbHost.HostId, App.tbHost.HostDescription, App.tbHost.EmailAddress, App.tbHost.EmailPassword, App.tbHost.HostName, App.tbHost.HostPort
	FROM App.tbOptions 
		JOIN App.tbHost ON App.tbOptions.HostId = App.tbHost.HostId;
go
ALTER VIEW Invoice.vwDoc
AS
	SELECT     Org.tbOrg.EmailAddress, Usr.tbUser.UserName, Org.tbOrg.AccountCode, Org.tbOrg.AccountName, Org.tbAddress.Address AS InvoiceAddress, 
						  Invoice.tbInvoice.InvoiceNumber, Invoice.tbType.InvoiceType, Invoice.tbStatus.InvoiceStatus, Invoice.tbInvoice.InvoicedOn, Invoice.tbInvoice.DueOn, 
						  Invoice.tbInvoice.InvoiceValue, Invoice.tbInvoice.TaxValue, 
						  Invoice.tbInvoice.InvoiceValue + Invoice.tbInvoice.TaxValue AS TotalValue, 
						  Invoice.tbInvoice.PaymentTerms, Invoice.tbInvoice.Notes
	FROM         Invoice.tbInvoice INNER JOIN
						  Org.tbOrg ON Invoice.tbInvoice.AccountCode = Org.tbOrg.AccountCode INNER JOIN
						  Invoice.tbType ON Invoice.tbInvoice.InvoiceTypeCode = Invoice.tbType.InvoiceTypeCode INNER JOIN
						  Usr.tbUser ON Invoice.tbInvoice.UserId = Usr.tbUser.UserId INNER JOIN
						  Invoice.tbStatus ON Invoice.tbInvoice.InvoiceStatusCode = Invoice.tbStatus.InvoiceStatusCode LEFT OUTER JOIN
						  Org.tbAddress ON Org.tbOrg.AddressCode = Org.tbAddress.AddressCode
go
CREATE VIEW Invoice.vwDocDetails
AS
	SELECT 
		InvoiceNumber, 
		TaskCode ItemCode,
		ActivityCode ItemDescription,
		CAST(SecondReference as nvarchar(MAX)) ItemReference,
		TaxCode,
		InvoiceValue,
		TaxValue,
		InvoiceValue + TaxValue AS TotalValue,
		CAST(1 as bit) IsTask,
		ActionedOn,
		Quantity,
		UnitOfMeasure
	FROM Invoice.vwDocTask

	UNION

	SELECT
		InvoiceNumber,
		CashCode ItemCode,
		CashDescription ItemDescription,
		CAST(ItemReference as nvarchar(MAX)) ItemReference,
		TaxCode,
		InvoiceValue,
		TaxValue,
		InvoiceValue + TaxValue AS TotalValue,
		CAST(0 as bit) IsTask,
		ActionedOn,
		1 Quantity,
		NULL UnitOfMeasure	
	FROM Invoice.vwDocItem;
go
IF NOT EXISTS(SELECT * FROM sys.schemas s WHERE s.[name] = 'Web')
BEGIN
	DECLARE @SQL nvarchar(max) = 'CREATE SCHEMA Web';
	EXECUTE sys.sp_executesql @stmt = @SQL;
END
go
IF NOT EXISTS (select * from sys.tables where [name] = 'tbAttachment')
BEGIN
	CREATE TABLE Web.tbAttachment(
		AttachmentId int IDENTITY(1,1) NOT NULL,
		AttachmentFileName nvarchar(256) NOT NULL,
		CONSTRAINT PK_Web_tbAttachment PRIMARY KEY CLUSTERED (AttachmentId ASC)
	);

	CREATE TABLE Web.tbAttachmentInvoice(
		InvoiceTypeCode smallint NOT NULL,
		AttachmentId int NOT NULL,
		CONSTRAINT PK_Web_tbInvoiceAttachment PRIMARY KEY CLUSTERED (InvoiceTypeCode ASC, AttachmentId ASC)
	);

	CREATE TABLE Web.tbImage(
		ImageTag nvarchar(50) NOT NULL,
		ImageFileName nvarchar(256) NOT NULL,
		CONSTRAINT PK_Web_tbImage PRIMARY KEY CLUSTERED (ImageTag ASC)
	);

	CREATE TABLE Web.tbTemplate(
		TemplateId int IDENTITY(1,1) NOT NULL,
		TemplateFileName nvarchar(256) NULL,
		CONSTRAINT PK_Web_tbTemplate PRIMARY KEY CLUSTERED (TemplateId ASC)
	);

	CREATE TABLE Web.tbTemplateImage(
		TemplateId int NOT NULL,
		ImageTag nvarchar(50) NOT NULL,
		CONSTRAINT PK_Web_tbTemplateImage PRIMARY KEY CLUSTERED (TemplateId ASC,ImageTag ASC)
	);

	CREATE TABLE Web.tbTemplateInvoice(
		InvoiceTypeCode smallint NOT NULL,
		TemplateId int NOT NULL,
		LastUsedOn datetime NULL,
		CONSTRAINT PK_Web_tbTemplateInvoice PRIMARY KEY CLUSTERED (InvoiceTypeCode ASC,TemplateId ASC)
	);

	CREATE UNIQUE NONCLUSTERED INDEX IX_Web_tbAttachmentInvoice ON Web.tbAttachmentInvoice
	(
		AttachmentId ASC,
		InvoiceTypeCode ASC
	);

	CREATE UNIQUE NONCLUSTERED INDEX IX_Web_tbTemplateInvoice ON Web.tbTemplateInvoice
	(
		TemplateId ASC,
		InvoiceTypeCode ASC
	);

	CREATE NONCLUSTERED INDEX IX_Web_tbTemplateInvoice_LastUsedOn ON Web.tbTemplateInvoice
	(
		InvoiceTypeCode ASC,
		LastUsedOn DESC
	);

	CREATE UNIQUE NONCLUSTERED INDEX IX_Web_tbAttachment_AttachmentFileName ON Web.tbAttachment
	(
		AttachmentFileName ASC
	);

	CREATE UNIQUE NONCLUSTERED INDEX IX_Web_tbImage_ImageFileName ON Web.tbImage
	(
		ImageFileName ASC
	);

	CREATE UNIQUE NONCLUSTERED INDEX IX_Web_tbTemplate_TemplateFileName ON Web.tbTemplate
	(
		TemplateFileName ASC
	);

	ALTER TABLE Web.tbAttachmentInvoice  WITH CHECK ADD  CONSTRAINT FK_tbAttachmentInvoice_tbAttachment FOREIGN KEY(AttachmentId)
	REFERENCES Web.tbAttachment (AttachmentId)
	ON UPDATE CASCADE
	ON DELETE CASCADE

	ALTER TABLE Web.tbAttachmentInvoice CHECK CONSTRAINT FK_tbAttachmentInvoice_tbAttachment

	ALTER TABLE Web.tbAttachmentInvoice  WITH CHECK ADD  CONSTRAINT FK_tbAttachmentInvoice_tbType FOREIGN KEY(InvoiceTypeCode)
	REFERENCES Invoice.tbType (InvoiceTypeCode)

	ALTER TABLE Web.tbAttachmentInvoice CHECK CONSTRAINT FK_tbAttachmentInvoice_tbType

	ALTER TABLE Web.tbTemplateImage  WITH CHECK ADD  CONSTRAINT FK_tbTemplateImage_tbImage FOREIGN KEY(ImageTag)
	REFERENCES Web.tbImage (ImageTag)
	ON UPDATE CASCADE
	ON DELETE CASCADE

	ALTER TABLE Web.tbTemplateImage CHECK CONSTRAINT FK_tbTemplateImage_tbImage

	ALTER TABLE Web.tbTemplateImage  WITH CHECK ADD  CONSTRAINT FK_tbTemplateImage_tbTemplate FOREIGN KEY(TemplateId)
	REFERENCES Web.tbTemplate (TemplateId)
	ON UPDATE CASCADE
	ON DELETE CASCADE

	ALTER TABLE Web.tbTemplateImage CHECK CONSTRAINT FK_tbTemplateImage_tbTemplate

	ALTER TABLE Web.tbTemplateInvoice  WITH CHECK ADD  CONSTRAINT FK_tbTemplateInvoice_tbTemplate FOREIGN KEY(TemplateId)
	REFERENCES Web.tbTemplate (TemplateId)
	ON UPDATE CASCADE
	ON DELETE CASCADE

	ALTER TABLE Web.tbTemplateInvoice CHECK CONSTRAINT FK_tbTemplateInvoice_tbTemplate

	ALTER TABLE Web.tbTemplateInvoice  WITH CHECK ADD  CONSTRAINT FK_tbTemplateInvoice_tbType FOREIGN KEY(InvoiceTypeCode)
	REFERENCES Invoice.tbType (InvoiceTypeCode)

	ALTER TABLE Web.tbTemplateInvoice CHECK CONSTRAINT FK_tbTemplateInvoice_tbType
END
go
CREATE VIEW Org.vwEmailAddresses
AS
	SELECT AccountCode, AccountName ContactName, EmailAddress, CAST(1 as bit) IsAdmin
	FROM Org.tbOrg
	WHERE (NOT (EmailAddress IS NULL))
	UNION
	SELECT AccountCode, ContactName, EmailAddress, CAST(0 as bit) IsAdmin
	FROM            Org.tbContact
	WHERE        (NOT (EmailAddress IS NULL))
go
CREATE VIEW Web.vwTemplateInvoices
AS
	SELECT Web.tbTemplateInvoice.InvoiceTypeCode, Invoice.tbType.InvoiceType, Web.tbTemplateInvoice.TemplateId, Web.tbTemplate.TemplateFileName, Web.tbTemplateInvoice.LastUsedOn
	FROM Web.tbTemplateInvoice 
		JOIN Invoice.tbType ON Web.tbTemplateInvoice.InvoiceTypeCode = Invoice.tbType.InvoiceTypeCode 
		JOIN Web.tbTemplate ON Web.tbTemplateInvoice.TemplateId = Web.tbTemplate.TemplateId;
go
CREATE VIEW Web.vwTemplateImages
AS
	SELECT Web.tbTemplateImage.TemplateId, Web.tbTemplate.TemplateFileName, Web.tbTemplateImage.ImageTag, Web.tbImage.ImageFileName
	FROM Web.tbTemplateImage 
		JOIN Web.tbTemplate ON Web.tbTemplateImage.TemplateId = Web.tbTemplate.TemplateId 
		JOIN Web.tbImage ON Web.tbTemplateImage.ImageTag = Web.tbImage.ImageTag;
go
CREATE VIEW Web.vwAttachmentInvoices
AS
	SELECT Web.tbAttachmentInvoice.InvoiceTypeCode, Invoice.tbType.InvoiceType, Web.tbAttachmentInvoice.AttachmentId, Web.tbAttachment.AttachmentFileName
	FROM Web.tbAttachmentInvoice 
		JOIN Invoice.tbType ON Web.tbAttachmentInvoice.InvoiceTypeCode = Invoice.tbType.InvoiceTypeCode 
		JOIN Web.tbAttachment ON Web.tbAttachmentInvoice.AttachmentId = Web.tbAttachment.AttachmentId;
go
CREATE PROCEDURE Web.proc_ImageTag(@ImageTag nvarchar(50), @NewImageTag nvarchar(50))
AS
	SET NOCOUNT, XACT_ABORT ON;
	BEGIN TRY
		UPDATE Web.tbImage
		SET ImageTag = @NewImageTag
		WHERE ImageTag = @ImageTag
	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
go
ALTER VIEW App.vwIdentity
AS
	SELECT TOP (1) Org.tbOrg.AccountName, Org.tbAddress.Address, Org.tbOrg.PhoneNumber, Org.tbOrg.EmailAddress, Org.tbOrg.WebSite, Org.tbOrg.Logo, Usr.tbUser.UserName, Usr.tbUser.LogonName, Usr.tbUser.Avatar, 
							 Org.tbOrg.CompanyNumber, Org.tbOrg.VatNumber, App.tbUoc.UocName, App.tbUoc.UocSymbol
	FROM  Org.tbOrg INNER JOIN
		App.tbOptions ON Org.tbOrg.AccountCode = App.tbOptions.AccountCode INNER JOIN
		App.tbUoc ON App.tbOptions.UnitOfCharge = App.tbUoc.UnitOfCharge LEFT OUTER JOIN
		Org.tbAddress ON Org.tbOrg.AddressCode = Org.tbAddress.AddressCode CROSS JOIN
		Usr.vwCredentials INNER JOIN
		Usr.tbUser ON Usr.vwCredentials.UserId = Usr.tbUser.UserId
go
ALTER TRIGGER Usr.Usr_tbUser_TriggerUpdate 
   ON  Usr.tbUser
   AFTER UPDATE
AS 
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY
		IF NOT UPDATE(UserName)
		BEGIN
			UPDATE Usr.tbUser
			SET UpdatedBy = SUSER_SNAME(), UpdatedOn = CURRENT_TIMESTAMP
			FROM Usr.tbUser INNER JOIN inserted AS i ON tbUser.UserId = i.UserId;
		END
	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
END
go
ALTER VIEW Cash.vwReserveAccount
AS
	SELECT TOP 1 CashAccountCode, LiquidityLevel, CashAccountName, AccountNumber, SortCode 
	FROM Org.tbAccount 
			LEFT OUTER JOIN Cash.tbCode ON Org.tbAccount.CashCode = Cash.tbCode.CashCode 
	WHERE (Cash.tbCode.CashCode) IS NULL AND (Org.tbAccount.AccountTypeCode = 0) AND (Org.tbAccount.AccountClosed = 0)
	ORDER BY CashAccountCode
go
ALTER VIEW Cash.vwCurrentAccount
AS
	SELECT TOP (1) Org.tbAccount.CashAccountCode, Org.tbAccount.LiquidityLevel, Org.tbAccount.CashAccountName, Org.tbAccount.AccountNumber, Org.tbAccount.SortCode, Org.tbAccount.AccountCode, Org.tbOrg.AccountName
	FROM            Org.tbAccount INNER JOIN
							 Cash.tbCode ON Org.tbAccount.CashCode = Cash.tbCode.CashCode INNER JOIN
							 Cash.tbCategory ON Cash.tbCode.CategoryCode = Cash.tbCategory.CategoryCode INNER JOIN
							 Org.tbOrg ON Org.tbAccount.AccountCode = Org.tbOrg.AccountCode
	WHERE        (Cash.tbCategory.CashTypeCode = 2) AND (Org.tbAccount.AccountTypeCode = 0) AND (Org.tbAccount.AccountClosed = 0)
	ORDER BY Org.tbAccount.CashAccountCode;
go
ALTER TRIGGER Invoice.Invoice_tbInvoice_TriggerDelete
ON Invoice.tbInvoice
FOR DELETE
AS
	SET NOCOUNT ON;

	BEGIN TRY

		IF EXISTS (SELECT * FROM deleted INNER JOIN Org.tbOrg ON deleted.AccountCode = Org.tbOrg.AccountCode WHERE Org.tbOrg.TransmitStatusCode > 1)
		BEGIN
			DECLARE @Msg NVARCHAR(MAX);
			SELECT @Msg = Message FROM App.tbText WHERE TextId = 1220;
			RAISERROR (@Msg, 10, 1)
		END
		
	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
go
IF NOT EXISTS(SELECT * FROM App.tbMonth)
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
go

ALTER TRIGGER dbo.AspNetUsers_TriggerInsert 
   ON dbo.AspNetUsers
   AFTER INSERT
AS 
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY
		
		IF NOT EXISTS(SELECT * FROM Usr.tbUser)
		BEGIN
			UPDATE AspNetUsers
			SET EmailConfirmed = 1
			FROM AspNetUsers 
				JOIN inserted ON AspNetUsers.Id = inserted.Id;

			INSERT INTO AspNetUserRoles (UserId, RoleId)
			SELECT inserted.Id UserId, (SELECT Id FROM AspNetRoles WHERE [Name] = 'Administrators') RoleId 
			FROM inserted; 
		END
		ELSE IF EXISTS (SELECT * FROM inserted 
					JOIN Usr.tbUser ON inserted.UserName = Usr.tbUser.EmailAddress
					WHERE Usr.tbUser.IsAdministrator <> 0)
		BEGIN
			UPDATE AspNetUsers
			SET EmailConfirmed = 1
			FROM AspNetUsers 
				JOIN inserted ON AspNetUsers.Id = inserted.Id
				JOIN Usr.tbUser ON inserted.UserName = Usr.tbUser.EmailAddress
					WHERE Usr.tbUser.IsAdministrator <> 0;

			INSERT INTO AspNetUserRoles (UserId, RoleId)
			SELECT inserted.Id UserId, (SELECT Id FROM AspNetRoles WHERE [Name] = 'Administrators') RoleId 
				FROM inserted 
					JOIN Usr.tbUser ON inserted.UserName = Usr.tbUser.EmailAddress
			WHERE Usr.tbUser.IsAdministrator <> 0
		END

		UPDATE AspNetUsers
		SET PhoneNumber = Usr.tbUser.PhoneNumber, PhoneNumberConfirmed = 1
		FROM AspNetUsers 
			JOIN inserted ON AspNetUsers.Id = inserted.Id
			JOIN Usr.tbUser ON inserted.UserName = Usr.tbUser.EmailAddress;
	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH

END
go
ALTER TRIGGER dbo.AspNetUsers_TriggerUpdate 
   ON dbo.AspNetUsers
   AFTER UPDATE
AS 
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY

		IF UPDATE (EmailConfirmed)
			AND NOT EXISTS (SELECT * FROM inserted  JOIN Usr.tbUser ON inserted.Email = Usr.tbUser.EmailAddress )
			AND EXISTS (SELECT * FROM Usr.tbUser)
		BEGIN			
			ROLLBACK TRANSACTION;
			EXEC App.proc_EventLog 'Unregistered ASP.NET users cannot be confirmed';
		END

		IF UPDATE (PhoneNumber)
		BEGIN
			UPDATE Usr.tbUser
			SET PhoneNumber = inserted.PhoneNumber
			FROM inserted
				JOIN Usr.tbUser u ON inserted.UserName = u.EmailAddress
		END

	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH

END
go
IF NOT EXISTS (SELECT * FROM App.tbEventType WHERE EventTypeCode BETWEEN 0 AND 2)
BEGIN
	INSERT INTO App.tbEventType (EventTypeCode, EventType)
	VALUES (0, 'Error')
	, (1, 'Warning')
	, (2, 'Information');
END
go
ALTER PROCEDURE App.proc_NodeInitialisation
(
	@AccountCode NVARCHAR(10),
	@BusinessName NVARCHAR(255),
	@FullName NVARCHAR(100),
	@BusinessAddress NVARCHAR(MAX),
	@BusinessEmailAddress NVARCHAR(255) = null,
	@UserEmailAddress NVARCHAR(255) = null,
	@PhoneNumber NVARCHAR(50) = null,
	@CompanyNumber NVARCHAR(20) = null,
	@VatNumber NVARCHAR(20) = null,
	@CalendarCode NVARCHAR(10),
	@UnitOfCharge NVARCHAR(5)
)
AS
   	SET NOCOUNT, XACT_ABORT ON;

	BEGIN TRY

		BEGIN TRAN

		UPDATE Cash.tbTaxType
		SET AccountCode = null, CashCode = null;

		DELETE FROM App.tbOptions;

		DELETE FROM Cash.tbPayment;
		DELETE FROM Invoice.tbInvoice;
		DELETE FROM Task.tbFlow;
		DELETE FROM Task.tbTask;
		DELETE FROM Activity.tbFlow;
		DELETE FROM Activity.tbActivity;
		DELETE FROM Org.tbAccount;
		DELETE FROM Org.tbOrg;
		DELETE FROM Usr.tbMenuUser;
		DELETE FROM Usr.tbMenu;
		DELETE FROM Usr.tbUser;
		DELETE FROM App.tbCalendar;

		DELETE FROM App.tbYear;
		DELETE FROM App.tbBucket;
		DELETE FROM App.tbUom;
		DELETE FROM Cash.tbCategoryTotal;
		DELETE FROM Cash.tbCategoryExp;	
		DELETE FROM Cash.tbCode;
		DELETE FROM App.tbTaxCode;
		DELETE FROM Cash.tbTaxType;
		DELETE FROM Cash.tbCategory;
	
		/***************** CONTROL DATA *****************************************/
		IF NOT EXISTS(SELECT * FROM Activity.tbAttributeType)
			INSERT INTO Activity.tbAttributeType (AttributeTypeCode, AttributeType)
			VALUES (0, 'Order')
			, (1, 'Quote');

		IF NOT EXISTS(SELECT * FROM Activity.tbSyncType)
			INSERT INTO Activity.tbSyncType (SyncTypeCode, SyncType)
			VALUES (0, 'SYNC')
			, (1, 'ASYNC')
			, (2, 'CALL-OFF');

		IF NOT EXISTS(SELECT * FROM App.tbBucketInterval)
			INSERT INTO App.tbBucketInterval (BucketIntervalCode, BucketInterval)
			VALUES (0, 'Day')
			, (1, 'Week')
			, (2, 'Month');

		IF NOT EXISTS(SELECT * FROM App.tbBucketType)
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

		IF NOT EXISTS(SELECT * FROM App.tbCodeExclusion)
			INSERT INTO App.tbCodeExclusion (ExcludedTag)
			VALUES ('Limited')
			, ('Ltd')
			, ('PLC');

		IF NOT EXISTS(SELECT * FROM App.tbDocClass)
			INSERT INTO App.tbDocClass (DocClassCode, DocClass)
			VALUES (0, 'Product')
			, (1, 'Money');

		IF NOT EXISTS(SELECT * FROM App.tbDocType)
			INSERT INTO App.tbDocType (DocTypeCode, DocType, DocClassCode)
			VALUES (0, 'Quotation', 0)
			, (1, 'Sales Order', 0)
			, (2, 'Enquiry', 0)
			, (3, 'Purchase Order', 0)
			, (4, 'Sales Invoice', 1)
			, (5, 'Credit Note', 1)
			, (6, 'Debit Note', 1);

		IF NOT EXISTS(SELECT * FROM App.tbRecurrence)
			INSERT INTO App.tbRecurrence (RecurrenceCode, Recurrence)
			VALUES (0, 'On Demand')
			, (1, 'Monthly')
			, (2, 'Quarterly')
			, (3, 'Bi-annual')
			, (4, 'Yearly');

		IF NOT EXISTS(SELECT * FROM App.tbRounding)
			INSERT INTO App.tbRounding (RoundingCode, Rounding)
			VALUES (0, 'Round')
			, (1, 'Truncate');


		IF NOT EXISTS(SELECT * FROM Cash.tbCategoryType)
			INSERT INTO Cash.tbCategoryType (CategoryTypeCode, CategoryType)
			VALUES (0, 'Cash Code')
			, (1, 'Total')
			, (2, 'Expression');

		IF NOT EXISTS(SELECT * FROM Cash.tbEntryType)
			INSERT INTO Cash.tbEntryType (CashEntryTypeCode, CashEntryType)
			VALUES (0, 'Payment')
			, (1, 'Invoice')
			, (2, 'Order')
			, (3, 'Quote')
			, (4, 'Corporation Tax')
			, (5, 'Vat')
			, (6, 'Forecast');

		IF NOT EXISTS(SELECT * FROM Cash.tbMode)
			INSERT INTO Cash.tbMode (CashModeCode, CashMode)
			VALUES (0, 'Expense')
			, (1, 'Income')
			, (2, 'Neutral');

		IF NOT EXISTS(SELECT * FROM Cash.tbStatus)
			INSERT INTO Cash.tbStatus (CashStatusCode, CashStatus)
			VALUES (0, 'Forecast')
			, (1, 'Current')
			, (2, 'Closed')
			, (3, 'Archived');

		IF NOT EXISTS(SELECT * FROM Cash.tbTaxType)
			INSERT INTO Cash.tbTaxType (TaxTypeCode, TaxType, MonthNumber, RecurrenceCode, OffsetDays)
			VALUES (0, 'Corporation Tax', 12, 4, 275)
			, (1, 'Vat', 4, 2, 31)
			, (2, 'N.I.', 4, 1, 0)
			, (3, 'General', 4, 0, 0);

		IF NOT EXISTS(SELECT * FROM Cash.tbType)
			INSERT INTO Cash.tbType (CashTypeCode, CashType)
			VALUES (0, 'TRADE')
			, (1, 'EXTERNAL')
			, (2, 'MONEY');

		IF NOT EXISTS(SELECT * FROM Invoice.tbStatus)
			INSERT INTO Invoice.tbStatus (InvoiceStatusCode, InvoiceStatus)
			VALUES (1, 'Invoiced')
			, (2, 'Partially Paid')
			, (3, 'Paid')
			, (0, 'Pending');

		IF NOT EXISTS(SELECT * FROM Invoice.tbType)
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

		IF NOT EXISTS(SELECT * FROM Org.tbStatus)
			INSERT INTO Org.tbStatus (OrganisationStatusCode, OrganisationStatus)
			VALUES (0, 'Pending')
			, (1, 'Active')
			, (2, 'Hot')
			, (3, 'Dead');

		IF NOT EXISTS(SELECT * FROM Task.tbOpStatus)
			INSERT INTO Task.tbOpStatus (OpStatusCode, OpStatus)
			VALUES (0, 'Pending')
			, (1, 'In-progress')
			, (2, 'Complete');

		IF NOT EXISTS(SELECT * FROM Task.tbStatus)
			INSERT INTO Task.tbStatus (TaskStatusCode, TaskStatus)
			VALUES (0, 'Pending')
			, (1, 'Open')
			, (2, 'Closed')
			, (3, 'Charged')
			, (4, 'Cancelled')
			, (5, 'Archive');

		IF NOT EXISTS(SELECT * FROM Usr.tbMenuCommand)
			INSERT INTO Usr.tbMenuCommand (Command, CommandText)
			VALUES (0, 'Folder')
			, (1, 'Link')
			, (2, 'Form In Read Mode')
			, (3, 'Form In Add Mode')
			, (4, 'Form In Edit Mode')
			, (5, 'Report');

		IF NOT EXISTS(SELECT * FROM Usr.tbMenuOpenMode) 
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

		IF NOT EXISTS(SELECT * FROM App.tbRegister)
			INSERT INTO App.tbRegister (RegisterName, NextNumber)
			VALUES ('Expenses', 40000)
			, ('Event Log', 1)
			, ('Project', 30000)
			, ('Purchase Order', 20000)
			, ('Sales Order', 10000);

		IF NOT EXISTS(SELECT * FROM App.tbDoc)
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

		IF NOT EXISTS(SELECT * FROM Org.tbType)
			INSERT INTO Org.tbType (OrganisationTypeCode, CashModeCode, OrganisationType)
			VALUES (0, 0, 'Supplier')
			, (1, 1, 'Customer')
			, (2, 1, 'Prospect')
			, (4, 1, 'Company')
			, (5, 0, 'Bank')
			, (7, 0, 'Other')
			, (8, 0, 'TBC')
			, (9, 0, 'Employee');

		IF NOT EXISTS(SELECT * FROM App.tbText WHERE NOT TextId BETWEEN 1220 AND 1225)
		BEGIN
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
		END

		/***************** BUSINESS DATA *****************************************/

		INSERT INTO Org.tbOrg (AccountCode, AccountName, OrganisationTypeCode, OrganisationStatusCode, PhoneNumber, EmailAddress, CompanyNumber, VatNumber)
		VALUES (@AccountCode, @BusinessName, 4, 1, @PhoneNumber, @BusinessEmailAddress, @CompanyNumber, @VatNumber);

		EXEC Org.proc_AddContact @AccountCode = @AccountCode, @ContactName = @FullName;
		EXEC Org.proc_AddAddress @AccountCode = @AccountCode, @Address = @BusinessAddress;

		INSERT INTO App.tbCalendar (CalendarCode, Monday, Tuesday, Wednesday, Thursday, Friday, Saturday, Sunday)
		VALUES (@CalendarCode, 1, 1, 1, 1, 1, 0, 0);
		
		INSERT INTO Usr.tbUser (UserId, UserName, LogonName, IsAdministrator, IsEnabled, CalendarCode, EmailAddress, PhoneNumber)
		VALUES (CONCAT(LEFT(@FullName, 1), SUBSTRING(@FullName, CHARINDEX(' ', @FullName) + 1, 1)), @FullName, 
			SUSER_NAME() , 1, 1, @CalendarCode, @UserEmailAddress, @PhoneNumber);

		INSERT INTO App.tbOptions (Identifier, IsInitialised, AccountCode, RegisterName, DefaultPrintMode, BucketIntervalCode, BucketTypeCode, TaxHorizon, IsAutoOffsetDays, UnitOfCharge)
		VALUES ('TC', 0, @AccountCode, 'Event Log', 2, 1, 1, 730, 0, @UnitOfCharge);

		SET IDENTITY_INSERT [Usr].[tbMenu] ON;
		INSERT INTO [Usr].[tbMenu] ([MenuId], [MenuName], [InterfaceCode])
		VALUES (1, 'Accounts', 0)
		, (2, 'MIS', 1);
		SET IDENTITY_INSERT [Usr].[tbMenu] OFF;

		SET IDENTITY_INSERT [Usr].[tbMenuEntry] ON;
		INSERT INTO [Usr].[tbMenuEntry] ([MenuId], [EntryId], [FolderId], [ItemId], [ItemText], [Command], [ProjectName], [Argument], [OpenMode])
		VALUES (1, 1, 1, 0, 'Accounts', 0, '', 'Root', 0)
		, (1, 2, 2, 0, 'System Settings', 0, 'Trader', '', 0)
		, (1, 3, 2, 1, 'Administration', 4, 'Trader', 'App_Admin', 0)
		, (1, 4, 2, 2, 'SQL Connect', 4, 'Trader', 'Sys_SQLConnect', 0)
		, (1, 5, 2, 5, 'Definitions', 4, 'Trader', 'App_Definition', 0)
		, (1, 6, 4, 0, 'Cash Accounts', 0, 'Trader', '', 0)
		, (1, 7, 4, 2, 'Cash Account Statements', 4, 'Trader', 'Org_PaymentAccount', 0)
		, (1, 8, 5, 0, 'Invoicing', 0, 'Trader', '', 0)
		, (1, 9, 5, 3, 'Raise Invoices and Credit Notes', 4, 'Trader', 'Invoice_Entry', 0)
		, (1, 10, 6, 0, 'Transaction Entry', 0, 'Trader', '', 0)
		, (1, 12, 6, 5, 'Asset Entry', 4, 'Trader', 'Cash_Assets', 0)
		, (1, 13, 1, 1, 'System Settings', 1, '', '2', 0)
		, (1, 14, 1, 3, 'Cash Accounts', 1, '', '4', 0)
		, (1, 15, 1, 4, 'Invoicing', 1, '', '5', 0)
		, (1, 16, 1, 5, 'Transaction Entry', 1, '', '6', 0)
		, (1, 17, 5, 5, 'Invoice Register', 4, 'Trader', 'Invoice_Register', 0)
		, (1, 18, 4, 5, 'Bank Transfers', 4, 'Trader', 'Cash_Transfer', 0)
		, (1, 20, 6, 6, 'Budget', 4, 'Trader', 'Cash_Budget', 0)
		, (1, 21, 7, 0, 'Organisations', 0, 'Trader', '', 1)
		, (1, 22, 1, 6, 'Organisations', 1, '', '7', 1)
		, (1, 23, 7, 1, 'Organisation Maintenance', 4, 'Trader', 'Org_Maintenance', 0)
		, (1, 24, 7, 2, 'Organisation Enquiry', 4, 'Trader', 'Org_Enquiry', 0)
		, (1, 25, 7, 3, 'Balance Sheet Audit', 5, 'Trader', 'Org_BalanceSheetAudit', 2)
		, (2, 26, 1, 0, 'MIS', 0, '', 'Root', 0)
		, (2, 27, 2, 0, 'System Settings', 0, 'Trader', '', 0)
		, (2, 28, 2, 1, 'Administration', 4, 'Trader', 'App_Admin', 0)
		, (2, 29, 2, 2, 'SQL Connect', 4, 'Trader', 'Sys_SQLConnect', 0)
		, (2, 30, 2, 5, 'Definitions', 4, 'Trader', 'App_Definition', 0)
		, (2, 31, 4, 0, 'Maintenance', 0, 'Trader', '', 0)
		, (2, 32, 4, 1, 'Organisations', 4, 'Trader', 'Org_Maintenance', 0)
		, (2, 33, 4, 2, 'Activities', 4, 'Trader', 'Activity_Edit', 0)
		, (2, 34, 5, 0, 'Work Flow', 0, 'Trader', '', 0)
		, (2, 35, 5, 1, 'Task Explorer', 4, 'Trader', 'Task_Explorer', 0)
		, (2, 36, 5, 2, 'Document Manager', 4, 'Trader', 'App_DocManager', 0)
		, (2, 37, 5, 3, 'Raise Invoices', 4, 'Trader', 'Invoice_Raise', 0)
		, (2, 38, 6, 0, 'Information', 0, 'Trader', '', 0)
		, (2, 39, 6, 1, 'Organisation Enquiry', 2, 'Trader', 'Org_Enquiry', 0)
		, (2, 40, 6, 2, 'Invoice Register', 4, 'Trader', 'Invoice_Register', 0)
		, (2, 41, 6, 3, 'Cash Statements', 4, 'Trader', 'Org_PaymentAccount', 0)
		, (2, 42, 6, 4, 'Data Warehouse', 4, 'Trader', 'App_Warehouse', 0)
		, (2, 43, 6, 5, 'Company Statement', 4, 'Trader', 'Cash_Statement', 0)
		, (2, 44, 4, 3, 'Organisation Datasheet', 4, 'Trader', 'Org_Maintenance', 1)
		, (2, 45, 6, 6, 'Job Profit Status by Month', 4, 'Trader', 'Task_ProfitStatus', 0)
		, (2, 46, 5, 6, 'Expenses', 3, 'Trader', 'Task_Expenses', 0)
		, (2, 47, 1, 1, 'System Settings', 1, '', '2', 0)
		, (2, 48, 1, 3, 'Maintenance', 1, '', '4', 0)
		, (2, 49, 1, 4, 'Workflow', 1, '', '5', 0)
		, (2, 50, 1, 5, 'Information', 1, '', '6', 0)
		, (2, 51, 6, 7, 'Status Graphs', 4, 'Trader', 'Cash_StatusGraphs', 0)
		, (2, 53, 4, 4, 'Budget', 4, 'Trader', 'Cash_Budget', 0)
		, (2, 54, 4, 5, 'Assets', 4, 'Trader', 'Cash_Assets', 0)
		, (2, 57, 5, 7, 'Network Allocations', 4, 'Trader', 'Task_Allocation', 0)
		, (2, 58, 5, 8, 'Network Invoices', 4, 'Trader', 'Invoice_Mirror', 0)
		, (2, 62, 7, 0, 'Audit Reports', 0, 'Trader', '', 1)
		, (2, 63, 6, 11, 'Audit Reports', 1, '', '7', 1)
		, (2, 64, 7, 1, 'Corporation Tax Accruals', 5, 'Trader', 'Cash_CorpTaxAuditAccruals', 4)
		, (2, 65, 7, 2, 'Vat Accruals', 5, 'Trader', 'Cash_VatAuditAccruals', 4)
		, (2, 66, 7, 3, 'Balance Sheet Audit', 5, 'Trader', 'Org_BalanceSheetAudit', 4);
		SET IDENTITY_INSERT [Usr].[tbMenuEntry] OFF;

		IF @UnitOfCharge <> 'BTC'
		BEGIN
			INSERT INTO Usr.tbMenuEntry (MenuId, FolderId, ItemId, ItemText, Command, ProjectName, Argument, OpenMode)
			VALUES 
				(1, 6, 3, 'Payment Entry', 4, 'Trader', 'Cash_PaymentEntry', 0)
				, (2, 5, 5, 'Transfers', 4, 'Trader', 'Cash_Transfer', 0)
				, (2, 5, 4, 'Payment Entry', 4, 'Trader', 'Cash_PaymentEntry', 0)
				

		END


		INSERT INTO Usr.tbMenuUser (UserId, MenuId)
		SELECT (SELECT UserId FROM Usr.tbUser) AS UserId, MenuId 
		FROM Usr.tbMenu;

		COMMIT TRAN
  	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
go
ALTER PROCEDURE App.proc_TemplateTutorials
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
		, ('TA1', 'Taxes on Company', 0, 0, 1, 60, 1)
		, ('TA2', 'Taxes on Trade', 0, 0, 1, 60, 1)
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
		, ('TP', 'TA1')
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
		, ('601', 'VAT', 'TA2', 'N/A', 1)
		, ('602', 'Taxes (General)', 'TA1', 'N/A', 1)
		, ('603', 'Taxes (Corporation)', 'TA2', 'N/A', 1)
		, ('604', 'Employers NI', 'TA1', 'N/A', 1)
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

		--CAPITAL 
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


	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog
	END CATCH
go
ALTER PROCEDURE App.proc_TemplateCompanyGeneral
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

		INSERT INTO Cash.tbCategory (CategoryCode, Category, CategoryTypeCode, CashModeCode, CashTypeCode, DisplayOrder, IsEnabled)
		VALUES ('AL', 'Assets and Liabilities', 1, 2, 0, 20, 1)
		, ('AS', 'Assets', 0, 1, 2, 70, 1)
		, ('BA', 'Bank Accounts', 0, 2, 2, 80, 1)
		, ('BP', 'Bank Payments', 0, 0, 0, 90, 1)
		, ('BR', 'Bank Receipts', 0, 1, 0, 100, 1)
		, ('DB', 'Directors Bank Account', 0, 1, 0, 0, 1)
		, ('DBA', 'Director Account', 1, 2, 0, 11, 1)
		, ('DC', 'Direct Cost', 0, 0, 0, 20, 1)
		, ('DI', 'Dividends', 0, 0, 0, 110, -1)
		, ('DR', 'Drawings', 0, 2, 0, 150, 0)
		, ('EX', 'Expenses', 1, 2, 0, 10, 1)
		, ('FY', 'Profit for Financial Year', 1, 2, 0, 50, 1)
		, ('IC', 'Indirect Cost', 0, 0, 0, 30, 1)
		, ('IP', 'Intercompany Payment', 0, 0, 2, 120, 1)
		, ('IR', 'Intercompany Receipt', 0, 1, 2, 130, 1)
		, ('IV', 'Investment', 0, 2, 0, 160, 1)
		, ('LI', 'Liabilities', 0, 0, 2, 71, 1)
		, ('PL', 'Profit Before Taxation', 1, 2, 0, 30, 1)
		, ('SA', 'Sales', 0, 1, 0, 10, 1)
		, ('TA', 'Tax on Company', 0, 0, 1, 60, 1)
		, ('TO', 'Turnover', 1, 2, 0, 0, 1)
		, ('TP', 'Tax on Profit', 1, 2, 0, 40, 1)
		, ('TR', 'Trading Profit', 1, 2, 0, 12, 1)
		, ('TV', 'Tax on Goods', 0, 0, 1, 61, -1)
		, ('VAT', 'Vat Cash Codes', 1, 2, 0, 100, 1)
		, ('WA', 'Wages', 0, 0, 0, 50, 1)
		;

		INSERT INTO Cash.tbCode (CashCode, CashDescription, CategoryCode, TaxCode, IsEnabled)
		VALUES ('ACCOUNTS', 'Professional Fees', 'IC', 'T1', 1)
		, ('ADMIN', 'Company Administration', 'IC', 'T1', 1)
		, ('BANKINTR', 'Bank Interest', 'BR', 'N/A', 1)
		, ('BC', 'Bank Charges', 'BP', 'N/A', 1)
		, ('CAPITAL', 'Share Capital', 'LI', 'N/A', 1)
		, ('CASH', 'Company Cash', 'BA', 'N/A', 1)
		, ('COMS', 'Communications', 'IC', 'T1', 1)
		, ('DEBTWRITEOFF', 'Capital Debt Write-off', 'DB', 'N/A', 1)
		, ('DEPR', 'Depreciation', 'AS', 'N/A', 1)
		, ('DIVIDEND', 'Dividends', 'DI', 'N/A', 1)
		, ('DLAP', 'Directors Personal Bank', 'DB', 'N/A', 1)
		, ('EQUIP', 'Equipment Expensed', 'IC', 'T1', 1)
		, ('EXPENSES', 'Directors Expenses reimbursement', 'IC', 'N/A', 1)
		, ('IT', 'IT and Software', 'IC', 'T1', 1)
		, ('LOANCOM', 'Company Loan', 'IV', 'N/A', -1)
		, ('LOANDIR', 'Directors Loan', 'IV', 'N/A', 1)
		, ('LOANREPAY', 'Dept Repayment', 'LI', 'N/A', 1)
		, ('MAT', 'Material Purchases', 'DC', 'T1', 1)
		, ('MILEAGE', 'Travel - Car Mileage', 'IC', 'T0', 1)
		, ('NI', 'Employers NI', 'TA', 'N/A', 1)
		, ('OFFICERENT', 'Office Rent', 'IC', 'T0', 1)
		, ('PAYIN', 'Transfer Receipt', 'IR', 'N/A', 1)
		, ('PAYOUT', 'Account Payment', 'IP', 'N/A', 1)
		, ('POST', 'Post and Stationary', 'IC', 'T1', 1)
		, ('PURCHASES', 'Direct Purchase', 'DC', 'T1', 1)
		, ('SALARY', 'Salaries', 'WA', 'NI1', 1)
		, ('SALES', 'Sales', 'SA', 'T1', 1)
		, ('SUNDRYCOST', 'Sundry Costs', 'IC', 'T1', 1)
		, ('TAXCOMPANY', 'Taxes (Corporation)', 'TV', 'N/A', 1)
		, ('TAXGENERAL', 'Taxes (General)', 'TA', 'N/A', 1)
		, ('TAXVAT', 'VAT', 'TV', 'N/A', 1)
		, ('TRAVEL', 'Travel - General', 'IC', 'T1', 1)
		;
		INSERT INTO Cash.tbCategoryTotal (ParentCode, ChildCode)
		VALUES ('AL', 'AS')
		, ('AL', 'LI')
		, ('DBA', 'DB')
		, ('EX', 'BP')
		, ('EX', 'DC')
		, ('EX', 'IC')
		, ('EX', 'WA')
		, ('FY', 'PL')
		, ('FY', 'TP')
		, ('PL', 'AL')
		, ('PL', 'TR')
		, ('TO', 'BR')
		, ('TO', 'IV')
		, ('TO', 'SA')
		, ('TP', 'TA')
		, ('TR', 'DB')
		, ('TR', 'EX')
		, ('TR', 'TO')
		, ('VAT', 'DC')
		, ('VAT', 'IC')
		, ('VAT', 'SA')
		;

		IF @CoinTypeCode < 2
		BEGIN
			INSERT INTO [Cash].[tbCode] ([CashCode], [CashDescription], [CategoryCode], [TaxCode], [IsEnabled])
			VALUES ('MINERFEE', 'Miner Fees', 'IC', 'N/A', 1);
		
			UPDATE App.tbOptions
			SET MinerFeeCode = 'MINERFEE';
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

		--ASSIGN CASH CODES AND GOV TO TAX TYPES
		UPDATE Cash.tbTaxType
		SET AccountCode = @AccountCode, CashCode = 'TAXCOMPANY', MonthNumber = @FinancialMonth
		WHERE TaxTypeCode = 0;

		UPDATE Cash.tbTaxType
		SET AccountCode = @AccountCode, CashCode = 'TAXVAT', MonthNumber = @FinancialMonth
		WHERE TaxTypeCode = 1;

		UPDATE Cash.tbTaxType
		SET AccountCode = @AccountCode, CashCode = 'NI', MonthNumber = @FinancialMonth
		WHERE TaxTypeCode = 2;

		UPDATE Cash.tbTaxType
		SET AccountCode = @AccountCode, CashCode = 'TAXGENERAL', MonthNumber = @FinancialMonth
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
		VALUES        (@CashAccountCode, @AccountCode, @CurrentAccount, 0, @CA_SortCode, @CA_AccountNumber, 'CASH')

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
			INSERT INTO Org.tbAccount (CashAccountCode, AccountCode, CashAccountName, AccountTypeCode)
			VALUES        (@CashAccountCode, @AccountCode, @DummyAccount, 1);
		END

		--CAPITAL 
		DECLARE @CapitalAccount NVARCHAR(50);

		SET @CapitalAccount = 'LONGTERM LIABILITIES';
		EXEC Org.proc_DefaultAccountCode @AccountName = @CapitalAccount, @AccountCode = @CashAccountCode OUTPUT
		INSERT INTO Org.tbAccount (CashAccountCode, AccountCode, CashAccountName, AccountTypeCode, LiquidityLevel, CashCode, AccountClosed)
		VALUES        (@CashAccountCode, @AccountCode, @CapitalAccount, 2, 50, 'LOANREPAY', 0);

		SET @CapitalAccount = 'CALLED UP SHARE CAPITAL';
		EXEC Org.proc_DefaultAccountCode @AccountName = @CapitalAccount, @AccountCode = @CashAccountCode OUTPUT
		INSERT INTO Org.tbAccount (CashAccountCode, AccountCode, CashAccountName, AccountTypeCode, LiquidityLevel, CashCode, AccountClosed)
		VALUES        (@CashAccountCode, @AccountCode, @CapitalAccount, 2, 60, 'CAPITAL', 0);

		SET @CapitalAccount = 'PLANT AND MACHINERY';
		EXEC Org.proc_DefaultAccountCode @AccountName = @CapitalAccount, @AccountCode = @CashAccountCode OUTPUT
		INSERT INTO Org.tbAccount (CashAccountCode, AccountCode, CashAccountName, AccountTypeCode, LiquidityLevel, CashCode, AccountClosed)
		VALUES        (@CashAccountCode, @AccountCode, @CapitalAccount, 2, 30, 'DEPR', 1);

	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog
	END CATCH
go
ALTER PROCEDURE App.proc_BasicSetup
(
	@TemplateName NVARCHAR(100),
	@FinancialMonth SMALLINT = 4,
	@CoinTypeCode SMALLINT,
	@GovAccountName NVARCHAR(255),
	@BankName NVARCHAR(255) = null,
	@BankAddress NVARCHAR(MAX) = null,
	@DummyAccount NVARCHAR(50) = null, 
	@CurrentAccount NVARCHAR(50) = null,
	@CA_SortCode NVARCHAR(10) = null,
	@CA_AccountNumber NVARCHAR(20) = null,
	@ReserveAccount NVARCHAR(50) = null, 
	@RA_SortCode NVARCHAR(10) = null,
	@RA_AccountNumber NVARCHAR(20) = null
)
AS
	DECLARE 
		@FinancialYear SMALLINT = DATEPART(YEAR, CURRENT_TIMESTAMP);

		IF EXISTS (SELECT * FROM App.tbOptions WHERE UnitOfCharge <> 'BTC') AND (@CoinTypeCode <> 2)
			SET @CoinTypeCode = 2;

		IF DATEPART(MONTH, CURRENT_TIMESTAMP) < @FinancialMonth
			 SET @FinancialYear -= 1;
		
	DECLARE 
		@Year SMALLINT = @FinancialYear - 1;

	SET NOCOUNT, XACT_ABORT ON;

	BEGIN TRY
		BEGIN TRAN
		
		UPDATE App.tbOptions
		SET CoinTypeCode = @CoinTypeCode;

		DECLARE 
			@ProcName nvarchar(100) = (SELECT StoredProcedure FROM App.tbTemplate WHERE TemplateName = @TemplateName);		

		EXEC @ProcName
				@FinancialMonth = @FinancialMonth,
				@GovAccountName = @GovAccountName, 
				@BankName = @BankName, 
				@BankAddress = @BankAddress, 
				@DummyAccount = @DummyAccount, 
				@CurrentAccount = @CurrentAccount, 
				@CA_SortCode = @CA_SortCode, 
				@CA_AccountNumber = @CA_AccountNumber, 
				@ReserveAccount = @ReserveAccount, 
				@RA_SortCode = @RA_SortCode, 
				@RA_AccountNumber = @RA_AccountNumber;

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

		COMMIT TRAN
	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog
	END CATCH
go
CREATE PROCEDURE Invoice.proc_PostEntryById(@UserId nvarchar(10), @AccountCode nvarchar(10), @CashCode nvarchar(50))
AS
   	SET NOCOUNT, XACT_ABORT ON;

	BEGIN TRY
		DECLARE 
			@InvoiceTypeCode smallint
			, @InvoiceNumber nvarchar(20);
			

		BEGIN TRAN;

		SELECT @InvoiceTypeCode = InvoiceTypeCode 
		FROM Invoice.tbEntry 
		WHERE UserId = @UserId AND AccountCode = @AccountCode AND CashCode = @CashCode;
		
		EXEC Invoice.proc_RaiseBlank @AccountCode, @InvoiceTypeCode, @InvoiceNumber output;

		WITH invoice_entry AS
		(
			SELECT @InvoiceNumber InvoiceNumber, MIN(InvoicedOn) InvoicedOn
			FROM Invoice.tbEntry
			WHERE AccountCode = @AccountCode AND InvoiceTypeCode = @InvoiceTypeCode
		)
		UPDATE Invoice.tbInvoice
		SET 
			UserId = @UserId,
			InvoicedOn = invoice_entry.InvoicedOn,
			Printed = CASE WHEN  @InvoiceTypeCode < 2 THEN 0 ELSE 1 END
		FROM Invoice.tbInvoice invoice_header 
			JOIN invoice_entry ON invoice_header.InvoiceNumber = invoice_entry.InvoiceNumber;

		INSERT INTO Invoice.tbItem (InvoiceNumber, CashCode, TaxCode, ItemReference, TotalValue, InvoiceValue)
		SELECT @InvoiceNumber InvoiceNumber, CashCode, TaxCode, ItemReference, TotalValue, InvoiceValue
		FROM Invoice.tbEntry
		WHERE AccountCode = @AccountCode AND CashCode = @CashCode

		EXEC Invoice.proc_Accept @InvoiceNumber;

		DELETE FROM Invoice.tbEntry
		WHERE UserId = @UserId AND AccountCode = @AccountCode AND CashCode = @CashCode;

		COMMIT TRAN;

  	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
go
CREATE PROCEDURE Invoice.proc_PostAccountById(@UserId nvarchar(10), @AccountCode nvarchar(10))
AS
   	SET NOCOUNT, XACT_ABORT ON;

	BEGIN TRY
		DECLARE 			
			@InvoiceTypeCode smallint
			, @InvoiceNumber nvarchar(20);
			
		DECLARE c1 CURSOR LOCAL FOR
			SELECT InvoiceTypeCode
			FROM Invoice.tbEntry
			WHERE UserId = @UserId AND AccountCode = @AccountCode
			GROUP BY InvoiceTypeCode;

		OPEN c1;

		BEGIN TRAN;

		FETCH NEXT FROM c1 INTO @InvoiceTypeCode;
		
		WHILE (@@FETCH_STATUS = 0)
		BEGIN
			EXEC Invoice.proc_RaiseBlank @AccountCode, @InvoiceTypeCode, @InvoiceNumber output;

			WITH invoice_entry AS
			(
				SELECT @InvoiceNumber InvoiceNumber, MIN(InvoicedOn) InvoicedOn
				FROM Invoice.tbEntry
				WHERE AccountCode = @AccountCode AND InvoiceTypeCode = @InvoiceTypeCode
			)
			UPDATE Invoice.tbInvoice
			SET 
				UserId = @UserId,
				InvoicedOn = invoice_entry.InvoicedOn,
				Printed = CASE WHEN  @InvoiceTypeCode < 2 THEN 0 ELSE 1 END
			FROM Invoice.tbInvoice invoice_header 
				JOIN invoice_entry ON invoice_header.InvoiceNumber = invoice_entry.InvoiceNumber;

			INSERT INTO Invoice.tbItem (InvoiceNumber, CashCode, TaxCode, ItemReference, TotalValue, InvoiceValue)
			SELECT @InvoiceNumber InvoiceNumber, CashCode, TaxCode, ItemReference, TotalValue, InvoiceValue
			FROM Invoice.tbEntry
			WHERE UserId = @UserId AND AccountCode = @AccountCode AND InvoiceTypeCode = @InvoiceTypeCode

			EXEC Invoice.proc_Accept @InvoiceNumber;

			FETCH NEXT FROM c1 INTO @InvoiceTypeCode;
		END

		DELETE FROM Invoice.tbEntry
		WHERE UserId = @UserId AND AccountCode = @AccountCode;

		COMMIT TRAN;

		CLOSE c1;
		DEALLOCATE c1;

  	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
go
UPDATE App.tbTemplate
SET TemplateName = '1: MIS Tutorials'
WHERE TemplateName = '1: Tutorials Template'
go
ALTER VIEW App.vwPeriods
AS
	SELECT TOP (100) PERCENT App.tbYear.YearNumber, App.tbYearPeriod.MonthNumber, App.tbYearPeriod.StartOn, App.tbYear.Description + SPACE(1) + App.tbMonth.MonthName AS Description, App.tbYearPeriod.CashStatusCode, App.tbYearPeriod.RowVer
	FROM            App.tbYearPeriod INNER JOIN
							 App.tbMonth ON App.tbYearPeriod.MonthNumber = App.tbMonth.MonthNumber INNER JOIN
							 App.tbYear ON App.tbYearPeriod.YearNumber = App.tbYear.YearNumber
	WHERE        (App.tbYear.CashStatusCode < 3) AND (App.tbYearPeriod.CashStatusCode < 3)

go
ALTER VIEW Cash.vwPayments
AS
	SELECT        Cash.tbPayment.PaymentCode, Cash.tbPayment.PaymentStatusCode, Cash.tbPayment.UserId, Usr.tbUser.UserName, Org.tbOrg.AccountName, Cash.tbPayment.AccountCode, Cash.tbPayment.CashAccountCode, Org.tbAccount.CashAccountName, 
							 Cash.tbPayment.CashCode, Cash.tbCode.CashDescription, Cash.tbPayment.TaxCode, App.tbTaxCode.TaxDescription, Cash.tbPayment.PaidOn, Cash.tbPayment.PaidInValue, Cash.tbPayment.PaidOutValue, 
							 Cash.tbPayment.PaymentReference, Cash.tbPayment.IsProfitAndLoss, Cash.tbPayment.InsertedBy, Cash.tbPayment.InsertedOn, Cash.tbPayment.UpdatedBy, Cash.tbPayment.UpdatedOn
	FROM            Cash.tbPayment INNER JOIN
							 Usr.tbUser ON Cash.tbPayment.UserId = Usr.tbUser.UserId INNER JOIN
							 Org.tbOrg ON Cash.tbPayment.AccountCode = Org.tbOrg.AccountCode INNER JOIN
							 Org.tbAccount ON Cash.tbPayment.CashAccountCode = Org.tbAccount.CashAccountCode LEFT OUTER JOIN
							 App.tbTaxCode ON Cash.tbPayment.TaxCode = App.tbTaxCode.TaxCode LEFT OUTER JOIN
							 Cash.tbCode ON Cash.tbPayment.CashCode = Cash.tbCode.CashCode
go
ALTER VIEW Cash.vwBankCashCodes
AS
	SELECT        Cash.tbCode.CashCode, Cash.tbCode.CashDescription, Cash.tbCode.TaxCode, Cash.tbCategory.CashModeCode
	FROM            Cash.tbCode INNER JOIN
							 Cash.tbCategory ON Cash.tbCode.CategoryCode = Cash.tbCategory.CategoryCode LEFT OUTER JOIN
							 Cash.vwTransferCodeLookup ON Cash.tbCode.CashCode = Cash.vwTransferCodeLookup.CashCode
	WHERE        (Cash.tbCategory.CashTypeCode = 2)
go