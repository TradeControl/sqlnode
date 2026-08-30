/*
    Generic Tax Tag mapping validator fixture.
    Run against a freshly bootstrapped MTD node. All mutations roll back.
*/
SET NOCOUNT, XACT_ABORT ON;

BEGIN TRAN TaxTagMapValidatorFixture;
BEGIN TRY
    DECLARE @Source NVARCHAR(20) = 'UK-ITSA-SE-CUM';

    IF EXISTS (SELECT 1 FROM Cash.fnTaxTagMapValidate(@Source) WHERE IsError = 1)
        THROW 51000, 'Valid Component bootstrap mappings must pass generic validation.', 1;
    IF EXISTS (SELECT 1 FROM Cash.fnTaxTagMapValidate(@Source)
               WHERE IsError = 1 AND Message LIKE N'%polarity%')
        THROW 51000, 'Valid configured Component polarity must pass.', 1;

    UPDATE Cash.tbTaxTag
    SET TagClassCode = 0
    WHERE TaxSourceCode = @Source AND TagCode = 'turnover';
    IF NOT EXISTS (SELECT 1 FROM Cash.fnTaxTagMapValidate(@Source)
                   WHERE IsError = 1 AND TagCode = 'turnover' AND Message LIKE N'%Only Component%')
        THROW 51000, 'Rollup mappings must be rejected.', 1;

    UPDATE Cash.tbTaxTag
    SET TagClassCode = 2
    WHERE TaxSourceCode = @Source AND TagCode = 'turnover';
    IF NOT EXISTS (SELECT 1 FROM Cash.fnTaxTagMapValidate(@Source)
                   WHERE IsError = 1 AND TagCode = 'turnover' AND Message LIKE N'%Only Component%')
        THROW 51000, 'Derived mappings must be rejected.', 1;

    UPDATE Cash.tbTaxTag
    SET TagClassCode = 1
    WHERE TaxSourceCode = @Source AND TagCode = 'turnover';

    UPDATE Cash.tbCategory SET IsEnabled = 0 WHERE CategoryCode = 'CT-TURNOV';
    IF NOT EXISTS (SELECT 1 FROM Cash.fnTaxTagMapValidate(@Source)
                   WHERE IsError = 1 AND CategoryCode = 'CT-TURNOV' AND Message LIKE N'%disabled%')
        THROW 51000, 'Disabled Category mapping roots must be rejected.', 1;
    UPDATE Cash.tbCategory SET IsEnabled = 1 WHERE CategoryCode = 'CT-TURNOV';

    INSERT INTO Cash.tbTaxTagMap
        (TaxSourceCode, TagCode, MapTypeCode, CategoryCode, CashCode, IsEnabled)
    VALUES (@Source, 'turnover', 0, 'CA-SALES', '', 1);
    IF NOT EXISTS (SELECT 1 FROM Cash.fnTaxTagMapValidate(@Source)
                   WHERE IsError = 1 AND TagCode = 'turnover' AND Message LIKE N'%multiple times%')
        THROW 51000, 'Parent/descendant duplicate contribution must be rejected.', 1;
    DELETE FROM Cash.tbTaxTagMap
    WHERE TaxSourceCode = @Source AND TagCode = 'turnover'
      AND MapTypeCode = 0 AND CategoryCode = 'CA-SALES';

    DECLARE @SalesCode NVARCHAR(50) =
        (SELECT TOP (1) CashCode FROM Cash.vwTaxTagCashCode
         WHERE TaxSourceCode = @Source AND TagCode = 'turnover');

    DECLARE @SalesCategory NVARCHAR(10) =
        (SELECT CategoryCode FROM Cash.tbCode WHERE CashCode = @SalesCode);
    UPDATE Cash.tbCategory SET CashPolarityCode = 0 WHERE CategoryCode = @SalesCategory;
    IF NOT EXISTS (SELECT 1 FROM Cash.fnTaxTagMapValidate(@Source)
                   WHERE IsError = 1 AND CashCode = @SalesCode AND Message LIKE N'%polarity%')
        THROW 51000, 'Configured Tax Tag cash polarity mismatch must be rejected.', 1;
    UPDATE Cash.tbCategory SET CashPolarityCode = 1 WHERE CategoryCode = @SalesCategory;

    DELETE FROM Cash.tbTaxTagMap WHERE TaxSourceCode = @Source AND TagCode = 'turnover';
    IF NOT EXISTS (SELECT 1 FROM Cash.fnTaxTagMapValidate(@Source)
                   WHERE IsError = 0 AND CashCode = @SalesCode AND Message LIKE N'%not covered%')
        THROW 51000, 'Uncovered enabled P&L CashCode warning must use effective Category coverage.', 1;

    ROLLBACK TRAN TaxTagMapValidatorFixture;
    PRINT 'Generic Tax Tag mapping validator fixture passed.';
END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0 ROLLBACK TRAN TaxTagMapValidatorFixture;
    THROW;
END CATCH;
