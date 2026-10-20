CREATE PROCEDURE [App].[proc_NodeBusinessInit]
(
	@SubjectCode NVARCHAR(50),
	@BusinessName NVARCHAR(255),
	@FullName NVARCHAR(100),
	@BusinessAddress NVARCHAR(MAX),
	@BusinessEmailAddress NVARCHAR(255) = null,
	@UserEmailAddress NVARCHAR(255) = null,
	@PhoneNumber NVARCHAR(50) = null,
	@CompanyNumber NVARCHAR(20) = null,
	@VatNumber NVARCHAR(20) = null,
	@CalendarCode NVARCHAR(10),
	@JurisdictionCode NVARCHAR(10),
	@UnitOfCharge NVARCHAR(5) = NULL
)
AS
SET NOCOUNT, XACT_ABORT ON;

BEGIN TRY
	IF NOT EXISTS (SELECT 1 FROM App.tbJurisdiction WHERE JurisdictionCode = @JurisdictionCode)
		THROW 51005, 'NodeBusinessInit: jurisdiction not found.', 1;

	IF @UnitOfCharge IS NULL
		SELECT @UnitOfCharge = UocCode
		FROM App.tbJurisdiction
		WHERE JurisdictionCode = @JurisdictionCode;

	BEGIN TRAN;

	INSERT INTO Subject.tbSubject
	(
		SubjectCode,
		SubjectName,
		SubjectTypeCode,
		SubjectStatusCode,
		PhoneNumber,
		EmailAddress
	)
	VALUES
	(
		@SubjectCode,
		@BusinessName,
		4,
		1,
		@PhoneNumber,
		@BusinessEmailAddress
	);

	INSERT INTO Subject.tbVirtual
	(
		SubjectCode,
		CompanyNumber,
		VatNumber
	)
	VALUES
	(
		@SubjectCode,
		@CompanyNumber,
		@VatNumber
	);

	EXEC Subject.proc_AddContact @SubjectCode = @SubjectCode, @ContactName = @FullName;
	EXEC Subject.proc_AddAddress @SubjectCode = @SubjectCode, @Address = @BusinessAddress;

	INSERT INTO App.tbCalendar (CalendarCode, Monday, Tuesday, Wednesday, Thursday, Friday, Saturday, Sunday)
	VALUES (@CalendarCode, 1, 1, 1, 1, 1, 0, 0);
		
	INSERT INTO Usr.tbUser (UserId, UserName, LogonName, IsAdministrator, IsEnabled, CalendarCode, EmailAddress, PhoneNumber, ThemeCode)
	VALUES (CONCAT(LEFT(@FullName, 1), SUBSTRING(@FullName, CHARINDEX(' ', @FullName) + 1, 1)), @FullName, 
		SUSER_SNAME() , 1, 1, @CalendarCode, @UserEmailAddress, @PhoneNumber, 'ORANGE');

	IF NOT EXISTS (SELECT 1 FROM Web.tbTemplate WHERE TemplateFileName = 'support_request.html')
		INSERT INTO Web.tbTemplate (TemplateFileName) VALUES ('support_request.html');

	IF NOT EXISTS (SELECT 1 FROM Web.tbTemplate WHERE TemplateFileName = 'user_registration.html')
		INSERT INTO Web.tbTemplate (TemplateFileName) VALUES ('user_registration.html');

	IF NOT EXISTS (SELECT 1 FROM Web.tbTemplate WHERE TemplateFileName = 'user_registration_confirm.html')
		INSERT INTO Web.tbTemplate (TemplateFileName) VALUES ('user_registration_confirm.html');

	IF NOT EXISTS (SELECT 1 FROM Web.tbTemplate WHERE TemplateFileName = 'user_registration_admin_notify.html')
		INSERT INTO Web.tbTemplate (TemplateFileName) VALUES ('user_registration_admin_notify.html');

	DECLARE @SupportRequestTemplateId INT =
		(SELECT TemplateId FROM Web.tbTemplate WHERE TemplateFileName = 'support_request.html');

	DECLARE @UserRegistrationTemplateId INT =
		(SELECT TemplateId FROM Web.tbTemplate WHERE TemplateFileName = 'user_registration.html');

    DECLARE @RegistrationConfirmTemplateId INT =
		(SELECT TemplateId FROM Web.tbTemplate WHERE TemplateFileName = 'user_registration_confirm.html');

	DECLARE @RegstrationNotifyTemplateId INT =
		(SELECT TemplateId FROM Web.tbTemplate WHERE TemplateFileName = 'user_registration_admin_notify.html');

	INSERT INTO App.tbOptions
	(
		Identifier,
		IsInitialised,
		SubjectCode,
		RegisterName,
		DefaultPrintMode,
		BucketIntervalCode,
		BucketTypeCode,
		TaxHorizon,
		IsAutoOffsetDays,
		JurisdictionCode,
		UnitOfCharge,
		SupportRequestTemplateId,
		UserRegistrationTemplateId,
        UserRegistrationConfirmTemplateId,
        UserRegistrationAdminNotifyTemplateId
	)
	VALUES
	(
		'TC',
		0,
		@SubjectCode,
		'Event Log',
		2,
		1,
		1,
		730,
		0,
		@JurisdictionCode,
		@UnitOfCharge,
		@SupportRequestTemplateId,
		@UserRegistrationTemplateId,
        @RegistrationConfirmTemplateId,
        @RegstrationNotifyTemplateId
	);

	COMMIT TRAN;

	EXEC App.proc_RotateSymmetricKeys;

END TRY
BEGIN CATCH
	EXEC App.proc_ErrorLog;
END CATCH
