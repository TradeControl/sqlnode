
CREATE VIEW [Cash].[vwTaxLossesCarriedForward]
AS
	SELECT YearEndDescription = CONCAT(computation.Description, ' ', DATENAME(month, computation.PeriodEnd)),
		StartOn = CONVERT(datetime, DATEADD(day, 1, computation.PeriodEnd)),
		TaxDue = CONVERT(decimal(18, 5), computation.TaxDue),
		TaxBalance = CONVERT(decimal(18, 5), computation.TaxDue),
		LossesCarriedForward = CONVERT(decimal(18, 5), computation.ClosingLoss)
	FROM Cash.vwTaxBizComputationByYear computation;
