CREATE FUNCTION [Subject].[fnRegistration]
(
    @SubjectCode NVARCHAR(50),
    @RegistrationSchemeCode NVARCHAR(20),
    @AsOfDate DATE
)
RETURNS TABLE
AS
RETURN
(
    SELECT
        registration.SubjectCode,
        registration.RegistrationCode,
        registration.RegistrationSchemeCode,
        scheme.SchemeName,
        scheme.AuthorityCode,
        authority.JurisdictionCode,
        registration.RegistrationValue,
        scheme.IsSensitive,
        registration.ValidFrom,
        registration.ValidTo,
        registration.StatusCode,
        status.StatusName,
        registration.ValueSourceCode,
        source.ValueSourceName,
        registration.IsReviewed,
        registration.InsertedBy,
        registration.InsertedOn,
        registration.UpdatedBy,
        registration.UpdatedOn,
        CONVERT(binary(8), registration.RowVer) AS RowVer
    FROM Subject.tbRegistration registration
    JOIN App.tbRegistrationScheme scheme
      ON scheme.RegistrationSchemeCode = registration.RegistrationSchemeCode
    JOIN App.tbAuthority authority ON authority.AuthorityCode = scheme.AuthorityCode
    JOIN App.tbStatutoryStatus status
      ON status.StatusCode = registration.StatusCode AND status.IsActive = 1
    JOIN App.tbValueSource source ON source.ValueSourceCode = registration.ValueSourceCode
    WHERE registration.SubjectCode = @SubjectCode
      AND (@RegistrationSchemeCode IS NULL OR registration.RegistrationSchemeCode = @RegistrationSchemeCode)
      AND registration.ValidFrom <= @AsOfDate
      AND (registration.ValidTo IS NULL OR registration.ValidTo >= @AsOfDate)
);
