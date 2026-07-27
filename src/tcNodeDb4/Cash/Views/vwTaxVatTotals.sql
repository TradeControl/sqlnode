CREATE VIEW Cash.vwTaxVatTotals
AS
WITH vat_dates AS
(
    SELECT
        PayFrom,
        PayTo
    FROM Cash.fnTaxTypeDueDates(1, 0)
)
, 
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
        VatAdjustment
    FROM App.tbYearPeriod AS p
        JOIN App.tbYear AS y
            ON p.YearNumber = y.YearNumber
    WHERE y.CashStatusCode IN (1, 2)
)
,
vat_results AS
(
    SELECT
        VatEndOn,
        SUM(HomeSales)           AS HomeSales,
        SUM(HomePurchases)       AS HomePurchases,
        SUM(ExportSales)         AS ExportSales,
        SUM(ExportPurchases)     AS ExportPurchases,

        SUM(HomeSalesVat)        AS HomeSalesVat,
        SUM(HomePurchasesVat)    AS HomePurchasesVat,
        SUM(ExportSalesVat)      AS ExportSalesVat,
        SUM(ExportPurchasesVat)  AS ExportPurchasesVat,

        SUM(VatDue)              AS VatDue
    FROM Cash.vwTaxVatSummary AS vatCodeDue
        JOIN vatPeriod
            ON vatCodeDue.StartOn = vatPeriod.StartOn
    GROUP BY
        VatEndOn
)
,
vat_adjustments AS
(
    SELECT
        VatEndOn,
        CAST(SUM(VatAdjustment) AS decimal(18, 5)) AS VatAdjustment
    FROM vatPeriod AS p
    GROUP BY
        VatEndOn
)
SELECT
    active_year.YearNumber,
    active_year.Description,
    active_month.MonthName AS Period,

    vat_results.VatEndOn AS StartOn,
    HomeSales,
    HomePurchases,
    ExportSales,
    ExportPurchases,

    HomeSalesVat,
    HomePurchasesVat,
    ExportSalesVat,
    ExportPurchasesVat,

    vat_adjustments.VatAdjustment,
    VatDue - vat_adjustments.VatAdjustment AS VatDue

FROM vat_results
    JOIN vat_adjustments
        ON vat_results.VatEndOn = vat_adjustments.VatEndOn

    JOIN App.tbYearPeriod AS year_period
        ON vat_results.VatEndOn = year_period.StartOn

    JOIN App.tbMonth AS active_month
        ON year_period.MonthNumber = active_month.MonthNumber

    JOIN App.tbYear AS active_year
        ON year_period.YearNumber = active_year.YearNumber;
GO


