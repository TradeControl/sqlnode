/*
    Selects one annual business-tax provider for the node. The multi-statement
    boundary is deliberate: a UNION-based view caused SQL Server to execute
    both the UK and legacy providers even though the node context is singular.
    Each branch remains a set-based annual calculation.
*/
CREATE FUNCTION Cash.fnTaxBizComputationByYearSelected()
RETURNS @Computation TABLE
(
    YearNumber smallint NOT NULL,
    Description nvarchar(10) NOT NULL,
    PeriodStart date NOT NULL,
    PeriodEnd date NOT NULL,
    TaxableResult decimal(38,5) NULL,
    OpeningLoss decimal(38,5) NULL,
    LossCreated decimal(38,5) NULL,
    LossUsed decimal(38,5) NULL,
    ClosingLoss decimal(38,5) NULL,
    EffectiveTaxRate decimal(38,12) NULL,
    BusinessTaxAdjustment decimal(38,5) NULL,
    TaxableProfitAfterRelief decimal(38,5) NULL,
    TaxBeforeRelief decimal(38,5) NULL,
    TaxReliefApplied decimal(38,5) NULL,
    TaxDue decimal(38,5) NULL,
    JurisdictionCode nvarchar(10) NULL,
    TaxSourceCode nvarchar(20) NULL,
    ReportingProfileCode nvarchar(20) NULL,
    CalculationCode nvarchar(40) NULL,
    FindingCode nvarchar(40) NULL,
    IsAccrualReady bit NOT NULL,
    IsFilingReady bit NOT NULL
)
AS
BEGIN
    DECLARE @JurisdictionCode nvarchar(10);

    SELECT @JurisdictionCode = options.JurisdictionCode
    FROM App.tbOptions options;

    IF @JurisdictionCode = N'UK' AND Cash.fnGetBizTaxType() = 0
    BEGIN
        INSERT @Computation
        (
            YearNumber, Description, PeriodStart, PeriodEnd, TaxableResult,
            OpeningLoss, LossCreated, LossUsed, ClosingLoss, EffectiveTaxRate,
            BusinessTaxAdjustment, TaxableProfitAfterRelief, TaxBeforeRelief,
            TaxReliefApplied, TaxDue, JurisdictionCode, TaxSourceCode,
            ReportingProfileCode, CalculationCode, FindingCode,
            IsAccrualReady, IsFilingReady
        )
        SELECT projection.YearNumber,
               projection.Description,
               projection.PeriodStart,
               projection.PeriodEnd,
               TaxableResult = projection.AccountingResult,
               projection.OpeningLoss,
               projection.LossCreated,
               projection.LossUsed,
               projection.ClosingLoss,
               EffectiveTaxRate = CONVERT(decimal(38,12), CASE
                   WHEN projection.TaxableTotalProfits = 0 THEN 0
                   ELSE projection.CorporationTaxChargeable / projection.TaxableTotalProfits END),
               projection.BusinessTaxAdjustment,
               TaxableProfitAfterRelief = projection.TaxableTotalProfits,
               TaxBeforeRelief = CONVERT(decimal(38,5),
                   projection.TaxBeforeMarginalRelief + projection.BusinessTaxAdjustment),
               TaxReliefApplied = CONVERT(decimal(38,5), projection.MarginalRelief * -1),
               projection.TaxDue,
               projection.JurisdictionCode,
               projection.TaxSourceCode,
               projection.ReportingProfileCode,
               projection.CalculationCode,
               FindingCode = COALESCE(projection.RateFindingCode,
                   projection.ProfileFindingCode, projection.KernelFindingCode),
               projection.IsAccrualReady,
               projection.IsFilingReady
        FROM Cash.vwTaxCorpLiabilityUK projection;
    END
    ELSE
    BEGIN
        WITH year_source AS
        (
            SELECT year_definition.YearNumber,
                   year_definition.Description,
                   PeriodStart = CONVERT(date, MIN(period.StartOn)),
                   PeriodEnd = CONVERT(date,
                       DATEADD(day, -1, DATEADD(month, 1, MAX(period.StartOn)))),
                   TaxableResult = CONVERT(decimal(38,5),
                       SUM(COALESCE(totals.NetProfit, 0))),
                   BusinessTaxAdjustment = CONVERT(decimal(38,5),
                       SUM(period.BusinessTaxAdjustment)),
                   EffectiveTaxRate = CONVERT(decimal(38,12),
                       CONVERT(decimal(28,12),
                           SUM(CONVERT(decimal(19,12), period.BusinessTaxRate)
                               * DATEDIFF(day, period.StartOn,
                                   DATEADD(month, 1, period.StartOn))))
                       / NULLIF(CONVERT(decimal(10,0),
                           SUM(DATEDIFF(day, period.StartOn,
                               DATEADD(month, 1, period.StartOn)))), 0))
            FROM App.tbYear year_definition
            JOIN App.tbYearPeriod period
              ON period.YearNumber = year_definition.YearNumber
            LEFT JOIN Cash.vwTaxBizTotalsByPeriod totals
              ON totals.StartOn = period.StartOn
            GROUP BY year_definition.YearNumber, year_definition.Description
        ), ordered AS
        (
            SELECT *, SequenceNumber = ROW_NUMBER() OVER (ORDER BY YearNumber)
            FROM year_source
        ), tax_rollup AS
        (
            SELECT source.SequenceNumber,
                   source.YearNumber,
                   source.Description,
                   source.PeriodStart,
                   source.PeriodEnd,
                   source.TaxableResult,
                   source.BusinessTaxAdjustment,
                   source.EffectiveTaxRate,
                   OpeningLoss = CONVERT(decimal(38,5), 0),
                   LossCreated = CONVERT(decimal(38,5), CASE
                       WHEN source.TaxableResult < 0 THEN -source.TaxableResult ELSE 0 END),
                   LossUsed = CONVERT(decimal(38,5), 0),
                   ClosingLoss = CONVERT(decimal(38,5), CASE
                       WHEN source.TaxableResult < 0 THEN -source.TaxableResult ELSE 0 END),
                   TaxableProfitAfterRelief = CONVERT(decimal(38,5), CASE
                       WHEN source.TaxableResult > 0 THEN source.TaxableResult ELSE 0 END)
            FROM ordered source
            WHERE source.SequenceNumber = 1

            UNION ALL

            SELECT source.SequenceNumber,
                   source.YearNumber,
                   source.Description,
                   source.PeriodStart,
                   source.PeriodEnd,
                   source.TaxableResult,
                   source.BusinessTaxAdjustment,
                   source.EffectiveTaxRate,
                   OpeningLoss = CONVERT(decimal(38,5), prior.ClosingLoss),
                   LossCreated = CONVERT(decimal(38,5), CASE
                       WHEN source.TaxableResult < 0 THEN -source.TaxableResult ELSE 0 END),
                   LossUsed = CONVERT(decimal(38,5), CASE
                       WHEN source.TaxableResult <= 0 THEN 0
                       WHEN prior.ClosingLoss < source.TaxableResult THEN prior.ClosingLoss
                       ELSE source.TaxableResult END),
                   ClosingLoss = CONVERT(decimal(38,5), CASE
                       WHEN source.TaxableResult < 0
                       THEN prior.ClosingLoss - source.TaxableResult
                       WHEN prior.ClosingLoss > source.TaxableResult
                       THEN prior.ClosingLoss - source.TaxableResult
                       ELSE 0 END),
                   TaxableProfitAfterRelief = CONVERT(decimal(38,5), CASE
                       WHEN source.TaxableResult > prior.ClosingLoss
                       THEN source.TaxableResult - prior.ClosingLoss ELSE 0 END)
            FROM tax_rollup prior
            JOIN ordered source
              ON source.SequenceNumber = prior.SequenceNumber + 1
        ), computed AS
        (
            SELECT *,
                   TaxBeforeRelief = CONVERT(decimal(38,5), ROUND(
                       CASE WHEN TaxableResult > 0 THEN TaxableResult ELSE 0 END
                           * EffectiveTaxRate + BusinessTaxAdjustment, 5)),
                   TaxDue = CONVERT(decimal(38,5), ROUND(
                       TaxableProfitAfterRelief * EffectiveTaxRate
                           + BusinessTaxAdjustment, 5))
            FROM tax_rollup
        )
        INSERT @Computation
        (
            YearNumber, Description, PeriodStart, PeriodEnd, TaxableResult,
            OpeningLoss, LossCreated, LossUsed, ClosingLoss, EffectiveTaxRate,
            BusinessTaxAdjustment, TaxableProfitAfterRelief, TaxBeforeRelief,
            TaxReliefApplied, TaxDue, JurisdictionCode, TaxSourceCode,
            ReportingProfileCode, CalculationCode, FindingCode,
            IsAccrualReady, IsFilingReady
        )
        SELECT computed.YearNumber,
               computed.Description,
               computed.PeriodStart,
               computed.PeriodEnd,
               computed.TaxableResult,
               computed.OpeningLoss,
               computed.LossCreated,
               computed.LossUsed,
               computed.ClosingLoss,
               computed.EffectiveTaxRate,
               computed.BusinessTaxAdjustment,
               computed.TaxableProfitAfterRelief,
               computed.TaxBeforeRelief,
               TaxReliefApplied = CONVERT(decimal(38,5),
                   computed.TaxDue - computed.TaxBeforeRelief),
               computed.TaxDue,
               @JurisdictionCode,
               TaxSourceCode = CONVERT(nvarchar(20), NULL),
               ReportingProfileCode = CONVERT(nvarchar(20), NULL),
               CalculationCode = CONVERT(nvarchar(40), N'LEGACY-FLAT-RATE'),
               FindingCode = CONVERT(nvarchar(40), NULL),
               IsAccrualReady = CONVERT(bit, 1),
               IsFilingReady = CONVERT(bit, 0)
        FROM computed;
    END;

    RETURN;
END;
GO
