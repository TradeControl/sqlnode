CREATE FUNCTION Cash.fnTaxTagMapValidate
(
    @TaxSourceCode NVARCHAR(20)
)
RETURNS @Result TABLE
(
    IsError BIT NOT NULL,
    TagCode NVARCHAR(64) NULL,
    TagName NVARCHAR(100) NULL,
    CashCode NVARCHAR(50) NULL,
    CategoryCode NVARCHAR(10) NULL,
    HitCount INT NULL,
    Message NVARCHAR(4000) NOT NULL
)
AS
BEGIN
    DECLARE @Detailed TABLE (TagCode NVARCHAR(64) PRIMARY KEY);
    INSERT INTO @Detailed VALUES
        ('costOfGoods'), ('paymentsToSubcontractors'), ('wagesAndStaffCosts'),
        ('carVanTravelExpenses'), ('premisesRunningCosts'), ('maintenanceCosts'),
        ('adminCosts'), ('advertisingCosts'), ('businessEntertainmentCosts'),
        ('interestOnBankOtherLoans'), ('financeCharges'), ('professionalFees'), ('otherExpenses');
    DECLARE @Manifest TABLE (TagCode NVARCHAR(64) PRIMARY KEY, StatutoryPolarityCode SMALLINT NOT NULL);
    INSERT INTO @Manifest VALUES
        ('turnover', 1), ('otherBusinessIncome', 1), ('consolidatedExpenses', 0),
        ('costOfGoods', 0), ('paymentsToSubcontractors', 0), ('wagesAndStaffCosts', 0),
        ('carVanTravelExpenses', 0), ('premisesRunningCosts', 0), ('maintenanceCosts', 0),
        ('adminCosts', 0), ('advertisingCosts', 0), ('businessEntertainmentCosts', 0),
        ('interestOnBankOtherLoans', 0), ('financeCharges', 0), ('professionalFees', 0),
        ('otherExpenses', 0);

    INSERT INTO @Result
    SELECT 1, tm.TagCode, t.TagName, NULL, tm.CategoryCode, NULL,
           N'Mapped category does not exist or resolves to no enabled non-neutral nominal CashCode.'
    FROM Cash.tbTaxTagMap tm
    LEFT JOIN Cash.tbTaxTag t ON t.TaxSourceCode = tm.TaxSourceCode AND t.TagCode = tm.TagCode
    WHERE tm.TaxSourceCode = @TaxSourceCode AND tm.IsEnabled = 1 AND tm.MapTypeCode = 0
      AND NOT EXISTS
      (
          SELECT 1 FROM Cash.vwTaxTagCashCode ec
          WHERE ec.TaxSourceCode = tm.TaxSourceCode AND ec.TagCode = tm.TagCode
            AND ec.MapTypeCode = tm.MapTypeCode AND ec.MappingRoot = tm.CategoryCode
      );

    INSERT INTO @Result
    SELECT 1, tm.TagCode, t.TagName, tm.CashCode, NULL, NULL,
           N'Mapped CashCode does not exist or is not an enabled non-neutral nominal leaf.'
    FROM Cash.tbTaxTagMap tm
    LEFT JOIN Cash.tbTaxTag t ON t.TaxSourceCode = tm.TaxSourceCode AND t.TagCode = tm.TagCode
    WHERE tm.TaxSourceCode = @TaxSourceCode AND tm.IsEnabled = 1 AND tm.MapTypeCode = 1
      AND NOT EXISTS
      (
          SELECT 1 FROM Cash.vwTaxTagCashCode ec
          WHERE ec.TaxSourceCode = tm.TaxSourceCode AND ec.TagCode = tm.TagCode
            AND ec.MapTypeCode = tm.MapTypeCode AND ec.MappingRoot = tm.CashCode
      );

    INSERT INTO @Result
    SELECT 1, ec.TagCode, t.TagName, ec.CashCode, ec.LeafCategoryCode, COUNT(*),
           N'CashCode is included multiple times in this tag through overlapping mapping roots.'
    FROM Cash.vwTaxTagCashCode ec
    JOIN Cash.tbTaxTag t ON t.TaxSourceCode = ec.TaxSourceCode AND t.TagCode = ec.TagCode
    WHERE ec.TaxSourceCode = @TaxSourceCode
    GROUP BY ec.TagCode, t.TagName, ec.CashCode, ec.LeafCategoryCode
    HAVING COUNT(*) > 1;

    INSERT INTO @Result
    SELECT 1, MIN(ec.TagCode), NULL, ec.CashCode, ec.LeafCategoryCode,
           COUNT(DISTINCT ec.TagCode),
           N'CashCode contributes to more than one mutually exclusive cumulative Tax Tag.'
    FROM Cash.vwTaxTagCashCode ec
    WHERE ec.TaxSourceCode = @TaxSourceCode
      AND @TaxSourceCode = 'UK-ITSA-SE-CUM'
    GROUP BY ec.CashCode, ec.LeafCategoryCode
    HAVING COUNT(DISTINCT ec.TagCode) > 1;

    INSERT INTO @Result
    SELECT 1, ec.TagCode, t.TagName, ec.CashCode, ec.LeafCategoryCode, NULL,
           N'Contributor polarity is neutral, null, or does not match the Tax Tag statutory orientation.'
    FROM Cash.vwTaxTagCashCode ec
    JOIN Cash.tbTaxTag t ON t.TaxSourceCode = ec.TaxSourceCode AND t.TagCode = ec.TagCode
    WHERE ec.TaxSourceCode = @TaxSourceCode
      AND @TaxSourceCode = 'UK-ITSA-SE-CUM'
      AND (ec.CashPolarityCode IS NULL OR ec.CashPolarityCode = 2
           OR ec.CashPolarityCode <> t.StatutoryPolarityCode);

    IF @TaxSourceCode = 'UK-ITSA-SE-CUM'
    BEGIN
        IF EXISTS
           (
               SELECT m.TagCode, m.StatutoryPolarityCode FROM @Manifest m
               EXCEPT
               SELECT t.TagCode, t.StatutoryPolarityCode FROM Cash.tbTaxTag t
               WHERE t.TaxSourceCode = @TaxSourceCode
           )
           OR EXISTS
           (
               SELECT t.TagCode, t.StatutoryPolarityCode FROM Cash.tbTaxTag t
               WHERE t.TaxSourceCode = @TaxSourceCode
               EXCEPT
               SELECT m.TagCode, m.StatutoryPolarityCode FROM @Manifest m
           )
            INSERT INTO @Result VALUES
                (1, NULL, NULL, NULL, NULL, NULL,
                 N'Cumulative source manifest must contain exactly sixteen approved tags with explicit orientations.');

        IF NOT EXISTS (SELECT 1 FROM Cash.vwTaxTagCashCode WHERE TaxSourceCode = @TaxSourceCode AND TagCode = 'turnover')
           OR NOT EXISTS (SELECT 1 FROM Cash.vwTaxTagCashCode WHERE TaxSourceCode = @TaxSourceCode AND TagCode = 'otherBusinessIncome')
            INSERT INTO @Result VALUES
                (1, NULL, NULL, NULL, NULL, NULL, N'Both cumulative income tags must be mapped.');

        DECLARE @HasConsolidated BIT = CASE WHEN EXISTS
            (SELECT 1 FROM Cash.vwTaxTagCashCode WHERE TaxSourceCode = @TaxSourceCode AND TagCode = 'consolidatedExpenses')
            THEN 1 ELSE 0 END;
        DECLARE @DetailedMapped INT =
            (SELECT COUNT(*) FROM @Detailed d WHERE EXISTS
                (SELECT 1 FROM Cash.vwTaxTagCashCode ec
                 WHERE ec.TaxSourceCode = @TaxSourceCode AND ec.TagCode = d.TagCode));

        IF @HasConsolidated = 1 AND @DetailedMapped > 0
            INSERT INTO @Result VALUES
                (1, 'consolidatedExpenses', NULL, NULL, NULL, @DetailedMapped,
                 N'Consolidated and detailed expense patterns cannot coexist.');
        ELSE IF @HasConsolidated = 0 AND @DetailedMapped <> 13
            INSERT INTO @Result VALUES
                (1, NULL, NULL, NULL, NULL, @DetailedMapped,
                 N'Detailed submission readiness requires all thirteen directed expense tags.');
    END;

    RETURN;
END;
GO
