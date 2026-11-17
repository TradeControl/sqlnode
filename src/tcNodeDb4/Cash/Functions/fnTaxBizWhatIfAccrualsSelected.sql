/*
    Selects the current node's business-tax provider for What-if Projects.
    UK companies consume the marginal-relief scenario delta. Other regimes
    retain the configured period-rate fallback over the same scenario facts.
*/
CREATE FUNCTION Cash.fnTaxBizWhatIfAccrualsSelected()
RETURNS @Accruals TABLE
(
    StartOn datetime NOT NULL,
    TaxDue decimal(38,5) NULL
)
AS
BEGIN
    DECLARE @JurisdictionCode nvarchar(10);

    SELECT @JurisdictionCode = options.JurisdictionCode
    FROM App.tbOptions options;

    IF @JurisdictionCode = N'UK' AND Cash.fnGetBizTaxType() = 0
    BEGIN
        INSERT @Accruals (StartOn, TaxDue)
        SELECT CONVERT(datetime, liability.PeriodStart),
               liability.ScenarioTaxAccrual
        FROM Cash.vwTaxCorpWhatIfLiabilityUK liability
        WHERE liability.IsAccrualReady = 1
          AND liability.ScenarioTaxAccrual IS NOT NULL
          AND liability.ScenarioTaxAccrual <> 0;
    END
    ELSE
    BEGIN
        INSERT @Accruals (StartOn, TaxDue)
        SELECT scenario.StartOn,
               TaxDue = CONVERT(decimal(38,5),
                   SUM(scenario.OrderValue) * period.BusinessTaxRate)
        FROM Cash.vwTaxBizWhatIfOrderBook scenario
        JOIN App.tbYearPeriod period
          ON period.YearNumber = scenario.YearNumber
         AND period.StartOn = scenario.StartOn
        GROUP BY scenario.StartOn, period.BusinessTaxRate;
    END;

    RETURN;
END;
GO
