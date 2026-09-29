CREATE PROCEDURE App.proc_DatasetSyntheticMIS_VatSandboxAlign
(
    @SandboxVrn nvarchar(9),
    @ObligationPeriodKey nvarchar(16),
    @ObligationStart date,
    @ObligationEnd date
)
AS
    SET NOCOUNT, XACT_ABORT ON;

    IF @SandboxVrn IS NULL OR LEN(@SandboxVrn) <> 9 OR @SandboxVrn LIKE N'%[^0-9]%'
        THROW 51081, 'VAT sandbox alignment: a nine-digit generated organisation VRN is required.', 1;

    IF @SandboxVrn = N'999000001'
        THROW 51082, 'VAT sandbox alignment: the synthetic placeholder VRN cannot be used.', 1;

    IF NULLIF(LTRIM(RTRIM(@ObligationPeriodKey)), N'') IS NULL
        THROW 51083, 'VAT sandbox alignment: the authority period key is required.', 1;

    IF @ObligationStart IS NULL OR @ObligationEnd IS NULL OR @ObligationEnd < @ObligationStart
        THROW 51084, 'VAT sandbox alignment: the authority period dates are invalid.', 1;

    DECLARE
        @SubjectCode nvarchar(50) = (SELECT TOP (1) SubjectCode FROM App.tbOptions ORDER BY Identifier),
        @ProfileCode nvarchar(20),
        @StatusCode smallint,
        @ValidFrom date,
        @TaxSourceCode nvarchar(20);

    SELECT
        @ProfileCode = ReportingProfileCode,
        @StatusCode = StatusCode,
        @ValidFrom = ValidFrom,
        @TaxSourceCode = TaxSourceCode
    FROM Cash.tbReportingProfile
    WHERE SubjectCode = @SubjectCode
      AND ReportingTypeCode = N'INDIRECT-TAX'
      AND ValueSourceCode = N'SYNTHETIC';

    IF @ProfileCode IS NULL
        THROW 51085, 'VAT sandbox alignment is restricted to a disposable synthetic node.', 1;

    IF NOT EXISTS
    (
        SELECT 1
        FROM Cash.vwTaxVatSubmission submission
        JOIN Cash.fnTaxTypeDueDates(1, 0) due ON submission.StartOn = due.PayTo
        WHERE CONVERT(date, due.PayFrom) = @ObligationStart
          AND CONVERT(date, DATEADD(day, -1, due.PayTo)) = @ObligationEnd
    )
        THROW 51086, 'VAT sandbox alignment: no exact calculated local VAT submission period exists.', 1;

    EXEC Cash.proc_ReportingProfileSave
        @SubjectCode = @SubjectCode,
        @ReportingTypeCode = N'INDIRECT-TAX',
        @TaxSourceCode = @TaxSourceCode,
        @AuthorityReference = @SandboxVrn,
        @ValidFrom = @ValidFrom,
        @StatusCode = @StatusCode,
        @ValueSourceCode = N'SYNTHETIC',
        @IsReviewed = 1,
        @ReportingProfileCode = @ProfileCode OUTPUT;

    SELECT
        @ProfileCode AS ReportingProfileCode,
        @SandboxVrn AS SandboxVrn,
        @ObligationPeriodKey AS ObligationPeriodKey,
        @ObligationStart AS ObligationStart,
        @ObligationEnd AS ObligationEnd,
        N'Cash.vwTaxVatSubmission' AS SourceView;
GO
