CREATE FUNCTION Cash.fnCategoryVersionUnmappedCashCodes
(
    @CategoryVersionId nvarchar(10),
    @FromYearNumber smallint,
    @ToYearNumber smallint,
    @IncludeOrderBook bit
)
RETURNS TABLE
AS
RETURN
(
    WITH statement_periods AS
    (
        SELECT StartOn,
               LEAD(StartOn, 1, DATEADD(MONTH, 1, StartOn)) OVER (ORDER BY StartOn) AS EndOn
        FROM App.tbYearPeriod
        WHERE YearNumber BETWEEN @FromYearNumber AND @ToYearNumber
    ),
    horizon AS
    (
        SELECT MIN(StartOn) AS StartOn, MAX(EndOn) AS EndOn FROM statement_periods
    ),
    candidates AS
    (
        SELECT period.CashCode
        FROM Cash.tbPeriod AS period
        JOIN App.tbYearPeriod AS year_period ON year_period.StartOn = period.StartOn
        WHERE year_period.YearNumber BETWEEN @FromYearNumber AND @ToYearNumber
          AND (period.ForecastValue <> 0 OR period.ForecastTax <> 0
            OR period.InvoiceValue <> 0 OR period.InvoiceTax <> 0)
        UNION
        SELECT item.CashCode
        FROM Invoice.tbItem AS item
        JOIN Invoice.tbInvoice AS invoice ON invoice.InvoiceNumber = item.InvoiceNumber
        CROSS JOIN horizon
        WHERE invoice.InvoicedOn >= horizon.StartOn AND invoice.InvoicedOn < horizon.EndOn
        UNION
        SELECT project.CashCode
        FROM Invoice.tbProject AS project
        JOIN Invoice.tbInvoice AS invoice ON invoice.InvoiceNumber = project.InvoiceNumber
        CROSS JOIN horizon
        WHERE invoice.InvoicedOn >= horizon.StartOn AND invoice.InvoicedOn < horizon.EndOn
        UNION
        SELECT payment.CashCode
        FROM Cash.tbPayment AS payment
        CROSS JOIN horizon
        WHERE payment.PaidOn >= horizon.StartOn AND payment.PaidOn < horizon.EndOn
        UNION
        SELECT project.CashCode
        FROM Project.tbProject AS project
        CROSS JOIN horizon
        WHERE @IncludeOrderBook <> 0
          AND project.ProjectStatusCode IN (1, 2)
          AND project.ActionOn >= horizon.StartOn AND project.ActionOn < horizon.EndOn
    )
    SELECT TOP (101) code.CashCode, code.CashDescription
    FROM candidates
    JOIN Cash.tbCode AS code ON code.CashCode = candidates.CashCode
    LEFT JOIN Cash.tbCategoryCodeMap AS category_code
      ON category_code.VersionId = @CategoryVersionId AND category_code.CashCode = candidates.CashCode
    WHERE category_code.CashCode IS NULL
    ORDER BY code.CashCode
);
