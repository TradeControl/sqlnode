CREATE PROCEDURE App.proc_DatasetSyntheticMIS_SoleTraderPersonalTaxRate
(
	@IsCompany bit
)
AS
	SET NOCOUNT, XACT_ABORT ON;

	IF @IsCompany <> 0
		RETURN;

	-- Annual profit is derived from the same net profit basis as business-tax totals.
	-- A calculated effective rate is evidence only when profit is positive. Loss,
	-- break-even and empty forecast years retain the latest non-zero planning rate,
	-- falling back to the expected-profit rate established by BasicSetup.
	;WITH yearly_profit AS
	(
		SELECT
			yp.YearNumber,
			AnnualProfit = CAST(SUM(COALESCE(ct.NetProfit, 0)) AS decimal(18, 2))
		FROM App.tbYearPeriod yp
			LEFT JOIN Cash.vwTaxBizTotalsByPeriod ct
				ON ct.StartOn = yp.StartOn
		GROUP BY yp.YearNumber
	),
	yearly_rate AS
	(
		SELECT
			YearNumber,
			[BusinessTaxRate] = CASE WHEN AnnualProfit > 0
				THEN CAST(Cash.fnPersonalEffectiveRateCalculator(AnnualProfit) AS decimal(9, 6))
				ELSE NULL
			END
		FROM yearly_profit
	), effective_rate AS
	(
		SELECT
			yr.YearNumber,
			[BusinessTaxRate] = COALESCE
			(
				yr.BusinessTaxRate,
				(
					SELECT TOP (1) prior_rate.BusinessTaxRate
					FROM yearly_rate prior_rate
					WHERE prior_rate.YearNumber < yr.YearNumber
						AND prior_rate.BusinessTaxRate > 0
					ORDER BY prior_rate.YearNumber DESC
				),
				(
					SELECT MAX(existing.BusinessTaxRate)
					FROM App.tbYearPeriod existing
					WHERE existing.YearNumber = yr.YearNumber
						AND existing.BusinessTaxRate > 0
				)
			)
		FROM yearly_rate yr
	)
	UPDATE yp
	SET yp.[BusinessTaxRate] = er.[BusinessTaxRate]
	FROM App.tbYearPeriod yp
		JOIN effective_rate er
			ON er.YearNumber = yp.YearNumber;
GO
