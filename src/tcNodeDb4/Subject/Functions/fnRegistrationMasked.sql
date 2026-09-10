CREATE FUNCTION [Subject].[fnRegistrationMasked]
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
        registration.SchemeName,
        registration.AuthorityCode,
        registration.JurisdictionCode,
        CASE registration.IsSensitive
            WHEN 1 THEN App.fnIdentifierMask(registration.RegistrationValue, 4)
            ELSE registration.RegistrationValue
        END AS RegistrationDisplayValue,
        registration.IsSensitive,
        registration.ValidFrom,
        registration.ValidTo,
        registration.StatusCode,
        registration.StatusName,
        registration.ValueSourceCode,
        registration.ValueSourceName,
        registration.IsReviewed,
        registration.UpdatedBy,
        registration.UpdatedOn,
        registration.RowVer
    FROM Subject.fnRegistration(@SubjectCode, @RegistrationSchemeCode, @AsOfDate) registration
);
