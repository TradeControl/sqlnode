/**************************************************************************************
Trade Control
Upgrade script
Release: 3.27.1

Date: 01 May 2020
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
ALTER TABLE Activity.tbActivity WITH NOCHECK ADD
	ActivityDescription NVARCHAR(100) NULL;
go
UPDATE Activity.tbActivity SET ActivityDescription = DefaultText;
go
CREATE TABLE App.tbUoc (
	UnitOfCharge nvarchar(5) NOT NULL,
	UocSymbol nvarchar(10) NOT NULL,
	UocName nvarchar(100) NOT NULL,
	CONSTRAINT PK_tbTag PRIMARY KEY CLUSTERED (
		UnitOfCharge ASC
	) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
INSERT App.tbUoc (UnitOfCharge, UocSymbol, UocName) VALUES 
	(N'AED', N'د.إ.‏', N'United Arab Emirates Dirhams')
	,(N'ALL', N'Lek', N'Albania Leke')
	,(N'AMD', N'դր.', N'Armenia Drams')
	,(N'ARS', N'$', N'Argentina Pesos')
	,(N'AUD', N'$', N'Australia Dollars')
	,(N'AZM', N'man.', N'Azerbaijan Manats')
	,(N'BGL', N'лв', N'Bulgaria')
	,(N'BHD', N'د.ب.‏', N'Bahrain Dinars')
	,(N'BND', N'$', N'Brunei Dollars')
	,(N'BOB', N'$b', N'Bolivia Bolivianos')
	,(N'BRL', N'R$ ', N'Brazil Reais')
	,(N'BTC', N'₿', N'Bitcoin')
	,(N'BYB', N'р.', N'Belarus')
	,(N'BZD', N'BZ$', N'Belize Dollars')
	,(N'CAD', N'$', N'Canada Dollars')
	,(N'CHF', N'SFr.', N'Switzerland Francs')
	,(N'CLP', N'$', N'Chile Pesos')
	,(N'CNY', N'￥', N'China Yuan Renminbi')
	,(N'COP', N'$', N'Colombia Pesos')
	,(N'CRC', N'₡', N'Costa Rica Colones')
	,(N'CZK', N'Kč', N'Czech Republic Koruny')
	,(N'DKK', N'kr', N'Denmark Kroner')
	,(N'DOP', N'RD$', N'Dominican Republic Pesos')
	,(N'DZD', N'د.ج.‏', N'Algeria Dinars')
	,(N'EEK', N'kr', N'Estonia Krooni')
	,(N'EGP', N'ج.م.‏', N'Egypt Pounds')
	,(N'EUR', N'€', N'Euro')
	,(N'GBP', N'£', N'UK Pounds')
	,(N'GEL', N'Lari', N'Georgia Lari')
	,(N'GTQ', N'Q', N'Guatemala Quetzales')
	,(N'HKD', N'HK$', N'Hong Kong Dollars')
	,(N'HNL', N'L.', N'Honduras Lempiras')
	,(N'HRK', N'kn', N'Croatia Kuna')
	,(N'HUF', N'Ft', N'Hungary Forint')
	,(N'IDR', N'Rp', N'Indonesia Rupiahs')
	,(N'ILS', N'₪', N'Israel New Shekels')
	,(N'INR', N'रु', N'India Rupees')
	,(N'IQD', N'د.ع.‏', N'Iraq Dinars')
	,(N'IRR', N'ريال', N'Iran Rials')
	,(N'ISK', N'kr.', N'Iceland Kronur')
	,(N'JMD', N'J$', N'Jamaica Dollars')
	,(N'JOD', N'د.ا.‏', N'Jordan Dinars')
	,(N'JPY', N'¥', N'Japan Yen')
	,(N'KES', N'S', N'Kenya Shillings')
	,(N'KGS', N'сом', N'Kyrgyzstan Soms')
	,(N'KRW', N'₩', N'South Korea Won')
	,(N'KWD', N'د.ك.‏', N'Kuwait Dinars')
	,(N'KZT', N'Т', N'Kazakhstan Tenge')
	,(N'LBP', N'ل.ل.‏', N'Lebanon Pounds')
	,(N'LTL', N'Lt', N'Lithuania Litai')
	,(N'LVL', N'Ls', N'Latvia Lati')
	,(N'LYD', N'د.ل.‏', N'Libya Dinars')
	,(N'MAD', N'د.م.‏', N'Morocco Dirhams')
	,(N'MKD', N'ден.', N'Macedonia Denars')
	,(N'MNT', N'₮', N'Mongolia Tugriks')
	,(N'MOP', N'P', N'Macau Patacas')
	,(N'MVR', N'ރ.', N'Maldives Rufiyaa')
	,(N'MXN', N'$', N'Mexico Pesos')
	,(N'MYR', N'R', N'Malaysia Ringgits')
	,(N'NIO', N'C$', N'Nicaragua Cordobas')
	,(N'NOK', N'kr', N'Norway Kroner')
	,(N'NZD', N'$', N'New Zealand Dollars')
	,(N'OMR', N'ر.ع.‏', N'Oman Rials')
	,(N'PAB', N'B/.', N'Panama Balboas')
	,(N'PEN', N'S/.', N'Peru Nuevos Soles')
	,(N'PHP', N'Php', N'Philippines Pesos')
	,(N'PKR', N'Rs', N'Pakistan Rupees')
	,(N'PLN', N'zł', N'Poland Zlotych')
	,(N'PYG', N'Gs', N'Paraguay Guarani')
	,(N'QAR', N'ر.ق.‏', N'Qatar Riyals')
	,(N'ROL', N'lei', N'Romania Lei')
	,(N'RUR', N'р.', N'Russia')
	,(N'SAR', N'ر.س.‏', N'Saudi Arabia Riyals')
	,(N'SEK', N'kr', N'Sweden Kronor')
	,(N'SGD', N'$', N'Singapore Dollars')
	,(N'SIT', N'SIT', N'Slovenia Tolars')
	,(N'SKK', N'Sk', N'Slovakia Koruny')
	,(N'SYP', N'ل.س.‏', N'Syria Pounds')
	,(N'THB', N'฿', N'Thailand Baht')
	,(N'TND', N'د.ت.‏', N'Tunisia Dinars')
	,(N'TRL', N'TL', N'Turkey Liras')
	,(N'TTD', N'TT$', N'Trinidad and Tobago Dollars')
	,(N'TWD', N'NT$', N'Taiwan New Dollars')
	,(N'UAH', N'грн.', N'Ukraine Hryvnia')
	,(N'USD', N'$', N'US Dollars')
	,(N'UYU', N'$U', N'Uruguay Pesos')
	,(N'UZS', N'su''m', N'Uzbekistan Sums')
	,(N'VEB', N'Bs', N'Venezuela Bolivares')
	,(N'VND', N'₫', N'Vietnam Dong')
	,(N'YER', N'ر.ي.‏', N'Yemen Rials')
	,(N'YUN', N'Din.', N'Serbia')
	,(N'ZAR', N'R', N'South Africa Rand')
	,(N'ZWD', N'Z$', N'Zimbabwe Dollar');
go
ALTER TABLE App.tbOptions WITH NOCHECK ADD
	UnitOfCharge nvarchar(5) NULL,
	CONSTRAINT FK_App_tbUoc_UnitOfCharge FOREIGN KEY (UnitOfCharge) REFERENCES App.tbUoc (UnitOfCharge);
go
ALTER TABLE Activity.tbActivity
	DROP COLUMN DefaultText;
go
CREATE TABLE App.tbEth (
	NetworkProvider nvarchar(200) NOT NULL,
	PublicKey nvarchar(42) NOT NULL,
	PrivateKey nvarchar(64) NULL,
	ConsortiumAddress nvarchar(42) NULL
	CONSTRAINT PK_App_tbEth PRIMARY KEY CLUSTERED (NetworkProvider)
) ON [PRIMARY];
go
CREATE TABLE Activity.tbMirror (
	ActivityCode nvarchar(50) NOT NULL,
	AccountCode nvarchar(10) NOT NULL,
	AllocationCode nvarchar(50) NOT NULL,
	TransmitStatusCode smallint NOT NULL CONSTRAINT DF_Activity_tbMirror_TransmitStatusCode DEFAULT (0),
	InsertedBy nvarchar(50) NOT NULL CONSTRAINT DF_Activity_tbMirror_InsertedBy  DEFAULT (suser_sname()),
	InsertedOn datetime NOT NULL CONSTRAINT DF_Activity_tbMirror_InsertedOn  DEFAULT (getdate()),
	UpdatedBy nvarchar(50) NOT NULL CONSTRAINT DF_Activity_tbMirror_UpdatedBy  DEFAULT (suser_sname()),
	UpdatedOn datetime NOT NULL CONSTRAINT DF_Activity_tbMirror_UpdatedOn  DEFAULT (getdate()),
	RowVer timestamp NOT NULL,
	CONSTRAINT PK_Activity_tbMirror PRIMARY KEY CLUSTERED (ActivityCode, AccountCode, AllocationCode),	
	CONSTRAINT FK_Activity_tbMirror_tbActivity FOREIGN KEY (ActivityCode) REFERENCES Activity.tbActivity (ActivityCode) ON UPDATE CASCADE ON DELETE CASCADE,
	CONSTRAINT FK_Activity_tbMirror_tbOrg FOREIGN KEY (AccountCode) REFERENCES Org.tbOrg (AccountCode) ON UPDATE CASCADE ON DELETE CASCADE,
	CONSTRAINT FK_Activity_tbMirror_tbTransmitStatus FOREIGN KEY (TransmitStatusCode) REFERENCES Org.tbTransmitStatus (TransmitStatusCode)
) ON [PRIMARY];
go
CREATE UNIQUE NONCLUSTERED INDEX IX_Activity_tbMirror_AllocationCode ON Activity.tbMirror (AccountCode, AllocationCode) INCLUDE (ActivityCode) ON [PRIMARY];
CREATE NONCLUSTERED INDEX IX_Activity_tbMirror_TransmitStatusCode ON Activity.tbMirror (TransmitStatusCode, AllocationCode) ON [PRIMARY];
go
CREATE OR ALTER TRIGGER Activity_tbMirror_Trigger_Insert
ON Activity.tbMirror
FOR INSERT
AS
	SET NOCOUNT ON;

	BEGIN TRY

		UPDATE mirror
		SET TransmitStatusCode = org.TransmitStatusCode
		FROM Activity.tbMirror mirror 
			JOIN inserted ON mirror.AccountCode = inserted.AccountCode AND mirror.ActivityCode = inserted.ActivityCode
			JOIN Org.tbOrg org ON inserted.AccountCode = org.AccountCode;
	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
go
CREATE OR ALTER TRIGGER Activity_tbMirror_Trigger_Update
ON Activity.tbMirror
FOR UPDATE
AS
	SET NOCOUNT ON;

	BEGIN TRY
		IF NOT UPDATE(TransmitStatusCode)
		BEGIN
			UPDATE mirror
			SET 
				TransmitStatusCode = CASE WHEN org.TransmitStatusCode = 1 THEN 2 ELSE 0 END,
				UpdatedBy = SUSER_NAME(),
				UpdatedOn = CURRENT_TIMESTAMP
			FROM Activity.tbMirror mirror 
				JOIN inserted ON mirror.AccountCode = inserted.AccountCode AND mirror.ActivityCode = inserted.ActivityCode
				JOIN Org.tbOrg org ON inserted.AccountCode = org.AccountCode
			WHERE inserted.TransmitStatusCode <> 1;
		END
	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
go
CREATE TABLE Task.tbAllocation (
	ContractAddress nvarchar(42) NOT NULL,
	AccountCode nvarchar(10) NOT NULL,
	AllocationCode nvarchar(50) NOT NULL,
	AllocationDescription nvarchar(256) NULL,
	TaskCode nvarchar(20) NOT NULL,
	TaskTitle nvarchar(100) NULL,
	CashModeCode smallint NOT NULL,
	UnitOfMeasure nvarchar(15) NULL,
	UnitOfCharge nvarchar(5) NULL,
	TaskStatusCode smallint NOT NULL,
	ActionOn datetime NOT NULL,
	UnitCharge decimal(18, 6) NOT NULL,
	TaxRate decimal(18, 4) NOT NULL,
	QuantityOrdered decimal(18, 4) NOT NULL,
	QuantityDelivered decimal(18, 4) NOT NULL,
	InsertedOn datetime NOT NULL CONSTRAINT DF_Task_tbAllocation_InsertedOn DEFAULT (GETDATE()),
	RowVer timestamp NOT NULL,
	CONSTRAINT PK_Task_tbAllocation PRIMARY KEY CLUSTERED (ContractAddress),
	CONSTRAINT FK_Task_tbAllocation_AccountCode FOREIGN KEY (AccountCode) REFERENCES Org.tbOrg (AccountCode)  ON UPDATE CASCADE ON DELETE CASCADE,
	CONSTRAINT FK_Task_tbAllocation_CashModeCode FOREIGN KEY (CashModeCode) REFERENCES Cash.tbMode (CashModeCode),
	CONSTRAINT FK_Task_tbAllocation_TaskStatusCode FOREIGN KEY (TaskStatusCode) REFERENCES Task.tbStatus (TaskStatusCode)
) ON [PRIMARY];
go
CREATE NONCLUSTERED INDEX IX_Task_tbAllocation_ActivityCode ON Task.tbAllocation (AccountCode, AllocationCode) ON [PRIMARY];
CREATE NONCLUSTERED INDEX IX_Task_tbAllocation_TaskStatusCode ON Task.tbAllocation(TaskStatusCode, AccountCode, AllocationCode, ActionOn) ON [PRIMARY];
CREATE NONCLUSTERED INDEX IX_Task_tbAllocation_TaskCode ON Task.tbAllocation (AccountCode, TaskCode) ON [PRIMARY];
go
INSERT INTO App.tbEventType (EventTypeCode, EventType)
VALUES (3, 'Price Change'), (4, 'Reschedule'), (5, 'Delivered'), (6, 'Status Change'), (7, 'Payment');
go
CREATE TABLE Task.tbAllocationEvent (
	ContractAddress nvarchar(42) NOT NULL,
	LogId int IDENTITY(1,1) NOT NULL,
	EventTypeCode smallint NOT NULL,	
	TaskStatusCode smallint NOT NULL,
	ActionOn datetime NOT NULL,
	UnitCharge decimal(18, 6) NOT NULL,
	TaxRate decimal(18, 4) NOT NULL,
	QuantityOrdered decimal(18, 4) NOT NULL,
	QuantityDelivered decimal(18, 4) NOT NULL,
	InsertedOn datetime NOT NULL CONSTRAINT DF_Task_tbAllocationEvent_InsertedOn DEFAULT (GETDATE()),
	RowVer timestamp NOT NULL,
	CONSTRAINT PK_Task_tbAllocationEvent PRIMARY KEY CLUSTERED (ContractAddress, LogId),
	CONSTRAINT FK_Task_tbAllocationEvent_tbAllocation FOREIGN KEY (ContractAddress) REFERENCES Task.tbAllocation (ContractAddress) ON DELETE CASCADE,
	CONSTRAINT FK_Task_tbAllocationEvent_App_tbEventType FOREIGN KEY (EventTypeCode) REFERENCES App.tbEventType (EventTypeCode),
	CONSTRAINT FK_Task_tbAllocationEvent_Task_tbStatus FOREIGN KEY (TaskStatusCode) REFERENCES Task.tbStatus (TaskStatusCode)

) ON [PRIMARY];
go
CREATE NONCLUSTERED INDEX IX_Task_tbAllocationEvent_EventTypeCide ON Task.tbAllocationEvent (EventTypeCode, TaskStatusCode, InsertedOn DESC) ON [PRIMARY];
go
ALTER TABLE Task.tbChangeLog DROP CONSTRAINT PK_Task_tbChangeLog WITH ( ONLINE = OFF )
go
DROP INDEX IX_Task_tbChangeLog_TaskCode ON Task.tbChangeLog;
go
ALTER TABLE Task.tbChangeLog ADD
	CONSTRAINT PK_Task_tbChangeLog PRIMARY KEY CLUSTERED (TaskCode, LogId DESC)
	--,CONSTRAINT FK_Task_tbChangeLog_tbTask FOREIGN KEY(TaskCode) REFERENCES Task.tbTask (TaskCode) ON DELETE CASCADE;
go
CREATE UNIQUE NONCLUSTERED INDEX IX_Task_tbChangeLog_LogId ON Task.tbChangeLog (LogId DESC) ON [PRIMARY];
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
CREATE OR ALTER TRIGGER Task.Task_tbTask_TriggerUpdate
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
		END;

		IF UPDATE(AccountCode)
		BEGIN
			WITH candidates AS
			(
				SELECT inserted.* FROM inserted
				JOIN deleted ON inserted.TaskCode = deleted.TaskCode
				WHERE inserted.AccountCode <> deleted.AccountCode
			)
			INSERT INTO Task.tbChangeLog
									 (TaskCode, TransmitStatusCode, AccountCode, ActivityCode, TaskStatusCode, ActionOn, Quantity, CashCode, TaxCode, UnitCharge)
			SELECT candidates.TaskCode, Org.tbOrg.TransmitStatusCode, candidates.AccountCode, candidates.ActivityCode, candidates.TaskStatusCode, 
									 candidates.ActionOn, candidates.Quantity, candidates.CashCode, candidates.TaxCode, candidates.UnitCharge
			FROM candidates 
				JOIN Org.tbOrg ON candidates.AccountCode = Org.tbOrg.AccountCode
				JOIN Cash.tbCode ON candidates.CashCode = Cash.tbCode.CashCode;
		END

	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
go
ALTER PROCEDURE Task.proc_AssignToParent 
	(
	@ChildTaskCode nvarchar(20),
	@ParentTaskCode nvarchar(20)
	)
  AS
   	SET NOCOUNT, XACT_ABORT ON;

	BEGIN TRY
		DECLARE 
			@TaskTitle nvarchar(100)
			, @StepNumber smallint

		BEGIN TRANSACTION
		
		IF EXISTS (SELECT ParentTaskCode FROM Task.tbFlow WHERE ChildTaskCode = @ChildTaskCode)
			DELETE FROM Task.tbFlow WHERE ChildTaskCode = @ChildTaskCode

		IF EXISTS(SELECT     TOP 1 StepNumber
				  FROM         Task.tbFlow
				  WHERE     (ParentTaskCode = @ParentTaskCode))
			BEGIN
			SELECT  @StepNumber = MAX(StepNumber) 
			FROM         Task.tbFlow
			WHERE     (ParentTaskCode = @ParentTaskCode)
			SET @StepNumber = @StepNumber - (@StepNumber % 10) + 10		
			END
		ELSE
			SET @StepNumber = 10


		SELECT     @TaskTitle = TaskTitle
		FROM         Task.tbTask
		WHERE     (TaskCode = @ParentTaskCode)		
	
		UPDATE    Task.tbTask
		SET              TaskTitle = @TaskTitle
		WHERE     (TaskCode = @ChildTaskCode) AND ((TaskTitle IS NULL) OR (TaskTitle = ActivityCode))
	
		INSERT INTO Task.tbFlow
							  (ParentTaskCode, StepNumber, ChildTaskCode, UsedOnQuantity)
		VALUES     (@ParentTaskCode, @StepNumber, @ChildTaskCode, 0)
	
		COMMIT TRANSACTION

  	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
go
CREATE OR ALTER PROCEDURE Task.proc_Configure (@ParentTaskCode nvarchar(20))
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
		WHERE LEN(ISNULL(Task.tbTask.ContactName, '')) > 0 AND (Task.tbTask.TaskCode = @ParentTaskCode)
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
						Task_tb1.ActionById, Task_tb1.ActionOn, Activity.tbActivity.ActivityDescription, Task_tb1.Quantity * Activity.tbFlow.UsedOnQuantity AS Quantity,
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
CREATE OR ALTER PROCEDURE Task.proc_NetworkUpdated (@TaskCode nvarchar(20))
AS
	SET NOCOUNT, XACT_ABORT ON;

	BEGIN TRY

		UPDATE Task.tbChangeLog
		SET TransmitStatusCode = 3
		WHERE TaskCode = @TaskCode AND TransmitStatusCode < 3;

	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
go
CREATE OR ALTER VIEW Task.vwNetworkDeployments
AS
	SELECT DISTINCT Task.tbTask.TaskCode, Task.tbTask.AccountCode, Task.tbTask.ActivityCode, Activity.tbActivity.ActivityDescription, Task.tbTask.TaskTitle, Task.tbTask.TaskStatusCode, Task.tbStatus.TaskStatus, Task.tbTask.ActionOn, Task.tbTask.Quantity, 
							 Cash.tbCategory.CashModeCode, Cash.tbMode.CashMode, App.tbTaxCode.TaxRate, Task.tbTask.UnitCharge, Activity.tbActivity.UnitOfMeasure,
								 (SELECT        UnitOfCharge
								   FROM            App.tbOptions) AS UnitOfCharge
	FROM            Task.tbChangeLog INNER JOIN
							 Task.tbTask ON Task.tbChangeLog.TaskCode = Task.tbTask.TaskCode INNER JOIN
							 Cash.tbCode ON Task.tbTask.CashCode = Cash.tbCode.CashCode INNER JOIN
							 Cash.tbCategory ON Cash.tbCode.CategoryCode = Cash.tbCategory.CategoryCode AND Cash.tbCode.CategoryCode = Cash.tbCategory.CategoryCode INNER JOIN
							 App.tbTaxCode ON Task.tbTask.TaxCode = App.tbTaxCode.TaxCode AND Task.tbTask.TaxCode = App.tbTaxCode.TaxCode INNER JOIN
							 Activity.tbActivity ON Task.tbTask.ActivityCode = Activity.tbActivity.ActivityCode AND Task.tbTask.ActivityCode = Activity.tbActivity.ActivityCode INNER JOIN
							 Task.tbStatus ON Task.tbTask.TaskStatusCode = Task.tbStatus.TaskStatusCode INNER JOIN
							 Cash.tbMode ON Cash.tbCategory.CashModeCode = Cash.tbMode.CashModeCode AND Cash.tbCategory.CashModeCode = Cash.tbMode.CashModeCode
	WHERE        (Task.tbChangeLog.TransmitStatusCode = 1)
go
CREATE OR ALTER VIEW Task.vwNetworkUpdates
AS
	WITH updates AS
	(
		SELECT DISTINCT TaskCode FROM Task.tbChangeLog 
		WHERE TransmitStatusCode = 2
		EXCEPT
		SELECT DISTINCT TaskCode FROM Task.tbChangeLog 
		WHERE TransmitStatusCode = 1
	)
	SELECT Task.tbTask.TaskCode, Task.tbTask.AccountCode, Task.tbTask.ActivityCode, Task.tbTask.TaskStatusCode, Task.tbStatus.TaskStatus, Task.tbTask.ActionOn, Task.tbTask.Quantity, App.tbTaxCode.TaxRate, Task.tbTask.UnitCharge
	FROM  updates 
		JOIN Task.tbTask ON updates.TaskCode = Task.tbTask.TaskCode 
		JOIN Cash.tbCode ON Task.tbTask.CashCode = Cash.tbCode.CashCode 
		JOIN Task.tbStatus ON Task.tbTask.TaskStatusCode = Task.tbStatus.TaskStatusCode
		JOIN App.tbTaxCode ON Task.tbTask.TaxCode = App.tbTaxCode.TaxCode AND Task.tbTask.TaxCode = App.tbTaxCode.TaxCode;
go
CREATE OR ALTER VIEW Task.vwNetworkEventLog
AS
	SELECT        Task.tbAllocationEvent.ContractAddress, Task.tbAllocationEvent.LogId, Task.tbAllocationEvent.EventTypeCode, Task.tbAllocationEvent.TaskStatusCode, Task.tbAllocationEvent.ActionOn, Task.tbAllocationEvent.UnitCharge, 
							 Task.tbAllocationEvent.TaxRate, Task.tbAllocationEvent.QuantityOrdered, Task.tbAllocationEvent.QuantityDelivered, Task.tbAllocationEvent.InsertedOn, Task.tbAllocationEvent.RowVer, App.tbEventType.EventType, 
							 Task.tbStatus.TaskStatus, Task.tbAllocation.AccountCode, Org.tbOrg.AccountName, Activity.tbMirror.ActivityCode, Task.tbAllocation.AllocationCode, Task.tbAllocation.AllocationDescription, Task.tbAllocation.TaskCode, 
							 Task.tbAllocation.CashModeCode, Cash.tbMode.CashMode, Task.tbAllocation.UnitOfMeasure, Task.tbAllocation.UnitOfCharge
	FROM            Task.tbAllocationEvent INNER JOIN
							 Task.tbStatus ON Task.tbAllocationEvent.TaskStatusCode = Task.tbStatus.TaskStatusCode INNER JOIN
							 Task.tbAllocation ON Task.tbAllocationEvent.ContractAddress = Task.tbAllocation.ContractAddress AND Task.tbStatus.TaskStatusCode = Task.tbAllocation.TaskStatusCode AND 
							 Task.tbStatus.TaskStatusCode = Task.tbAllocation.TaskStatusCode INNER JOIN
							 Org.tbOrg ON Task.tbAllocation.AccountCode = Org.tbOrg.AccountCode AND Task.tbAllocation.AccountCode = Org.tbOrg.AccountCode INNER JOIN
							 Cash.tbMode ON Task.tbAllocation.CashModeCode = Cash.tbMode.CashModeCode AND Task.tbAllocation.CashModeCode = Cash.tbMode.CashModeCode INNER JOIN
							 Activity.tbMirror ON Task.tbAllocation.AccountCode = Activity.tbMirror.AccountCode AND Task.tbAllocation.AllocationCode = Activity.tbMirror.AllocationCode INNER JOIN
							 App.tbEventType ON Task.tbAllocationEvent.EventTypeCode = App.tbEventType.EventTypeCode;
go
CREATE OR ALTER VIEW Activity.vwUnMirrored
AS
	WITH candidates AS
	(
		SELECT DISTINCT Task.tbAllocation.AccountCode, Org.tbOrg.AccountName, Task.tbAllocation.AllocationCode, Task.tbAllocation.AllocationDescription, Task.tbAllocation.CashModeCode, Cash.tbMode.CashMode, Task.tbAllocation.UnitCharge, Task.tbAllocation.UnitOfMeasure
		FROM            Task.tbAllocation 
			INNER JOIN Cash.tbMode ON Task.tbAllocation.CashModeCode = Cash.tbMode.CashModeCode 
			INNER JOIN Org.tbOrg ON Task.tbAllocation.AccountCode = Org.tbOrg.AccountCode 
			LEFT OUTER JOIN Activity.tbMirror ON Task.tbAllocation.AccountCode = Activity.tbMirror.AccountCode AND Task.tbAllocation.AllocationCode = Activity.tbMirror.AllocationCode
		WHERE        (Activity.tbMirror.ActivityCode IS NULL)
	)
	SELECT CAST(ROW_NUMBER() OVER (ORDER BY AccountCode, AllocationCode) AS int) CandidateId,
		candidates.AccountCode, candidates.AccountName, candidates.AllocationCode, candidates.AllocationDescription, candidates.CashModeCode, candidates.CashMode, candidates.UnitCharge, candidates.UnitOfMeasure,
		CASE WHEN act_code.ActivityCode IS NULL THEN 0 ELSE 1 END IsActivity
	FROM candidates LEFT OUTER JOIN Activity.tbActivity act_code ON candidates.AllocationCode = act_code.ActivityCode;
go
ALTER VIEW Activity.vwCandidateCashCodes
AS
	SELECT Cash.tbCode.CashCode, Cash.tbCode.CashDescription, Cash.tbCategory.Category, Cash.tbCategory.CashModeCode, Cash.tbCategory.CashTypeCode
	FROM            Cash.tbCode INNER JOIN
							 Cash.tbCategory ON Cash.tbCode.CategoryCode = Cash.tbCategory.CategoryCode
	WHERE        (Cash.tbCategory.CashTypeCode < 2)  AND (Cash.tbCategory.IsEnabled <> 0) AND (Cash.tbCode.IsEnabled <> 0)
go
CREATE OR ALTER VIEW Activity.vwExpenseCashCodes
AS
	SELECT CashCode, CashDescription, Category
	FROM Activity.vwCandidateCashCodes
	WHERE CashModeCode = 0 AND CashTypeCode = 0
go
CREATE OR ALTER VIEW Activity.vwIncomeCashCodes
AS
	SELECT CashCode, CashDescription, Category
	FROM Activity.vwCandidateCashCodes
	WHERE CashModeCode = 1 AND CashTypeCode = 0
go
CREATE OR ALTER PROCEDURE Activity.proc_Mirror(@ActivityCode nvarchar(50), @AccountCode nvarchar(10), @AllocationCode nvarchar(50))
AS
	SET NOCOUNT, XACT_ABORT ON;

	BEGIN TRY
		IF NOT EXISTS (SELECT * FROM Activity.tbMirror WHERE ActivityCode = @ActivityCode AND AccountCode = @AccountCode AND AllocationCode = @AllocationCode)
		BEGIN
			INSERT INTO Activity.tbMirror (ActivityCode, AccountCode, AllocationCode)
			VALUES (@ActivityCode, @AccountCode, @AllocationCode);
		END
	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
go
CREATE OR ALTER VIEW Activity.vwNetworkMirrors
AS
	SELECT AccountCode, ActivityCode, AllocationCode, TransmitStatusCode FROM Activity.tbMirror WHERE TransmitStatusCode BETWEEN 1 AND 2;
go
CREATE OR ALTER PROCEDURE Activity.proc_NetworkUpdated(@AccountCode nvarchar(10), @AllocationCode nvarchar(50))
AS
	SET NOCOUNT, XACT_ABORT ON;

	BEGIN TRY
		UPDATE Activity.tbMirror
		SET TransmitStatusCode = 3
		WHERE AccountCode = @AccountCode AND AllocationCode = @AllocationCode;
	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
go
CREATE OR ALTER VIEW Task.vwAllocationSvD
AS
	WITH allocs AS
	(
		SELECT mirror.ActivityCode, alloc.AccountCode, alloc.TaskCode, alloc.ActionOn, 
			CASE CashModeCode WHEN 0 THEN 1 ELSE 0 END SupplyOrder, CAST(1 AS bit) IsAllocation, UnitCharge,
			CASE CashModeCode 
				WHEN 0 THEN (alloc.QuantityOrdered - alloc.QuantityDelivered) * -1
				WHEN 1 THEN (alloc.QuantityOrdered - alloc.QuantityDelivered)
			END Quantity,
			CASE CashModeCode 
				WHEN 0 THEN 1
				WHEN 1 THEN 0
			END CashModeCode			
		FROM Task.tbAllocation alloc
			JOIN Activity.tbMirror mirror ON alloc.AccountCode = mirror.AccountCode AND alloc.AllocationCode = mirror.AllocationCode
		WHERE TaskStatusCode BETWEEN 1 AND 2	
	), tasks AS
	(
		SELECT task.ActivityCode, task.AccountCode, TaskCode, ActionOn, Quantity, UnitCharge, CashModeCode
		FROM Task.tbTask task
			JOIN Activity.tbMirror mirror ON task.AccountCode = mirror.AccountCode AND task.ActivityCode = mirror.ActivityCode
			JOIN Cash.tbCode cash_code ON task.CashCode = cash_code.CashCode
			JOIN Cash.tbCategory category ON cash_code.CategoryCode = category.CategoryCode
		WHERE TaskStatusCode BETWEEN 1 AND 2
	), invoice_quantities AS
	(
		SELECT tasks.TaskCode, SUM(COALESCE(invoice_quantity.Quantity, 0)) InvoiceQuantity
		FROM tasks
		OUTER APPLY 
			(
				SELECT CASE invoice.InvoiceTypeCode 
							WHEN 1 THEN delivery.Quantity * -1 
							WHEN 3 THEN delivery.Quantity * -1 
							ELSE delivery.Quantity 
						END Quantity
				FROM Invoice.tbTask delivery 
					JOIN Invoice.tbInvoice invoice ON delivery.InvoiceNumber = invoice.InvoiceNumber
				WHERE delivery.TaskCode = tasks.TaskCode
			) invoice_quantity
		GROUP BY tasks.TaskCode
	), deliveries AS
	(
		SELECT tasks.*, invoice_quantities.InvoiceQuantity
		FROM tasks JOIN invoice_quantities ON tasks.TaskCode = invoice_quantities.TaskCode 
	
	), order_book AS
	(
		SELECT ActivityCode, AccountCode, TaskCode, ActionOn, CASE CashModeCode WHEN 0 THEN 1 ELSE 0 END SupplyOrder, CAST(0 AS bit) IsAllocation, UnitCharge,
			CASE CashModeCode
				WHEN 0 THEN (Quantity - InvoiceQuantity) * -1
				WHEN 1 THEN (Quantity - InvoiceQuantity)
			END Quantity,
			CashModeCode
		FROM deliveries
	), SvD AS
	(
		SELECT * FROM allocs
		UNION
		SELECT * FROM order_book
	), SvD_ordered AS
	(
		SELECT
			ActivityCode,
			ROW_NUMBER() OVER (PARTITION BY ActivityCode ORDER BY ActionOn, SupplyOrder) RowNumber,
			AccountCode, IsAllocation, TaskCode, CashModeCode, UnitCharge, ActionOn, Quantity
		FROM SvD
	), SvD_projection AS
	(
		SELECT
			ActivityCode, RowNumber, AccountCode, IsAllocation, TaskCode, CashModeCode, UnitCharge, ActionOn, Quantity,
			SUM(Quantity) OVER (PARTITION BY ActivityCode ORDER BY RowNumber ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS Balance
		FROM SvD_ordered
	), SvD_scheduled AS
	(
		SELECT ActivityCode, RowNumber, AccountCode, TaskCode, IsAllocation, CashModeCode, UnitCharge, ActionOn, Quantity, Balance,
			CASE WHEN 
				LEAD(Balance, 1, Balance) OVER (PARTITION BY ActivityCode ORDER BY RowNumber) < 0 
					AND LAG(Balance, 1, 0) OVER (PARTITION BY ActivityCode ORDER BY RowNumber) >= 0 
					AND Balance < 0
				THEN ActionOn
				ELSE NULL END ScheduleOn
		FROM SvD_projection
	)
	SELECT CAST(ROW_NUMBER() OVER (ORDER BY SvD_scheduled.ActivityCode, RowNumber) AS int) AllocationId, SvD_scheduled.ActivityCode, activity.ActivityDescription, AccountCode, IsAllocation, TaskCode, SvD_scheduled.CashModeCode, polarity.CashMode, SvD_scheduled.UnitCharge, ActionOn, Quantity, CAST(Balance AS decimal(18,2)) Balance,
		MAX(ScheduleOn) OVER (PARTITION BY SvD_scheduled.ActivityCode ORDER BY RowNumber) ScheduleOn			
	FROM SvD_scheduled
		JOIN Activity.tbActivity activity ON SvD_scheduled.ActivityCode = activity.ActivityCode
		JOIN Cash.tbMode polarity ON SvD_scheduled.CashModeCode = polarity.CashModeCode;
go
CREATE OR ALTER TRIGGER Task_tbAllocation_Insert
ON Task.tbAllocation
FOR INSERT
AS
	SET NOCOUNT ON;

	BEGIN TRY
		INSERT INTO Task.tbAllocationEvent (ContractAddress, EventTypeCode, TaskStatusCode, ActionOn, UnitCharge, TaxRate, QuantityOrdered, QuantityDelivered)
		SELECT ContractAddress, 2 EventTypeCode, TaskStatusCode, ActionOn, UnitCharge, TaxRate, QuantityOrdered, QuantityDelivered
		FROM inserted
	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
go
CREATE OR ALTER TRIGGER Task_tbAllocation_Trigger_Update
ON Task.tbAllocation
FOR UPDATE
AS
	SET NOCOUNT ON;

	BEGIN TRY

		IF UPDATE(TaskStatusCode)
		BEGIN
			INSERT INTO Task.tbAllocationEvent (ContractAddress, EventTypeCode, TaskStatusCode, ActionOn, UnitCharge, TaxRate, QuantityOrdered, QuantityDelivered)
			SELECT i.ContractAddress, 6 EventTypeCode, i.TaskStatusCode, i.ActionOn, i.UnitCharge, i.TaxRate, i.QuantityOrdered, i.QuantityDelivered
			FROM inserted i
				JOIN deleted d ON i.ContractAddress = d.ContractAddress
			WHERE d.TaskStatusCode <> i.TaskStatusCode
		END

		IF UPDATE(UnitCharge) OR UPDATE(TaxRate)
		BEGIN
			INSERT INTO Task.tbAllocationEvent (ContractAddress, EventTypeCode, TaskStatusCode, ActionOn, UnitCharge, TaxRate, QuantityOrdered, QuantityDelivered)
			SELECT i.ContractAddress, 3 EventTypeCode, i.TaskStatusCode, i.ActionOn, i.UnitCharge, i.TaxRate, i.QuantityOrdered, i.QuantityDelivered
			FROM inserted i
				JOIN deleted d ON i.ContractAddress = d.ContractAddress
			WHERE d.UnitCharge <> i.UnitCharge OR d.TaxRate <> i.TaxRate
		END

		IF UPDATE(ActionOn) OR UPDATE(QuantityOrdered)
		BEGIN
			INSERT INTO Task.tbAllocationEvent (ContractAddress, EventTypeCode, TaskStatusCode, ActionOn, UnitCharge, TaxRate, QuantityOrdered, QuantityDelivered)
			SELECT i.ContractAddress, 4 EventTypeCode, i.TaskStatusCode, i.ActionOn, i.UnitCharge, i.TaxRate, i.QuantityOrdered, i.QuantityDelivered
			FROM inserted i
				JOIN deleted d ON i.ContractAddress = d.ContractAddress
			WHERE d.ActionOn <> i.ActionOn OR d.QuantityOrdered <> i.QuantityOrdered
		END

		IF UPDATE(QuantityDelivered)
		BEGIN
			INSERT INTO Task.tbAllocationEvent (ContractAddress, EventTypeCode, TaskStatusCode, ActionOn, UnitCharge, TaxRate, QuantityOrdered, QuantityDelivered)
			SELECT i.ContractAddress, 5 EventTypeCode, i.TaskStatusCode, i.ActionOn, i.UnitCharge, i.TaxRate, i.QuantityOrdered, i.QuantityDelivered
			FROM inserted i
				JOIN deleted d ON i.ContractAddress = d.ContractAddress
			WHERE d.QuantityDelivered <> i.QuantityDelivered
		END

	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
go

CREATE OR ALTER VIEW Task.vwNetworkAllocations
AS
	SELECT        Task.tbAllocation.ContractAddress, Task.tbAllocation.AccountCode, Org.tbOrg.AccountName, Activity.tbMirror.ActivityCode, Task.tbAllocation.AllocationCode, Task.tbAllocation.AllocationDescription, Task.tbAllocation.TaskCode, 
							 Task.tbAllocation.TaskTitle, Task.tbAllocation.CashModeCode, Cash.tbMode.CashMode, Task.tbAllocation.UnitOfMeasure, Task.tbAllocation.UnitOfCharge, Task.tbAllocation.TaskStatusCode, Task.tbStatus.TaskStatus, 
							 Task.tbAllocation.ActionOn, Task.tbAllocation.UnitCharge, Task.tbAllocation.TaxRate, Task.tbAllocation.QuantityOrdered, Task.tbAllocation.QuantityDelivered, Task.tbAllocation.InsertedOn, Task.tbAllocation.RowVer
	FROM            Task.tbAllocation INNER JOIN
							 Activity.tbMirror ON Task.tbAllocation.AccountCode = Activity.tbMirror.AccountCode AND Task.tbAllocation.AllocationCode = Activity.tbMirror.AllocationCode INNER JOIN
							 Org.tbOrg ON Task.tbAllocation.AccountCode = Org.tbOrg.AccountCode AND Task.tbAllocation.AccountCode = Org.tbOrg.AccountCode AND Task.tbAllocation.AccountCode = Org.tbOrg.AccountCode AND 
							 Task.tbAllocation.AccountCode = Org.tbOrg.AccountCode AND Task.tbAllocation.AccountCode = Org.tbOrg.AccountCode INNER JOIN
							 Cash.tbMode ON Task.tbAllocation.CashModeCode = Cash.tbMode.CashModeCode AND Task.tbAllocation.CashModeCode = Cash.tbMode.CashModeCode AND 
							 Task.tbAllocation.CashModeCode = Cash.tbMode.CashModeCode AND Task.tbAllocation.CashModeCode = Cash.tbMode.CashModeCode AND Task.tbAllocation.CashModeCode = Cash.tbMode.CashModeCode INNER JOIN
							 Task.tbStatus ON Task.tbAllocation.TaskStatusCode = Task.tbStatus.TaskStatusCode AND Task.tbAllocation.TaskStatusCode = Task.tbStatus.TaskStatusCode AND 
							 Task.tbAllocation.TaskStatusCode = Task.tbStatus.TaskStatusCode AND Task.tbAllocation.TaskStatusCode = Task.tbStatus.TaskStatusCode AND Task.tbAllocation.TaskStatusCode = Task.tbStatus.TaskStatusCode;
go
CREATE OR ALTER VIEW Task.vwNetworkEvents
AS
	SELECT        Task.tbAllocationEvent.ContractAddress, Task.tbAllocationEvent.LogId, App.tbEventType.EventTypeCode, App.tbEventType.EventType, 
							 Task.tbStatus.TaskStatusCode, Task.tbStatus.TaskStatus, Task.tbAllocationEvent.ActionOn, Task.tbAllocationEvent.UnitCharge, Task.tbAllocationEvent.TaxRate, Task.tbAllocationEvent.QuantityOrdered, 
							 Task.tbAllocationEvent.QuantityDelivered, Task.tbAllocationEvent.InsertedOn
	FROM            Task.tbAllocationEvent INNER JOIN
							 App.tbEventType ON Task.tbAllocationEvent.EventTypeCode = App.tbEventType.EventTypeCode INNER JOIN
							 Task.tbStatus ON Task.tbAllocationEvent.TaskStatusCode = Task.tbStatus.TaskStatusCode;
go
CREATE OR ALTER VIEW Task.vwNetworkQuotations
AS
	WITH requests AS
	(
		SELECT mirror.ActivityCode, alloc.AccountCode, alloc.TaskCode, alloc.ActionOn, 
			CASE CashModeCode WHEN 0 THEN 1 ELSE 0 END SupplyOrder, CAST(1 AS bit) IsAllocation, UnitCharge,
			CASE CashModeCode 
				WHEN 0 THEN (alloc.QuantityOrdered - alloc.QuantityDelivered) * -1
				WHEN 1 THEN (alloc.QuantityOrdered - alloc.QuantityDelivered)
			END Quantity,
			CASE CashModeCode 
				WHEN 0 THEN 1
				WHEN 1 THEN 0
			END CashModeCode			
		FROM Task.tbAllocation alloc
			JOIN Activity.tbMirror mirror ON alloc.AccountCode = mirror.AccountCode AND alloc.AllocationCode = mirror.AllocationCode
		WHERE TaskStatusCode = 0	
	), tasks AS
	(
		SELECT task.ActivityCode, task.AccountCode, TaskCode, ActionOn,  
			CASE CashModeCode WHEN 0 THEN 1 ELSE 0 END SupplyOrder, CAST(0 AS bit) IsAllocation, UnitCharge,
			CASE CashModeCode
					WHEN 0 THEN Quantity * -1
					WHEN 1 THEN Quantity 
				END Quantity, CashModeCode
		FROM Task.tbTask task
			JOIN Activity.tbMirror mirror ON task.AccountCode = mirror.AccountCode AND task.ActivityCode = mirror.ActivityCode
			JOIN Cash.tbCode cash_code ON task.CashCode = cash_code.CashCode
			JOIN Cash.tbCategory category ON cash_code.CategoryCode = category.CategoryCode
		WHERE TaskStatusCode = 0
	), quotes AS
	(
		SELECT * FROM requests
		UNION
		SELECT * FROM tasks
	), quotes_ordered AS
	(
			SELECT
				ActivityCode,
				ROW_NUMBER() OVER (PARTITION BY ActivityCode ORDER BY ActionOn, SupplyOrder) RowNumber,
				AccountCode, IsAllocation, TaskCode, CashModeCode, UnitCharge, ActionOn, Quantity
			FROM quotes
	), quotes_projection AS
	(
		SELECT
			ActivityCode, RowNumber, AccountCode, IsAllocation, TaskCode, CashModeCode, UnitCharge, ActionOn, Quantity,
			SUM(Quantity) OVER (PARTITION BY ActivityCode ORDER BY RowNumber ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS Balance
		FROM quotes_ordered
	)
	SELECT CAST(ROW_NUMBER() OVER (ORDER BY quotes_projection.ActivityCode, RowNumber) AS int) AllocationId, quotes_projection.ActivityCode, activity.ActivityDescription, AccountCode, IsAllocation, 
		TaskCode, quotes_projection.CashModeCode, polarity.CashMode, quotes_projection.UnitCharge, ActionOn, Quantity, CAST(Balance AS decimal(18,2)) Balance
	FROM quotes_projection
		JOIN Activity.tbActivity activity ON quotes_projection.ActivityCode = activity.ActivityCode
		JOIN Cash.tbMode polarity ON quotes_projection.CashModeCode = polarity.CashModeCode;
go
CREATE OR ALTER VIEW Task.vwNetworkChangeLog
AS
	SELECT Task.tbTask.AccountCode, Org.tbOrg.AccountName, Task.tbTask.TaskCode, Task.tbChangeLog.LogId, Task.tbChangeLog.ChangedOn, Task.tbChangeLog.TransmitStatusCode, Org.tbTransmitStatus.TransmitStatus, 
				Task.tbChangeLog.ActivityCode, Activity.tbMirror.AllocationCode, Task.tbChangeLog.TaskStatusCode, Task.tbStatus.TaskStatus, Cash.tbMode.CashModeCode, Cash.tbMode.CashMode, Task.tbChangeLog.ActionOn, 
				Task.tbChangeLog.TaxCode, Task.tbChangeLog.Quantity, Task.tbChangeLog.UnitCharge, Task.tbChangeLog.UpdatedBy, Task.tbChangeLog.RowVer
	FROM Task.tbChangeLog 
		INNER JOIN Task.tbTask ON Task.tbChangeLog.TaskCode = Task.tbTask.TaskCode INNER JOIN
				Cash.tbCode ON Task.tbTask.CashCode = Cash.tbCode.CashCode INNER JOIN
				Cash.tbCategory ON Cash.tbCode.CategoryCode = Cash.tbCategory.CategoryCode AND Cash.tbCode.CategoryCode = Cash.tbCategory.CategoryCode INNER JOIN
				Cash.tbMode ON Cash.tbCategory.CashModeCode = Cash.tbMode.CashModeCode AND Cash.tbCategory.CashModeCode = Cash.tbMode.CashModeCode INNER JOIN
				Org.tbOrg ON Task.tbTask.AccountCode = Org.tbOrg.AccountCode AND Task.tbTask.AccountCode = Org.tbOrg.AccountCode AND Task.tbTask.AccountCode = Org.tbOrg.AccountCode INNER JOIN
				Org.tbTransmitStatus ON Task.tbChangeLog.TransmitStatusCode = Org.tbTransmitStatus.TransmitStatusCode AND Task.tbChangeLog.TransmitStatusCode = Org.tbTransmitStatus.TransmitStatusCode AND 
				Task.tbChangeLog.TransmitStatusCode = Org.tbTransmitStatus.TransmitStatusCode AND Task.tbChangeLog.TransmitStatusCode = Org.tbTransmitStatus.TransmitStatusCode AND 
				Task.tbChangeLog.TransmitStatusCode = Org.tbTransmitStatus.TransmitStatusCode INNER JOIN
				Task.tbStatus ON Task.tbChangeLog.TaskStatusCode = Task.tbStatus.TaskStatusCode LEFT OUTER JOIN
				Activity.tbMirror ON Task.tbChangeLog.AccountCode = Activity.tbMirror.AccountCode AND Task.tbChangeLog.ActivityCode = Activity.tbMirror.ActivityCode
	WHERE Task.tbChangeLog.TransmitStatusCode > 0
go
/************************ Invoicing ******************************/
go
CREATE TABLE Cash.tbMirror (
	CashCode nvarchar(50) NOT NULL,
	AccountCode nvarchar(10) NOT NULL,
	ChargeCode nvarchar(50) NOT NULL,
	TransmitStatusCode smallint NOT NULL CONSTRAINT DF_Cash_tbMirror_TransmitStatusCode DEFAULT (0),
	InsertedBy nvarchar(50) NOT NULL CONSTRAINT DF_Cash_tbMirror_InsertedBy  DEFAULT (suser_sname()),
	InsertedOn datetime NOT NULL CONSTRAINT DF_Cash_tbMirror_InsertedOn  DEFAULT (getdate()),
	UpdatedBy nvarchar(50) NOT NULL CONSTRAINT DF_Cash_tbMirror_UpdatedBy  DEFAULT (suser_sname()),
	UpdatedOn datetime NOT NULL CONSTRAINT DF_Cash_tbMirror_UpdatedOn  DEFAULT (getdate()),
	RowVer timestamp NOT NULL,
	CONSTRAINT PK_Cash_tbMirror PRIMARY KEY CLUSTERED (CashCode, AccountCode, ChargeCode),	
	CONSTRAINT FK_Cash_tbMirror_tbCode FOREIGN KEY (CashCode) REFERENCES Cash.tbCode (CashCode),
	CONSTRAINT FK_Cash_tbMirror_tbOrg FOREIGN KEY (AccountCode) REFERENCES Org.tbOrg (AccountCode),
	CONSTRAINT FK_Cash_tbMirror_tbTransmitStatus FOREIGN KEY (TransmitStatusCode) REFERENCES Org.tbTransmitStatus (TransmitStatusCode)
) ON [PRIMARY];
go
CREATE UNIQUE NONCLUSTERED INDEX IX_Cash_tbMirror_ChargeCode ON Cash.tbMirror (AccountCode, ChargeCode) INCLUDE (CashCode) ON [PRIMARY];
CREATE NONCLUSTERED INDEX IX_Cash_tbMirror_TransmitStatusCode ON Cash.tbMirror (TransmitStatusCode, ChargeCode) ON [PRIMARY];
go
CREATE OR ALTER TRIGGER Cash_tbMirror_Trigger_Insert
ON Cash.tbMirror
FOR INSERT
AS
	SET NOCOUNT ON;

	BEGIN TRY

		UPDATE mirror
		SET TransmitStatusCode = org.TransmitStatusCode
		FROM Cash.tbMirror mirror 
			JOIN inserted ON mirror.AccountCode = inserted.AccountCode AND mirror.CashCode = inserted.CashCode
			JOIN Org.tbOrg org ON inserted.AccountCode = org.AccountCode;
	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
go
CREATE OR ALTER TRIGGER Cash_tbMirror_Trigger_Update
ON Cash.tbMirror
FOR UPDATE
AS
	SET NOCOUNT ON;

	BEGIN TRY
		IF NOT UPDATE(TransmitStatusCode)
		BEGIN
			UPDATE mirror
			SET 
				TransmitStatusCode = CASE WHEN org.TransmitStatusCode = 1 THEN 2 ELSE 0 END,
				UpdatedBy = SUSER_NAME(),
				UpdatedOn = CURRENT_TIMESTAMP
			FROM Cash.tbMirror mirror 
				JOIN inserted ON mirror.AccountCode = inserted.AccountCode AND mirror.CashCode = inserted.CashCode
				JOIN Org.tbOrg org ON inserted.AccountCode = org.AccountCode
			WHERE inserted.TransmitStatusCode <> 1;
		END
	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
go
CREATE TABLE Invoice.tbMirror (
	ContractAddress nvarchar(42) NOT NULL,
	AccountCode nvarchar(10) NOT NULL,
	InvoiceNumber nvarchar(50) NOT NULL,
	InvoiceTypeCode smallint NOT NULL,
	InvoiceStatusCode smallint NOT NULL,
	InvoicedOn datetime NOT NULL,
	DueOn datetime NOT NULL,
	UnitOfCharge nvarchar(5) NULL,
	InvoiceValue money NOT NULL,
	InvoiceTax money NOT NULL,
	PaidValue money NOT NULL CONSTRAINT DF_Invoice_tbMirror_PaidValue DEFAULT (0),
	PaidTaxValue money NOT NULL CONSTRAINT DF_Invoice_tbMirror_PaidTaxValue DEFAULT (0),
	PaymentTerms nvarchar(100) NULL,
	InsertedOn datetime NOT NULL CONSTRAINT DF_Invoice_tbMirror_InsertedOn DEFAULT (GETDATE()),
	RowVer timestamp NOT NULL,
	CONSTRAINT PK_Invoice_tbMirror PRIMARY KEY CLUSTERED (ContractAddress),
	CONSTRAINT FK_Invoice_tbMirror_tbOrg FOREIGN KEY (AccountCode) REFERENCES Org.tbOrg (AccountCode),
	CONSTRAINT FK_Invoice_tbMirror_tbType FOREIGN KEY (InvoiceTypeCode) REFERENCES Invoice.tbType (InvoiceTypeCode),
	CONSTRAINT FK_Invoice_tbMirror_tbStatus FOREIGN KEY (InvoiceStatusCode) REFERENCES Invoice.tbStatus (InvoiceStatusCode)
);
go
CREATE UNIQUE NONCLUSTERED INDEX IX_Invoice_tbMirror_InvoiceNumber ON Invoice.tbMirror (AccountCode, InvoiceNumber);
go
CREATE TABLE Invoice.tbMirrorReference (
	ContractAddress nvarchar(42) NOT NULL,
	InvoiceNumber nvarchar(20) NOT NULL
	CONSTRAINT PK_Invoice_tbMirrorReference PRIMARY KEY CLUSTERED (ContractAddress),
	CONSTRAINT FK_Invoice_tbMirrorReference_tbMirror FOREIGN KEY (ContractAddress) REFERENCES Invoice.tbMirror (ContractAddress) ON DELETE CASCADE,
	CONSTRAINT FK_Invoice_tbMirrorReference_tbInvoice FOREIGN KEY (InvoiceNumber) REFERENCES Invoice.tbInvoice (InvoiceNumber) ON DELETE CASCADE
);
go
CREATE UNIQUE NONCLUSTERED INDEX IX_Invoice_tbMirrorReference_InvoiceNumber ON Invoice.tbMirrorReference (InvoiceNumber) INCLUDE (ContractAddress); 
go
CREATE TABLE Invoice.tbMirrorTask (
	ContractAddress nvarchar(42) NOT NULL,
	TaskCode nvarchar(20) NOT NULL,
	Quantity decimal(18, 4) NOT NULL,
	InvoiceValue money NOT NULL,
	TaxValue money NOT NULL,
	TaxCode nvarchar(10) NULL,
	RowVer timestamp NULL,
	CONSTRAINT PK_Invoice_tbMirrorTask PRIMARY KEY CLUSTERED (ContractAddress, TaskCode),
	CONSTRAINT FK_Invoice_tbMirrorTask_ContractAddress FOREIGN KEY (ContractAddress) REFERENCES Invoice.tbMirror (ContractAddress) ON DELETE CASCADE
)
go
CREATE NONCLUSTERED INDEX IX_Invoice_tbMirrorTask_TaskCode ON Invoice.tbMirrorTask (TaskCode, ContractAddress);
go
CREATE TABLE Invoice.tbMirrorItem (
	ContractAddress nvarchar(42) NOT NULL,
	ChargeCode nvarchar(50) NOT NULL,
	ChargeDescription nvarchar(100) NULL,
	InvoiceValue money NOT NULL,
	TaxValue money NOT NULL,
	TaxCode nvarchar(10) NULL,
	RowVer timestamp NOT NULL,
	CONSTRAINT PK_Invoice_tbMirrorItem PRIMARY KEY CLUSTERED (ContractAddress, ChargeCode),
	CONSTRAINT FK_Invoice_tbMirrorItem_ContractAddress FOREIGN KEY (ContractAddress) REFERENCES Invoice.tbMirror (ContractAddress) ON DELETE CASCADE
)
go
CREATE NONCLUSTERED INDEX IX_Invoice_tbMirrorItem_InvoiceNumber ON Invoice.tbMirrorItem (ChargeCode, ContractAddress);
go
CREATE TABLE Invoice.tbMirrorEvent (
	ContractAddress nvarchar(42) NOT NULL,
	LogId int IDENTITY(1,1) NOT NULL,
	EventTypeCode smallint,	
	InvoiceStatusCode smallint,
	DueOn datetime NULL,
	PaidValue money NOT NULL CONSTRAINT DF_Invoice_tbMirrorEvent_PaidValue DEFAULT (0),
	PaidTaxValue money NOT NULL CONSTRAINT DF_Invoice_tbMirrorEvent_PaidTaxValue DEFAULT (0),
	InsertedOn datetime NOT NULL CONSTRAINT DF_Task_tbMirrorEvent_InsertedOn DEFAULT (GETDATE()),
	RowVer timestamp NOT NULL,
	CONSTRAINT PK_Invoice_tbMirrorEvent PRIMARY KEY CLUSTERED (ContractAddress, LogId),
	CONSTRAINT FK_Invoice_tbMirrorEvent_EventTypeCode FOREIGN KEY (EventTypeCode) REFERENCES App.tbEventType (EventTypeCode),
	CONSTRAINT FK_Invoice_tbMirrorEvent_ContractAddress FOREIGN KEY (ContractAddress) REFERENCES Invoice.tbMirror (ContractAddress)
);
go
CREATE UNIQUE NONCLUSTERED INDEX IX_Invoice_tbMirrorEvent_EventTypeCode ON Invoice.tbMirrorEvent (EventTypeCode, InvoiceStatusCode, InsertedOn)
go
DELETE FROM Invoice.tbChangeLog
FROM            Invoice.tbChangeLog LEFT OUTER JOIN
                         Invoice.tbInvoice ON Invoice.tbChangeLog.InvoiceNumber = Invoice.tbInvoice.InvoiceNumber
WHERE        (Invoice.tbInvoice.InvoiceNumber IS NULL);
go
ALTER TABLE Invoice.tbChangeLog DROP CONSTRAINT PK_Invoice_tbChangeLog WITH ( ONLINE = OFF )
go
DROP INDEX IX_Invoice_tbChangeLog_InvoiceCode ON Invoice.tbChangeLog;
go
ALTER TABLE Invoice.tbChangeLog ADD
	CONSTRAINT PK_Invoice_tbChangeLog PRIMARY KEY CLUSTERED (InvoiceNumber, LogId DESC),
	CONSTRAINT FK_Invoice_tbChangeLog_tbInvoice FOREIGN KEY(InvoiceNumber) REFERENCES Invoice.tbInvoice (InvoiceNumber) ON DELETE CASCADE;
go
CREATE UNIQUE NONCLUSTERED INDEX IX_Invoice_tbChangeLog_LogId ON Invoice.tbChangeLog (LogId DESC);
go
CREATE OR ALTER TRIGGER Invoice.Invoice_tbMirror_TriggerInsert
ON Invoice.tbMirror
FOR INSERT
AS
	SET NOCOUNT ON;

	BEGIN TRY
		INSERT INTO Invoice.tbMirrorEvent (ContractAddress, EventTypeCode, InvoiceStatusCode, DueOn, PaidValue, PaidTaxValue)
		SELECT ContractAddress, 2 EventTypeCode, InvoiceStatusCode, DueOn, PaidValue, PaidTaxValue
		FROM inserted;
	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
go
CREATE OR ALTER TRIGGER Invoice.Invoice_tbMirror_TriggerUpdate
ON Invoice.tbMirror
FOR UPDATE
AS
	SET NOCOUNT ON;

	BEGIN TRY

		IF UPDATE(InvoiceStatusCode)
		BEGIN
			INSERT INTO Invoice.tbMirrorEvent (ContractAddress, EventTypeCode, InvoiceStatusCode, DueOn, PaidValue, PaidTaxValue)
			SELECT i.ContractAddress, 6 EventTypeCode, i.InvoiceStatusCode, i.DueOn, i.PaidValue, i.PaidTaxValue
			FROM inserted i
				JOIN deleted d ON i.ContractAddress = d.ContractAddress
			WHERE d.InvoiceStatusCode <> i.InvoiceStatusCode;	
		END

		IF UPDATE(DueOn)
		BEGIN
			INSERT INTO Invoice.tbMirrorEvent (ContractAddress, EventTypeCode, InvoiceStatusCode, DueOn, PaidValue, PaidTaxValue)
			SELECT i.ContractAddress, 4 EventTypeCode, i.InvoiceStatusCode, i.DueOn, i.PaidValue, i.PaidTaxValue
			FROM inserted i
				JOIN deleted d ON i.ContractAddress = d.ContractAddress
			WHERE d.DueOn <> i.DueOn;
		END

		IF UPDATE(PaidValue) OR UPDATE(PaidTaxValue)
		BEGIN
			INSERT INTO Invoice.tbMirrorEvent (ContractAddress, EventTypeCode, InvoiceStatusCode, DueOn, PaidValue, PaidTaxValue)
			SELECT i.ContractAddress, 7 EventTypeCode, i.InvoiceStatusCode, i.DueOn, i.PaidValue, i.PaidTaxValue
			FROM inserted i
				JOIN deleted d ON i.ContractAddress = d.ContractAddress
			WHERE (d.PaidValue + d.PaidTaxValue) <> (i.PaidValue + i.PaidTaxValue);
		END

	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
go
CREATE OR ALTER TRIGGER Invoice.Invoice_tbMirrorTask_TriggerInsert
ON Invoice.tbMirrorTask
FOR INSERT
AS
	SET NOCOUNT ON;

	BEGIN TRY
		WITH deliveries AS
		(
			SELECT mirror.AccountCode, inserted.TaskCode, 
				CASE mirror.InvoiceTypeCode
					WHEN 0 THEN inserted.Quantity
					WHEN 1 THEN inserted.Quantity * -1
					WHEN 2 THEN inserted.Quantity
					WHEN 3 THEN inserted.Quantity * -1
					ELSE 0
				END QuantityDelivered
			FROM inserted
				JOIN Invoice.tbMirror mirror ON inserted.ContractAddress = mirror.ContractAddress
		)
		UPDATE allocs
		SET QuantityDelivered += deliveries.QuantityDelivered
		FROM Task.tbAllocation allocs
			JOIN deliveries ON allocs.AccountCode = deliveries.AccountCode AND allocs.TaskCode = deliveries.TaskCode;

	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
go
ALTER TRIGGER Invoice.Invoice_tbInvoice_TriggerInsert
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
		WHERE i.InvoiceTypeCode = 0;

		INSERT INTO Invoice.tbChangeLog
								 (InvoiceNumber, TransmitStatusCode, InvoiceStatusCode, DueOn, InvoiceValue, TaxValue)
		SELECT      inserted.InvoiceNumber, Org.tbOrg.TransmitStatusCode, inserted.InvoiceStatusCode, inserted.DueOn, inserted.InvoiceValue, inserted.TaxValue
		FROM            inserted INNER JOIN
								 Org.tbOrg ON inserted.AccountCode = Org.tbOrg.AccountCode
		WHERE InvoiceStatusCode > 0
								 
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
ALTER PROCEDURE Invoice.proc_Accept 
	(
	@InvoiceNumber nvarchar(20)
	)
AS
 	SET NOCOUNT, XACT_ABORT ON;

	BEGIN TRY
		IF EXISTS(SELECT     InvoiceNumber
	          FROM         Invoice.tbItem
	          WHERE     (InvoiceNumber = @InvoiceNumber)) 
		or EXISTS(SELECT     InvoiceNumber
	          FROM         Invoice.tbTask
	          WHERE     (InvoiceNumber = @InvoiceNumber))
		BEGIN
			BEGIN TRANSACTION
			
			EXEC Invoice.proc_Total @InvoiceNumber
			
			UPDATE    Invoice.tbInvoice
			SET              InvoiceStatusCode = 1
			WHERE     (InvoiceNumber = @InvoiceNumber) AND (InvoiceStatusCode = 0); 
	
			WITH task_codes AS
			(
				SELECT TaskCode
				FROM Invoice.tbTask 
				WHERE InvoiceNumber = @InvoiceNumber
				GROUP BY TaskCode
			), deliveries AS
			(
				SELECT invoices.TaskCode, SUM(Quantity) QuantityDelivered
				FROM Invoice.tbTask invoices JOIN task_codes ON invoices.TaskCode = task_codes.TaskCode
				GROUP BY invoices.TaskCode
			)
			UPDATE task
			SET TaskStatusCode = 3
			FROM Task.tbTask task JOIN deliveries ON task.TaskCode = deliveries.TaskCode
			WHERE Quantity <= QuantityDelivered;
			
			COMMIT TRANSACTION
		END
			
  	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
go
ALTER PROCEDURE Invoice.proc_Cancel
AS
  	SET NOCOUNT, XACT_ABORT ON;

	BEGIN TRY

		BEGIN TRAN

		UPDATE       Task
		SET                TaskStatusCode = 2
		FROM            Task.tbTask AS Task INNER JOIN
								 Invoice.tbTask AS InvoiceTask ON Task.TaskCode = InvoiceTask.TaskCode AND Task.TaskCode = InvoiceTask.TaskCode INNER JOIN
								 Invoice.tbInvoice ON InvoiceTask.InvoiceNumber = Invoice.tbInvoice.InvoiceNumber INNER JOIN
								 Usr.vwCredentials ON Invoice.tbInvoice.UserId = Usr.vwCredentials.UserId
		WHERE        (Invoice.tbInvoice.InvoiceTypeCode = 0 OR Invoice.tbInvoice.InvoiceTypeCode = 2) 
			AND (Invoice.tbInvoice.InvoiceStatusCode = 0) AND (Task.TaskStatusCode = 3)
	                      
		DELETE Invoice.tbInvoice
		FROM         Invoice.tbInvoice INNER JOIN
							  Usr.vwCredentials ON Invoice.tbInvoice.UserId = Usr.vwCredentials.UserId
		WHERE     ( Invoice.tbInvoice.InvoiceStatusCode = 0)
		
		COMMIT TRAN

  	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
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
				SUM(TaxValue) AS TaxValue,
				SUM(PaidValue) AS PaidValue, 
				SUM(PaidTaxValue) AS PaidTaxValue
			FROM         Invoice.tbTask
			GROUP BY InvoiceNumber
			HAVING      (InvoiceNumber = @InvoiceNumber)
			UNION
			SELECT InvoiceNumber, SUM(InvoiceValue) AS InvoiceValue, 
				SUM(TaxValue) AS TaxValue,
				SUM(PaidValue) AS PaidValue, 
				SUM(PaidTaxValue) AS PaidTaxValue
			FROM         Invoice.tbItem
			GROUP BY InvoiceNumber
			HAVING      (InvoiceNumber = @InvoiceNumber)
		), grand_total AS
		(
			SELECT InvoiceNumber, ISNULL(SUM(InvoiceValue), 0) AS InvoiceValue, 
				ISNULL(SUM(TaxValue), 0) AS TaxValue, 
				ISNULL(SUM(PaidValue), 0) AS PaidValue, 
				ISNULL(SUM(PaidTaxValue), 0) AS PaidTaxValue
			FROM totals
			GROUP BY InvoiceNumber
		) 
		UPDATE    Invoice.tbInvoice
		SET InvoiceValue = grand_total.InvoiceValue, TaxValue = grand_total.TaxValue,
			PaidValue = grand_total.PaidValue, PaidTaxValue = grand_total.PaidTaxValue,
			InvoiceStatusCode = CASE 
					WHEN grand_total.PaidValue >= grand_total.InvoiceValue THEN 3 
					WHEN grand_total.PaidValue > 0 THEN 2 
					ELSE InvoiceStatusCode END
		FROM Invoice.tbInvoice INNER JOIN grand_total ON Invoice.tbInvoice.InvoiceNumber = grand_total.InvoiceNumber;
		
  	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
go
CREATE OR ALTER VIEW Invoice.vwNetworkDeployments
AS
	SELECT Invoice.tbInvoice.InvoiceNumber, Invoice.tbInvoice.AccountCode, 
		Invoice.tbType.CashModeCode AS PaymentPolarity, 
		CASE Invoice.tbType.InvoiceTypeCode 
			WHEN 0 THEN Invoice.tbType.CashModeCode 
			WHEN 1 THEN 1
			WHEN 2 THEN Invoice.tbType.CashModeCode 
			WHEN 3 THEN 0
		END InvoicePolarity, 
		Invoice.tbInvoice.InvoiceStatusCode,
		Invoice.tbInvoice.DueOn, Invoice.tbInvoice.InvoicedOn, Invoice.tbInvoice.InvoiceValue, Invoice.tbInvoice.TaxValue, 
		Invoice.tbInvoice.PaymentTerms, (SELECT TOP 1 UnitOfCharge FROM App.tbOptions) UnitOfCharge,
		Invoice.tbMirrorReference.ContractAddress,
		Invoice.tbMirror.InvoiceNumber ContractNumber
	FROM            Invoice.tbMirrorReference RIGHT OUTER JOIN
							 Invoice.tbChangeLog INNER JOIN
							 Invoice.tbInvoice ON Invoice.tbChangeLog.InvoiceNumber = Invoice.tbInvoice.InvoiceNumber INNER JOIN
							 Invoice.tbType ON Invoice.tbInvoice.InvoiceTypeCode = Invoice.tbType.InvoiceTypeCode ON Invoice.tbMirrorReference.InvoiceNumber = Invoice.tbInvoice.InvoiceNumber LEFT OUTER JOIN
							 Invoice.tbMirror ON Invoice.tbMirrorReference.ContractAddress = Invoice.tbMirror.ContractAddress AND Invoice.tbMirrorReference.ContractAddress = Invoice.tbMirror.ContractAddress
	WHERE        (Invoice.tbChangeLog.TransmitStatusCode = 1)
go
CREATE OR ALTER VIEW Invoice.vwNetworkDeploymentItems
AS
	SELECT Invoice.tbItem.InvoiceNumber, Invoice.tbItem.CashCode ChargeCode, 
		CASE WHEN LEN(COALESCE(CAST(Invoice.tbItem.ItemReference AS NVARCHAR), '')) > 0 THEN Invoice.tbItem.ItemReference ELSE Cash.tbCode.CashDescription END ChargeDescription, 
			Invoice.tbItem.InvoiceValue, Invoice.tbItem.TaxValue, 0 AS InvoiceQuantity, Invoice.tbItem.PaidValue, Invoice.tbItem.PaidTaxValue, Invoice.tbItem.TaxCode
	FROM  Invoice.tbItem 
		INNER JOIN Cash.tbCode ON Invoice.tbItem.CashCode = Cash.tbCode.CashCode;
go
CREATE OR ALTER VIEW Invoice.vwNetworkUpdates
AS
	WITH updates AS
	(
		SELECT DISTINCT InvoiceNumber FROM Invoice.tbChangeLog 
		WHERE TransmitStatusCode = 2
		EXCEPT
		SELECT DISTINCT InvoiceNumber FROM Invoice.tbChangeLog 
		WHERE TransmitStatusCode = 1
	)
	SELECT Invoice.tbInvoice.InvoiceNumber, Invoice.tbInvoice.AccountCode, Invoice.tbInvoice.InvoiceStatusCode,
			Invoice.tbInvoice.DueOn, Invoice.tbInvoice.PaidValue, Invoice.tbInvoice.PaidTaxValue
	FROM updates 
		JOIN Invoice.tbInvoice ON updates.InvoiceNumber = Invoice.tbInvoice.InvoiceNumber 
		JOIN Invoice.tbType ON Invoice.tbInvoice.InvoiceTypeCode = Invoice.tbType.InvoiceTypeCode
go
CREATE OR ALTER VIEW Invoice.vwNetworkChangeLog
AS
	SELECT  Invoice.tbChangeLog.LogId, Invoice.tbInvoice.AccountCode, Org.tbOrg.AccountName, Invoice.tbInvoice.InvoiceNumber, Invoice.tbInvoice.InvoiceTypeCode, Invoice.tbType.InvoiceType, Invoice.tbInvoice.InvoiceStatusCode, Invoice.tbStatus.InvoiceStatus, 
							 Invoice.tbChangeLog.TransmitStatusCode, Org.tbTransmitStatus.TransmitStatus, Invoice.tbType.CashModeCode, Cash.tbMode.CashMode, Invoice.tbChangeLog.DueOn, Invoice.tbChangeLog.InvoiceValue, 
							 Invoice.tbChangeLog.TaxValue, Invoice.tbChangeLog.PaidValue, Invoice.tbChangeLog.PaidTaxValue, Invoice.tbChangeLog.UpdatedBy, Invoice.tbChangeLog.ChangedOn, Invoice.tbChangeLog.RowVer
	FROM  Invoice.tbChangeLog 
		INNER JOIN Invoice.tbInvoice ON Invoice.tbChangeLog.InvoiceNumber = Invoice.tbInvoice.InvoiceNumber 
		INNER JOIN Invoice.tbType ON Invoice.tbInvoice.InvoiceTypeCode = Invoice.tbType.InvoiceTypeCode 
		INNER JOIN Cash.tbMode ON Invoice.tbType.CashModeCode = Cash.tbMode.CashModeCode 
		INNER JOIN Invoice.tbStatus ON Invoice.tbChangeLog.InvoiceStatusCode = Invoice.tbStatus.InvoiceStatusCode 
		INNER JOIN Org.tbOrg ON Invoice.tbInvoice.AccountCode = Org.tbOrg.AccountCode AND Invoice.tbInvoice.AccountCode = Org.tbOrg.AccountCode 
		INNER JOIN Org.tbTransmitStatus ON Invoice.tbChangeLog.TransmitStatusCode = Org.tbTransmitStatus.TransmitStatusCode;
go
CREATE OR ALTER VIEW Cash.vwNetworkMirrors
AS
	SELECT AccountCode, CashCode, ChargeCode, TransmitStatusCode FROM Cash.tbMirror WHERE TransmitStatusCode BETWEEN 1 AND 2;
go
ALTER   VIEW Invoice.vwChangeLog
AS
	SELECT LogId, InvoiceNumber, ChangedOn, changelog.TransmitStatusCode, transmit.TransmitStatus, changelog.InvoiceStatusCode, invoicestatus.InvoiceStatus, DueOn, InvoiceValue, TaxValue, PaidValue, PaidTaxValue, UpdatedBy
	FROM Invoice.tbChangeLog changelog
		JOIN Org.tbTransmitStatus transmit ON changelog.TransmitStatusCode = transmit.TransmitStatusCode
		JOIN Invoice.tbStatus invoicestatus ON changelog.InvoiceStatusCode = invoicestatus.InvoiceStatusCode;
go
CREATE OR ALTER PROCEDURE Cash.proc_Mirror(@CashCode nvarchar(50), @AccountCode nvarchar(10), @ChargeCode nvarchar(50))
AS
	SET NOCOUNT, XACT_ABORT ON;

	BEGIN TRY
		IF NOT EXISTS (SELECT * FROM Cash.tbMirror WHERE CashCode = @CashCode AND AccountCode = @AccountCode AND ChargeCode = @ChargeCode)
		BEGIN
			INSERT INTO Cash.tbMirror (CashCode, AccountCode, ChargeCode)
			VALUES (@CashCode, @AccountCode, @ChargeCode);
		END
	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
go

CREATE OR ALTER PROCEDURE Cash.proc_NetworkUpdated(@AccountCode nvarchar(10), @ChargeCode nvarchar(50))
AS
	SET NOCOUNT, XACT_ABORT ON;

	BEGIN TRY
		UPDATE Cash.tbMirror
		SET TransmitStatusCode = 3
		WHERE AccountCode = @AccountCode AND ChargeCode = @ChargeCode;
	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
go
CREATE OR ALTER PROCEDURE Invoice.proc_NetworkUpdated (@InvoiceNumber nvarchar(20))
AS
	SET NOCOUNT, XACT_ABORT ON;

	BEGIN TRY

		UPDATE Invoice.tbChangeLog
		SET TransmitStatusCode = 3
		WHERE InvoiceNumber = @InvoiceNumber AND TransmitStatusCode < 3;

	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
go

CREATE OR ALTER VIEW Cash.vwUnMirrored
AS
	WITH charge_codes AS
	(
		SELECT DISTINCT Invoice.tbMirror.AccountCode, Invoice.tbMirrorItem.ChargeCode, Org.tbOrg.AccountName, Invoice.tbMirrorItem.ChargeDescription, Invoice.tbType.CashModeCode, Cash.tbMode.CashMode, 
			Invoice.tbMirrorItem.TaxCode, ROUND(Invoice.tbMirrorItem.TaxValue / Invoice.tbMirrorItem.InvoiceValue, 3) AS TaxRate
		FROM            Invoice.tbMirrorItem INNER JOIN
								 Invoice.tbMirror ON Invoice.tbMirrorItem.ContractAddress = Invoice.tbMirror.ContractAddress INNER JOIN
								 Org.tbOrg ON Invoice.tbMirror.AccountCode = Org.tbOrg.AccountCode INNER JOIN
								 Invoice.tbType ON Invoice.tbMirror.InvoiceTypeCode = Invoice.tbType.InvoiceTypeCode INNER JOIN
								 Cash.tbMode ON Invoice.tbType.CashModeCode = Cash.tbMode.CashModeCode AND Invoice.tbType.CashModeCode = Cash.tbMode.CashModeCode
		WHERE        (Invoice.tbMirror.InvoiceTypeCode = 0) OR
								 (Invoice.tbMirror.InvoiceTypeCode = 2)
	)
	SELECT CAST(ROW_NUMBER() OVER (ORDER BY charge_codes.AccountCode, charge_codes.ChargeCode) AS int) CandidateId, charge_codes.*
	FROM charge_codes 
		LEFT OUTER JOIN Cash.tbMirror mirror ON charge_codes.AccountCode = mirror.AccountCode AND charge_codes.ChargeCode = mirror.ChargeCode
	WHERE mirror.ChargeCode IS NULL;
go
CREATE OR ALTER VIEW Invoice.vwMirrorDetails
AS
	SELECT invoice_task.ContractAddress, invoice_task.TaskCode DetailRef, mirror.ActivityCode DetailCode, alloc.AllocationDescription DetailDescription,
		invoice_task.Quantity, invoice_task.InvoiceValue, invoice_task.TaxValue, invoice_task.TaxCode, invoice_task.RowVer 
	FROM Invoice.tbMirrorTask invoice_task
		JOIN Invoice.tbMirror invoice ON invoice.ContractAddress = invoice_task.ContractAddress
		JOIN Task.tbAllocation alloc ON alloc.AccountCode = invoice.AccountCode AND alloc.TaskCode = invoice_task.TaskCode
		JOIN Activity.tbMirror mirror ON alloc.AccountCode = mirror.AccountCode AND alloc.AllocationCode = mirror.AllocationCode
	UNION
	SELECT invoice_item.ContractAddress, invoice_item.ChargeCode DetailRef, mirror.CashCode DetailCode, invoice_item.ChargeDescription DetailDescription,
		0 Quantity, invoice_item.InvoiceValue, invoice_item.TaxValue, invoice_item.TaxCode, invoice_item.RowVer
	FROM Invoice.tbMirrorItem invoice_item
		JOIN Invoice.tbMirror invoice ON invoice.ContractAddress = invoice_item.ContractAddress
		JOIN Cash.tbMirror mirror ON invoice_item.ChargeCode = mirror.ChargeCode AND invoice.AccountCode = mirror.AccountCode;
go
CREATE OR ALTER VIEW Invoice.vwMirrors
AS
	SELECT        Invoice.tbMirror.ContractAddress, Invoice.tbMirror.AccountCode, Org.tbOrg.AccountName, 
					CASE WHEN tbMirrorReference.ContractAddress IS NULL THEN CAST(0 AS BIT) ELSE CAST(1 AS BIT) END AS IsMirrored, 
							 Invoice.tbMirrorReference.InvoiceNumber, Invoice.tbMirror.InvoiceNumber AS MirrorNumber, Invoice.tbMirror.InvoiceTypeCode, Invoice.tbType.InvoiceType, Invoice.tbType.CashModeCode, 
							 Invoice.tbMirror.InvoiceStatusCode, Invoice.tbStatus.InvoiceStatus, Invoice.tbMirror.InvoicedOn, Invoice.tbMirror.DueOn, Invoice.tbMirror.UnitOfCharge, Invoice.tbMirror.InvoiceValue, Invoice.tbMirror.InvoiceTax, 
							 Invoice.tbMirror.PaidValue, Invoice.tbMirror.PaidTaxValue, Invoice.tbMirror.PaymentTerms, Invoice.tbMirror.InsertedOn, Invoice.tbMirror.RowVer
	FROM            Invoice.tbMirror INNER JOIN
							 Invoice.tbType ON Invoice.tbMirror.InvoiceTypeCode = Invoice.tbType.InvoiceTypeCode INNER JOIN
							 Invoice.tbStatus ON Invoice.tbMirror.InvoiceStatusCode = Invoice.tbStatus.InvoiceStatusCode INNER JOIN
							 Org.tbOrg ON Invoice.tbMirror.AccountCode = Org.tbOrg.AccountCode LEFT OUTER JOIN
							 Invoice.tbMirrorReference ON Invoice.tbMirror.ContractAddress = Invoice.tbMirrorReference.ContractAddress
go
CREATE OR ALTER VIEW Invoice.vwMirrorEvents
AS
	SELECT        Invoice.tbMirrorEvent.ContractAddress, Invoice.tbMirror.AccountCode, Org.tbOrg.AccountName, Invoice.tbMirror.InvoiceNumber, Invoice.tbMirrorEvent.LogId, Invoice.tbMirrorEvent.EventTypeCode, App.tbEventType.EventType, 
							 Invoice.tbMirrorEvent.InvoiceStatusCode, Invoice.tbStatus.InvoiceStatus, Invoice.tbMirrorEvent.DueOn, Invoice.tbMirrorEvent.PaidValue, Invoice.tbMirrorEvent.PaidTaxValue, Invoice.tbMirrorEvent.InsertedOn, 
							 Invoice.tbMirrorEvent.RowVer
	FROM            Invoice.tbMirrorEvent INNER JOIN
							 Invoice.tbMirror ON Invoice.tbMirrorEvent.ContractAddress = Invoice.tbMirror.ContractAddress INNER JOIN
							 Invoice.tbType ON Invoice.tbMirror.InvoiceTypeCode = Invoice.tbType.InvoiceTypeCode INNER JOIN
							 App.tbEventType ON Invoice.tbMirrorEvent.EventTypeCode = App.tbEventType.EventTypeCode INNER JOIN
							 Invoice.tbStatus ON Invoice.tbMirrorEvent.InvoiceStatusCode = Invoice.tbStatus.InvoiceStatusCode INNER JOIN
							 Org.tbOrg ON Invoice.tbMirror.AccountCode = Org.tbOrg.AccountCode AND Invoice.tbMirror.AccountCode = Org.tbOrg.AccountCode AND Invoice.tbMirror.AccountCode = Org.tbOrg.AccountCode AND 
							 Invoice.tbMirror.AccountCode = Org.tbOrg.AccountCode AND Invoice.tbMirror.AccountCode = Org.tbOrg.AccountCode AND Invoice.tbMirror.AccountCode = Org.tbOrg.AccountCode;
go
CREATE OR ALTER PROCEDURE Invoice.proc_Mirror(@ContractAddress nvarchar(42), @InvoiceNumber nvarchar(20) OUTPUT)
AS
 	SET NOCOUNT, XACT_ABORT ON;

	BEGIN TRY
	DECLARE 
		@UserId nvarchar(10)
		, @NextNumber int
		, @InvoiceSuffix nvarchar(4)
		, @AccountCode nvarchar(10)
		, @InvoiceTypeCode smallint
	
		SELECT @UserId = UserId FROM Usr.vwCredentials
		SET @InvoiceSuffix = '.' + @UserId

		SELECT 
			@InvoiceTypeCode = CASE InvoiceTypeCode 
								WHEN 0 THEN 2
								WHEN 1 THEN 3
								WHEN 2 THEN 0
								WHEN 3 THEN 1
							END
		FROM Invoice.tbMirror
		WHERE ContractAddress = @ContractAddress
	
		SELECT @NextNumber = NextNumber
		FROM Invoice.tbType
		WHERE InvoiceTypeCode = @InvoiceTypeCode
	
		SELECT @InvoiceNumber = FORMAT(@NextNumber, '000000') + @InvoiceSuffix
	
		WHILE EXISTS (SELECT     InvoiceNumber
						FROM         Invoice.tbInvoice
						WHERE     (InvoiceNumber = @InvoiceNumber))
			BEGIN
			SET @NextNumber = @NextNumber + 1
			SET @InvoiceNumber = FORMAT(@NextNumber, '000000') + @InvoiceSuffix
			END

		BEGIN TRAN

		UPDATE    Invoice.tbType
		SET              NextNumber = @NextNumber + 1
		WHERE     (InvoiceTypeCode = @InvoiceTypeCode)
	
		INSERT INTO Invoice.tbInvoice
							(InvoiceNumber, UserId, AccountCode, InvoiceTypeCode, InvoicedOn, DueOn, ExpectedOn, InvoiceStatusCode, PaymentTerms)
		SELECT     @InvoiceNumber AS InvoiceNumber, @UserId AS UserId, mirror.AccountCode, 
				@InvoiceTypeCode AS InvoiceTypeCode, CAST(mirror.InvoicedOn AS DATE) AS InvoicedOn, mirror.DueOn, mirror.DueOn ExpectedOn, 0 AS InvoiceStatusCode, 
				CASE WHEN Org.tbOrg.PaymentTerms IS NULL THEN mirror.PaymentTerms ELSE Org.tbOrg.PaymentTerms END PaymentTerms
		FROM Invoice.tbMirror mirror
			JOIN Org.tbOrg ON mirror.AccountCode = Org.tbOrg.AccountCode
		WHERE ContractAddress = @ContractAddress;

		INSERT INTO Invoice.tbMirrorReference (ContractAddress, InvoiceNumber)
		VALUES (@ContractAddress, @InvoiceNumber);

		WITH allocations AS
		(
			SELECT 0 Allocationid, 
				allocation.TaskCode,
				activity_mirror.ActivityCode, allocation.AccountCode, 
					CASE allocation.CashModeCode 
						WHEN 0 THEN task_mirror.Quantity * -1
						WHEN 1 THEN task_mirror.Quantity
					END Quantity, allocation.CashModeCode
			FROM Invoice.tbMirror invoice_mirror
				JOIN Invoice.tbMirrorTask task_mirror ON invoice_mirror.ContractAddress = task_mirror.ContractAddress
				JOIN Task.tbAllocation allocation ON invoice_mirror.AccountCode = allocation.AccountCode AND task_mirror.TaskCode = allocation.TaskCode			
				JOIN Activity.tbMirror activity_mirror ON invoice_mirror.AccountCode = activity_mirror.AccountCode AND allocation.AllocationCode = activity_mirror.AllocationCode
			WHERE invoice_mirror.ContractAddress = @ContractAddress
		), tasks AS
		(
			SELECT ROW_NUMBER() OVER (PARTITION BY tasks.AccountCode, tasks.ActivityCode ORDER BY ActionOn) Allocationid,
				tasks.TaskCode, tasks.ActivityCode, tasks.AccountCode, tasks.Quantity, category.CashModeCode
			FROM allocations
				JOIN Task.tbTask tasks ON tasks.ActivityCode = allocations.ActivityCode AND tasks.AccountCode = allocations.AccountCode
				JOIN Cash.tbCode cash_code ON tasks.CashCode = cash_code.CashCode
				JOIN Cash.tbCategory category ON cash_code.CategoryCode = category.CategoryCode
			WHERE tasks.TaskStatusCode BETWEEN 1 AND 2
		), order_book AS
		(
			SELECT tasks.TaskCode, SUM(COALESCE(invoice_quantity.Quantity, 0)) InvoiceQuantity
			FROM tasks
				OUTER APPLY 
					(
						SELECT CASE invoice.InvoiceTypeCode 
									WHEN 1 THEN delivery.Quantity * -1 
									WHEN 3 THEN delivery.Quantity * -1 
									ELSE delivery.Quantity 
								END Quantity
						FROM Invoice.tbTask delivery 
							JOIN Invoice.tbInvoice invoice ON delivery.InvoiceNumber = invoice.InvoiceNumber
						WHERE delivery.TaskCode = tasks.TaskCode
					) invoice_quantity
			GROUP BY tasks.TaskCode
		), deliveries AS
		(
			SELECT Allocationid, tasks.TaskCode, ActivityCode, AccountCode,
						CASE CashModeCode 
							WHEN 0 THEN (tasks.Quantity - order_book.InvoiceQuantity) * -1
							WHEN 1 THEN tasks.Quantity - order_book.InvoiceQuantity
						END Quantity, CashModeCode		
			FROM tasks
				JOIN order_book ON tasks.TaskCode = order_book.TaskCode
		), svd_union AS
		(
			SELECT * FROM deliveries
			UNION 
			SELECT * FROM allocations
		), svd_projected AS
		(
			SELECT *,
				SUM(Quantity) OVER (PARTITION BY AccountCode, ActivityCode  ORDER BY AllocationId ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS Balance
			FROM svd_union
		), svd_balance AS
		(
			SELECT *, LAG(Balance) OVER (PARTITION BY AccountCode, ActivityCode  ORDER BY AllocationId) PreviousBalance
			FROM svd_projected
		), alloc_deliveries AS
		(
			SELECT *, 
					CASE CashModeCode 
						WHEN 0 THEN
							CASE WHEN Balance > 0 THEN ABS(Quantity) 
								WHEN PreviousBalance > 0 THEN PreviousBalance
								ELSE 0
							END 
						WHEN 1 THEN
							CASE WHEN Balance < 0 THEN Quantity
								WHEN PreviousBalance < 0 THEN ABS(PreviousBalance)
								ELSE 0
							END 
					END QuantityDelivered
			FROM svd_balance
		)
		INSERT INTO Invoice.tbTask (InvoiceNumber, TaskCode, Quantity, InvoiceValue, CashCode, TaxCode)
		SELECT @InvoiceNumber InvoiceNumber, alloc_deliveries.TaskCode, alloc_deliveries.QuantityDelivered, task.UnitCharge * alloc_deliveries.QuantityDelivered, task.CashCode, task.TaxCode 
		FROM alloc_deliveries
			JOIN Task.tbTask task ON alloc_deliveries.TaskCode = task.TaskCode
		WHERE QuantityDelivered > 0;

		INSERT INTO Invoice.tbItem (InvoiceNumber, CashCode, TaxCode, InvoiceValue, ItemReference)
		SELECT @InvoiceNumber InvoiceNumber, cash_code_mirror.CashCode, 
			CASE WHEN (item_mirror.TaxValue / item_mirror.InvoiceValue) <> tax_code.TaxRate 
				THEN (SELECT TOP 1 TaxCode FROM App.tbTaxCode WHERE TaxTypeCode = 1 AND ROUND(TaxRate, 3) =  ROUND((item_mirror.TaxValue / item_mirror.InvoiceValue), 3))
				ELSE tax_code.TaxCode 
				END TaxCode,
				item_mirror.InvoiceValue, item_mirror.ChargeDescription ItemReference
		FROM Invoice.tbMirror invoice_mirror 
			JOIN Invoice.tbMirrorItem item_mirror ON invoice_mirror.ContractAddress = item_mirror.ContractAddress			
			JOIN Cash.tbMirror cash_code_mirror ON item_mirror.ChargeCode = cash_code_mirror.ChargeCode and invoice_mirror.AccountCode = cash_code_mirror.AccountCode
			JOIN Cash.tbCode cash_code ON cash_code_mirror.CashCode = cash_code.CashCode
			JOIN App.tbTaxCode tax_code ON cash_code.TaxCode = tax_code.TaxCode
		WHERE invoice_mirror.ContractAddress = @ContractAddress

		EXEC Invoice.proc_Total @InvoiceNumber	

		COMMIT TRAN

  	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
go
ALTER VIEW Invoice.vwRegisterTasks
AS
	SELECT       (SELECT TOP (1) p.StartOn FROM App.tbYearPeriod p WHERE (p.StartOn <= Invoice.tbInvoice.InvoicedOn) ORDER BY p.StartOn DESC) AS StartOn,  
			Invoice.tbInvoice.InvoiceNumber, InvoiceTask.TaskCode, Task.TaskTitle, Cash.tbCode.CashCode, Cash.tbCode.CashDescription, 
							 InvoiceTask.TaxCode, App.tbTaxCode.TaxDescription, Invoice.tbInvoice.AccountCode, Invoice.tbInvoice.InvoiceTypeCode, Invoice.tbInvoice.InvoiceStatusCode, 
							 Invoice.tbInvoice.InvoicedOn, InvoiceTask.Quantity,
							 CASE WHEN Invoice.tbType.CashModeCode = 0 THEN InvoiceTask.InvoiceValue * - 1 ELSE InvoiceTask.InvoiceValue END AS InvoiceValue, 
							 CASE WHEN Invoice.tbType.CashModeCode = 0 THEN InvoiceTask.TaxValue * - 1 ELSE InvoiceTask.TaxValue END AS TaxValue, 
							 CASE WHEN Invoice.tbType.CashModeCode = 0 THEN InvoiceTask.PaidValue * - 1 ELSE InvoiceTask.PaidValue END AS PaidValue, 
							 CASE WHEN Invoice.tbType.CashModeCode = 0 THEN InvoiceTask.PaidTaxValue * - 1 ELSE InvoiceTask.PaidTaxValue END AS PaidTaxValue, Invoice.tbInvoice.PaymentTerms, Invoice.tbInvoice.Printed, 
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
							  InvoicedOn, Quantity, InvoiceValue, TaxValue, PaidValue, PaidTaxValue, PaymentTerms, Printed, AccountName, UserName, InvoiceStatus, CashModeCode, 
							  InvoiceType
		FROM         Invoice.vwRegisterTasks
		UNION
		SELECT     StartOn, InvoiceNumber, TaskCode, CashCode, CashDescription, TaxCode, TaxDescription, AccountCode, InvoiceTypeCode, InvoiceStatusCode, 
							  InvoicedOn, 0 Quantity, InvoiceValue, TaxValue, PaidValue, PaidTaxValue, PaymentTerms, Printed, AccountName, UserName, InvoiceStatus, CashModeCode, 
							  InvoiceType
		FROM         Invoice.vwRegisterItems
	)
	SELECT *, (InvoiceValue)+TaxValue-(PaidValue+PaidTaxValue) AS UnpaidValue FROM register;
go
/******************* Installation **************************************************/
go
ALTER PROCEDURE Usr.proc_AddUser
(
	@UserName NVARCHAR(25), 
	@FullName NVARCHAR(100),
	@HomeAddress NVARCHAR(MAX),
	@EmailAddress NVARCHAR(255),
	@MobileNumber NVARCHAR(50),
	@CalendarCode NVARCHAR(10),
	@IsAdministrator BIT = 0
)
AS

	DECLARE @SQL NVARCHAR(MAX);
	DECLARE @ObjectName NVARCHAR(100);

	SET @SQL = CONCAT('CREATE USER [', @UserName, '] FOR LOGIN [', @UserName, '] WITH DEFAULT_SCHEMA=[dbo];');
	EXECUTE sys.sp_executesql @stmt = @SQL;

	SET @SQL = CONCAT('ALTER ROLE [db_datareader] ADD MEMBER [', @UserName, '];');
	EXECUTE sys.sp_executesql @stmt = @SQL;
	SET @SQL = CONCAT('ALTER ROLE [db_datawriter] ADD MEMBER [', @UserName, '];');
	EXECUTE sys.sp_executesql @stmt = @SQL;

	--Register with client
	DECLARE @UserId NVARCHAR(10) = CONCAT(LEFT(@FullName, 1), SUBSTRING(@FullName, CHARINDEX(' ', @FullName) + 1, 1)); 

	INSERT INTO Usr.tbUser (UserId, UserName, LogonName, IsAdministrator, IsEnabled, CalendarCode, EmailAddress, MobileNumber, [Address])
	VALUES (@UserId, @FullName, @UserName, @IsAdministrator, 1, @CalendarCode, @EmailAddress, @MobileNumber, @HomeAddress)

	INSERT INTO Usr.tbMenuUser (UserId, MenuId)
	SELECT @UserId AS UserId, (SELECT MenuId FROM Usr.tbMenu) AS MenuId;

	--protect system tables
	DECLARE tbs CURSOR FOR
		WITH tbnames AS
		(
			SELECT SCHEMA_NAME(schema_id) AS SchemaName, CONCAT(SCHEMA_NAME(schema_id), '.', [name]) AS TableName
			FROM sys.tables
			WHERE type = 'U' AND SCHEMA_NAME(schema_id) <> 'dbo' 
		)
		SELECT TableName
		FROM tbnames
		WHERE (TableName like '%Status%' or TableName like '%Type%')
			OR (TableName = 'App.tbDocClass')
			OR (TableName = 'App.tbEventLog')
			OR (TableName = 'App.tbInstall')
			OR (TableName = 'App.tbRecurrence')
			OR (TableName = 'App.tbRounding')
			OR (TableName = 'App.tbText')
			OR (TableName = 'Cash.tbMode')
			OR (TableName = 'App.tbEth');

		OPEN tbs
		FETCH NEXT FROM tbs INTO @ObjectName
		WHILE @@FETCH_STATUS = 0
		BEGIN
			SET @SQL = CONCAT('DENY DELETE ON ', DB_NAME(), '.', @ObjectName, ' TO [', @UserName, ']')
			EXECUTE sys.sp_executesql @stmt = @SQL
			SET @SQL = CONCAT('DENY INSERT ON ', DB_NAME(), '.', @ObjectName, ' TO [', @UserName, ']')
			EXECUTE sys.sp_executesql @stmt = @SQL
			SET @SQL = CONCAT('DENY UPDATE ON ', DB_NAME(), '.', @ObjectName, ' TO [', @UserName, ']')
			EXECUTE sys.sp_executesql @stmt = @SQL
			SET @SQL = CONCAT('GRANT SELECT ON ', DB_NAME(), '.', @ObjectName, ' TO [', @UserName, ']')
			EXECUTE sys.sp_executesql @stmt = @SQL
			 
			FETCH NEXT FROM tbs INTO @ObjectName
		END
		CLOSE tbs
		DEALLOCATE tbs

	--Deny non-administrators insert, delete and update permission on Usr schema tables
	IF @IsAdministrator = 0
	BEGIN
		DECLARE tbs CURSOR FOR
			WITH tbnames AS
			(
				SELECT SCHEMA_NAME(schema_id) AS SchemaName, CONCAT(SCHEMA_NAME(schema_id), '.', [name]) AS TableName
				FROM sys.tables
				WHERE type = 'U' AND SCHEMA_NAME(schema_id) <> 'dbo' 
			)
			SELECT TableName
			FROM tbnames
			WHERE (SchemaName = 'Usr');

			OPEN tbs
			FETCH NEXT FROM tbs INTO @ObjectName
			WHILE @@FETCH_STATUS = 0
			BEGIN
				SET @SQL = CONCAT('DENY DELETE ON ', DB_NAME(), '.', @ObjectName, ' TO [', @UserName, ']')
				EXECUTE sys.sp_executesql @stmt = @SQL
				SET @SQL = CONCAT('DENY INSERT ON ', DB_NAME(), '.', @ObjectName, ' TO [', @UserName, ']')
				EXECUTE sys.sp_executesql @stmt = @SQL
				SET @SQL = CONCAT('DENY UPDATE ON ', DB_NAME(), '.', @ObjectName, ' TO [', @UserName, ']')
				EXECUTE sys.sp_executesql @stmt = @SQL
				SET @SQL = CONCAT('GRANT SELECT ON ', DB_NAME(), '.', @ObjectName, ' TO [', @UserName, ']')
				EXECUTE sys.sp_executesql @stmt = @SQL
			 
				FETCH NEXT FROM tbs INTO @ObjectName
			END
			CLOSE tbs
			DEALLOCATE tbs
	END

	--Assign full read/write/execute permissions
	DECLARE procs CURSOR FOR
		SELECT CONCAT(SCHEMA_NAME([schema_id]), '.', name) AS proc_name
		FROM sys.procedures;
	
		OPEN procs
		FETCH NEXT FROM procs INTO @ObjectName
		WHILE @@FETCH_STATUS = 0
		BEGIN
			SET @SQL = CONCAT('GRANT EXECUTE ON ', DB_NAME(), '.', @ObjectName, ' TO [', @UserName, '];');
			EXECUTE sys.sp_executesql @stmt = @SQL 
			FETCH NEXT FROM procs INTO @ObjectName
		END
		CLOSE procs
		DEALLOCATE procs

	DECLARE funcs CURSOR FOR
		SELECT CONCAT(SCHEMA_NAME([schema_id]), '.', name), type 
		FROM sys.objects where type IN ('TF', 'IF', 'FN');

	DECLARE @Type CHAR(2);

		OPEN funcs
		FETCH NEXT FROM funcs INTO @ObjectName, @Type
		WHILE @@FETCH_STATUS = 0
		BEGIN
			IF @Type = 'FN'
				SET @SQL = CONCAT('GRANT EXECUTE ON ', DB_NAME(), '.', @ObjectName, ' TO [', @UserName, '];');
			ELSE
				SET @SQL = CONCAT('GRANT SELECT ON ', DB_NAME(), '.', @ObjectName, ' TO [', @UserName, '];');

			EXECUTE sys.sp_executesql @stmt = @SQL 

			FETCH NEXT FROM funcs INTO @ObjectName, @Type
		END
		CLOSE funcs
		DEALLOCATE funcs
go
ALTER PROCEDURE App.proc_BasicSetup
(	
	@FinancialMonth SMALLINT = 4,
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
DECLARE @FinancialYear SMALLINT;

	SET @FinancialYear = DATEPART(YEAR, CURRENT_TIMESTAMP);
	IF DATEPART(MONTH, CURRENT_TIMESTAMP) < @FinancialMonth
		 SET @FinancialYear -= 1;

	DECLARE 
		@AccountCode NVARCHAR(10),
		@CashAccountCode NVARCHAR(10),
		@Year SMALLINT = @FinancialYear;

	SET NOCOUNT, XACT_ABORT ON;

	BEGIN TRY
		BEGIN TRAN
		
		INSERT INTO [App].[tbTaxCode] ([TaxCode], [TaxRate], [TaxDescription], [TaxTypeCode], [RoundingCode])
		VALUES ('INT', 0, 'Interest Tax', 3, 0)
		, ('N/A', 0, 'Untaxed', 3, 0)
		, ('NI1', 0, 'Directors National Insurance', 2, 0)
		, ('NI2', 0.121, 'Employees National Insurance', 2, 0)
		, ('T0', 0, 'Zero Rated VAT', 1, 0)
		, ('T1', 0.2, 'Standard VAT Rate', 1, 0)
		, ('T9', 0, 'TBC', 1, 0)
		;

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
		, ('SI', 'Startup Investment', 0, 1, 0, 17, 0)
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
		, ('214', 'Company Loan', 'IV', 'N/A', 0)
		, ('215', 'Directors Loan', 'IV', 'N/A', 0)
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

		--ASSIGN NET PROFIT CALCULATION
		UPDATE App.tbOptions
		SET NetProfitCode = 'NP', VatCategoryCode = 'VAT';

		--SET HOME TAX CODE
		UPDATE Org.tbOrg
		SET TaxCode = 'T0'
		WHERE AccountCode = (SELECT AccountCode FROM App.tbOptions)

		--CREATE GOV
		EXEC Org.proc_DefaultAccountCode @AccountName = @GovAccountName, @AccountCode = @AccountCode OUTPUT
		INSERT INTO Org.tbOrg (AccountCode, AccountName, OrganisationStatusCode, OrganisationTypeCode, TaxCode)
			VALUES (@AccountCode, @GovAccountName, 1, 7, 'N/A');

		--BANK ACCOUNTS
		EXEC Org.proc_DefaultAccountCode @AccountName = @BankName, @AccountCode = @AccountCode OUTPUT	
		INSERT INTO Org.tbOrg (AccountCode, AccountName, OrganisationStatusCode, OrganisationTypeCode, TaxCode)
		VALUES (@AccountCode, @BankName, 1, 5, 'T0');

		EXEC Org.proc_AddAddress @AccountCode = @AccountCode, @Address = @BankAddress;

		EXEC Org.proc_DefaultAccountCode @AccountName = @CurrentAccount, @AccountCode = @CashAccountCode OUTPUT
		INSERT INTO Org.tbAccount (CashAccountCode, AccountCode, CashAccountName, OpeningBalance, SortCode, AccountNumber, CashCode)
		VALUES        (@CashAccountCode, @AccountCode, @CurrentAccount, 0, @CA_SortCode, @CA_AccountNumber, '301')

		IF (LEN(@ReserveAccount) > 0)
		BEGIN
			EXEC Org.proc_DefaultAccountCode @AccountName = @ReserveAccount, @AccountCode = @CashAccountCode OUTPUT
			INSERT INTO Org.tbAccount (CashAccountCode, AccountCode, CashAccountName, OpeningBalance, SortCode, AccountNumber)
			VALUES        (@CashAccountCode, @AccountCode, @ReserveAccount, 0, @RA_SortCode, @RA_AccountNumber)
		END

		IF (LEN(@DummyAccount) > 0)
		BEGIN
			SELECT @AccountCode = (SELECT AccountCode FROM App.tbOptions)
			EXEC Org.proc_DefaultAccountCode @AccountName = @DummyAccount, @AccountCode = @CashAccountCode OUTPUT
			INSERT INTO Org.tbAccount (CashAccountCode, AccountCode, CashAccountName, DummyAccount)
			VALUES        (@CashAccountCode, @AccountCode, @DummyAccount, 1)
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

		INSERT INTO [Activity].[tbAttributeType] ([AttributeTypeCode], [AttributeType])
		VALUES (0, 'Order')
		, (1, 'Quote');

		INSERT INTO [Activity].[tbSyncType] ([SyncTypeCode], [SyncType])
		VALUES (0, 'SYNC')
		, (1, 'ASYNC')
		, (2, 'CALL-OFF');

		INSERT INTO [App].[tbBucketInterval] ([BucketIntervalCode], [BucketInterval])
		VALUES (0, 'Day')
		, (1, 'Week')
		, (2, 'Month');

		INSERT INTO [App].[tbBucketType] ([BucketTypeCode], [BucketType])
		VALUES (0, 'Default')
		, (1, 'Sunday')
		, (2, 'Monday')
		, (3, 'Tuesday')
		, (4, 'Wednesday')
		, (5, 'Thursday')
		, (6, 'Friday')
		, (7, 'Saturday')
		, (8, 'Month');

		INSERT INTO [App].[tbCodeExclusion] ([ExcludedTag])
		VALUES ('Limited')
		, ('Ltd')
		, ('PLC');

		INSERT INTO [App].[tbDocClass] ([DocClassCode], [DocClass])
		VALUES (0, 'Product')
		, (1, 'Money');

		INSERT INTO [App].[tbDocType] ([DocTypeCode], [DocType], [DocClassCode])
		VALUES (0, 'Quotation', 0)
		, (1, 'Sales Order', 0)
		, (2, 'Enquiry', 0)
		, (3, 'Purchase Order', 0)
		, (4, 'Sales Invoice', 1)
		, (5, 'Credit Note', 1)
		, (6, 'Debit Note', 1);

		INSERT INTO [App].[tbEventType] ([EventTypeCode], [EventType])
		VALUES (0, 'Error')
		, (1, 'Warning')
		, (2, 'Information');

		INSERT INTO [App].[tbMonth] ([MonthNumber], [MonthName])
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

		INSERT INTO [App].[tbRecurrence] ([RecurrenceCode], [Recurrence])
		VALUES (0, 'On Demand')
		, (1, 'Monthly')
		, (2, 'Quarterly')
		, (3, 'Bi-annual')
		, (4, 'Yearly');

		INSERT INTO [App].[tbRounding] ([RoundingCode], [Rounding])
		VALUES (0, 'Round')
		, (1, 'Truncate');


		INSERT INTO [Cash].[tbCategoryType] ([CategoryTypeCode], [CategoryType])
		VALUES (0, 'Cash Code')
		, (1, 'Total')
		, (2, 'Expression');

		INSERT INTO [Cash].[tbEntryType] ([CashEntryTypeCode], [CashEntryType])
		VALUES (0, 'Payment')
		, (1, 'Invoice')
		, (2, 'Order')
		, (3, 'Quote')
		, (4, 'Corporation Tax')
		, (5, 'Vat')
		, (6, 'Forecast');

		INSERT INTO [Cash].[tbMode] ([CashModeCode], [CashMode])
		VALUES (0, 'Expense')
		, (1, 'Income')
		, (2, 'Neutral');

		INSERT INTO [Cash].[tbStatus] ([CashStatusCode], [CashStatus])
		VALUES (0, 'Forecast')
		, (1, 'Current')
		, (2, 'Closed')
		, (3, 'Archived');

		INSERT INTO [Cash].[tbTaxType] ([TaxTypeCode], [TaxType], [MonthNumber], [RecurrenceCode], [OffsetDays])
		VALUES (0, 'Corporation Tax', 12, 4, 0)
		, (1, 'Vat', 4, 2, 31)
		, (2, 'N.I.', 4, 1, 0)
		, (3, 'General', 4, 0, 0);

		INSERT INTO [Cash].[tbType] ([CashTypeCode], [CashType])
		VALUES (0, 'TRADE')
		, (1, 'EXTERNAL')
		, (2, 'BANK');

		INSERT INTO [Invoice].[tbStatus] ([InvoiceStatusCode], [InvoiceStatus])
		VALUES (1, 'Invoiced')
		, (2, 'Partially Paid')
		, (3, 'Paid')
		, (0, 'Pending');

		INSERT INTO [Invoice].[tbType] ([InvoiceTypeCode], [InvoiceType], [CashModeCode], [NextNumber])
		VALUES (0, 'Sales Invoice', 1, 10000)
		, (1, 'Credit Note', 0, 20000)
		, (2, 'Purchase Invoice', 0, 30000)
		, (3, 'Debit Note', 1, 40000);

		INSERT INTO [Org].[tbPaymentStatus] ([PaymentStatusCode], [PaymentStatus])
		VALUES (0, 'Unposted')
		, (1, 'Payment')
		, (2, 'Transfer');

		INSERT INTO [Org].[tbStatus] ([OrganisationStatusCode], [OrganisationStatus])
		VALUES (0, 'Pending')
		, (1, 'Active')
		, (2, 'Hot')
		, (3, 'Dead');

		INSERT INTO [Task].[tbOpStatus] ([OpStatusCode], [OpStatus])
		VALUES (0, 'Pending')
		, (1, 'In-progress')
		, (2, 'Complete');

		INSERT INTO [Task].[tbStatus] ([TaskStatusCode], [TaskStatus])
		VALUES (0, 'Pending')
		, (1, 'Open')
		, (2, 'Closed')
		, (3, 'Charged')
		, (4, 'Cancelled')
		, (5, 'Archive');

		INSERT INTO [Usr].[tbMenuCommand] ([Command], [CommandText])
		VALUES (0, 'Folder')
		, (1, 'Link')
		, (2, 'Form In Read Mode')
		, (3, 'Form In Add Mode')
		, (4, 'Form In Edit Mode')
		, (5, 'Report');

		INSERT INTO [Usr].[tbMenuOpenMode] ([OpenMode], [OpenModeDescription])
		VALUES (0, 'Normal')
		, (1, 'Datasheet')
		, (2, 'Default Printing')
		, (3, 'Direct Printing')
		, (4, 'Print Preview')
		, (5, 'Email RTF')
		, (6, 'Email HTML')
		, (7, 'Email Snapshot')
		, (8, 'Email PDF');

		INSERT INTO [App].[tbRegister] ([RegisterName], [NextNumber])
		VALUES ('Expenses', 40000)
		, ('Event Log', 1)
		, ('Project', 30000)
		, ('Purchase Order', 20000)
		, ('Sales Order', 10000);

		INSERT INTO [App].[tbDoc] ([DocTypeCode], [ReportName], [OpenMode], [Description])
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

		INSERT INTO [Org].[tbType] ([OrganisationTypeCode], [CashModeCode], [OrganisationType])
		VALUES (0, 0, 'Non-Approved Supplier')
		, (1, 1, 'Customer')
		, (2, 1, 'Prospect')
		, (4, 1, 'Company')
		, (5, 1, 'Bank')
		, (7, 0, 'Other')
		, (8, 0, 'Approved Supplier')
		, (9, 0, 'Employee');

		INSERT INTO [App].[tbText] ([TextId], [Message], [Arguments])
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

		INSERT INTO [App].[tbCalendar] ([CalendarCode], [Monday], [Tuesday], [Wednesday], [Thursday], [Friday], [Saturday], [Sunday])
		VALUES (@CalendarCode, 1, 1, 1, 1, 1, 0, 0)
		;

		INSERT INTO Usr.tbUser (UserId, UserName, LogonName, IsAdministrator, IsEnabled, CalendarCode, EmailAddress, PhoneNumber)
		VALUES (CONCAT(LEFT(@FullName, 1), SUBSTRING(@FullName, CHARINDEX(' ', @FullName) + 1, 1)), @FullName, 
			SUSER_NAME() , 1, 1, @CalendarCode, @EmailAddress, @PhoneNumber)

		INSERT INTO App.tbOptions (Identifier, IsInitialised, AccountCode, RegisterName, DefaultPrintMode, BucketIntervalCode, BucketTypeCode, TaxHorizon, IsAutoOffsetDays, UnitOfCharge)
		VALUES ('TC', 0, @AccountCode, 'Event Log', 2, 1, 1, 730, 0, @UnitOfCharge);

		SET IDENTITY_INSERT [Usr].[tbMenu] ON;
		INSERT INTO [Usr].[tbMenu] ([MenuId], [MenuName])
		VALUES (1, 'Administrator')
		SET IDENTITY_INSERT [Usr].[tbMenu] OFF;

		SET IDENTITY_INSERT [Usr].[tbMenuEntry] ON;
		INSERT INTO [Usr].[tbMenuEntry] ([MenuId], [EntryId], [FolderId], [ItemId], [ItemText], [Command], [ProjectName], [Argument], [OpenMode])
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
		, (1, 39, 5, 4, 'Payment Entry', 4, 'Trader', 'Org_PaymentEntry', 0)
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
		, (1, 54, 5, 5, 'Transfers', 4, 'Trader', 'Cash_Transfer', 0)
		, (1, 55, 4, 4, 'Budget', 4, 'Trader', 'Cash_Budget', 0)
		, (1, 66, 6, 9, 'Audit Accruals - Corporation Tax', 5, 'Trader', 'Cash_CorpTaxAuditAccruals', 4)
		, (1, 67, 6, 8, 'Audit Accruals - VAT', 5, 'Trader', 'Cash_VatAuditAccruals', 4)
		, (1, 68, 5, 7, 'Network Allocations', 4, 'Trader', 'Task_Allocation', 0)
		, (1, 69, 5, 8, 'Network Invoices', 4, 'Trader', 'Invoice_Mirror', 0)
		;
		SET IDENTITY_INSERT [Usr].[tbMenuEntry] OFF;

		INSERT INTO Usr.tbMenuUser (UserId, MenuId)
		SELECT (SELECT UserId FROM Usr.tbUser) AS UserId, (SELECT MenuId FROM Usr.tbMenu) AS MenuId;

		COMMIT TRAN
  	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
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
		DELETE FROM Org.tbPayment;
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

		INSERT INTO [Activity].[tbActivity] ([ActivityCode], [TaskStatusCode], [ActivityDescription], [UnitOfMeasure], [CashCode], [UnitCharge], [Printed], [RegisterName])
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
		INSERT INTO [Activity].[tbAttribute] ([ActivityCode], [Attribute], [PrintOrder], [AttributeTypeCode], [DefaultText])
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
		INSERT INTO [Activity].[tbFlow] ([ParentCode], [StepNumber], [ChildCode], [SyncTypeCode], [OffsetDays], [UsedOnQuantity])
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
		INSERT INTO [Activity].[tbOp] ([ActivityCode], [OperationNumber], [SyncTypeCode], [Operation], [Duration], [OffsetDays])
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

		INSERT INTO [Org].[tbOrg] ([AccountCode], [AccountName], [OrganisationTypeCode], [OrganisationStatusCode], [TaxCode], [AddressCode], [AreaCode], [PhoneNumber], [EmailAddress], [WebSite], [AccountSource], [PaymentTerms], [ExpectedDays], [PaymentDays], [PayDaysFromMonthEnd], [PayBalance])
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
		INSERT INTO [Org].[tbAddress] ([AddressCode], [AccountCode], [Address])
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
		INSERT INTO [Org].[tbContact] ([AccountCode], [ContactName], [FileAs], [OnMailingList], [NameTitle], [NickName], [JobTitle], [PhoneNumber], [MobileNumber], [EmailAddress])
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

		INSERT INTO [Task].[tbTask] ([TaskCode], [UserId], [AccountCode], [SecondReference], [TaskTitle], [ContactName], [ActivityCode], [TaskStatusCode], [ActionById], [ActionOn], [ActionedOn], [PaymentOn], [TaskNotes], [Quantity], [CashCode], [TaxCode], [UnitCharge], [TotalCharge], [AddressCodeFrom], [AddressCodeTo], [Spooled], [Printed])
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
		INSERT INTO [Task].[tbFlow] ([ParentTaskCode], [StepNumber], [ChildTaskCode], [SyncTypeCode], [UsedOnQuantity], [OffsetDays])
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
		INSERT INTO [Task].[tbOp] ([TaskCode], [OperationNumber], [SyncTypeCode], [OpStatusCode], [UserId], [Operation], [Note], [StartOn], [EndOn], [Duration], [OffsetDays])
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
		INSERT INTO [Task].[tbQuote] ([TaskCode], [Quantity], [TotalPrice], [RunOnQuantity], [RunOnPrice], [RunBackQuantity], [RunBackPrice])
		VALUES (CONCAT(@UserId, '_10014'), 5000, 1000.0000, 1000, 50.0000, 1000, 45)
		, (CONCAT(@UserId, '_10014'), 10000, 1400.0000, 1000, 48.0000, 1000, 43)
		, (CONCAT(@UserId, '_10014'), 20000, 2200.0000, 1000, 45.0000, 1000, 42)
		;
		INSERT INTO [Task].[tbAttribute] ([TaskCode], [Attribute], [PrintOrder], [AttributeTypeCode], [AttributeDescription])
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

		INSERT INTO [Invoice].[tbInvoice] ([InvoiceNumber], [UserId], [AccountCode], [InvoiceTypeCode], [InvoiceStatusCode], [InvoicedOn], [ExpectedOn], [DueOn], [InvoiceValue], [TaxValue], [PaidValue], [PaidTaxValue], [PaymentTerms], [Notes], [Printed], [Spooled])
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

		INSERT INTO [Invoice].[tbTask] ([InvoiceNumber], [TaskCode], [Quantity], [TotalValue], [InvoiceValue], [TaxValue], [PaidValue], [PaidTaxValue], [CashCode], [TaxCode])
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
		INSERT INTO [Invoice].[tbItem] ([InvoiceNumber], [CashCode], [TaxCode], [TotalValue], [InvoiceValue], [TaxValue], [PaidValue], [PaidTaxValue], [ItemReference])
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

		INSERT INTO [Org].[tbPayment] ([PaymentCode], [UserId], [PaymentStatusCode], [AccountCode], [CashAccountCode], [CashCode], [TaxCode], [PaidOn], [PaidInValue], [PaidOutValue], [TaxInValue], [TaxOutValue], [PaymentReference])
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

		UPDATE Org.tbPayment
		SET PaidOn = DATEADD(MONTH, @OffsetMonth, App.fnAdjustToCalendar(PaidOn, 0));

CommitTran:
		EXEC App.proc_SystemRebuild;
		COMMIT TRAN;

	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
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
				
		BEGIN TRAN

		-->>>>>>>>>>>>> RESET >>>>>>>>>>>>>>>>>>>>>>>>>>>
		DELETE FROM Org.tbPayment;
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
		VALUES ('M/00/70/00', 1, 'PIGEON HOLE SHELF ASSEMBLY CLEAR', 'each', '103', 16.6240, 1, 'Sales Order')
		, ('M/100/70/00', 1, 'PIGEON HOLE SUB SHELF CLEAR', 'each', NULL, 0.0000, 0, 'Works Order')
		, ('M/101/70/00', 1, 'PIGEON HOLE BACK DIVIDER', 'each', NULL, 0.0000, 0, 'Works Order')
		, ('M/97/70/00', 1, 'SHELF DIVIDER (WIDE FOOT)', 'each', NULL, 0.0000, 0, 'Works Order')
		, ('M/99/70/00', 1, 'SHELF DIVIDER (NARROW FOOT)', 'each', NULL, 0.0000, 0, 'Works Order')
		, ('PALLET/01', 1, 'EURO 3 1200 x 800 4 WAY', 'each', '200', 2.2500, 1, 'Purchase Order')
		, ('BOX/41', 1, 'PIGEON ASSY 125KTB S WALL 404x220x90', 'each', '200', 0.2940, 1, 'Purchase Order')
		, ('BOX/99', 1, 'INTERNAL USE ANY BLACK,BLUE,RED ANY', 'each', NULL, 0.0000, 0, 'Works Order')
		, ('PC/999', 1, 'CALIBRE 303EP CLEAR UL94-V2', 'kilo', '200', 2.1500, 1, 'Purchase Order')
		, ('INSERT/09', 1, 'HEAT-LOK SHK B M3.5 HEADED BRASS 8620035-80', 'each', '200', 0.0430, 1, 'Purchase Order')
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
			@Quantity DECIMAL = 1000;

		EXEC Task.proc_NextCode 'PROJECT', @ParentTaskCode OUTPUT
		INSERT INTO Task.tbTask
								 (TaskCode, UserId, AccountCode, TaskTitle, ActivityCode, TaskStatusCode, ActionById)
		VALUES        (@ParentTaskCode,@UserId, 'STOBOX', N'PIGEON HOLE SHELF ASSEMBLY', N'PROJECT', 0,@UserId)
	
		EXEC Task.proc_NextCode 'M/00/70/00', @TaskCode OUTPUT
		
		INSERT INTO Task.tbTask
				(TaskCode, UserId, AccountCode, TaskTitle, ContactName, ActivityCode, TaskStatusCode, ActionById, TaskNotes, Quantity, CashCode, TaxCode, UnitCharge, AddressCodeFrom, AddressCodeTo, SecondReference, Printed)
		VALUES        (@TaskCode,@UserId, 'STOBOX', N'PIGEON HOLE SHELF ASSEMBLY', 'Francis Brown', 'M/00/70/00', 1,@UserId, 'PIGEON HOLE SHELF ASSEMBLY', @Quantity, '103', 'T1', 16.624, 'STOBOX_001', 'STOBOX_001', N'12354/2', 0);

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
		SET AccountCode = 'HAULOG', ContactName = 'John Iron',  AddressCodeFrom = 'HOME_001', AddressCodeTo = 'STOBOX_001', Quantity = 1, UnitCharge = 250, TotalCharge = 250
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

		DECLARE @PaymentCode NVARCHAR(20);
		EXEC Org.proc_NextPaymentCode @PaymentCode OUTPUT
		INSERT INTO Org.tbPayment (CashAccountCode, PaymentCode, UserId, AccountCode, CashCode, TaxCode, PaidInValue)
		SELECT DISTINCT
			CashAccountCode,
			@PaymentCode AS PaymentCode, 
			@UserId AS UserId,
			AccountCode,
			'214' AS CashCode,
			'T0' AS TaxCode,
			(SELECT ABS(ROUND(MIN(Balance), -3)) + 1000	FROM Cash.vwStatement) AS PaidInValue
		FROM Org.tbAccount WHERE NOT CashCode IS NULL

		EXEC Org.proc_PaymentPost;


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


