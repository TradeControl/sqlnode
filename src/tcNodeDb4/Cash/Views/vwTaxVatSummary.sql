CREATE VIEW [Cash].[vwTaxVatSummary]
AS
	WITH vat_transactions AS
	(
		SELECT
			(
				SELECT TOP (1) yp.StartOn
				FROM App.tbYearPeriod AS yp
				WHERE yp.StartOn <= i.InvoicedOn
				ORDER BY yp.StartOn DESC
			) AS StartOn,
			it.TaxCode,
			i.InvoiceTypeCode,
			it.InvoiceValue,
			it.TaxValue,
			ISNULL(s.ExportTypeCode, 0) AS ExportTypeCode
		FROM App.vwTaxVatCashCodes AS c
			INNER JOIN Invoice.tbItem AS it
				ON c.CashCode = it.CashCode
			INNER JOIN Invoice.tbInvoice AS i
				ON it.InvoiceNumber = i.InvoiceNumber
			INNER JOIN Subject.tbSubject AS s
				ON i.SubjectCode = s.SubjectCode
			INNER JOIN App.tbTaxCode AS tc
				ON it.TaxCode = tc.TaxCode
		WHERE tc.TaxTypeCode = 1

		UNION ALL

		SELECT
			(
				SELECT TOP (1) yp.StartOn
				FROM App.tbYearPeriod AS yp
				WHERE yp.StartOn <= i.InvoicedOn
				ORDER BY yp.StartOn DESC
			) AS StartOn,
			ip.TaxCode,
			i.InvoiceTypeCode,
			ip.InvoiceValue,
			ip.TaxValue,
			ISNULL(s.ExportTypeCode, 0) AS ExportTypeCode
		FROM App.vwTaxVatCashCodes AS c
			INNER JOIN Invoice.tbProject AS ip
				ON c.CashCode = ip.CashCode
			INNER JOIN Invoice.tbInvoice AS i
				ON ip.InvoiceNumber = i.InvoiceNumber
			INNER JOIN Subject.tbSubject AS s
				ON i.SubjectCode = s.SubjectCode
			INNER JOIN App.tbTaxCode AS tc
				ON ip.TaxCode = tc.TaxCode
		WHERE tc.TaxTypeCode = 1
	), vat_tran AS
	(
		SELECT
			StartOn,
			TaxCode,
			CAST(SUM
			(
				CASE
					WHEN ExportTypeCode IN (0, 2) THEN
						CASE InvoiceTypeCode
							WHEN 0 THEN TaxValue
							WHEN 1 THEN TaxValue * -1
							ELSE 0
						END
					ELSE 0
				END
			) AS decimal(18,5)) AS vatDueSales,
			CAST(SUM
			(
				CASE
					WHEN ExportTypeCode = 2 THEN
						CASE InvoiceTypeCode
							WHEN 2 THEN TaxValue * -1
							WHEN 3 THEN TaxValue
							ELSE 0
						END
					ELSE 0
				END
			) AS decimal(18,5)) AS vatDueAcquisitions,
			CAST(SUM
			(
				CASE
					WHEN ExportTypeCode IN (0, 2) THEN
						CASE InvoiceTypeCode
							WHEN 0 THEN InvoiceValue
							WHEN 1 THEN InvoiceValue * -1
							ELSE 0
						END
					ELSE 0
				END
			) AS decimal(18,5)) AS totalValueSalesExVAT,
			CAST(SUM
			(
				CASE
					WHEN ExportTypeCode IN (0, 2) THEN
						CASE
							WHEN ExportTypeCode = 0 AND InvoiceTypeCode = 2 THEN InvoiceValue
							WHEN ExportTypeCode = 0 AND InvoiceTypeCode = 3 THEN InvoiceValue * -1
							WHEN ExportTypeCode = 2 AND InvoiceTypeCode = 2 THEN InvoiceValue
							WHEN ExportTypeCode = 2 AND InvoiceTypeCode = 3 THEN InvoiceValue * -1
							ELSE 0
						END
					ELSE 0
				END
			) AS decimal(18,5)) AS totalValuePurchasesExVAT,
			CAST(SUM
			(
				CASE
					WHEN ExportTypeCode = 0 THEN
						CASE InvoiceTypeCode
							WHEN 2 THEN TaxValue * -1
							WHEN 3 THEN TaxValue
							ELSE 0
						END
					ELSE 0
				END
			) AS decimal(18,5)) AS vatReclaimedCurrPeriod,
			CAST(0 AS decimal(18,5)) AS totalValueGoodsSuppliedExVAT,
			CAST(0 AS decimal(18,5)) AS totalValueGoodsReceivedExVAT
		FROM vat_transactions
		WHERE ExportTypeCode <> 1
		GROUP BY
			StartOn,
			TaxCode
	)
	SELECT 
		vt.StartOn
		, vt.TaxCode
		, vt.totalValueGoodsReceivedExVAT
		, vt.totalValueGoodsSuppliedExVAT
		, vt.totalValuePurchasesExVAT
		, vt.totalValueSalesExVAT
		, vt.vatDueAcquisitions
		, vt.vatDueSales
		, vt.vatReclaimedCurrPeriod
		, p.VatAdjustment vatAdjustment
		, CAST
		  (
			vatDueSales
			+ vatDueAcquisitions
			+ vatReclaimedCurrPeriod
			+ p.VatAdjustment AS decimal(18,5)
		  ) AS netVatDue
	FROM vat_tran vt
		JOIN App.tbYearPeriod AS p
			ON vt.StartOn = p.StartOn
GO
