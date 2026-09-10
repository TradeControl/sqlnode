CREATE FUNCTION [Cash].[fnReportingProfileMasked]
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
        profile.AuthorityName,
        profile.JurisdictionCode,
        profile.ReportingTypeCode,
        profile.ReportingTypeName,
        App.fnIdentifierMask(profile.AuthorityReference, 4) AS AuthorityReferenceDisplay,
        profile.ValidFrom,
        profile.ValidTo,
        profile.StatusCode,
        profile.StatusName,
        profile.ValueSourceCode,
        profile.ValueSourceName,
        profile.IsReviewed,
        profile.UpdatedBy,
        profile.UpdatedOn,
        profile.RowVer
    FROM Cash.fnReportingProfile
    (
        @SubjectCode, @ReportingTypeCode, @TaxSourceCode, @AsOfDate
    ) profile
);
