/**************************************************************************************
Trade Control
Upgrade script
Release: 3.24.1

Date: 1 August 2019
Author: Ian Monnox

Trade Control by Trade Control Ltd is licensed under GNU General Public License v3.0. 

You may obtain a copy of the License at

	https://www.gnu.org/licenses/gpl-3.0.en.html

Purpose:
Demonstrates how upgrades are applied.
The script removes all references to Fax Machines from the schema.

Instructions:
This script should be applied by the TC Node Configuration app.
It inserts the upgade into App.tbInstall.

***********************************************************************************/
go
ALTER PROCEDURE Task.proc_Configure 
	(
	@ParentTaskCode nvarchar(20)
	)
AS
 	SET NOCOUNT, XACT_ABORT ON;

	BEGIN TRY
		DECLARE 
			@StepNumber smallint
			, @TaskCode nvarchar(20)
			, @UserId nvarchar(10)
			, @ActivityCode nvarchar(50)
			, @AccountCode nvarchar(10)
			, @DefaultAccountCode nvarchar(10)
			, @TaxCode nvarchar(10)

		IF @@NESTLEVEL = 1
			BEGIN TRANSACTION

		INSERT INTO Org.tbContact 
			(AccountCode, ContactName, FileAs, PhoneNumber, EmailAddress)
		SELECT Task.tbTask.AccountCode, Task.tbTask.ContactName, Task.tbTask.ContactName AS NickName, Org.tbOrg.PhoneNumber, Org.tbOrg.EmailAddress
		FROM  Task.tbTask 
			INNER JOIN Org.tbOrg ON Task.tbTask.AccountCode = Org.tbOrg.AccountCode
		WHERE        (Task.tbTask.TaskCode = @ParentTaskCode)
					AND EXISTS (SELECT *
								FROM Task.tbTask
								WHERE (TaskCode = @ParentTaskCode) AND (NOT (ContactName IS NULL)) OR (TaskCode = @ParentTaskCode) AND (ContactName <> N''))
				AND NOT EXISTS(SELECT *
								FROM  Task.tbTask 
									INNER JOIN Org.tbContact ON Task.tbTask.AccountCode = Org.tbContact.AccountCode AND Task.tbTask.ContactName = Org.tbContact.ContactName
								WHERE     ( Task.tbTask.TaskCode = @ParentTaskCode))
	
		UPDATE Org.tbOrg
		SET OrganisationStatusCode = 1
		FROM Org.tbOrg INNER JOIN Task.tbTask ON Org.tbOrg.AccountCode = Task.tbTask.AccountCode
		WHERE ( Task.tbTask.TaskCode = @ParentTaskCode) AND ( Org.tbOrg.OrganisationStatusCode = 0)				
			AND EXISTS(SELECT *
				FROM  Org.tbOrg INNER JOIN Task.tbTask ON Org.tbOrg.AccountCode = Task.tbTask.AccountCode
				WHERE     ( Task.tbTask.TaskCode = @ParentTaskCode) AND ( Org.tbOrg.OrganisationStatusCode = 0))
	          
		UPDATE    Task.tbTask
		SET  ActionedOn = ActionOn
		WHERE (TaskCode = @ParentTaskCode)
			AND EXISTS(SELECT *
					  FROM Task.tbTask
					  WHERE (TaskStatusCode = 2) AND (TaskCode = @ParentTaskCode))

		UPDATE Task.tbTask
		SET TaskTitle = ActivityCode
		WHERE (TaskCode = @ParentTaskCode)
			AND EXISTS(SELECT *
				  FROM Task.tbTask
				  WHERE (TaskCode = @ParentTaskCode) AND (TaskTitle IS NULL))  	 				              
	     	
		INSERT INTO Task.tbAttribute
			(TaskCode, Attribute, AttributeDescription, PrintOrder, AttributeTypeCode)
		SELECT Task.tbTask.TaskCode, Activity.tbAttribute.Attribute, Activity.tbAttribute.DefaultText, Activity.tbAttribute.PrintOrder, Activity.tbAttribute.AttributeTypeCode
		FROM Activity.tbAttribute 
			INNER JOIN Task.tbTask ON Activity.tbAttribute.ActivityCode = Task.tbTask.ActivityCode
		WHERE     ( Task.tbTask.TaskCode = @ParentTaskCode)
	
		INSERT INTO Task.tbOp
			(TaskCode, UserId, OperationNumber, SyncTypeCode, Operation, Duration, OffsetDays, StartOn)
		SELECT Task.tbTask.TaskCode, Task.tbTask.UserId, Activity.tbOp.OperationNumber, Activity.tbOp.SyncTypeCode, Activity.tbOp.Operation, Activity.tbOp.Duration,  Activity.tbOp.OffsetDays, Task.tbTask.ActionOn
		FROM Activity.tbOp INNER JOIN Task.tbTask ON Activity.tbOp.ActivityCode = Task.tbTask.ActivityCode
		WHERE     ( Task.tbTask.TaskCode = @ParentTaskCode)
	                   
	
		SELECT @UserId = UserId FROM Task.tbTask WHERE Task.tbTask.TaskCode = @ParentTaskCode
	
		DECLARE curAct cursor local for
			SELECT Activity.tbFlow.StepNumber
			FROM Activity.tbFlow INNER JOIN Task.tbTask ON Activity.tbFlow.ParentCode = Task.tbTask.ActivityCode
			WHERE     ( Task.tbTask.TaskCode = @ParentTaskCode)
			ORDER BY Activity.tbFlow.StepNumber	
	
		OPEN curAct
		FETCH NEXT FROM curAct INTO @StepNumber
		WHILE @@FETCH_STATUS = 0
			BEGIN
			SELECT  
				@ActivityCode = Activity.tbActivity.ActivityCode, 
				@AccountCode = Task.tbTask.AccountCode
			FROM Activity.tbFlow 
				INNER JOIN Activity.tbActivity ON Activity.tbFlow.ChildCode = Activity.tbActivity.ActivityCode 
				INNER JOIN Task.tbTask ON Activity.tbFlow.ParentCode = Task.tbTask.ActivityCode
			WHERE     ( Activity.tbFlow.StepNumber = @StepNumber) AND ( Task.tbTask.TaskCode = @ParentTaskCode)
		
			EXEC Task.proc_NextCode @ActivityCode, @TaskCode output

			INSERT INTO Task.tbTask
				(TaskCode, UserId, AccountCode, ContactName, ActivityCode, TaskStatusCode, ActionById, ActionOn, TaskNotes, Quantity, UnitCharge, AddressCodeFrom, AddressCodeTo, CashCode, Printed, TaskTitle)
			SELECT  @TaskCode AS NewTask, Task_tb1.UserId, Task_tb1.AccountCode, Task_tb1.ContactName, Activity.tbActivity.ActivityCode, Activity.tbActivity.TaskStatusCode, 
						Task_tb1.ActionById, Task_tb1.ActionOn, Activity.tbActivity.DefaultText, Task_tb1.Quantity * Activity.tbFlow.UsedOnQuantity AS Quantity,
						Activity.tbActivity.UnitCharge, Org.tbOrg.AddressCode AS AddressCodeFrom, Org.tbOrg.AddressCode AS AddressCodeTo, 
						tbActivity.CashCode, CASE WHEN Activity.tbActivity.Printed = 0 THEN 1 ELSE 0 END AS Printed, Task_tb1.TaskTitle
			FROM  Activity.tbFlow 
				INNER JOIN Activity.tbActivity ON Activity.tbFlow.ChildCode = Activity.tbActivity.ActivityCode 
				INNER JOIN Task.tbTask Task_tb1 ON Activity.tbFlow.ParentCode = Task_tb1.ActivityCode 
				INNER JOIN Org.tbOrg ON Task_tb1.AccountCode = Org.tbOrg.AccountCode
			WHERE     ( Activity.tbFlow.StepNumber = @StepNumber) AND ( Task_tb1.TaskCode = @ParentTaskCode)

			IF EXISTS (SELECT * FROM Task.tbTask 
							INNER JOIN  Org.tbOrg ON Task.tbTask.AccountCode = Org.tbOrg.AccountCode 
							INNER JOIN App.tbTaxCode ON Org.tbOrg.TaxCode = App.tbTaxCode.TaxCode AND Org.tbOrg.TaxCode = App.tbTaxCode.TaxCode)
				BEGIN
				UPDATE Task.tbTask
				SET TaxCode = App.tbTaxCode.TaxCode
				FROM Task.tbTask 
					INNER JOIN Org.tbOrg ON Task.tbTask.AccountCode = Org.tbOrg.AccountCode 
					INNER JOIN App.tbTaxCode ON Org.tbOrg.TaxCode = App.tbTaxCode.TaxCode AND Org.tbOrg.TaxCode = App.tbTaxCode.TaxCode
				WHERE (Task.tbTask.TaskCode = @TaskCode)
				END
			ELSE
				BEGIN
				UPDATE Task.tbTask
				SET TaxCode = Cash.tbCode.TaxCode
				FROM  Task.tbTask 
					INNER JOIN Cash.tbCode ON Task.tbTask.CashCode = Cash.tbCode.CashCode
				WHERE  (Task.tbTask.TaskCode = @TaskCode)
				END			
			
			SELECT @DefaultAccountCode = (SELECT TOP 1  AccountCode FROM Task.tbTask
											WHERE   (ActivityCode = (SELECT ActivityCode FROM  Task.tbTask AS tbTask_1 WHERE (TaskCode = @TaskCode))) AND (TaskCode <> @TaskCode))

			IF NOT @DefaultAccountCode IS NULL
				BEGIN
				UPDATE Task.tbTask
				SET AccountCode = @DefaultAccountCode
				WHERE (TaskCode = @TaskCode)
				END
					
			INSERT INTO Task.tbFlow
				(ParentTaskCode, StepNumber, ChildTaskCode, SyncTypeCode, UsedOnQuantity, OffsetDays)
			SELECT Task.tbTask.TaskCode, Activity.tbFlow.StepNumber, @TaskCode AS ChildTaskCode, Activity.tbFlow.SyncTypeCode, Activity.tbFlow.UsedOnQuantity, Activity.tbFlow.OffsetDays
			FROM Activity.tbFlow 
				INNER JOIN Task.tbTask ON Activity.tbFlow.ParentCode = Task.tbTask.ActivityCode
			WHERE (Task.tbTask.TaskCode = @ParentTaskCode) AND ( Activity.tbFlow.StepNumber = @StepNumber)
		
			EXEC Task.proc_Configure @TaskCode

			FETCH NEXT FROM curAct INTO @StepNumber
			END
	
		CLOSE curAct
		DEALLOCATE curAct
		
		IF @@NESTLEVEL = 1
			COMMIT TRANSACTION

  	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
go
ALTER VIEW Usr.vwDoc
AS
	WITH bank AS 
	(
		SELECT        TOP (1) (SELECT AccountCode FROM App.tbOptions) AS AccountCode, CONCAT(Org.tbOrg.AccountName, SPACE(1), Org.tbAccount.CashAccountName) AS BankAccount, Org.tbAccount.SortCode AS BankSortCode, 
															  Org.tbAccount.AccountNumber AS BankAccountNumber
									 FROM            Org.tbAccount INNER JOIN
															  Org.tbOrg ON Org.tbAccount.AccountCode = Org.tbOrg.AccountCode
									 WHERE        (NOT (Org.tbAccount.CashCode IS NULL))
	)
    SELECT        TOP (1) company.AccountName AS CompanyName, Org.tbAddress.Address AS CompanyAddress, company.PhoneNumber AS CompanyPhoneNumber,  
                              company.EmailAddress AS CompanyEmailAddress, company.WebSite AS CompanyWebsite, company.CompanyNumber, company.VatNumber, company.Logo, bank_details.BankAccount, 
                              bank_details.BankAccountNumber, bank_details.BankSortCode
     FROM            Org.tbOrg AS company INNER JOIN
                              App.tbOptions ON company.AccountCode = App.tbOptions.AccountCode LEFT OUTER JOIN
                              bank AS bank_details ON company.AccountCode = bank_details.AccountCode LEFT OUTER JOIN
                              Org.tbAddress ON company.AddressCode = Org.tbAddress.AddressCode;
go
ALTER VIEW Org.vwContacts
AS
	WITH ContactCount AS (SELECT        ContactName, COUNT(TaskCode) AS Tasks
                                                   FROM            Task.tbTask
                                                   WHERE        (TaskStatusCode < 2)
                                                   GROUP BY ContactName
                                                   HAVING         (ContactName IS NOT NULL))
    SELECT TOP (100) PERCENT   Org.tbContact.ContactName, Org.tbOrg.AccountCode, ContactCount_1.Tasks, Org.tbContact.PhoneNumber, Org.tbContact.HomeNumber, Org.tbContact.MobileNumber,  
                              Org.tbContact.EmailAddress, Org.tbOrg.AccountName, Org.tbType.OrganisationType, Org.tbStatus.OrganisationStatus, Org.tbContact.NameTitle, Org.tbContact.NickName, Org.tbContact.JobTitle, 
                              Org.tbContact.Department
     FROM            Org.tbOrg INNER JOIN
                              Org.tbType ON Org.tbOrg.OrganisationTypeCode = Org.tbType.OrganisationTypeCode INNER JOIN
                              Org.tbStatus ON Org.tbOrg.OrganisationStatusCode = Org.tbStatus.OrganisationStatusCode INNER JOIN
                              Org.tbContact ON Org.tbOrg.AccountCode = Org.tbContact.AccountCode LEFT OUTER JOIN
                              ContactCount AS ContactCount_1 ON Org.tbContact.ContactName = ContactCount_1.ContactName
     WHERE        (Org.tbOrg.OrganisationStatusCode < 3)
     ORDER BY Org.tbContact.ContactName;
go
ALTER VIEW Org.vwCompanyHeader
AS
SELECT        TOP (1) Org.tbOrg.AccountName AS CompanyName, Org.tbAddress.Address AS CompanyAddress, Org.tbOrg.PhoneNumber AS CompanyPhoneNumber, 
                         Org.tbOrg.EmailAddress AS CompanyEmailAddress, Org.tbOrg.WebSite AS CompanyWebsite, Org.tbOrg.CompanyNumber, Org.tbOrg.VatNumber
FROM            Org.tbOrg INNER JOIN
                         App.tbOptions ON Org.tbOrg.AccountCode = App.tbOptions.AccountCode LEFT OUTER JOIN
                         Org.tbAddress ON Org.tbOrg.AddressCode = Org.tbAddress.AddressCode;
go
ALTER VIEW App.vwIdentity
AS
SELECT TOP (1) Org.tbOrg.AccountName, Org.tbAddress.Address, Org.tbOrg.PhoneNumber, Org.tbOrg.EmailAddress, Org.tbOrg.WebSite, Org.tbOrg.Logo, Usr.tbUser.UserName, Usr.tbUser.LogonName, 
                         Usr.tbUser.Avatar, Org.tbOrg.CompanyNumber, Org.tbOrg.VatNumber
FROM            Org.tbOrg INNER JOIN
                         Org.tbAddress ON Org.tbOrg.AddressCode = Org.tbAddress.AddressCode INNER JOIN
                         App.tbOptions ON Org.tbOrg.AccountCode = App.tbOptions.AccountCode CROSS JOIN
                         Usr.vwCredentials INNER JOIN
                         Usr.tbUser ON Usr.vwCredentials.UserId = Usr.tbUser.UserId;
go
ALTER VIEW Org.vwStatusReport
AS
SELECT        Org.vwDatasheet.AccountCode, Org.vwDatasheet.AccountName, Org.vwDatasheet.OrganisationType, Org.vwDatasheet.OrganisationStatus, Org.vwDatasheet.TaxDescription, Org.vwDatasheet.Address, 
                         Org.vwDatasheet.AreaCode, Org.vwDatasheet.PhoneNumber, Org.vwDatasheet.EmailAddress, Org.vwDatasheet.WebSite, Org.vwDatasheet.IndustrySector, 
                         Org.vwDatasheet.AccountSource, Org.vwDatasheet.PaymentTerms, Org.vwDatasheet.PaymentDays, Org.vwDatasheet.ExpectedDays, Org.vwDatasheet.NumberOfEmployees, Org.vwDatasheet.CompanyNumber, Org.vwDatasheet.VatNumber, 
                         Org.vwDatasheet.Turnover, Org.vwDatasheet.OpeningBalance, Org.vwDatasheet.EUJurisdiction, Org.vwDatasheet.BusinessDescription, 
                         Org.tbPayment.PaymentCode, Usr.tbUser.UserName, App.tbTaxCode.TaxDescription AS PaymentTaxDescription, Org.tbAccount.CashAccountName, Cash.tbCode.CashDescription, Org.tbPayment.UserId, 
                         Org.tbPayment.CashAccountCode, Org.tbPayment.CashCode, Org.tbPayment.TaxCode, Org.tbPayment.PaidOn, Org.tbPayment.PaidInValue, Org.tbPayment.PaidOutValue, Org.tbPayment.TaxInValue, 
                         Org.tbPayment.TaxOutValue, Org.tbPayment.InsertedBy, Org.tbPayment.InsertedOn, Org.tbPayment.UpdatedBy, Org.tbPayment.UpdatedOn, Org.tbPayment.PaymentReference
FROM            Org.tbPayment INNER JOIN
                         Usr.tbUser ON Org.tbPayment.UserId = Usr.tbUser.UserId INNER JOIN
                         Org.tbAccount ON Org.tbPayment.CashAccountCode = Org.tbAccount.CashAccountCode INNER JOIN
                         Cash.tbCode ON Org.tbPayment.CashCode = Cash.tbCode.CashCode LEFT OUTER JOIN
                         App.tbTaxCode ON Org.tbPayment.TaxCode = App.tbTaxCode.TaxCode INNER JOIN
                         Org.vwDatasheet ON Org.tbPayment.AccountCode = Org.vwDatasheet.AccountCode
WHERE        (Org.tbPayment.PaymentStatusCode = 1);
go
ALTER VIEW Org.vwDatasheet
AS
	With task_count AS
	(
		SELECT        AccountCode, COUNT(TaskCode) AS TaskCount
		FROM            Task.tbTask
		WHERE        (TaskStatusCode = 1)
		GROUP BY AccountCode
	)
	SELECT        o.AccountCode, o.AccountName, ISNULL(task_count.TaskCount, 0) AS Tasks, o.OrganisationTypeCode, Org.tbType.OrganisationType, Org.tbType.CashModeCode, o.OrganisationStatusCode, 
							 Org.tbStatus.OrganisationStatus, Org.tbAddress.Address, App.tbTaxCode.TaxDescription, o.TaxCode, o.AddressCode, o.AreaCode, o.PhoneNumber, o.EmailAddress, o.WebSite,
								 (SELECT        TOP (1) IndustrySector
								   FROM            Org.tbSector AS sector
								   WHERE        (AccountCode = o.AccountCode)) AS IndustrySector, o.AccountSource, o.PaymentTerms, o.PaymentDays, o.ExpectedDays, o.PayDaysFromMonthEnd, o.PayBalance, o.NumberOfEmployees, o.CompanyNumber, o.VatNumber, o.Turnover, 
							 o.OpeningBalance, o.EUJurisdiction, o.BusinessDescription, o.InsertedBy, o.InsertedOn, o.UpdatedBy, o.UpdatedOn 
	FROM            Org.tbOrg AS o INNER JOIN
							 Org.tbStatus ON o.OrganisationStatusCode = Org.tbStatus.OrganisationStatusCode INNER JOIN
							 Org.tbType ON o.OrganisationTypeCode = Org.tbType.OrganisationTypeCode LEFT OUTER JOIN
							 App.tbTaxCode ON o.TaxCode = App.tbTaxCode.TaxCode LEFT OUTER JOIN
							 Org.tbAddress ON o.AddressCode = Org.tbAddress.AddressCode LEFT OUTER JOIN
							 task_count ON o.AccountCode = task_count.AccountCode
go
ALTER TABLE Usr.tbUser DROP COLUMN FaxNumber;
go
ALTER TABLE Org.tbOrg DROP COLUMN FaxNumber;
go
ALTER TABLE Org.tbContact DROP COLUMN FaxNumber;
go

