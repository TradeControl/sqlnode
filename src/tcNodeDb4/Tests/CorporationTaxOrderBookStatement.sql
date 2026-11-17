/*
    MR-4 live statement integration regression.

    Read-only: reconciles the selected Project CT accrual through its audit,
    Company Statement due-date event and Cash Statement procedure toggle.
*/
SET NOCOUNT ON;
SET XACT_ABORT ON;

IF OBJECT_ID(N'Cash.vwTaxBizAccruals', N'V') IS NULL
    THROW 51460, 'The live business-tax accrual contract is not deployed.', 1;

DECLARE @LiveTaxDue decimal(38,5) =
    (SELECT CONVERT(decimal(38,5), SUM(TaxDue)) FROM Cash.vwTaxBizAccruals);

DECLARE @AnnualTaxDue decimal(38,5) =
    (SELECT CONVERT(decimal(38,5), SUM(TaxAccrual))
     FROM Cash.vwTaxCorpOrderBookLiabilityUK);

IF @LiveTaxDue <> @AnnualTaxDue
    THROW 51461, 'The live Project CT accrual does not reconcile to the annual liability delta.', 1;

IF (SELECT CONVERT(decimal(38,5), SUM(TaxDue)) FROM Cash.vwTaxBizAuditAccruals) <> @LiveTaxDue
    THROW 51462, 'The Project CT audit does not reconcile to the live accrual contract.', 1;

DECLARE @AccrualReference nvarchar(255) =
    (SELECT CONVERT(nvarchar(255), Message) FROM App.tbText WHERE TextId = 1215);

IF
(
    SELECT CONVERT(decimal(38,5), SUM(statement.PayOut - statement.PayIn))
    FROM Cash.vwStatementBase statement
    WHERE statement.CashEntryTypeCode = 4
      AND statement.ReferenceCode = @AccrualReference
) <> @LiveTaxDue
    THROW 51463, 'The Company Statement CT accrual event does not reconcile to the live accrual.', 1;

DECLARE @TaxCashCode nvarchar(50) =
    (SELECT TOP (1) CashCode FROM Cash.tbTaxType WHERE TaxTypeCode = 0 ORDER BY CashCode);

IF @TaxCashCode IS NULL
    THROW 51464, 'The business-tax Cash Code is not configured.', 1;

DECLARE @DueYearNumber smallint;

WITH accrual_due AS
(
    SELECT accrual.StartOn,
           due.PayOn
    FROM Cash.vwTaxBizAccruals accrual
    CROSS APPLY
    (
        SELECT TOP (1) dates.PayOn
        FROM Cash.fnTaxTypeDueDates(0, 1) dates
        WHERE accrual.StartOn >= dates.PayFrom
          AND accrual.StartOn < dates.PayTo
    ) due
)
SELECT TOP (1) @DueYearNumber = period.YearNumber
FROM accrual_due due
CROSS APPLY
(
    SELECT TOP (1) year_period.YearNumber
    FROM App.tbYearPeriod year_period
    WHERE year_period.StartOn <= due.PayOn
    ORDER BY year_period.StartOn DESC
) period
GROUP BY period.YearNumber
ORDER BY period.YearNumber;

IF @DueYearNumber IS NULL
    THROW 51465, 'No Cash Statement financial year contains the projected CT due date.', 1;

CREATE TABLE #WithoutTaxAccruals
(
    StartOn datetime NOT NULL,
    InvoiceValue decimal(18,5) NOT NULL,
    InvoiceTax decimal(18,5) NOT NULL,
    ForecastValue decimal(18,5) NOT NULL,
    ForecastTax decimal(18,5) NOT NULL
);

CREATE TABLE #WithTaxAccruals
(
    StartOn datetime NOT NULL,
    InvoiceValue decimal(18,5) NOT NULL,
    InvoiceTax decimal(18,5) NOT NULL,
    ForecastValue decimal(18,5) NOT NULL,
    ForecastTax decimal(18,5) NOT NULL
);

INSERT #WithoutTaxAccruals
EXEC Cash.proc_FlowCashCodeValues
    @CashCode = @TaxCashCode,
    @YearNumber = @DueYearNumber,
    @IncludeActivePeriods = 1,
    @IncludeOrderBook = 0,
    @IncludeTaxAccruals = 0;

INSERT #WithTaxAccruals
EXEC Cash.proc_FlowCashCodeValues
    @CashCode = @TaxCashCode,
    @YearNumber = @DueYearNumber,
    @IncludeActivePeriods = 1,
    @IncludeOrderBook = 0,
    @IncludeTaxAccruals = 1;

DECLARE @CashStatementDelta decimal(38,5) =
(
    SELECT CONVERT(decimal(38,5), SUM(with_tax.InvoiceValue - without_tax.InvoiceValue))
    FROM #WithTaxAccruals with_tax
    JOIN #WithoutTaxAccruals without_tax
      ON without_tax.StartOn = with_tax.StartOn
);

DECLARE @ExpectedDueYearDelta decimal(38,5);

WITH accrual_due AS
(
    SELECT accrual.TaxDue,
           due.PayOn
    FROM Cash.vwTaxBizAccruals accrual
    CROSS APPLY
    (
        SELECT TOP (1) dates.PayOn
        FROM Cash.fnTaxTypeDueDates(0, 1) dates
        WHERE accrual.StartOn >= dates.PayFrom
          AND accrual.StartOn < dates.PayTo
    ) due
), due_year AS
(
    SELECT accrual_due.TaxDue,
           period.YearNumber
    FROM accrual_due
    CROSS APPLY
    (
        SELECT TOP (1) year_period.YearNumber
        FROM App.tbYearPeriod year_period
        WHERE year_period.StartOn <= accrual_due.PayOn
        ORDER BY year_period.StartOn DESC
    ) period
)
SELECT @ExpectedDueYearDelta = CONVERT(decimal(38,5), SUM(TaxDue))
FROM due_year
WHERE YearNumber = @DueYearNumber;

IF @CashStatementDelta <> @ExpectedDueYearDelta
    THROW 51466, 'The Cash Statement tax-accrual toggle did not add the expected CT due amount.', 1;

SELECT LiveTaxDue = @LiveTaxDue,
       CompanyStatementTaxDue =
       (
           SELECT CONVERT(decimal(38,5), SUM(statement.PayOut - statement.PayIn))
           FROM Cash.vwStatementBase statement
           WHERE statement.CashEntryTypeCode = 4
             AND statement.ReferenceCode = @AccrualReference
       ),
       CashStatementDueYear = @DueYearNumber,
       CashStatementTaxToggleDelta = @CashStatementDelta;
