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
    DECLARE @SnapshotPeriodStart DATE =
    (
        SELECT MAX(CONVERT(DATE, StartOn))
        FROM App.tbYearPeriod
        WHERE CONVERT(DATE, StartOn) <= @AsOfDate
    );
    DECLARE @MappingsValid BIT = CASE WHEN EXISTS
        (SELECT 1 FROM Cash.fnTaxTagMapValidate(@TaxSourceCode) WHERE IsError = 1)
        THEN 0 ELSE 1 END;
    DECLARE @SnapshotRowVer BINARY(8) = CONVERT(BINARY(8), @@DBTS);
    DECLARE @NonCurrentAssets DECIMAL(18, 5) = 0;
    DECLARE @CurrentAssets DECIMAL(18, 5) = 0;
    DECLARE @CurrentLiabilities DECIMAL(18, 5) = 0;
    DECLARE @NonCurrentLiabilities DECIMAL(18, 5) = 0;

    ;WITH EffectiveAccountMappings AS
    (
        SELECT DISTINCT
            CASE mapping.MappingRoot
                WHEN N'CA-LIAB' THEN N'BalanceSheet.NonCurrentLiabilities'
                ELSE N'BalanceSheet.NonCurrentAssets'
            END AS BalanceClassCode,
            account.AccountCode
        FROM Cash.vwTaxTagCashCode mapping
        JOIN Subject.tbAccount account
          ON account.CashCode = mapping.CashCode
         AND account.AccountTypeCode = 2
         AND account.AccountClosed = 0
        WHERE mapping.TaxSourceCode = @TaxSourceCode
          AND mapping.MappingRoot IN (N'CA-ASSET', N'CA-DEPREC', N'CA-LIAB')
    )
    SELECT
        @NonCurrentAssets = COALESCE(SUM(CONVERT(DECIMAL(18, 5),
            CASE mapping.BalanceClassCode
                WHEN N'BalanceSheet.NonCurrentAssets' THEN balance.Balance
                ELSE 0
            END)), 0),
        @NonCurrentLiabilities = COALESCE(SUM(CONVERT(DECIMAL(18, 5),
            CASE mapping.BalanceClassCode
                WHEN N'BalanceSheet.NonCurrentLiabilities' THEN balance.Balance * -1
                ELSE 0
            END)), 0)
    FROM EffectiveAccountMappings mapping
    JOIN Cash.vwBalanceSheetAssets balance
      ON balance.AssetCode = mapping.AccountCode
     AND CONVERT(DATE, balance.StartOn) = @SnapshotPeriodStart;

    SELECT @CurrentAssets = COALESCE(SUM(source.StatutoryAmount), 0)
    FROM
    (
        SELECT CONVERT(DECIMAL(18, 5), Balance) AS StatutoryAmount
        FROM Cash.vwBalanceSheetSubjects
        WHERE AssetTypeCode = 0
          AND CONVERT(DATE, StartOn) = @SnapshotPeriodStart

        UNION ALL

        SELECT CONVERT(DECIMAL(18, 5), Balance)
        FROM Cash.vwBalanceSheetAccounts
        WHERE AssetTypeCode IN (2, 3)
          AND CONVERT(DATE, StartOn) = @SnapshotPeriodStart
    ) source;

    SELECT @CurrentLiabilities = COALESCE(SUM(source.StatutoryAmount), 0)
    FROM
    (
        SELECT CONVERT(DECIMAL(18, 5), Balance * -1) AS StatutoryAmount
        FROM Cash.vwBalanceSheetSubjects
        WHERE AssetTypeCode = 1
          AND CONVERT(DATE, StartOn) = @SnapshotPeriodStart

        UNION ALL

        SELECT CONVERT(DECIMAL(18, 5), Balance * -1)
        FROM Cash.vwBalanceSheetTax
        WHERE CONVERT(DATE, StartOn) = @SnapshotPeriodStart

        UNION ALL

        SELECT CONVERT(DECIMAL(18, 5), Balance * -1)
        FROM Cash.vwBalanceSheetVat
        WHERE CONVERT(DATE, StartOn) = @SnapshotPeriodStart
    ) source;

    INSERT INTO @Projection
    SELECT
        @TaxSourceCode,
        @AsOfDate,
        @SnapshotPeriodStart,
        CASE WHEN @SnapshotPeriodStart IS NOT NULL AND @MappingsValid = 1 THEN N'Ready' ELSE N'Invalid' END,
        value.TagCode,
        N'Source',
        CASE WHEN @SnapshotPeriodStart IS NOT NULL AND @MappingsValid = 1 THEN N'Supported' ELSE N'Invalid' END,
        CASE WHEN @SnapshotPeriodStart IS NOT NULL AND @MappingsValid = 1 THEN value.StatutoryAmount END,
        @SnapshotRowVer
    FROM
    (
        VALUES
            (N'BalanceSheet.NonCurrentAssets', @NonCurrentAssets),
            (N'BalanceSheet.CurrentAssets', @CurrentAssets),
            (N'BalanceSheet.CurrentLiabilities', @CurrentLiabilities),
            (N'BalanceSheet.NonCurrentLiabilities', @NonCurrentLiabilities)
    ) value(TagCode, StatutoryAmount);

    RETURN;
END;
GO
