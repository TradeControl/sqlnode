/**************************************************************************************
Trade Control
Upgrade script
Release: 3.26.1

Date: 06 April 2020
Author: Ian Monnox

Trade Control by Trade Control Ltd is licensed under GNU General Public License v3.0. 

You may obtain a copy of the License at

	https://www.gnu.org/licenses/gpl-3.0.en.html

Change log:

	https://github.com/tradecontrol/sqlnode

Instructions:
This script should be applied by the TC Node Configuration app.
It inserts the upgade into App.tbInstall.


***********************************************************************************/
DISABLE TRIGGER Task.Task_tbTask_TriggerUpdate ON Task.tbTask;
go

ALTER TABLE Task.tbTask WITH NOCHECK ADD
	QuantityStore float,
	UnitChargeStore float;
go
UPDATE Task.tbTask
SET QuantityStore = Quantity, UnitChargeStore = UnitCharge
go

DROP INDEX IX_Task_tbTask_ActionOn_TaskCode_CashCode ON Task.tbTask;
DROP INDEX IX_Task_tbTask_TaskCode_CashCode ON Task.tbTask;
go
ALTER TABLE Task.tbTask DROP 
	CONSTRAINT DF_Task_tbTask_Quantity, DF_Task_tb_UnitCharge,
	COLUMN	Quantity, UnitCharge;
go
ALTER TABLE Task.tbTask WITH NOCHECK ADD
	Quantity decimal(18, 4) NOT NULL CONSTRAINT DF_Task_tb_Quantity DEFAULT (0),
	UnitCharge decimal(18, 6) NOT NULL CONSTRAINT DF_Task_tb_UnitCharge DEFAULT (0);
go
UPDATE Task.tbTask
SET Quantity = QuantityStore, UnitCharge = UnitChargeStore
go

CREATE NONCLUSTERED INDEX [IX_Task_tbTask_ActionOn_TaskCode_CashCode] ON [Task].[tbTask]
(
	[ActionOn] ASC,
	[TaskCode] ASC,
	[CashCode] ASC,
	[TaskStatusCode] ASC,
	[AccountCode] ASC
)
INCLUDE([TaskTitle],[ActivityCode],[ActionedOn],[Quantity],[UnitCharge],[TotalCharge],[PaymentOn]) 
go
CREATE NONCLUSTERED INDEX [IX_Task_tbTask_TaskCode_CashCode] ON [Task].[tbTask]
(
	[TaskCode] ASC,
	[CashCode] ASC
)
INCLUDE([Quantity],[UnitCharge]) 
go


ALTER TABLE Task.tbTask DROP 
	COLUMN QuantityStore, UnitChargeStore
go
ENABLE TRIGGER Task.Task_tbTask_TriggerUpdate ON Task.tbTask;
go

ALTER TABLE [App].[tbTaxCode] ADD
	TaxRateStore float
go
UPDATE App.tbTaxCode SET TaxRateStore = TaxRate;
go
ALTER TABLE App.tbTaxCode DROP
	CONSTRAINT DF_App_tbTaxCode_VatRate,
	COLUMN TaxRate;
go
ALTER TABLE App.tbTaxCode WITH NOCHECK ADD
	TaxRate decimal(18, 4) NOT NULL CONSTRAINT DF_App_tbTaxCode_TaxRate DEFAULT (0)
go
UPDATE App.tbTaxCode SET TaxRate = TaxRateStore;
go
ALTER TABLE App.tbTaxCode DROP COLUMN TaxRateStore;
go

DISABLE TRIGGER Task_tbFlow_TriggerUpdate ON Task.tbFlow;
go
ALTER TABLE [Task].[tbFlow] WITH NOCHECK ADD
	UsedOnQuantityStore float 
go
UPDATE Task.tbFlow SET UsedOnQuantityStore = UsedOnQuantity
go
ALTER TABLE Task.tbFlow DROP
	CONSTRAINT DF_Task_tbFlow_UsedOnQuantity,
	COLUMN UsedOnQuantity;
go
ALTER TABLE Task.tbFlow WITH NOCHECK ADD
	UsedOnQuantity decimal(18, 6) NOT NULL CONSTRAINT DF_Task_tbFlow_UsedOnQuantity DEFAULT (1)
go
UPDATE Task.tbFlow SET UsedOnQuantity = UsedOnQuantityStore
go
ALTER TABLE Task.tbFlow DROP COLUMN UsedOnQuantityStore
go
ENABLE TRIGGER Task_tbFlow_TriggerUpdate ON Task.tbFlow;
go

ALTER TABLE [Invoice].[tbTask] ADD QuantityStore float;
go
UPDATE Invoice.tbTask SET QuantityStore = Quantity;
go
ALTER TABLE [Invoice].[tbTask] DROP
	CONSTRAINT DF_Invoice_tbTask_Quantity, 
	COLUMN Quantity;
go
ALTER TABLE Invoice.tbTask WITH NOCHECK ADD
	Quantity decimal(18, 4) NOT NULL CONSTRAINT DF_Invoice_tbTask_Quantity DEFAULT (0);
go
UPDATE Invoice.tbTask SET Quantity = QuantityStore;
go
ALTER TABLE [Invoice].[tbTask] DROP COLUMN QuantityStore;
go

DISABLE TRIGGER Task_tbOp_TriggerUpdate ON Task.tbOp;
go
ALTER TABLE [Task].[tbOp] ADD
	DurationStore float;
go
UPDATE Task.tbOp SET DurationStore = Duration;
go
ALTER TABLE Task.tbOp DROP
	CONSTRAINT DF_Task_tbOp_Duration, 
	COLUMN Duration;
go
ALTER TABLE [Task].[tbOp] ADD
	Duration decimal(18, 4) CONSTRAINT DF_Task_tbOp_Duration DEFAULT (0);
go
UPDATE Task.tbOp SET Duration = DurationStore;
go
ALTER TABLE Task.tbOp DROP COLUMN DurationStore;
go
ENABLE TRIGGER Task_tbOp_TriggerUpdate ON Task.tbOp;
go


ALTER TABLE Task.tbChangeLog WITH NOCHECK ADD
	QuantityStore float,
	UnitChargeStore float;
go
UPDATE Task.tbChangeLog
SET QuantityStore = Quantity, UnitChargeStore = UnitCharge
go
ALTER TABLE Task.tbChangeLog DROP COLUMN
	Quantity, UnitCharge;
go
ALTER TABLE Task.tbChangeLog WITH NOCHECK ADD
	Quantity decimal(18, 4) NOT NULL CONSTRAINT DF_Task_tbChangeLog_Quantity DEFAULT (0),
	UnitCharge decimal(18, 7) NOT NULL CONSTRAINT DF_Task_tbChangeLog_UnitCharge DEFAULT (0);
go
UPDATE Task.tbChangeLog
SET Quantity = QuantityStore, UnitCharge = UnitChargeStore
go
ALTER TABLE Task.tbChangeLog DROP COLUMN
	QuantityStore, UnitChargeStore
go
	

DISABLE TRIGGER Activity_tbFlow_TriggerUpdate ON Activity.tbFlow;
go
ALTER TABLE [Activity].[tbFlow] WITH NOCHECK ADD
	UsedOnQuantityStore float 
go
UPDATE Activity.tbFlow SET UsedOnQuantityStore = UsedOnQuantity
go
ALTER TABLE Activity.tbFlow DROP
	CONSTRAINT DF_Activity_tbCodeFlow_Quantity,
	COLUMN UsedOnQuantity;
go
ALTER TABLE Activity.tbFlow WITH NOCHECK ADD
	UsedOnQuantity decimal(18, 6) NOT NULL CONSTRAINT DF_Activity_tbFlow_UsedOnQuantity DEFAULT (1)
go
UPDATE Activity.tbFlow SET UsedOnQuantity = UsedOnQuantityStore
go
ALTER TABLE Activity.tbFlow DROP COLUMN UsedOnQuantityStore
go
ENABLE TRIGGER Activity_tbFlow_TriggerUpdate ON Activity.tbFlow;
go

DISABLE TRIGGER Activity_tbOp_TriggerUpdate ON Activity.tbOp;
go
ALTER TABLE [Activity].[tbOp] ADD
	DurationStore float;
go
UPDATE Activity.tbOp SET DurationStore = Duration;
go
ALTER TABLE Activity.tbOp DROP
	CONSTRAINT DF_Activity_tbOp_Duration, 
	COLUMN Duration;
go
ALTER TABLE [Activity].[tbOp] ADD
	Duration decimal(18, 4) CONSTRAINT DF_Activity_tbOp_Duration DEFAULT (0);
go
UPDATE Activity.tbOp SET Duration = DurationStore;
go
ALTER TABLE Activity.tbOp DROP COLUMN DurationStore;
go
ENABLE TRIGGER Activity_tbOp_TriggerUpdate ON Activity.tbOp;
go


ALTER TABLE [Task].[tbQuote] DROP CONSTRAINT [PK_Task_tbQuote] WITH ( ONLINE = OFF );
go
ALTER TABLE [Task].[tbQuote] DROP CONSTRAINT [FK_Task_tbQuote_Task_tb];
go
ALTER TABLE Task.tbQuote ADD
	QuantityStore float, RunOnQuantityStore float, RunBackQuantityStore float, RunBackPriceStore float;
go
UPDATE Task.tbQuote
SET QuantityStore = Quantity, RunOnQuantityStore = RunOnQuantity,
	RunBackQuantityStore = RunBackQuantity, RunBackPriceStore = RunBackPrice;
go
ALTER TABLE Task.tbQuote DROP
	CONSTRAINT DF_Task_tbQuote_Quantity, DF_Task_tbQuote_RunOnQuantity, DF_Task_tbQuote_RunBackQuantity, DF_Task_tbQuote_RunBackPrice,
	COLUMN Quantity, RunOnQuantity, RunBackQuantity, RunBackPrice;
go
ALTER TABLE Task.tbQuote ADD
	Quantity decimal(18, 4) NOT NULL CONSTRAINT DF_Task_tbQuote_Quantity DEFAULT (0),
	RunOnQuantity decimal(18, 4) NOT NULL CONSTRAINT DF_Task_tbQuote_RunOnQuantity DEFAULT (0),
	RunBackQuantity decimal(18, 4) NOT NULL CONSTRAINT DF_Task_tbQuote_RunBackQuantity DEFAULT (0),
	RunBackPrice decimal(18, 4) NOT NULL CONSTRAINT DF_Task_tbQuote_RunBackPrice DEFAULT (0)
go
UPDATE Task.tbQuote
SET Quantity = QuantityStore, RunOnQuantity = RunOnQuantityStore,
	RunBackQuantity = RunBackQuantityStore, RunBackPrice = RunBackPriceStore;
go
ALTER TABLE Task.tbQuote DROP
	COLUMN QuantityStore, RunOnQuantityStore, RunBackQuantityStore, RunBackPriceStore;
go
ALTER TABLE [Task].[tbQuote] ADD  CONSTRAINT [PK_Task_tbQuote] PRIMARY KEY CLUSTERED 
(
	[TaskCode] ASC,
	[Quantity] ASC
) ON [PRIMARY]
go
ALTER TABLE [Task].[tbQuote]  WITH NOCHECK ADD  CONSTRAINT [FK_Task_tbQuote_Task_tb] FOREIGN KEY([TaskCode])
REFERENCES [Task].[tbTask] ([TaskCode])
ON UPDATE CASCADE
ON DELETE CASCADE;
go
ALTER TABLE [Task].[tbQuote] CHECK CONSTRAINT [FK_Task_tbQuote_Task_tb];
go

CREATE OR ALTER   VIEW [App].[vwMonths]
AS
	SELECT DISTINCT CAST(App.tbYearPeriod.StartOn AS decimal) AS StartOn, App.tbMonth.MonthName, App.tbYearPeriod.MonthNumber
	FROM         App.tbYearPeriod INNER JOIN
						  App.fnActivePeriod() AS fnSystemActivePeriod ON App.tbYearPeriod.YearNumber = fnSystemActivePeriod.YearNumber INNER JOIN
						  App.tbMonth ON App.tbYearPeriod.MonthNumber = App.tbMonth.MonthNumber
go

CREATE OR ALTER VIEW Cash.vwFlowVatRecurrenceAccruals
AS	
	WITH active_periods AS
	(
		SELECT App.tbYear.YearNumber, App.tbYearPeriod.StartOn
		FROM            App.tbYearPeriod INNER JOIN
								 App.tbMonth ON App.tbYearPeriod.MonthNumber = App.tbMonth.MonthNumber INNER JOIN
								 App.tbYear ON App.tbYearPeriod.YearNumber = App.tbYear.YearNumber
		WHERE        (App.tbYear.CashStatusCode < 3)
	),	vat_dates AS
	(
		SELECT PayFrom, PayTo FROM Cash.fnTaxTypeDueDates(1)
	), vatPeriod AS
	(
		SELECT        StartOn, y.YearNumber, p.MonthNumber,
			(SELECT PayTo FROM vat_dates WHERE p.StartOn >= PayFrom AND p.StartOn < PayTo) AS VatStartOn, VatAdjustment
		FROM            App.tbYearPeriod AS p JOIN App.tbYear AS y ON p.YearNumber = y.YearNumber 
	)
	, vat_accruals AS
	(
		SELECT  vatPeriod.VatStartOn AS StartOn,
				SUM(HomeSales) AS HomeSales, SUM(HomePurchases) AS HomePurchases, SUM(ExportSales) AS ExportSales, SUM(ExportPurchases) AS ExportPurchases, 
				SUM(HomeSalesVat) AS HomeSalesVat, SUM(HomePurchasesVat) AS HomePurchasesVat, 
				SUM(ExportSalesVat) AS ExportSalesVat, SUM(ExportPurchasesVat) AS ExportPurchasesVat, SUM(VatDue) AS VatDue
		FROM Cash.vwFlowVatPeriodAccruals accruals JOIN vatPeriod ON accruals.StartOn = vatPeriod.StartOn
		GROUP BY vatPeriod.VatStartOn
	)
	SELECT active_periods.YearNumber, active_periods.StartOn, CAST(ISNULL(HomeSales, 0) AS money) AS HomeSales, CAST(ISNULL(HomePurchases, 0) AS money) AS HomePurchases, 
		CAST(ISNULL(ExportSales, 0) AS money) AS ExportSales, CAST(ISNULL(ExportPurchases, 0) AS money) AS ExportPurchases, CAST(ISNULL(HomeSalesVat, 0) as money) AS HomeSalesVat, 
		CAST(ISNULL(HomePurchasesVat, 0) AS money) AS HomePurchasesVat, CAST(ISNULL(ExportSalesVat, 0) AS money) AS ExportSalesVat, 
		CAST(ISNULL(ExportPurchasesVat, 0) AS money) AS ExportPurchasesVat, CAST(ISNULL(VatDue, 0) AS money) AS VatDue 
	FROM vat_accruals 
		RIGHT OUTER JOIN active_periods ON active_periods.StartOn = vat_accruals.StartOn;		

go
CREATE OR ALTER VIEW Cash.vwFlowVatPeriodAccruals
AS
	WITH active_periods AS
	(
		SELECT App.tbYear.YearNumber, App.tbYearPeriod.StartOn
		FROM            App.tbYearPeriod INNER JOIN
								 App.tbMonth ON App.tbYearPeriod.MonthNumber = App.tbMonth.MonthNumber INNER JOIN
								 App.tbYear ON App.tbYearPeriod.YearNumber = App.tbYear.YearNumber
		WHERE        (App.tbYear.CashStatusCode < 3)
	),	 vat_accruals AS
	(
		SELECT   active_periods.YearNumber, active_periods.StartOn, ISNULL(SUM(vat_audit.HomeSales), 0) AS HomeSales, ISNULL(SUM(vat_audit.HomePurchases), 0) AS HomePurchases, ISNULL(SUM(vat_audit.ExportSales), 0) AS ExportSales, ISNULL(SUM(vat_audit.ExportPurchases), 0) 
								 AS ExportPurchases, ISNULL(SUM(vat_audit.HomeSalesVat), 0) AS HomeSalesVat, ISNULL(SUM(vat_audit.HomePurchasesVat), 0) AS HomePurchasesVat, ISNULL(SUM(vat_audit.ExportSalesVat), 0) AS ExportSalesVat, 
								 ISNULL(SUM(vat_audit.ExportPurchasesVat), 0) AS ExportPurchasesVat
		FROM            Cash.vwTaxVatAuditAccruals AS vat_audit RIGHT OUTER JOIN
								 active_periods ON active_periods.StartOn = vat_audit.StartOn
		GROUP BY active_periods.YearNumber, active_periods.StartOn
	)
	SELECT YearNumber, StartOn, CAST(HomeSales AS money) HomeSales, CAST(HomePurchases AS money) HomePurchases, CAST(ExportSales AS money) AS ExportSales, 
		CAST(ExportPurchases AS money) ExportPurchases, CAST(HomeSalesVat AS money) HomeSalesVat, CAST(HomePurchasesVat AS money) HomePurchasesVat, 
		CAST(ExportSalesVat AS money) ExportSalesVat, CAST(ExportPurchasesVat AS money) ExportPurchasesVat,
		CAST((HomeSalesVat + ExportSalesVat) - (HomePurchasesVat + ExportPurchasesVat) AS money) VatDue
	FROM vat_accruals;
go

ALTER PROCEDURE Task.proc_Cost 
	(
	@ParentTaskCode nvarchar(20),
	@TotalCost money = 0 OUTPUT
	)
AS
 	SET NOCOUNT, XACT_ABORT ON;

	BEGIN TRY
		WITH task_flow AS
		(
			SELECT parent_task.TaskCode, child.ParentTaskCode, child.ChildTaskCode, 
				CASE WHEN child.UsedOnQuantity <> 0 THEN CAST(parent_task.Quantity * child.UsedOnQuantity AS decimal(18, 4)) ELSE child_task.Quantity END AS Quantity, 
				1 AS Depth				
			FROM Task.tbFlow child 
				JOIN Task.tbTask parent_task ON child.ParentTaskCode = parent_task.TaskCode
				JOIN Task.tbTask child_task ON child.ChildTaskCode = child_task.TaskCode
			WHERE parent_task.TaskCode = @ParentTaskCode

			UNION ALL

			SELECT parent.TaskCode, child.ParentTaskCode, child.ChildTaskCode, 
				CASE WHEN child.UsedOnQuantity <> 0 THEN CAST(parent.Quantity * child.UsedOnQuantity AS decimal(18, 4)) ELSE child_task.Quantity END AS Quantity, 
				parent.Depth + 1 AS Depth
			FROM Task.tbFlow child 
				JOIN task_flow parent ON child.ParentTaskCode = parent.ChildTaskCode
				JOIN Task.tbTask child_task ON child.ChildTaskCode = child_task.TaskCode
		)
		, tasks AS
		(
			SELECT task_flow.TaskCode, task.Quantity,
				CASE category.CashModeCode 
					WHEN NULL THEN 0 
					WHEN 0 THEN task.UnitCharge * -1 
					ELSE task.UnitCharge 
				END AS UnitCharge
			FROM task_flow
				JOIN Task.tbTask task ON task_flow.ChildTaskCode = task.TaskCode
				LEFT OUTER JOIN Cash.tbCode cashcode ON cashcode.CashCode = task.CashCode 
				LEFT OUTER JOIN Cash.tbCategory category ON category.CategoryCode = cashcode.CategoryCode
		), task_costs AS
		(
			SELECT TaskCode, SUM(Quantity * UnitCharge) AS TotalCost
			FROM tasks
			GROUP BY TaskCode
		)
		SELECT @TotalCost = TotalCost
		FROM task_costs;		

  	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
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
					 SUM(CASE CashModeCode WHEN 0 THEN Invoice.tbTask.PaidValue * -1 ELSE Invoice.tbTask.PaidValue END) AS InvoicePaid
				FROM Invoice.tbTask 
					INNER JOIN Invoice.tbInvoice ON Invoice.tbTask.InvoiceNumber = Invoice.tbInvoice.InvoiceNumber
					INNER JOIN Invoice.tbType ON Invoice.tbType.InvoiceTypeCode = Invoice.tbInvoice.InvoiceTypeCode 
				GROUP BY Invoice.tbTask.TaskCode
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
			TaskTitle, AccountName, CashDescription, TaskStatus, TotalCharge, InvoicedCharge, InvoicedChargePaid,
			CAST(TotalCost AS MONEY) TotalCost, InvoicedCost, InvoicedCostPaid, CAST(Profit AS MONEY) Profit,
			CAST(UninvoicedCharge AS MONEY) UninvoicedCharge, CAST(UnpaidCharge AS MONEY) UnpaidCharge,
			CAST(UninvoicedCost AS MONEY) UninvoicedCost, CAST(UnpaidCost AS MONEY) UnpaidCost,
			ActionOn, ActionedOn, PaymentOn
		FROM profits;
go
ALTER PROCEDURE Task.proc_Op (@TaskCode nvarchar(20))
AS
  	SET NOCOUNT, XACT_ABORT ON;

	BEGIN TRY
		IF EXISTS (SELECT     TaskCode
				   FROM         Task.tbOp
				   WHERE     (TaskCode = @TaskCode))
			BEGIN
			SELECT     Task.tbOp.*
				   FROM         Task.tbOp
				   WHERE     (TaskCode = @TaskCode)
			END
		ELSE
			BEGIN
			SELECT     Task.tbOp.*
				   FROM         Task.tbFlow INNER JOIN
										 Task.tbOp ON Task.tbFlow.ParentTaskCode = Task.tbOp.TaskCode
				   WHERE     ( Task.tbFlow.ChildTaskCode = @TaskCode)
			END
		
  	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
go
