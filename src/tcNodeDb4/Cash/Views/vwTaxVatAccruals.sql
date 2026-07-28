CREATE VIEW Cash.vwTaxVatAccruals
AS
	WITH Project_invoiced_quantity AS
	(
		SELECT
			ip.ProjectCode,
			SUM(ip.Quantity) AS InvoiceQuantity
		FROM Invoice.tbProject AS ip
			INNER JOIN Invoice.tbInvoice AS i
				ON ip.InvoiceNumber = i.InvoiceNumber
		WHERE i.InvoiceTypeCode IN (0, 2)
		GROUP BY
			ip.ProjectCode
	),
	Project_transactions AS
	(
		SELECT
			(
				SELECT TOP (1) yp.StartOn
				FROM App.tbYearPeriod AS yp
				WHERE yp.StartOn <= p.ActionOn
				ORDER BY yp.StartOn DESC
			) AS StartOn,
			p.ProjectCode,
			p.TaxCode,
			p.Quantity - ISNULL(iq.InvoiceQuantity, 0) AS QuantityRemaining,
			p.UnitCharge * (p.Quantity - ISNULL(iq.InvoiceQuantity, 0)) AS TotalValue,
			p.UnitCharge * (p.Quantity - ISNULL(iq.InvoiceQuantity, 0)) * tc.TaxRate AS TaxValue,
			tc.TaxRate,
			ISNULL(s.ExportTypeCode, 0) AS ExportTypeCode,
			cat.CashPolarityCode
		FROM Project.tbProject AS p
			INNER JOIN Subject.tbSubject AS s
				ON p.SubjectCode = s.SubjectCode
			INNER JOIN Cash.tbCode AS c
				ON p.CashCode = c.CashCode
			INNER JOIN Cash.tbCategory AS cat
				ON c.CategoryCode = cat.CategoryCode
			INNER JOIN App.tbTaxCode AS tc
				ON p.TaxCode = tc.TaxCode
			LEFT OUTER JOIN Project_invoiced_quantity AS iq
				ON p.ProjectCode = iq.ProjectCode
		WHERE tc.TaxTypeCode = 1
			AND p.ProjectStatusCode > 0
			AND p.ProjectStatusCode < 3
			AND p.ActionOn <= (SELECT DATEADD(DAY, TaxHorizon, CURRENT_TIMESTAMP) FROM App.tbOptions)
			AND ISNULL(s.ExportTypeCode, 0) <> 1
	)
	SELECT
		pt.StartOn,
		pt.ProjectCode,
		pt.TaxCode,
		pt.TaxRate,
		pt.TotalValue,
		pt.TaxValue,
		pt.QuantityRemaining,
		CAST
		(
			CASE
				WHEN pt.ExportTypeCode IN (0, 2) AND pt.CashPolarityCode = 1 THEN pt.TaxValue
				ELSE 0
			END
			AS decimal(18,5)
		) AS vatDueSales,
		CAST
		(
			CASE
				WHEN pt.ExportTypeCode = 2 AND pt.CashPolarityCode = 0 THEN pt.TaxValue * -1
				ELSE 0
			END
			AS decimal(18,5)
		) AS vatDueAcquisitions,
		CAST
		(
			CASE
				WHEN pt.ExportTypeCode = 0 AND pt.CashPolarityCode = 0 THEN pt.TaxValue * -1
				ELSE 0
			END
			AS decimal(18,5)
		) AS vatReclaimedCurrPeriod,
		CAST
		(
			CASE
				WHEN pt.ExportTypeCode IN (0, 2) AND pt.CashPolarityCode = 1 THEN pt.TotalValue
				ELSE 0
			END
			AS decimal(18,5)
		) AS totalValueSalesExVAT,
		CAST
		(
			CASE
				WHEN pt.ExportTypeCode IN (0, 2) AND pt.CashPolarityCode = 0 THEN pt.TotalValue
				ELSE 0
			END
			AS decimal(18,5)
		) AS totalValuePurchasesExVAT,
		CAST(0 AS decimal(18,5)) AS totalValueGoodsSuppliedExVAT,
		CAST(0 AS decimal(18,5)) AS totalValueGoodsReceivedExVAT,
		CAST
		(
			CASE
				WHEN pt.ExportTypeCode IN (0, 2) AND pt.CashPolarityCode = 1 THEN pt.TaxValue
				ELSE 0
			END
			+
			CASE
				WHEN pt.ExportTypeCode = 0 AND pt.CashPolarityCode = 0 THEN pt.TaxValue * -1
				ELSE 0
			END
			+
			CASE
				WHEN pt.ExportTypeCode = 2 AND pt.CashPolarityCode = 0 THEN pt.TaxValue * -1
				ELSE 0
			END
			AS decimal(18,5)
		) AS netVatDue
	FROM Project_transactions AS pt
		INNER JOIN App.tbYearPeriod AS yp
			ON pt.StartOn = yp.StartOn
		INNER JOIN App.tbYear AS y
			ON yp.YearNumber = y.YearNumber
		INNER JOIN App.tbMonth AS m
			ON yp.MonthNumber = m.MonthNumber;
GO
