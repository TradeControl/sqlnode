CREATE FUNCTION [Cash].[fnReportingProfile]
(
    @SubjectCode NVARCHAR(50),
    @ReportingTypeCode NVARCHAR(20),
    @TaxSourceCode NVARCHAR(20),
    @AsOfDate DATE
)
RETURNS TABLE
AS
RETURN
(
    SELECT
        profile.SubjectCode,
        profile.ReportingProfileCode,
        profile.TaxSourceCode,
        profile.AuthorityCode,
        authority.AuthorityName,
        authority.JurisdictionCode,
        profile.ReportingTypeCode,
        reportingType.ReportingTypeName,
        profile.AuthorityReference,
        profile.ValidFrom,
        profile.ValidTo,
        profile.StatusCode,
        status.StatusName,
        profile.ValueSourceCode,
        source.ValueSourceName,
        profile.IsReviewed,
        profile.InsertedBy,
        profile.InsertedOn,
        profile.UpdatedBy,
        profile.UpdatedOn,
        CONVERT(binary(8), profile.RowVer) AS RowVer
    FROM Cash.tbReportingProfile profile
    JOIN App.tbAuthority authority ON authority.AuthorityCode = profile.AuthorityCode
    JOIN App.tbReportingType reportingType ON reportingType.ReportingTypeCode = profile.ReportingTypeCode
    JOIN App.tbStatutoryStatus status
      ON status.StatusCode = profile.StatusCode AND status.IsActive = 1
    JOIN App.tbValueSource source ON source.ValueSourceCode = profile.ValueSourceCode
    WHERE profile.SubjectCode = @SubjectCode
      AND (@ReportingTypeCode IS NULL OR profile.ReportingTypeCode = @ReportingTypeCode)
      AND (@TaxSourceCode IS NULL OR profile.TaxSourceCode = @TaxSourceCode)
      AND profile.ValidFrom <= @AsOfDate
      AND (profile.ValidTo IS NULL OR profile.ValidTo >= @AsOfDate)
);
