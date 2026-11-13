CREATE PROCEDURE App.proc_DatasetSyntheticMIS_DividendsReceived
(
    @IsCompany bit
)
AS
SET NOCOUNT, XACT_ABORT ON;

IF ISNULL(@IsCompany, 0) = 0
    RETURN;

IF OBJECT_ID('tempdb..#DatasetCodes') IS NULL
    THROW 51310, 'DatasetSyntheticMIS_DividendsReceived: missing temp table #DatasetCodes. Run via App.proc_DatasetSyntheticMIS.', 1;

DECLARE
    @UserId nvarchar(10) = (SELECT TOP (1) UserId FROM Usr.vwCredentials),
    @BuyerRootCode nvarchar(50) =
        (SELECT CodeValue FROM #DatasetCodes WHERE CodeType = N'SUBJECT' AND CodeName = N'BuyerRoot'),
    @SettlementAccountCode nvarchar(10) =
        (SELECT CodeValue FROM #DatasetCodes WHERE CodeType = N'LINK' AND CodeName = N'SettlementAccountCode'),
    @CategoryVersionId nvarchar(10) = (SELECT CategoryVersionId FROM App.tbOptions),
    @InvesteeSubjectCode nvarchar(50) = NULL;

IF @UserId IS NULL OR @BuyerRootCode IS NULL OR @SettlementAccountCode IS NULL
    THROW 51311, 'DatasetSyntheticMIS_DividendsReceived: user, buyer root and settlement account are required.', 1;

IF NOT EXISTS
(
    SELECT 1
    FROM Cash.tbCategoryRoot root
    JOIN Cash.tbCategoryTotal total
      ON total.VersionId = root.VersionId
     AND total.ParentCode = root.CategoryCode
    JOIN Cash.tbCategoryCodeMap codeMap
      ON codeMap.VersionId = total.VersionId
     AND codeMap.CategoryCode = total.ChildCode
    JOIN Cash.tbCode cashCode ON cashCode.CashCode = codeMap.CashCode
    WHERE root.VersionId = @CategoryVersionId
      AND root.RootTypeCode = 2
      AND codeMap.CashCode = N'CC-DIVRC'
      AND cashCode.IsEnabled = 1
)
    THROW 51312, 'DatasetSyntheticMIS_DividendsReceived: the active company Category Tree has no enabled CC-DIVRC distribution mapping.', 1;

IF NOT EXISTS (SELECT 1 FROM App.tbTaxCode WHERE TaxCode = N'T0')
    THROW 51313, 'DatasetSyntheticMIS_DividendsReceived: non-VAT tax code T0 is required.', 1;

EXEC Subject.proc_AddNamespace
    @RootSubjectCode = @BuyerRootCode,
    @SubjectName = N'Dataset Investee Company',
    @SubjectTypeCode = 1,
    @SubjectCode = @InvesteeSubjectCode OUTPUT;

UPDATE Subject.tbSubject
SET SubjectStatusCode = 1,
    TaxCode = N'T0',
    ExportTypeCode = 0,
    PaymentTerms = N'Immediate',
    ExpectedDays = 0,
    PaymentDays = 0,
    PayDaysFromMonthEnd = 0,
    PayBalance = 0
WHERE SubjectCode = @InvesteeSubjectCode;

MERGE #DatasetCodes AS target
USING
(
    SELECT N'SUBJECT' AS CodeType,
           N'DividendInvestee' AS CodeName,
           @InvesteeSubjectCode AS CodeValue,
           N'BuyerRoot' AS RelatedName,
           N'External company paying deterministic received dividends' AS Notes
) AS source
ON source.CodeType = target.CodeType AND source.CodeName = target.CodeName
WHEN MATCHED THEN
    UPDATE SET CodeValue = source.CodeValue,
               RelatedName = source.RelatedName,
               Notes = source.Notes
WHEN NOT MATCHED THEN
    INSERT (CodeType, CodeName, CodeValue, RelatedName, Notes)
    VALUES (source.CodeType, source.CodeName, source.CodeValue, source.RelatedName, source.Notes);

DECLARE
    @YearNumber smallint,
    @Description nvarchar(10),
    @PaidOn date,
    @PaymentCode nvarchar(20),
    @Amount decimal(18,5);

DECLARE dividendYears CURSOR LOCAL FAST_FORWARD FOR
    SELECT year.YearNumber,
           year.Description,
           CONVERT(date, EOMONTH(MAX(period.StartOn))) AS PaidOn
    FROM App.tbYear year
    JOIN App.tbYearPeriod period ON period.YearNumber = year.YearNumber
    WHERE year.CashStatusCode = 2
    GROUP BY year.YearNumber, year.Description
    ORDER BY year.YearNumber;

OPEN dividendYears;
FETCH NEXT FROM dividendYears INTO @YearNumber, @Description, @PaidOn;

WHILE @@FETCH_STATUS = 0
BEGIN
    SET @Amount = CONVERT(decimal(18,5),
        4000 + (ABS(CHECKSUM(CONCAT(N'DS:CT:DIV:', @YearNumber))) % 2001));
    SET @PaymentCode = NULL;

    EXEC Cash.proc_NextPaymentCode @PaymentCode = @PaymentCode OUTPUT;

    INSERT INTO Cash.tbPayment
    (
        PaymentCode, UserId, PaymentStatusCode,
        SubjectCode, AccountCode,
        CashCode, TaxCode,
        PaidOn, PaidInValue, PaidOutValue,
        PaymentReference
    )
    VALUES
    (
        @PaymentCode, @UserId, 0,
        @InvesteeSubjectCode, @SettlementAccountCode,
        N'CC-DIVRC', N'T0',
        @PaidOn, @Amount, 0,
        CONCAT(N'Synthetic dividend ', @Description)
    );

    EXEC Cash.proc_PaymentPost;

    FETCH NEXT FROM dividendYears INTO @YearNumber, @Description, @PaidOn;
END;

CLOSE dividendYears;
DEALLOCATE dividendYears;
GO
