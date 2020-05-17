﻿CREATE   VIEW Invoice.vwMirrors
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
