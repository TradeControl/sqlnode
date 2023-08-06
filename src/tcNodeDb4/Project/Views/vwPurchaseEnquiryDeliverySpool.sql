﻿CREATE VIEW Project.vwPurchaseEnquiryDeliverySpool
AS
	SELECT        purchase_enquiry.ProjectCode, purchase_enquiry.ContactName, Subject.tbContact.NickName, Usr.tbUser.UserName, Subject.tbSubject.AccountName, Subject.tbAddress.Address AS InvoiceAddress, 
							 collection_account.AccountName AS CollectAccount, collection_address.Address AS CollectAddress, delivery_account.AccountName AS DeliveryAccount, delivery_address.Address AS DeliveryAddress, 
							 purchase_enquiry.AccountCode, purchase_enquiry.ProjectNotes, purchase_enquiry.ObjectCode, purchase_enquiry.ActionOn, Object.tbObject.UnitOfMeasure, purchase_enquiry.Quantity, App.tbTaxCode.TaxCode, 
							 App.tbTaxCode.TaxRate, purchase_enquiry.UnitCharge, purchase_enquiry.TotalCharge, Usr.tbUser.MobileNumber, Usr.tbUser.Signature, purchase_enquiry.ProjectTitle
	FROM            Subject.tbSubject AS delivery_account INNER JOIN
							 Subject.tbSubject AS collection_account INNER JOIN
							 Usr.tbUser INNER JOIN
							 Object.tbObject INNER JOIN
							 Project.tbProject AS purchase_enquiry ON Object.tbObject.ObjectCode = purchase_enquiry.ObjectCode INNER JOIN
							 Subject.tbSubject ON purchase_enquiry.AccountCode = Subject.tbSubject.AccountCode LEFT OUTER JOIN
							 Subject.tbAddress ON Subject.tbSubject.AddressCode = Subject.tbAddress.AddressCode ON Usr.tbUser.UserId = purchase_enquiry.ActionById INNER JOIN
							 Subject.tbAddress AS delivery_address ON purchase_enquiry.AddressCodeTo = delivery_address.AddressCode LEFT OUTER JOIN
							 App.tbTaxCode ON purchase_enquiry.TaxCode = App.tbTaxCode.TaxCode LEFT OUTER JOIN
							 Subject.tbContact ON purchase_enquiry.ContactName = Subject.tbContact.ContactName AND purchase_enquiry.AccountCode = Subject.tbContact.AccountCode INNER JOIN
							 Subject.tbAddress AS collection_address ON purchase_enquiry.AddressCodeFrom = collection_address.AddressCode ON collection_account.AccountCode = collection_address.AccountCode ON 
							 delivery_account.AccountCode = delivery_address.AccountCode
	WHERE EXISTS (SELECT * FROM App.tbDocSpool AS doc WHERE DocTypeCode = 2 AND UserName = SUSER_SNAME() AND purchase_enquiry.ProjectCode = doc.DocumentNumber);
