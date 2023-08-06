﻿CREATE VIEW Project.vwQuotationSpool
AS
	SELECT        sales_order.ProjectCode, sales_order.ContactName, Subject.tbContact.NickName, Usr.tbUser.UserName, Subject.tbSubject.AccountName, invoice_address.Address AS InvoiceAddress, 
							 delivery_address.Address AS DeliveryAddress, sales_order.AccountCode, sales_order.ProjectNotes, sales_order.ObjectCode, sales_order.ActionOn, Object.tbObject.UnitOfMeasure, sales_order.Quantity, 
							 App.tbTaxCode.TaxCode, App.tbTaxCode.TaxRate, sales_order.UnitCharge, sales_order.TotalCharge, Usr.tbUser.MobileNumber, Usr.tbUser.Signature, sales_order.ProjectTitle
	FROM            Usr.tbUser INNER JOIN
							 Object.tbObject INNER JOIN
							 Project.tbProject AS sales_order ON Object.tbObject.ObjectCode = sales_order.ObjectCode INNER JOIN
							 Subject.tbSubject ON sales_order.AccountCode = Subject.tbSubject.AccountCode LEFT OUTER JOIN
							 Subject.tbAddress AS invoice_address ON Subject.tbSubject.AddressCode = invoice_address.AddressCode ON Usr.tbUser.UserId = sales_order.ActionById LEFT OUTER JOIN
							 Subject.tbAddress AS delivery_address ON sales_order.AddressCodeTo = delivery_address.AddressCode LEFT OUTER JOIN
							 App.tbTaxCode ON sales_order.TaxCode = App.tbTaxCode.TaxCode LEFT OUTER JOIN
							 Subject.tbContact ON sales_order.AccountCode = Subject.tbContact.AccountCode AND sales_order.ContactName = Subject.tbContact.ContactName
	WHERE EXISTS (
		SELECT        UserName, DocTypeCode, DocumentNumber, SpooledOn
		FROM            App.tbDocSpool AS doc
		WHERE        (DocTypeCode = 0) AND (UserName = SUSER_SNAME()) AND (sales_order.ProjectCode = DocumentNumber));
