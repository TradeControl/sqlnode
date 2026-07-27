
CREATE   VIEW Cash.vwTagCashPeriodMap 
AS
--tags mapped to cash codes and due dates

	WITH tagMap AS
	(
		SELECT tm.TaxSourceCode, tm.TagCode, tm.CategoryCode ParentCode, cc.CashCode
		FROM Cash.tbTaxTagMap tm
			CROSS APPLY
			(
				SELECT cc. CashCode
				FROM Cash.fnCategoryCashCodes(tm.CategoryCode) cc
			) cc	
		WHERE tm.MapTypeCode = 0 AND IsEnabled != 0
		UNION
		SELECT tm.TaxSourceCode, tm.TagCode, cc.CashCode ParentCode, cc.CashCode
		FROM Cash.tbTaxTagMap tm
			JOIN Cash.tbCode cc
				on cc.CashCode = tm.CashCode
		WHERE tm.MapTypeCode = 1 AND tm.IsEnabled != 0 AND cc.IsEnabled != 0
	)
	SELECT tm.TaxSourceCode, tm.TagCode, tm.ParentCode, tm.CashCode, ts.PeriodFrom, ts.PeriodTo
	FROM tagMap tm
		CROSS APPLY
		(
			SELECT ts.TaxSourceCode, PayFrom PeriodFrom, PayTo PeriodTo
			FROM Cash.tbTaxTagSource ts
				CROSS APPLY
				(
					SELECT PayOn, PayFrom, PayTo 
					FROM Cash.fnTaxTypeDueDates(ts.TaxTypeCode, 0)

				) tt
			WHERE ts.TaxSourceCode = tm.TaxSourceCode
		) ts;