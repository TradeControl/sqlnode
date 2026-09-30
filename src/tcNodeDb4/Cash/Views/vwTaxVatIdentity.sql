CREATE VIEW [Cash].[vwTaxVatIdentity]
AS
    SELECT
        options.SubjectCode,
        reportingSubject.VatNumber,
        profile.ReportingProfileCode,
        profile.AuthorityReference,
        profile.ValidFrom,
        profile.ValidTo,
        profile.StatusCode,
        profile.IsReviewed,
        CASE
            WHEN ISNULL(NULLIF(LTRIM(RTRIM(reportingSubject.VatNumber)), N''), N'')
               = ISNULL(NULLIF(LTRIM(RTRIM(profile.AuthorityReference)), N''), N'')
            THEN CAST(1 AS BIT)
            ELSE CAST(0 AS BIT)
        END AS IsConsistent
    FROM App.tbOptions options
    JOIN Subject.tbVirtual reportingSubject
      ON reportingSubject.SubjectCode = options.SubjectCode
    LEFT JOIN Cash.tbReportingProfile profile
      ON profile.SubjectCode = options.SubjectCode
     AND profile.ReportingTypeCode = 0;
GO
