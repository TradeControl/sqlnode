/*
    Synthetic MIS completed-year horizon regression.

    Run against a completed App.proc_DatasetSyntheticMIS generation. The test
    is read-only: it does not build or reset the node.
*/
SET NOCOUNT ON;

DECLARE
    @ExpectedCompletedYears smallint = 3,
    @Tolerance decimal(18, 5) = 0.10;

DECLARE @CompletedYears TABLE
(
    SequenceNumber int NOT NULL,
    YearNumber smallint NOT NULL,
    PeriodStart date NOT NULL,
    PeriodEnd date NOT NULL
);

INSERT INTO @CompletedYears (SequenceNumber, YearNumber, PeriodStart, PeriodEnd)
SELECT
    ROW_NUMBER() OVER (ORDER BY y.YearNumber),
    y.YearNumber,
    MIN(CONVERT(date, yp.StartOn)),
    EOMONTH(MAX(CONVERT(date, yp.StartOn)))
FROM App.tbYear y
JOIN App.tbYearPeriod yp ON yp.YearNumber = y.YearNumber
WHERE y.CashStatusCode = 2
GROUP BY y.YearNumber;

IF (SELECT COUNT(*) FROM @CompletedYears) <> @ExpectedCompletedYears
    THROW 51992, 'Synthetic dataset does not contain the expected number of completed years.', 1;

IF EXISTS
(
    SELECT 1
    FROM @CompletedYears current_year
    JOIN @CompletedYears prior_year
      ON prior_year.SequenceNumber = current_year.SequenceNumber - 1
    WHERE current_year.YearNumber <> prior_year.YearNumber + 1
       OR current_year.PeriodStart <> DATEADD(day, 1, prior_year.PeriodEnd)
)
    THROW 51993, 'Synthetic completed years are not consecutive.', 1;

IF EXISTS
(
    SELECT 1
    FROM Cash.vwEquityReconciliationByYear bridge
    JOIN @CompletedYears completed ON completed.YearNumber = bridge.YearNumber
    WHERE ABS(bridge.Variance) > @Tolerance
)
    THROW 51994, 'Synthetic completed-year Equity Bridge exceeds tolerance.', 1;

IF EXISTS
(
    SELECT 1
    FROM @CompletedYears completed
    CROSS APPLY Cash.fnTaxBizBalanceSheetUK(N'UK-CO-ACCTS-2026', completed.PeriodEnd) projection
    WHERE projection.ValidationStatus <> N'Ready'
)
    THROW 51995, 'A synthetic completed-year statutory balance-sheet projection is not ready.', 1;

IF NOT EXISTS
(
    SELECT 1
    FROM Object.tbFlow parent_flow
    JOIN Object.tbFlow child_flow ON child_flow.ParentCode = parent_flow.ChildCode
)
    THROW 51996, 'The synthetic dataset does not contain a multi-level Object/BOM flow.', 1;

IF NOT EXISTS
(
    SELECT 1
    FROM Project.tbFlow parent_flow
    JOIN Project.tbFlow child_flow ON child_flow.ParentProjectCode = parent_flow.ChildProjectCode
)
    THROW 51997, 'The synthetic dataset does not contain a multi-level Project flow.', 1;

IF EXISTS
(
    SELECT 1
    FROM @CompletedYears completed
    WHERE NOT EXISTS
        (SELECT 1 FROM Project.tbProject project WHERE project.ActionOn BETWEEN completed.PeriodStart AND completed.PeriodEnd)
       OR NOT EXISTS
        (SELECT 1 FROM Invoice.tbInvoice invoice WHERE invoice.InvoicedOn BETWEEN completed.PeriodStart AND completed.PeriodEnd)
       OR NOT EXISTS
        (SELECT 1 FROM Cash.tbPayment payment WHERE payment.PaidOn BETWEEN completed.PeriodStart AND completed.PeriodEnd)
)
    THROW 51998, 'A synthetic completed year is missing Project, invoice or payment activity.', 1;

SELECT
    completed.SequenceNumber,
    completed.YearNumber,
    completed.PeriodStart,
    completed.PeriodEnd,
    bridge.OpeningCapital,
    bridge.ClosingCapital,
    bridge.Profit,
    bridge.BusinessTax,
    bridge.ProfitAfterTax,
    bridge.CapitalMovement,
    bridge.CapitalDelta,
    bridge.Variance,
    Projects = (SELECT COUNT(*) FROM Project.tbProject project
        WHERE project.ActionOn BETWEEN completed.PeriodStart AND completed.PeriodEnd),
    Invoices = (SELECT COUNT(*) FROM Invoice.tbInvoice invoice
        WHERE invoice.InvoicedOn BETWEEN completed.PeriodStart AND completed.PeriodEnd),
    Payments = (SELECT COUNT(*) FROM Cash.tbPayment payment
        WHERE payment.PaidOn BETWEEN completed.PeriodStart AND completed.PeriodEnd)
FROM @CompletedYears completed
JOIN Cash.vwEquityReconciliationByYear bridge ON bridge.YearNumber = completed.YearNumber
ORDER BY completed.SequenceNumber;

SELECT
    ObjectFlows = (SELECT COUNT(*) FROM Object.tbFlow),
    MultiLevelObjectLinks =
    (
        SELECT COUNT(*)
        FROM Object.tbFlow parent_flow
        JOIN Object.tbFlow child_flow ON child_flow.ParentCode = parent_flow.ChildCode
    ),
    ProjectFlows = (SELECT COUNT(*) FROM Project.tbFlow),
    MultiLevelProjectLinks =
    (
        SELECT COUNT(*)
        FROM Project.tbFlow parent_flow
        JOIN Project.tbFlow child_flow ON child_flow.ParentProjectCode = parent_flow.ChildProjectCode
    );
