CREATE VIEW Cash.vwTaxVatAuditInvoices
AS
	WITH vat_transactions AS
	(
		SELECT
			i.InvoicedOn,
			i.InvoiceNumber,
			i.InvoiceTypeCode,
			it.TaxCode,
			it.InvoiceValue,
			it.TaxValue,
			ROUND(it.TaxValue / it.InvoiceValue, 3) AS CalcRate,
			tc.TaxRate,
			ISNULL(s.ExportTypeCode, 0) AS ExportTypeCode,
			it.CashCode AS IdentityCode,
			c.CashDescription AS ItemDescription
		FROM Invoice.tbItem AS it
			INNER JOIN Invoice.tbInvoice AS i
				ON it.InvoiceNumber = i.InvoiceNumber
			INNER JOIN Subject.tbSubject AS s
				ON i.SubjectCode = s.SubjectCode
			INNER JOIN App.tbTaxCode AS tc
				ON it.TaxCode = tc.TaxCode
			INNER JOIN Cash.tbCode AS c
				ON it.CashCode = c.CashCode
		WHERE tc.TaxTypeCode = 1
			AND it.InvoiceValue <> 0

		UNION ALL

		SELECT
			i.InvoicedOn,
			ip.InvoiceNumber,
			i.InvoiceTypeCode,
			ip.TaxCode,
			ip.InvoiceValue,
			ip.TaxValue,
			ROUND(ip.TaxValue / ip.InvoiceValue, 3) AS CalcRate,
			tc.TaxRate,
			ISNULL(s.ExportTypeCode, 0) AS ExportTypeCode,
			ip.ProjectCode AS IdentityCode,
			p.ProjectTitle AS ItemDescription
		FROM Invoice.tbProject AS ip
			INNER JOIN Invoice.tbInvoice AS i
				ON ip.InvoiceNumber = i.InvoiceNumber
			INNER JOIN Subject.tbSubject AS s
				ON i.SubjectCode = s.SubjectCode
			INNER JOIN App.tbTaxCode AS tc
				ON ip.TaxCode = tc.TaxCode
			INNER JOIN Project.tbProject AS p
				ON ip.ProjectCode = p.ProjectCode
		WHERE tc.TaxTypeCode = 1
			AND ip.InvoiceValue <> 0
	),
	vat_dataset AS
	(
		SELECT
			(
				SELECT due_dates.PayTo
				FROM Cash.fnTaxTypeDueDates(1, 0) AS due_dates
				WHERE vt.InvoicedOn >= due_dates.PayFrom
					AND vt.InvoicedOn < due_dates.PayTo
			) AS StartOn,
			vt.InvoicedOn,
			vt.InvoiceNumber,
			it.InvoiceType,
			vt.InvoiceTypeCode,
			vt.TaxCode,
			vt.InvoiceValue,
			vt.TaxValue,
			vt.TaxRate,
			vt.ExportTypeCode,
			vt.IdentityCode,
			vt.ItemDescription,
			CAST
			(
				CASE
					WHEN vt.ExportTypeCode IN (0, 2) THEN
						CASE vt.InvoiceTypeCode
							WHEN 0 THEN vt.TaxValue
							WHEN 1 THEN vt.TaxValue * -1
							ELSE 0
						END
					ELSE 0
				END
				AS decimal(18,5)
			) AS vatDueSales,
			CAST
			(
				CASE
					WHEN vt.ExportTypeCode = 2 THEN
						CASE vt.InvoiceTypeCode
							WHEN 2 THEN vt.TaxValue * -1
							WHEN 3 THEN vt.TaxValue
							ELSE 0
						END
					ELSE 0
				END
				AS decimal(18,5)
			) AS vatDueAcquisitions,
			CAST
			(
				CASE
					WHEN vt.ExportTypeCode = 0 THEN
						CASE vt.InvoiceTypeCode
							WHEN 2 THEN vt.TaxValue * -1
							WHEN 3 THEN vt.TaxValue
							ELSE 0
						END
					ELSE 0
				END
				AS decimal(18,5)
			) AS vatReclaimedCurrPeriod,
			CAST
			(
				CASE
					WHEN vt.ExportTypeCode IN (0, 2) THEN
						CASE vt.InvoiceTypeCode
							WHEN 0 THEN vt.InvoiceValue
							WHEN 1 THEN vt.InvoiceValue * -1
							ELSE 0
						END
					ELSE 0
				END
				AS decimal(18,5)
			) AS totalValueSalesExVAT,
			CAST
			(
				CASE
					WHEN vt.ExportTypeCode IN (0, 2) THEN
						CASE
							WHEN vt.InvoiceTypeCode = 2 THEN vt.InvoiceValue
							WHEN vt.InvoiceTypeCode = 3 THEN vt.InvoiceValue * -1
							ELSE 0
						END
					ELSE 0
				END
				AS decimal(18,5)
			) AS totalValuePurchasesExVAT,
			CAST(0 AS decimal(18,5)) AS totalValueGoodsSuppliedExVAT,
			CAST(0 AS decimal(18,5)) AS totalValueGoodsReceivedExVAT
		FROM vat_transactions AS vt
			INNER JOIN Invoice.tbType AS it
				ON vt.InvoiceTypeCode = it.InvoiceTypeCode
		WHERE vt.ExportTypeCode <> 1
	)
	SELECT
		CONCAT(y.Description, ' ', m.MonthName) AS YearPeriod,
		vd.StartOn,
		vd.InvoicedOn,
		vd.InvoiceNumber,
		vd.InvoiceType,
		vd.InvoiceTypeCode,
		vd.TaxCode,
		vd.InvoiceValue,
		vd.TaxValue,
		vd.TaxRate,
		vd.ExportTypeCode,
		vd.IdentityCode,
		vd.ItemDescription,
		vd.vatDueSales,
		vd.vatDueAcquisitions,
		CAST(vd.vatDueSales + vd.vatDueAcquisitions AS decimal(18,5)) AS totalVatDue,
		CAST(vd.vatReclaimedCurrPeriod + vd.vatDueAcquisitions AS decimal(18,5)) AS vatReclaimedCurrPeriod,
		CAST(vd.vatDueSales + vd.vatDueAcquisitions + vd.vatReclaimedCurrPeriod AS decimal(18,5)) AS netVatDue,
		vd.totalValueSalesExVAT,
		vd.totalValuePurchasesExVAT,
		vd.totalValueGoodsSuppliedExVAT,
		vd.totalValueGoodsReceivedExVAT
	FROM vat_dataset AS vd
		INNER JOIN App.tbYearPeriod AS yp
			ON vd.StartOn = yp.StartOn
		INNER JOIN App.tbYear AS y
			ON yp.YearNumber = y.YearNumber
		INNER JOIN App.tbMonth AS m
			ON yp.MonthNumber = m.MonthNumber;
GO
