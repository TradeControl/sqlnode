CREATE FUNCTION [Subject].[fnStatutoryIdentity]
(
    @AsOfDate DATE
)
RETURNS TABLE
AS
RETURN
(
    SELECT
        options.JurisdictionCode,
        options.UnitOfCharge,
        subject.SubjectCode,
        subject.SubjectName,
        subject.SubjectTypeCode,
        type.SubjectClassCode,
        class.SubjectClass,
        subject.AddressCode,
        address.Address AS FreeFormAddress,
        detail.AddressLine1,
        detail.AddressLine2,
        detail.AddressLine3,
        detail.Locality,
        detail.Region,
        detail.PostalCode,
        detail.JurisdictionCode AS AddressJurisdictionCode,
        detail.ValueSourceCode AS AddressValueSourceCode,
        detail.IsReviewed AS IsAddressReviewed,
        subject.PhoneNumber,
        subject.EmailAddress,
        virtual.WebSite,
        virtual.CompanyNumber,
        virtual.VatNumber,
        virtual.BusinessDescription,
        legal.LegalFormJurisdictionCode,
        legal.LegalFormCode,
        legal.LegalFormName,
        legal.RegistryJurisdictionCode,
        legal.ValueSourceCode AS LegalValueSourceCode,
        legal.IsReviewed AS IsLegalProfileReviewed,
        CONVERT(binary(8), options.RowVer) AS OptionsRowVer,
        CONVERT(binary(8), subject.RowVer) AS SubjectRowVer,
        CONVERT(binary(8), address.RowVer) AS AddressRowVer,
        CONVERT(binary(8), detail.RowVer) AS AddressDetailRowVer,
        CONVERT(binary(8), virtual.RowVer) AS VirtualRowVer,
        CONVERT(binary(8), legal.RowVer) AS LegalProfileRowVer,
        subject.UpdatedOn AS SubjectUpdatedOn,
        address.UpdatedOn AS AddressUpdatedOn,
        detail.UpdatedOn AS AddressDetailUpdatedOn,
        legal.UpdatedOn AS LegalProfileUpdatedOn
    FROM App.tbOptions options
    JOIN Subject.tbSubject subject ON subject.SubjectCode = options.SubjectCode
    JOIN Subject.tbType type ON type.SubjectTypeCode = subject.SubjectTypeCode
    JOIN Subject.tbClass class ON class.SubjectClassCode = type.SubjectClassCode
    LEFT JOIN Subject.tbAddress address ON address.AddressCode = subject.AddressCode
    LEFT JOIN Subject.tbAddressDetail detail ON detail.AddressCode = address.AddressCode
    LEFT JOIN Subject.tbVirtual virtual ON virtual.SubjectCode = subject.SubjectCode
    OUTER APPLY
    (
        SELECT TOP (1)
            profile.LegalFormJurisdictionCode,
            profile.LegalFormCode,
            form.LegalFormName,
            profile.RegistryJurisdictionCode,
            profile.ValueSourceCode,
            profile.IsReviewed,
            profile.RowVer,
            profile.UpdatedOn
        FROM Subject.tbLegalProfile profile
        JOIN App.tbLegalForm form
          ON form.JurisdictionCode = profile.LegalFormJurisdictionCode
         AND form.LegalFormCode = profile.LegalFormCode
        JOIN App.tbStatutoryStatus status ON status.StatusCode = profile.StatusCode
        WHERE profile.SubjectCode = subject.SubjectCode
          AND status.IsActive = 1
          AND profile.ValidFrom <= @AsOfDate
          AND (profile.ValidTo IS NULL OR profile.ValidTo >= @AsOfDate)
        ORDER BY profile.ValidFrom DESC, profile.LegalFormCode
    ) legal
);
