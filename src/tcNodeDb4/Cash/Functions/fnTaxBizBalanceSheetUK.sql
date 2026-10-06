CREATE FUNCTION Cash.fnTaxBizBalanceSheetUK
(
    @TaxSourceCode NVARCHAR(20),
    @AsOfDate DATE
)
RETURNS TABLE
AS
RETURN
(
    SELECT
        TaxSourceCode,
        AsOfDate,
        PeriodStart,
        ValidationStatus,
        CONVERT(NVARCHAR(64), CASE TagCode
            WHEN N'BalanceSheet.NonCurrentAssets' THEN N'BalanceSheet.FixedAssets'
            WHEN N'BalanceSheet.CurrentAssets' THEN N'BalanceSheet.CurrentAssets'
            WHEN N'BalanceSheet.CurrentLiabilities' THEN N'BalanceSheet.CreditorsDueWithinOneYear'
            WHEN N'BalanceSheet.NonCurrentLiabilities' THEN N'BalanceSheet.CreditorsDueAfterOneYear'
        END) AS TagCode,
        ValueState,
        SupportStatus,
        StatutoryAmount,
        SnapshotRowVer
    FROM Cash.fnTaxBizBalanceSheet(@TaxSourceCode, @AsOfDate)
);
GO
