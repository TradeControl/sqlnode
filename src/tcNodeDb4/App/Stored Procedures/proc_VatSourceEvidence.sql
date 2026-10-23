CREATE PROCEDURE [App].[proc_VatSourceEvidence]
    @PeriodStart DATE,
    @PeriodEnd DATE
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;

    IF @PeriodStart IS NULL OR @PeriodEnd IS NULL OR @PeriodEnd < @PeriodStart
        THROW 51030, 'A valid VAT evidence period is required.', 1;

    BEGIN TRANSACTION;

    SELECT
        CONVERT(nvarchar(36), identityRow.DatabaseInstanceId) AS DatabaseInstanceReference,
        options.SubjectCode AS ReportingSubjectReference,
        CONVERT(bigint, @@DBTS) AS AccountingEventId,
        CONCAT(CONVERT(varchar(10), install.SQLDataVersion), '.', install.SQLRelease, '.', install.SQLBuild) AS SqlNodeVersion
    FROM App.tbDatabaseIdentity identityRow
    CROSS JOIN App.tbOptions options
    CROSS APPLY
    (
        SELECT TOP (1) SQLDataVersion, SQLRelease, SQLBuild
        FROM App.tbInstall
        ORDER BY InstallId DESC
    ) install
    WHERE identityRow.IdentityCode = 1;

    SELECT CONVERT(date, period.StartOn) AS PeriodStart,
           period.VatAdjustment AS Amount,
           period.VatAdjustmentNote AS Explanation
    FROM App.tbYearPeriod period
    WHERE period.StartOn >= @PeriodStart
      AND period.StartOn < DATEADD(day, 1, @PeriodEnd)
      AND (period.VatAdjustment <> 0 OR NULLIF(LTRIM(RTRIM(period.VatAdjustmentNote)), N'') IS NOT NULL)
    ORDER BY period.StartOn;

    DECLARE @inventory TABLE
    (
        SourceObject sysname NOT NULL PRIMARY KEY,
        CanonicalState nvarchar(max) NULL
    );

    INSERT @inventory VALUES
    (N'App.tbOptions', (SELECT Identifier, SubjectCode, VatCategoryCode, JurisdictionCode,
        CONVERT(varchar(18), RowVer, 1) RowVer FROM App.tbOptions ORDER BY Identifier FOR JSON PATH, INCLUDE_NULL_VALUES)),
    (N'App.tbYear', (SELECT YearNumber, CashStatusCode, CONVERT(varchar(18), RowVer, 1) RowVer
        FROM App.tbYear ORDER BY YearNumber FOR JSON PATH, INCLUDE_NULL_VALUES)),
    (N'App.tbYearPeriod', (SELECT YearNumber, CONVERT(date, StartOn) StartOn, MonthNumber, CashStatusCode,
        VatAdjustment, VatAdjustmentNote, CONVERT(varchar(18), RowVer, 1) RowVer
        FROM App.tbYearPeriod WHERE StartOn <= @PeriodEnd
        ORDER BY StartOn FOR JSON PATH, INCLUDE_NULL_VALUES)),
    (N'Cash.tbTaxType', (SELECT TaxTypeCode, IsEnabled, CashCode, MonthNumber, RecurrenceCode, SubjectCode, OffsetDays,
        CONVERT(varchar(18), RowVer, 1) RowVer FROM Cash.tbTaxType WHERE TaxTypeCode = 1
        ORDER BY TaxTypeCode FOR JSON PATH, INCLUDE_NULL_VALUES)),
    (N'Cash.tbCategory', (SELECT CategoryCode, CategoryTypeCode, CashPolarityCode, CashTypeCode, IsEnabled,
        CONVERT(varchar(18), RowVer, 1) RowVer FROM Cash.tbCategory ORDER BY CategoryCode FOR JSON PATH, INCLUDE_NULL_VALUES)),
    (N'Cash.tbCategoryTotal', (SELECT ParentCode, ChildCode, DisplayOrder,
        CONVERT(varchar(18), RowVer, 1) RowVer FROM Cash.tbCategoryTotal
        ORDER BY ParentCode, ChildCode FOR JSON PATH, INCLUDE_NULL_VALUES)),
    (N'Cash.tbCode', (SELECT CashCode, CategoryCode, TaxCode, IsEnabled,
        CONVERT(varchar(18), RowVer, 1) RowVer FROM Cash.tbCode ORDER BY CashCode FOR JSON PATH, INCLUDE_NULL_VALUES)),
    (N'App.tbTaxCode', (SELECT TaxCode, TaxTypeCode, RoundingCode, TaxRate, Decimals,
        CONVERT(varchar(18), RowVer, 1) RowVer FROM App.tbTaxCode WHERE TaxTypeCode = 1
        ORDER BY TaxCode FOR JSON PATH, INCLUDE_NULL_VALUES)),
    (N'Invoice.tbInvoice', (SELECT InvoiceNumber, SubjectCode, InvoiceTypeCode, CONVERT(date, InvoicedOn) InvoicedOn,
        CONVERT(varchar(18), RowVer, 1) RowVer FROM Invoice.tbInvoice
        WHERE InvoicedOn >= @PeriodStart AND InvoicedOn < DATEADD(day, 1, @PeriodEnd)
        ORDER BY InvoiceNumber FOR JSON PATH, INCLUDE_NULL_VALUES)),
    (N'Invoice.tbItem', (SELECT item.InvoiceNumber, item.CashCode, item.TaxCode, item.InvoiceValue, item.TaxValue,
        CONVERT(varchar(18), item.RowVer, 1) RowVer FROM Invoice.tbItem item
        JOIN Invoice.tbInvoice invoice ON invoice.InvoiceNumber = item.InvoiceNumber
        WHERE invoice.InvoicedOn >= @PeriodStart AND invoice.InvoicedOn < DATEADD(day, 1, @PeriodEnd)
        ORDER BY item.InvoiceNumber, item.CashCode FOR JSON PATH, INCLUDE_NULL_VALUES)),
    (N'Invoice.tbProject', (SELECT project.InvoiceNumber, project.ProjectCode, project.CashCode, project.TaxCode,
        project.InvoiceValue, project.TaxValue, CONVERT(varchar(18), project.RowVer, 1) RowVer
        FROM Invoice.tbProject project JOIN Invoice.tbInvoice invoice ON invoice.InvoiceNumber = project.InvoiceNumber
        WHERE invoice.InvoicedOn >= @PeriodStart AND invoice.InvoicedOn < DATEADD(day, 1, @PeriodEnd)
        ORDER BY project.InvoiceNumber, project.ProjectCode FOR JSON PATH, INCLUDE_NULL_VALUES)),
    (N'Subject.tbSubject', (SELECT subject.SubjectCode, subject.ExportTypeCode,
        CONVERT(varchar(18), subject.RowVer, 1) RowVer FROM Subject.tbSubject subject
        WHERE subject.SubjectCode IN
        (
            SELECT invoice.SubjectCode FROM Invoice.tbInvoice invoice
            WHERE invoice.InvoicedOn >= @PeriodStart AND invoice.InvoicedOn < DATEADD(day, 1, @PeriodEnd)
            UNION SELECT SubjectCode FROM App.tbOptions
        ) ORDER BY subject.SubjectCode FOR JSON PATH, INCLUDE_NULL_VALUES)),
    (N'Subject.tbRegistration', (SELECT registration.SubjectCode, registration.RegistrationCode,
        registration.RegistrationSchemeCode, registration.RegistrationValue, registration.ValidFrom,
        registration.ValidTo, registration.StatusCode, registration.ValueSourceCode, registration.IsReviewed,
        CONVERT(varchar(18), registration.RowVer, 1) RowVer FROM Subject.tbRegistration registration
        JOIN App.tbOptions options ON options.SubjectCode = registration.SubjectCode
        ORDER BY registration.SubjectCode, registration.RegistrationCode FOR JSON PATH, INCLUDE_NULL_VALUES)),
    (N'Cash.tbReportingProfile', (SELECT profile.SubjectCode, profile.ReportingProfileCode, profile.TaxSourceCode,
        profile.AuthorityCode, profile.ReportingTypeCode, profile.AuthorityReference, profile.ValidFrom,
        profile.ValidTo, profile.StatusCode, profile.ValueSourceCode, profile.IsReviewed,
        CONVERT(varchar(18), profile.RowVer, 1) RowVer FROM Cash.tbReportingProfile profile
        JOIN App.tbOptions options ON options.SubjectCode = profile.SubjectCode
        WHERE profile.ReportingTypeCode = 0
        ORDER BY profile.SubjectCode, profile.ReportingProfileCode FOR JSON PATH, INCLUDE_NULL_VALUES)),
    (N'Cash.tbReportingProfileSetting', (SELECT setting.SubjectCode, setting.ReportingProfileCode,
        setting.SettingCode, setting.EffectiveFrom, setting.EffectiveTo, setting.TextValue, setting.IntegerValue,
        setting.DecimalValue, setting.DateValue, setting.BooleanValue, setting.StatusCode, setting.ValueSourceCode,
        setting.IsReviewed, CONVERT(varchar(18), setting.RowVer, 1) RowVer
        FROM Cash.tbReportingProfileSetting setting
        JOIN Cash.tbReportingProfile profile ON profile.SubjectCode = setting.SubjectCode
            AND profile.ReportingProfileCode = setting.ReportingProfileCode
        JOIN App.tbOptions options ON options.SubjectCode = profile.SubjectCode
        WHERE profile.ReportingTypeCode = 0
        ORDER BY setting.SubjectCode, setting.ReportingProfileCode, setting.SettingCode, setting.EffectiveFrom
        FOR JSON PATH, INCLUDE_NULL_VALUES));

    SELECT SourceObject, COALESCE(CanonicalState, N'[]') CanonicalState FROM @inventory ORDER BY SourceObject;

    COMMIT TRANSACTION;
END;
GO
