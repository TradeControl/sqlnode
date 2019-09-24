
CREATE   PROCEDURE Invoice.proc_Total 
	(
	@InvoiceNumber nvarchar(20)
	)
  AS
   	SET NOCOUNT, XACT_ABORT ON;

	BEGIN TRY

		WITH totals AS
		(
			SELECT InvoiceNumber, SUM(InvoiceValue) AS InvoiceValue, 
				SUM(TaxValue) AS TaxValue,
				SUM(PaidValue) AS PaidValue, 
				SUM(PaidTaxValue) AS PaidTaxValue
			FROM         Invoice.tbTask
			GROUP BY InvoiceNumber
			HAVING      (InvoiceNumber = @InvoiceNumber)
			UNION
			SELECT InvoiceNumber, SUM(InvoiceValue) AS InvoiceValue, 
				SUM(TaxValue) AS TaxValue,
				SUM(PaidValue) AS PaidValue, 
				SUM(PaidTaxValue) AS PaidTaxValue
			FROM         Invoice.tbItem
			GROUP BY InvoiceNumber
			HAVING      (InvoiceNumber = @InvoiceNumber)
		), grand_total AS
		(
			SELECT InvoiceNumber, ISNULL(SUM(InvoiceValue), 0) AS InvoiceValue, 
				ISNULL(SUM(TaxValue), 0) AS TaxValue, 
				ISNULL(SUM(PaidValue), 0) AS PaidValue, 
				ISNULL(SUM(PaidTaxValue), 0) AS PaidTaxValue
			FROM totals
			GROUP BY InvoiceNumber
		) 
		UPDATE    Invoice.tbInvoice
		SET InvoiceValue = grand_total.InvoiceValue, TaxValue = grand_total.TaxValue,
			PaidValue = grand_total.PaidValue, PaidTaxValue = grand_total.PaidTaxValue,
			InvoiceStatusCode = CASE 
					WHEN grand_total.PaidValue >= grand_total.InvoiceValue THEN 3 
					WHEN grand_total.PaidValue > 0 THEN 2 
					ELSE 1 END
		FROM Invoice.tbInvoice INNER JOIN grand_total ON Invoice.tbInvoice.InvoiceNumber = grand_total.InvoiceNumber;
		
  	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
