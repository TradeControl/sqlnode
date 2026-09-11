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
        subject.AddressCode AS TradingAddressCode,
        tradingAddress.Address AS TradingAddress,
        registeredAddress.AddressCode AS RegisteredAddressCode,
        registeredAddress.Address AS RegisteredAddress,
        subject.PhoneNumber,
        subject.EmailAddress,
        virtual.WebSite,
        virtual.CompanyNumber,
        virtual.VatNumber,
        virtual.BusinessDescription,
        virtual.RegistryJurisdictionCode,
        COALESCE(virtual.RegistryJurisdictionCode, options.JurisdictionCode) AS EffectiveRegistryJurisdictionCode,
        CONVERT(binary(8), options.RowVer) AS OptionsRowVer,
        CONVERT(binary(8), subject.RowVer) AS SubjectRowVer,
        CONVERT(binary(8), tradingAddress.RowVer) AS TradingAddressRowVer,
        CONVERT(binary(8), registeredAddress.RowVer) AS RegisteredAddressRowVer,
        CONVERT(binary(8), virtual.RowVer) AS VirtualRowVer,
        subject.UpdatedOn AS SubjectUpdatedOn,
        tradingAddress.UpdatedOn AS TradingAddressUpdatedOn,
        registeredAddress.UpdatedOn AS RegisteredAddressUpdatedOn
    FROM App.tbOptions options
    JOIN Subject.tbSubject subject ON subject.SubjectCode = options.SubjectCode
    JOIN Subject.tbType type ON type.SubjectTypeCode = subject.SubjectTypeCode
    JOIN Subject.tbClass class ON class.SubjectClassCode = type.SubjectClassCode
    LEFT JOIN Subject.tbAddress tradingAddress ON tradingAddress.AddressCode = subject.AddressCode
    LEFT JOIN Subject.tbAddress registeredAddress
        ON registeredAddress.SubjectCode = subject.SubjectCode
        AND registeredAddress.AddressTypeCode = 2
    LEFT JOIN Subject.tbVirtual virtual ON virtual.SubjectCode = subject.SubjectCode
);
