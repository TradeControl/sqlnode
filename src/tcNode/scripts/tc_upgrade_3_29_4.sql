/**************************************************************************************
Trade Control
Upgrade script
Release: 3.29.4

Date: 14 September 2020
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
ALTER TABLE Activity.tbActivity WITH NOCHECK ADD
	UnitChargeStore float;
go
UPDATE Activity.tbActivity
SET UnitChargeStore = UnitCharge
go
ALTER TABLE Activity.tbActivity DROP 
	CONSTRAINT DF_Activity_tbActivity_UnitCharge,	
	COLUMN	UnitCharge;
go
ALTER TABLE Activity.tbActivity WITH NOCHECK ADD
	UnitCharge decimal(18, 7) NOT NULL CONSTRAINT DF_Activity_tbActivity_UnitCharge DEFAULT (0);
go
UPDATE Activity.tbActivity
SET UnitCharge = UnitChargeStore
go
ALTER TABLE Activity.tbActivity DROP
	COLUMN UnitChargeStore
go

ALTER TABLE Task.tbChangeLog WITH NOCHECK ADD
	UnitChargeStore float;
go
UPDATE Task.tbChangeLog
SET UnitChargeStore = UnitCharge
go
ALTER TABLE Task.tbChangeLog DROP 
	CONSTRAINT DF_Task_tbChangeLog_UnitCharge,
	COLUMN	UnitCharge;
go
ALTER TABLE Task.tbChangeLog WITH NOCHECK ADD
	UnitCharge decimal(18, 7) NOT NULL CONSTRAINT DF_Task_tbChangeLog_UnitCharge DEFAULT (0);
go
UPDATE Task.tbChangeLog
SET UnitCharge = UnitChargeStore
go
ALTER TABLE Task.tbChangeLog DROP
	COLUMN UnitChargeStore
go

ALTER TABLE Task.tbAllocation WITH NOCHECK ADD
	UnitChargeStore float;
go
UPDATE Task.tbAllocation
SET UnitChargeStore = UnitCharge
go
ALTER TABLE Task.tbAllocation DROP 
	COLUMN	UnitCharge;
go
ALTER TABLE Task.tbAllocation WITH NOCHECK ADD
	UnitCharge decimal(18, 7) NOT NULL CONSTRAINT DF_Task_tbAllocation_UnitCharge DEFAULT (0);
go
UPDATE Task.tbAllocation
SET UnitCharge = UnitChargeStore
go
ALTER TABLE Task.tbAllocation DROP
	COLUMN UnitChargeStore
go
ALTER TABLE Task.tbAllocationEvent WITH NOCHECK ADD
	UnitChargeStore float;
go
UPDATE Task.tbAllocationEvent
SET UnitChargeStore = UnitCharge
go
ALTER TABLE Task.tbAllocationEvent DROP 
	COLUMN	UnitCharge;
go
ALTER TABLE Task.tbAllocationEvent WITH NOCHECK ADD
	UnitCharge decimal(18, 7) NOT NULL CONSTRAINT DF_tbAllocationEvent_UnitCharge DEFAULT (0);
go
UPDATE Task.tbAllocationEvent
SET UnitCharge = UnitChargeStore
go
ALTER TABLE Task.tbAllocationEvent DROP
	COLUMN UnitChargeStore
go
ALTER VIEW Org.vwSales
AS
	SELECT        AccountCode, TaskCode, UserId, ContactName, ActivityCode, TaskTitle, TaskStatusCode, ActionById, ActionOn, ActionedOn, PaymentOn, SecondReference, TaskNotes, TaxCode, Quantity, UnitCharge, TotalCharge, 
							 AddressCodeFrom, AddressCodeTo, Printed, Spooled, InsertedBy, InsertedOn, UpdatedBy, UpdatedOn, Period, BucketId, TaskStatus, CashCode, CashDescription, OwnerName, ActionName, AccountName, 
							 OrganisationStatus, OrganisationType, CashModeCode
	FROM            Task.vwTasks
	WHERE        (CashModeCode = 1) AND (CashCode IS NOT NULL);
go
ALTER VIEW Org.vwPurchases
AS
	SELECT        AccountCode, TaskCode, UserId, ContactName, ActivityCode, TaskTitle, TaskStatusCode, ActionById, ActionOn, ActionedOn, PaymentOn, SecondReference, TaskNotes, TaxCode, Quantity, UnitCharge, TotalCharge, 
							 AddressCodeFrom, AddressCodeTo, Printed, Spooled, InsertedBy, InsertedOn, UpdatedBy, UpdatedOn, Period, BucketId, TaskStatus, CashCode, CashDescription, OwnerName, ActionName, AccountName, 
							 OrganisationStatus, OrganisationType, CashModeCode
	FROM            Task.vwTasks
	WHERE        (CashModeCode = 0) AND (CashCode IS NOT NULL);

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
ALTER VIEW Task.vwOrgActivity
AS
	SELECT AccountCode, TaskStatusCode, ActionOn, TaskTitle, ActivityCode, ActionById, TaskCode, Period, BucketId, ContactName, TaskStatus, TaskNotes, ActionedOn, OwnerName, CashCode, CashDescription, Quantity, 
							 UnitCharge, TotalCharge, AddressCodeFrom, AddressCodeTo, Printed, InsertedBy, InsertedOn, UpdatedBy, UpdatedOn, AccountName, ActionName
	FROM            Task.vwTasks
	WHERE        (TaskStatusCode < 2);
go
ALTER VIEW Task.vwActiveData
AS
	SELECT        TaskCode, UserId, AccountCode, ContactName, ActivityCode, TaskTitle, TaskStatusCode, ActionById, ActionOn, ActionedOn, PaymentOn, SecondReference, TaskNotes, TaxCode, Quantity, UnitCharge, TotalCharge, 
							 AddressCodeFrom, AddressCodeTo, Printed, Spooled, InsertedBy, InsertedOn, UpdatedBy, UpdatedOn, Period, BucketId, TaskStatus, CashCode, CashDescription, OwnerName, ActionName, AccountName, 
							 OrganisationStatus, OrganisationType, CashModeCode
	FROM            Task.vwTasks
	WHERE        (TaskStatusCode = 1);
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
ALTER VIEW App.vwDocPurchaseEnquiry
AS
	SELECT Task.vwTasks.TaskCode, Task.vwTasks.ActionOn, Task.vwTasks.ActivityCode, Task.vwTasks.ActionById, Task.vwTasks.BucketId, Task.vwTasks.TaskTitle, Task.vwTasks.AccountCode, 
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
	SELECT Task.vwTasks.TaskCode, Task.vwTasks.ActionOn, Task.vwTasks.ActivityCode, Task.vwTasks.ActionById, Task.vwTasks.BucketId, Task.vwTasks.TaskTitle, Task.vwTasks.AccountCode, 
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
	SELECT Task.vwTasks.TaskCode, Task.vwTasks.ActionOn, Task.vwTasks.ActivityCode, Task.vwTasks.ActionById, Task.vwTasks.BucketId, Task.vwTasks.TaskTitle, Task.vwTasks.AccountCode, 
							 Task.vwTasks.ContactName, Task.vwTasks.TaskNotes, Task.vwTasks.OwnerName, Task.vwTasks.CashCode, Task.vwTasks.CashDescription, Task.vwTasks.Quantity, Activity.tbActivity.UnitOfMeasure, 
							 Task.vwTasks.UnitCharge, Task.vwTasks.TotalCharge, Org_tbAddress_1.Address AS FromAddress, Org.tbAddress.Address AS ToAddress, Task.vwTasks.InsertedBy, Task.vwTasks.InsertedOn, 
							 Task.vwTasks.UpdatedBy, Task.vwTasks.UpdatedOn, Task.vwTasks.AccountName, Task.vwTasks.ActionName, Task.vwTasks.Period, Task.vwTasks.Printed, Task.vwTasks.Spooled, Task.vwTasks.RowVer
	FROM            Task.vwTasks LEFT OUTER JOIN
							 Org.tbAddress AS Org_tbAddress_1 ON Task.vwTasks.AddressCodeFrom = Org_tbAddress_1.AddressCode LEFT OUTER JOIN
							 Org.tbAddress ON Task.vwTasks.AddressCodeTo = Org.tbAddress.AddressCode INNER JOIN
							 Activity.tbActivity ON Task.vwTasks.ActivityCode = Activity.tbActivity.ActivityCode
	WHERE        (Task.vwTasks.CashCode IS NOT NULL) AND (Task.vwTasks.CashModeCode = 1) AND (Task.vwTasks.TaskStatusCode = 0);
go
ALTER VIEW [App].[vwDocSalesOrder]
AS
	SELECT Task.vwTasks.TaskCode, Task.vwTasks.ActionOn, Task.vwTasks.ActivityCode, Task.vwTasks.ActionById, Task.vwTasks.BucketId, Task.vwTasks.AccountCode, Task.vwTasks.TaskTitle, 
							 Task.vwTasks.ContactName, Task.vwTasks.TaskNotes, Task.vwTasks.OwnerName, Task.vwTasks.CashCode, Task.vwTasks.CashDescription, Task.vwTasks.Quantity, Activity.tbActivity.UnitOfMeasure, 
							 Task.vwTasks.UnitCharge, Task.vwTasks.TotalCharge, Org_tbAddress_1.Address AS FromAddress, Org.tbAddress.Address AS ToAddress, Task.vwTasks.InsertedBy, Task.vwTasks.InsertedOn, 
							 Task.vwTasks.UpdatedBy, Task.vwTasks.UpdatedOn, Task.vwTasks.AccountName, Task.vwTasks.ActionName, Task.vwTasks.Period, Task.vwTasks.Printed, Task.vwTasks.Spooled, Task.vwTasks.RowVer
	FROM            Task.vwTasks LEFT OUTER JOIN
							 Org.tbAddress AS Org_tbAddress_1 ON Task.vwTasks.AddressCodeFrom = Org_tbAddress_1.AddressCode LEFT OUTER JOIN
							 Org.tbAddress ON Task.vwTasks.AddressCodeTo = Org.tbAddress.AddressCode INNER JOIN
							 Activity.tbActivity ON Task.vwTasks.ActivityCode = Activity.tbActivity.ActivityCode
	WHERE        (Task.vwTasks.CashCode IS NOT NULL) AND (Task.vwTasks.CashModeCode = 1) AND (Task.vwTasks.TaskStatusCode > 0);
go
ALTER VIEW Task.vwNetworkDeployments
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
ALTER VIEW Task.vwNetworkUpdates
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
ALTER VIEW Task.vwNetworkEventLog
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
ALTER VIEW Activity.vwUnMirrored
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
ALTER VIEW Task.vwAllocationSvD
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
ALTER VIEW Task.vwNetworkAllocations
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
ALTER VIEW Task.vwNetworkEvents
AS
	SELECT        Task.tbAllocationEvent.ContractAddress, Task.tbAllocationEvent.LogId, App.tbEventType.EventTypeCode, App.tbEventType.EventType, 
							 Task.tbStatus.TaskStatusCode, Task.tbStatus.TaskStatus, Task.tbAllocationEvent.ActionOn, Task.tbAllocationEvent.UnitCharge, Task.tbAllocationEvent.TaxRate, Task.tbAllocationEvent.QuantityOrdered, 
							 Task.tbAllocationEvent.QuantityDelivered, Task.tbAllocationEvent.InsertedOn
	FROM            Task.tbAllocationEvent INNER JOIN
							 App.tbEventType ON Task.tbAllocationEvent.EventTypeCode = App.tbEventType.EventTypeCode INNER JOIN
							 Task.tbStatus ON Task.tbAllocationEvent.TaskStatusCode = Task.tbStatus.TaskStatusCode;
go
ALTER VIEW Task.vwNetworkQuotations
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
ALTER VIEW Task.vwNetworkChangeLog
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
ALTER VIEW Task.vwChangeLog AS
	SELECT  Task.tbChangeLog.LogId, Task.tbChangeLog.TaskCode, Task.tbChangeLog.ChangedOn, Org.tbTransmitStatus.TransmitStatusCode, Org.tbTransmitStatus.TransmitStatus, Org.tbOrg.AccountCode, Org.tbOrg.AccountName, 
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
