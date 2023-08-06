﻿CREATE VIEW Project.vwPurchaseOrderDeliverySpool
AS
	SELECT        purchase_order.ProjectCode, purchase_order.ContactName, Subject.tbContact.NickName, Usr.tbUser.UserName, Subject.tbSubject.AccountName, invoice_address.Address AS InvoiceAddress, 
							 delivery_account.AccountName AS CollectAccount, delivery_address.Address AS CollectAddress, collection_account.AccountName AS DeliveryAccount, collection_address.Address AS DeliveryAddress, 
							 purchase_order.AccountCode, purchase_order.ProjectNotes, purchase_order.ObjectCode, purchase_order.ActionOn, Object.tbObject.UnitOfMeasure, purchase_order.Quantity, App.tbTaxCode.TaxCode, 
							 App.tbTaxCode.TaxRate, purchase_order.UnitCharge, purchase_order.TotalCharge, Usr.tbUser.MobileNumber, Usr.tbUser.Signature, purchase_order.ProjectTitle
	FROM            Subject.tbSubject AS collection_account INNER JOIN
							 Subject.tbSubject AS delivery_account INNER JOIN
							 Usr.tbUser INNER JOIN
							 Object.tbObject INNER JOIN
							 Project.tbProject AS purchase_order ON Object.tbObject.ObjectCode = purchase_order.ObjectCode INNER JOIN
							 Subject.tbSubject ON purchase_order.AccountCode = Subject.tbSubject.AccountCode LEFT OUTER JOIN
							 Subject.tbAddress AS invoice_address ON Subject.tbSubject.AddressCode = invoice_address.AddressCode ON Usr.tbUser.UserId = purchase_order.ActionById INNER JOIN
							 Subject.tbAddress AS collection_address ON purchase_order.AddressCodeTo = collection_address.AddressCode LEFT OUTER JOIN
							 App.tbTaxCode ON purchase_order.TaxCode = App.tbTaxCode.TaxCode LEFT OUTER JOIN
							 Subject.tbContact ON purchase_order.ContactName = Subject.tbContact.ContactName AND purchase_order.AccountCode = Subject.tbContact.AccountCode INNER JOIN
							 Subject.tbAddress AS delivery_address ON purchase_order.AddressCodeFrom = delivery_address.AddressCode ON delivery_account.AccountCode = delivery_address.AccountCode ON 
							 collection_account.AccountCode = collection_address.AccountCode
	WHERE EXISTS (
		SELECT        UserName, DocTypeCode, DocumentNumber, SpooledOn
		FROM            App.tbDocSpool AS doc
		WHERE        (DocTypeCode = 3) AND (UserName = SUSER_SNAME()) AND (purchase_order.ProjectCode = DocumentNumber));
