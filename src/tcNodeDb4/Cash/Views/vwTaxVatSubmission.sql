

CREATE   VIEW [Cash].[vwTaxVatSubmission]
AS
WITH vat_dates AS
(
    SELECT
        PayFrom,
        PayTo
    FROM Cash.fnTaxTypeDueDates(1, 0)
),
vatPeriod AS
(
    SELECT
        p.StartOn,
        (
            SELECT PayTo
            FROM vat_dates
            WHERE p.StartOn >= PayFrom
              AND p.StartOn < PayTo
        ) AS VatEndOn,
        y.YearNumber,
        p.MonthNumber,
        p.VatAdjustment
    FROM App.tbYearPeriod AS p
        JOIN App.tbYear AS y
            ON p.YearNumber = y.YearNumber
    WHERE y.CashStatusCode IN (1, 2)
),
vat_results AS
(
    SELECT
        VatEndOn,
        SUM(vatDueSales) AS vatDueSales,
        SUM(vatDueAcquisitions) AS vatDueAcquisitions,
        SUM(vatReclaimedCurrPeriod) AS vatReclaimedCurrPeriod,
        SUM(totalValueSalesExVAT) AS totalValueSalesExVAT,
        SUM(totalValuePurchasesExVAT) AS totalValuePurchasesExVAT,
		SUM(vatCodeDue.vatAdjustment) AS vatAdjustment,
		SUM(vatCodeDue.netVatDue) AS netVatDue
    FROM Cash.vwTaxVatSummary AS vatCodeDue
        JOIN vatPeriod
            ON vatCodeDue.StartOn = vatPeriod.StartOn
    GROUP BY
        VatEndOn
)
SELECT
    active_year.YearNumber,
    active_year.Description,
    active_month.MonthName AS Period,
    year_period.StartOn,
    DATEADD(DAY, -DATEPART(DAY, year_period.StartOn), DATEADD(MONTH, 1, year_period.StartOn)) AS VatEndOn,
    CAST(vat_results.vatDueSales AS decimal(18, 5)) AS vatDueSales,
    CAST(vat_results.vatDueAcquisitions AS decimal(18, 5)) AS vatDueAcquisitions,
    CAST(vat_results.vatDueSales + vat_results.vatDueAcquisitions + vat_results.VatAdjustment AS decimal(18, 5)) AS totalVatDue,
    CAST(vat_results.vatReclaimedCurrPeriod + vat_results.vatDueAcquisitions AS decimal(18, 5)) AS vatReclaimedCurrPeriod,
    CAST(vat_results.netVatDue AS decimal(18, 5)) AS netVatDue,
    CAST(vat_results.totalValueSalesExVAT AS decimal(18, 5)) AS totalValueSalesExVAT,
    CAST(vat_results.totalValuePurchasesExVAT AS decimal(18, 5)) AS totalValuePurchasesExVAT,
    CAST(0 AS decimal(18, 5)) AS totalValueGoodsSuppliedExVAT,
    CAST(0 AS decimal(18, 5)) AS totalValueGoodsReceivedExVAT
FROM vat_results
    JOIN App.tbYearPeriod AS year_period
        ON vat_results.VatEndOn = year_period.StartOn
    JOIN App.tbMonth AS active_month
        ON year_period.MonthNumber = active_month.MonthNumber
    JOIN App.tbYear AS active_year
        ON year_period.YearNumber = active_year.YearNumber;
GO
