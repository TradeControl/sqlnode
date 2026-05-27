CREATE VIEW Subject.vwBalanceSheetAudit
AS
    SELECT
        year.YearNumber,
        year.Description,
        month.MonthName,
        subject.SubjectCode,
        balances.ParentSubjectCode,
        parent.SubjectName AS ParentSubjectName,
        subject.SubjectName,
        type.SubjectType,
        polarity.CashPolarity,
        assetType.AssetTypeCode,
        assetType.AssetType,
        balances.StartOn,
        balances.Balance
    FROM Subject.vwAssetBalances AS balances
        INNER JOIN Cash.tbAssetType AS assetType
            ON balances.AssetTypeCode = assetType.AssetTypeCode
        INNER JOIN Subject.tbSubject AS subject
            ON balances.SubjectCode = subject.SubjectCode
        LEFT OUTER JOIN Subject.tbSubject AS parent
            ON balances.ParentSubjectCode = parent.SubjectCode
        INNER JOIN App.tbYearPeriod AS period
            ON balances.StartOn = period.StartOn
        INNER JOIN Subject.tbType AS type
            ON subject.SubjectTypeCode = type.SubjectTypeCode
        INNER JOIN Cash.tbPolarity AS polarity
            ON type.CashPolarityCode = polarity.CashPolarityCode
        INNER JOIN App.tbYear AS year
            ON period.YearNumber = year.YearNumber
        INNER JOIN App.tbMonth AS month
            ON period.MonthNumber = month.MonthNumber
    WHERE balances.Balance <> 0
      AND balances.StartOn <= (SELECT TOP (1) StartOn FROM App.vwActivePeriod);
