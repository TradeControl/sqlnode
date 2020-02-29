/**************************************************************************************
Trade Control
Sample upgrade script
Release: 3.25.1

Date: 29 February 2020
Author: Ian Monnox

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
CREATE TABLE Org.tbTransmitStatus (
	TransmitStatusCode smallint NOT NULL,
	TransmitStatus nvarchar(20) NOT NULL,
	CONSTRAINT PK_App_tbTransmitStatus PRIMARY KEY CLUSTERED (TransmitStatusCode)
) ON [PRIMARY]
go
INSERT INTO Org.tbTransmitStatus (TransmitStatusCode, TransmitStatus)
VALUES (0, 'Disconnected'), (1, 'Deploy'), (2, 'Update'), (3, 'Processed');
go
ALTER TABLE Org.tbOrg WITH NOCHECK ADD
	TransmitStatusCode smallint NOT NULL CONSTRAINT DF_Org_tbOrg_TransmitStatusCode DEFAULT (0),
	CONSTRAINT FK_Org_tbOrg_tbTransmitStatus FOREIGN KEY (TransmitStatusCode) REFERENCES Org.tbTransmitStatus (TransmitStatusCode)
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
							 Org.tbStatus.OrganisationStatus, Org.tbTransmitStatus.TransmitStatus, Org.tbAddress.Address, App.tbTaxCode.TaxDescription, o.TaxCode, o.AddressCode, o.AreaCode, o.PhoneNumber, o.EmailAddress, o.WebSite,
								 (SELECT        TOP (1) IndustrySector
								   FROM            Org.tbSector AS sector
								   WHERE        (AccountCode = o.AccountCode)) AS IndustrySector, o.AccountSource, o.PaymentTerms, o.PaymentDays, o.ExpectedDays, o.PayDaysFromMonthEnd, o.PayBalance, o.NumberOfEmployees, o.CompanyNumber, o.VatNumber, o.Turnover, 
							 o.OpeningBalance, o.EUJurisdiction, o.BusinessDescription, o.InsertedBy, o.InsertedOn, o.UpdatedBy, o.UpdatedOn 
	FROM            Org.tbOrg AS o 
		JOIN Org.tbStatus ON o.OrganisationStatusCode = Org.tbStatus.OrganisationStatusCode 
		JOIN Org.tbType ON o.OrganisationTypeCode = Org.tbType.OrganisationTypeCode 
		JOIN Org.tbTransmitStatus ON o.TransmitStatusCode = Org.tbTransmitStatus.TransmitStatusCode
		LEFT OUTER JOIN App.tbTaxCode ON o.TaxCode = App.tbTaxCode.TaxCode 
		LEFT OUTER JOIN Org.tbAddress ON o.AddressCode = Org.tbAddress.AddressCode 
		LEFT OUTER JOIN task_count ON o.AccountCode = task_count.AccountCode

go
CREATE TABLE Task.tbChangeLog (
	LogId int IDENTITY(1,1) NOT NULL,
	TaskCode nvarchar(20) NOT NULL,
	ChangedOn datetime NOT NULL CONSTRAINT DF_Task_tbChangeLog_ChangedOn DEFAULT (DATEADD(MILLISECOND, DATEPART(MILLISECOND, CURRENT_TIMESTAMP) * -1, CURRENT_TIMESTAMP)),
	TransmitStatusCode smallint NOT NULL CONSTRAINT DF_Task_tbChangeLog_TransmissionStatusCode DEFAULT (0),
	AccountCode nvarchar(10) NOT NULL,
	ActivityCode nvarchar(50) NOT NULL,
	TaskStatusCode smallint NOT NULL,
	ActionOn datetime NOT NULL,
	Quantity float NOT NULL,
	CashCode nvarchar(50) NULL,
	TaxCode nvarchar(10) NULL,
	UnitCharge float NOT NULL,
	UpdatedBy nvarchar(50) NOT NULL CONSTRAINT DF_Task_tbChangeLog_UpdatedBy DEFAULT (SUSER_SNAME()),
	RowVer timestamp NOT NULL,
	CONSTRAINT PK_Task_tbChangeLog PRIMARY KEY CLUSTERED (LogId DESC),
	--CONSTRAINT FK_Task_tbChangeLog_tbTask FOREIGN KEY(TaskCode) REFERENCES Task.tbTask (TaskCode),
	CONSTRAINT FK_Task_tbChangeLog_TrasmitStatusCode FOREIGN KEY (TransmitStatusCode) REFERENCES Org.tbTransmitStatus (TransmitStatusCode)
) ON [PRIMARY];
go
CREATE NONCLUSTERED INDEX IX_Task_tbChangeLog_TaskCode ON Task.tbChangeLog (TaskCode, LogId DESC) ON [PRIMARY];
CREATE NONCLUSTERED INDEX IX_Task_tbChangeLog_ChangedOn ON Task.tbChangeLog (ChangedOn DESC) ON [PRIMARY];
CREATE NONCLUSTERED INDEX IX_Task_tbChangeLog_TransmitStatus ON Task.tbChangeLog (TransmitStatusCode, ChangedOn) ON [PRIMARY];
go
CREATE OR ALTER VIEW Task.vwChangeLog AS
	SELECT    Task.tbChangeLog.LogId, Task.tbChangeLog.TaskCode, Task.tbChangeLog.ChangedOn, Org.tbTransmitStatus.TransmitStatusCode, Org.tbTransmitStatus.TransmitStatus, Org.tbOrg.AccountCode, Org.tbOrg.AccountName, 
			Task.tbChangeLog.ActivityCode, Task.tbStatus.TaskStatus, Task.tbChangeLog.ActionOn, 
			Task.tbChangeLog.Quantity, Task.tbChangeLog.CashCode, Cash.tbCode.CashDescription, Task.tbChangeLog.UnitCharge, Task.tbChangeLog.UnitCharge * Task.tbChangeLog.Quantity TotalCharge, 
			Task.tbChangeLog.TaxCode, App.tbTaxCode.TaxRate, Task.tbChangeLog.UpdatedBy
	FROM            Task.tbChangeLog INNER JOIN
							 Org.tbTransmitStatus ON Task.tbChangeLog.TransmitStatusCode = Org.tbTransmitStatus.TransmitStatusCode INNER JOIN
							 Org.tbOrg ON Task.tbChangeLog.AccountCode = Org.tbOrg.AccountCode INNER JOIN
							 Task.tbStatus ON Task.tbChangeLog.TaskStatusCode = Task.tbStatus.TaskStatusCode INNER JOIN
							 App.tbTaxCode ON Task.tbChangeLog.TaxCode = App.tbTaxCode.TaxCode INNER JOIN
							 Cash.tbCode ON Task.tbChangeLog.CashCode = Cash.tbCode.CashCode;
go
ALTER TRIGGER Task.Task_tbTask_TriggerInsert
ON Task.tbTask
FOR INSERT
AS
	SET NOCOUNT ON;
	BEGIN TRY

	    UPDATE task
	    SET task.ActionOn = CAST(task.ActionOn AS DATE)
	    FROM Task.tbTask task JOIN inserted i ON task.TaskCode = i.TaskCode
	    WHERE DATEDIFF(SECOND, CAST(i.ActionOn AS DATE), i.ActionOn) <> 0;

	    UPDATE task
	    SET task.TotalCharge = i.UnitCharge * i.Quantity
	    FROM Task.tbTask task JOIN inserted i ON task.TaskCode = i.TaskCode
	    WHERE i.TotalCharge = 0 

	    UPDATE task
	    SET task.UnitCharge = i.TotalCharge / i.Quantity
	    FROM Task.tbTask task JOIN inserted i ON task.TaskCode = i.TaskCode
	    WHERE i.UnitCharge = 0 AND i.Quantity > 0;

	    UPDATE task
	    SET PaymentOn = App.fnAdjustToCalendar(
            CASE WHEN org.PayDaysFromMonthEnd <> 0 THEN 
                    DATEADD(d, -1, DATEADD(m, 1, CONCAT(FORMAT(DATEADD(d, org.PaymentDays + org.ExpectedDays, task.ActionOn), 'yyyyMM'), '01')))												
                ELSE 
                    DATEADD(d, org.PaymentDays + org.ExpectedDays, task.ActionOn) END, 0) 
	    FROM Task.tbTask task
		    JOIN Org.tbOrg org ON task.AccountCode = org.AccountCode
		    JOIN inserted i ON task.TaskCode = i.TaskCode
	    WHERE NOT task.CashCode IS NULL 

	    INSERT INTO Org.tbContact (AccountCode, ContactName)
	    SELECT DISTINCT AccountCode, ContactName 
	    FROM inserted
	    WHERE EXISTS (SELECT ContactName FROM inserted AS i WHERE (NOT (ContactName IS NULL)) AND (ContactName <> N''))
                AND NOT EXISTS(SELECT Org.tbContact.ContactName FROM inserted AS i INNER JOIN Org.tbContact ON i.AccountCode = Org.tbContact.AccountCode AND i.ContactName = Org.tbContact.ContactName)

		INSERT INTO Task.tbChangeLog
								 (TaskCode, TransmitStatusCode, AccountCode, ActivityCode, TaskStatusCode, ActionOn, Quantity, CashCode, TaxCode, UnitCharge)
		SELECT inserted.TaskCode, Org.tbOrg.TransmitStatusCode, inserted.AccountCode, inserted.ActivityCode, inserted.TaskStatusCode, 
								 inserted.ActionOn, inserted.Quantity, inserted.CashCode, inserted.TaxCode, inserted.UnitCharge
		FROM inserted 
			JOIN Org.tbOrg ON inserted.AccountCode = Org.tbOrg.AccountCode
			JOIN Cash.tbCode ON inserted.CashCode = Cash.tbCode.CashCode
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
		EXEC App.proc_ErrorLog;
		THROW;
	END CATCH
go
ALTER TRIGGER Task.Task_tbTask_TriggerUpdate
ON Task.tbTask
FOR UPDATE
AS
	SET NOCOUNT ON;

	BEGIN TRY

		UPDATE task
		SET task.ActionOn = CAST(task.ActionOn AS DATE)
		FROM Task.tbTask task JOIN inserted i ON task.TaskCode = i.TaskCode
		WHERE DATEDIFF(SECOND, CAST(i.ActionOn AS DATE), i.ActionOn) <> 0;

		IF UPDATE(TaskStatusCode)
			BEGIN
			UPDATE ops
			SET OpStatusCode = 2
			FROM inserted JOIN Task.tbOp ops ON inserted.TaskCode = ops.TaskCode
			WHERE TaskStatusCode > 1 AND OpStatusCode < 2;

			WITH first_ops AS
			(
				SELECT ops.TaskCode, MIN(ops.OperationNumber) AS OperationNumber
				FROM inserted i JOIN Task.tbOp ops ON i.TaskCode = ops.TaskCode 
				WHERE i.TaskStatusCode = 1		
				GROUP BY ops.TaskCode		
			), next_ops AS
			(
				SELECT ops.TaskCode, ops.OperationNumber, ops.SyncTypeCode,
					LEAD(ops.OperationNumber) OVER (PARTITION BY ops.TaskCode ORDER BY ops.OperationNumber) AS NextOpNo
				FROM inserted i JOIN Task.tbOp ops ON i.TaskCode = ops.TaskCode 
			), async_ops AS
			(
				SELECT first_ops.TaskCode, first_ops.OperationNumber, next_ops.NextOpNo
				FROM first_ops JOIN next_ops ON first_ops.TaskCode = next_ops.TaskCode AND first_ops.OperationNumber = next_ops.OperationNumber

				UNION ALL

				SELECT next_ops.TaskCode, next_ops.OperationNumber, next_ops.NextOpNo
				FROM next_ops JOIN async_ops ON next_ops.TaskCode = async_ops.TaskCode AND next_ops.OperationNumber = async_ops.NextOpNo
				WHERE next_ops.SyncTypeCode = 1

			)
			UPDATE ops
			SET OpStatusCode = 1
			FROM async_ops JOIN Task.tbOp ops ON async_ops.TaskCode = ops.TaskCode
				AND async_ops.OperationNumber = ops.OperationNumber;
			
			WITH cascade_status AS
			(
				SELECT TaskCode, TaskStatusCode
				FROM Task.tbTask inserted
				WHERE NOT CashCode IS NULL AND TaskStatusCode > 1
			), task_flow AS
			(
				SELECT cascade_status.TaskStatusCode ParentStatusCode, child.ParentTaskCode, child.ChildTaskCode, child_task.TaskStatusCode
				FROM Task.tbFlow child 
					JOIN cascade_status ON child.ParentTaskCode = cascade_status.TaskCode
					JOIN Task.tbTask child_task ON child.ChildTaskCode = child_task.TaskCode
				WHERE CashCode IS NULL

				UNION ALL

				SELECT parent.ParentStatusCode, child.ParentTaskCode, child.ChildTaskCode, child_task.TaskStatusCode
				FROM Task.tbFlow child 
					JOIN task_flow parent ON child.ParentTaskCode = parent.ChildTaskCode
					JOIN Task.tbTask child_task ON child.ChildTaskCode = child_task.TaskCode
				WHERE CashCode IS NULL
			)
			UPDATE task
			SET TaskStatusCode = CASE task_flow.ParentStatusCode WHEN 3 THEN 2 ELSE task_flow.ParentStatusCode END
			FROM Task.tbTask task JOIN task_flow ON task_flow.ChildTaskCode = task.TaskCode
			WHERE task.TaskStatusCode < 2;

			--not triggering fix
			WITH cascade_status AS
			(
				SELECT TaskCode, TaskStatusCode
				FROM Task.tbTask inserted
				WHERE NOT CashCode IS NULL AND TaskStatusCode > 1
			), task_flow AS
			(
				SELECT cascade_status.TaskStatusCode ParentStatusCode, child.ParentTaskCode, child.ChildTaskCode, child_task.TaskStatusCode
				FROM Task.tbFlow child 
					JOIN cascade_status ON child.ParentTaskCode = cascade_status.TaskCode
					JOIN Task.tbTask child_task ON child.ChildTaskCode = child_task.TaskCode
				WHERE CashCode IS NULL

				UNION ALL

				SELECT parent.ParentStatusCode, child.ParentTaskCode, child.ChildTaskCode, child_task.TaskStatusCode
				FROM Task.tbFlow child 
					JOIN task_flow parent ON child.ParentTaskCode = parent.ChildTaskCode
					JOIN Task.tbTask child_task ON child.ChildTaskCode = child_task.TaskCode
				WHERE CashCode IS NULL
			)
			UPDATE ops
			SET OpStatusCode = 2
			FROM Task.tbOp ops JOIN task_flow ON task_flow.ChildTaskCode = ops.TaskCode
			WHERE ops.OpStatusCode < 2;

			END

		IF UPDATE(Quantity)
			BEGIN
			UPDATE flow
			SET UsedOnQuantity = inserted.Quantity / parent_task.Quantity
			FROM Task.tbFlow AS flow 
				JOIN inserted ON flow.ChildTaskCode = inserted.TaskCode 
				JOIN Task.tbTask AS parent_task ON flow.ParentTaskCode = parent_task.TaskCode
				JOIN Cash.tbCode ON parent_task.CashCode = Cash.tbCode.CashCode
			WHERE (flow.UsedOnQuantity <> 0) AND (inserted.Quantity <> 0) 
				AND (inserted.Quantity / parent_task.Quantity <> flow.UsedOnQuantity)
			END

		IF UPDATE(Quantity) OR UPDATE(UnitCharge)
			BEGIN
			UPDATE task
			SET task.TotalCharge = i.Quantity * i.UnitCharge
			FROM Task.tbTask task JOIN inserted i ON task.TaskCode = i.TaskCode
			END

		IF UPDATE(TotalCharge)
			BEGIN
			UPDATE task
			SET task.UnitCharge = CASE i.TotalCharge + i.Quantity WHEN 0 THEN 0 ELSE i.TotalCharge / i.Quantity END
			FROM Task.tbTask task JOIN inserted i ON task.TaskCode = i.TaskCode			
			END

		IF UPDATE(ActionOn)
			BEGIN			
			WITH parent_task AS
			(
				SELECT        ParentTaskCode
				FROM            Task.tbFlow flow
					JOIN Task.tbTask task ON flow.ParentTaskCode = task.TaskCode
					JOIN Cash.tbCode cash ON task.CashCode = cash.CashCode
					JOIN inserted ON flow.ChildTaskCode = inserted.TaskCode
				--manual scheduling only
				WHERE (SELECT SUM(UsedOnQuantity) FROM inserted JOIN Task.tbFlow ON inserted.TaskCode = Task.tbFlow.ChildTaskCode) = 0	
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
			
			IF EXISTS(SELECT * FROM App.tbOptions WHERE IsAutoOffsetDays <> 0)
			BEGIN
				UPDATE flow
				SET OffsetDays = App.fnOffsetDays(inserted.ActionOn, parent_task.ActionOn)
									- ISNULL((SELECT SUM(OffsetDays) FROM Task.tbFlow sub_flow WHERE sub_flow.ParentTaskCode = flow.ParentTaskCode AND sub_flow.StepNumber > flow.StepNumber), 0)
				FROM Task.tbFlow AS flow 
					JOIN inserted ON flow.ChildTaskCode = inserted.TaskCode 
					JOIN Task.tbTask AS parent_task ON flow.ParentTaskCode = parent_task.TaskCode
					JOIN Cash.tbCode ON parent_task.CashCode = Cash.tbCode.CashCode
				WHERE (SELECT SUM(UsedOnQuantity) FROM inserted JOIN Task.tbFlow ON inserted.TaskCode = Task.tbFlow.ChildTaskCode) = 0
			END

			UPDATE task
			SET PaymentOn = App.fnAdjustToCalendar(CASE WHEN org.PayDaysFromMonthEnd <> 0 
													THEN 
														DATEADD(d, -1, DATEADD(m, 1, CONCAT(FORMAT(DATEADD(d, org.PaymentDays + org.ExpectedDays, i.ActionOn), 'yyyyMM'), '01')))												
													ELSE
														DATEADD(d, org.PaymentDays + org.ExpectedDays, i.ActionOn)	
													END, 0) 
			FROM Task.tbTask task
				JOIN inserted i ON task.TaskCode = i.TaskCode
				JOIN Org.tbOrg org ON i.AccountCode = org.AccountCode				
			WHERE NOT task.CashCode IS NULL 
			END

		IF UPDATE (TaskTitle)
		BEGIN
			WITH cascade_title_change AS
			(
				SELECT inserted.TaskCode, inserted.TaskTitle AS TaskTitle, deleted.TaskTitle AS PreviousTitle 				
				FROM inserted
					JOIN deleted ON inserted.TaskCode = deleted.TaskCode
			), task_flow AS
			(
				SELECT cascade_title_change.TaskTitle AS ProjectTitle, cascade_title_change.PreviousTitle, child.ParentTaskCode, child.ChildTaskCode, child_task.TaskTitle
				FROM Task.tbFlow child 
					JOIN cascade_title_change ON child.ParentTaskCode = cascade_title_change.TaskCode
					JOIN Task.tbTask child_task ON child.ChildTaskCode = child_task.TaskCode

				UNION ALL

				SELECT parent.ProjectTitle, parent.PreviousTitle, child.ParentTaskCode, child.ChildTaskCode, child_task.TaskTitle
				FROM Task.tbFlow child 
					JOIN task_flow parent ON child.ParentTaskCode = parent.ChildTaskCode
					JOIN Task.tbTask child_task ON child.ChildTaskCode = child_task.TaskCode
			)
			UPDATE task
			SET TaskTitle = ProjectTitle
			FROM Task.tbTask task JOIN task_flow ON task.TaskCode = task_flow.ChildTaskCode
			WHERE task_flow.PreviousTitle = task_flow.TaskTitle;
		END

		IF UPDATE (Spooled)
		BEGIN
			INSERT INTO App.tbDocSpool (DocTypeCode, DocumentNumber)
			SELECT CASE 
					WHEN CashModeCode = 0 THEN		--Expense
						CASE WHEN TaskStatusCode = 0 THEN 2	ELSE 3 END	--Enquiry								
					WHEN CashModeCode = 1 THEN		--Income
						CASE WHEN TaskStatusCode = 0 THEN 0	ELSE 1 END	--Quote
					END AS DocTypeCode, task.TaskCode
			FROM   inserted task INNER JOIN
									 Cash.tbCode ON task.CashCode = Cash.tbCode.CashCode INNER JOIN
									 Cash.tbCategory ON Cash.tbCode.CategoryCode = Cash.tbCategory.CategoryCode
			WHERE (task.Spooled <> 0)
				
			DELETE App.tbDocSpool
			FROM         inserted i INNER JOIN
								  App.tbDocSpool ON i.TaskCode = App.tbDocSpool.DocumentNumber
			WHERE    (i.Spooled = 0) AND ( App.tbDocSpool.DocTypeCode <= 3)
		END

		IF UPDATE (ContactName)
		BEGIN
			INSERT INTO Org.tbContact (AccountCode, ContactName)
			SELECT DISTINCT AccountCode, ContactName FROM inserted
			WHERE EXISTS (SELECT     *
						FROM         inserted AS i
						WHERE     (NOT (ContactName IS NULL)) AND
												(ContactName <> N''))
				AND NOT EXISTS(SELECT  *
								FROM         inserted AS i INNER JOIN
													Org.tbContact ON i.AccountCode = Org.tbContact.AccountCode AND i.ContactName = Org.tbContact.ContactName)
		END
		
		UPDATE Task.tbTask
		SET UpdatedBy = SUSER_SNAME(), UpdatedOn = CURRENT_TIMESTAMP
		FROM Task.tbTask INNER JOIN inserted AS i ON tbTask.TaskCode = i.TaskCode;

		IF UPDATE(TaskStatusCode) OR UPDATE(Quantity) OR UPDATE(ActionOn) OR UPDATE(UnitCharge) OR UPDATE(ActivityCode) OR UPDATE(CashCode) OR UPDATE (TaxCode)
		BEGIN
			WITH candidates AS
			(
				SELECT TaskCode, AccountCode, ActivityCode, TaskStatusCode, ActionOn, Quantity, CashCode, TaxCode, UnitCharge
				FROM inserted
				WHERE EXISTS (SELECT * FROM Task.tbChangeLog WHERE TaskCode = inserted.TaskCode)
			)
			, logs AS
			(
				SELECT clog.LogId, clog.TaskCode, clog.AccountCode, clog.ActivityCode, clog.TaskStatusCode, clog.TransmitStatusCode, clog.ActionOn, clog.Quantity, clog.CashCode, clog.TaxCode, clog.UnitCharge
				FROM Task.tbChangeLog clog
				JOIN candidates ON clog.TaskCode = candidates.TaskCode AND LogId = (SELECT MAX(LogId) FROM Task.tbChangeLog WHERE TaskCode = candidates.TaskCode)		
			)
			INSERT INTO Task.tbChangeLog
									(TaskCode, TransmitStatusCode, AccountCode, ActivityCode, TaskStatusCode, ActionOn, Quantity, CashCode, TaxCode, UnitCharge)
			SELECT candidates.TaskCode, CASE orgs.TransmitStatusCode WHEN 1 THEN 2 ELSE 0 END TransmitStatusCode, candidates.AccountCode,
				candidates.ActivityCode, candidates.TaskStatusCode, candidates.ActionOn, candidates.Quantity, candidates.CashCode, candidates.TaxCode, candidates.UnitCharge
			FROM candidates 
				JOIN Org.tbOrg orgs ON candidates.AccountCode = orgs.AccountCode 
				JOIN logs ON candidates.TaskCode = logs.TaskCode
			WHERE (logs.TaskStatusCode <> candidates.TaskStatusCode) 
				OR (logs.TransmitStatusCode < 2)
				OR (logs.ActionOn <> candidates.ActionOn) 
				OR (logs.Quantity <> candidates.Quantity)
				OR (logs.UnitCharge <> candidates.UnitCharge)
				OR (logs.TaxCode <> candidates.TaxCode);
		END

	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
go
CREATE OR ALTER TRIGGER Task.Task_tbTask_TriggerDelete
ON Task.tbTask
FOR DELETE
AS
	SET NOCOUNT ON;

	BEGIN TRY
		INSERT INTO Task.tbChangeLog
								 (TaskCode, TransmitStatusCode, AccountCode, ActivityCode, TaskStatusCode, ActionOn, Quantity, CashCode, TaxCode, UnitCharge)
		SELECT deleted.TaskCode, CASE Org.tbOrg.TransmitStatusCode WHEN 1 THEN 2 ELSE 0 END TransmitStatusCode, 
					deleted.AccountCode, deleted.ActivityCode, 4 CancelledStatusCode, 
					deleted.ActionOn, deleted.Quantity, deleted.CashCode, deleted.TaxCode, deleted.UnitCharge
		FROM deleted INNER JOIN Org.tbOrg ON deleted.AccountCode = Org.tbOrg.AccountCode;
	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
go
CREATE TABLE Invoice.tbChangeLog (
	LogId int IDENTITY(1,1) NOT NULL,
	InvoiceNumber nvarchar(20) NOT NULL,
	ChangedOn datetime NOT NULL CONSTRAINT DF_Invoice_tbChangeLog_ChangedOn DEFAULT (DATEADD(MILLISECOND, DATEPART(MILLISECOND, CURRENT_TIMESTAMP) * -1, CURRENT_TIMESTAMP)),
	TransmitStatusCode smallint NOT NULL CONSTRAINT DF_Invoice_tbChangeLog_TransmissionStatusCode DEFAULT (0),
	InvoiceStatusCode smallint NOT NULL,
	DueOn datetime NOT NULL,
	InvoiceValue money NOT NULL CONSTRAINT DF_Invoice_tbChangeLog_InvoiceValue DEFAULT (0),
	TaxValue money NOT NULL CONSTRAINT DF_Invoice_tbChangeLogTaxValue DEFAULT (0),
	PaidValue money NOT NULL CONSTRAINT DF_Invoice_tbChangeLog_PaidValue DEFAULT (0),
	PaidTaxValue money NOT NULL CONSTRAINT DF_Invoice_tbChangeLog_PaidTaxValue DEFAULT (0),
	UpdatedBy nvarchar(50) NOT NULL CONSTRAINT DF_Invoice_tbChangeLog_UpdatedBy DEFAULT (SUSER_SNAME()),
	RowVer timestamp NOT NULL,
	CONSTRAINT PK_Invoice_tbChangeLog PRIMARY KEY CLUSTERED (LogId DESC),
	CONSTRAINT FK_Invoice_tbChangeLog_TrasmitStatusCode FOREIGN KEY (TransmitStatusCode) REFERENCES Org.tbTransmitStatus (TransmitStatusCode)
);
go
CREATE NONCLUSTERED INDEX IX_Invoice_tbChangeLog_InvoiceCode ON Invoice.tbChangeLog (InvoiceNumber, LogId DESC) ON [PRIMARY];
CREATE NONCLUSTERED INDEX IX_Invoice_tbChangeLog_ChangedOn ON Invoice.tbChangeLog (ChangedOn DESC) ON [PRIMARY];
CREATE NONCLUSTERED INDEX IX_Invoice_tbChangeLog_TransmitStatus ON Invoice.tbChangeLog (TransmitStatusCode, ChangedOn) ON [PRIMARY];
go
CREATE OR ALTER VIEW Invoice.vwChangeLog AS
	SELECT LogId, InvoiceNumber, ChangedOn, transmit.TransmitStatusCode, transmit.TransmitStatus, invoicestatus.InvoiceStatus, DueOn, InvoiceValue, TaxValue, PaidValue, PaidTaxValue, UpdatedBy
	FROM Invoice.tbChangeLog changelog
		JOIN Org.tbTransmitStatus transmit ON changelog.TransmitStatusCode = transmit.TransmitStatusCode
		JOIN Invoice.tbStatus invoicestatus ON changelog.InvoiceStatusCode = invoicestatus.InvoiceStatusCode;
go
CREATE OR ALTER TRIGGER Invoice.Invoice_tbInvoice_TriggerInsert
ON Invoice.tbInvoice
FOR INSERT
AS
	SET NOCOUNT ON;

	BEGIN TRY
		UPDATE invoice
		SET DueOn = App.fnAdjustToCalendar(CASE WHEN org.PayDaysFromMonthEnd <> 0 
												THEN 
													DATEADD(d, -1, DATEADD(m, 1, CONCAT(FORMAT(DATEADD(d, org.PaymentDays, i.InvoicedOn), 'yyyyMM'), '01')))												
												ELSE
													DATEADD(d, org.PaymentDays, invoice.InvoicedOn)	
												END, 0),
			ExpectedOn = App.fnAdjustToCalendar(CASE WHEN org.PayDaysFromMonthEnd <> 0 
												THEN 
													DATEADD(d, -1, DATEADD(m, 1, CONCAT(FORMAT(DATEADD(d, org.PaymentDays + org.ExpectedDays, i.InvoicedOn), 'yyyyMM'), '01')))												
												ELSE
													DATEADD(d, org.PaymentDays + org.ExpectedDays, invoice.InvoicedOn)	
												END, 0)				 
		FROM Invoice.tbInvoice invoice
			JOIN inserted i ON i.InvoiceNumber = invoice.InvoiceNumber
			JOIN Org.tbOrg org ON i.AccountCode = org.AccountCode		

		INSERT INTO Invoice.tbChangeLog
								 (InvoiceNumber, TransmitStatusCode, InvoiceStatusCode, DueOn, InvoiceValue, TaxValue)
		SELECT      inserted.InvoiceNumber, Org.tbOrg.TransmitStatusCode, inserted.InvoiceStatusCode, inserted.DueOn, inserted.InvoiceValue, inserted.TaxValue
		FROM            inserted INNER JOIN
								 Org.tbOrg ON inserted.AccountCode = Org.tbOrg.AccountCode
								 
	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
go
CREATE OR ALTER TRIGGER Invoice.Invoice_tbInvoice_TriggerUpdate
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


		IF UPDATE(InvoicedOn)
		BEGIN
			UPDATE invoice
		SET DueOn = App.fnAdjustToCalendar(CASE WHEN org.PayDaysFromMonthEnd <> 0 
												THEN 
													DATEADD(d, -1, DATEADD(m, 1, CONCAT(FORMAT(DATEADD(d, org.PaymentDays, i.InvoicedOn), 'yyyyMM'), '01')))												
												ELSE
													DATEADD(d, org.PaymentDays, invoice.InvoicedOn)	
												END, 0),
			ExpectedOn = App.fnAdjustToCalendar(CASE WHEN org.PayDaysFromMonthEnd <> 0 
												THEN 
													DATEADD(d, -1, DATEADD(m, 1, CONCAT(FORMAT(DATEADD(d, org.PaymentDays + org.ExpectedDays, i.InvoicedOn), 'yyyyMM'), '01')))												
												ELSE
													DATEADD(d, org.PaymentDays + org.ExpectedDays, invoice.InvoicedOn)	
												END, 0)		
			FROM Invoice.tbInvoice invoice
				JOIN inserted i ON i.InvoiceNumber = invoice.InvoiceNumber
				JOIN Org.tbOrg org ON i.AccountCode = org.AccountCode
		END	
		
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
IF NOT EXISTS (SELECT * FROM App.tbText WHERE TextId = 1220)
	INSERT INTO App.tbText (TextId, Message, Arguments) VALUES (1220, 'Invoices deployed to the network cannot be deleted. Add a credit/debit note instead.', 0);
go
CREATE OR ALTER TRIGGER Invoice.Invoice_tbInvoice_TriggerDelete
ON Invoice.tbInvoice
FOR DELETE
AS
	SET NOCOUNT ON;

	BEGIN TRY

		IF EXISTS (SELECT * FROM deleted INNER JOIN Org.tbOrg ON deleted.AccountCode = Org.tbOrg.AccountCode WHERE Org.tbOrg.TransmitStatusCode <> 1)
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


/*********************************************************************************/
DELETE FROM Usr.tbMenuEntry WHERE Argument = 'App_EventLog';
IF NOT EXISTS (SELECT * FROM App.tbText WHERE TextId = 1221)
	INSERT INTO App.tbText (TextId, Message, Arguments) VALUES (1221, 'Service Log cleared down.', 0);
go
CREATE OR ALTER PROCEDURE App.proc_EventLogCleardown (@RetentionDays SMALLINT = 30)
AS
	SET NOCOUNT, XACT_ABORT OFF;

	BEGIN TRY
		DECLARE 
			@EventMessage nvarchar(max) = (SELECT [Message] FROM App.tbText WHERE TextId = 1221)
			, @EventTypeCode smallint = 2
			, @LogCode nvarchar(20)

		DELETE FROM App.tbEventLog
		WHERE LoggedOn < DATEADD(DAY, @RetentionDays * -1, CAST(CURRENT_TIMESTAMP AS DATE));
		
		EXECUTE App.proc_EventLog @EventMessage, @EventTypeCode, @LogCode OUTPUT

	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
go
IF NOT EXISTS (SELECT * FROM App.tbText WHERE TextId = 1222)
	INSERT INTO App.tbText (TextId, Message, Arguments) VALUES (1222, 'Task Change Log cleared down.', 0);
go
CREATE OR ALTER PROCEDURE Task.proc_ChangeLogCleardown (@RetentionDays SMALLINT = 30)
AS
	SET NOCOUNT, XACT_ABORT OFF;

	BEGIN TRY					
		DECLARE 
			@EventMessage nvarchar(max) = (SELECT [Message] FROM App.tbText WHERE TextId = 1222)
			, @EventTypeCode smallint = 2
			, @LogCode nvarchar(20)

		DELETE FROM Task.tbChangeLog
		WHERE ChangedOn < DATEADD(DAY, @RetentionDays * -1, CAST(CURRENT_TIMESTAMP AS DATE)) 

		EXECUTE App.proc_EventLog @EventMessage, @EventTypeCode, @LogCode OUTPUT

	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
go
IF NOT EXISTS (SELECT * FROM App.tbText WHERE TextId = 1223)
	INSERT INTO App.tbText (TextId, Message, Arguments) VALUES (1223, 'Invoice Change Log cleared down.', 0);
go
CREATE OR ALTER PROCEDURE Invoice.proc_ChangeLogCleardown (@RetentionDays SMALLINT = 30)
AS
	SET NOCOUNT, XACT_ABORT OFF;

	BEGIN TRY					
		DECLARE 
			@EventMessage nvarchar(max) = (SELECT [Message] FROM App.tbText WHERE TextId = 1223)
			, @EventTypeCode smallint = 2
			, @LogCode nvarchar(20)

		DELETE FROM Invoice.tbChangeLog
		WHERE ChangedOn < DATEADD(DAY, @RetentionDays * -1, CAST(CURRENT_TIMESTAMP AS DATE)) 

		EXECUTE App.proc_EventLog @EventMessage, @EventTypeCode, @LogCode OUTPUT

	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
go
/*********************************************************************************/
DROP FUNCTION IF EXISTS Cash.fnFlowCashCodeValues;
go
ALTER PROCEDURE Cash.proc_FlowCashCodeValues(@CashCode nvarchar(50), @YearNumber smallint, @IncludeActivePeriods BIT = 0, @IncludeOrderBook BIT = 0, @IncludeTaxAccruals BIT = 0)
AS
	SET NOCOUNT, XACT_ABORT ON;

	BEGIN TRY
		DECLARE @StartOn DATE
			, @IsTaxCode BIT = 0;

		DECLARE @tbReturn AS TABLE (
			StartOn DATETIME NOT NULL, 
			CashStatusCode SMALLINT NOT NULL, 
			ForecastValue MONEY NOT NULL, 
			ForecastTax MONEY NOT NULL, 
			InvoiceValue MONEY NOT NULL, 
			InvoiceTax MONEY NOT NULL);

		INSERT INTO @tbReturn (StartOn, CashStatusCode, ForecastValue, ForecastTax, InvoiceValue, InvoiceTax)
		SELECT   Cash.tbPeriod.StartOn, App.tbYearPeriod.CashStatusCode,
			Cash.tbPeriod.ForecastValue, 
			Cash.tbPeriod.ForecastTax, 
			CASE App.tbYearPeriod.CashStatusCode WHEN 2 THEN Cash.tbPeriod.InvoiceValue ELSE 0 END AS InvoiceValue, 
			CASE App.tbYearPeriod.CashStatusCode WHEN 2 THEN Cash.tbPeriod.InvoiceTax ELSE 0 END AS InvoiceTax
		FROM            Cash.tbPeriod INNER JOIN
									App.tbYearPeriod ON Cash.tbPeriod.StartOn = App.tbYearPeriod.StartOn INNER JOIN
									App.tbYear ON App.tbYearPeriod.YearNumber = App.tbYear.YearNumber
		WHERE        (App.tbYear.CashStatusCode < 3) AND (App.tbYearPeriod.YearNumber = @YearNumber) AND (Cash.tbPeriod.CashCode = @CashCode);

	
		SELECT @StartOn = (SELECT CAST(MIN(StartOn) AS DATE) FROM @tbReturn WHERE CashStatusCode < 2);
		IF EXISTS(SELECT * FROM Cash.tbTaxType tt WHERE tt.CashCode = @CashCode) SET @IsTaxCode = 1;

		IF (@IncludeActivePeriods <> 0)
			BEGIN		
			WITH active_candidates AS
			(
				SELECT (SELECT TOP (1) StartOn FROM App.tbYearPeriod AS p WHERE (StartOn <= invoices.InvoicedOn) ORDER BY StartOn DESC) AS StartOn,
						CASE WHEN invoice_type.CashModeCode = 0 THEN tasks.InvoiceValue * - 1 ELSE tasks.InvoiceValue END AS InvoiceValue, 
						CASE WHEN invoice_type.CashModeCode = 0 THEN tasks.TaxValue * - 1 ELSE tasks.TaxValue END AS InvoiceTax
				FROM Invoice.tbInvoice invoices
					JOIN Invoice.tbType invoice_type ON invoices.InvoiceTypeCode = invoice_type.InvoiceTypeCode
					JOIN Invoice.tbTask tasks ON invoices.InvoiceNumber = tasks.InvoiceNumber
				WHERE invoices.InvoicedOn >= @StartOn
					AND tasks.CashCode = @CashCode
			), active_tasks AS
			(
				SELECT StartOn, SUM(InvoiceValue) InvoiceValue, SUM(InvoiceTax) InvoiceTax
				FROM active_candidates
				GROUP BY StartOn
			), active_items AS
			(
				SELECT (SELECT TOP (1) StartOn FROM App.tbYearPeriod AS p WHERE (StartOn <= invoices.InvoicedOn) ORDER BY StartOn DESC) AS StartOn,
						CASE WHEN invoice_type.CashModeCode = 0 THEN items.InvoiceValue * - 1 ELSE items.InvoiceValue END AS InvoiceValue, 
						CASE WHEN invoice_type.CashModeCode = 0 THEN items.TaxValue * - 1 ELSE items.TaxValue END AS InvoiceTax
				FROM Invoice.tbInvoice invoices
					JOIN Invoice.tbType invoice_type ON invoices.InvoiceTypeCode = invoice_type.InvoiceTypeCode
					JOIN Invoice.tbItem items ON invoices.InvoiceNumber = items.InvoiceNumber
				WHERE invoices.InvoicedOn >= @StartOn AND items.CashCode = @CashCode
			), active_invoices AS
			(
				SELECT StartOn, InvoiceValue, InvoiceTax FROM active_tasks
				UNION
				SELECT StartOn, InvoiceValue, InvoiceTax FROM active_items
			), active_periods AS
			(
				SELECT StartOn, SUM(InvoiceValue) AS InvoiceValue, SUM(InvoiceTax) AS InvoiceTax
				FROM active_invoices
				GROUP BY StartOn
			)
			UPDATE cashcode_values
			SET InvoiceValue += ABS(active_periods.InvoiceValue), InvoiceTax += ABS(active_periods.InvoiceTax)
			FROM @tbReturn cashcode_values JOIN active_periods ON cashcode_values.StartOn = active_periods.StartOn;

			IF @IsTaxCode <> 0
				BEGIN
				IF EXISTS (SELECT CashCode FROM Cash.tbTaxType WHERE CashCode = @CashCode AND TaxTypeCode = 0)
					BEGIN	
					WITH ct_due AS
					(
						SELECT (SELECT TOP (1) StartOn FROM App.tbYearPeriod AS p WHERE (StartOn <= ct_statement.StartOn) ORDER BY StartOn DESC) AS StartOn, TaxDue 
						FROM Cash.vwTaxCorpStatement ct_statement
						WHERE ct_statement.StartOn >= @StartOn
					)							
					UPDATE cashcode_values
					SET InvoiceValue += TaxDue
					FROM ct_due
						JOIN @tbReturn cashcode_values ON ct_due.StartOn = cashcode_values.StartOn;	
					END

				IF EXISTS (SELECT CashCode FROM Cash.tbTaxType WHERE CashCode = @CashCode AND TaxTypeCode = 1)
					BEGIN			
					WITH vat_due AS
					(
						SELECT (SELECT TOP (1) StartOn FROM App.tbYearPeriod AS p WHERE (StartOn <= vat_statement.StartOn) ORDER BY StartOn DESC) AS StartOn, VatDue 
						FROM Cash.vwTaxVatStatement vat_statement
						WHERE vat_statement.StartOn >= @StartOn
					)
					UPDATE cashcode_values
					SET InvoiceValue += VatDue
					FROM vat_due
						JOIN @tbReturn cashcode_values ON vat_due.StartOn = cashcode_values.StartOn;		
					END
				END
			END

		IF (@IncludeOrderBook <> 0)
			BEGIN
			WITH tasks AS
			(
				SELECT task.TaskCode,
						(SELECT        TOP (1) StartOn
						FROM            App.tbYearPeriod
						WHERE        (StartOn <= task.ActionOn)
						ORDER BY StartOn DESC) AS StartOn, task.TotalCharge, ISNULL(tax.TaxRate, 0) AS TaxRate
				FROM            Task.tbTask AS task INNER JOIN
											App.tbTaxCode AS tax ON task.TaxCode = tax.TaxCode
				WHERE     (task.CashCode = @CashCode) AND ((task.TaskStatusCode = 1) OR (task.TaskStatusCode = 2))
			), tasks_foryear AS
			(
				SELECT tasks.TaskCode, tasks.StartOn, tasks.TotalCharge, tasks.TaxRate
				FROM tasks
					JOIN @tbReturn invoice_history ON tasks.StartOn = invoice_history.StartOn		
			)
			, order_invoice_value AS
			(
				SELECT   invoices.TaskCode, tasks_foryear.StartOn, SUM(invoices.InvoiceValue) AS InvoiceValue, SUM(invoices.TaxValue) AS InvoiceTax
				FROM  Invoice.tbTask invoices
					JOIN tasks_foryear ON invoices.TaskCode = tasks_foryear.TaskCode 
				GROUP BY invoices.TaskCode, StartOn
			), orders AS
			(
				SELECT tasks_foryear.StartOn, 
					tasks_foryear.TotalCharge - ISNULL(order_invoice_value.InvoiceValue, 0) AS InvoiceValue,
					(tasks_foryear.TotalCharge * tasks_foryear.TaxRate) - ISNULL(order_invoice_value.InvoiceTax, 0) AS InvoiceTax
				FROM tasks_foryear LEFT OUTER JOIN order_invoice_value ON tasks_foryear.TaskCode = order_invoice_value.TaskCode
			), order_summary AS
			(
				SELECT StartOn, SUM(InvoiceValue) As InvoiceValue, SUM(InvoiceTax) As InvoiceTax
				FROM orders
				GROUP BY StartOn
			)
			UPDATE cashcode_values
			SET InvoiceValue += order_summary.InvoiceValue, InvoiceTax += order_summary.InvoiceTax
			FROM @tbReturn cashcode_values JOIN order_summary ON cashcode_values.StartOn = order_summary.StartOn;

			END
	
		IF (@IncludeTaxAccruals <> 0) AND (@IsTaxCode <> 0)
			BEGIN
			IF EXISTS (SELECT CashCode FROM Cash.tbTaxType WHERE CashCode = @CashCode AND TaxTypeCode = 0)
				BEGIN
				WITH ct_dates AS
				(
					SELECT PayOn, PayFrom, PayTo FROM Cash.fnTaxTypeDueDates(0)
				), ct_period AS
				(
					SELECT (SELECT TOP (1) StartOn FROM App.tbYearPeriod WHERE (StartOn <= PayOn) ORDER BY StartOn DESC) AS StartOn, PayOn, PayFrom, PayTo
					FROM  ct_dates 
						JOIN  App.tbYearPeriod AS year_period ON ct_dates.PayTo = year_period.StartOn 
						JOIN App.tbYear AS y ON year_period.YearNumber = y.YearNumber 
					WHERE     year_period.StartOn >= (SELECT StartOn FROM App.vwActivePeriod)
				), ct_accrual_details AS
				(		
					SELECT StartOn, SUM(TaxDue) AS TaxDue 
					FROM Cash.vwTaxCorpAccruals
					WHERE TaxDue <> 0
					GROUP BY StartOn
				), ct_accruals AS
				(
					SELECT (SELECT ct_period.StartOn FROM ct_period WHERE ct_accrual_details.StartOn >= ct_period.PayFrom AND ct_accrual_details.StartOn < ct_period.PayTo) AS StartOn, TaxDue
					FROM ct_accrual_details
				), ct_due AS
				(
					SELECT StartOn, SUM(TaxDue) AS TaxDue
					FROM ct_accruals
					GROUP BY StartOn
				)
				UPDATE cashcode_values
				SET InvoiceValue += TaxDue
				FROM ct_due
					JOIN @tbReturn cashcode_values ON ct_due.StartOn = cashcode_values.StartOn;	

				END

			IF EXISTS (SELECT CashCode FROM Cash.tbTaxType WHERE CashCode = @CashCode AND TaxTypeCode = 1)
				BEGIN
				WITH vat_dates AS
				(
					SELECT PayOn, PayFrom, PayTo FROM Cash.fnTaxTypeDueDates(1)
				), vat_period AS
				(
					SELECT (SELECT TOP (1) StartOn FROM App.tbYearPeriod WHERE (StartOn <= PayOn) ORDER BY StartOn DESC) AS StartOn, PayOn, PayFrom, PayTo
					FROM  vat_dates 
						JOIN  App.tbYearPeriod AS year_period ON vat_dates.PayTo = year_period.StartOn 
						JOIN App.tbYear AS y ON year_period.YearNumber = y.YearNumber 
					WHERE     (y.CashStatusCode = 1) OR (y.CashStatusCode = 2)
				), vat_accrual_details AS
				(		
					SELECT StartOn, SUM(VatDue) AS VatDue 
					FROM Cash.vwTaxVatAccruals
					WHERE VatDue <> 0
					GROUP BY StartOn
				), vat_accruals AS
				(
					SELECT (SELECT vat_period.StartOn FROM vat_period WHERE vat_accrual_details.StartOn >= vat_period.PayFrom AND vat_accrual_details.StartOn < vat_period.PayTo) AS StartOn, VatDue
					FROM vat_accrual_details
				), vat_due AS
				(
					SELECT StartOn, SUM(VatDue) AS VatDue
					FROM vat_accruals
					GROUP BY StartOn
				)
				UPDATE cashcode_values
				SET InvoiceValue += VatDue
				FROM vat_due
					JOIN @tbReturn cashcode_values ON vat_due.StartOn = cashcode_values.StartOn;	
				END
			END

		SELECT StartOn, InvoiceValue, InvoiceTax, ForecastValue, ForecastTax FROM @tbReturn;

	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
go