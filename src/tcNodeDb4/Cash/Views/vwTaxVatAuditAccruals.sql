CREATE VIEW Cash.vwTaxVatAuditAccruals
AS
SELECT
	App.tbYear.YearNumber,
	CONCAT(App.tbYear.Description, ' ', App.tbMonth.MonthName) AS YearPeriod,
	vat_accruals.StartOn,
	Project.tbProject.ActionOn,
	Project.tbProject.ProjectTitle,
	Project.tbProject.ProjectCode,
	Cash.tbCode.CashCode,
	Cash.tbCode.CashDescription,
	Object.tbObject.ObjectCode,
	Project.tbStatus.ProjectStatus,
	Project.tbStatus.ProjectStatusCode,
	vat_accruals.TaxCode,
	vat_accruals.TaxRate,
	vat_accruals.TotalValue,
	vat_accruals.TaxValue,
	vat_accruals.QuantityRemaining,
	Object.tbObject.UnitOfMeasure,
	vat_accruals.vatDueSales,
	vat_accruals.vatDueAcquisitions,
	CAST(vat_accruals.vatDueSales + vat_accruals.vatDueAcquisitions AS decimal(18,5)) AS totalVatDue,
	CAST(vat_accruals.vatReclaimedCurrPeriod + vat_accruals.vatDueAcquisitions AS decimal(18,5)) AS vatReclaimedCurrPeriod,
	vat_accruals.netVatDue,
	vat_accruals.totalValueSalesExVAT,
	vat_accruals.totalValuePurchasesExVAT,
	vat_accruals.totalValueGoodsSuppliedExVAT,
	vat_accruals.totalValueGoodsReceivedExVAT
FROM Cash.vwTaxVatAccruals AS vat_accruals
	INNER JOIN App.tbYearPeriod AS year_period
		ON vat_accruals.StartOn = year_period.StartOn
	INNER JOIN App.tbYear
		ON year_period.YearNumber = App.tbYear.YearNumber
	INNER JOIN App.tbMonth
		ON year_period.MonthNumber = App.tbMonth.MonthNumber
	INNER JOIN Project.tbProject
		ON vat_accruals.ProjectCode = Project.tbProject.ProjectCode
	INNER JOIN Project.tbStatus
		ON Project.tbProject.ProjectStatusCode = Project.tbStatus.ProjectStatusCode
	INNER JOIN Subject.tbSubject
		ON Project.tbProject.SubjectCode = Subject.tbSubject.SubjectCode
	INNER JOIN Object.tbObject
		ON Project.tbProject.ObjectCode = Object.tbObject.ObjectCode
	INNER JOIN Cash.tbCode
		ON Project.tbProject.CashCode = Cash.tbCode.CashCode;
GO
