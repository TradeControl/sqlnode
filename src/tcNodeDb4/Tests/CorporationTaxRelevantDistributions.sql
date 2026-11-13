/*
    Corporation Tax relevant-distributions acceptance fixture.
    Supports both generator modes:
      @EnableDividends = 0 gives the permanent zero-D control;
      @EnableDividends = 1 gives deterministic positive-D closed years.
*/
SET NOCOUNT ON;

IF NOT EXISTS
(
    SELECT 1
    FROM Cash.tbCategoryRoot root
    JOIN App.tbOptions options ON options.CategoryVersionId = root.VersionId
    WHERE root.RootTypeCode = 2
      AND root.CategoryCode = N'CT-DIST'
)
    THROW 51320, 'The active Category Tree has no Relevant Distributions root.', 1;

IF NOT EXISTS
(
    SELECT 1
    FROM Cash.vwTaxTagCashCode
    WHERE TaxSourceCode = N'UK-CO-CT-2026'
      AND TagCode = N'RelevantDistributions'
      AND MappingRoot = N'CT-DIST'
      AND CashCode = N'CC-DIVRC'
)
    THROW 51321, 'Relevant distributions do not resolve from CT-DIST to CC-DIVRC.', 1;

IF EXISTS (SELECT 1 FROM App.vwTaxVatCashCodes WHERE CashCode = N'CC-DIVRC')
    THROW 51322, 'Received dividends were incorrectly included in the VAT mapping.', 1;

DECLARE @Results TABLE
(
    YearNumber smallint NOT NULL,
    PeriodStart date NOT NULL,
    PeriodEnd date NOT NULL,
    AccountingResult decimal(28,5) NOT NULL,
    RelevantDistributions decimal(28,5) NOT NULL,
    PostedDividendReceipts decimal(28,5) NOT NULL,
    TaxableTotalProfits decimal(28,5) NOT NULL,
    AugmentedProfits decimal(28,5) NOT NULL,
    CorporationTaxChargeable decimal(28,5) NOT NULL,
    ZeroDistributionCharge decimal(28,5) NOT NULL
);

INSERT INTO @Results
(
    YearNumber, PeriodStart, PeriodEnd, AccountingResult,
    RelevantDistributions, PostedDividendReceipts,
    TaxableTotalProfits, AugmentedProfits,
    CorporationTaxChargeable, ZeroDistributionCharge
)
SELECT
    computation.YearNumber,
    CONVERT(date, computation.PeriodStart),
    CONVERT(date, computation.PeriodEnd),
    computation.TaxableResult,
    distribution.StatutoryAmount,
    payments.PostedDividendReceipts,
    computation.TaxableResult - distribution.StatutoryAmount,
    positiveKernel.AugmentedProfits,
    positiveKernel.CorporationTaxChargeable,
    zeroKernel.CorporationTaxChargeable
FROM Cash.vwTaxBizComputationByYear computation
CROSS APPLY Cash.fnTaxBizCumulative
(
    N'UK-CO-CT-2026',
    CONVERT(date, computation.PeriodStart),
    DATEADD(day, 1, CONVERT(date, computation.PeriodEnd))
) distribution
CROSS APPLY
(
    SELECT PostedDividendReceipts = CONVERT(decimal(28,5), COALESCE(SUM(payment.PaidInValue), 0))
    FROM Cash.tbPayment payment
    WHERE payment.PaymentStatusCode = 1
      AND payment.CashCode = N'CC-DIVRC'
      AND CONVERT(date, payment.PaidOn) >= CONVERT(date, computation.PeriodStart)
      AND CONVERT(date, payment.PaidOn) <= CONVERT(date, computation.PeriodEnd)
) payments
CROSS APPLY Cash.fnTaxCorpMarginalReliefUK
(
    computation.TaxableResult - distribution.StatutoryAmount,
    distribution.StatutoryAmount,
    CONVERT(date, computation.PeriodStart),
    CONVERT(date, computation.PeriodEnd),
    0, 0.25, 0.19, 50000, 250000, 0.015
) positiveKernel
CROSS APPLY Cash.fnTaxCorpMarginalReliefUK
(
    computation.TaxableResult - distribution.StatutoryAmount,
    0,
    CONVERT(date, computation.PeriodStart),
    CONVERT(date, computation.PeriodEnd),
    0, 0.25, 0.19, 50000, 250000, 0.015
) zeroKernel
WHERE distribution.TagCode = N'RelevantDistributions';

IF EXISTS
(
    SELECT 1 FROM @Results
    WHERE RelevantDistributions <> PostedDividendReceipts
)
    THROW 51323, 'D does not reconcile to posted CC-DIVRC receipts.', 1;

IF EXISTS
(
    SELECT 1 FROM @Results
    WHERE AugmentedProfits <> TaxableTotalProfits + RelevantDistributions
       OR AugmentedProfits <> AccountingResult
)
    THROW 51324, 'N, D and A do not reconcile to the accounting result.', 1;

IF EXISTS
(
    SELECT 1 FROM Cash.tbPayment
    WHERE CashCode = N'CC-DIVRC'
      AND (TaxCode <> N'T0' OR PaidOutValue <> 0 OR PaidInValue <= 0)
)
    THROW 51325, 'A dividend receipt has invalid VAT treatment or payment polarity.', 1;

IF EXISTS (SELECT 1 FROM @Results WHERE RelevantDistributions > 0)
   AND NOT EXISTS
   (
       SELECT 1 FROM @Results
       WHERE RelevantDistributions > 0
         AND CorporationTaxChargeable <> ZeroDistributionCharge
   )
    THROW 51326, 'Positive D did not affect the marginal-relief result.', 1;

SELECT * FROM @Results ORDER BY YearNumber;
PRINT 'Corporation Tax relevant-distributions fixture passed.';
