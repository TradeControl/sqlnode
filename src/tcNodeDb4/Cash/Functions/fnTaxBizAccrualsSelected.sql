/*
    Selects one Project business-tax accrual provider for the node while
    preserving the established five-column statement/audit contract.

    UK companies consume deterministic marginal-relief Project deltas. Other
    regimes retain the configured period-rate fallback over the same canonical
    uninvoiced Profit-root order book.
*/
CREATE FUNCTION Cash.fnTaxBizAccrualsSelected()
RETURNS @Accruals TABLE
(
    StartOn datetime NOT NULL,
    ProjectCode nvarchar(20) NOT NULL,
    QuantityRemaining decimal(18,4) NULL,
    OrderValue decimal(38,5) NULL,
    TaxDue decimal(38,5) NULL
)
AS
BEGIN
    DECLARE @JurisdictionCode nvarchar(10);

    SELECT @JurisdictionCode = options.JurisdictionCode
    FROM App.tbOptions options;

    IF @JurisdictionCode = N'UK' AND Cash.fnGetBizTaxType() = 0
    BEGIN
        INSERT @Accruals
        (
            StartOn, ProjectCode, QuantityRemaining, OrderValue, TaxDue
        )
        SELECT CONVERT(datetime, accrual.StartOn),
               accrual.ProjectCode,
               accrual.QuantityRemaining,
               accrual.OrderValue,
               accrual.TaxDue
        FROM Cash.vwTaxCorpOrderBookAccrualUK accrual
        WHERE accrual.IsAccrualReady = 1
          AND accrual.TaxDue IS NOT NULL;
    END
    ELSE
    BEGIN
        INSERT @Accruals
        (
            StartOn, ProjectCode, QuantityRemaining, OrderValue, TaxDue
        )
        SELECT order_book.StartOn,
               order_book.ProjectCode,
               order_book.QuantityRemaining,
               order_book.OrderValue,
               TaxDue = CONVERT(decimal(38,5),
                   order_book.OrderValue * period.BusinessTaxRate)
        FROM Cash.vwTaxBizOrderBook order_book
        JOIN App.tbYearPeriod period
          ON period.YearNumber = order_book.YearNumber
         AND period.StartOn = order_book.StartOn;
    END;

    RETURN;
END;
GO
