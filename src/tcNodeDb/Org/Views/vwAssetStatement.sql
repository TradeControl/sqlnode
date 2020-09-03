CREATE   VIEW Org.vwAssetStatement
AS
	WITH payment_data AS
	(
		SELECT Cash.tbPayment.AccountCode, Cash.tbPayment.PaidOn AS TransactedOn, 2 AS OrderBy, 
				CASE WHEN PaidInValue > 0 THEN PaidInValue - TaxInValue ELSE (PaidOutValue - TaxOutValue) * - 1 END AS Charge
		FROM Cash.tbPayment 
			JOIN Org.tbAccount ON Cash.tbPayment.CashAccountCode = Org.tbAccount.CashAccountCode
			JOIN Cash.tbPaymentStatus ON Cash.tbPayment.PaymentStatusCode = Cash.tbPaymentStatus.PaymentStatusCode
		WHERE Org.tbAccount.AccountTypeCode < 2
	), payments AS
	(
		SELECT     AccountCode, TransactedOn, OrderBy, SUM(Charge) AS Charge
		FROM     payment_data
		GROUP BY AccountCode, TransactedOn, OrderBy
	), invoices AS
	(
		SELECT Invoice.tbInvoice.AccountCode, Invoice.tbInvoice.InvoicedOn AS TransactedOn, 1 AS OrderBy, 
			CASE CashModeCode 
				WHEN 0 THEN Invoice.tbInvoice.InvoiceValue 
				WHEN 1 THEN Invoice.tbInvoice.InvoiceValue  * - 1 
			END AS Charge
		FROM         Invoice.tbInvoice INNER JOIN
							  Invoice.tbType ON Invoice.tbInvoice.InvoiceTypeCode = Invoice.tbType.InvoiceTypeCode
	), transactions_union AS
	(
		SELECT     AccountCode, TransactedOn, OrderBy, Charge
		FROM         payments
		UNION
		SELECT     AccountCode, TransactedOn, OrderBy, Charge
		FROM         invoices
	), transactions AS
	(
		SELECT AccountCode, ROW_NUMBER() OVER (PARTITION BY AccountCode ORDER BY TransactedOn, OrderBy) AS RowNumber, TransactedOn, OrderBy, Charge 
		FROM transactions_union
	), opening_balance AS
	(
		SELECT AccountCode, 0 AS RowNumber, InsertedOn AS TransactedOn, 0 AS OrderBy, OpeningBalance AS Charge
		FROM Org.tbOrg org
	), statement_data AS
	( 
		SELECT AccountCode, RowNumber, TransactedOn, OrderBy, Charge FROM transactions
		UNION
		SELECT AccountCode, RowNumber, TransactedOn, OrderBy, Charge FROM opening_balance
	)
	SELECT AccountCode, CAST(RowNumber AS INT) AS RowNumber, TransactedOn, OrderBy, CAST(Charge AS float) AS Charge,
		CAST(SUM(Charge) OVER (PARTITION BY AccountCode ORDER BY RowNumber ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS float) AS Balance
	FROM statement_data;
