﻿CREATE   FUNCTION Cash.fnChange(@AccountCode nvarchar(10), @KeyName nvarchar(50), @ChangeTypeCode smallint)
RETURNS TABLE
AS
	RETURN
	(
		WITH account_reference AS
		(
			SELECT        Cash.tbChangeReference.PaymentAddress, Cash.tbChangeReference.InvoiceNumber, Invoice.tbInvoice.SubjectCode, Subject.tbSubject.SubjectName, Invoice.tbType.InvoiceType, 
										Invoice.tbInvoice.InvoiceValue + Invoice.tbInvoice.TaxValue - Invoice.tbInvoice.PaidValue - Invoice.tbInvoice.PaidTaxValue AS AmountDue, Invoice.tbInvoice.ExpectedOn, Invoice.tbStatus.InvoiceStatus, Invoice.tbType.CashPolarityCode
			FROM            Cash.tbChangeReference INNER JOIN
										Invoice.tbInvoice ON Cash.tbChangeReference.InvoiceNumber = Invoice.tbInvoice.InvoiceNumber INNER JOIN
										Subject.tbSubject ON Invoice.tbInvoice.SubjectCode = Subject.tbSubject.SubjectCode INNER JOIN
										Invoice.tbType ON Invoice.tbInvoice.InvoiceTypeCode = Invoice.tbType.InvoiceTypeCode INNER JOIN
										Invoice.tbStatus ON Invoice.tbInvoice.InvoiceStatusCode = Invoice.tbStatus.InvoiceStatusCode
		), key_namespace AS
		(
			SELECT AccountCode, HDPath, KeyNamespace, KeyName
			FROM Subject.fnKeyNamespace(@AccountCode, @KeyName) kn
		), change AS
		(
			SELECT Cash.fnChangeKeyPath(cash_account.CoinTypeCode, key_namespace.HDPath.ToString(), change.ChangeTypeCode, AddressIndex)  FullHDPath, 
				change.AccountCode, key_namespace.KeyName, key_namespace.KeyNamespace, change.AddressIndex, change.PaymentAddress, change.ChangeTypeCode, change_type.ChangeType, change.ChangeStatusCode, change_Status.ChangeStatus,
				change.Note, account_reference.InvoiceNumber, account_reference.SubjectCode, account_reference.SubjectName, account_reference.InvoiceType, account_reference.InvoiceStatus, account_reference.CashPolarityCode,
				account_reference.AmountDue, account_reference.ExpectedOn, change.UpdatedOn, change.UpdatedBy, change.InsertedOn, change.InsertedBy, change.RowVer
			FROM  key_namespace 
				JOIN Subject.tbAccount AS cash_account ON key_namespace.AccountCode = cash_account.AccountCode AND key_namespace.AccountCode = cash_account.AccountCode 
				JOIN Cash.tbChange AS change ON key_namespace.AccountCode = change.AccountCode AND key_namespace.HDPath = change.HDPath 
				JOIN Cash.tbChangeType change_type ON change.ChangeTypeCode = change_type .ChangeTypeCode 
				JOIN Cash.tbChangeStatus change_status ON change.ChangeStatusCode = change_status .ChangeStatusCode 

				LEFT OUTER JOIN account_reference ON change.PaymentAddress = account_reference.PaymentAddress
			WHERE change.ChangeTypeCode = @ChangeTypeCode 
	)
	SELECT change.*, COALESCE(change_balance.Balance, 0) Balance
	FROM change
		OUTER APPLY
		(
			SELECT PaymentAddress, SUM(MoneyIn) Balance
			FROM Cash.tbTx tx
			WHERE tx.PaymentAddress = change.PaymentAddress AND tx.TxStatusCode = 1
			GROUP BY PaymentAddress
		) AS change_balance
	)
