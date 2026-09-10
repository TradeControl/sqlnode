CREATE PROCEDURE [Cash].[proc_ReportingProfileSave]
(
    @SubjectCode NVARCHAR(50),
    @ReportingTypeCode NVARCHAR(20),
    @TaxSourceCode NVARCHAR(20),
    @AuthorityReference NVARCHAR(100) = NULL,
    @ValidFrom DATE,
    @ValidTo DATE = NULL,
    @StatusCode SMALLINT = 0,
    @ValueSourceCode NVARCHAR(10) = N'USER',
    @IsReviewed BIT = 0,
    @ReportingProfileCode NVARCHAR(20) = NULL OUTPUT
)
AS
    SET NOCOUNT, XACT_ABORT ON;

    BEGIN TRY
        DECLARE @AuthorityCode NVARCHAR(20) =
        (
            SELECT AuthorityCode
            FROM App.tbReportingType
            WHERE ReportingTypeCode = @ReportingTypeCode
              AND IsEnabled = 1
        );

        IF @AuthorityCode IS NULL
            THROW 51031, 'An enabled reporting type is required.', 1;

        IF @StatusCode = 1 AND @IsReviewed = 0
            THROW 51032, 'An active reporting profile must be reviewed.', 1;

        IF @ReportingProfileCode IS NULL
            EXEC Cash.proc_DefaultReportingProfileCode
                @SubjectCode = @SubjectCode,
                @ReportingTypeCode = @ReportingTypeCode,
                @ReportingProfileCode = @ReportingProfileCode OUTPUT;

        IF EXISTS
        (
            SELECT 1
            FROM Cash.tbReportingProfile
            WHERE SubjectCode = @SubjectCode
              AND ReportingProfileCode = @ReportingProfileCode
        )
            UPDATE Cash.tbReportingProfile
            SET TaxSourceCode = @TaxSourceCode,
                AuthorityCode = @AuthorityCode,
                ReportingTypeCode = @ReportingTypeCode,
                AuthorityReference = NULLIF(LTRIM(RTRIM(@AuthorityReference)), N''),
                ValidFrom = @ValidFrom,
                ValidTo = @ValidTo,
                StatusCode = @StatusCode,
                ValueSourceCode = @ValueSourceCode,
                IsReviewed = @IsReviewed,
                UpdatedBy = suser_sname(),
                UpdatedOn = current_timestamp
            WHERE SubjectCode = @SubjectCode
              AND ReportingProfileCode = @ReportingProfileCode;
        ELSE
            INSERT Cash.tbReportingProfile
            (
                SubjectCode, ReportingProfileCode, TaxSourceCode, AuthorityCode,
                ReportingTypeCode, AuthorityReference, ValidFrom, ValidTo,
                StatusCode, ValueSourceCode, IsReviewed
            )
            VALUES
            (
                @SubjectCode, @ReportingProfileCode, @TaxSourceCode, @AuthorityCode,
                @ReportingTypeCode, NULLIF(LTRIM(RTRIM(@AuthorityReference)), N''), @ValidFrom, @ValidTo,
                @StatusCode, @ValueSourceCode, @IsReviewed
            );
    END TRY
    BEGIN CATCH
        EXEC App.proc_ErrorLog;
    END CATCH;
GO
