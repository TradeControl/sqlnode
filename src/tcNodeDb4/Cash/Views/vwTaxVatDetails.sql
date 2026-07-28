CREATE VIEW Cash.vwTaxVatDetails
AS
SELECT
	App.tbYearPeriod.YearNumber,
	App.tbYear.Description,
	CONCAT(App.tbMonth.MonthName, SPACE(1), YEAR(App.tbYearPeriod.StartOn)) AS PeriodName,
	Cash.vwTaxVatSummary.StartOn,
	Cash.vwTaxVatSummary.TaxCode,
	Cash.vwTaxVatSummary.vatDueSales,
	Cash.vwTaxVatSummary.vatDueAcquisitions,
	CAST(Cash.vwTaxVatSummary.vatDueSales + Cash.vwTaxVatSummary.vatDueAcquisitions AS decimal(18,5)) AS totalVatDue,
	CAST(Cash.vwTaxVatSummary.vatReclaimedCurrPeriod + Cash.vwTaxVatSummary.vatDueAcquisitions AS decimal(18,5)) AS vatReclaimedCurrPeriod,
	CAST(Cash.vwTaxVatSummary.vatDueSales + Cash.vwTaxVatSummary.vatDueAcquisitions + Cash.vwTaxVatSummary.vatReclaimedCurrPeriod AS decimal(18,5)) AS netVatDue,
	Cash.vwTaxVatSummary.totalValueSalesExVAT,
	Cash.vwTaxVatSummary.totalValuePurchasesExVAT,
	Cash.vwTaxVatSummary.totalValueGoodsSuppliedExVAT,
	Cash.vwTaxVatSummary.totalValueGoodsReceivedExVAT
FROM Cash.vwTaxVatSummary
	INNER JOIN App.tbYearPeriod
		INNER JOIN App.tbMonth ON App.tbYearPeriod.MonthNumber = App.tbMonth.MonthNumber
			ON Cash.vwTaxVatSummary.StartOn = App.tbYearPeriod.StartOn
	INNER JOIN App.tbYear ON App.tbYearPeriod.YearNumber = App.tbYear.YearNumber;
