CREATE   VIEW Invoice.vwStatusLive
AS
	WITH nonzero_balance_orgs AS
	(
		SELECT AccountCode, Balance, CASE WHEN Balance > 0 THEN 0 ELSE 1 END CashModeCode 
		FROM Org.vwCurrentBalance
	), invoice_statement AS
	(
		SELECT nonzero_balance_orgs.AccountCode, 
			RowNumber, InvoiceNumber, CashModeCode, TotalCharge, TaxValue,
			CASE RowNumber 
				WHEN 1 THEN nonzero_balance_orgs.Balance + TotalCharge
			ELSE TotalCharge 
			END Charge,
			CASE RowNumber 
				WHEN 1 THEN nonzero_balance_orgs.Balance 
				ELSE 0 END OpeningBalance, 
			CASE RowNumber
				WHEN 1 THEN 
					CASE CashModeCode 
						WHEN 0 THEN
							CASE WHEN TotalCharge > 0 THEN -1 ELSE 1 END
						WHEN 1 THEN
							CASE WHEN TotalCharge < 0 THEN -1 ELSE 1 END
					END
				ELSE 1
			END Multiplier
		FROM nonzero_balance_orgs
			CROSS APPLY
				(
					SELECT InvoiceNumber,
						ROW_NUMBER() OVER (ORDER BY InvoicedOn DESC) RowNumber,
						CASE CashModeCode 
							WHEN 0 THEN (InvoiceValue + TaxValue) * - 1  
							WHEN 1 THEN (InvoiceValue + TaxValue)
						END AS TotalCharge,
						TaxValue
					FROM Invoice.tbInvoice invoices
						INNER JOIN Invoice.tbType ON invoices.InvoiceTypeCode = Invoice.tbType.InvoiceTypeCode
					WHERE AccountCode = nonzero_balance_orgs.AccountCode AND InvoiceValue <> 0
				) invoices
	), invoice_multiplier AS
	(
		SELECT AccountCode, RowNumber, InvoiceNumber, CashModeCode, TotalCharge, TaxValue, OpeningBalance, Charge,
			MIN(Multiplier) OVER (PARTITION BY AccountCode ORDER BY RowNumber) Multiplier
		FROM invoice_statement
	), invoice_balances AS
	(
		SELECT  AccountCode, RowNumber, InvoiceNumber, CashModeCode, TotalCharge, TaxValue, OpeningBalance, Charge,
			CAST(SUM(Charge * Multiplier) OVER (PARTITION BY AccountCode ORDER BY RowNumber ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS float) AS Balance
		FROM invoice_multiplier
	), invoice_paid AS
	(
		SELECT AccountCode, RowNumber, InvoiceNumber, CashModeCode, TotalCharge,
			ABS(TotalCharge) - TaxValue InvoiceValue, TaxValue, TaxValue / ABS(TotalCharge) TaxRate, 
			OpeningBalance, Charge, Balance, 
			CASE CashModeCode 
				WHEN 0 THEN
					CASE 
						WHEN Balance >= 0 THEN 1
						WHEN TotalCharge < Balance THEN 2
						ELSE 3
					END 
				WHEN 1 THEN
					CASE 
						WHEN Balance <= 0 THEN 1
						WHEN TotalCharge > Balance THEN 2
						ELSE 3
					END 
			END InvoiceStatusCode,
			CASE CashModeCode 
				WHEN 0 THEN
					CASE 
						WHEN Balance >= 0 THEN 0
						WHEN TotalCharge < Balance THEN TotalCharge - Balance
						ELSE TotalCharge
					END 
				WHEN 1 THEN
					CASE 
						WHEN Balance <= 0 THEN 0
						WHEN TotalCharge > Balance THEN TotalCharge - Balance
						ELSE TotalCharge
					END 
			END TotalPaid		
		FROM invoice_balances
	)
	, invoice_status AS
	(
		SELECT AccountCode, RowNumber, InvoiceNumber, CashModeCode, TotalCharge, InvoiceValue, TaxValue, TaxRate, OpeningBalance, Charge, Balance, TotalPaid,
			MAX(InvoiceStatusCode) OVER (PARTITION BY AccountCode ORDER BY RowNumber) InvoiceStatusCode
		FROM invoice_paid
	)
	SELECT AccountCode, RowNumber, InvoiceNumber, CashModeCode, TotalCharge, InvoiceValue, TaxValue, TaxRate, OpeningBalance, Charge, Balance, TotalPaid,
		InvoiceStatusCode, 
		CASE CashModeCode 
			WHEN 0 THEN
				CASE InvoiceStatusCode
					WHEN 1 THEN 0
					WHEN 2 THEN InvoiceValue + (TotalPaid / (1 + TaxRate)) 
					ELSE InvoiceValue
				END
			WHEN 1 THEN
				CASE InvoiceStatusCode
					WHEN 1 THEN 0
					WHEN 2 THEN InvoiceValue - (TotalPaid / (1 + TaxRate)) 
					ELSE InvoiceValue
				END
		END PaidValue, 				
		CASE CashModeCode 
			WHEN 0 THEN
				CASE InvoiceStatusCode						
					WHEN 1 THEN 0
					WHEN 2 THEN TaxValue +	(TotalPaid - (TotalPaid / (1 + TaxRate))) 
					ELSE TaxValue
				END
			WHEN 1 THEN
				CASE InvoiceStatusCode						
					WHEN 1 THEN 0
					WHEN 2 THEN TaxValue -(TotalPaid - (TotalPaid / (1 + TaxRate))) 
					ELSE TaxValue
				END
		END PaidTaxValue
	FROM invoice_status;
