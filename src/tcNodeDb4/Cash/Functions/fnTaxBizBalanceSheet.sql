CREATE FUNCTION Cash.fnTaxBizBalanceSheet
(
    @TaxSourceCode NVARCHAR(20),
    @AsOfDate DATE
)
RETURNS @Projection TABLE
(
    TaxSourceCode NVARCHAR(20) NOT NULL,
    AsOfDate DATE NOT NULL,
    PeriodStart DATE NULL,
    ValidationStatus NVARCHAR(12) NOT NULL,
    TagCode NVARCHAR(64) NOT NULL,
    ValueState NVARCHAR(20) NOT NULL,
    SupportStatus NVARCHAR(16) NOT NULL,
    StatutoryAmount DECIMAL(18, 5) NULL,
    SnapshotRowVer BINARY(8) NOT NULL
)
AS
BEGIN
    DECLARE @PeriodStart DATE =
    (
        SELECT MAX(CONVERT(DATE, StartOn))
        FROM App.tbYearPeriod
        WHERE CONVERT(DATE, StartOn) <= @AsOfDate
    );
    DECLARE @MappingsValid BIT = CASE WHEN EXISTS
        (SELECT 1 FROM Cash.fnTaxTagMapValidate(@TaxSourceCode) WHERE IsError = 1)
        THEN 0 ELSE 1 END;
    DECLARE @SnapshotRowVer BINARY(8) = CONVERT(BINARY(8), @@DBTS);

    ;WITH EffectiveAccountMappings AS
    (
        SELECT DISTINCT mapping.TagCode, account.AccountCode
        FROM Cash.vwTaxTagCashCode mapping
        JOIN Subject.tbAccount account
          ON account.CashCode = mapping.CashCode
         AND account.AccountTypeCode = 2
         AND account.AccountClosed = 0
        WHERE mapping.TaxSourceCode = @TaxSourceCode
          AND mapping.TagCode IN
              (N'BalanceSheet.FixedAssets', N'BalanceSheet.CreditorsDueAfterOneYear')
    ),
    MappedAccountAmounts AS
    (
        SELECT mapping.TagCode,
               SUM(CONVERT(DECIMAL(18, 5),
                   CASE mapping.TagCode
                       WHEN N'BalanceSheet.CreditorsDueAfterOneYear' THEN COALESCE(balance.Balance, 0) * -1
                       ELSE COALESCE(balance.Balance, 0)
                   END)) AS StatutoryAmount
        FROM EffectiveAccountMappings mapping
        JOIN Cash.vwBalanceSheetAssets balance
          ON balance.AssetCode = mapping.AccountCode
         AND CONVERT(DATE, balance.StartOn) = @PeriodStart
        GROUP BY mapping.TagCode
    ),
    Components AS
    (
        SELECT
            FixedAssets = COALESCE((SELECT StatutoryAmount FROM MappedAccountAmounts WHERE TagCode = N'BalanceSheet.FixedAssets'), 0),
            CurrentAssets =
                COALESCE((SELECT SUM(CONVERT(DECIMAL(18, 5), Balance)) FROM Cash.vwBalanceSheetSubjects WHERE AssetTypeCode = 0 AND CONVERT(DATE, StartOn) = @PeriodStart), 0)
              + COALESCE((SELECT SUM(CONVERT(DECIMAL(18, 5), Balance)) FROM Cash.vwBalanceSheetAccounts WHERE AssetTypeCode IN (2, 3) AND CONVERT(DATE, StartOn) = @PeriodStart), 0),
            CreditorsWithin =
                COALESCE((SELECT SUM(CONVERT(DECIMAL(18, 5), Balance * -1)) FROM Cash.vwBalanceSheetSubjects WHERE AssetTypeCode = 1 AND CONVERT(DATE, StartOn) = @PeriodStart), 0)
              + COALESCE((SELECT SUM(CONVERT(DECIMAL(18, 5), Balance * -1)) FROM Cash.vwBalanceSheetTax WHERE CONVERT(DATE, StartOn) = @PeriodStart), 0)
              + COALESCE((SELECT SUM(CONVERT(DECIMAL(18, 5), Balance * -1)) FROM Cash.vwBalanceSheetVat WHERE CONVERT(DATE, StartOn) = @PeriodStart), 0),
            CreditorsAfter = COALESCE((SELECT StatutoryAmount FROM MappedAccountAmounts WHERE TagCode = N'BalanceSheet.CreditorsDueAfterOneYear'), 0)
    ),
    ProjectionValues AS
    (
        SELECT N'BalanceSheet.FixedAssets' TagCode, N'Source' ValueState, FixedAssets StatutoryAmount FROM Components
        UNION ALL SELECT N'BalanceSheet.CurrentAssets', N'Source', CurrentAssets FROM Components
        UNION ALL SELECT N'BalanceSheet.PrepaymentsAndAccruedIncome', N'ReviewedFilingInput', CONVERT(DECIMAL(18, 5), 0) FROM Components
        UNION ALL SELECT N'BalanceSheet.CreditorsDueWithinOneYear', N'Source', CreditorsWithin FROM Components
        UNION ALL SELECT N'BalanceSheet.NetCurrentAssetsLiabilities', N'Derived', CurrentAssets - CreditorsWithin FROM Components
        UNION ALL SELECT N'BalanceSheet.TotalAssetsLessCurrentLiabilities', N'Derived', FixedAssets + CurrentAssets - CreditorsWithin FROM Components
        UNION ALL SELECT N'BalanceSheet.CreditorsDueAfterOneYear', N'Source', CreditorsAfter FROM Components
        UNION ALL SELECT N'BalanceSheet.Provisions', N'ReviewedFilingInput', CONVERT(DECIMAL(18, 5), 0) FROM Components
        UNION ALL SELECT N'BalanceSheet.AccrualsAndDeferredIncome', N'ReviewedFilingInput', CONVERT(DECIMAL(18, 5), 0) FROM Components
        UNION ALL SELECT N'BalanceSheet.NetAssetsLiabilities', N'Derived', FixedAssets + CurrentAssets - CreditorsWithin - CreditorsAfter FROM Components
        UNION ALL SELECT N'BalanceSheet.CapitalAndReserves', N'Derived', FixedAssets + CurrentAssets - CreditorsWithin - CreditorsAfter FROM Components
    )
    INSERT INTO @Projection
    SELECT
        @TaxSourceCode,
        @AsOfDate,
        @PeriodStart,
        CASE WHEN @PeriodStart IS NOT NULL AND @MappingsValid = 1 THEN N'Ready' ELSE N'Invalid' END,
        value.TagCode,
        value.ValueState,
        CASE WHEN @PeriodStart IS NOT NULL AND @MappingsValid = 1 THEN N'Supported' ELSE N'Invalid' END,
        CASE WHEN @PeriodStart IS NOT NULL AND @MappingsValid = 1 THEN value.StatutoryAmount END,
        @SnapshotRowVer
    FROM ProjectionValues value;

    RETURN;
END;
GO
