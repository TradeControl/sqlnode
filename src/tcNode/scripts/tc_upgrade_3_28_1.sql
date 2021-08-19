/**************************************************************************************
Trade Control
Upgrade script
Release: 3.28.1

Date: 01 July 2020
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
ALTER TABLE Org.tbOrg WITH NOCHECK ADD
	OpeningBalanceStore money,
	TurnoverStore money
go
UPDATE Org.tbOrg
SET OpeningBalanceStore = OpeningBalance, TurnoverStore = Turnover
go
DROP INDEX IX_Org_tbOrg_OpeningBalance ON Org.tbOrg
go
ALTER TABLE Org.tbOrg DROP 
	CONSTRAINT DF_Org_tb_OpeningBalance,
	CONSTRAINT DF_Org_tb_Turnover,
	COLUMN OpeningBalance,
	COLUMN Turnover
go
ALTER TABLE Org.tbOrg ADD 
	OpeningBalance decimal(18, 5) NOT NULL CONSTRAINT DF_Org_tb_OpeningBalance  DEFAULT ((0)),
	Turnover decimal(18, 5) NOT NULL CONSTRAINT DF_Org_tb_Turnover DEFAULT ((0)) 
go
UPDATE Org.tbOrg
SET OpeningBalance = OpeningBalanceStore, Turnover = TurnoverStore
go
ALTER TABLE Org.tbOrg DROP 
	COLUMN OpeningBalanceStore,
	COLUMN TurnoverStore
go
CREATE NONCLUSTERED INDEX IX_Org_tbOrg_OpeningBalance ON Org.tbOrg ( AccountCode ASC) INCLUDE (OpeningBalance) 
go

ALTER TABLE Task.tbTask ADD
	TotalChargeStore money
go
UPDATE Task.tbTask
SET TotalChargeStore = TotalCharge
go

DISABLE TRIGGER Task.Task_tbTask_TriggerUpdate ON Task.tbTask;
DROP INDEX IX_Task_tbTask_ActionOn_TaskCode_CashCode ON Task.tbTask
DROP INDEX IX_Task_tbTask_Status_TaxCode_TaskCode ON Task.tbTask
DROP INDEX IX_Task_tbTask_TaskCode_TaxCode_CashCode ON Task.tbTask
go

ALTER TABLE Task.tbTask DROP
	CONSTRAINT DF_Task_tb_TotalCharge,
	COLUMN TotalCharge
go
ALTER TABLE Task.tbTask ADD 
	TotalCharge decimal(18, 5) NOT NULL CONSTRAINT DF_Task_tb_TotalCharge  DEFAULT (0)
go
UPDATE Task.tbTask
SET TotalCharge = TotalChargeStore
go
ALTER TABLE Task.tbTask DROP 
	COLUMN TotalChargeStore
go
CREATE NONCLUSTERED INDEX IX_Task_tbTask_ActionOn_TaskCode_CashCode ON Task.tbTask
(
	ActionOn ASC,
	TaskCode ASC,
	CashCode ASC,
	TaskStatusCode ASC,
	AccountCode ASC
)
INCLUDE(TaskTitle,ActivityCode,ActionedOn,Quantity,UnitCharge,TotalCharge,PaymentOn)
go
CREATE NONCLUSTERED INDEX IX_Task_tbTask_Status_TaxCode_TaskCode ON Task.tbTask
(
	TaskStatusCode ASC,
	TaxCode ASC,
	TaskCode ASC,
	CashCode ASC,
	ActionOn ASC
)
INCLUDE(TotalCharge)
go
CREATE NONCLUSTERED INDEX IX_Task_tbTask_TaskCode_TaxCode_CashCode ON Task.tbTask
(
	TaskCode ASC,
	TaxCode ASC,
	CashCode ASC,
	ActionOn ASC
)
INCLUDE(TotalCharge)
go
ENABLE TRIGGER Task.Task_tbTask_TriggerUpdate ON Task.tbTask;
go

ALTER TABLE Activity.tbActivity ADD
	UnitChargeStore money
go
UPDATE Activity.tbActivity
SET UnitChargeStore = UnitCharge
go
ALTER TABLE Activity.tbActivity DROP
	CONSTRAINT DF_Activity_tbActivity_UnitCharge,
	COLUMN UnitCharge
go
ALTER TABLE Activity.tbActivity ADD  
	UnitCharge decimal (18, 5) NOT NULL CONSTRAINT [DF_Activity_tbActivity_UnitCharge]  DEFAULT (0)
go
UPDATE Activity.tbActivity
SET UnitCharge = UnitChargeStore
go
ALTER TABLE Activity.tbActivity DROP
	COLUMN UnitChargeStore
go


ALTER TABLE Org.tbAccount ADD
	OpeningBalanceStore money,
	CurrentBalanceStore money
go
UPDATE Org.tbAccount
SET OpeningBalanceStore = OpeningBalance, CurrentBalanceStore = CurrentBalance
go
ALTER TABLE Org.tbAccount DROP
	CONSTRAINT DF_Org_tbAccount_OpeningBalance,
	CONSTRAINT DF_Org_tbAccount_CurrentBalance,
	COLUMN OpeningBalance,
	COLUMN CurrentBalance
go
ALTER TABLE Org.tbAccount ADD  
	OpeningBalance decimal(18, 5) NOT NULL CONSTRAINT DF_Org_tbAccount_OpeningBalance  DEFAULT (0),
	CurrentBalance decimal(18, 5) NOT NULL CONSTRAINT DF_Org_tbAccount_CurrentBalance  DEFAULT (0)
go
UPDATE Org.tbAccount
SET OpeningBalance = OpeningBalanceStore, CurrentBalance = CurrentBalanceStore
go
ALTER TABLE Org.tbAccount DROP
	COLUMN OpeningBalanceStore,
	COLUMN CurrentBalanceStore
go


ALTER TABLE Invoice.tbInvoice ADD
	InvoiceValueStore money,
	TaxValueStore money,
	PaidValueStore money,
	PaidTaxValueStore money
go
UPDATE Invoice.tbInvoice 
SET
	InvoiceValueStore = InvoiceValue,
	TaxValueStore = TaxValue,
	PaidValueStore = PaidValue,
	PaidTaxValueStore = PaidTaxValue
go
DROP INDEX IX_Invoice_tbInvoice_AccountCode_Type ON Invoice.tbInvoice
DROP INDEX IX_Invoice_tbInvoice_AccountValues ON Invoice.tbInvoice
go
ALTER TABLE Invoice.tbInvoice DROP
	CONSTRAINT DF_Invoice_tb_InvoiceValue,
	CONSTRAINT DF_Invoice_tb_TaxValue,
	CONSTRAINT DF_Invoice_tb_PaidValue,
	CONSTRAINT DF_Invoice_tb_PaidTaxValue,
	COLUMN InvoiceValue,
	COLUMN TaxValue,
	COLUMN PaidValue,
	COLUMN PaidTaxValue
go
ALTER TABLE Invoice.tbInvoice ADD 
	InvoiceValue decimal(18, 5) NOT NULL CONSTRAINT DF_Invoice_tb_InvoiceValue  DEFAULT (0),
	TaxValue decimal(18, 5) NOT NULL CONSTRAINT DF_Invoice_tb_TaxValue  DEFAULT (0),
	PaidValue decimal(18, 5) NOT NULL CONSTRAINT DF_Invoice_tb_PaidValue  DEFAULT (0),
	PaidTaxValue decimal(18, 5) NOT NULL CONSTRAINT DF_Invoice_tb_PaidTaxValue  DEFAULT (0)
go
UPDATE Invoice.tbInvoice
SET
	InvoiceValue = InvoiceValueStore,
	TaxValue = TaxValueStore,
	PaidValue = PaidValueStore,
	PaidTaxValue = PaidTaxValueStore
go
CREATE NONCLUSTERED INDEX IX_Invoice_tbInvoice_AccountCode_Type ON Invoice.tbInvoice
(
	AccountCode ASC,
	InvoiceNumber ASC,
	InvoiceTypeCode ASC
)
INCLUDE (InvoiceValue,TaxValue) 
GO
CREATE NONCLUSTERED INDEX IX_Invoice_tbInvoice_AccountValues ON Invoice.tbInvoice
(
	AccountCode ASC,
	InvoiceStatusCode ASC,
	InvoiceNumber ASC
)
INCLUDE (InvoiceValue,TaxValue) 
GO
ALTER TABLE Invoice.tbInvoice DROP
	COLUMN InvoiceValueStore,
	COLUMN TaxValueStore,
	COLUMN PaidValueStore,
	COLUMN PaidTaxValueStore
go

ALTER TABLE App.tbYearPeriod WITH NOCHECK ADD
	TaxAdjustmentStore money,
	VatAdjustmentStore money
go
UPDATE App.tbYearPeriod
SET TaxAdjustmentStore = TaxAdjustment, VatAdjustmentStore = VatAdjustment
go
ALTER TABLE App.tbYearPeriod DROP 
	CONSTRAINT DF_App_tbYearPeriod_TaxAdjustment,
	CONSTRAINT DF_App_tbYearPeriod_VatAdjustment,
	COLUMN TaxAdjustment,
	COLUMN VatAdjustment
go
ALTER TABLE App.tbYearPeriod ADD 
	TaxAdjustment decimal(18, 5) NOT NULL CONSTRAINT DF_App_tbYearPeriod_TaxAdjustment  DEFAULT ((0)),
	VatAdjustment decimal(18, 5) NOT NULL CONSTRAINT DF_App_tbYearPeriod_VatAdjustment DEFAULT ((0)) 
go
UPDATE App.tbYearPeriod
SET TaxAdjustment = TaxAdjustmentStore, VatAdjustment = VatAdjustmentStore
go
ALTER TABLE App.tbYearPeriod DROP 
	COLUMN TaxAdjustmentStore,
	COLUMN VatAdjustmentStore
go

ALTER TABLE Invoice.tbTask ADD
	TotalValueStore money,
	InvoiceValueStore money,
	TaxValueStore money,
	PaidValueStore money,
	PaidTaxValueStore money
go
UPDATE Invoice.tbTask 
SET
	TotalValueStore = TotalValue,
	InvoiceValueStore = InvoiceValue,
	TaxValueStore = TaxValue,
	PaidValueStore = PaidValue,
	PaidTaxValueStore = PaidTaxValue
go
DROP INDEX IX_Invoice_tbTask_Full ON Invoice.tbTask;
DROP INDEX IX_Invoice_tbTask_InvoiceNumber_TaxCode ON Invoice.tbTask;
DROP INDEX IX_Invoice_tbTask_TaskCode ON Invoice.tbTask;
DROP INDEX IX_Invoice_tbTask_TaxCode ON Invoice.tbTask;
go
ALTER TABLE Invoice.tbTask DROP
	CONSTRAINT DF_Invoice_tbTask_TotalValue,
	CONSTRAINT DF_Invoice_tbActivity_InvoiceValue,
	CONSTRAINT DF_Invoice_tbActivity_TaxValue,
	CONSTRAINT DF_Invoice_tbTask_PaidValue,
	CONSTRAINT DF_Invoice_tbTask_PaidTaxValue,
	COLUMN TotalValue,
	COLUMN InvoiceValue,
	COLUMN TaxValue,
	COLUMN PaidValue,
	COLUMN PaidTaxValue
go
ALTER TABLE Invoice.tbTask ADD 
	TotalValue decimal(18, 5) NOT NULL CONSTRAINT DF_Invoice_tbTask_TotalValue  DEFAULT (0),
	InvoiceValue decimal(18, 5) NOT NULL CONSTRAINT DF_Invoice_tbTask_InvoiceValue  DEFAULT (0),
	TaxValue decimal(18, 5) NOT NULL CONSTRAINT DF_Invoice_tbTask_TaxValue  DEFAULT (0),
	PaidValue decimal(18, 5) NOT NULL CONSTRAINT DF_Invoice_tbTask_PaidValue  DEFAULT (0),
	PaidTaxValue decimal(18, 5) NOT NULL CONSTRAINT DF_Invoice_tbTask_PaidTaxValue  DEFAULT (0)
go
UPDATE Invoice.tbTask
SET
	TotalValue = TotalValueStore,
	InvoiceValue = InvoiceValueStore,
	TaxValue = TaxValueStore,
	PaidValue = PaidValueStore,
	PaidTaxValue = PaidTaxValueStore
go
CREATE NONCLUSTERED INDEX IX_Invoice_tbTask_Full ON Invoice.tbTask
(
	InvoiceNumber ASC,
	CashCode ASC,
	InvoiceValue ASC,
	TaxValue ASC,
	TaxCode ASC
)
go
CREATE NONCLUSTERED INDEX IX_Invoice_tbTask_InvoiceNumber_TaxCode ON Invoice.tbTask
(
	InvoiceNumber ASC,
	TaxCode ASC
)
INCLUDE(CashCode,InvoiceValue,TaxValue)
go
CREATE NONCLUSTERED INDEX IX_Invoice_tbTask_TaskCode ON Invoice.tbTask
(
	TaskCode ASC,
	InvoiceNumber ASC
)
INCLUDE(InvoiceValue,TaxValue)
go
CREATE NONCLUSTERED INDEX IX_Invoice_tbTask_TaxCode ON Invoice.tbTask
(
	TaxCode ASC
)
INCLUDE(InvoiceValue,TaxValue)
go
ALTER TABLE Invoice.tbTask DROP
	COLUMN TotalValueStore,
	COLUMN InvoiceValueStore,
	COLUMN TaxValueStore,
	COLUMN PaidValueStore,
	COLUMN PaidTaxValueStore
go

ALTER TABLE Invoice.tbItem ADD
	TotalValueStore money,
	InvoiceValueStore money,
	TaxValueStore money,
	PaidValueStore money,
	PaidTaxValueStore money
go
UPDATE Invoice.tbItem 
SET
	TotalValueStore = TotalValue,
	InvoiceValueStore = InvoiceValue,
	TaxValueStore = TaxValue,
	PaidValueStore = PaidValue,
	PaidTaxValueStore = PaidTaxValue
go
DROP INDEX IX_Invoice_tbItem_Full ON Invoice.tbItem;
DROP INDEX IX_Invoice_tbItem_InvoiceNumber_TaxCode ON Invoice.tbItem;
DROP INDEX IX_Invoice_tbItem_CashCode ON Invoice.tbItem;
DROP INDEX IX_Invoice_tbItem_TaxCode ON Invoice.tbItem;
go
ALTER TABLE Invoice.tbItem DROP
	CONSTRAINT DF_Invoice_tbItem_TotalValue,
	CONSTRAINT DF_Invoice_tbItem_InvoiceValue,
	CONSTRAINT DF_Invoice_tbItem_TaxValue,
	CONSTRAINT DF_Invoice_tbItem_PaidValue,
	CONSTRAINT DF_Invoice_tbItem_PaidTaxValue,
	COLUMN TotalValue,
	COLUMN InvoiceValue,
	COLUMN TaxValue,
	COLUMN PaidValue,
	COLUMN PaidTaxValue
go
ALTER TABLE Invoice.tbItem ADD 
	TotalValue decimal(18, 5) NOT NULL CONSTRAINT DF_Invoice_tbItem_TotalValue  DEFAULT (0),
	InvoiceValue decimal(18, 5) NOT NULL CONSTRAINT DF_Invoice_tbItem_InvoiceValue  DEFAULT (0),
	TaxValue decimal(18, 5) NOT NULL CONSTRAINT DF_Invoice_tbItem_TaxValue  DEFAULT (0),
	PaidValue decimal(18, 5) NOT NULL CONSTRAINT DF_Invoice_tbItem_PaidValue  DEFAULT (0),
	PaidTaxValue decimal(18, 5) NOT NULL CONSTRAINT DF_Invoice_tbItem_PaidTaxValue  DEFAULT (0)
go
UPDATE Invoice.tbItem
SET
	TotalValue = TotalValueStore,
	InvoiceValue = InvoiceValueStore,
	TaxValue = TaxValueStore,
	PaidValue = PaidValueStore,
	PaidTaxValue = PaidTaxValueStore
go
CREATE NONCLUSTERED INDEX IX_Invoice_tbItem_Full ON Invoice.tbItem
(
	InvoiceNumber ASC,
	CashCode ASC,
	InvoiceValue ASC,
	TaxValue ASC,
	TaxCode ASC
)
go
CREATE NONCLUSTERED INDEX IX_Invoice_tbItem_InvoiceNumber_TaxCode ON Invoice.tbItem
(
	InvoiceNumber ASC,
	TaxCode ASC
)
INCLUDE(CashCode,InvoiceValue,TaxValue)
go
CREATE NONCLUSTERED INDEX IX_Invoice_tbItem_CashCode ON Invoice.tbItem
(
	CashCode ASC,
	InvoiceNumber ASC
)
INCLUDE(InvoiceValue,TaxValue)
go
CREATE NONCLUSTERED INDEX IX_Invoice_tbItem_TaxCode ON Invoice.tbItem
(
	TaxCode ASC
)
INCLUDE(InvoiceValue,TaxValue)
go
ALTER TABLE Invoice.tbItem DROP
	COLUMN TotalValueStore,
	COLUMN InvoiceValueStore,
	COLUMN TaxValueStore,
	COLUMN PaidValueStore,
	COLUMN PaidTaxValueStore
go

ALTER TABLE Invoice.tbChangeLog ADD
	InvoiceValueStore money,
	TaxValueStore money,
	PaidValueStore money,
	PaidTaxValueStore money
go
UPDATE Invoice.tbChangeLog 
SET
	InvoiceValueStore = InvoiceValue,
	TaxValueStore = TaxValue,
	PaidValueStore = PaidValue,
	PaidTaxValueStore = PaidTaxValue
go
ALTER TABLE Invoice.tbChangeLog DROP
	CONSTRAINT DF_Invoice_tbChangeLog_InvoiceValue,
	CONSTRAINT DF_Invoice_tbChangeLogTaxValue,
	CONSTRAINT DF_Invoice_tbChangeLog_PaidValue,
	CONSTRAINT DF_Invoice_tbChangeLog_PaidTaxValue,
	COLUMN InvoiceValue,
	COLUMN TaxValue,
	COLUMN PaidValue,
	COLUMN PaidTaxValue
go
ALTER TABLE Invoice.tbChangeLog ADD 
	InvoiceValue decimal(18, 5) NOT NULL CONSTRAINT DF_Invoice_tbChangeLog_InvoiceValue  DEFAULT (0),
	TaxValue decimal(18, 5) NOT NULL CONSTRAINT DF_Invoice_tbChangeLog_TaxValue  DEFAULT (0),
	PaidValue decimal(18, 5) NOT NULL CONSTRAINT DF_Invoice_tbChangeLog_PaidValue  DEFAULT (0),
	PaidTaxValue decimal(18, 5) NOT NULL CONSTRAINT DF_Invoice_tbChangeLog_PaidTaxValue  DEFAULT (0)
go
UPDATE Invoice.tbChangeLog
SET
	InvoiceValue = InvoiceValueStore,
	TaxValue = TaxValueStore,
	PaidValue = PaidValueStore,
	PaidTaxValue = PaidTaxValueStore
go
ALTER TABLE Invoice.tbChangeLog DROP
	COLUMN InvoiceValueStore,
	COLUMN TaxValueStore,
	COLUMN PaidValueStore,
	COLUMN PaidTaxValueStore
go

ALTER TABLE Invoice.tbMirror ADD
	InvoiceValueStore money,
	InvoiceTaxStore money,
	PaidValueStore money,
	PaidTaxValueStore money
go
UPDATE Invoice.tbMirror 
SET
	InvoiceValueStore = InvoiceValue,
	InvoiceTaxStore = InvoiceTax,
	PaidValueStore = PaidValue,
	PaidTaxValueStore = PaidTaxValue
go
ALTER TABLE Invoice.tbMirror DROP
	CONSTRAINT DF_Invoice_tbMirror_PaidValue,
	CONSTRAINT DF_Invoice_tbMirror_PaidTaxValue,
	COLUMN InvoiceValue,
	COLUMN InvoiceTax,
	COLUMN PaidValue,
	COLUMN PaidTaxValue
go
ALTER TABLE Invoice.tbMirror ADD 
	InvoiceValue decimal(18, 5) NOT NULL CONSTRAINT DF_Invoice_tbMirror_InvoiceValue  DEFAULT (0),
	InvoiceTax decimal(18, 5) NOT NULL CONSTRAINT DF_Invoice_tbMirror_InvoiceTax  DEFAULT (0),
	PaidValue decimal(18, 5) NOT NULL CONSTRAINT DF_Invoice_tbMirror_PaidValue  DEFAULT (0),
	PaidTaxValue decimal(18, 5) NOT NULL CONSTRAINT DF_Invoice_tbMirror_PaidTaxValue  DEFAULT (0)
go
UPDATE Invoice.tbMirror
SET
	InvoiceValue = InvoiceValueStore,
	InvoiceTax = InvoiceTaxStore,
	PaidValue = PaidValueStore,
	PaidTaxValue = PaidTaxValueStore
go
ALTER TABLE Invoice.tbMirror DROP
	COLUMN InvoiceValueStore,
	COLUMN InvoiceTaxStore,
	COLUMN PaidValueStore,
	COLUMN PaidTaxValueStore
go

ALTER TABLE Invoice.tbMirrorItem ADD
	InvoiceValueStore money,
	TaxValueStore money
go
UPDATE Invoice.tbMirrorItem 
SET
	InvoiceValueStore = InvoiceValue,
	TaxValueStore = TaxValue
go
ALTER TABLE Invoice.tbMirrorItem DROP
	COLUMN InvoiceValue,
	COLUMN TaxValue
go
ALTER TABLE Invoice.tbMirrorItem ADD 
	InvoiceValue decimal(18, 5) NOT NULL CONSTRAINT DF_Invoice_tbMirrorItem_InvoiceValue  DEFAULT (0),
	TaxValue decimal(18, 5) NOT NULL CONSTRAINT DF_Invoice_tbMirrorItem_TaxValue  DEFAULT (0)
go
UPDATE Invoice.tbMirrorItem
SET
	InvoiceValue = InvoiceValueStore,
	TaxValue = TaxValueStore
go
ALTER TABLE Invoice.tbMirrorItem DROP
	COLUMN InvoiceValueStore,
	COLUMN TaxValueStore
go

ALTER TABLE Invoice.tbMirrorTask ADD
	InvoiceValueStore money,
	TaxValueStore money
go
UPDATE Invoice.tbMirrorTask 
SET
	InvoiceValueStore = InvoiceValue,
	TaxValueStore = TaxValue
go
ALTER TABLE Invoice.tbMirrorTask DROP
	COLUMN InvoiceValue,
	COLUMN TaxValue
go
ALTER TABLE Invoice.tbMirrorTask ADD 
	InvoiceValue decimal(18, 5) NOT NULL CONSTRAINT DF_Invoice_tbMirrorTask_InvoiceValue  DEFAULT (0),
	TaxValue decimal(18, 5) NOT NULL CONSTRAINT DF_Invoice_tbMirrorTask_TaxValue  DEFAULT (0)
go
UPDATE Invoice.tbMirrorTask
SET
	InvoiceValue = InvoiceValueStore,
	TaxValue = TaxValueStore
go
ALTER TABLE Invoice.tbMirrorTask DROP
	COLUMN InvoiceValueStore,
	COLUMN TaxValueStore
go

ALTER TABLE Invoice.tbMirrorEvent ADD
	PaidValueStore money,
	PaidTaxValueStore money
go
UPDATE Invoice.tbMirrorEvent 
SET
	PaidValueStore = PaidValue,
	PaidTaxValueStore = PaidTaxValue
go
ALTER TABLE Invoice.tbMirrorEvent DROP
	CONSTRAINT DF_Invoice_tbMirrorEvent_PaidValue,
	CONSTRAINT DF_Invoice_tbMirrorEvent_PaidTaxValue,
	COLUMN PaidValue,
	COLUMN PaidTaxValue
go
ALTER TABLE Invoice.tbMirrorEvent ADD 
	PaidValue decimal(18, 5) NOT NULL CONSTRAINT DF_Invoice_tbMirrorEvent_PaidValue  DEFAULT (0),
	PaidTaxValue decimal(18, 5) NOT NULL CONSTRAINT DF_Invoice_tbMirrorEvent_PaidTaxValue  DEFAULT (0)
go
UPDATE Invoice.tbMirrorEvent
SET
	PaidValue = PaidValueStore,
	PaidTaxValue = PaidTaxValueStore
go
ALTER TABLE Invoice.tbMirrorEvent DROP
	COLUMN PaidValueStore,
	COLUMN PaidTaxValueStore
go

ALTER TABLE Cash.tbPeriod ADD
	InvoiceValueStore money,
	InvoiceTaxStore money,
	ForecastValueStore money,
	ForecastTaxStore money
go
UPDATE Cash.tbPeriod 
SET
	InvoiceValueStore = InvoiceValue,
	InvoiceTaxStore = InvoiceTax,
	ForecastValueStore = ForecastValue,
	ForecastTaxStore = ForecastTax
go
ALTER TABLE Cash.tbPeriod DROP
	CONSTRAINT DF_Cash_tbPeriod_InvoiceValue,
	CONSTRAINT DF_Cash_tbPeriod_InvoiceTax,
	CONSTRAINT DF_Cash_tbPeriod_ForecastValue,
	CONSTRAINT DF_Cash_tbPeriod_ForecastTax,
	COLUMN InvoiceValue,
	COLUMN InvoiceTax,
	COLUMN ForecastValue,
	COLUMN ForecastTax
go
ALTER TABLE Cash.tbPeriod ADD 
	InvoiceValue decimal(18, 5) NOT NULL CONSTRAINT DF_Cash_tbPeriod_InvoiceValue  DEFAULT (0),
	InvoiceTax decimal(18, 5) NOT NULL CONSTRAINT DF_Cash_tbPeriod_InvoiceTax  DEFAULT (0),
	ForecastValue decimal(18, 5) NOT NULL CONSTRAINT DF_Cash_tbPeriod_ForecastValue  DEFAULT (0),
	ForecastTax decimal(18, 5) NOT NULL CONSTRAINT DF_Cash_tbPeriod_ForecastTax  DEFAULT (0)
go
UPDATE Cash.tbPeriod
SET
	InvoiceValue = InvoiceValueStore,
	InvoiceTax = InvoiceTaxStore,
	ForecastValue = ForecastValueStore,
	ForecastTax = ForecastTaxStore
go
ALTER TABLE Cash.tbPeriod DROP
	COLUMN InvoiceValueStore,
	COLUMN InvoiceTaxStore,
	COLUMN ForecastValueStore,
	COLUMN ForecastTaxStore
go

ALTER TABLE Task.tbQuote ADD
	TotalPriceStore money,
	RunBackPriceStore money,
	RunOnPriceStore money
go
UPDATE Task.tbQuote 
SET
	TotalPriceStore = TotalPrice,
	RunBackPriceStore = RunBackPrice,
	RunOnPriceStore = RunOnPrice
go
ALTER TABLE Task.tbQuote DROP
	CONSTRAINT DF_Task_tbQuote_TotalPrice,
	CONSTRAINT DF_Task_tbQuote_RunOnPrice,
	CONSTRAINT DF_Task_tbQuote_RunBackPrice,
	COLUMN TotalPrice,
	COLUMN RunOnPrice,
	COLUMN RunBackPrice
go
ALTER TABLE Task.tbQuote ADD 
	TotalPrice decimal(18, 5) NOT NULL CONSTRAINT DF_Task_tbQuote_TotalPrice  DEFAULT (0),
	RunOnPrice decimal(18, 5) NOT NULL CONSTRAINT DF_Task_tbQuote_RunOnPrice  DEFAULT (0),
	RunBackPrice decimal(18, 5) NOT NULL CONSTRAINT DF_Task_tbQuote_RunBackPrice  DEFAULT (0)
go
UPDATE Task.tbQuote
SET
	TotalPrice = TotalPriceStore,
	RunOnPrice = RunOnPriceStore,
	RunBackPrice = RunBackPriceStore
go
ALTER TABLE Task.tbQuote DROP
	COLUMN TotalPriceStore,
	COLUMN RunOnPriceStore,
	COLUMN RunBackPriceStore
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
			CAST(TotalCost AS decimal(18, 5)) TotalCost, InvoicedCost, InvoicedCostPaid, CAST(Profit AS decimal(18, 5)) Profit,
			CAST(UninvoicedCharge AS decimal(18, 5)) UninvoicedCharge, CAST(UnpaidCharge AS decimal(18, 5)) UnpaidCharge,
			CAST(UninvoicedCost AS decimal(18, 5)) UninvoicedCost, CAST(UnpaidCost AS decimal(18, 5)) UnpaidCost,
			ActionOn, ActionedOn, PaymentOn
		FROM profits;

go
ALTER VIEW Org.vwCashAccounts
AS
SELECT        Org.tbAccount.CashAccountCode, Org.tbAccount.CashAccountName, Org.tbOrg.AccountName, Org.tbType.OrganisationType, Org.tbAccount.OpeningBalance, Org.tbAccount.CurrentBalance, Org.tbAccount.SortCode, 
                         Org.tbAccount.AccountNumber, Org.tbAccount.AccountClosed, Org.tbAccount.RowVer
FROM            Org.tbOrg INNER JOIN
                         Org.tbAccount ON Org.tbOrg.AccountCode = Org.tbAccount.AccountCode INNER JOIN
                         Org.tbType ON Org.tbOrg.OrganisationTypeCode = Org.tbType.OrganisationTypeCode;

go
ALTER VIEW Cash.vwFlowVatPeriodAccruals
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
	SELECT YearNumber, StartOn, CAST(HomeSales AS decimal(18,5)) HomeSales, CAST(HomePurchases AS decimal(18,5)) HomePurchases, CAST(ExportSales AS decimal(18,5)) AS ExportSales, 
		CAST(ExportPurchases AS decimal(18,5)) ExportPurchases, CAST(HomeSalesVat AS decimal(18,5)) HomeSalesVat, CAST(HomePurchasesVat AS decimal(18,5)) HomePurchasesVat, 
		CAST(ExportSalesVat AS decimal(18,5)) ExportSalesVat, CAST(ExportPurchasesVat AS decimal(18,5)) ExportPurchasesVat,
		CAST((HomeSalesVat + ExportSalesVat) - (HomePurchasesVat + ExportPurchasesVat) AS decimal(18,5)) VatDue
	FROM vat_accruals;
go
ALTER VIEW Cash.vwFlowVatRecurrenceAccruals
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
	SELECT active_periods.YearNumber, active_periods.StartOn, CAST(ISNULL(HomeSales, 0) AS decimal(18,5)) AS HomeSales, CAST(ISNULL(HomePurchases, 0) AS decimal(18,5)) AS HomePurchases, 
		CAST(ISNULL(ExportSales, 0) AS decimal(18,5)) AS ExportSales, CAST(ISNULL(ExportPurchases, 0) AS decimal(18,5)) AS ExportPurchases, CAST(ISNULL(HomeSalesVat, 0) as decimal(18,5)) AS HomeSalesVat, 
		CAST(ISNULL(HomePurchasesVat, 0) AS decimal(18,5)) AS HomePurchasesVat, CAST(ISNULL(ExportSalesVat, 0) AS decimal(18,5)) AS ExportSalesVat, 
		CAST(ISNULL(ExportPurchasesVat, 0) AS decimal(18,5)) AS ExportPurchasesVat, CAST(ISNULL(VatDue, 0) AS decimal(18,5)) AS VatDue 
	FROM vat_accruals 
		RIGHT OUTER JOIN active_periods ON active_periods.StartOn = vat_accruals.StartOn;	
go
ALTER VIEW Cash.vwTaxCorpTotals
AS
	WITH totals AS
	(
		SELECT netprofit_totals.StartOn, YEAR(App.tbYearPeriod.StartOn) AS PeriodYear, App.tbYear.Description, 
						  App.tbMonth.MonthName + ' ' + LTRIM(STR(YEAR(App.tbYearPeriod.StartOn))) AS Period, App.tbYearPeriod.CorporationTaxRate, 
						  App.tbYearPeriod.TaxAdjustment, SUM(netprofit_totals.NetProfit) AS NetProfit, SUM(netprofit_totals.CorporationTax) AS CorporationTax
		FROM       Cash.vwTaxCorpTotalsByPeriod  netprofit_totals INNER JOIN
							  App.tbYearPeriod ON netprofit_totals.StartOn = App.tbYearPeriod.StartOn INNER JOIN
							  App.tbYear ON App.tbYearPeriod.YearNumber = App.tbYear.YearNumber INNER JOIN
							  App.tbMonth ON App.tbYearPeriod.MonthNumber = App.tbMonth.MonthNumber
		WHERE     (App.tbYear.CashStatusCode BETWEEN 1 AND 2)
		GROUP BY App.tbYear.Description, App.tbMonth.MonthName, netprofit_totals.StartOn, YEAR(App.tbYearPeriod.StartOn), 
							  App.tbYearPeriod.CorporationTaxRate, App.tbYearPeriod.TaxAdjustment
	)
	SELECT StartOn, PeriodYear, [Description], [Period], CorporationTaxRate, TaxAdjustment, CAST(NetProfit AS decimal(18, 5)) NetProfit, CAST(CorporationTax AS decimal(18, 5)) CorporationTax
	FROM totals;
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
			ForecastValue DECIMAL(18, 5) NOT NULL, 
			ForecastTax DECIMAL(18, 5) NOT NULL, 
			InvoiceValue DECIMAL(18, 5) NOT NULL, 
			InvoiceTax DECIMAL(18, 5) NOT NULL);

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
ALTER PROCEDURE Cash.proc_VatBalance(@Balance decimal(18, 5) output)
 AS
  	SET NOCOUNT, XACT_ABORT ON;

	BEGIN TRY
		SELECT TOP (1)  @Balance = Balance FROM Cash.vwTaxVatStatement ORDER BY StartOn DESC, VatDue DESC
  	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
go
ALTER PROCEDURE Org.proc_BalanceToPay(@AccountCode NVARCHAR(10), @Balance DECIMAL(18, 5) = 0 OUTPUT)
AS
	SET NOCOUNT, XACT_ABORT ON;

	BEGIN TRY
		DECLARE @PayBalance BIT

		SELECT @PayBalance = PayBalance FROM Org.tbOrg WHERE AccountCode = @AccountCode

		IF @PayBalance <> 0
			EXEC Org.proc_BalanceOutstanding @AccountCode, @Balance OUTPUT
		ELSE
			BEGIN
			SELECT TOP (1)   @Balance = CASE Invoice.tbType.CashModeCode 
											WHEN 0 THEN ((InvoiceValue + TaxValue) - (PaidValue + PaidTaxValue)) * - 1 
											WHEN 1 THEN (InvoiceValue + TaxValue) - (PaidValue + PaidTaxValue) END 
			FROM            Invoice.tbInvoice INNER JOIN
									 Invoice.tbType ON Invoice.tbInvoice.InvoiceTypeCode = Invoice.tbType.InvoiceTypeCode
			WHERE  Invoice.tbInvoice.AccountCode = @AccountCode AND (Invoice.tbInvoice.InvoiceStatusCode > 0) AND (Invoice.tbInvoice.InvoiceStatusCode < 3) 
			ORDER BY ExpectedOn
			END

		SET @Balance = ISNULL(@Balance, 0)

	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH

go
ALTER PROCEDURE Task.proc_Cost 
	(
	@ParentTaskCode nvarchar(20),
	@TotalCost decimal(18, 5) = 0 OUTPUT
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
ALTER PROCEDURE Task.proc_FullyInvoiced
	(
	@TaskCode nvarchar(20),
	@IsFullyInvoiced bit = 0 output
	)
AS
	SET NOCOUNT, XACT_ABORT ON;

	BEGIN TRY
		DECLARE 
			@InvoiceValue decimal(18, 5)
			, @TotalCharge decimal(18, 5)

		SELECT @InvoiceValue = SUM(InvoiceValue)
		FROM         Invoice.tbTask
		WHERE     (TaskCode = @TaskCode)
	
	
		SELECT @TotalCharge = SUM(TotalCharge)
		FROM         Task.tbTask
		WHERE     (TaskCode = @TaskCode)
	
		IF (@TotalCharge = @InvoiceValue)
			SET @IsFullyInvoiced = 1
		ELSE
			SET @IsFullyInvoiced = 0	
  	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
go
ALTER PROCEDURE Task.proc_ReconcileCharge
	(
	@TaskCode nvarchar(20)
	)
AS
  	SET NOCOUNT, XACT_ABORT ON;

	BEGIN TRY
		DECLARE @InvoiceValue decimal(18, 5)

		SELECT @InvoiceValue = SUM(InvoiceValue)
		FROM         Invoice.tbTask
		WHERE     (TaskCode = @TaskCode)

		UPDATE    Task.tbTask
		SET              TotalCharge = @InvoiceValue, UnitCharge = @InvoiceValue / Quantity
		WHERE     (TaskCode = @TaskCode)	
	
  	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
go

CREATE TABLE Cash.tbPaymentStatus
(
	PaymentStatusCode smallint NOT NULL,
	PaymentStatus nvarchar(20) NOT NULL,
	CONSTRAINT PK_Cash_tbPaymentStatus PRIMARY KEY CLUSTERED (PaymentStatusCode ASC)
)
go
INSERT INTO Cash.tbPaymentStatus (PaymentStatusCode, PaymentStatus)
	VALUES (0, 'Unposted'), (1, 'Payment'), (2, 'Transfer');
go
CREATE TABLE Cash.tbPayment
(
	PaymentCode nvarchar(20) NOT NULL,
	UserId nvarchar(10) NOT NULL,
	PaymentStatusCode smallint NOT NULL,
	AccountCode nvarchar(10) NOT NULL,
	CashAccountCode nvarchar(10) NOT NULL,
	CashCode nvarchar(50) NULL,
	TaxCode nvarchar(10) NULL,
	PaidOn datetime NOT NULL,
	PaidInValue decimal(18, 5) NOT NULL,
	PaidOutValue decimal(18, 5) NOT NULL,
	TaxInValue decimal(18, 5) NOT NULL,
	TaxOutValue decimal(18, 5) NOT NULL,
	PaymentReference nvarchar(50) NULL,
	InsertedBy nvarchar(50) NOT NULL,
	InsertedOn datetime NOT NULL,
	UpdatedBy nvarchar(50) NOT NULL,
	UpdatedOn datetime NOT NULL,
	RowVer timestamp NOT NULL,
	CONSTRAINT PK_Cash_tbPayment PRIMARY KEY CLUSTERED (PaymentCode ASC)
) 
go
ALTER TABLE Cash.tbPayment ADD  CONSTRAINT DF_Cash_tbPayment_PaymentStatusCode  DEFAULT ((0)) FOR PaymentStatusCode
go
ALTER TABLE Cash.tbPayment ADD  CONSTRAINT DF_Cash_tbPayment_PaidOn  DEFAULT (CONVERT(date,getdate())) FOR PaidOn
go
ALTER TABLE Cash.tbPayment ADD  CONSTRAINT DF_Cash_tbPayment_PaidInValue  DEFAULT ((0)) FOR PaidInValue
go
ALTER TABLE Cash.tbPayment ADD  CONSTRAINT DF_Cash_tbPayment_PaidOutValue  DEFAULT ((0)) FOR PaidOutValue
go
ALTER TABLE Cash.tbPayment ADD  CONSTRAINT DF_Cash_tbPayment_TaxInValue  DEFAULT ((0)) FOR TaxInValue
go
ALTER TABLE Cash.tbPayment ADD  CONSTRAINT DF_Cash_tbPayment_TaxOutValue  DEFAULT ((0)) FOR TaxOutValue
go
ALTER TABLE Cash.tbPayment ADD  CONSTRAINT DF_Cash_tbPayment_InsertedBy  DEFAULT (suser_sname()) FOR InsertedBy
go
ALTER TABLE Cash.tbPayment ADD  CONSTRAINT DF_Cash_tbPayment_InsertedOn  DEFAULT (getdate()) FOR InsertedOn
go
ALTER TABLE Cash.tbPayment ADD  CONSTRAINT DF_Cash_tbPayment_UpdatedBy  DEFAULT (suser_sname()) FOR UpdatedBy
go
ALTER TABLE Cash.tbPayment ADD  CONSTRAINT DF_Cash_tbPayment_UpdatedOn  DEFAULT (getdate()) FOR UpdatedOn
go
ALTER TABLE Cash.tbPayment  WITH NOCHECK ADD  CONSTRAINT FK_Cash_tbPayment_App_tbTaxCode FOREIGN KEY(TaxCode)
REFERENCES App.tbTaxCode (TaxCode)
go
ALTER TABLE Cash.tbPayment CHECK CONSTRAINT FK_Cash_tbPayment_App_tbTaxCode
go
ALTER TABLE Cash.tbPayment  WITH CHECK ADD  CONSTRAINT FK_Cash_tbPayment_Cash_tbCode FOREIGN KEY(CashCode)
REFERENCES Cash.tbCode (CashCode)
ON UPDATE CASCADE
go
ALTER TABLE Cash.tbPayment CHECK CONSTRAINT FK_Cash_tbPayment_Cash_tbCode
go
ALTER TABLE Cash.tbPayment  WITH CHECK ADD  CONSTRAINT FK_Cash_tbPayment_Org_tbAccount FOREIGN KEY(CashAccountCode)
REFERENCES Org.tbAccount (CashAccountCode)
ON UPDATE CASCADE
go
ALTER TABLE Cash.tbPayment CHECK CONSTRAINT FK_Cash_tbPayment_Org_tbAccount
go
ALTER TABLE Cash.tbPayment  WITH CHECK ADD  CONSTRAINT FK_Cash_tbPayment_Cash_tbPaymentStatus FOREIGN KEY(PaymentStatusCode)
REFERENCES Cash.tbPaymentStatus (PaymentStatusCode)
go
ALTER TABLE Cash.tbPayment CHECK CONSTRAINT FK_Cash_tbPayment_Cash_tbPaymentStatus
go
ALTER TABLE Cash.tbPayment  WITH CHECK ADD  CONSTRAINT FK_Cash_tbPayment_tbOrg FOREIGN KEY(AccountCode)
REFERENCES Org.tbOrg (AccountCode)
go
ALTER TABLE Cash.tbPayment CHECK CONSTRAINT FK_Cash_tbPayment_tbOrg
go
ALTER TABLE Cash.tbPayment  WITH CHECK ADD  CONSTRAINT FK_Cash_tbPayment_Usr_tbUser FOREIGN KEY(UserId)
REFERENCES Usr.tbUser (UserId)
ON UPDATE CASCADE
go
ALTER TABLE Cash.tbPayment CHECK CONSTRAINT FK_Cash_tbPayment_Usr_tbUser
go
CREATE NONCLUSTERED INDEX IX_Cash_tbPayment ON Cash.tbPayment (PaymentReference ASC)
go
CREATE NONCLUSTERED INDEX IX_Cash_tbPayment_AccountCode ON Cash.tbPayment
(
	AccountCode ASC,
	PaidOn DESC
)
go
CREATE NONCLUSTERED INDEX IX_Cash_tbPayment_CashAccountCode ON Cash.tbPayment
(
	CashAccountCode ASC,
	PaidOn ASC
)
go
CREATE NONCLUSTERED INDEX IX_Cash_tbPayment_CashCode ON Cash.tbPayment
(
	CashCode ASC,
	PaidOn ASC
)
go
CREATE NONCLUSTERED INDEX IX_Cash_tbPayment_PaymentCode_Status ON Cash.tbPayment
(
	AccountCode ASC,
	PaymentStatusCode ASC,
	PaymentCode ASC
)
INCLUDE(PaidInValue,PaidOutValue) 
go
CREATE NONCLUSTERED INDEX IX_Cash_tbPayment_PaymentCode_TaxCode ON Cash.tbPayment
(
	AccountCode ASC,
	PaymentCode ASC,
	TaxCode ASC
)
INCLUDE(PaymentStatusCode,PaidInValue,PaidOutValue) 
go
CREATE NONCLUSTERED INDEX IX_Cash_tbPayment_Status ON Cash.tbPayment
(
	PaymentStatusCode ASC
)
INCLUDE(CashAccountCode,CashCode,PaidOn,PaidInValue,PaidOutValue) 
go
CREATE NONCLUSTERED INDEX IX_Cash_tbPayment_Status_AccountCode ON Cash.tbPayment
(
	PaymentStatusCode ASC,
	AccountCode ASC
)
go
CREATE NONCLUSTERED INDEX IX_Cash_tbPayment_Status_CashAccount_PaidOn ON Cash.tbPayment
(
	PaymentStatusCode ASC,
	CashAccountCode ASC,
	PaidOn ASC
)
INCLUDE(PaymentCode,PaidInValue,PaidOutValue) 
go
CREATE NONCLUSTERED INDEX IX_tbPayment_TaxCode ON Cash.tbPayment
(
	TaxCode ASC
)
INCLUDE(PaidInValue,PaidOutValue) 
go
ALTER TABLE App.tbTaxCode WITH NOCHECK ADD
	Decimals smallint NOT NULL CONSTRAINT DF_App_tbTaxCode_Decimals DEFAULT (2)
go
CREATE TRIGGER Cash.Cash_tbPayment_TriggerInsert
ON Cash.tbPayment
FOR INSERT
AS
	SET NOCOUNT ON;
	BEGIN TRY

		UPDATE payment
		SET PaymentStatusCode = 2
		FROM inserted
			JOIN Cash.tbPayment payment ON inserted.PaymentCode = payment.PaymentCode
			JOIN Cash.tbCode ON inserted.CashCode = Cash.tbCode.CashCode 
			JOIN Cash.tbCategory category ON Cash.tbCode.CategoryCode = category.CategoryCode
		WHERE category.CashTypeCode = 2 AND inserted.PaymentStatusCode = 0

	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
go
ALTER TABLE Cash.tbPayment ENABLE TRIGGER Cash_tbPayment_TriggerInsert
go
CREATE TRIGGER Cash.Cash_tbPayment_TriggerUpdate
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
			DECLARE @AccountCode NVARCHAR(10)
			DECLARE org CURSOR LOCAL FOR 
				SELECT AccountCode 
				FROM inserted
				WHERE PaymentStatusCode = 1

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
	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
go
ALTER TABLE Cash.tbPayment ENABLE TRIGGER Cash_tbPayment_TriggerUpdate
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
			CASE WHEN OpeningBalance< 0 THEN (SELECT CashCode FROM Cash.vwBankCashCodes WHERE CashModeCode = 0)
				WHEN OpeningBalance > 0 THEN  (SELECT CashCode FROM Cash.vwBankCashCodes WHERE CashModeCode = 1)
				ELSE 
					(SELECT CashCode FROM Cash.vwBankCashCodes WHERE CashModeCode = 2)
				END AS CashCode, 
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
ALTER VIEW Cash.vwTaxCorpStatement
AS
	WITH tax_dates AS
	(
		SELECT PayOn, PayFrom, PayTo FROM Cash.fnTaxTypeDueDates(0)
	), period_totals AS
	(
		SELECT (SELECT PayOn FROM tax_dates WHERE totals.StartOn >= PayFrom AND totals.StartOn < PayTo) AS StartOn, CorporationTax
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
	)
	SELECT StartOn, CAST(TaxDue AS decimal(18, 5)) TaxDue, CAST(TaxPaid AS decimal(18, 5)) TaxPaid, CAST(Balance AS decimal(18, 5)) Balance FROM tax_statement 
	WHERE StartOn >= (SELECT MIN(StartOn) FROM App.tbYearPeriod p JOIN App.tbYear y ON p.YearNumber = y.YearNumber  WHERE y.CashStatusCode < 3);

go
ALTER VIEW Cash.vwTaxVatStatement
AS
	WITH vat_dates AS
	(
		SELECT PayOn, PayFrom, PayTo FROM Cash.fnTaxTypeDueDates(1)
	), vatPeriod AS
	(
		SELECT        StartOn, 
			(SELECT PayTo FROM vat_dates WHERE StartOn >= PayFrom AND StartOn < PayTo) AS VatStartOn, VatAdjustment
		FROM            App.tbYearPeriod 
	), vat_codes AS
	(
		SELECT     CashCode
		FROM         Cash.tbTaxType
		WHERE     (TaxTypeCode = 1)
	)
	, vat_results AS
	(
		SELECT VatStartOn AS StartOn,
			SUM(HomeSales) AS HomeSales, SUM(HomePurchases) AS HomePurchases, SUM(ExportSales) AS ExportSales, SUM(ExportPurchases) AS ExportPurchases, 
			SUM(HomeSalesVat) AS HomeSalesVat, SUM(HomePurchasesVat) AS HomePurchasesVat, 
			SUM(ExportSalesVat) AS ExportSalesVat, SUM(ExportPurchasesVat) AS ExportPurchasesVat, SUM(VatDue) AS VatDue
		FROM Cash.vwTaxVatSummary vatCodeDue JOIN vatPeriod ON vatCodeDue.StartOn = vatPeriod.StartOn
		GROUP BY VatStartOn
	), vat_adjustments AS
	(
		SELECT VatStartOn AS StartOn, SUM(VatAdjustment) AS VatAdjustment
		FROM vatPeriod
		GROUP BY VatStartOn
	), vat_unordered AS
	(
		SELECT vat_dates.PayOn AS StartOn, VatDue - a.VatAdjustment AS VatDue, 0 As VatPaid		
		FROM vat_results r JOIN vat_adjustments a ON r.StartOn = a.StartOn
			JOIN vat_dates ON r.StartOn = vat_dates.PayTo
			UNION
		SELECT     Cash.tbPayment.PaidOn AS StartOn, 0 As VatDue, ( Cash.tbPayment.PaidOutValue * -1) + Cash.tbPayment.PaidInValue AS VatPaid
		FROM         Cash.tbPayment INNER JOIN
							  vat_codes ON Cash.tbPayment.CashCode = vat_codes.CashCode	
	), vat_ordered AS
	(
		SELECT ROW_NUMBER() OVER (ORDER BY StartOn, VatDue) AS RowNumber,
			StartOn, VatDue, VatPaid
		FROM vat_unordered
	), vat_statement AS
	(
		SELECT RowNumber, StartOn, VatDue, VatPaid,
			SUM(VatDue+VatPaid) OVER (ORDER BY RowNumber ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS Balance
		FROM vat_ordered
	)
	SELECT RowNumber, StartOn, VatDue, VatPaid, Balance
	FROM vat_statement
	WHERE StartOn >= (SELECT MIN(StartOn) FROM App.tbYearPeriod p JOIN App.tbYear y ON p.YearNumber = y.YearNumber  WHERE y.CashStatusCode < 3);
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
		WHERE     ( Org.tbAccount.AccountClosed = 0) AND (Org.tbAccount.DummyAccount = 0)
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
ALTER VIEW Org.vwStatusReport
AS
	SELECT        Org.vwDatasheet.AccountCode, Org.vwDatasheet.AccountName, Org.vwDatasheet.OrganisationType, Org.vwDatasheet.OrganisationStatus, Org.vwDatasheet.TaxDescription, Org.vwDatasheet.Address, 
							 Org.vwDatasheet.AreaCode, Org.vwDatasheet.PhoneNumber, Org.vwDatasheet.EmailAddress, Org.vwDatasheet.WebSite, Org.vwDatasheet.IndustrySector, 
							 Org.vwDatasheet.AccountSource, Org.vwDatasheet.PaymentTerms, Org.vwDatasheet.PaymentDays, Org.vwDatasheet.ExpectedDays, Org.vwDatasheet.NumberOfEmployees, Org.vwDatasheet.CompanyNumber, Org.vwDatasheet.VatNumber, 
							 Org.vwDatasheet.Turnover, Org.vwDatasheet.OpeningBalance, Org.vwDatasheet.EUJurisdiction, Org.vwDatasheet.BusinessDescription, 
							 Cash.tbPayment.PaymentCode, Usr.tbUser.UserName, App.tbTaxCode.TaxDescription AS PaymentTaxDescription, Org.tbAccount.CashAccountName, Cash.tbCode.CashDescription, Cash.tbPayment.UserId, 
							 Cash.tbPayment.CashAccountCode, Cash.tbPayment.CashCode, Cash.tbPayment.TaxCode, Cash.tbPayment.PaidOn, Cash.tbPayment.PaidInValue, Cash.tbPayment.PaidOutValue, Cash.tbPayment.TaxInValue, 
							 Cash.tbPayment.TaxOutValue, Cash.tbPayment.InsertedBy, Cash.tbPayment.InsertedOn, Cash.tbPayment.UpdatedBy, Cash.tbPayment.UpdatedOn, Cash.tbPayment.PaymentReference
	FROM            Cash.tbPayment INNER JOIN
							 Usr.tbUser ON Cash.tbPayment.UserId = Usr.tbUser.UserId INNER JOIN
							 Org.tbAccount ON Cash.tbPayment.CashAccountCode = Org.tbAccount.CashAccountCode INNER JOIN
							 Cash.tbCode ON Cash.tbPayment.CashCode = Cash.tbCode.CashCode LEFT OUTER JOIN
							 App.tbTaxCode ON Cash.tbPayment.TaxCode = App.tbTaxCode.TaxCode INNER JOIN
							 Org.vwDatasheet ON Cash.tbPayment.AccountCode = Org.vwDatasheet.AccountCode
	WHERE        (Cash.tbPayment.PaymentStatusCode = 1);
go
ALTER VIEW Cash.vwAccountRebuild
AS
	SELECT     Cash.tbPayment.CashAccountCode, Org.tbAccount.OpeningBalance, 
						  Org.tbAccount.OpeningBalance + SUM(Cash.tbPayment.PaidInValue - Cash.tbPayment.PaidOutValue) AS CurrentBalance
	FROM         Cash.tbPayment INNER JOIN
						  Org.tbAccount ON Cash.tbPayment.CashAccountCode = Org.tbAccount.CashAccountCode
	WHERE     (Cash.tbPayment.PaymentStatusCode = 1) 
	GROUP BY Cash.tbPayment.CashAccountCode, Org.tbAccount.OpeningBalance
go
ALTER VIEW Cash.vwStatementReserves
AS
	WITH reserve_account AS
	(
		SELECT  Org.tbAccount.CashAccountCode, Org.tbAccount.CashAccountName, Org.tbAccount.CurrentBalance
		FROM            Org.tbAccount LEFT OUTER JOIN
								 Cash.tbCode ON Org.tbAccount.CashCode = Cash.tbCode.CashCode 
		WHERE        (Org.tbAccount.AccountCode <> (SELECT AccountCode FROM App.tbOptions))
			AND (Cash.tbCode.CashCode IS NULL) AND (Org.tbAccount.DummyAccount = 0)
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
		PayOut, PayIn,
		SUM(PayIn + (PayOut * -1)) OVER (ORDER BY RowNumber) AS Balance,
		CashCode, CashDescription
	FROM unbalanced_reserves 
		JOIN Cash.tbEntryType entry_type ON unbalanced_reserves.CashEntryTypeCode = entry_type.CashEntryTypeCode
go
ALTER VIEW Cash.vwTransfersUnposted
AS
	SELECT        PaymentCode, UserId, PaymentStatusCode, AccountCode, CashAccountCode, CashCode, TaxCode, PaidOn, PaidInValue, PaidOutValue, TaxInValue, TaxOutValue, PaymentReference, InsertedBy, InsertedOn, 
							 UpdatedBy, UpdatedOn, RowVer
	FROM            Cash.tbPayment
	WHERE        (PaymentStatusCode = 2)
go
CREATE VIEW Cash.vwPayments
AS
SELECT        Cash.tbPayment.AccountCode, Cash.tbPayment.PaymentCode, Cash.tbPayment.UserId, Cash.tbPayment.PaymentStatusCode, Cash.tbPayment.CashAccountCode, Cash.tbPayment.CashCode, Cash.tbPayment.TaxCode, 
                         Cash.tbPayment.PaidOn, Cash.tbPayment.PaidInValue, Cash.tbPayment.PaidOutValue, Cash.tbPayment.TaxInValue, Cash.tbPayment.TaxOutValue, Cash.tbPayment.PaymentReference, Cash.tbPayment.InsertedBy, 
                         Cash.tbPayment.InsertedOn, Cash.tbPayment.UpdatedBy, Cash.tbPayment.UpdatedOn, Usr.tbUser.UserName, App.tbTaxCode.TaxDescription, Org.tbAccount.CashAccountName, Cash.tbCode.CashDescription
FROM            Cash.tbPayment INNER JOIN
                         Usr.tbUser ON Cash.tbPayment.UserId = Usr.tbUser.UserId INNER JOIN
                         Org.tbAccount ON Cash.tbPayment.CashAccountCode = Org.tbAccount.CashAccountCode INNER JOIN
                         Cash.tbCode ON Cash.tbPayment.CashCode = Cash.tbCode.CashCode LEFT OUTER JOIN
                         App.tbTaxCode ON Cash.tbPayment.TaxCode = App.tbTaxCode.TaxCode
WHERE        (Cash.tbPayment.PaymentStatusCode = 1);

go
IF NOT OBJECT_ID('Org.vwPayments') IS NULL
	DROP VIEW Org.vwPayments;
go
CREATE VIEW Cash.vwPaymentsListing
AS
SELECT        TOP (100) PERCENT Org.tbOrg.AccountCode, Org.tbOrg.AccountName, Org.tbType.OrganisationType, Org.tbStatus.OrganisationStatus, Cash.tbPayment.PaymentCode, Usr.tbUser.UserName, 
                         App.tbTaxCode.TaxDescription AS PaymentTaxDescription, Org.tbAccount.CashAccountName, Cash.tbCode.CashDescription, Cash.tbPayment.UserId, Cash.tbPayment.CashAccountCode, Cash.tbPayment.CashCode, 
                         Cash.tbPayment.TaxCode, CONCAT(YEAR(Cash.tbPayment.PaidOn), Format(MONTH(Cash.tbPayment.PaidOn), '00')) AS Period, Cash.tbPayment.PaidOn, Cash.tbPayment.PaidInValue, Cash.tbPayment.PaidOutValue, 
                         Cash.tbPayment.TaxInValue, Cash.tbPayment.TaxOutValue, Cash.tbPayment.InsertedBy, Cash.tbPayment.InsertedOn, Cash.tbPayment.UpdatedBy, Cash.tbPayment.UpdatedOn, Cash.tbPayment.PaymentReference
FROM            Cash.tbPayment INNER JOIN
                         Usr.tbUser ON Cash.tbPayment.UserId = Usr.tbUser.UserId INNER JOIN
                         Org.tbAccount ON Cash.tbPayment.CashAccountCode = Org.tbAccount.CashAccountCode INNER JOIN
                         Cash.tbCode ON Cash.tbPayment.CashCode = Cash.tbCode.CashCode LEFT OUTER JOIN
                         App.tbTaxCode ON Cash.tbPayment.TaxCode = App.tbTaxCode.TaxCode INNER JOIN
                         Org.tbOrg ON Cash.tbPayment.AccountCode = Org.tbOrg.AccountCode INNER JOIN
                         Org.tbType ON Org.tbOrg.OrganisationTypeCode = Org.tbType.OrganisationTypeCode INNER JOIN
                         Org.tbStatus ON Org.tbOrg.OrganisationStatusCode = Org.tbStatus.OrganisationStatusCode
WHERE        (Cash.tbPayment.PaymentStatusCode = 1) 
ORDER BY Cash.tbPayment.AccountCode, Cash.tbPayment.PaidOn DESC;
go
IF NOT OBJECT_ID('Org.vwPaymentsListing') IS NULL
	DROP VIEW Org.vwPaymentsListing
go
CREATE VIEW Cash.vwPaymentsUnposted
AS
SELECT        PaymentCode, UserId, PaymentStatusCode, AccountCode, CashAccountCode, CashCode, TaxCode, PaidOn, PaidInValue, PaidOutValue, TaxInValue, TaxOutValue, PaymentReference, InsertedBy, InsertedOn, 
                         UpdatedBy, UpdatedOn, RowVer
FROM            Cash.tbPayment
WHERE        (PaymentStatusCode = 0)
go
IF NOT OBJECT_ID('Org.vwPaymentsUnposted') IS NULL
	DROP VIEW Org.vwPaymentsUnposted
go
ALTER VIEW Org.vwStatement 
AS
	WITH payment_data AS
	(
		SELECT Cash.tbPayment.AccountCode, Cash.tbPayment.PaidOn AS TransactedOn, 2 AS OrderBy, 
							  Cash.tbPayment.PaymentReference AS Reference, Cash.tbPaymentStatus.PaymentStatus AS StatementType, 
							  CASE WHEN PaidInValue > 0 THEN PaidInValue ELSE PaidOutValue * - 1 END AS Charge
		FROM         Cash.tbPayment INNER JOIN
							  Cash.tbPaymentStatus ON Cash.tbPayment.PaymentStatusCode = Cash.tbPaymentStatus.PaymentStatusCode
	), payments AS
	(
		SELECT     AccountCode, TransactedOn, OrderBy, Reference, StatementType, SUM(Charge) AS Charge
		FROM     payment_data
		GROUP BY AccountCode, TransactedOn, OrderBy, Reference, StatementType
	), invoices AS
	(
		SELECT Invoice.tbInvoice.AccountCode, Invoice.tbInvoice.InvoicedOn AS TransactedOn, 1 AS OrderBy, Invoice.tbInvoice.InvoiceNumber AS Reference, 
							  Invoice.tbType.InvoiceType AS StatementType, 
							  CASE CashModeCode WHEN 0 THEN Invoice.tbInvoice.InvoiceValue + Invoice.tbInvoice.TaxValue WHEN 1 THEN (Invoice.tbInvoice.InvoiceValue + Invoice.tbInvoice.TaxValue)
							   * - 1 END AS Charge
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
		SELECT AccountCode, CAST(RowNumber AS INT) AS RowNumber, TransactedOn, OrderBy, Reference, StatementType, CAST(Charge AS decimal(18,5)) AS Charge,
			CAST(SUM(Charge) OVER (PARTITION BY AccountCode ORDER BY RowNumber ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS decimal(18,5)) AS Balance
		FROM statement_data;

go
CREATE PROCEDURE Cash.proc_PaymentPostMisc
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
		WHERE     (InvoiceTypeCode = @InvoiceTypeCode)

		UPDATE    Cash.tbPayment
		SET		PaymentStatusCode = 1,
			TaxInValue = 
				CASE TaxRate WHEN 0 THEN 0
				ELSE
				(
					CASE App.tbTaxCode.RoundingCode 
						WHEN 0 THEN ROUND(Cash.tbPayment.PaidInValue - ( Cash.tbPayment.PaidInValue / (1 + App.tbTaxCode.TaxRate)), Decimals) 
						WHEN 1 THEN ROUND(Cash.tbPayment.PaidInValue - ( Cash.tbPayment.PaidInValue / (1 + App.tbTaxCode.TaxRate)), Decimals, 1) 
					END
				)
				END, 
			TaxOutValue = 
				CASE TaxRate WHEN 0 THEN 0
				ELSE
				(
					CASE App.tbTaxCode.RoundingCode 
						WHEN 0 THEN ROUND(Cash.tbPayment.PaidOutValue - ( Cash.tbPayment.PaidOutValue / (1 + App.tbTaxCode.TaxRate)), Decimals) 
						WHEN 1 THEN ROUND(Cash.tbPayment.PaidOutValue - ( Cash.tbPayment.PaidOutValue / (1 + App.tbTaxCode.TaxRate)), Decimals, 1) 
					END
				)
				END
		FROM         Cash.tbPayment INNER JOIN
							  App.tbTaxCode ON Cash.tbPayment.TaxCode = App.tbTaxCode.TaxCode
		WHERE     (PaymentCode = @PaymentCode)

		INSERT INTO Invoice.tbInvoice
								 (InvoiceNumber, UserId, AccountCode, InvoiceTypeCode, InvoiceStatusCode, InvoicedOn, DueOn, ExpectedOn, InvoiceValue, TaxValue, PaidValue, PaidTaxValue, Printed)
		SELECT        @InvoiceNumber AS InvoiceNumber, Cash.tbPayment.UserId, Cash.tbPayment.AccountCode, @InvoiceTypeCode AS InvoiceTypeCode, 3 AS InvoiceStatusCode, 
								Cash.tbPayment.PaidOn, Cash.tbPayment.PaidOn AS DueOn, Cash.tbPayment.PaidOn AS ExpectedOn,
								CASE WHEN PaidInValue > 0 THEN PaidInValue - TaxInValue
									WHEN PaidOutValue > 0 THEN PaidOutValue - TaxOutValue
								END AS InvoiceValue, 
								CASE WHEN Cash.tbPayment.PaidInValue > 0 THEN Cash.tbPayment.TaxInValue 
									WHEN Cash.tbPayment.PaidOutValue > 0 THEN Cash.tbPayment.TaxOutValue
								END AS TaxValue, 
								CASE WHEN PaidInValue > 0 THEN PaidInValue - TaxInValue
									WHEN PaidOutValue > 0 THEN PaidOutValue - TaxOutValue
								END AS PaidValue, 
								CASE WHEN Cash.tbPayment.PaidInValue > 0 THEN Cash.tbPayment.TaxInValue 
									WHEN Cash.tbPayment.PaidOutValue > 0 THEN Cash.tbPayment.TaxOutValue
								END AS PaidTaxValue, 
								1 AS Printed
		FROM            Cash.tbPayment INNER JOIN
								 App.tbTaxCode ON Cash.tbPayment.TaxCode = App.tbTaxCode.TaxCode
		WHERE        ( Cash.tbPayment.PaymentCode = @PaymentCode)


		INSERT INTO Invoice.tbItem
							(InvoiceNumber, CashCode, InvoiceValue, TaxValue, PaidValue, PaidTaxValue, TaxCode)
		SELECT     @InvoiceNumber AS InvoiceNumber, Cash.tbPayment.CashCode, 
								CASE WHEN PaidInValue > 0 THEN PaidInValue - TaxInValue
									WHEN PaidOutValue > 0 THEN PaidOutValue - TaxOutValue
								END AS InvoiceValue, 
								CASE WHEN Cash.tbPayment.PaidInValue > 0 THEN Cash.tbPayment.TaxInValue 
									WHEN Cash.tbPayment.PaidOutValue > 0 THEN Cash.tbPayment.TaxOutValue
								END AS TaxValue, 
								CASE WHEN PaidInValue > 0 THEN PaidInValue - TaxInValue
									WHEN PaidOutValue > 0 THEN PaidOutValue - TaxOutValue
								END AS PaidValue, 
								CASE WHEN Cash.tbPayment.PaidInValue > 0 THEN Cash.tbPayment.TaxInValue 
									WHEN Cash.tbPayment.PaidOutValue > 0 THEN Cash.tbPayment.TaxOutValue
								END AS PaidTaxValue, 
							Cash.tbPayment.TaxCode
		FROM         Cash.tbPayment INNER JOIN
							  App.tbTaxCode ON Cash.tbPayment.TaxCode = App.tbTaxCode.TaxCode
		WHERE     ( Cash.tbPayment.PaymentCode = @PaymentCode)

		UPDATE Invoice.tbItem
		SET PaidValue = InvoiceValue, PaidTaxValue = TaxValue
		WHERE InvoiceNumber = @InvoiceNumber

		UPDATE  Org.tbAccount
		SET CurrentBalance = CASE WHEN PaidInValue > 0 THEN Org.tbAccount.CurrentBalance + PaidInValue ELSE Org.tbAccount.CurrentBalance - PaidOutValue END
		FROM         Org.tbAccount INNER JOIN
							  Cash.tbPayment ON Org.tbAccount.CashAccountCode = Cash.tbPayment.CashAccountCode
		WHERE Cash.tbPayment.PaymentCode = @PaymentCode

		COMMIT TRANSACTION

  	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH

go
IF NOT OBJECT_ID('Org.proc_PaymentPostMisc') IS NULL
	DROP PROCEDURE Org.proc_PaymentPostMisc;
go
ALTER PROCEDURE Cash.proc_PayAccrual (@PaymentCode NVARCHAR(20))
AS
    SET NOCOUNT, XACT_ABORT ON;

	BEGIN TRY
		
		IF EXISTS (	SELECT        *
					FROM            Cash.tbPayment 
					WHERE        (PaymentStatusCode = 2) 
						AND UserId = (SELECT UserId FROM Usr.vwCredentials))
			BEGIN

			BEGIN TRANSACTION
			EXEC Cash.proc_PaymentPostMisc @PaymentCode	
			COMMIT TRANSACTION
			
			END

  	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH

go
ALTER PROCEDURE Org.proc_BalanceOutstanding 
	(
	@AccountCode nvarchar(10),
	@Balance decimal(18, 5) = 0 OUTPUT
	)
AS
   	SET NOCOUNT, XACT_ABORT ON;

	BEGIN TRY		
		
		SELECT @Balance = ISNULL(Balance, 0) FROM Org.vwBalanceOutstanding WHERE AccountCode = @AccountCode

		IF EXISTS(SELECT     AccountCode
				  FROM         Cash.tbPayment
				  WHERE     (PaymentStatusCode = 0) AND (AccountCode = @AccountCode)) AND (@Balance <> 0)
			BEGIN
			SELECT  @Balance = @Balance - SUM(PaidInValue - PaidOutValue) 
			FROM         Cash.tbPayment
			WHERE     (PaymentStatusCode = 0) AND (AccountCode = @AccountCode)		
			END
		
  	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH

go
CREATE PROCEDURE Cash.proc_NextPaymentCode (@PaymentCode NVARCHAR(20) OUTPUT)
AS
	SET NOCOUNT, XACT_ABORT ON;

	BEGIN TRY
		SELECT @PaymentCode = PaymentCode FROM Cash.vwPaymentCode;
		WHILE EXISTS (SELECT * FROM Cash.tbPayment WHERE PaymentCode = @PaymentCode)
			SELECT @PaymentCode = PaymentCode FROM Cash.vwPaymentCode;
	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH

go
IF NOT OBJECT_ID('Org.proc_NextPaymentCode') IS NULL
	DROP PROCEDURE Org.proc_NextPaymentCode
go
IF NOT OBJECT_ID('Org.proc_PaymentAdd') IS NULL
	DROP PROCEDURE Org.proc_PaymentAdd;
go
CREATE PROCEDURE Cash.proc_PaymentDelete
	(
	@PaymentCode nvarchar(20)
	)
 AS
  	SET NOCOUNT, XACT_ABORT ON;

	BEGIN TRY
		DECLARE 
			@AccountCode nvarchar(10)
			, @CashAccountCode nvarchar(10)

		SELECT  @AccountCode = AccountCode, @CashAccountCode = CashAccountCode
		FROM         Cash.tbPayment
		WHERE     (PaymentCode = @PaymentCode)

		DELETE FROM Cash.tbPayment
		WHERE     (PaymentCode = @PaymentCode)
	
		EXEC Org.proc_Rebuild @AccountCode

		BEGIN TRANSACTION
		EXEC Cash.proc_AccountRebuild @CashAccountCode
		COMMIT TRANSACTION

  	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH

go
IF NOT OBJECT_ID('Org.proc_PaymentDelete') IS NULL
	DROP PROCEDURE Org.proc_PaymentDelete;
go
CREATE PROCEDURE Cash.proc_PaymentMove
	(
	@PaymentCode nvarchar(20),
	@CashAccountCode nvarchar(10)
	)
  AS
    SET NOCOUNT, XACT_ABORT ON;

	BEGIN TRY
		DECLARE @OldAccountCode nvarchar(10)

		SELECT @OldAccountCode = CashAccountCode
		FROM         Cash.tbPayment
		WHERE     (PaymentCode = @PaymentCode)
	
		BEGIN TRANSACTION
	
		UPDATE Cash.tbPayment 
		SET CashAccountCode = @CashAccountCode,
			UpdatedOn = CURRENT_TIMESTAMP,
			UpdatedBy = (suser_sname())
		WHERE PaymentCode = @PaymentCode	

		EXEC Cash.proc_AccountRebuild @CashAccountCode
		EXEC Cash.proc_AccountRebuild @OldAccountCode
	
		COMMIT TRANSACTION
	 
  	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH

go
CREATE PROCEDURE Cash.proc_PaymentPostReconcile
	(
	@PaymentCode nvarchar(20),
	@PostValue decimal(18, 5),
	@CashCode nvarchar(50),
	@TaxCode nvarchar(5),
	@InvoiceTypeCode smallint
	)
 AS
 	SET NOCOUNT, XACT_ABORT ON;

	BEGIN TRY
		DECLARE 
			@InvoiceNumber nvarchar(20)
			, @NextNumber int;

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

		UPDATE    Invoice.tbType
		SET              NextNumber = @NextNumber + 1
		WHERE     (InvoiceTypeCode = @InvoiceTypeCode)

		INSERT INTO Invoice.tbInvoice
								 (InvoiceNumber, UserId, AccountCode, InvoiceTypeCode, InvoiceStatusCode, InvoicedOn, DueOn, ExpectedOn, Printed)
		SELECT        @InvoiceNumber AS InvoiceNumber, Cash.tbPayment.UserId, Cash.tbPayment.AccountCode, @InvoiceTypeCode AS InvoiceTypeCode, 3 AS InvoiceStatusCode, 
								Cash.tbPayment.PaidOn, Cash.tbPayment.PaidOn AS DueOn, Cash.tbPayment.PaidOn AS ExpectedOn, 1 AS Printed
		FROM            Cash.tbPayment 
		WHERE        ( Cash.tbPayment.PaymentCode = @PaymentCode)

		INSERT INTO Invoice.tbItem (InvoiceNumber, CashCode, TotalValue, TaxCode)
		VALUES (@InvoiceNumber, @CashCode, @PostValue, @TaxCode)

		UPDATE Invoice.tbItem
		SET PaidValue = InvoiceValue, PaidTaxValue = TaxValue
		WHERE InvoiceNumber = @InvoiceNumber

		EXEC Invoice.proc_Total @InvoiceNumber

  	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
go
ALTER VIEW Invoice.vwOutstanding
AS
	WITH invoiced_items AS
	(
		SELECT        Invoice.tbItem.InvoiceNumber, '' AS TaskCode, Invoice.tbItem.CashCode, Invoice.tbItem.TaxCode, (Invoice.tbItem.InvoiceValue + Invoice.tbItem.TaxValue) - (Invoice.tbItem.PaidValue + Invoice.tbItem.PaidTaxValue)
								  AS OutstandingValue, CASE WHEN InvoiceValue = 0 THEN 0 ELSE TaxValue / InvoiceValue END AS TaxRate, App.tbTaxCode.RoundingCode, App.tbTaxCode.Decimals
		FROM            Invoice.tbItem INNER JOIN
								 App.tbTaxCode ON Invoice.tbItem.TaxCode = App.tbTaxCode.TaxCode
	), invoiced_tasks AS
	(
		SELECT        Invoice.tbTask.InvoiceNumber, Invoice.tbTask.TaskCode, Invoice.tbTask.CashCode, Invoice.tbTask.TaxCode, (Invoice.tbTask.InvoiceValue + Invoice.tbTask.TaxValue) 
								 - (Invoice.tbTask.PaidValue + Invoice.tbTask.PaidTaxValue) AS OutstandingValue, 
									CASE WHEN InvoiceValue = 0 THEN 0 ELSE TaxValue / InvoiceValue END AS TaxRate, App.tbTaxCode.RoundingCode, App.tbTaxCode.Decimals
		FROM            Invoice.tbTask INNER JOIN
								 App.tbTaxCode ON Invoice.tbTask.TaxCode = App.tbTaxCode.TaxCode
	), invoices_outstanding AS
	(
		SELECT        InvoiceNumber AS InvoiceNumber, TaskCode AS TaskCode, CashCode AS CashCode, TaxCode AS TaxCode, OutstandingValue, TaxRate, RoundingCode, Decimals
		FROM            invoiced_items
		UNION
		SELECT        InvoiceNumber AS InvoiceNumber, TaskCode AS TaskCode, CashCode AS CashCode, TaxCode AS TaxCode, OutstandingValue, TaxRate, RoundingCode, Decimals
		FROM            invoiced_tasks
	)
	SELECT Invoice.tbInvoice.AccountCode, Invoice.tbInvoice.DueOn, Invoice.tbInvoice.ExpectedOn, Invoice.tbInvoice.InvoiceNumber, invoices_outstanding.TaskCode, Invoice.tbInvoice.InvoiceStatusCode, 
							 Invoice.tbType.CashModeCode, invoices_outstanding.CashCode, invoices_outstanding.TaxCode, invoices_outstanding.TaxRate, invoices_outstanding.RoundingCode, invoices_outstanding.Decimals,
							 CASE WHEN Invoice.tbType.CashModeCode = 0 THEN OutstandingValue * - 1 ELSE OutstandingValue END AS ItemValue
	FROM            invoices_outstanding INNER JOIN
							 Invoice.tbInvoice ON invoices_outstanding.InvoiceNumber = Invoice.tbInvoice.InvoiceNumber INNER JOIN
							 Invoice.tbType ON Invoice.tbInvoice.InvoiceTypeCode = Invoice.tbType.InvoiceTypeCode
	WHERE        (Invoice.tbInvoice.InvoiceStatusCode = 1) OR
							 (Invoice.tbInvoice.InvoiceStatusCode = 2);

go
IF NOT OBJECT_ID('Org.proc_PaymentMove') IS NULL
	DROP PROCEDURE Org.proc_PaymentMove;
go
IF NOT OBJECT_ID('Org.proc_PaymentPostPaidIn') IS NULL
	DROP PROCEDURE Org.proc_PaymentPostPaidIn;
go
IF NOT OBJECT_ID('Org.proc_PaymentPostPaidOut') IS NULL
	DROP PROCEDURE Org.proc_PaymentPostPaidOut;
go
CREATE PROCEDURE Cash.proc_PaymentPostPaidIn
	(
	@PaymentCode nvarchar(20),
	@PostValue decimal(18, 5)  
	)
 AS
  	SET NOCOUNT, XACT_ABORT ON;

	BEGIN TRY
		DECLARE 
			@InvoiceNumber nvarchar(20)
			, @TaskCode nvarchar(20)
			, @TaxRate real
			, @ItemValue decimal(18, 5)
			, @RoundingCode smallint
			, @PaidValue decimal(18, 5)	
			, @PaidTaxValue decimal(18, 5)
			, @TaxInValue decimal(18, 5) = 0
			, @TaxOutValue decimal(18, 5) = 0
			, @CashCode nvarchar(50)	
			, @TaxCode nvarchar(10)
			, @Decimals smallint

	
		DECLARE curPaidIn CURSOR LOCAL FOR
			SELECT     Invoice.vwOutstanding.InvoiceNumber, Invoice.vwOutstanding.TaskCode, Invoice.vwOutstanding.CashCode, Invoice.vwOutstanding.TaxCode, 
								  Invoice.vwOutstanding.TaxRate, Invoice.vwOutstanding.ItemValue, Invoice.vwOutstanding.RoundingCode, Invoice.vwOutstanding.Decimals
			FROM         Invoice.vwOutstanding INNER JOIN
								  Cash.tbPayment ON Invoice.vwOutstanding.AccountCode = Cash.tbPayment.AccountCode
			WHERE     ( Cash.tbPayment.PaymentCode = @PaymentCode)
			ORDER BY Invoice.vwOutstanding.CashModeCode, Invoice.vwOutstanding.ExpectedOn

		OPEN curPaidIn
		FETCH NEXT FROM curPaidIn INTO @InvoiceNumber, @TaskCode, @CashCode, @TaxCode, @TaxRate, @ItemValue, @RoundingCode, @Decimals
		WHILE @@FETCH_STATUS = 0 and @PostValue < 0
			BEGIN
			IF (@PostValue + @ItemValue) > 0
				SET @ItemValue = @PostValue * -1

			SET @PaidTaxValue = 
				CASE @TaxRate WHEN 0 THEN 0
				ELSE	
				(
					CASE @RoundingCode 
						WHEN 0 THEN ROUND(ABS(@ItemValue) - (ABS(@ItemValue) / (1 + @TaxRate)), @Decimals) 
						WHEN 1 THEN ROUND(ABS(@ItemValue) - (ABS(@ItemValue) / (1 + @TaxRate)), @Decimals, 1) 
					END
				)
				END

			SET @PaidValue = ABS(@ItemValue) - @PaidTaxValue
				
			SET @PostValue = @PostValue + @ItemValue
		
			IF LEN(ISNULL(@TaskCode, '')) = 0
				BEGIN
				UPDATE    Invoice.tbItem
				SET              PaidValue = PaidValue + @PaidValue, PaidTaxValue = PaidTaxValue + @PaidTaxValue
				WHERE     (InvoiceNumber = @InvoiceNumber) AND (CashCode = @CashCode)
				END
			ELSE
				BEGIN
				UPDATE   Invoice.tbTask
				SET              PaidValue = PaidValue + @PaidValue, PaidTaxValue = PaidTaxValue + @PaidTaxValue
				WHERE     (InvoiceNumber = @InvoiceNumber) AND (TaskCode = @TaskCode)				
				END

			EXEC Invoice.proc_Total @InvoiceNumber
		        		  
			SET @TaxInValue += CASE WHEN @ItemValue > 0 THEN @PaidTaxValue ELSE 0 END
			SET @TaxOutValue += CASE WHEN @ItemValue < 0 THEN @PaidTaxValue ELSE 0 END	
				
			FETCH NEXT FROM curPaidIn INTO @InvoiceNumber, @TaskCode, @CashCode, @TaxCode, @TaxRate, @ItemValue, @RoundingCode, @Decimals
			END
	
		CLOSE curPaidIn
		DEALLOCATE curPaidIn
	
	
		IF NOT @CashCode IS NULL
			BEGIN
			UPDATE    Cash.tbPayment
			SET      PaymentStatusCode = 1, TaxInValue = @TaxInValue, TaxOutValue = @TaxOutValue, 
				CashCode = ISNULL(@CashCode, Cash.tbPayment.CashCode), 
				TaxCode = ISNULL(@TaxCode, Cash.tbPayment.TaxCode)
			WHERE     (PaymentCode = @PaymentCode)
			END	
			
  	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
go
CREATE PROCEDURE Cash.proc_PaymentPostPaidOut
	(
	@PaymentCode nvarchar(20),
	@PostValue decimal(18, 5)  
	)
 AS
  	SET NOCOUNT, XACT_ABORT ON;

	BEGIN TRY
		DECLARE 
			@InvoiceNumber nvarchar(20)	
			, @TaskCode nvarchar(20)
			, @TaxRate real
			, @ItemValue decimal(18, 5)
			, @RoundingCode smallint
			, @PaidValue decimal(18, 5)	
			, @PaidTaxValue decimal(18, 5)
			, @TaxInValue decimal(18, 5) = 0
			, @TaxOutValue decimal(18, 5) = 0
			, @CashCode nvarchar(50)	
			, @TaxCode nvarchar(10)
			, @Decimals smallint;


		DECLARE curPaidOut CURSOR LOCAL FOR
			SELECT     Invoice.vwOutstanding.InvoiceNumber, Invoice.vwOutstanding.TaskCode, Invoice.vwOutstanding.CashCode, Invoice.vwOutstanding.TaxCode, 
								  Invoice.vwOutstanding.TaxRate, Invoice.vwOutstanding.ItemValue, Invoice.vwOutstanding.RoundingCode, Invoice.vwOutstanding.Decimals
			FROM         Invoice.vwOutstanding INNER JOIN
								  Cash.tbPayment ON Invoice.vwOutstanding.AccountCode = Cash.tbPayment.AccountCode
			WHERE     ( Cash.tbPayment.PaymentCode = @PaymentCode)
			ORDER BY Invoice.vwOutstanding.CashModeCode DESC, Invoice.vwOutstanding.ExpectedOn

		OPEN curPaidOut
		FETCH NEXT FROM curPaidOut INTO @InvoiceNumber, @TaskCode, @CashCode, @TaxCode, @TaxRate, @ItemValue, @RoundingCode, @Decimals
		WHILE @@FETCH_STATUS = 0 and @PostValue > 0
			BEGIN
			IF (@PostValue + @ItemValue) < 0
				SET @ItemValue = @PostValue * -1

			SET @PaidTaxValue = 
				CASE @TaxRate WHEN 0 THEN 0
				ELSE
				(
					CASE @RoundingCode 
						WHEN 0 THEN ROUND(ABS(@ItemValue) - (ABS(@ItemValue) / (1 + @TaxRate)), @Decimals) 
						WHEN 1 THEN ROUND(ABS(@ItemValue) - (ABS(@ItemValue) / (1 + @TaxRate)), @Decimals, 1) 
					END
				)
				END

			SET @PaidValue = ABS(@ItemValue) - @PaidTaxValue
				
			SET @PostValue = @PostValue + @ItemValue
		
			IF LEN(ISNULL(@TaskCode, '')) = 0
				BEGIN
				UPDATE    Invoice.tbItem
				SET              PaidValue = PaidValue + @PaidValue, PaidTaxValue = PaidTaxValue + @PaidTaxValue
				WHERE     (InvoiceNumber = @InvoiceNumber) AND (CashCode = @CashCode)
				END
			ELSE
				BEGIN
				UPDATE   Invoice.tbTask
				SET              PaidValue = PaidValue + @PaidValue, PaidTaxValue = PaidTaxValue + @PaidTaxValue
				WHERE     (InvoiceNumber = @InvoiceNumber) AND (TaskCode = @TaskCode)				
				END

			EXEC Invoice.proc_Total @InvoiceNumber
		        		  
			SET @TaxInValue += CASE WHEN @ItemValue > 0 THEN @PaidTaxValue ELSE 0 END
			SET @TaxOutValue += CASE WHEN @ItemValue < 0 THEN @PaidTaxValue ELSE 0 END	
				
			FETCH NEXT FROM curPaidOut INTO @InvoiceNumber, @TaskCode, @CashCode, @TaxCode, @TaxRate, @ItemValue, @RoundingCode, @Decimals
			END
		
		CLOSE curPaidOut
		DEALLOCATE curPaidOut

		IF NOT @CashCode IS NULL
			BEGIN
			UPDATE    Cash.tbPayment
			SET      PaymentStatusCode = 1, TaxInValue = @TaxInValue, TaxOutValue = @TaxOutValue, 
				CashCode = ISNULL(@CashCode, Cash.tbPayment.CashCode), 
				TaxCode = ISNULL(@TaxCode, Cash.tbPayment.TaxCode)
			WHERE     (PaymentCode = @PaymentCode)
			END
	
  	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH

go
CREATE PROCEDURE Cash.proc_PaymentPostInvoiced (@PaymentCode nvarchar(20))
AS
	SET NOCOUNT, XACT_ABORT ON;

	BEGIN TRY
		DECLARE 
			@AccountCode nvarchar(10)
			, @CashModeCode smallint
			, @PostValue decimal(18, 5)

		SELECT   @PostValue = CASE WHEN PaidInValue = 0 THEN PaidOutValue ELSE PaidInValue * -1 END,
			@AccountCode = Org.tbOrg.AccountCode,
			@CashModeCode = CASE WHEN PaidInValue = 0 THEN 0 ELSE 1 END
		FROM         Cash.tbPayment INNER JOIN
							  Org.tbOrg ON Cash.tbPayment.AccountCode = Org.tbOrg.AccountCode
		WHERE     ( Cash.tbPayment.PaymentCode = @PaymentCode);

		BEGIN TRANSACTION

		IF @CashModeCode = 1
			EXEC Cash.proc_PaymentPostPaidIn @PaymentCode, @PostValue 
		ELSE
			EXEC Cash.proc_PaymentPostPaidOut @PaymentCode, @PostValue

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
IF NOT OBJECT_ID('Org.proc_PaymentPostInvoiced') IS NULL
	DROP PROCEDURE Org.proc_PaymentPostInvoiced;
go
CREATE PROCEDURE Cash.proc_PaymentPost 
AS
    SET NOCOUNT, XACT_ABORT ON;

	BEGIN TRY
		DECLARE @PaymentCode nvarchar(20)

		DECLARE curMisc cursor local for
			SELECT        Cash.tbPayment.PaymentCode
			FROM            Cash.tbPayment INNER JOIN
									 Cash.tbCode ON Cash.tbPayment.CashCode = Cash.tbCode.CashCode INNER JOIN
									 Cash.tbCategory ON Cash.tbCode.CategoryCode = Cash.tbCategory.CategoryCode
			WHERE        (Cash.tbPayment.PaymentStatusCode = 0) 
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
IF NOT OBJECT_ID('Org.proc_PaymentPost') IS NULL
	DROP PROCEDURE Org.proc_PaymentPost;
go
ALTER PROCEDURE Invoice.proc_Pay
	(
	@InvoiceNumber nvarchar(20),
	@PaidOn datetime,
	@Post bit = 1,
	@PaymentCode nvarchar(20) NULL OUTPUT
	)
AS
 	SET NOCOUNT, XACT_ABORT ON;

	BEGIN TRY
	DECLARE 
		@PaidOut decimal(18, 5) = 0
		, @PaidIn decimal(18, 5) = 0
		, @BalanceOutstanding decimal(18, 5) = 0
		, @TaskOutstanding decimal(18, 5) = 0
		, @ItemOutstanding decimal(18, 5) = 0
		, @CashModeCode smallint
		, @AccountCode nvarchar(10)
		, @CashAccountCode nvarchar(10)
		, @InvoiceStatusCode smallint
		, @UserId nvarchar(10)
		, @PaymentReference nvarchar(20)
		, @PayBalance BIT

		SELECT 
			@CashModeCode = Invoice.tbType.CashModeCode, 
			@AccountCode = Invoice.tbInvoice.AccountCode, 
			@PayBalance = Org.tbOrg.PayBalance,
			@InvoiceStatusCode = Invoice.tbInvoice.InvoiceStatusCode
		FROM Invoice.tbInvoice 
			INNER JOIN Invoice.tbType ON Invoice.tbInvoice.InvoiceTypeCode = Invoice.tbType.InvoiceTypeCode
			INNER JOIN Org.tbOrg ON Invoice.tbInvoice.AccountCode = Org.tbOrg.AccountCode
		WHERE     ( Invoice.tbInvoice.InvoiceNumber = @InvoiceNumber)
	
		EXEC Org.proc_BalanceOutstanding @AccountCode, @BalanceOutstanding OUTPUT
		IF @BalanceOutstanding = 0 
		BEGIN
			DECLARE @Msg NVARCHAR(MAX);
			SELECT @Msg = Message FROM App.tbText WHERE TextId = 3018;
			RAISERROR (@Msg, 10, 1)
		END
		ELSE IF @InvoiceStatusCode > 2
			RETURN 1

		SELECT @UserId = UserId FROM Usr.vwCredentials	
		SET @PaidOn = CAST(@PaidOn AS DATE)

		SET @PaymentCode = CONCAT(@UserId, '_', FORMAT(@PaidOn, 'yyyymmdd_hhmmss'))

		WHILE EXISTS (SELECT * FROM Cash.tbPayment WHERE PaymentCode = @PaymentCode)
			BEGIN
			SET @PaidOn = DATEADD(s, 1, @PaidOn)
			SET @PaymentCode = CONCAT(@UserId, '_', FORMAT(@PaidOn, 'yyyymmdd_hhmmss'))
			END
			
		IF @PayBalance = 0
			BEGIN	
			SET @PaymentReference = @InvoiceNumber
															
			SELECT  @TaskOutstanding = SUM( Invoice.tbTask.InvoiceValue + Invoice.tbTask.TaxValue - Invoice.tbTask.PaidValue - Invoice.tbTask.PaidTaxValue)
			FROM         Invoice.tbInvoice INNER JOIN
								  Invoice.tbTask ON Invoice.tbInvoice.InvoiceNumber = Invoice.tbTask.InvoiceNumber INNER JOIN
								  Invoice.tbType ON Invoice.tbInvoice.InvoiceTypeCode = Invoice.tbType.InvoiceTypeCode
			WHERE     ( Invoice.tbInvoice.InvoiceNumber = @InvoiceNumber)
			GROUP BY Invoice.tbType.CashModeCode


			SELECT @ItemOutstanding = SUM( Invoice.tbItem.InvoiceValue + Invoice.tbItem.TaxValue - Invoice.tbItem.PaidValue - Invoice.tbItem.PaidTaxValue)
			FROM         Invoice.tbInvoice INNER JOIN
								  Invoice.tbItem ON Invoice.tbInvoice.InvoiceNumber = Invoice.tbItem.InvoiceNumber
			WHERE     ( Invoice.tbInvoice.InvoiceNumber = @InvoiceNumber)

			IF @CashModeCode = 0
				BEGIN
				SET @PaidOut = ISNULL(@TaskOutstanding, 0) + ISNULL(@ItemOutstanding, 0)
				SET @PaidIn = 0
				END
			ELSE
				BEGIN
				SET @PaidIn = ISNULL(@TaskOutstanding, 0) + ISNULL(@ItemOutstanding, 0)
				SET @PaidOut = 0
				END
			END
		ELSE
			BEGIN
			SET @PaidIn = CASE WHEN @BalanceOutstanding > 0 THEN @BalanceOutstanding ELSE 0 END
			SET @PaidOut = CASE WHEN @BalanceOutstanding < 0 THEN ABS(@BalanceOutstanding) ELSE 0 END
			END
	
		EXEC Cash.proc_CurrentAccount @CashAccountCode OUTPUT

		BEGIN TRANSACTION

		IF @PaidIn + @PaidOut > 0
			BEGIN			

			INSERT INTO Cash.tbPayment
								  (PaymentCode, UserId, PaymentStatusCode, AccountCode, CashAccountCode, PaidOn, PaidInValue, PaidOutValue, PaymentReference)
			VALUES     (@PaymentCode,@UserId, 0, @AccountCode, @CashAccountCode, @PaidOn, @PaidIn, @PaidOut, @PaymentReference)		
		
			IF @Post <> 0
				EXEC Cash.proc_PaymentPostInvoiced @PaymentCode			
			END
		
		IF @@TRANCOUNT > 0
			COMMIT TRANSACTION

  	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH

go
CREATE VIEW Cash.vwPaymentCode
AS
	SELECT CONCAT(LEFT((SELECT UserId FROM Usr.vwCredentials), 2), '_', FORMAT(CURRENT_TIMESTAMP, 'yymmdd_hhmmss'), '_', DATEPART(MILLISECOND, CURRENT_TIMESTAMP)) AS PaymentCode
go
IF NOT OBJECT_ID('Org.vwPaymentCode') IS NULL
	DROP VIEW Org.vwPaymentCode;
go
DISABLE TRIGGER Cash.Cash_tbPayment_TriggerInsert ON Cash.tbPayment;
go
IF NOT OBJECT_ID('Org.tbPayment') IS NULL
BEGIN	
	INSERT INTO Cash.tbPayment
							 (PaymentCode, UserId, PaymentStatusCode, AccountCode, CashAccountCode, CashCode, TaxCode, PaidOn, PaidInValue, PaidOutValue, TaxInValue, TaxOutValue, PaymentReference, InsertedBy, InsertedOn, UpdatedBy, 
							 UpdatedOn)
	SELECT        PaymentCode, UserId, PaymentStatusCode, AccountCode, CashAccountCode, CashCode, TaxCode, PaidOn, PaidInValue, PaidOutValue, TaxInValue, TaxOutValue, PaymentReference, InsertedBy, InsertedOn, UpdatedBy, 
							 UpdatedOn
	FROM            Org.tbPayment AS tbPayment_1;
END
go
ENABLE TRIGGER Cash.Cash_tbPayment_TriggerInsert ON Cash.tbPayment;
go
IF NOT OBJECT_ID('Org.tbPayment') IS NULL
	DROP TABLE Org.tbPayment;

IF NOT OBJECT_ID('Org.tbPaymentStatus') IS NULL
	DROP TABLE Org.tbPaymentStatus;
go

UPDATE Usr.tbMenuEntry
SET Argument = 'Cash_PaymentEntry'
WHERE Argument = 'Org_PaymentEntry';
go
ALTER VIEW Cash.vwTransferCodeLookup
AS
	SELECT        Cash.tbCode.CashCode, Cash.tbCode.CashDescription, Cash.tbCategory.Category, Cash.tbMode.CashMode, Cash.tbMode.CashModeCode
	FROM            Cash.tbCode INNER JOIN
							 Cash.tbCategory ON Cash.tbCode.CategoryCode = Cash.tbCategory.CategoryCode INNER JOIN
							 Cash.tbMode ON Cash.tbCategory.CashModeCode = Cash.tbMode.CashModeCode
	WHERE (Cash.tbCode.IsEnabled <> 0) AND (Cash.tbCategory.IsEnabled <> 0) AND (Cash.tbCategory.CashTypeCode = 2);

go
ALTER PROCEDURE Org.proc_Rebuild(@AccountCode NVARCHAR(10))
AS
  	SET NOCOUNT, XACT_ABORT ON;

	DECLARE @tbPartialInvoice TABLE (
			AccountCode NVARCHAR(10), 
			InvoiceNumber NVARCHAR(10),
			RefType SMALLINT,
			RefCode NVARCHAR(20),
			TotalPaidValue decimal(18, 5)
			);

	BEGIN TRY
		BEGIN TRANSACTION;
		--payments
		UPDATE Cash.tbPayment
		SET
			TaxInValue = PaidInValue - 
				CASE TaxRate WHEN 0 THEN PaidInValue
				ELSE
				(
					CASE App.tbTaxCode.RoundingCode 
						WHEN 0 THEN ROUND((PaidInValue / (1 + TaxRate)), Decimals)
						WHEN 1 THEN ROUND((PaidInValue / (1 + TaxRate)), Decimals, 1) 
					END
				)
				END, 
			TaxOutValue = PaidOutValue - 
				CASE TaxRate WHEN 0 THEN PaidOutValue
				ELSE
				(		
					CASE App.tbTaxCode.RoundingCode 
						WHEN 0 THEN ROUND((PaidOutValue / (1 + TaxRate)), Decimals)
						WHEN 1 THEN ROUND((PaidOutValue / (1 + TaxRate)), Decimals, 1) 
					END
				)
				END
		FROM  Cash.tbPayment 
			INNER JOIN App.tbTaxCode ON Cash.tbPayment.TaxCode = App.tbTaxCode.TaxCode
		WHERE AccountCode = @AccountCode;

		--invoices
		IF EXISTS(SELECT * FROM Cash.tbPayment WHERE AccountCode = @AccountCode)
		BEGIN
			UPDATE Invoice.tbItem
			SET TaxValue = 
					CASE WHEN TaxRate = 0 THEN 0
					ELSE
					(
						CASE App.tbTaxCode.RoundingCode 
							WHEN 0 THEN ROUND(Invoice.tbItem.InvoiceValue * App.tbTaxCode.TaxRate, Decimals)
							WHEN 1 THEN ROUND( Invoice.tbItem.InvoiceValue * App.tbTaxCode.TaxRate, Decimals, 1) 
						END
					)
					END,
				PaidValue = Invoice.tbItem.InvoiceValue, 
				PaidTaxValue = 
					CASE WHEN TaxRate = 0 THEN 0
					ELSE
					(		
						CASE App.tbTaxCode.RoundingCode 
							WHEN 0 THEN ROUND(Invoice.tbItem.InvoiceValue * App.tbTaxCode.TaxRate, Decimals)
							WHEN 1 THEN ROUND( Invoice.tbItem.InvoiceValue * App.tbTaxCode.TaxRate, Decimals, 1) 
						END
					)
					END
			FROM Invoice.tbItem 
				INNER JOIN App.tbTaxCode ON Invoice.tbItem.TaxCode = App.tbTaxCode.TaxCode 
				INNER JOIN Invoice.tbInvoice ON Invoice.tbItem.InvoiceNumber = Invoice.tbInvoice.InvoiceNumber
			WHERE (Invoice.tbInvoice.InvoiceStatusCode <> 0) 
				AND (AccountCode = @AccountCode);
                      
			UPDATE Invoice.tbTask
			SET TaxValue = 
					CASE WHEN TaxRate = 0 THEN 0
					ELSE
					(
						CASE App.tbTaxCode.RoundingCode 
							WHEN 0 THEN ROUND(Invoice.tbTask.InvoiceValue * App.tbTaxCode.TaxRate, Decimals)
							WHEN 1 THEN ROUND( Invoice.tbTask.InvoiceValue * App.tbTaxCode.TaxRate, Decimals, 1) 
						END
					)
					END,
				PaidValue = Invoice.tbTask.InvoiceValue,
				PaidTaxValue = 
					CASE WHEN TaxRate = 0 THEN 0
					ELSE
					(
						CASE App.tbTaxCode.RoundingCode 
							WHEN 0 THEN ROUND(Invoice.tbTask.InvoiceValue * App.tbTaxCode.TaxRate, Decimals)
							WHEN 1 THEN ROUND( Invoice.tbTask.InvoiceValue * App.tbTaxCode.TaxRate, Decimals, 1) 
						END
					)
					END
			FROM  Invoice.tbTask 
				INNER JOIN App.tbTaxCode ON Invoice.tbTask.TaxCode = App.tbTaxCode.TaxCode 
				INNER JOIN Invoice.tbInvoice ON Invoice.tbTask.InvoiceNumber = Invoice.tbInvoice.InvoiceNumber
			WHERE (Invoice.tbInvoice.InvoiceStatusCode <> 0) AND (AccountCode = @AccountCode);
		END
		ELSE
		BEGIN
			UPDATE Invoice.tbItem
			SET TaxValue = 
					CASE WHEN TaxRate = 0 THEN 0
					ELSE
					(			
						CASE App.tbTaxCode.RoundingCode 
							WHEN 0 THEN ROUND(Invoice.tbItem.InvoiceValue * App.tbTaxCode.TaxRate, Decimals)
							WHEN 1 THEN ROUND( Invoice.tbItem.InvoiceValue * App.tbTaxCode.TaxRate, Decimals, 1) 
						END
					)
					END,
				PaidValue = 0,
				PaidTaxValue = 0
			FROM         Invoice.tbItem INNER JOIN
									App.tbTaxCode ON Invoice.tbItem.TaxCode = App.tbTaxCode.TaxCode INNER JOIN
									Invoice.tbInvoice ON Invoice.tbItem.InvoiceNumber = Invoice.tbInvoice.InvoiceNumber
			WHERE     ( Invoice.tbInvoice.InvoiceStatusCode <> 0)
				AND (AccountCode = @AccountCode);
                      
			UPDATE Invoice.tbTask
			SET TaxValue = 
					CASE WHEN TaxRate = 0 THEN 0
					ELSE
					(		
						CASE App.tbTaxCode.RoundingCode 
								WHEN 0 THEN ROUND(Invoice.tbTask.InvoiceValue * App.tbTaxCode.TaxRate, Decimals)
								WHEN 1 THEN ROUND( Invoice.tbTask.InvoiceValue * App.tbTaxCode.TaxRate, Decimals, 1) 
						END
					)
					END,
				PaidValue = 0,
				PaidTaxValue = 0
			FROM         Invoice.tbTask INNER JOIN
									App.tbTaxCode ON Invoice.tbTask.TaxCode = App.tbTaxCode.TaxCode INNER JOIN
									Invoice.tbInvoice ON Invoice.tbTask.InvoiceNumber = Invoice.tbInvoice.InvoiceNumber
			WHERE     ( Invoice.tbInvoice.InvoiceStatusCode <> 0)
				AND (AccountCode = @AccountCode);		
		END	

		UPDATE Invoice.tbInvoice
		SET InvoiceValue = 0, TaxValue = 0, PaidValue = 0, PaidTaxValue = 0, InvoiceStatusCode = 1
		WHERE     ( Invoice.tbInvoice.InvoiceStatusCode <> 0)
			AND (AccountCode = @AccountCode);
	
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
								ON Invoice.tbInvoice.InvoiceNumber = items.InvoiceNumber
		WHERE (AccountCode = @AccountCode);


		WITH tasks AS
		(
			SELECT     Invoice.tbInvoice.InvoiceNumber, SUM( Invoice.tbTask.InvoiceValue) AS TotalInvoiceValue, SUM( Invoice.tbTask.TaxValue) AS TotalTaxValue
			FROM         Invoice.tbTask INNER JOIN
								Invoice.tbInvoice ON Invoice.tbTask.InvoiceNumber = Invoice.tbInvoice.InvoiceNumber
			WHERE   ( Invoice.tbInvoice.InvoiceStatusCode <> 0) AND (AccountCode = @AccountCode)
			GROUP BY Invoice.tbTask.InvoiceNumber, Invoice.tbInvoice.InvoiceNumber
		)
		UPDATE Invoice.tbInvoice
		SET InvoiceValue = InvoiceValue + tasks.TotalInvoiceValue, 
			TaxValue = TaxValue + tasks.TotalTaxValue
		FROM         Invoice.tbInvoice INNER JOIN tasks ON Invoice.tbInvoice.InvoiceNumber = tasks.InvoiceNumber;

		IF EXISTS(SELECT * FROM Cash.tbPayment WHERE AccountCode = @AccountCode)
			UPDATE    Invoice.tbInvoice
			SET              PaidValue = InvoiceValue, PaidTaxValue = TaxValue, InvoiceStatusCode = 3
			WHERE (AccountCode = @AccountCode);
			
		WITH paid_balance AS
		(
			SELECT  AccountCode, SUM(PaidInValue + (PaidOutValue * -1)) AS PaidBalance
			FROM         Cash.tbPayment
			WHERE     (PaymentStatusCode <> 0) AND (AccountCode = @AccountCode)
			GROUP BY AccountCode
		), invoice_balance AS
		(
			SELECT AccountCode, SUM(CASE Invoice.tbType.CashModeCode WHEN 0 THEN (InvoiceValue + TaxValue) * - 1 WHEN 1 THEN InvoiceValue + TaxValue ELSE 0 END) AS InvoicedBalance
			FROM         Invoice.tbInvoice INNER JOIN
								  Invoice.tbType ON Invoice.tbInvoice.InvoiceTypeCode = Invoice.tbType.InvoiceTypeCode
			WHERE (AccountCode = @AccountCode)
			GROUP BY AccountCode
		), account_balance AS
		(
			SELECT paid_balance.AccountCode, PaidBalance, InvoicedBalance, PaidBalance - InvoicedBalance AS CurrentBalance
			FROM paid_balance JOIN invoice_balance ON paid_balance.AccountCode = invoice_balance.AccountCode
		), current_balance AS
		(
			SELECT account_balance.AccountCode, 
				OpeningBalance + account_balance.CurrentBalance AS CurrentBalance
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

		--SELECT * FROM @tbPartialInvoice

		UPDATE task
		SET PaidValue = 0, PaidTaxValue = 0
		FROM @tbPartialInvoice unpaid_task
			JOIN Invoice.tbTask task ON unpaid_task.InvoiceNumber = task.InvoiceNumber
				AND unpaid_task.RefCode = task.TaskCode	
		WHERE unpaid_task.RefType = 1 AND unpaid_task.TotalPaidValue = 0;

		UPDATE task
		SET 
			PaidTaxValue = 
					CASE WHEN TaxRate = 0 THEN 0
					ELSE
					(
						CASE RoundingCode 
							WHEN 0 THEN ROUND((TotalPaidValue - (TotalPaidValue / (1 + TaxRate))), Decimals)
							WHEN 1 THEN ROUND((TotalPaidValue - (TotalPaidValue / (1 + TaxRate))), Decimals, 1)
						END
					)
					END,
			PaidValue = TotalPaidValue -
					CASE WHEN TaxRate = 0 THEN 0
					ELSE
					(
						CASE RoundingCode 
							WHEN 0 THEN ROUND((TotalPaidValue - (TotalPaidValue / (1 + TaxRate))), Decimals)
							WHEN 1 THEN ROUND((TotalPaidValue - (TotalPaidValue / (1 + TaxRate))), Decimals, 1)
						END
					)
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
		WHERE unpaid_task.RefType = 2 AND unpaid_task.TotalPaidValue = 0;

		UPDATE item
		SET 
			PaidTaxValue = 
					CASE WHEN TaxRate = 0 THEN 0
					ELSE
					(
						CASE RoundingCode 
							WHEN 0 THEN ROUND((TotalPaidValue - (TotalPaidValue / (1 + TaxRate))), Decimals)
							WHEN 1 THEN ROUND((TotalPaidValue - (TotalPaidValue / (1 + TaxRate))), Decimals, 1)
						END
					)
					END,
			PaidValue = TotalPaidValue -
					CASE WHEN TaxRate = 0 THEN 0
					ELSE
					(
						CASE RoundingCode 
							WHEN 0 THEN ROUND((TotalPaidValue - (TotalPaidValue / (1 + TaxRate))), Decimals)
							WHEN 1 THEN ROUND((TotalPaidValue - (TotalPaidValue / (1 + TaxRate))), Decimals, 1)
						END
					)
					END
		FROM @tbPartialInvoice unpaid_item
			JOIN Invoice.tbItem item ON unpaid_item.InvoiceNumber = item.InvoiceNumber
				AND unpaid_item.RefCode = item.CashCode	
			JOIN App.tbTaxCode tax ON tax.TaxCode = item.TaxCode
		WHERE unpaid_item.RefType = 2 AND unpaid_item.TotalPaidValue <> 0;

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

		COMMIT TRANSACTION

		--log successful rebuild
		DECLARE @Msg NVARCHAR(MAX);
		SELECT @Msg = CONCAT(@AccountCode, ' ', Message) FROM App.tbText WHERE TextId = 3006;
		EXEC App.proc_EventLog @EventMessage = @Msg, @EventTypeCode = 2;

  	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH

go
ALTER PROCEDURE App.proc_SystemRebuild
AS
  	SET NOCOUNT, XACT_ABORT ON;

	DECLARE @tbPartialInvoice TABLE (
			AccountCode NVARCHAR(10), 
			InvoiceNumber NVARCHAR(10),
			RefType SMALLINT,
			RefCode NVARCHAR(20),
			TotalPaidValue decimal(18, 5)
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
			TaxInValue = PaidInValue - 
				CASE TaxRate WHEN 0 THEN PaidInValue
				ELSE
				(
					CASE App.tbTaxCode.RoundingCode 
						WHEN 0 THEN ROUND((PaidInValue / (1 + TaxRate)), Decimals)
						WHEN 1 THEN ROUND((PaidInValue / (1 + TaxRate)), Decimals, 1) 
					END
				)
				END, 
			TaxOutValue = PaidOutValue - 
				CASE TaxRate WHEN 0 THEN PaidOutValue
				ELSE
				(		
					CASE App.tbTaxCode.RoundingCode 
						WHEN 0 THEN ROUND((PaidOutValue / (1 + TaxRate)), Decimals)
						WHEN 1 THEN ROUND((PaidOutValue / (1 + TaxRate)), Decimals, 1) 
					END
				)
				END
		FROM Cash.tbPayment 
			INNER JOIN App.tbTaxCode ON Cash.tbPayment.TaxCode = App.tbTaxCode.TaxCode;

		--Invoice Items									
		UPDATE Invoice.tbItem
		SET InvoiceValue = 
				CASE WHEN TaxRate = 0 THEN Invoice.tbItem.TotalValue
				ELSE
				(
					ROUND(Invoice.tbItem.TotalValue / (1 + App.tbTaxCode.TaxRate), Decimals)
				)
				END,
			TaxValue = TotalValue - 
				CASE WHEN TaxRate = 0 THEN TotalValue
				ELSE
				(
					CASE App.tbTaxCode.RoundingCode
						WHEN 0 THEN ROUND(Invoice.tbItem.TotalValue / (1 + App.tbTaxCode.TaxRate), Decimals)
						WHEN 1 THEN ROUND(Invoice.tbItem.TotalValue / (1 + App.tbTaxCode.TaxRate), Decimals, 1)
					END
				)
				END
		FROM         Invoice.tbItem INNER JOIN
								App.tbTaxCode ON Invoice.tbItem.TaxCode = App.tbTaxCode.TaxCode INNER JOIN
								Invoice.tbInvoice ON Invoice.tbItem.InvoiceNumber = Invoice.tbInvoice.InvoiceNumber
		WHERE     ( Invoice.tbInvoice.InvoiceStatusCode <> 0) AND Invoice.tbItem.TotalValue <> 0;

		UPDATE Invoice.tbItem
		SET 
			InvoiceValue = 
				CASE WHEN Invoice.tbItem.TotalValue = 0 THEN Invoice.tbItem.InvoiceValue 
				ELSE 
				(
					CASE WHEN TaxRate = 0 THEN Invoice.tbItem.TotalValue
					ELSE
						ROUND(Invoice.tbItem.TotalValue / (1 + App.tbTaxCode.TaxRate), Decimals)
					END
				)
				END,
			TaxValue = 
				CASE WHEN TaxRate = 0 THEN 0
				ELSE
				(
					CASE App.tbTaxCode.RoundingCode 
						WHEN 0 THEN ROUND(Invoice.tbItem.InvoiceValue * App.tbTaxCode.TaxRate, Decimals)
						WHEN 1 THEN ROUND( Invoice.tbItem.InvoiceValue * App.tbTaxCode.TaxRate, Decimals, 1) 
					END
				)
				END			
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
		SET InvoiceValue =  
				CASE WHEN TaxRate = 0 THEN Invoice.tbTask.TotalValue
				ELSE
					ROUND(Invoice.tbTask.TotalValue / (1 + App.tbTaxCode.TaxRate), Decimals)
				END,
			TaxValue = TotalValue - 
				CASE WHEN TaxRate = 0 THEN TotalValue
				ELSE
				(
					ROUND(Invoice.tbTask.TotalValue / (1 + App.tbTaxCode.TaxRate), Decimals)
				)
				END
		FROM         Invoice.tbTask INNER JOIN
								App.tbTaxCode ON Invoice.tbTask.TaxCode = App.tbTaxCode.TaxCode INNER JOIN
								Invoice.tbInvoice ON Invoice.tbTask.InvoiceNumber = Invoice.tbInvoice.InvoiceNumber
		WHERE     (Invoice.tbInvoice.InvoiceStatusCode <> 0) AND Invoice.tbTask.TotalValue <> 0;

		UPDATE Invoice.tbTask
		SET 
			InvoiceValue = 
				CASE WHEN Invoice.tbTask.TotalValue = 0 THEN Invoice.tbTask.InvoiceValue 
				ELSE 
				(
					CASE WHEN TaxRate = 0 THEN Invoice.tbTask.TotalValue
					ELSE
						ROUND(Invoice.tbTask.TotalValue / (1 + App.tbTaxCode.TaxRate), Decimals) 
					END
				)
				END,
			TaxValue = 
				CASE WHEN TaxRate = 0 THEN 0
				ELSE
				(
					CASE App.tbTaxCode.RoundingCode 
						WHEN 0 THEN ROUND(Invoice.tbTask.InvoiceValue * App.tbTaxCode.TaxRate, Decimals)
						WHEN 1 THEN ROUND( Invoice.tbTask.InvoiceValue * App.tbTaxCode.TaxRate, Decimals, 1) 
					END
				)
				END
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
			SELECT account_balance.AccountCode, OpeningBalance + account_balance.CurrentBalance AS CurrentBalance
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
			PaidTaxValue = 
						CASE WHEN TaxRate = 0 THEN 0
						ELSE
						(
							CASE RoundingCode 
								WHEN 0 THEN ROUND((TotalPaidValue - (TotalPaidValue / (1 + TaxRate))), Decimals)
								WHEN 1 THEN ROUND((TotalPaidValue - (TotalPaidValue / (1 + TaxRate))), Decimals, 1)
							END
						)
						END,
			PaidValue = TotalPaidValue -
						CASE WHEN TaxRate = 0 THEN 0
						ELSE
						(
							CASE RoundingCode 
								WHEN 0 THEN ROUND((TotalPaidValue - (TotalPaidValue / (1 + TaxRate))), Decimals)
								WHEN 1 THEN ROUND((TotalPaidValue - (TotalPaidValue / (1 + TaxRate))), Decimals, 1)
							END
						)
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
		WHERE unpaid_task.RefType = 2 AND unpaid_task.TotalPaidValue = 0;

		UPDATE item
		SET 
			PaidTaxValue = 
						CASE WHEN TaxRate = 0 THEN 0
						ELSE
						(
							CASE RoundingCode 
								WHEN 0 THEN ROUND((TotalPaidValue - (TotalPaidValue / (1 + TaxRate))), Decimals)
								WHEN 1 THEN ROUND((TotalPaidValue - (TotalPaidValue / (1 + TaxRate))), Decimals, 1)
							END
						)
						END,
			PaidValue = TotalPaidValue -
						CASE WHEN TaxRate = 0 THEN 0
						ELSE
						(											
							CASE RoundingCode 
								WHEN 0 THEN ROUND((TotalPaidValue - (TotalPaidValue / (1 + TaxRate))), Decimals)
								WHEN 1 THEN ROUND((TotalPaidValue - (TotalPaidValue / (1 + TaxRate))), Decimals, 1)
							END
						)
						END
		FROM @tbPartialInvoice unpaid_item
			JOIN Invoice.tbItem item ON unpaid_item.InvoiceNumber = item.InvoiceNumber
				AND unpaid_item.RefCode = item.CashCode	
			JOIN App.tbTaxCode tax ON tax.TaxCode = item.TaxCode
		WHERE unpaid_item.RefType = 2 AND unpaid_item.TotalPaidValue <> 0;

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
		UPDATE       Cash.tbPeriod
		SET                InvoiceValue = 0, InvoiceTax = 0;
	
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
		FROM    Cash.tbPeriod INNER JOIN
				invoice_summary ON Cash.tbPeriod.CashCode = invoice_summary.CashCode AND Cash.tbPeriod.StartOn = invoice_summary.StartOn;


		UPDATE Cash.tbPeriod
		SET 
			InvoiceValue = Cash.vwAccountPeriodClosingBalance.ClosingBalance
		FROM         Cash.vwAccountPeriodClosingBalance INNER JOIN
							  Cash.tbPeriod ON Cash.vwAccountPeriodClosingBalance.CashCode = Cash.tbPeriod.CashCode AND 
							  Cash.vwAccountPeriodClosingBalance.StartOn = Cash.tbPeriod.StartOn;	            

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

ALTER VIEW App.vwDocCreditNote
AS
SELECT        TOP (100) PERCENT Invoice.tbInvoice.InvoiceNumber, Invoice.tbInvoice.Printed, Invoice.tbInvoice.Spooled, Invoice.tbInvoice.InvoiceStatusCode, Usr.tbUser.UserName, Invoice.tbInvoice.AccountCode, 
                         Org.tbOrg.AccountName, Invoice.tbStatus.InvoiceStatus, Invoice.tbInvoice.InvoicedOn, Invoice.tbInvoice.InvoiceValue, Invoice.tbInvoice.TaxValue, Invoice.tbInvoice.PaymentTerms, Invoice.tbInvoice.Notes, 
                         Org.tbOrg.EmailAddress, Invoice.tbInvoice.RowVer
FROM            Invoice.tbInvoice INNER JOIN
                         Invoice.tbStatus ON Invoice.tbInvoice.InvoiceStatusCode = Invoice.tbStatus.InvoiceStatusCode INNER JOIN
                         Org.tbOrg ON Invoice.tbInvoice.AccountCode = Org.tbOrg.AccountCode INNER JOIN
                         Usr.tbUser ON Invoice.tbInvoice.UserId = Usr.tbUser.UserId
WHERE        (Invoice.tbInvoice.InvoiceTypeCode = 1);

go
ALTER VIEW App.vwDocDebitNote
AS
SELECT        TOP (100) PERCENT Invoice.tbInvoice.InvoiceNumber, Invoice.tbInvoice.Printed, Invoice.tbInvoice.Spooled, Invoice.tbInvoice.InvoiceStatusCode, Usr.tbUser.UserName, Invoice.tbInvoice.AccountCode, 
                         Org.tbOrg.AccountName, Invoice.tbStatus.InvoiceStatus, Invoice.tbInvoice.InvoicedOn, Invoice.tbInvoice.InvoiceValue, Invoice.tbInvoice.TaxValue, Invoice.tbInvoice.PaymentTerms, Invoice.tbInvoice.Notes, 
                         Org.tbOrg.EmailAddress, Invoice.tbInvoice.RowVer
FROM            Invoice.tbInvoice INNER JOIN
                         Invoice.tbStatus ON Invoice.tbInvoice.InvoiceStatusCode = Invoice.tbStatus.InvoiceStatusCode INNER JOIN
                         Org.tbOrg ON Invoice.tbInvoice.AccountCode = Org.tbOrg.AccountCode INNER JOIN
                         Usr.tbUser ON Invoice.tbInvoice.UserId = Usr.tbUser.UserId
WHERE        (Invoice.tbInvoice.InvoiceTypeCode = 3);
go
ALTER VIEW App.vwDocPurchaseEnquiry
AS
SELECT        TOP (100) PERCENT Task.vwTasks.TaskCode, Task.vwTasks.ActionOn, Task.vwTasks.ActivityCode, Task.vwTasks.ActionById, Task.vwTasks.BucketId, Task.vwTasks.TaskTitle, Task.vwTasks.AccountCode, 
                         Task.vwTasks.ContactName, Task.vwTasks.TaskNotes, Task.vwTasks.OwnerName, Task.vwTasks.CashCode, Task.vwTasks.CashDescription, Task.vwTasks.Quantity, Activity.tbActivity.UnitOfMeasure, 
                         Task.vwTasks.UnitCharge, Task.vwTasks.TotalCharge, Org_tbAddress_1.Address AS FromAddress, Org.tbAddress.Address AS ToAddress, Task.vwTasks.InsertedBy, Task.vwTasks.InsertedOn, 
                         Task.vwTasks.UpdatedBy, Task.vwTasks.UpdatedOn, Task.vwTasks.AccountName, Task.vwTasks.ActionName, Task.vwTasks.Period, Task.vwTasks.Printed, Task.vwTasks.Spooled, Task.vwTasks.RowVer
FROM            Task.vwTasks LEFT OUTER JOIN
                         Org.tbAddress AS Org_tbAddress_1 ON Task.vwTasks.AddressCodeFrom = Org_tbAddress_1.AddressCode LEFT OUTER JOIN
                         Org.tbAddress ON Task.vwTasks.AddressCodeTo = Org.tbAddress.AddressCode INNER JOIN
                         Activity.tbActivity ON Task.vwTasks.ActivityCode = Activity.tbActivity.ActivityCode
WHERE        (Task.vwTasks.CashCode IS NOT NULL) AND (Task.vwTasks.CashModeCode = 0) AND (Task.vwTasks.TaskStatusCode = 0);
go
ALTER VIEW App.vwDocPurchaseOrder
AS
SELECT        TOP (100) PERCENT Task.vwTasks.TaskCode, Task.vwTasks.ActionOn, Task.vwTasks.ActivityCode, Task.vwTasks.ActionById, Task.vwTasks.BucketId, Task.vwTasks.TaskTitle, Task.vwTasks.AccountCode, 
                         Task.vwTasks.ContactName, Task.vwTasks.TaskNotes, Task.vwTasks.OwnerName, Task.vwTasks.CashCode, Task.vwTasks.CashDescription, Task.vwTasks.Quantity, Activity.tbActivity.UnitOfMeasure, 
                         Task.vwTasks.UnitCharge, Task.vwTasks.TotalCharge, Org_tbAddress_1.Address AS FromAddress, Org.tbAddress.Address AS ToAddress, Task.vwTasks.InsertedBy, Task.vwTasks.InsertedOn, 
                         Task.vwTasks.UpdatedBy, Task.vwTasks.UpdatedOn, Task.vwTasks.AccountName, Task.vwTasks.ActionName, Task.vwTasks.Period, Task.vwTasks.Printed, Task.vwTasks.Spooled, Task.vwTasks.RowVer
FROM            Task.vwTasks LEFT OUTER JOIN
                         Org.tbAddress AS Org_tbAddress_1 ON Task.vwTasks.AddressCodeFrom = Org_tbAddress_1.AddressCode LEFT OUTER JOIN
                         Org.tbAddress ON Task.vwTasks.AddressCodeTo = Org.tbAddress.AddressCode INNER JOIN
                         Activity.tbActivity ON Task.vwTasks.ActivityCode = Activity.tbActivity.ActivityCode
WHERE        (Task.vwTasks.CashCode IS NOT NULL) AND (Task.vwTasks.CashModeCode = 0) AND (Task.vwTasks.TaskStatusCode > 0);
go
ALTER VIEW App.vwDocQuotation
AS
SELECT        TOP (100) PERCENT Task.vwTasks.TaskCode, Task.vwTasks.ActionOn, Task.vwTasks.ActivityCode, Task.vwTasks.ActionById, Task.vwTasks.BucketId, Task.vwTasks.TaskTitle, Task.vwTasks.AccountCode, 
                         Task.vwTasks.ContactName, Task.vwTasks.TaskNotes, Task.vwTasks.OwnerName, Task.vwTasks.CashCode, Task.vwTasks.CashDescription, Task.vwTasks.Quantity, Activity.tbActivity.UnitOfMeasure, 
                         Task.vwTasks.UnitCharge, Task.vwTasks.TotalCharge, Org_tbAddress_1.Address AS FromAddress, Org.tbAddress.Address AS ToAddress, Task.vwTasks.InsertedBy, Task.vwTasks.InsertedOn, 
                         Task.vwTasks.UpdatedBy, Task.vwTasks.UpdatedOn, Task.vwTasks.AccountName, Task.vwTasks.ActionName, Task.vwTasks.Period, Task.vwTasks.Printed, Task.vwTasks.Spooled, Task.vwTasks.RowVer
FROM            Task.vwTasks LEFT OUTER JOIN
                         Org.tbAddress AS Org_tbAddress_1 ON Task.vwTasks.AddressCodeFrom = Org_tbAddress_1.AddressCode LEFT OUTER JOIN
                         Org.tbAddress ON Task.vwTasks.AddressCodeTo = Org.tbAddress.AddressCode INNER JOIN
                         Activity.tbActivity ON Task.vwTasks.ActivityCode = Activity.tbActivity.ActivityCode
WHERE        (Task.vwTasks.CashCode IS NOT NULL) AND (Task.vwTasks.CashModeCode = 1) AND (Task.vwTasks.TaskStatusCode = 0);
go
ALTER VIEW App.vwDocSalesOrder
AS
SELECT        TOP (100) PERCENT Task.vwTasks.TaskCode, Task.vwTasks.ActionOn, Task.vwTasks.ActivityCode, Task.vwTasks.ActionById, Task.vwTasks.BucketId, Task.vwTasks.AccountCode, Task.vwTasks.TaskTitle, 
                         Task.vwTasks.ContactName, Task.vwTasks.TaskNotes, Task.vwTasks.OwnerName, Task.vwTasks.CashCode, Task.vwTasks.CashDescription, Task.vwTasks.Quantity, Activity.tbActivity.UnitOfMeasure, 
                         Task.vwTasks.UnitCharge, Task.vwTasks.TotalCharge, Org_tbAddress_1.Address AS FromAddress, Org.tbAddress.Address AS ToAddress, Task.vwTasks.InsertedBy, Task.vwTasks.InsertedOn, 
                         Task.vwTasks.UpdatedBy, Task.vwTasks.UpdatedOn, Task.vwTasks.AccountName, Task.vwTasks.ActionName, Task.vwTasks.Period, Task.vwTasks.Printed, Task.vwTasks.Spooled, Task.vwTasks.RowVer
FROM            Task.vwTasks LEFT OUTER JOIN
                         Org.tbAddress AS Org_tbAddress_1 ON Task.vwTasks.AddressCodeFrom = Org_tbAddress_1.AddressCode LEFT OUTER JOIN
                         Org.tbAddress ON Task.vwTasks.AddressCodeTo = Org.tbAddress.AddressCode INNER JOIN
                         Activity.tbActivity ON Task.vwTasks.ActivityCode = Activity.tbActivity.ActivityCode
WHERE        (Task.vwTasks.CashCode IS NOT NULL) AND (Task.vwTasks.CashModeCode = 1) AND (Task.vwTasks.TaskStatusCode > 0);
go
ALTER VIEW App.vwDocSalesInvoice
AS
SELECT        TOP (100) PERCENT Invoice.tbInvoice.InvoiceNumber, Invoice.tbInvoice.Printed, Invoice.tbInvoice.Spooled, Invoice.tbInvoice.InvoiceStatusCode, Usr.tbUser.UserName, Invoice.tbInvoice.AccountCode, 
                         Org.tbOrg.AccountName, Invoice.tbStatus.InvoiceStatus, Invoice.tbInvoice.InvoicedOn, Invoice.tbInvoice.InvoiceValue, Invoice.tbInvoice.TaxValue, Invoice.tbInvoice.PaymentTerms, Invoice.tbInvoice.Notes, 
                         Org.tbOrg.EmailAddress, Invoice.tbInvoice.RowVer
FROM            Invoice.tbInvoice INNER JOIN
                         Invoice.tbStatus ON Invoice.tbInvoice.InvoiceStatusCode = Invoice.tbStatus.InvoiceStatusCode INNER JOIN
                         Org.tbOrg ON Invoice.tbInvoice.AccountCode = Org.tbOrg.AccountCode INNER JOIN
                         Usr.tbUser ON Invoice.tbInvoice.UserId = Usr.tbUser.UserId
WHERE        (Invoice.tbInvoice.InvoiceTypeCode = 0);
go
ALTER VIEW App.vwGraphTaskActivity
AS
SELECT        CONCAT(Task.tbStatus.TaskStatus, SPACE(1), Cash.tbMode.CashMode) AS Category, SUM(Task.tbTask.TotalCharge) AS SumOfTotalCharge
FROM            Task.tbTask INNER JOIN
                         Task.tbStatus ON Task.tbTask.TaskStatusCode = Task.tbStatus.TaskStatusCode INNER JOIN
                         Cash.tbCode ON Task.tbTask.CashCode = Cash.tbCode.CashCode INNER JOIN
                         Cash.tbCategory ON Cash.tbCode.CategoryCode = Cash.tbCategory.CategoryCode INNER JOIN
                         Cash.tbMode ON Cash.tbCategory.CashModeCode = Cash.tbMode.CashModeCode
WHERE        (Task.tbTask.TaskStatusCode < 3) AND (Task.tbTask.TaskStatusCode > 0)
GROUP BY CONCAT(Task.tbStatus.TaskStatus, SPACE(1), Cash.tbMode.CashMode);
go
ALTER VIEW App.vwGraphBankBalance
AS
SELECT        Format(Cash.vwAccountPeriodClosingBalance.StartOn, 'yyyy-MM') AS PeriodOn, SUM(Cash.vwAccountPeriodClosingBalance.ClosingBalance) AS SumOfClosingBalance
FROM            Cash.vwAccountPeriodClosingBalance INNER JOIN
                         Cash.tbCode ON Cash.vwAccountPeriodClosingBalance.CashCode = Cash.tbCode.CashCode
WHERE        (Cash.vwAccountPeriodClosingBalance.StartOn > DATEADD(m, - 6, CURRENT_TIMESTAMP))
GROUP BY Format(Cash.vwAccountPeriodClosingBalance.StartOn, 'yyyy-MM');
go
ALTER VIEW Cash.vwAccountPeriodClosingBalance
AS
	WITH last_entries AS
	(
		SELECT     CashAccountCode, StartOn, MAX(EntryNumber) AS LastEntry
		FROM         Cash.vwAccountStatement
		GROUP BY CashAccountCode, StartOn
		HAVING      (NOT (StartOn IS NULL))
	)
	SELECT        Org.tbAccount.CashAccountCode, Org.tbAccount.CashCode, last_entries.StartOn, SUM(Cash.vwAccountStatement.PaidBalance) AS ClosingBalance
	FROM            last_entries INNER JOIN
							 Cash.vwAccountStatement ON last_entries.CashAccountCode = Cash.vwAccountStatement.CashAccountCode AND 
							 last_entries.StartOn = Cash.vwAccountStatement.StartOn AND 
							 last_entries.LastEntry = Cash.vwAccountStatement.EntryNumber INNER JOIN
							 Org.tbAccount ON last_entries.CashAccountCode = Org.tbAccount.CashAccountCode
	GROUP BY Org.tbAccount.CashAccountCode, Org.tbAccount.CashCode, last_entries.StartOn
go
ALTER VIEW Cash.vwAccountStatementListing
AS
	SELECT        App.tbYear.YearNumber, Org.tbOrg.AccountName AS Bank, Org.tbAccount.CashAccountCode, Org.tbAccount.CashAccountName, Org.tbAccount.SortCode, Org.tbAccount.AccountNumber, CONCAT(App.tbYear.Description, SPACE(1), 
							 App.tbMonth.MonthName) AS PeriodName, Cash.vwAccountStatement.StartOn, CAST(Cash.vwAccountStatement.EntryNumber AS INT) EntryNumber, Cash.vwAccountStatement.PaymentCode, Cash.vwAccountStatement.PaidOn, 
							 Cash.vwAccountStatement.AccountName, Cash.vwAccountStatement.PaymentReference, Cash.vwAccountStatement.PaidInValue, Cash.vwAccountStatement.PaidOutValue, 
							 Cash.vwAccountStatement.PaidBalance, Cash.vwAccountStatement.TaxInValue, Cash.vwAccountStatement.TaxOutValue, Cash.vwAccountStatement.CashCode, 
							 Cash.vwAccountStatement.CashDescription, Cash.vwAccountStatement.TaxDescription, Cash.vwAccountStatement.UserName, Cash.vwAccountStatement.AccountCode, 
							 Cash.vwAccountStatement.TaxCode
	FROM            App.tbYearPeriod INNER JOIN
							 App.tbMonth ON App.tbYearPeriod.MonthNumber = App.tbMonth.MonthNumber INNER JOIN
							 Cash.vwAccountStatement INNER JOIN
							 Org.tbAccount ON Cash.vwAccountStatement.CashAccountCode = Org.tbAccount.CashAccountCode INNER JOIN
							 Org.tbOrg ON Org.tbAccount.AccountCode = Org.tbOrg.AccountCode ON App.tbYearPeriod.StartOn = Cash.vwAccountStatement.StartOn INNER JOIN
							 App.tbYear ON App.tbYearPeriod.YearNumber = App.tbYear.YearNumber;
go
ALTER VIEW Cash.vwBankAccounts
AS
	SELECT CashAccountCode, CashAccountName, OpeningBalance, CASE WHEN NOT CashCode IS NULL THEN 0 ELSE 1 END AS DisplayOrder
	FROM Org.tbAccount  
	WHERE AccountCode <> (SELECT AccountCode FROM App.vwHomeAccount)

go
ALTER VIEW Cash.vwBudget
AS
SELECT TOP 100 PERCENT Cash.tbCode.CategoryCode, Cash.tbPeriod.CashCode, Cash.tbCode.CashDescription, 
	Cash.tbPeriod.StartOn, App.tbYearPeriod.YearNumber, App.tbMonth.MonthName, Format(App.tbYearPeriod.StartOn, 'yy-MM') AS Period,  
	Cash.tbPeriod.ForecastValue, Cash.tbPeriod.ForecastTax, Cash.tbPeriod.InvoiceValue, Cash.tbPeriod.InvoiceTax, Cash.tbPeriod.Note, Cash.tbMode.CashMode, App.tbTaxCode.TaxRate
FROM            App.tbYearPeriod INNER JOIN
                         Cash.tbPeriod ON App.tbYearPeriod.StartOn = Cash.tbPeriod.StartOn INNER JOIN
                         App.tbMonth ON App.tbYearPeriod.MonthNumber = App.tbMonth.MonthNumber INNER JOIN
                         Cash.tbCode ON Cash.tbPeriod.CashCode = Cash.tbCode.CashCode INNER JOIN
                         Cash.tbCategory ON Cash.tbCode.CategoryCode = Cash.tbCategory.CategoryCode INNER JOIN
						 Cash.tbMode ON Cash.tbCategory.CashModeCode = Cash.tbMode.CashModeCode INNER JOIN
                         App.tbTaxCode ON Cash.tbCode.TaxCode = App.tbTaxCode.TaxCode


go
ALTER VIEW Cash.vwBudgetDataEntry
AS
SELECT        TOP (100) PERCENT App.tbYearPeriod.YearNumber, Cash.tbPeriod.CashCode, Cash.tbPeriod.StartOn, App.tbMonth.MonthName, Cash.tbPeriod.ForecastValue, Cash.tbPeriod.ForecastTax, Cash.tbPeriod.Note, 
                         Cash.tbPeriod.RowVer
FROM            App.tbYearPeriod INNER JOIN
                         Cash.tbPeriod ON App.tbYearPeriod.StartOn = Cash.tbPeriod.StartOn INNER JOIN
                         App.tbMonth ON App.tbYearPeriod.MonthNumber = App.tbMonth.MonthNumber
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
	SELECT     active_periods.YearNumber, active_periods.StartOn, ISNULL(SUM(vat.HomeSales), 0) AS HomeSales, ISNULL(SUM(vat.HomePurchases), 0) AS HomePurchases, ISNULL(SUM(vat.ExportSales), 0) AS ExportSales, ISNULL(SUM(vat.ExportPurchases), 0) AS ExportPurchases, 
							 ISNULL(SUM(vat.HomeSalesVat), 0) AS HomeSalesVat, ISNULL(SUM(vat.HomePurchasesVat), 0) AS HomePurchasesVat, ISNULL(SUM(vat.ExportSalesVat), 0) AS ExportSalesVat, ISNULL(SUM(vat.ExportPurchasesVat), 0) AS ExportPurchasesVat, 
							 ISNULL(SUM(vat.VatDue), 0) AS VatDue
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
	SELECT        active_periods.YearNumber, active_periods.StartOn, ISNULL(SUM(vat.HomeSales), 0) AS HomeSales, ISNULL(SUM(vat.HomePurchases), 0) AS HomePurchases, ISNULL(SUM(vat.ExportSales), 0) AS ExportSales, ISNULL(SUM(vat.ExportPurchases), 0) AS ExportPurchases, 
							 ISNULL(SUM(vat.HomeSalesVat), 0) AS HomeSalesVat, ISNULL(SUM(vat.HomePurchasesVat), 0) AS HomePurchasesVat, ISNULL(SUM(vat.ExportSalesVat), 0) AS ExportSalesVat, ISNULL(SUM(vat.ExportPurchasesVat), 0) AS ExportPurchasesVat, 
							 ISNULL(SUM(vat.VatAdjustment), 0) AS VatAdjustment, ISNULL(SUM(vat.VatDue), 0) AS VatDue
	FROM            active_periods LEFT OUTER JOIN
							 Cash.vwTaxVatTotals AS vat ON active_periods.StartOn = vat.StartOn
	GROUP BY active_periods.YearNumber, active_periods.StartOn;
go
ALTER VIEW Cash.vwSummary
AS
	WITH company AS
	(
		SELECT 0 AS SummaryId, SUM( Org.tbAccount.CurrentBalance) AS CompanyBalance 
		FROM Org.tbAccount WHERE ( Org.tbAccount.AccountClosed = 0) AND (Org.tbAccount.DummyAccount = 0)
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
ALTER VIEW Cash.vwTaxCorpTotalsByPeriod
AS
	WITH invoiced_tasks AS
	(
		SELECT (SELECT TOP (1) StartOn FROM App.tbYearPeriod WHERE (StartOn <= Invoice.tbInvoice.InvoicedOn) ORDER BY StartOn DESC) AS StartOn,  
								 CASE WHEN Invoice.tbType.CashModeCode = 0 THEN Invoice.tbTask.InvoiceValue * - 1 ELSE Invoice.tbTask.InvoiceValue END AS InvoiceValue
		FROM            Invoice.tbTask INNER JOIN
								 App.vwCorpTaxCashCodes CashCodes  ON Invoice.tbTask.CashCode = CashCodes.CashCode INNER JOIN
								 Invoice.tbInvoice ON Invoice.tbTask.InvoiceNumber = Invoice.tbInvoice.InvoiceNumber INNER JOIN
								 Invoice.tbType ON Invoice.tbInvoice.InvoiceTypeCode = Invoice.tbType.InvoiceTypeCode
	), invoiced_items AS
	(
		SELECT (SELECT TOP (1) StartOn FROM App.tbYearPeriod WHERE (StartOn <= Invoice.tbInvoice.InvoicedOn) ORDER BY StartOn DESC) AS StartOn,  
							  CASE WHEN Invoice.tbType.CashModeCode = 0 THEN Invoice.tbItem.InvoiceValue * - 1 ELSE Invoice.tbItem.InvoiceValue END AS InvoiceValue
		FROM         Invoice.tbItem INNER JOIN
							  App.vwCorpTaxCashCodes CashCodes ON Invoice.tbItem.CashCode = CashCodes.CashCode INNER JOIN
							  Invoice.tbInvoice ON Invoice.tbItem.InvoiceNumber = Invoice.tbInvoice.InvoiceNumber INNER JOIN
							  Invoice.tbType ON Invoice.tbInvoice.InvoiceTypeCode = Invoice.tbType.InvoiceTypeCode
	), netprofits AS	
	(
		SELECT StartOn, SUM(InvoiceValue) AS NetProfit FROM invoiced_tasks GROUP BY StartOn
		UNION
		SELECT StartOn, SUM(InvoiceValue) AS NetProfit FROM invoiced_items GROUP BY StartOn
	)
	, netprofit_consolidated AS
	(
		SELECT StartOn, SUM(NetProfit) AS NetProfit FROM netprofits GROUP BY StartOn
	)
	SELECT App.tbYearPeriod.StartOn, netprofit_consolidated.NetProfit, 
							netprofit_consolidated.NetProfit * App.tbYearPeriod.CorporationTaxRate + App.tbYearPeriod.TaxAdjustment AS CorporationTax, 
							App.tbYearPeriod.TaxAdjustment
	FROM         netprofit_consolidated INNER JOIN
							App.tbYearPeriod ON netprofit_consolidated.StartOn = App.tbYearPeriod.StartOn;

go
ALTER VIEW Cash.vwTaxCorpStatement
AS
	WITH tax_dates AS
	(
		SELECT PayOn, PayFrom, PayTo FROM Cash.fnTaxTypeDueDates(0)
	), period_totals AS
	(
		SELECT (SELECT PayOn FROM tax_dates WHERE totals.StartOn >= PayFrom AND totals.StartOn < PayTo) AS StartOn, CorporationTax
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
	)
	SELECT StartOn, CAST(TaxDue AS decimal(18, 5)) TaxDue, CAST(TaxPaid AS decimal(18, 5)) TaxPaid, CAST(Balance AS decimal(18, 5)) Balance FROM tax_statement 
	WHERE StartOn >= (SELECT MIN(StartOn) FROM App.tbYearPeriod p JOIN App.tbYear y ON p.YearNumber = y.YearNumber  WHERE y.CashStatusCode < 3);
go
ALTER VIEW Cash.vwTaxCorpAccruals
AS
	WITH corptax_ordered_confirmed AS
	(
		SELECT        task.TaskCode, task.ActionOn, task.Quantity, CASE WHEN Cash.tbCategory.CashModeCode = 0 THEN task.TotalCharge * - 1 ELSE task.TotalCharge END AS TotalCharge
		FROM            Task.tbTask AS task INNER JOIN
								 Cash.tbCode ON task.CashCode = Cash.tbCode.CashCode INNER JOIN
								 Cash.tbCategory ON Cash.tbCode.CategoryCode = Cash.tbCategory.CategoryCode AND Cash.tbCode.CategoryCode = Cash.tbCategory.CategoryCode
		WHERE        (task.TaskStatusCode BETWEEN 1 AND 2) AND (task.ActionOn <= (SELECT DATEADD(d, TaxHorizon, CURRENT_TIMESTAMP) AS HorizonOn FROM App.tbOptions))
	), corptax_ordered_invoices AS
	(
		SELECT corptax_ordered_confirmed.TaskCode, task_invoice.Quantity,
			CASE WHEN invoice_type.CashModeCode = 0 THEN task_invoice.InvoiceValue * -1 ELSE task_invoice.InvoiceValue END AS InvoiceValue
		FROM corptax_ordered_confirmed JOIN Invoice.tbTask task_invoice ON corptax_ordered_confirmed.TaskCode = task_invoice.TaskCode
			JOIN Invoice.tbInvoice invoice ON task_invoice.InvoiceNumber = invoice.InvoiceNumber
			JOIN Invoice.tbType invoice_type ON invoice_type.InvoiceTypeCode = invoice.InvoiceTypeCode
	), corptax_ordered AS
	(
		SELECT (SELECT TOP (1) StartOn FROM App.tbYearPeriod WHERE (StartOn <= corptax_ordered_confirmed.ActionOn) ORDER BY StartOn DESC) AS StartOn, 
			corptax_ordered_confirmed.TaskCode,
			corptax_ordered_confirmed.Quantity - ISNULL(corptax_ordered_invoices.Quantity, 0) AS QuantityRemaining,
			corptax_ordered_confirmed.TotalCharge - ISNULL(corptax_ordered_invoices.InvoiceValue, 0) AS OrderValue
		FROM corptax_ordered_confirmed 
			LEFT JOIN corptax_ordered_invoices ON corptax_ordered_confirmed.TaskCode = corptax_ordered_invoices.TaskCode
	)
	SELECT corptax_ordered.StartOn, TaskCode, QuantityRemaining, OrderValue, OrderValue * CorporationTaxRate AS TaxDue
	FROM corptax_ordered JOIN App.tbYearPeriod year_period ON corptax_ordered.StartOn = year_period.StartOn;
go
ALTER VIEW Cash.vwTaxCorpAuditAccruals
AS
	SELECT     App.tbYear.YearNumber, CONCAT(App.tbYear.Description, ' ', App.tbMonth.MonthName) AS YearPeriod, Cash.vwTaxCorpAccruals.StartOn, Task.tbTask.TaskCode, Task.tbTask.AccountCode, Org.tbOrg.AccountName, 
							 Task.tbTask.TaskTitle, Activity.tbActivity.ActivityCode, Task.tbStatus.TaskStatusCode, Task.tbStatus.TaskStatus, Task.tbTask.CashCode, Cash.tbCode.CashDescription, Activity.tbActivity.UnitOfMeasure, 
							 Cash.vwTaxCorpAccruals.QuantityRemaining, Cash.vwTaxCorpAccruals.OrderValue, Cash.vwTaxCorpAccruals.TaxDue
	FROM            Task.tbTask INNER JOIN
							 Org.tbOrg ON Task.tbTask.AccountCode = Org.tbOrg.AccountCode INNER JOIN
							 Cash.vwTaxCorpAccruals ON Task.tbTask.TaskCode = Cash.vwTaxCorpAccruals.TaskCode INNER JOIN
							 Task.tbStatus ON Task.tbTask.TaskStatusCode = Task.tbStatus.TaskStatusCode AND Task.tbTask.TaskStatusCode = Task.tbStatus.TaskStatusCode INNER JOIN
							 Activity.tbActivity ON Task.tbTask.ActivityCode = Activity.tbActivity.ActivityCode AND Task.tbTask.ActivityCode = Activity.tbActivity.ActivityCode INNER JOIN
							 Cash.tbCode ON Task.tbTask.CashCode = Cash.tbCode.CashCode AND Task.tbTask.CashCode = Cash.tbCode.CashCode INNER JOIN
							 App.tbYearPeriod ON Cash.vwTaxCorpAccruals.StartOn = App.tbYearPeriod.StartOn INNER JOIN
							 App.tbYear ON App.tbYearPeriod.YearNumber = App.tbYear.YearNumber AND App.tbYearPeriod.YearNumber = App.tbYear.YearNumber AND App.tbYearPeriod.YearNumber = App.tbYear.YearNumber AND 
							 App.tbYearPeriod.YearNumber = App.tbYear.YearNumber AND App.tbYearPeriod.YearNumber = App.tbYear.YearNumber AND App.tbYearPeriod.YearNumber = App.tbYear.YearNumber AND 
							 App.tbYearPeriod.YearNumber = App.tbYear.YearNumber INNER JOIN
							 App.tbMonth ON App.tbYearPeriod.MonthNumber = App.tbMonth.MonthNumber AND App.tbYearPeriod.MonthNumber = App.tbMonth.MonthNumber AND 
							 App.tbYearPeriod.MonthNumber = App.tbMonth.MonthNumber AND App.tbYearPeriod.MonthNumber = App.tbMonth.MonthNumber AND App.tbYearPeriod.MonthNumber = App.tbMonth.MonthNumber AND 
							 App.tbYearPeriod.MonthNumber = App.tbMonth.MonthNumber AND App.tbYearPeriod.MonthNumber = App.tbMonth.MonthNumber
go
ALTER VIEW Cash.vwTaxCorpTotals
AS
	WITH totals AS
	(
		SELECT netprofit_totals.StartOn, YEAR(App.tbYearPeriod.StartOn) AS PeriodYear, App.tbYear.Description, 
						  App.tbMonth.MonthName + ' ' + LTRIM(STR(YEAR(App.tbYearPeriod.StartOn))) AS Period, App.tbYearPeriod.CorporationTaxRate, 
						  App.tbYearPeriod.TaxAdjustment, SUM(netprofit_totals.NetProfit) AS NetProfit, SUM(netprofit_totals.CorporationTax) AS CorporationTax
		FROM       Cash.vwTaxCorpTotalsByPeriod  netprofit_totals INNER JOIN
							  App.tbYearPeriod ON netprofit_totals.StartOn = App.tbYearPeriod.StartOn INNER JOIN
							  App.tbYear ON App.tbYearPeriod.YearNumber = App.tbYear.YearNumber INNER JOIN
							  App.tbMonth ON App.tbYearPeriod.MonthNumber = App.tbMonth.MonthNumber
		WHERE     (App.tbYear.CashStatusCode BETWEEN 1 AND 2)
		GROUP BY App.tbYear.Description, App.tbMonth.MonthName, netprofit_totals.StartOn, YEAR(App.tbYearPeriod.StartOn), 
							  App.tbYearPeriod.CorporationTaxRate, App.tbYearPeriod.TaxAdjustment
	)
	SELECT StartOn, PeriodYear, Description, Period, CorporationTaxRate, TaxAdjustment, CAST(NetProfit AS decimal(18, 5)) NetProfit, CAST(CorporationTax AS decimal(18, 5)) CorporationTax
	FROM totals;
go
ALTER VIEW Cash.vwTaxVatAuditInvoices
AS
	WITH vat_transactions AS
	(
		SELECT   Invoice.tbInvoice.InvoicedOn, Invoice.tbInvoice.InvoiceNumber, Invoice.tbInvoice.InvoiceTypeCode, Invoice.tbItem.TaxCode, Invoice.tbItem.InvoiceValue, Invoice.tbItem.TaxValue,
								  ROUND((Invoice.tbItem.TaxValue /  Invoice.tbItem.InvoiceValue), 3) As CalcRate,
								 App.tbTaxCode.TaxRate, Org.tbOrg.EUJurisdiction, Invoice.tbItem.CashCode AS IdentityCode, Cash.tbCode.CashDescription As ItemDescription
		FROM            Invoice.tbItem INNER JOIN
								 Invoice.tbInvoice ON Invoice.tbItem.InvoiceNumber = Invoice.tbInvoice.InvoiceNumber INNER JOIN
								 Org.tbOrg ON Invoice.tbInvoice.AccountCode = Org.tbOrg.AccountCode INNER JOIN
								 App.tbTaxCode ON Invoice.tbItem.TaxCode = App.tbTaxCode.TaxCode INNER JOIN
								 Cash.tbCode ON Invoice.tbItem.CashCode = Cash.tbCode.CashCode
		WHERE        (App.tbTaxCode.TaxTypeCode = 1) AND (Invoice.tbItem.InvoiceValue <> 0)
		UNION
		SELECT   Invoice.tbInvoice.InvoicedOn, Invoice.tbTask.InvoiceNumber, Invoice.tbInvoice.InvoiceTypeCode, Invoice.tbTask.TaxCode, Invoice.tbTask.InvoiceValue, Invoice.tbTask.TaxValue, 
								 ROUND(Invoice.tbTask.TaxValue / Invoice.tbTask.InvoiceValue, 3) AS CalcRate, App.tbTaxCode.TaxRate, Org.tbOrg.EUJurisdiction, Invoice.tbTask.TaskCode AS IdentityCode, tbTask_1.TaskTitle As ItemDescription
		FROM            Invoice.tbTask INNER JOIN
								 Invoice.tbInvoice ON Invoice.tbTask.InvoiceNumber = Invoice.tbInvoice.InvoiceNumber INNER JOIN
								 Org.tbOrg ON Invoice.tbInvoice.AccountCode = Org.tbOrg.AccountCode INNER JOIN
								 App.tbTaxCode ON Invoice.tbTask.TaxCode = App.tbTaxCode.TaxCode INNER JOIN
								 Task.tbTask AS tbTask_1 ON Invoice.tbTask.TaskCode = tbTask_1.TaskCode
		WHERE        (App.tbTaxCode.TaxTypeCode = 1) AND (Invoice.tbTask.InvoiceValue <> 0)
	)
	, vat_dataset AS
	(
		SELECT  (SELECT PayTo FROM Cash.fnTaxTypeDueDates(1) due_dates WHERE vat_transactions.InvoicedOn >= PayFrom AND vat_transactions.InvoicedOn < PayTo) AS StartOn,
		 vat_transactions.InvoicedOn, InvoiceNumber, invoice_type.InvoiceType, vat_transactions.InvoiceTypeCode, TaxCode, InvoiceValue, TaxValue, TaxRate, EUJurisdiction, IdentityCode, ItemDescription,
				CASE WHEN EUJurisdiction = 0 THEN CASE vat_transactions.InvoiceTypeCode WHEN 0 THEN InvoiceValue WHEN 1 THEN
				InvoiceValue * - 1 ELSE 0 END ELSE 0 END AS HomeSales, 
				CASE WHEN EUJurisdiction = 0 THEN CASE vat_transactions.InvoiceTypeCode WHEN 2 THEN InvoiceValue WHEN 3 THEN
				InvoiceValue * - 1 ELSE 0 END ELSE 0 END AS HomePurchases, 
				CASE WHEN EUJurisdiction != 0 THEN CASE vat_transactions.InvoiceTypeCode WHEN 0 THEN InvoiceValue WHEN 1 THEN
				InvoiceValue * - 1 ELSE 0 END ELSE 0 END AS ExportSales, 
				CASE WHEN EUJurisdiction != 0 THEN CASE vat_transactions.InvoiceTypeCode WHEN 2 THEN InvoiceValue WHEN 3 THEN
				InvoiceValue * - 1 ELSE 0 END ELSE 0 END AS ExportPurchases, 
				CASE WHEN EUJurisdiction = 0 THEN CASE vat_transactions.InvoiceTypeCode WHEN 0 THEN TaxValue WHEN 1 THEN TaxValue
				* - 1 ELSE 0 END ELSE 0 END AS HomeSalesVat, 
				CASE WHEN EUJurisdiction = 0 THEN CASE vat_transactions.InvoiceTypeCode WHEN 2 THEN TaxValue WHEN 3 THEN TaxValue
				* - 1 ELSE 0 END ELSE 0 END AS HomePurchasesVat, 
				CASE WHEN EUJurisdiction != 0 THEN CASE vat_transactions.InvoiceTypeCode WHEN 0 THEN TaxValue WHEN 1 THEN TaxValue
				* - 1 ELSE 0 END ELSE 0 END AS ExportSalesVat, 
				CASE WHEN EUJurisdiction != 0 THEN CASE vat_transactions.InvoiceTypeCode WHEN 2 THEN TaxValue WHEN 3 THEN TaxValue
				* - 1 ELSE 0 END ELSE 0 END AS ExportPurchasesVat
		FROM  vat_transactions 
			JOIN Invoice.tbType invoice_type ON vat_transactions.InvoiceTypeCode = invoice_type.InvoiceTypeCode
	)
	SELECT CONCAT(App.tbYear.Description, ' ', App.tbMonth.MonthName) AS YearPeriod, vat_dataset.*,
		 (HomeSalesVat + ExportSalesVat) - (HomePurchasesVat + ExportPurchasesVat) AS VatDue
	FROM vat_dataset
		JOIN App.tbYearPeriod AS year_period ON vat_dataset.StartOn = year_period.StartOn INNER JOIN
                         App.tbYear ON year_period.YearNumber = App.tbYear.YearNumber INNER JOIN
                         App.tbMonth ON year_period.MonthNumber = App.tbMonth.MonthNumber;
go
ALTER VIEW Cash.vwTaxVatDetails
AS
SELECT        App.tbYearPeriod.YearNumber, App.tbYear.Description, CONCAT(App.tbMonth.MonthName, SPACE(1), YEAR(App.tbYearPeriod.StartOn)) AS PeriodName, Cash.vwTaxVatSummary.StartOn, 
                         Cash.vwTaxVatSummary.TaxCode, Cash.vwTaxVatSummary.HomeSales, Cash.vwTaxVatSummary.HomePurchases, Cash.vwTaxVatSummary.ExportSales, Cash.vwTaxVatSummary.ExportPurchases, 
                         Cash.vwTaxVatSummary.HomeSalesVat, Cash.vwTaxVatSummary.HomePurchasesVat, Cash.vwTaxVatSummary.ExportSalesVat, Cash.vwTaxVatSummary.ExportPurchasesVat, Cash.vwTaxVatSummary.VatDue                         
FROM            Cash.vwTaxVatSummary INNER JOIN
                         App.tbYearPeriod INNER JOIN
                         App.tbMonth ON App.tbYearPeriod.MonthNumber = App.tbMonth.MonthNumber ON Cash.vwTaxVatSummary.StartOn = App.tbYearPeriod.StartOn INNER JOIN
                         App.tbYear ON App.tbYearPeriod.YearNumber = App.tbYear.YearNumber;

go
ALTER VIEW Cash.vwTaxVatSummary
AS

	WITH vat_transactions AS
	(	
		SELECT  (SELECT TOP (1) p.StartOn FROM App.tbYearPeriod p WHERE (p.StartOn <= Invoice.tbInvoice.InvoicedOn) ORDER BY p.StartOn DESC) AS StartOn,  
				Invoice.tbInvoice.InvoiceNumber, Invoice.tbInvoice.InvoiceTypeCode, Invoice.tbItem.TaxCode, Invoice.tbItem.InvoiceValue, 
								 Invoice.tbItem.TaxValue, Org.tbOrg.EUJurisdiction, Invoice.tbItem.CashCode AS IdentityCode
		FROM   App.vwVatTaxCashCodes cash_codes INNER JOIN  Invoice.tbItem ON cash_codes.CashCode = Invoice.tbItem.CashCode 
				INNER JOIN Invoice.tbInvoice ON Invoice.tbItem.InvoiceNumber = Invoice.tbInvoice.InvoiceNumber INNER JOIN
								 Org.tbOrg ON Invoice.tbInvoice.AccountCode = Org.tbOrg.AccountCode INNER JOIN
								 App.tbTaxCode ON Invoice.tbItem.TaxCode = App.tbTaxCode.TaxCode
		WHERE        (App.tbTaxCode.TaxTypeCode = 1)
		UNION
		SELECT  (SELECT TOP (1) p.StartOn FROM App.tbYearPeriod p WHERE (p.StartOn <= Invoice.tbInvoice.InvoicedOn) ORDER BY p.StartOn DESC) AS StartOn,  
					Invoice.tbTask.InvoiceNumber, Invoice.tbInvoice.InvoiceTypeCode, Invoice.tbTask.TaxCode, Invoice.tbTask.InvoiceValue, 
								 Invoice.tbTask.TaxValue, Org.tbOrg.EUJurisdiction, Invoice.tbTask.TaskCode AS IdentityCode
		FROM    App.vwVatTaxCashCodes cash_codes INNER JOIN  Invoice.tbTask ON cash_codes.CashCode = Invoice.tbTask.CashCode 
					INNER JOIN Invoice.tbInvoice ON Invoice.tbTask.InvoiceNumber = Invoice.tbInvoice.InvoiceNumber INNER JOIN
								 Org.tbOrg ON Invoice.tbInvoice.AccountCode = Org.tbOrg.AccountCode INNER JOIN
								 App.tbTaxCode ON Invoice.tbTask.TaxCode = App.tbTaxCode.TaxCode
		WHERE        (App.tbTaxCode.TaxTypeCode = 1)
	), vat_detail AS
	(
		SELECT        StartOn, TaxCode, 
								 CASE WHEN EUJurisdiction = 0 THEN CASE InvoiceTypeCode WHEN 0 THEN InvoiceValue WHEN 1 THEN
								  InvoiceValue * - 1 ELSE 0 END ELSE 0 END AS HomeSales, 
								 CASE WHEN EUJurisdiction = 0 THEN CASE InvoiceTypeCode WHEN 2 THEN InvoiceValue WHEN 3 THEN
								  InvoiceValue * - 1 ELSE 0 END ELSE 0 END AS HomePurchases, 
								 CASE WHEN EUJurisdiction != 0 THEN CASE InvoiceTypeCode WHEN 0 THEN InvoiceValue WHEN 1 THEN
								  InvoiceValue * - 1 ELSE 0 END ELSE 0 END AS ExportSales, 
								 CASE WHEN EUJurisdiction != 0 THEN CASE InvoiceTypeCode WHEN 2 THEN InvoiceValue WHEN 3 THEN
								  InvoiceValue * - 1 ELSE 0 END ELSE 0 END AS ExportPurchases, 
								 CASE WHEN EUJurisdiction = 0 THEN CASE InvoiceTypeCode WHEN 0 THEN TaxValue WHEN 1 THEN TaxValue
								  * - 1 ELSE 0 END ELSE 0 END AS HomeSalesVat, 
								 CASE WHEN EUJurisdiction = 0 THEN CASE InvoiceTypeCode WHEN 2 THEN TaxValue WHEN 3 THEN TaxValue
								  * - 1 ELSE 0 END ELSE 0 END AS HomePurchasesVat, 
								 CASE WHEN EUJurisdiction != 0 THEN CASE InvoiceTypeCode WHEN 0 THEN TaxValue WHEN 1 THEN TaxValue
								  * - 1 ELSE 0 END ELSE 0 END AS ExportSalesVat, 
								 CASE WHEN EUJurisdiction != 0 THEN CASE InvoiceTypeCode WHEN 2 THEN TaxValue WHEN 3 THEN TaxValue
								  * - 1 ELSE 0 END ELSE 0 END AS ExportPurchasesVat
		FROM  vat_transactions
	), vatcode_summary AS
	(
		SELECT        StartOn, TaxCode, SUM(HomeSales) AS HomeSales, SUM(HomePurchases) AS HomePurchases, SUM(ExportSales) AS ExportSales, SUM(ExportPurchases) AS ExportPurchases, SUM(HomeSalesVat) 
								AS HomeSalesVat, SUM(HomePurchasesVat) AS HomePurchasesVat, SUM(ExportSalesVat) AS ExportSalesVat, SUM(ExportPurchasesVat) AS ExportPurchasesVat
		FROM            vat_detail
		GROUP BY StartOn, TaxCode
	)
	SELECT   StartOn, 
		TaxCode, HomeSales, HomePurchases, ExportSales, ExportPurchases, HomeSalesVat, HomePurchasesVat, ExportSalesVat, ExportPurchasesVat
			, (HomeSalesVat + ExportSalesVat) - (HomePurchasesVat + ExportPurchasesVat) AS VatDue
	FROM vatcode_summary;


go
ALTER VIEW Cash.vwTaxVatTotals
AS
	WITH vat_dates AS
	(
		SELECT PayFrom, PayTo FROM Cash.fnTaxTypeDueDates(1)
	), vatPeriod AS
	(
		SELECT        StartOn, y.YearNumber, p.MonthNumber,
			(SELECT PayTo FROM vat_dates WHERE p.StartOn >= PayFrom AND p.StartOn < PayTo) AS VatStartOn, VatAdjustment
		FROM            App.tbYearPeriod AS p JOIN App.tbYear AS y ON p.YearNumber = y.YearNumber 
		WHERE     (y.CashStatusCode = 1) OR (y.CashStatusCode = 2)
	), vat_results AS
	(
		SELECT VatStartOn AS PayTo, DATEADD(MONTH, -1, VatStartOn) AS PostOn,
			SUM(HomeSales) AS HomeSales, SUM(HomePurchases) AS HomePurchases, SUM(ExportSales) AS ExportSales, SUM(ExportPurchases) AS ExportPurchases, 
			SUM(HomeSalesVat) AS HomeSalesVat, SUM(HomePurchasesVat) AS HomePurchasesVat, 
			SUM(ExportSalesVat) AS ExportSalesVat, SUM(ExportPurchasesVat) AS ExportPurchasesVat, SUM(VatDue) AS VatDue
		FROM Cash.vwTaxVatSummary vatCodeDue JOIN vatPeriod ON vatCodeDue.StartOn = vatPeriod.StartOn
		GROUP BY VatStartOn
	), vat_adjustments AS
	(
		SELECT VatStartOn AS PayTo, SUM(VatAdjustment) AS VatAdjustment
		FROM vatPeriod p 
		GROUP BY VatStartOn
	)
	SELECT active_year.YearNumber, active_year.Description, active_month.MonthName AS Period, vat_results.PostOn AS StartOn, HomeSales, HomePurchases, ExportSales, ExportPurchases, HomeSalesVat, HomePurchasesVat, ExportSalesVat, ExportPurchasesVat,
		vat_adjustments.VatAdjustment, VatDue - vat_adjustments.VatAdjustment AS VatDue
	FROM vat_results JOIN vat_adjustments ON vat_results.PayTo = vat_adjustments.PayTo
		JOIN App.tbYearPeriod year_period ON vat_results.PostOn = year_period.StartOn
		JOIN App.tbMonth active_month ON year_period.MonthNumber = active_month.MonthNumber
		JOIN App.tbYear active_year ON year_period.YearNumber = active_year.YearNumber;

go
ALTER VIEW Cash.vwUnMirrored
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
ALTER VIEW Invoice.vwAgedDebtPurchases
AS
SELECT TOP 100 PERCENT Invoice.tbInvoice.InvoiceNumber, Invoice.tbInvoice.AccountCode, Org.tbOrg.AccountName, Invoice.tbInvoice.InvoiceTypeCode, Invoice.tbInvoice.InvoiceStatusCode, Invoice.tbStatus.InvoiceStatus, 
                         Invoice.tbType.InvoiceType, (Invoice.tbInvoice.InvoiceValue + Invoice.tbInvoice.TaxValue) - (Invoice.tbInvoice.PaidValue + Invoice.tbInvoice.PaidTaxValue) AS UnpaidValue, DATEDIFF(DD, CURRENT_TIMESTAMP, 
                         Invoice.tbInvoice.InvoicedOn) AS UnpaidDays, Invoice.tbInvoice.InvoicedOn, Invoice.tbInvoice.DueOn, Invoice.tbInvoice.ExpectedOn, Invoice.tbInvoice.InvoiceValue, Invoice.tbInvoice.TaxValue, Invoice.tbInvoice.PaymentTerms, 
                         Invoice.tbInvoice.Notes
FROM            Invoice.tbInvoice INNER JOIN
                         Invoice.tbStatus ON Invoice.tbInvoice.InvoiceStatusCode = Invoice.tbStatus.InvoiceStatusCode INNER JOIN
                         Invoice.tbType ON Invoice.tbInvoice.InvoiceTypeCode = Invoice.tbType.InvoiceTypeCode INNER JOIN
                         Org.tbOrg ON Invoice.tbInvoice.AccountCode = Org.tbOrg.AccountCode
WHERE        (Invoice.tbInvoice.InvoiceTypeCode > 1) AND (Invoice.tbInvoice.InvoiceStatusCode < 3)
ORDER BY Invoice.tbInvoice.ExpectedOn;

go
ALTER VIEW Invoice.vwAgedDebtSales
AS
SELECT TOP 100 PERCENT  Invoice.tbInvoice.InvoiceNumber, Invoice.tbInvoice.AccountCode, Org.tbOrg.AccountName, Invoice.tbInvoice.InvoiceTypeCode, Invoice.tbInvoice.InvoiceStatusCode, Invoice.tbStatus.InvoiceStatus, 
                         Invoice.tbType.InvoiceType, (Invoice.tbInvoice.InvoiceValue + Invoice.tbInvoice.TaxValue) - (Invoice.tbInvoice.PaidValue + Invoice.tbInvoice.PaidTaxValue) AS UnpaidValue, DATEDIFF(DD, CURRENT_TIMESTAMP, 
                         Invoice.tbInvoice.InvoicedOn) AS UnpaidDays, Invoice.tbInvoice.InvoicedOn, Invoice.tbInvoice.DueOn, Invoice.tbInvoice.ExpectedOn, Invoice.tbInvoice.InvoiceValue, Invoice.tbInvoice.TaxValue, Invoice.tbInvoice.PaymentTerms, 
                         Invoice.tbInvoice.Notes
FROM            Invoice.tbInvoice INNER JOIN
                         Invoice.tbStatus ON Invoice.tbInvoice.InvoiceStatusCode = Invoice.tbStatus.InvoiceStatusCode INNER JOIN
                         Invoice.tbType ON Invoice.tbInvoice.InvoiceTypeCode = Invoice.tbType.InvoiceTypeCode INNER JOIN
                         Org.tbOrg ON Invoice.tbInvoice.AccountCode = Org.tbOrg.AccountCode
WHERE        (Invoice.tbInvoice.InvoiceTypeCode < 2) AND (Invoice.tbInvoice.InvoiceStatusCode < 3)
ORDER BY Invoice.tbInvoice.ExpectedOn;

go
ALTER VIEW Invoice.vwCandidateCredits
AS
SELECT TOP 100 PERCENT Invoice.tbInvoice.InvoiceNumber, Invoice.tbInvoice.UserId, Invoice.tbInvoice.AccountCode, Invoice.tbInvoice.InvoiceTypeCode, Invoice.tbInvoice.InvoiceStatusCode, Invoice.tbInvoice.InvoicedOn, 
                         Invoice.tbInvoice.InvoiceValue, Invoice.tbInvoice.TaxValue, Invoice.tbInvoice.PaidValue, Invoice.tbInvoice.PaidTaxValue, Invoice.tbInvoice.PaymentTerms, Invoice.tbInvoice.Notes, Invoice.tbInvoice.Printed, 
                         Invoice.tbInvoice.DueOn, Invoice.tbInvoice.Spooled, Usr.tbUser.UserName, Invoice.tbStatus.InvoiceStatus, Invoice.tbType.InvoiceType
FROM            Invoice.tbInvoice INNER JOIN
                         Invoice.tbStatus ON Invoice.tbInvoice.InvoiceStatusCode = Invoice.tbStatus.InvoiceStatusCode INNER JOIN
                         Invoice.tbType ON Invoice.tbInvoice.InvoiceTypeCode = Invoice.tbType.InvoiceTypeCode INNER JOIN
                         Usr.tbUser ON Invoice.tbInvoice.UserId = Usr.tbUser.UserId
WHERE        (Invoice.tbInvoice.InvoiceTypeCode = 0)
ORDER BY Invoice.tbInvoice.AccountCode, Invoice.tbInvoice.InvoicedOn DESC
go
ALTER VIEW Invoice.vwCandidateDebits
AS
SELECT TOP 100 PERCENT Invoice.tbInvoice.InvoiceNumber, Invoice.tbInvoice.UserId, Invoice.tbInvoice.AccountCode, Invoice.tbInvoice.InvoiceTypeCode, Invoice.tbInvoice.InvoiceStatusCode, Invoice.tbInvoice.InvoicedOn, 
                         Invoice.tbInvoice.InvoiceValue, Invoice.tbInvoice.TaxValue, Invoice.tbInvoice.PaidValue, Invoice.tbInvoice.PaidTaxValue, Invoice.tbInvoice.PaymentTerms, Invoice.tbInvoice.Notes, Invoice.tbInvoice.Printed, 
                         Invoice.tbInvoice.DueOn, Invoice.tbInvoice.Spooled, Usr.tbUser.UserName, Invoice.tbStatus.InvoiceStatus, Invoice.tbType.InvoiceType
FROM            Invoice.tbInvoice INNER JOIN
                         Invoice.tbStatus ON Invoice.tbInvoice.InvoiceStatusCode = Invoice.tbStatus.InvoiceStatusCode INNER JOIN
                         Invoice.tbType ON Invoice.tbInvoice.InvoiceTypeCode = Invoice.tbType.InvoiceTypeCode INNER JOIN
                         Usr.tbUser ON Invoice.tbInvoice.UserId = Usr.tbUser.UserId
WHERE        (Invoice.tbInvoice.InvoiceTypeCode = 2)
ORDER BY Invoice.tbInvoice.AccountCode, Invoice.tbInvoice.InvoicedOn DESC
go
ALTER VIEW Invoice.vwCandidateSales
AS
SELECT TOP 100 PERCENT TaskCode, AccountCode, ContactName, ActivityCode, ActionOn, ActionedOn, TaskTitle, Quantity, UnitCharge, TotalCharge, TaskNotes, CashDescription, ActionName, OwnerName, TaskStatus, InsertedBy, 
                         InsertedOn, UpdatedBy, UpdatedOn, TaskStatusCode
FROM            Task.vwTasks
WHERE        (TaskStatusCode = 1 OR
                         TaskStatusCode = 2) AND (CashModeCode = 1) AND (CashCode IS NOT NULL)
ORDER BY ActionOn;
go
ALTER VIEW Invoice.vwCandidatePurchases
AS
SELECT TOP 100 PERCENT  TaskCode, AccountCode, ContactName, ActivityCode, ActionOn, ActionedOn, Quantity, UnitCharge, TotalCharge, TaskTitle, TaskNotes, CashDescription, ActionName, OwnerName, TaskStatus, InsertedBy, 
                         InsertedOn, UpdatedBy, UpdatedOn, TaskStatusCode
FROM            Task.vwTasks
WHERE        (TaskStatusCode = 1 OR
                         TaskStatusCode = 2) AND (CashModeCode = 0) AND (CashCode IS NOT NULL)
ORDER BY ActionOn;
go
ALTER VIEW Invoice.vwChangeLog
AS
	SELECT LogId, InvoiceNumber, ChangedOn, changelog.TransmitStatusCode, transmit.TransmitStatus, changelog.InvoiceStatusCode, invoicestatus.InvoiceStatus, DueOn, InvoiceValue, TaxValue, PaidValue, PaidTaxValue, UpdatedBy
	FROM Invoice.tbChangeLog changelog
		JOIN Org.tbTransmitStatus transmit ON changelog.TransmitStatusCode = transmit.TransmitStatusCode
		JOIN Invoice.tbStatus invoicestatus ON changelog.InvoiceStatusCode = invoicestatus.InvoiceStatusCode;
go
ALTER VIEW Invoice.vwCreditNoteSpool
AS
SELECT        credit_note.InvoiceNumber, credit_note.Printed, Invoice.tbType.InvoiceType, credit_note.InvoiceStatusCode, Usr.tbUser.UserName, credit_note.AccountCode, Org.tbOrg.AccountName, Invoice.tbStatus.InvoiceStatus, 
                         credit_note.InvoicedOn, credit_note.InvoiceValue AS InvoiceValueTotal, credit_note.TaxValue AS TaxValueTotal, credit_note.PaymentTerms, credit_note.Notes, Org.tbOrg.EmailAddress, 
                         Org.tbAddress.Address AS InvoiceAddress, tbInvoiceTask.TaskCode, Task.tbTask.TaskTitle, Task.tbTask.ActionedOn, tbInvoiceTask.Quantity, Activity.tbActivity.UnitOfMeasure, tbInvoiceTask.TaxCode, 
                         tbInvoiceTask.InvoiceValue, tbInvoiceTask.TaxValue
FROM            Invoice.tbInvoice AS credit_note INNER JOIN
                         Invoice.tbStatus ON credit_note.InvoiceStatusCode = Invoice.tbStatus.InvoiceStatusCode INNER JOIN
                         Org.tbOrg ON credit_note.AccountCode = Org.tbOrg.AccountCode INNER JOIN
                         Usr.tbUser ON credit_note.UserId = Usr.tbUser.UserId LEFT OUTER JOIN
                         Org.tbAddress ON Org.tbOrg.AddressCode = Org.tbAddress.AddressCode INNER JOIN
                         Invoice.tbTask AS tbInvoiceTask ON credit_note.InvoiceNumber = tbInvoiceTask.InvoiceNumber INNER JOIN
                         Task.tbTask ON tbInvoiceTask.TaskCode = Task.tbTask.TaskCode INNER JOIN
                         Activity.tbActivity ON Task.tbTask.ActivityCode = Activity.tbActivity.ActivityCode INNER JOIN
                         Invoice.tbType ON credit_note.InvoiceTypeCode = Invoice.tbType.InvoiceTypeCode
WHERE credit_note.InvoiceTypeCode = 1 
	AND EXISTS (SELECT * FROM App.tbDocSpool AS doc WHERE DocTypeCode = 5 AND UserName = SUSER_SNAME() AND credit_note.InvoiceNumber = doc.DocumentNumber);

go
ALTER VIEW Invoice.vwDebitNoteSpool
AS
SELECT        debit_note.Printed, debit_note.InvoiceNumber, Invoice.tbType.InvoiceType, debit_note.InvoiceStatusCode, Usr.tbUser.UserName, debit_note.AccountCode, Org.tbOrg.AccountName, Invoice.tbStatus.InvoiceStatus, 
                         debit_note.InvoicedOn, debit_note.InvoiceValue AS InvoiceValueTotal, debit_note.TaxValue AS TaxValueTotal, debit_note.PaymentTerms, debit_note.Notes, Org.tbOrg.EmailAddress, 
                         Org.tbAddress.Address AS InvoiceAddress, tbInvoiceTask.TaskCode, Task.tbTask.TaskTitle, Task.tbTask.ActionedOn, tbInvoiceTask.Quantity, Activity.tbActivity.UnitOfMeasure, tbInvoiceTask.TaxCode, 
                         tbInvoiceTask.InvoiceValue, tbInvoiceTask.TaxValue
FROM            Invoice.tbInvoice AS debit_note INNER JOIN
                         Invoice.tbStatus ON debit_note.InvoiceStatusCode = Invoice.tbStatus.InvoiceStatusCode INNER JOIN
                         Org.tbOrg ON debit_note.AccountCode = Org.tbOrg.AccountCode INNER JOIN
                         Usr.tbUser ON debit_note.UserId = Usr.tbUser.UserId LEFT OUTER JOIN
                         Org.tbAddress ON Org.tbOrg.AddressCode = Org.tbAddress.AddressCode INNER JOIN
                         Invoice.tbTask AS tbInvoiceTask ON debit_note.InvoiceNumber = tbInvoiceTask.InvoiceNumber INNER JOIN
                         Task.tbTask ON tbInvoiceTask.TaskCode = Task.tbTask.TaskCode INNER JOIN
                         Activity.tbActivity ON Task.tbTask.ActivityCode = Activity.tbActivity.ActivityCode INNER JOIN
                         Invoice.tbType ON debit_note.InvoiceTypeCode = Invoice.tbType.InvoiceTypeCode
WHERE debit_note.InvoiceTypeCode = 3 AND
	EXISTS (SELECT * FROM App.tbDocSpool AS doc WHERE DocTypeCode = 6 AND UserName = SUSER_SNAME() AND debit_note.InvoiceNumber = doc.DocumentNumber);

go

ALTER VIEW Invoice.vwDoc
AS
SELECT     Org.tbOrg.EmailAddress, Usr.tbUser.UserName, Org.tbOrg.AccountCode, Org.tbOrg.AccountName, Org.tbAddress.Address AS InvoiceAddress, 
                      Invoice.tbInvoice.InvoiceNumber, Invoice.tbType.InvoiceType, Invoice.tbStatus.InvoiceStatus, Invoice.tbInvoice.InvoicedOn, Invoice.tbInvoice.DueOn, 
                      Invoice.tbInvoice.InvoiceValue, Invoice.tbInvoice.TaxValue, Invoice.tbInvoice.PaymentTerms, Invoice.tbInvoice.Notes
FROM         Invoice.tbInvoice INNER JOIN
                      Org.tbOrg ON Invoice.tbInvoice.AccountCode = Org.tbOrg.AccountCode INNER JOIN
                      Invoice.tbType ON Invoice.tbInvoice.InvoiceTypeCode = Invoice.tbType.InvoiceTypeCode INNER JOIN
                      Usr.tbUser ON Invoice.tbInvoice.UserId = Usr.tbUser.UserId INNER JOIN
                      Invoice.tbStatus ON Invoice.tbInvoice.InvoiceStatusCode = Invoice.tbStatus.InvoiceStatusCode LEFT OUTER JOIN
                      Org.tbAddress ON Org.tbOrg.AddressCode = Org.tbAddress.AddressCode
go
ALTER VIEW Invoice.vwDocItem
AS
SELECT     Invoice.tbItem.InvoiceNumber, Invoice.tbItem.CashCode, Cash.tbCode.CashDescription, Invoice.tbInvoice.InvoicedOn AS ActionedOn, 
                      Invoice.tbItem.TaxCode, Invoice.tbItem.InvoiceValue, Invoice.tbItem.TaxValue, Invoice.tbItem.ItemReference
FROM         Invoice.tbItem INNER JOIN
                      Cash.tbCode ON Invoice.tbItem.CashCode = Cash.tbCode.CashCode INNER JOIN
                      Invoice.tbInvoice ON Invoice.tbItem.InvoiceNumber = Invoice.tbInvoice.InvoiceNumber
go
ALTER VIEW Invoice.vwDocTask
AS
SELECT        tbTaskInvoice.InvoiceNumber, tbTaskInvoice.TaskCode, Task.tbTask.TaskTitle, Task.tbTask.ActivityCode, tbTaskInvoice.CashCode, Cash.tbCode.CashDescription, Task.tbTask.ActionedOn, tbTaskInvoice.Quantity, 
                         Activity.tbActivity.UnitOfMeasure, tbTaskInvoice.InvoiceValue, tbTaskInvoice.TaxValue, tbTaskInvoice.TaxCode, Task.tbTask.SecondReference
FROM            Invoice.tbTask AS tbTaskInvoice INNER JOIN
                         Task.tbTask ON tbTaskInvoice.TaskCode = Task.tbTask.TaskCode AND tbTaskInvoice.TaskCode = Task.tbTask.TaskCode INNER JOIN
                         Cash.tbCode ON tbTaskInvoice.CashCode = Cash.tbCode.CashCode INNER JOIN
                         Activity.tbActivity ON Task.tbTask.ActivityCode = Activity.tbActivity.ActivityCode
go
ALTER VIEW Invoice.vwHistoryCashCodes
AS
SELECT        App.tbYearPeriod.YearNumber, CONCAT(App.tbMonth.MonthName, SPACE(1), YEAR(App.tbYearPeriod.StartOn)) AS Period, Invoice.vwRegisterDetail.StartOn, Invoice.vwRegisterDetail.CashCode, 
                         Invoice.vwRegisterDetail.CashDescription, SUM(Invoice.vwRegisterDetail.InvoiceValue) AS TotalInvoiceValue, SUM(Invoice.vwRegisterDetail.TaxValue) AS TotalTaxValue
FROM            Invoice.vwRegisterDetail INNER JOIN
                         App.tbYearPeriod INNER JOIN
                         App.tbMonth ON App.tbYearPeriod.MonthNumber = App.tbMonth.MonthNumber ON Invoice.vwRegisterDetail.StartOn = App.tbYearPeriod.StartOn INNER JOIN
                         App.tbYear ON App.tbYearPeriod.YearNumber = App.tbYear.YearNumber
GROUP BY App.tbYearPeriod.YearNumber, CONCAT(App.tbMonth.MonthName, SPACE(1), YEAR(App.tbYearPeriod.StartOn)), Invoice.vwRegisterDetail.StartOn, Invoice.vwRegisterDetail.CashCode, 
                         Invoice.vwRegisterDetail.CashDescription;

go
ALTER VIEW Invoice.vwHistoryPurchaseItems
AS
SELECT        CONCAT(App.tbMonth.MonthName, SPACE(1), YEAR(App.tbYearPeriod.StartOn)) AS PeriodName, App.tbYearPeriod.YearNumber, Invoice.vwRegisterDetail.StartOn, Invoice.vwRegisterDetail.InvoiceNumber, 
                         Invoice.vwRegisterDetail.TaskCode, Invoice.vwRegisterDetail.CashCode, Invoice.vwRegisterDetail.CashDescription, Invoice.vwRegisterDetail.TaxCode, Invoice.vwRegisterDetail.TaxDescription, 
                         Invoice.vwRegisterDetail.AccountCode, Invoice.vwRegisterDetail.InvoiceTypeCode, Invoice.vwRegisterDetail.InvoiceStatusCode, Invoice.vwRegisterDetail.InvoicedOn, Invoice.vwRegisterDetail.InvoiceValue, 
                         Invoice.vwRegisterDetail.TaxValue, Invoice.vwRegisterDetail.PaidValue, Invoice.vwRegisterDetail.PaidTaxValue, Invoice.vwRegisterDetail.PaymentTerms, Invoice.vwRegisterDetail.Printed, 
                         Invoice.vwRegisterDetail.AccountName, Invoice.vwRegisterDetail.UserName, Invoice.vwRegisterDetail.InvoiceStatus, Invoice.vwRegisterDetail.CashModeCode, Invoice.vwRegisterDetail.InvoiceType, 
                         Invoice.vwRegisterDetail.UnpaidValue
FROM            Invoice.vwRegisterDetail INNER JOIN
                         App.tbYearPeriod ON Invoice.vwRegisterDetail.StartOn = App.tbYearPeriod.StartOn INNER JOIN
                         App.tbYear ON App.tbYearPeriod.YearNumber = App.tbYear.YearNumber INNER JOIN
                         App.tbMonth ON App.tbYearPeriod.MonthNumber = App.tbMonth.MonthNumber
WHERE        (Invoice.vwRegisterDetail.InvoiceTypeCode > 1);

go
ALTER VIEW Invoice.vwHistoryPurchases
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
ALTER VIEW Invoice.vwHistorySalesItems
AS
SELECT        App.tbYearPeriod.YearNumber, CONCAT(App.tbMonth.MonthName, SPACE(1), YEAR(App.tbYearPeriod.StartOn)) AS PeriodName, Invoice.vwRegisterDetail.StartOn, Invoice.vwRegisterDetail.InvoiceNumber, 
                         (Invoice.vwRegisterDetail.InvoiceValue + Invoice.vwRegisterDetail.TaxValue) - (Invoice.vwRegisterDetail.PaidValue + Invoice.vwRegisterDetail.PaidTaxValue) AS UnpaidValue, Invoice.vwRegisterDetail.TaskCode, 
                         Invoice.vwRegisterDetail.CashCode, Invoice.vwRegisterDetail.CashDescription, Invoice.vwRegisterDetail.TaxCode, Invoice.vwRegisterDetail.AccountCode, Invoice.vwRegisterDetail.InvoicedOn, 
                         Invoice.vwRegisterDetail.InvoiceValue, Invoice.vwRegisterDetail.TaxValue, Invoice.vwRegisterDetail.PaidValue, Invoice.vwRegisterDetail.PaidTaxValue, Invoice.vwRegisterDetail.PaymentTerms, 
                         Invoice.vwRegisterDetail.AccountName, Invoice.vwRegisterDetail.InvoiceStatus, Invoice.vwRegisterDetail.InvoiceType, Invoice.vwRegisterDetail.InvoiceTypeCode, 
                         Invoice.vwRegisterDetail.InvoiceStatusCode
FROM            Invoice.vwRegisterDetail INNER JOIN
                         App.tbYearPeriod ON Invoice.vwRegisterDetail.StartOn = App.tbYearPeriod.StartOn INNER JOIN
                         App.tbYear ON App.tbYearPeriod.YearNumber = App.tbYear.YearNumber INNER JOIN
                         App.tbMonth ON App.tbYearPeriod.MonthNumber = App.tbMonth.MonthNumber
WHERE        (Invoice.vwRegisterDetail.InvoiceTypeCode < 2);

go
ALTER VIEW Invoice.vwHistorySales
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
ALTER VIEW Invoice.vwItems
AS
SELECT        Invoice.tbItem.InvoiceNumber, Invoice.tbItem.CashCode, Cash.tbCode.CashDescription, Invoice.tbItem.TaxCode, Invoice.tbItem.TaxValue, Invoice.tbItem.InvoiceValue, Invoice.tbItem.ItemReference, 
                         Invoice.tbInvoice.InvoicedOn
FROM            Invoice.tbItem INNER JOIN
                         Invoice.tbInvoice ON Invoice.tbItem.InvoiceNumber = Invoice.tbInvoice.InvoiceNumber INNER JOIN
                         Cash.tbCode ON Invoice.tbItem.CashCode = Cash.tbCode.CashCode;

go
ALTER VIEW Invoice.vwMirrorDetails
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
ALTER VIEW Invoice.vwNetworkChangeLog
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
ALTER VIEW Invoice.vwNetworkDeploymentItems
AS
	SELECT Invoice.tbItem.InvoiceNumber, Invoice.tbItem.CashCode ChargeCode, 
		CASE WHEN LEN(COALESCE(CAST(Invoice.tbItem.ItemReference AS NVARCHAR), '')) > 0 THEN Invoice.tbItem.ItemReference ELSE Cash.tbCode.CashDescription END ChargeDescription, 
			Invoice.tbItem.InvoiceValue, Invoice.tbItem.TaxValue, 0 AS InvoiceQuantity, Invoice.tbItem.PaidValue, Invoice.tbItem.PaidTaxValue, Invoice.tbItem.TaxCode
	FROM  Invoice.tbItem 
		INNER JOIN Cash.tbCode ON Invoice.tbItem.CashCode = Cash.tbCode.CashCode;

go
ALTER VIEW Invoice.vwRegisterItems
AS
	SELECT       (SELECT TOP (1) p.StartOn FROM App.tbYearPeriod p WHERE (p.StartOn <= Invoice.tbInvoice.InvoicedOn) ORDER BY p.StartOn DESC) AS StartOn,  
					Invoice.tbInvoice.InvoiceNumber, Invoice.tbItem.CashCode AS TaskCode, Cash.tbCode.CashCode, Cash.tbCode.CashDescription, 
							 Invoice.tbItem.TaxCode, App.tbTaxCode.TaxDescription, Invoice.tbInvoice.AccountCode, Invoice.tbInvoice.InvoiceTypeCode, Invoice.tbInvoice.InvoiceStatusCode, Invoice.tbInvoice.InvoicedOn, 
							 CASE WHEN Invoice.tbType.CashModeCode = 0 THEN Invoice.tbItem.InvoiceValue * - 1 ELSE Invoice.tbItem.InvoiceValue END AS InvoiceValue, 
							 CASE WHEN Invoice.tbType.CashModeCode = 0 THEN Invoice.tbItem.TaxValue * - 1 ELSE Invoice.tbItem.TaxValue END AS TaxValue, 
							 CASE WHEN Invoice.tbType.CashModeCode = 0 THEN Invoice.tbItem.PaidValue * - 1 ELSE Invoice.tbItem.PaidValue END AS PaidValue, 
							 CASE WHEN Invoice.tbType.CashModeCode = 0 THEN Invoice.tbItem.PaidTaxValue * - 1 ELSE Invoice.tbItem.PaidTaxValue END AS PaidTaxValue, Invoice.tbInvoice.PaymentTerms, Invoice.tbInvoice.Printed, 
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
ALTER VIEW Invoice.vwRegister
AS
	SELECT       (SELECT TOP (1) p.StartOn FROM App.tbYearPeriod p WHERE (p.StartOn <= Invoice.tbInvoice.InvoicedOn) ORDER BY p.StartOn DESC) AS StartOn,  
			Invoice.tbInvoice.InvoiceNumber, Invoice.tbInvoice.AccountCode, Invoice.tbInvoice.InvoiceTypeCode, Invoice.tbInvoice.InvoiceStatusCode, 
							 Invoice.tbInvoice.InvoicedOn, CASE WHEN Invoice.tbType.CashModeCode = 0 THEN Invoice.tbInvoice.InvoiceValue * - 1 ELSE Invoice.tbInvoice.InvoiceValue END AS InvoiceValue, 
							 CASE WHEN Invoice.tbType.CashModeCode = 0 THEN Invoice.tbInvoice.TaxValue * - 1 ELSE Invoice.tbInvoice.TaxValue END AS TaxValue, 
							 CASE WHEN Invoice.tbType.CashModeCode = 0 THEN Invoice.tbInvoice.PaidValue * - 1 ELSE Invoice.tbInvoice.PaidValue END AS PaidValue, 
							 CASE WHEN Invoice.tbType.CashModeCode = 0 THEN Invoice.tbInvoice.PaidTaxValue * - 1 ELSE Invoice.tbInvoice.PaidTaxValue END AS PaidTaxValue, Invoice.tbInvoice.PaymentTerms, Invoice.tbInvoice.Notes, 
							 Invoice.tbInvoice.Printed, Org.tbOrg.AccountName, Usr.tbUser.UserName, Invoice.tbStatus.InvoiceStatus, Invoice.tbType.CashModeCode, Invoice.tbType.InvoiceType
	FROM            Invoice.tbInvoice INNER JOIN
							 Org.tbOrg ON Invoice.tbInvoice.AccountCode = Org.tbOrg.AccountCode INNER JOIN
							 Invoice.tbType ON Invoice.tbInvoice.InvoiceTypeCode = Invoice.tbType.InvoiceTypeCode INNER JOIN
							 Invoice.tbStatus ON Invoice.tbInvoice.InvoiceStatusCode = Invoice.tbStatus.InvoiceStatusCode INNER JOIN
							 Usr.tbUser ON Invoice.tbInvoice.UserId = Usr.tbUser.UserId
	WHERE        (Invoice.tbInvoice.AccountCode <> (SELECT AccountCode FROM App.tbOptions));

go
ALTER VIEW Invoice.vwRegisterExpenses
 AS
SELECT     Invoice.vwRegisterTasks.StartOn, Invoice.vwRegisterTasks.InvoiceNumber, Invoice.vwRegisterTasks.TaskCode, App.tbYearPeriod.YearNumber, 
                      App.tbYear.Description, App.tbMonth.MonthName + ' ' + LTRIM(STR(YEAR( App.tbYearPeriod.StartOn))) AS Period, Invoice.vwRegisterTasks.TaskTitle, 
                      Invoice.vwRegisterTasks.CashCode, Invoice.vwRegisterTasks.CashDescription, Invoice.vwRegisterTasks.TaxCode, Invoice.vwRegisterTasks.TaxDescription, 
                      Invoice.vwRegisterTasks.AccountCode, Invoice.vwRegisterTasks.InvoiceTypeCode, Invoice.vwRegisterTasks.InvoiceStatusCode, Invoice.vwRegisterTasks.InvoicedOn, 
                      Invoice.vwRegisterTasks.InvoiceValue, Invoice.vwRegisterTasks.TaxValue, Invoice.vwRegisterTasks.PaidValue, Invoice.vwRegisterTasks.PaidTaxValue, 
                      Invoice.vwRegisterTasks.PaymentTerms, Invoice.vwRegisterTasks.Printed, Invoice.vwRegisterTasks.AccountName, Invoice.vwRegisterTasks.UserName, 
                      Invoice.vwRegisterTasks.InvoiceStatus, Invoice.vwRegisterTasks.CashModeCode, Invoice.vwRegisterTasks.InvoiceType, 
                      (Invoice.vwRegisterTasks.InvoiceValue + Invoice.vwRegisterTasks.TaxValue) - (Invoice.vwRegisterTasks.PaidValue + Invoice.vwRegisterTasks.PaidTaxValue) 
                      AS UnpaidValue
FROM         Invoice.vwRegisterTasks INNER JOIN
                      App.tbYearPeriod ON Invoice.vwRegisterTasks.StartOn = App.tbYearPeriod.StartOn INNER JOIN
                      App.tbYear ON App.tbYearPeriod.YearNumber = App.tbYear.YearNumber INNER JOIN
                      App.tbMonth ON App.tbYearPeriod.MonthNumber = App.tbMonth.MonthNumber
WHERE     (Task.fnIsExpense(Invoice.vwRegisterTasks.TaskCode) = 1)
go
ALTER VIEW Invoice.vwRegisterCashCodes
AS
	SELECT TOP 100 PERCENT StartOn, CashCode, CashDescription, SUM(InvoiceValue) AS TotalInvoiceValue, SUM(TaxValue) AS TotalTaxValue
	FROM            Invoice.vwRegisterDetail
	GROUP BY StartOn, CashCode, CashDescription
	ORDER BY StartOn, CashCode;

go
ALTER VIEW Invoice.vwRegisterPurchases
AS
SELECT        StartOn, InvoiceNumber, AccountCode, InvoiceTypeCode, InvoiceStatusCode, InvoicedOn, InvoiceValue, TaxValue, PaidValue, PaidTaxValue, PaymentTerms, Notes, Printed, AccountName, UserName, 
                         InvoiceStatus, CashModeCode, InvoiceType, (InvoiceValue + TaxValue) - (PaidValue + PaidTaxValue) AS UnpaidValue
FROM            Invoice.vwRegister
WHERE        (InvoiceTypeCode > 1);

go
ALTER VIEW Invoice.vwRegisterPurchaseTasks
AS
SELECT        StartOn, InvoiceNumber, TaskCode, CashCode, CashDescription, TaxCode, TaxDescription, AccountCode, InvoiceTypeCode, InvoiceStatusCode, InvoicedOn, InvoiceValue, TaxValue, PaidValue, PaidTaxValue, 
                         PaymentTerms, Printed, AccountName, UserName, InvoiceStatus, CashModeCode, InvoiceType, (InvoiceValue + TaxValue) - (PaidValue + PaidTaxValue) AS UnpaidValue
FROM            Invoice.vwRegisterDetail
WHERE        (InvoiceTypeCode > 1);

go
ALTER VIEW Invoice.vwRegisterSales
AS
SELECT        StartOn, InvoiceNumber, AccountCode, InvoiceTypeCode, InvoiceStatusCode, InvoicedOn, InvoiceValue, TaxValue, PaidValue, PaidTaxValue, PaymentTerms, Notes, Printed, AccountName, UserName, 
                         InvoiceStatus, CashModeCode, InvoiceType, (InvoiceValue + TaxValue) - (PaidValue + PaidTaxValue) AS UnpaidValue
FROM            Invoice.vwRegister
WHERE        (InvoiceTypeCode < 2);

go
ALTER VIEW Invoice.vwRegisterSaleTasks
AS
SELECT        StartOn, InvoiceNumber, TaskCode, CashCode, CashDescription, TaxCode, TaxDescription, AccountCode, InvoiceTypeCode, InvoiceStatusCode, InvoicedOn, InvoiceValue, TaxValue, PaidValue, PaidTaxValue, 
                         PaymentTerms, Printed, AccountName, UserName, InvoiceStatus, CashModeCode, InvoiceType, (InvoiceValue + TaxValue) - (PaidValue + PaidTaxValue) AS UnpaidValue
FROM            Invoice.vwRegisterDetail
WHERE        (InvoiceTypeCode < 2);

go
ALTER VIEW Invoice.vwSalesInvoiceSpool
AS
SELECT        sales_invoice.InvoiceNumber, Invoice.tbType.InvoiceType, sales_invoice.InvoiceStatusCode, Usr.tbUser.UserName, sales_invoice.AccountCode, Org.tbOrg.AccountName, Invoice.tbStatus.InvoiceStatus, 
                         sales_invoice.InvoicedOn, sales_invoice.InvoiceValue AS InvoiceValueTotal, sales_invoice.TaxValue AS TaxValueTotal, sales_invoice.PaymentTerms, sales_invoice.DueOn, sales_invoice.Notes, Org.tbOrg.EmailAddress, 
                         Org.tbAddress.Address AS InvoiceAddress, tbInvoiceTask.TaskCode, Task.tbTask.TaskTitle, Task.tbTask.ActivityCode, Task.tbTask.ActionedOn, tbInvoiceTask.Quantity, Activity.tbActivity.UnitOfMeasure, tbInvoiceTask.TaxCode, 
                         tbInvoiceTask.InvoiceValue, tbInvoiceTask.TaxValue
FROM            Invoice.tbInvoice AS sales_invoice INNER JOIN
                         Invoice.tbStatus ON sales_invoice.InvoiceStatusCode = Invoice.tbStatus.InvoiceStatusCode INNER JOIN
                         Org.tbOrg ON sales_invoice.AccountCode = Org.tbOrg.AccountCode INNER JOIN
                         Usr.tbUser ON sales_invoice.UserId = Usr.tbUser.UserId LEFT OUTER JOIN
                         Org.tbAddress ON Org.tbOrg.AddressCode = Org.tbAddress.AddressCode INNER JOIN
                         Invoice.tbTask AS tbInvoiceTask ON sales_invoice.InvoiceNumber = tbInvoiceTask.InvoiceNumber INNER JOIN
                         Task.tbTask ON tbInvoiceTask.TaskCode = Task.tbTask.TaskCode INNER JOIN
                         Activity.tbActivity ON Task.tbTask.ActivityCode = Activity.tbActivity.ActivityCode INNER JOIN
                         Invoice.tbType ON sales_invoice.InvoiceTypeCode = Invoice.tbType.InvoiceTypeCode
WHERE        (sales_invoice.InvoiceTypeCode = 0) AND EXISTS
                             (SELECT        UserName, DocTypeCode, DocumentNumber, SpooledOn, RowVer
                               FROM            App.tbDocSpool AS doc
                               WHERE        (DocTypeCode = 4) AND (UserName = SUSER_SNAME()) AND (sales_invoice.InvoiceNumber = DocumentNumber))

go
ALTER VIEW Invoice.vwSalesInvoiceSpoolByActivity
AS
WITH invoice AS 
(
	SELECT        sales_invoice.InvoiceNumber, Invoice.tbType.InvoiceType, sales_invoice.InvoiceStatusCode, Usr.tbUser.UserName, sales_invoice.AccountCode, Org.tbOrg.AccountName, 
							Invoice.tbStatus.InvoiceStatus, sales_invoice.InvoicedOn, sales_invoice.InvoiceValue AS InvoiceValueTotal, sales_invoice.TaxValue AS TaxValueTotal, sales_invoice.PaymentTerms, 
							Org.tbOrg.EmailAddress, Org.tbOrg.AddressCode, Activity.tbActivity.ActivityCode, Activity.tbActivity.UnitOfMeasure, MIN(Task.tbTask.ActionedOn) AS FirstActionedOn, 
							SUM(tbInvoiceTask.Quantity) AS ActivityQuantity, tbInvoiceTask.TaxCode, SUM(tbInvoiceTask.InvoiceValue) AS ActivityInvoiceValue, SUM(tbInvoiceTask.TaxValue) AS ActivityTaxValue
	FROM            Invoice.tbInvoice AS sales_invoice INNER JOIN
							Invoice.tbStatus ON sales_invoice.InvoiceStatusCode = Invoice.tbStatus.InvoiceStatusCode INNER JOIN
							Org.tbOrg ON sales_invoice.AccountCode = Org.tbOrg.AccountCode INNER JOIN
							Usr.tbUser ON sales_invoice.UserId = Usr.tbUser.UserId INNER JOIN
							Invoice.tbTask AS tbInvoiceTask ON sales_invoice.InvoiceNumber = tbInvoiceTask.InvoiceNumber INNER JOIN
							Task.tbTask ON tbInvoiceTask.TaskCode = Task.tbTask.TaskCode INNER JOIN
							Activity.tbActivity ON Task.tbTask.ActivityCode = Activity.tbActivity.ActivityCode INNER JOIN
							Invoice.tbType ON sales_invoice.InvoiceTypeCode = Invoice.tbType.InvoiceTypeCode
	WHERE        EXISTS
								(SELECT        UserName, DocTypeCode, DocumentNumber, SpooledOn
									FROM            App.tbDocSpool AS doc
									WHERE        (DocTypeCode = 4) AND (UserName = SUSER_SNAME()) AND (sales_invoice.InvoiceNumber = DocumentNumber))
	GROUP BY sales_invoice.InvoiceNumber, Invoice.tbType.InvoiceType, sales_invoice.InvoiceStatusCode, Usr.tbUser.UserName, sales_invoice.AccountCode, Org.tbOrg.AccountName, 
							Invoice.tbStatus.InvoiceStatus, sales_invoice.InvoicedOn, sales_invoice.InvoiceValue, sales_invoice.TaxValue, sales_invoice.PaymentTerms, Org.tbOrg.EmailAddress, Org.tbOrg.AddressCode, 
							Activity.tbActivity.ActivityCode, Activity.tbActivity.UnitOfMeasure, tbInvoiceTask.TaxCode
)
SELECT        invoice_1.InvoiceNumber, invoice_1.InvoiceType, invoice_1.InvoiceStatusCode, invoice_1.UserName, invoice_1.AccountCode, invoice_1.AccountName, invoice_1.InvoiceStatus, invoice_1.InvoicedOn, 
                        Invoice.tbInvoice.Notes, Org.tbAddress.Address AS InvoiceAddress, invoice_1.InvoiceValueTotal, invoice_1.TaxValueTotal, invoice_1.PaymentTerms, invoice_1.EmailAddress, invoice_1.AddressCode, 
                        invoice_1.ActivityCode, invoice_1.UnitOfMeasure, invoice_1.FirstActionedOn, invoice_1.ActivityQuantity, invoice_1.TaxCode, invoice_1.ActivityInvoiceValue, invoice_1.ActivityTaxValue
FROM            invoice AS invoice_1 INNER JOIN
                        Invoice.tbInvoice ON invoice_1.InvoiceNumber = Invoice.tbInvoice.InvoiceNumber LEFT OUTER JOIN
                        Org.tbAddress ON invoice_1.AddressCode = Org.tbAddress.AddressCode;

go
ALTER VIEW Invoice.vwSummary
AS
	WITH tasks AS
	(
		SELECT  (SELECT TOP (1) p.StartOn FROM App.tbYearPeriod p WHERE (p.StartOn <= Invoice.tbInvoice.InvoicedOn) ORDER BY p.StartOn DESC) AS StartOn,  
								 CASE WHEN Invoice.tbInvoice.InvoiceTypeCode = 1 THEN 0 ELSE CASE WHEN Invoice.tbInvoice.InvoiceTypeCode = 3 THEN 2 ELSE Invoice.tbInvoice.InvoiceTypeCode END END AS InvoiceTypeCode, 
								 CASE WHEN Invoice.tbType.CashModeCode = 0 THEN Invoice.tbTask.InvoiceValue * - 1 ELSE Invoice.tbTask.InvoiceValue END AS InvoiceValue, 
								 CASE WHEN Invoice.tbType.CashModeCode = 0 THEN Invoice.tbTask.TaxValue * - 1 ELSE Invoice.tbTask.TaxValue END AS TaxValue
		FROM            Invoice.tbTask INNER JOIN
								 Invoice.tbInvoice ON Invoice.tbTask.InvoiceNumber = Invoice.tbInvoice.InvoiceNumber INNER JOIN
								 Invoice.tbType ON Invoice.tbInvoice.InvoiceTypeCode = Invoice.tbType.InvoiceTypeCode
		WHERE        (Invoice.tbInvoice.InvoicedOn >= (	
						SELECT MIN( App.tbYearPeriod.StartOn) FROM App.tbYear 
						INNER JOIN App.tbYearPeriod ON App.tbYear.YearNumber = App.tbYearPeriod.YearNumber 
						WHERE ( App.tbYear.CashStatusCode < 3)))
	), items AS
	(
		SELECT  (SELECT TOP (1) p.StartOn FROM App.tbYearPeriod p WHERE (p.StartOn <= Invoice.tbInvoice.InvoicedOn) ORDER BY p.StartOn DESC) AS StartOn,  
								 CASE WHEN Invoice.tbInvoice.InvoiceTypeCode = 1 THEN 0 ELSE CASE WHEN Invoice.tbInvoice.InvoiceTypeCode = 3 THEN 2 ELSE Invoice.tbInvoice.InvoiceTypeCode END END AS InvoiceTypeCode, 
								 CASE WHEN Invoice.tbType.CashModeCode = 0 THEN Invoice.tbItem.InvoiceValue * - 1 ELSE Invoice.tbItem.InvoiceValue END AS InvoiceValue, 
								 CASE WHEN Invoice.tbType.CashModeCode = 0 THEN Invoice.tbItem.TaxValue * - 1 ELSE Invoice.tbItem.TaxValue END AS TaxValue
		FROM            Invoice.tbItem INNER JOIN
								 Invoice.tbInvoice ON Invoice.tbItem.InvoiceNumber = Invoice.tbInvoice.InvoiceNumber INNER JOIN
								 Invoice.tbType ON Invoice.tbInvoice.InvoiceTypeCode = Invoice.tbType.InvoiceTypeCode
		WHERE        (Invoice.tbInvoice.InvoicedOn >= (	
						SELECT MIN( App.tbYearPeriod.StartOn) FROM App.tbYear 
						INNER JOIN App.tbYearPeriod ON App.tbYear.YearNumber = App.tbYearPeriod.YearNumber 
						WHERE ( App.tbYear.CashStatusCode < 3)))
	), invoice_entries AS
	(
		SELECT     StartOn, InvoiceTypeCode, InvoiceValue, TaxValue
		FROM         items
		UNION
		SELECT     StartOn, InvoiceTypeCode, InvoiceValue, TaxValue
		FROM         tasks
	), invoice_totals AS
	(
		SELECT     invoice_entries.StartOn, invoice_entries.InvoiceTypeCode, Invoice.tbType.InvoiceType, 
							  SUM(invoice_entries.InvoiceValue) AS TotalInvoiceValue, SUM(invoice_entries.TaxValue) AS TotalTaxValue
		FROM         invoice_entries INNER JOIN
							  Invoice.tbType ON invoice_entries.InvoiceTypeCode = Invoice.tbType.InvoiceTypeCode
		GROUP BY invoice_entries.StartOn, invoice_entries.InvoiceTypeCode, Invoice.tbType.InvoiceType
	), invoice_margin AS
	(
		SELECT     StartOn, 4 AS InvoiceTypeCode, (SELECT CAST(Message AS NVARCHAR(10)) FROM App.tbText WHERE TextId = 3004) AS InvoiceType, SUM(TotalInvoiceValue) AS TotalInvoiceValue, SUM(TotalTaxValue) 
							  AS TotalTaxValue
		FROM         invoice_totals
		GROUP BY StartOn
	)
	SELECT     CONCAT(DATENAME(yyyy, StartOn), '/', FORMAT(MONTH(StartOn), '00')) AS PeriodOn, StartOn, InvoiceTypeCode, InvoiceType AS InvoiceType, 
						  ABS(TotalInvoiceValue) AS TotalInvoiceValue, ABS(TotalTaxValue) AS TotalTaxValue
	FROM         invoice_totals
	UNION
	SELECT     CONCAT(DATENAME(yyyy, StartOn), '/', FORMAT(MONTH(StartOn), '00')) AS PeriodOn, StartOn, InvoiceTypeCode, InvoiceType AS InvoiceType, 
						  TotalInvoiceValue, TotalTaxValue
	FROM         invoice_margin;

go
ALTER VIEW Invoice.vwTaxSummary
AS
	WITH base AS
	(
		SELECT        InvoiceNumber, TaxCode, SUM(InvoiceValue) AS InvoiceValueTotal, SUM(TaxValue) AS TaxValueTotal
		FROM            Invoice.tbItem
		GROUP BY InvoiceNumber, TaxCode
		HAVING        (NOT (TaxCode IS NULL))
		UNION
		SELECT        InvoiceNumber, TaxCode, SUM(InvoiceValue) AS InvoiceValueTotal, SUM(TaxValue) AS TaxValueTotal
		FROM            Invoice.tbTask
		GROUP BY InvoiceNumber, TaxCode
		HAVING        (NOT (TaxCode IS NULL))
	)
	SELECT        InvoiceNumber, TaxCode, CAST(SUM(InvoiceValueTotal) as decimal(18, 5)) AS InvoiceValueTotal, CAST(SUM(TaxValueTotal) as decimal(18, 5)) AS TaxValueTotal, 
	 CASE WHEN SUM(InvoiceValueTotal) <> 0 THEN CAST((SUM(TaxValueTotal) / SUM(InvoiceValueTotal)) as decimal(18, 5)) ELSE 0 END AS TaxRate
	FROM            base
	GROUP BY InvoiceNumber, TaxCode;

go
ALTER VIEW Org.vwBalanceOutstanding
AS
	WITH invoices_unpaid AS
	(
		SELECT        Invoice.tbInvoice.AccountCode, 
			CASE Invoice.tbType.CashModeCode 
				WHEN 0 THEN ((InvoiceValue + TaxValue) - (PaidValue + PaidTaxValue)) * - 1 
				WHEN 1 THEN (InvoiceValue + TaxValue) - (PaidValue + PaidTaxValue) END AS OutstandingValue
		FROM            Invoice.tbInvoice INNER JOIN
								 Invoice.tbType ON Invoice.tbInvoice.InvoiceTypeCode = Invoice.tbType.InvoiceTypeCode
		WHERE        (Invoice.tbInvoice.InvoiceStatusCode > 0) AND (Invoice.tbInvoice.InvoiceStatusCode < 3) 
	), current_balance AS
	(
		SELECT AccountCode, SUM(OutstandingValue) AS Balance
		FROM   invoices_unpaid	
		GROUP BY AccountCode
	)
	SELECT org.AccountCode, ISNULL(current_balance.Balance, 0) AS Balance
	FROM Org.tbOrg org 
		LEFT OUTER JOIN current_balance ON org.AccountCode = current_balance.AccountCode;
go
ALTER VIEW Org.vwCashAccounts
AS
SELECT        Org.tbAccount.CashAccountCode, Org.tbAccount.CashAccountName, Org.tbOrg.AccountName, Org.tbType.OrganisationType, Org.tbAccount.OpeningBalance, Org.tbAccount.CurrentBalance, Org.tbAccount.SortCode, 
                         Org.tbAccount.AccountNumber, Org.tbAccount.AccountClosed, Org.tbAccount.RowVer
FROM            Org.tbOrg INNER JOIN
                         Org.tbAccount ON Org.tbOrg.AccountCode = Org.tbAccount.AccountCode INNER JOIN
                         Org.tbType ON Org.tbOrg.OrganisationTypeCode = Org.tbType.OrganisationTypeCode;

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
ALTER VIEW Org.vwInvoiceItems
AS
SELECT        Invoice.tbInvoice.AccountCode, Invoice.tbItem.InvoiceNumber, Invoice.tbItem.CashCode, Invoice.tbInvoice.InvoicedOn, Invoice.tbInvoice.InvoiceTypeCode, Invoice.tbStatus.InvoiceStatus, 
                         Cash.tbCode.CashDescription, Org.tbOrg.AccountName, Invoice.tbInvoice.InvoiceStatusCode, Invoice.tbType.InvoiceType, Invoice.tbItem.TaxCode, Invoice.tbItem.TaxValue, 
                         Invoice.tbItem.InvoiceValue, Invoice.tbItem.PaidValue, Invoice.tbItem.PaidTaxValue, Invoice.tbItem.ItemReference
FROM            Invoice.tbInvoice INNER JOIN
                         Invoice.tbStatus ON Invoice.tbInvoice.InvoiceStatusCode = Invoice.tbStatus.InvoiceStatusCode INNER JOIN
                         Org.tbOrg ON Invoice.tbInvoice.AccountCode = Org.tbOrg.AccountCode INNER JOIN
                         Invoice.tbType ON Invoice.tbInvoice.InvoiceTypeCode = Invoice.tbType.InvoiceTypeCode INNER JOIN
                         Invoice.tbItem ON Invoice.tbInvoice.InvoiceNumber = Invoice.tbItem.InvoiceNumber INNER JOIN
                         Cash.tbCode ON Invoice.tbItem.CashCode = Cash.tbCode.CashCode
WHERE        (Invoice.tbInvoice.InvoiceStatusCode > 0);

go
ALTER VIEW Org.vwInvoiceSummary
AS
	WITH ois AS
	(
		SELECT        AccountCode, StartOn, SUM(InvoiceValue) AS PeriodValue
		FROM            Invoice.vwRegister
		GROUP BY AccountCode, StartOn
	), acc AS
	(
		SELECT Org.tbOrg.AccountCode, App.vwPeriods.StartOn
		FROM Org.tbOrg CROSS JOIN App.vwPeriods
	)
	SELECT TOP (100) PERCENT acc.AccountCode, acc.StartOn, ois.PeriodValue 
	FROM ois RIGHT OUTER JOIN acc ON ois.AccountCode = acc.AccountCode AND ois.StartOn = acc.StartOn
	ORDER BY acc.AccountCode, acc.StartOn;

go
ALTER VIEW Org.vwPurchaseInvoices
AS
SELECT        Invoice.tbInvoice.AccountCode, tbInvoiceTask.InvoiceNumber, tbInvoiceTask.TaskCode, Task.tbTask.ContactName, Invoice.tbInvoice.InvoicedOn, tbInvoiceTask.Quantity, tbInvoiceTask.InvoiceValue, 
                         tbInvoiceTask.TaxValue, tbInvoiceTask.CashCode, tbInvoiceTask.TaxCode, Invoice.tbStatus.InvoiceStatus, Task.tbTask.TaskNotes, Cash.tbCode.CashDescription, Invoice.tbInvoice.InvoiceStatusCode, 
                         Task.tbTask.TaskTitle, Org.tbOrg.AccountName, Invoice.tbInvoice.InvoiceTypeCode, Invoice.tbType.InvoiceType
FROM            Invoice.tbInvoice INNER JOIN
                         Invoice.tbTask AS tbInvoiceTask ON Invoice.tbInvoice.InvoiceNumber = tbInvoiceTask.InvoiceNumber INNER JOIN
                         Task.tbTask ON tbInvoiceTask.TaskCode = Task.tbTask.TaskCode INNER JOIN
                         Cash.tbCode ON tbInvoiceTask.CashCode = Cash.tbCode.CashCode INNER JOIN
                         Invoice.tbStatus ON Invoice.tbInvoice.InvoiceStatusCode = Invoice.tbStatus.InvoiceStatusCode INNER JOIN
                         Org.tbOrg ON Invoice.tbInvoice.AccountCode = Org.tbOrg.AccountCode INNER JOIN
                         Invoice.tbType ON Invoice.tbInvoice.InvoiceTypeCode = Invoice.tbType.InvoiceTypeCode
WHERE        (Invoice.tbInvoice.InvoiceStatusCode > 0) AND (Invoice.tbInvoice.InvoiceTypeCode > 1);

go
ALTER VIEW Org.vwSalesInvoices
AS
SELECT        Invoice.tbInvoice.AccountCode, tbInvoiceTask.InvoiceNumber, tbInvoiceTask.TaskCode, Task.tbTask.ContactName, Invoice.tbInvoice.InvoicedOn, tbInvoiceTask.Quantity, tbInvoiceTask.InvoiceValue, 
                         tbInvoiceTask.TaxValue, tbInvoiceTask.CashCode, tbInvoiceTask.TaxCode, Invoice.tbStatus.InvoiceStatus, Task.tbTask.TaskNotes, Cash.tbCode.CashDescription, Invoice.tbInvoice.InvoiceStatusCode, 
                         Task.tbTask.TaskTitle, Org.tbOrg.AccountName, Invoice.tbInvoice.InvoiceTypeCode, Invoice.tbType.InvoiceType, tbInvoiceTask.PaidValue, tbInvoiceTask.PaidTaxValue
FROM            Invoice.tbInvoice INNER JOIN
                         Invoice.tbTask AS tbInvoiceTask ON Invoice.tbInvoice.InvoiceNumber = tbInvoiceTask.InvoiceNumber INNER JOIN
                         Task.tbTask ON tbInvoiceTask.TaskCode = Task.tbTask.TaskCode INNER JOIN
                         Cash.tbCode ON tbInvoiceTask.CashCode = Cash.tbCode.CashCode INNER JOIN
                         Invoice.tbStatus ON Invoice.tbInvoice.InvoiceStatusCode = Invoice.tbStatus.InvoiceStatusCode INNER JOIN
                         Org.tbOrg ON Invoice.tbInvoice.AccountCode = Org.tbOrg.AccountCode INNER JOIN
                         Invoice.tbType ON Invoice.tbInvoice.InvoiceTypeCode = Invoice.tbType.InvoiceTypeCode
WHERE        (Invoice.tbInvoice.InvoiceStatusCode > 0) AND (Invoice.tbInvoice.InvoiceTypeCode = 0);

go
ALTER VIEW Org.vwPurchases
AS
SELECT        AccountCode, TaskCode, UserId, ContactName, ActivityCode, TaskTitle, TaskStatusCode, ActionById, ActionOn, ActionedOn, PaymentOn, SecondReference, TaskNotes, TaxCode, Quantity, UnitCharge, TotalCharge, 
                         AddressCodeFrom, AddressCodeTo, Printed, Spooled, InsertedBy, InsertedOn, UpdatedBy, UpdatedOn, Period, BucketId, TaskStatus, CashCode, CashDescription, OwnerName, ActionName, AccountName, 
                         OrganisationStatus, OrganisationType, CashModeCode
FROM            Task.vwTasks
WHERE        (CashModeCode = 0) AND (CashCode IS NOT NULL);

go
ALTER VIEW Org.vwSales
AS
SELECT        AccountCode, TaskCode, UserId, ContactName, ActivityCode, TaskTitle, TaskStatusCode, ActionById, ActionOn, ActionedOn, PaymentOn, SecondReference, TaskNotes, TaxCode, Quantity, UnitCharge, TotalCharge, 
                         AddressCodeFrom, AddressCodeTo, Printed, Spooled, InsertedBy, InsertedOn, UpdatedBy, UpdatedOn, Period, BucketId, TaskStatus, CashCode, CashDescription, OwnerName, ActionName, AccountName, 
                         OrganisationStatus, OrganisationType, CashModeCode
FROM            Task.vwTasks
WHERE        (CashModeCode = 1) AND (CashCode IS NOT NULL);

go
ALTER VIEW Task.vwActiveData
AS
SELECT        TaskCode, UserId, AccountCode, ContactName, ActivityCode, TaskTitle, TaskStatusCode, ActionById, ActionOn, ActionedOn, PaymentOn, SecondReference, TaskNotes, TaxCode, Quantity, UnitCharge, TotalCharge, 
                         AddressCodeFrom, AddressCodeTo, Printed, Spooled, InsertedBy, InsertedOn, UpdatedBy, UpdatedOn, Period, BucketId, TaskStatus, CashCode, CashDescription, OwnerName, ActionName, AccountName, 
                         OrganisationStatus, OrganisationType, CashModeCode
FROM            Task.vwTasks
WHERE        (TaskStatusCode = 1);

go
ALTER VIEW Task.vwDoc
AS
SELECT     Task.fnEmailAddress(Task.tbTask.TaskCode) AS EmailAddress, Task.tbTask.TaskCode, Task.tbTask.TaskStatusCode, Task.tbStatus.TaskStatus, 
                      Task.tbTask.ContactName, Org.tbContact.NickName, Usr.tbUser.UserName, Org.tbOrg.AccountName, Org.tbAddress.Address AS InvoiceAddress, 
                      Org_tb1.AccountName AS DeliveryAccountName, Org_tbAddress1.Address AS DeliveryAddress, Org_tb2.AccountName AS CollectionAccountName, 
                      Org_tbAddress2.Address AS CollectionAddress, Task.tbTask.AccountCode, Task.tbTask.TaskNotes, Task.tbTask.ActivityCode, Task.tbTask.ActionOn, 
                      Activity.tbActivity.UnitOfMeasure, Task.tbTask.Quantity, App.tbTaxCode.TaxCode, App.tbTaxCode.TaxRate, Task.tbTask.UnitCharge, Task.tbTask.TotalCharge, 
                      Usr.tbUser.MobileNumber, Usr.tbUser.Signature, Task.tbTask.TaskTitle, Task.tbTask.PaymentOn, Task.tbTask.SecondReference, Org.tbOrg.PaymentTerms
FROM         Org.tbOrg AS Org_tb2 RIGHT OUTER JOIN
                      Org.tbAddress AS Org_tbAddress2 ON Org_tb2.AccountCode = Org_tbAddress2.AccountCode RIGHT OUTER JOIN
                      Task.tbStatus INNER JOIN
                      Usr.tbUser INNER JOIN
                      Activity.tbActivity INNER JOIN
                      Task.tbTask ON Activity.tbActivity.ActivityCode = Task.tbTask.ActivityCode INNER JOIN
                      Org.tbOrg ON Task.tbTask.AccountCode = Org.tbOrg.AccountCode LEFT OUTER JOIN
                      Org.tbAddress ON Org.tbOrg.AddressCode = Org.tbAddress.AddressCode ON Usr.tbUser.UserId = Task.tbTask.ActionById ON 
                      Task.tbStatus.TaskStatusCode = Task.tbTask.TaskStatusCode LEFT OUTER JOIN
                      Org.tbAddress AS Org_tbAddress1 LEFT OUTER JOIN
                      Org.tbOrg AS Org_tb1 ON Org_tbAddress1.AccountCode = Org_tb1.AccountCode ON Task.tbTask.AddressCodeTo = Org_tbAddress1.AddressCode ON 
                      Org_tbAddress2.AddressCode = Task.tbTask.AddressCodeFrom LEFT OUTER JOIN
                      Org.tbContact ON Task.tbTask.ContactName = Org.tbContact.ContactName AND Task.tbTask.AccountCode = Org.tbContact.AccountCode LEFT OUTER JOIN
                      App.tbTaxCode ON Task.tbTask.TaxCode = App.tbTaxCode.TaxCode

go
ALTER VIEW Task.vwEdit
AS
SELECT        Task.tbTask.TaskCode, Task.tbTask.UserId, Task.tbTask.AccountCode, Task.tbTask.TaskTitle, Task.tbTask.ContactName, Task.tbTask.ActivityCode, Task.tbTask.TaskStatusCode, Task.tbTask.ActionById, 
                         Task.tbTask.ActionOn, Task.tbTask.ActionedOn, Task.tbTask.TaskNotes, Task.tbTask.Quantity, Task.tbTask.CashCode, Task.tbTask.TaxCode, Task.tbTask.UnitCharge, Task.tbTask.TotalCharge, 
                         Task.tbTask.AddressCodeFrom, Task.tbTask.AddressCodeTo, Task.tbTask.Printed, Task.tbTask.InsertedBy, Task.tbTask.InsertedOn, Task.tbTask.UpdatedBy, Task.tbTask.UpdatedOn, Task.tbTask.PaymentOn, 
                         Task.tbTask.SecondReference, Task.tbTask.Spooled, Activity.tbActivity.UnitOfMeasure, Task.tbStatus.TaskStatus
FROM            Task.tbTask INNER JOIN
                         Activity.tbActivity ON Task.tbTask.ActivityCode = Activity.tbActivity.ActivityCode INNER JOIN
                         Task.tbStatus ON Task.tbTask.TaskStatusCode = Task.tbStatus.TaskStatusCode;
go
ALTER VIEW Task.vwFlow
AS
SELECT        Task.tbFlow.ParentTaskCode, Task.tbFlow.StepNumber, Task.tbTask.TaskCode, Task.tbTask.ActivityCode, Task.tbTask.TaskTitle, Task.tbTask.TaskNotes, Task.tbStatus.TaskStatus, Task.tbTask.ActionOn, 
                         Task.tbTask.Quantity, Task.tbTask.ActionedOn, Org.tbOrg.AccountCode, Usr.tbUser.UserName AS Owner, tbUser_1.UserName AS ActionBy, Org.tbOrg.AccountName, Task.tbTask.UnitCharge, 
                         Task.tbTask.TotalCharge, Task.tbTask.InsertedBy, Task.tbTask.InsertedOn, Task.tbTask.UpdatedBy, Task.tbTask.UpdatedOn, Task.tbTask.TaskStatusCode
FROM            Usr.tbUser AS tbUser_1 INNER JOIN
                         Task.tbTask INNER JOIN
                         Task.tbStatus ON Task.tbTask.TaskStatusCode = Task.tbStatus.TaskStatusCode INNER JOIN
                         Usr.tbUser ON Task.tbTask.UserId = Usr.tbUser.UserId INNER JOIN
                         Org.tbOrg ON Task.tbTask.AccountCode = Org.tbOrg.AccountCode ON tbUser_1.UserId = Task.tbTask.ActionById INNER JOIN
                         Task.tbFlow ON Task.tbTask.TaskCode = Task.tbFlow.ChildTaskCode;
go
ALTER VIEW Task.vwOps
AS
SELECT        Task.tbOp.TaskCode, Task.tbTask.ActivityCode, Task.tbOp.OperationNumber, Task.vwOpBucket.Period, Task.vwOpBucket.BucketId, Task.tbOp.UserId, Task.tbOp.SyncTypeCode, Task.tbOp.OpStatusCode, 
                         Task.tbOp.Operation, Task.tbOp.Note, Task.tbOp.StartOn, Task.tbOp.EndOn, Task.tbOp.Duration, Task.tbOp.OffsetDays, Task.tbOp.InsertedBy, Task.tbOp.InsertedOn, Task.tbOp.UpdatedBy, Task.tbOp.UpdatedOn, 
                         Task.tbTask.TaskTitle, Task.tbTask.TaskStatusCode, Task.tbStatus.TaskStatus, Task.tbTask.ActionOn, Task.tbTask.Quantity, Cash.tbCode.CashDescription, Task.tbTask.TotalCharge, Task.tbTask.AccountCode, 
                         Org.tbOrg.AccountName, Task.tbOp.RowVer AS OpRowVer, Task.tbTask.RowVer AS TaskRowVer
FROM            Task.tbOp INNER JOIN
                         Task.tbTask ON Task.tbOp.TaskCode = Task.tbTask.TaskCode INNER JOIN
                         Org.tbOrg ON Task.tbTask.AccountCode = Org.tbOrg.AccountCode INNER JOIN
                         Task.tbStatus ON Task.tbTask.TaskStatusCode = Task.tbStatus.TaskStatusCode INNER JOIN
                         Task.vwOpBucket ON Task.tbOp.TaskCode = Task.vwOpBucket.TaskCode AND Task.tbOp.OperationNumber = Task.vwOpBucket.OperationNumber LEFT OUTER JOIN
                         Cash.tbCode ON Task.tbTask.CashCode = Cash.tbCode.CashCode

go
ALTER VIEW Task.vwOrgActivity
AS
SELECT AccountCode, TaskStatusCode, ActionOn, TaskTitle, ActivityCode, ActionById, TaskCode, Period, BucketId, ContactName, TaskStatus, TaskNotes, ActionedOn, OwnerName, CashCode, CashDescription, Quantity, 
                         UnitCharge, TotalCharge, AddressCodeFrom, AddressCodeTo, Printed, InsertedBy, InsertedOn, UpdatedBy, UpdatedOn, AccountName, ActionName
FROM            Task.vwTasks
WHERE        (TaskStatusCode < 2);
go
ALTER VIEW Task.vwPurchaseEnquiryDeliverySpool
AS
SELECT        purchase_enquiry.TaskCode, purchase_enquiry.ContactName, Org.tbContact.NickName, Usr.tbUser.UserName, Org.tbOrg.AccountName, Org.tbAddress.Address AS InvoiceAddress, 
                         collection_account.AccountName AS CollectAccount, collection_address.Address AS CollectAddress, delivery_account.AccountName AS DeliveryAccount, delivery_address.Address AS DeliveryAddress, 
                         purchase_enquiry.AccountCode, purchase_enquiry.TaskNotes, purchase_enquiry.ActivityCode, purchase_enquiry.ActionOn, Activity.tbActivity.UnitOfMeasure, purchase_enquiry.Quantity, App.tbTaxCode.TaxCode, 
                         App.tbTaxCode.TaxRate, purchase_enquiry.UnitCharge, purchase_enquiry.TotalCharge, Usr.tbUser.MobileNumber, Usr.tbUser.Signature, purchase_enquiry.TaskTitle
FROM            Org.tbOrg AS delivery_account INNER JOIN
                         Org.tbOrg AS collection_account INNER JOIN
                         Usr.tbUser INNER JOIN
                         Activity.tbActivity INNER JOIN
                         Task.tbTask AS purchase_enquiry ON Activity.tbActivity.ActivityCode = purchase_enquiry.ActivityCode INNER JOIN
                         Org.tbOrg ON purchase_enquiry.AccountCode = Org.tbOrg.AccountCode LEFT OUTER JOIN
                         Org.tbAddress ON Org.tbOrg.AddressCode = Org.tbAddress.AddressCode ON Usr.tbUser.UserId = purchase_enquiry.ActionById INNER JOIN
                         Org.tbAddress AS delivery_address ON purchase_enquiry.AddressCodeTo = delivery_address.AddressCode LEFT OUTER JOIN
                         App.tbTaxCode ON purchase_enquiry.TaxCode = App.tbTaxCode.TaxCode LEFT OUTER JOIN
                         Org.tbContact ON purchase_enquiry.ContactName = Org.tbContact.ContactName AND purchase_enquiry.AccountCode = Org.tbContact.AccountCode INNER JOIN
                         Org.tbAddress AS collection_address ON purchase_enquiry.AddressCodeFrom = collection_address.AddressCode ON collection_account.AccountCode = collection_address.AccountCode ON 
                         delivery_account.AccountCode = delivery_address.AccountCode
WHERE EXISTS (SELECT * FROM App.tbDocSpool AS doc WHERE DocTypeCode = 2 AND UserName = SUSER_SNAME() AND purchase_enquiry.TaskCode = doc.DocumentNumber);

go
ALTER VIEW Task.vwPurchaseEnquirySpool
AS
SELECT        purchase_enquiry.TaskCode, purchase_enquiry.ContactName, Org.tbContact.NickName, Usr.tbUser.UserName, Org.tbOrg.AccountName, Org.tbAddress.Address AS InvoiceAddress, 
                         Org_tbAddress_1.Address AS DeliveryAddress, purchase_enquiry.AccountCode, purchase_enquiry.TaskNotes, purchase_enquiry.ActivityCode, purchase_enquiry.ActionOn, Activity.tbActivity.UnitOfMeasure, 
                         purchase_enquiry.Quantity, App.tbTaxCode.TaxCode, App.tbTaxCode.TaxRate, purchase_enquiry.UnitCharge, purchase_enquiry.TotalCharge, Usr.tbUser.MobileNumber, Usr.tbUser.Signature, 
                         purchase_enquiry.TaskTitle
FROM            Usr.tbUser INNER JOIN
                         Activity.tbActivity INNER JOIN
                         Task.tbTask AS purchase_enquiry ON Activity.tbActivity.ActivityCode = purchase_enquiry.ActivityCode INNER JOIN
                         Org.tbOrg ON purchase_enquiry.AccountCode = Org.tbOrg.AccountCode LEFT OUTER JOIN
                         Org.tbAddress ON Org.tbOrg.AddressCode = Org.tbAddress.AddressCode ON Usr.tbUser.UserId = purchase_enquiry.ActionById LEFT OUTER JOIN
                         Org.tbAddress AS Org_tbAddress_1 ON purchase_enquiry.AddressCodeTo = Org_tbAddress_1.AddressCode LEFT OUTER JOIN
                         App.tbTaxCode ON purchase_enquiry.TaxCode = App.tbTaxCode.TaxCode LEFT OUTER JOIN
                         Org.tbContact ON purchase_enquiry.AccountCode = Org.tbContact.AccountCode AND purchase_enquiry.ContactName = Org.tbContact.ContactName
WHERE EXISTS (SELECT * FROM App.tbDocSpool AS doc WHERE DocTypeCode = 2 AND UserName = SUSER_SNAME() AND purchase_enquiry.TaskCode = doc.DocumentNumber);

go
ALTER VIEW Task.vwPurchaseOrderDeliverySpool
AS
SELECT        purchase_order.TaskCode, purchase_order.ContactName, Org.tbContact.NickName, Usr.tbUser.UserName, Org.tbOrg.AccountName, invoice_address.Address AS InvoiceAddress, 
                         delivery_account.AccountName AS CollectAccount, delivery_address.Address AS CollectAddress, collection_account.AccountName AS DeliveryAccount, collection_address.Address AS DeliveryAddress, 
                         purchase_order.AccountCode, purchase_order.TaskNotes, purchase_order.ActivityCode, purchase_order.ActionOn, Activity.tbActivity.UnitOfMeasure, purchase_order.Quantity, App.tbTaxCode.TaxCode, 
                         App.tbTaxCode.TaxRate, purchase_order.UnitCharge, purchase_order.TotalCharge, Usr.tbUser.MobileNumber, Usr.tbUser.Signature, purchase_order.TaskTitle
FROM            Org.tbOrg AS collection_account INNER JOIN
                         Org.tbOrg AS delivery_account INNER JOIN
                         Usr.tbUser INNER JOIN
                         Activity.tbActivity INNER JOIN
                         Task.tbTask AS purchase_order ON Activity.tbActivity.ActivityCode = purchase_order.ActivityCode INNER JOIN
                         Org.tbOrg ON purchase_order.AccountCode = Org.tbOrg.AccountCode LEFT OUTER JOIN
                         Org.tbAddress AS invoice_address ON Org.tbOrg.AddressCode = invoice_address.AddressCode ON Usr.tbUser.UserId = purchase_order.ActionById INNER JOIN
                         Org.tbAddress AS collection_address ON purchase_order.AddressCodeTo = collection_address.AddressCode LEFT OUTER JOIN
                         App.tbTaxCode ON purchase_order.TaxCode = App.tbTaxCode.TaxCode LEFT OUTER JOIN
                         Org.tbContact ON purchase_order.ContactName = Org.tbContact.ContactName AND purchase_order.AccountCode = Org.tbContact.AccountCode INNER JOIN
                         Org.tbAddress AS delivery_address ON purchase_order.AddressCodeFrom = delivery_address.AddressCode ON delivery_account.AccountCode = delivery_address.AccountCode ON 
                         collection_account.AccountCode = collection_address.AccountCode
WHERE EXISTS (
	SELECT        UserName, DocTypeCode, DocumentNumber, SpooledOn
    FROM            App.tbDocSpool AS doc
    WHERE        (DocTypeCode = 3) AND (UserName = SUSER_SNAME()) AND (purchase_order.TaskCode = DocumentNumber));

go
ALTER VIEW Task.vwPurchaseOrderSpool
AS
SELECT        purchase_order.TaskCode, purchase_order.ContactName, Org.tbContact.NickName, Usr.tbUser.UserName, Org.tbOrg.AccountName, invoice_address.Address AS InvoiceAddress, 
                         delivery_address.Address AS DeliveryAddress, purchase_order.AccountCode, purchase_order.TaskNotes, purchase_order.ActivityCode, purchase_order.ActionOn, Activity.tbActivity.UnitOfMeasure, 
                         purchase_order.Quantity, App.tbTaxCode.TaxCode, App.tbTaxCode.TaxRate, purchase_order.UnitCharge, purchase_order.TotalCharge, Usr.tbUser.MobileNumber, Usr.tbUser.Signature, 
                         purchase_order.TaskTitle
FROM            Usr.tbUser INNER JOIN
                         Activity.tbActivity INNER JOIN
                         Task.tbTask AS purchase_order ON Activity.tbActivity.ActivityCode = purchase_order.ActivityCode INNER JOIN
                         Org.tbOrg ON purchase_order.AccountCode = Org.tbOrg.AccountCode LEFT OUTER JOIN
                         Org.tbAddress AS invoice_address ON Org.tbOrg.AddressCode = invoice_address.AddressCode ON Usr.tbUser.UserId = purchase_order.ActionById LEFT OUTER JOIN
                         Org.tbAddress AS delivery_address ON purchase_order.AddressCodeTo = delivery_address.AddressCode LEFT OUTER JOIN
                         App.tbTaxCode ON purchase_order.TaxCode = App.tbTaxCode.TaxCode LEFT OUTER JOIN
                         Org.tbContact ON purchase_order.AccountCode = Org.tbContact.AccountCode AND purchase_order.ContactName = Org.tbContact.ContactName
WHERE EXISTS (SELECT * FROM App.tbDocSpool AS doc WHERE DocTypeCode = 3 AND UserName = SUSER_SNAME() AND purchase_order.TaskCode = doc.DocumentNumber);

go
ALTER VIEW Task.vwPurchases
AS
SELECT        Task.vwTasks.TaskCode, Task.vwTasks.ActivityCode, Task.vwTasks.TaskStatusCode, Task.vwTasks.ActionOn, Task.vwTasks.ActionById, Task.vwTasks.TaskTitle, Task.vwTasks.Period, Task.vwTasks.BucketId, 
                         Task.vwTasks.AccountCode, Task.vwTasks.ContactName, Task.vwTasks.TaskStatus, Task.vwTasks.TaskNotes, Task.vwTasks.ActionedOn, Task.vwTasks.OwnerName, Task.vwTasks.CashCode, 
                         Task.vwTasks.CashDescription, Task.vwTasks.Quantity, Activity.tbActivity.UnitOfMeasure, Task.vwTasks.UnitCharge, Task.vwTasks.TotalCharge, Org_tbAddress_1.Address AS FromAddress, 
                         Org.tbAddress.Address AS ToAddress, Task.vwTasks.Printed, Task.vwTasks.InsertedBy, Task.vwTasks.InsertedOn, Task.vwTasks.UpdatedBy, Task.vwTasks.UpdatedOn, Task.vwTasks.AccountName, 
                         Task.vwTasks.ActionName, Task.vwTasks.SecondReference
FROM            Task.vwTasks LEFT OUTER JOIN
                         Org.tbAddress AS Org_tbAddress_1 ON Task.vwTasks.AddressCodeFrom = Org_tbAddress_1.AddressCode LEFT OUTER JOIN
                         Org.tbAddress ON Task.vwTasks.AddressCodeTo = Org.tbAddress.AddressCode INNER JOIN
                         Activity.tbActivity ON Task.vwTasks.ActivityCode = Activity.tbActivity.ActivityCode
WHERE        (Task.vwTasks.CashCode IS NOT NULL) AND (Task.vwTasks.CashModeCode = 0);

go
ALTER VIEW Task.vwQuotationSpool
AS
SELECT        sales_order.TaskCode, sales_order.ContactName, Org.tbContact.NickName, Usr.tbUser.UserName, Org.tbOrg.AccountName, invoice_address.Address AS InvoiceAddress, 
                         delivery_address.Address AS DeliveryAddress, sales_order.AccountCode, sales_order.TaskNotes, sales_order.ActivityCode, sales_order.ActionOn, Activity.tbActivity.UnitOfMeasure, sales_order.Quantity, 
                         App.tbTaxCode.TaxCode, App.tbTaxCode.TaxRate, sales_order.UnitCharge, sales_order.TotalCharge, Usr.tbUser.MobileNumber, Usr.tbUser.Signature, sales_order.TaskTitle
FROM            Usr.tbUser INNER JOIN
                         Activity.tbActivity INNER JOIN
                         Task.tbTask AS sales_order ON Activity.tbActivity.ActivityCode = sales_order.ActivityCode INNER JOIN
                         Org.tbOrg ON sales_order.AccountCode = Org.tbOrg.AccountCode LEFT OUTER JOIN
                         Org.tbAddress AS invoice_address ON Org.tbOrg.AddressCode = invoice_address.AddressCode ON Usr.tbUser.UserId = sales_order.ActionById LEFT OUTER JOIN
                         Org.tbAddress AS delivery_address ON sales_order.AddressCodeTo = delivery_address.AddressCode LEFT OUTER JOIN
                         App.tbTaxCode ON sales_order.TaxCode = App.tbTaxCode.TaxCode LEFT OUTER JOIN
                         Org.tbContact ON sales_order.AccountCode = Org.tbContact.AccountCode AND sales_order.ContactName = Org.tbContact.ContactName
WHERE EXISTS (
	SELECT        UserName, DocTypeCode, DocumentNumber, SpooledOn
    FROM            App.tbDocSpool AS doc
    WHERE        (DocTypeCode = 0) AND (UserName = SUSER_SNAME()) AND (sales_order.TaskCode = DocumentNumber));

go
ALTER VIEW Task.vwSalesOrderSpool
AS
SELECT        sales_order.TaskCode, sales_order.ContactName, Org.tbContact.NickName, Usr.tbUser.UserName, Org.tbOrg.AccountName, invoice_address.Address AS InvoiceAddress, 
                         delivery_address.Address AS DeliveryAddress, sales_order.AccountCode, sales_order.TaskNotes, sales_order.TaskTitle, sales_order.ActivityCode, sales_order.ActionOn, Activity.tbActivity.UnitOfMeasure, 
                         sales_order.Quantity, App.tbTaxCode.TaxCode, App.tbTaxCode.TaxRate, sales_order.UnitCharge, sales_order.TotalCharge, Usr.tbUser.MobileNumber, Usr.tbUser.Signature
FROM            Usr.tbUser INNER JOIN
                         Activity.tbActivity INNER JOIN
                         Task.tbTask AS sales_order ON Activity.tbActivity.ActivityCode = sales_order.ActivityCode INNER JOIN
                         Org.tbOrg ON sales_order.AccountCode = Org.tbOrg.AccountCode LEFT OUTER JOIN
                         Org.tbAddress AS invoice_address ON Org.tbOrg.AddressCode = invoice_address.AddressCode ON Usr.tbUser.UserId = sales_order.ActionById LEFT OUTER JOIN
                         Org.tbAddress AS delivery_address ON sales_order.AddressCodeTo = delivery_address.AddressCode LEFT OUTER JOIN
                         App.tbTaxCode ON sales_order.TaxCode = App.tbTaxCode.TaxCode LEFT OUTER JOIN
                         Org.tbContact ON sales_order.AccountCode = Org.tbContact.AccountCode AND sales_order.ContactName = Org.tbContact.ContactName
WHERE EXISTS (
	SELECT        UserName, DocTypeCode, DocumentNumber, SpooledOn
    FROM            App.tbDocSpool AS doc
    WHERE        (DocTypeCode = 1) AND (UserName = SUSER_SNAME()) AND (sales_order.TaskCode = DocumentNumber));

go
ALTER VIEW Task.vwSales
AS
SELECT        Task.vwTasks.TaskCode, Task.vwTasks.ActivityCode, Task.vwTasks.TaskStatusCode, Task.vwTasks.ActionOn, Task.vwTasks.ActionById, Task.vwTasks.TaskTitle, Task.vwTasks.Period, Task.vwTasks.BucketId, 
                         Task.vwTasks.AccountCode, Task.vwTasks.ContactName, Task.vwTasks.TaskStatus, Task.vwTasks.TaskNotes, Task.vwTasks.ActionedOn, Task.vwTasks.OwnerName, Task.vwTasks.CashCode, 
                         Task.vwTasks.CashDescription, Task.vwTasks.Quantity, Activity.tbActivity.UnitOfMeasure, Task.vwTasks.UnitCharge, Task.vwTasks.TotalCharge, Org_tbAddress_1.Address AS FromAddress, 
                         Org.tbAddress.Address AS ToAddress, Task.vwTasks.Printed, Task.vwTasks.InsertedBy, Task.vwTasks.InsertedOn, Task.vwTasks.UpdatedBy, Task.vwTasks.UpdatedOn, Task.vwTasks.AccountName, 
                         Task.vwTasks.ActionName, Task.vwTasks.SecondReference
FROM            Task.vwTasks LEFT OUTER JOIN
                         Org.tbAddress AS Org_tbAddress_1 ON Task.vwTasks.AddressCodeFrom = Org_tbAddress_1.AddressCode LEFT OUTER JOIN
                         Org.tbAddress ON Task.vwTasks.AddressCodeTo = Org.tbAddress.AddressCode INNER JOIN
                         Activity.tbActivity ON Task.vwTasks.ActivityCode = Activity.tbActivity.ActivityCode
WHERE        (Task.vwTasks.CashCode IS NOT NULL) AND (Task.vwTasks.CashModeCode = 1);

go
ALTER VIEW Task.vwTasks
AS
SELECT        Task.tbTask.TaskCode, Task.tbTask.UserId, Task.tbTask.AccountCode, Task.tbTask.ContactName, Task.tbTask.ActivityCode, Task.tbTask.TaskTitle, Task.tbTask.TaskStatusCode, Task.tbTask.ActionById, 
                         Task.tbTask.ActionOn, Task.tbTask.ActionedOn, Task.tbTask.PaymentOn, Task.tbTask.SecondReference, Task.tbTask.TaskNotes, Task.tbTask.TaxCode, Task.tbTask.Quantity, Task.tbTask.UnitCharge, 
                         Task.tbTask.TotalCharge, Task.tbTask.AddressCodeFrom, Task.tbTask.AddressCodeTo, Task.tbTask.Printed, Task.tbTask.Spooled, Task.tbTask.InsertedBy, Task.tbTask.InsertedOn, Task.tbTask.UpdatedBy, 
                         Task.tbTask.UpdatedOn, Task.vwBucket.Period, Task.vwBucket.BucketId, TaskStatus.TaskStatus, Task.tbTask.CashCode, Cash.tbCode.CashDescription, tbUser_1.UserName AS OwnerName, 
                         Usr.tbUser.UserName AS ActionName, Org.tbOrg.AccountName, OrgStatus.OrganisationStatus, Org.tbType.OrganisationType, CASE WHEN Cash.tbCategory.CategoryCode IS NULL 
                         THEN Org.tbType.CashModeCode ELSE Cash.tbCategory.CashModeCode END AS CashModeCode, Task.tbTask.RowVer
FROM            Usr.tbUser INNER JOIN
                         Task.tbStatus AS TaskStatus INNER JOIN
                         Org.tbType INNER JOIN
                         Org.tbOrg ON Org.tbType.OrganisationTypeCode = Org.tbOrg.OrganisationTypeCode INNER JOIN
                         Org.tbStatus AS OrgStatus ON Org.tbOrg.OrganisationStatusCode = OrgStatus.OrganisationStatusCode INNER JOIN
                         Task.tbTask ON Org.tbOrg.AccountCode = Task.tbTask.AccountCode ON TaskStatus.TaskStatusCode = Task.tbTask.TaskStatusCode ON Usr.tbUser.UserId = Task.tbTask.ActionById INNER JOIN
                         Usr.tbUser AS tbUser_1 ON Task.tbTask.UserId = tbUser_1.UserId INNER JOIN
                         Task.vwBucket ON Task.tbTask.TaskCode = Task.vwBucket.TaskCode LEFT OUTER JOIN
                         Cash.tbCode ON Task.tbTask.CashCode = Cash.tbCode.CashCode LEFT OUTER JOIN
                         Cash.tbCategory ON Cash.tbCode.CategoryCode = Cash.tbCategory.CategoryCode

go




