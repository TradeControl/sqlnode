CREATE PROCEDURE App.proc_StatutoryContext
(
	@AsOfDate DATE
)
AS
	SET NOCOUNT ON;

	DECLARE @SubjectCode NVARCHAR(50) =
		(SELECT SubjectCode FROM App.tbOptions);

	SELECT
		identityEvidence.*,
		virtual.NumberOfEmployees,
		Cash.fnGetBizTaxType() AS BusinessTaxTypeCode
	FROM Subject.fnStatutoryIdentity(@AsOfDate) identityEvidence
	LEFT JOIN Subject.tbVirtual virtual
		ON virtual.SubjectCode = identityEvidence.SubjectCode;

	SELECT
		RegistrationSchemeCode,
		RegistrationDisplayValue,
		IsSensitive,
		IsReviewed,
		ValueSourceCode,
		UpdatedOn,
		RowVer
	FROM Subject.fnRegistrationMasked(@SubjectCode, NULL, @AsOfDate);

	SELECT
		ReportingProfileCode,
		ReportingTypeCode,
		AuthorityCode,
		TaxSourceCode,
		AuthorityReferenceDisplay,
		IsReviewed,
		ValueSourceCode,
		UpdatedOn,
		RowVer
	FROM Cash.fnReportingProfileMasked(@SubjectCode, NULL, NULL, @AsOfDate);

	SELECT
		setting.ReportingProfileCode,
		setting.SettingCode,
		setting.ValueTypeCode,
		CASE definition.IsSensitive
			WHEN 1 THEN App.fnIdentifierMask(value.DisplayValue, 4)
			ELSE value.DisplayValue
		END AS DisplayValue,
		definition.IsSensitive,
		setting.IsReviewed,
		setting.ValueSourceCode,
		setting.UpdatedOn,
		setting.RowVer
	FROM Cash.fnReportingProfile(@SubjectCode, NULL, NULL, @AsOfDate) profile
	CROSS APPLY Cash.fnReportingProfileSetting(profile.SubjectCode, profile.ReportingProfileCode, NULL, @AsOfDate) setting
	JOIN App.tbSettingDefinition definition
		ON definition.SettingCode = setting.SettingCode
	CROSS APPLY
	(
		SELECT CASE setting.ValueTypeCode
			WHEN N'TEXT' THEN setting.TextValue
			WHEN N'INTEGER' THEN CONVERT(NVARCHAR(100), setting.IntegerValue)
			WHEN N'DECIMAL' THEN CONVERT(NVARCHAR(100), setting.DecimalValue)
			WHEN N'DATE' THEN CONVERT(NVARCHAR(10), setting.DateValue, 23)
			WHEN N'BOOLEAN' THEN CASE setting.BooleanValue WHEN 1 THEN N'true' ELSE N'false' END
		END AS DisplayValue
	) value;

	SELECT TOP (1)
		PayFrom,
		PayTo
	FROM Cash.fnTaxTypeDueDates(Cash.fnGetBizTaxType(), 0)
	WHERE PayFrom <= @AsOfDate
		AND PayTo > @AsOfDate
	ORDER BY PayFrom DESC;
