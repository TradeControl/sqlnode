﻿CREATE VIEW Subject.vwInvoiceItems
AS
SELECT        Invoice.tbInvoice.AccountCode, Invoice.tbItem.InvoiceNumber, Invoice.tbItem.CashCode, Invoice.tbInvoice.InvoicedOn, Invoice.tbInvoice.InvoiceTypeCode, Invoice.tbStatus.InvoiceStatus, 
                         Cash.tbCode.CashDescription, Subject.tbSubject.AccountName, Invoice.tbInvoice.InvoiceStatusCode, Invoice.tbType.InvoiceType, Invoice.tbItem.TaxCode, Invoice.tbItem.TaxValue, 
                         Invoice.tbItem.InvoiceValue, Invoice.tbInvoice.PaidValue, Invoice.tbInvoice.PaidTaxValue, Invoice.tbItem.ItemReference
FROM            Invoice.tbInvoice INNER JOIN
                         Invoice.tbStatus ON Invoice.tbInvoice.InvoiceStatusCode = Invoice.tbStatus.InvoiceStatusCode INNER JOIN
                         Subject.tbSubject ON Invoice.tbInvoice.AccountCode = Subject.tbSubject.AccountCode INNER JOIN
                         Invoice.tbType ON Invoice.tbInvoice.InvoiceTypeCode = Invoice.tbType.InvoiceTypeCode INNER JOIN
                         Invoice.tbItem ON Invoice.tbInvoice.InvoiceNumber = Invoice.tbItem.InvoiceNumber INNER JOIN
                         Cash.tbCode ON Invoice.tbItem.CashCode = Cash.tbCode.CashCode
WHERE        (Invoice.tbInvoice.InvoiceStatusCode > 0);
