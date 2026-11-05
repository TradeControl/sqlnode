CREATE VIEW Cash.vwEquityReconciliationByYear
AS
	SELECT eb.YearNumber,
		eb.Description,
		eb.OpeningCapital,
		eb.ClosingCapital,
		eb.Profit,
		eb.BusinessTax,
		eb.ProfitAfterTax,
		eb.TaxCarry,
		eb.CapitalMovement,
		eb.OpeningSubjectPosition,
		eb.OpeningAccountPosition,
		eb.OpeningLossesCarriedForward,
		eb.ClosingLossesCarriedForward,
		eb.LossesCarriedForwardDelta,
		eb.CapitalDelta,
		eb.Variance
	FROM App.tbOptions AS opt
	CROSS APPLY Cash.fnEquityReconciliationByYearByVersion(opt.CategoryVersionId) AS eb;
