/**************************************************************************************
Trade Control
Upgrade script
Release: 3.34.3

Date: 30 March 2021
Author: IAM

Trade Control by Trade Control Ltd is licensed under GNU General Public License v3.0. 

You may obtain a copy of the License at

	https://www.gnu.org/licenses/gpl-3.0.en.html

Change log:

	https://github.com/tradecontrol/sqlnode

Instructions:
This script should be applied by the Node Configuration app.

***********************************************************************************/
go
CREATE TABLE dbo.AspNetRoleClaims(
	Id int IDENTITY(1,1) NOT NULL,
	RoleId nvarchar(450) NOT NULL,
	ClaimType nvarchar(max) NULL,
	ClaimValue nvarchar(max) NULL,
	CONSTRAINT PK_AspNetRoleClaims PRIMARY KEY CLUSTERED 
	(
		Id ASC
	)
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
go
CREATE TABLE dbo.AspNetRoles(
	Id nvarchar(450) NOT NULL,
	Name nvarchar(256) NULL,
	NormalizedName nvarchar(256) NULL,
	ConcurrencyStamp nvarchar(max) NULL,
	CONSTRAINT PK_AspNetRoles PRIMARY KEY CLUSTERED 
	(
		Id ASC
	)
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
go
CREATE TABLE dbo.AspNetUserClaims(
	Id int IDENTITY(1,1) NOT NULL,
	UserId nvarchar(450) NOT NULL,
	ClaimType nvarchar(max) NULL,
	ClaimValue nvarchar(max) NULL,
	CONSTRAINT PK_AspNetUserClaims PRIMARY KEY CLUSTERED 
	(
		Id ASC
	)
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
go
CREATE TABLE dbo.AspNetUserLogins(
	LoginProvider nvarchar(128) NOT NULL,
	ProviderKey nvarchar(128) NOT NULL,
	ProviderDisplayName nvarchar(max) NULL,
	UserId nvarchar(450) NOT NULL,
	CONSTRAINT PK_AspNetUserLogins PRIMARY KEY CLUSTERED 
	(
		LoginProvider ASC,
		ProviderKey ASC
	)
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
go
CREATE TABLE dbo.AspNetUserRoles(
	UserId nvarchar(450) NOT NULL,
	RoleId nvarchar(450) NOT NULL,
	CONSTRAINT PK_AspNetUserRoles PRIMARY KEY CLUSTERED 
	(
		UserId ASC,
		RoleId ASC
	)
) ON [PRIMARY]
go
CREATE TABLE dbo.AspNetUsers(
	Id nvarchar(450) NOT NULL,
	UserName nvarchar(256) NULL,
	NormalizedUserName nvarchar(256) NULL,
	Email nvarchar(256) NULL,
	NormalizedEmail nvarchar(256) NULL,
	EmailConfirmed bit NOT NULL,
	PasswordHash nvarchar(max) NULL,
	SecurityStamp nvarchar(max) NULL,
	ConcurrencyStamp nvarchar(max) NULL,
	PhoneNumber nvarchar(max) NULL,
	PhoneNumberConfirmed bit NOT NULL,
	TwoFactorEnabled bit NOT NULL,
	LockoutEnd datetimeoffset(7) NULL,
	LockoutEnabled bit NOT NULL,
	AccessFailedCount int NOT NULL,
	CONSTRAINT PK_AspNetUsers PRIMARY KEY CLUSTERED 
	(
		Id ASC
	)
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
go
CREATE TABLE dbo.AspNetUserTokens(
	UserId nvarchar(450) NOT NULL,
	LoginProvider nvarchar(128) NOT NULL,
	Name nvarchar(128) NOT NULL,
	Value nvarchar(max) NULL,
	CONSTRAINT PK_AspNetUserTokens PRIMARY KEY CLUSTERED 
	(
		UserId ASC,
		LoginProvider ASC,
		Name ASC
	)
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
go
CREATE NONCLUSTERED INDEX IX_AspNetRoleClaims_RoleId ON dbo.AspNetRoleClaims
(
	RoleId ASC
)
go
CREATE UNIQUE NONCLUSTERED INDEX RoleNameIndex ON dbo.AspNetRoles
(
	NormalizedName ASC
)
WHERE (NormalizedName IS NOT NULL)
go
CREATE NONCLUSTERED INDEX IX_AspNetUserClaims_UserId ON dbo.AspNetUserClaims
(
	UserId ASC
)
go
CREATE NONCLUSTERED INDEX IX_AspNetUserLogins_UserId ON dbo.AspNetUserLogins
(
	UserId ASC
)
go
CREATE NONCLUSTERED INDEX IX_AspNetUserRoles_RoleId ON dbo.AspNetUserRoles
(
	RoleId ASC
)
go
CREATE NONCLUSTERED INDEX EmailIndex ON dbo.AspNetUsers
(
	NormalizedEmail ASC
)
go
CREATE UNIQUE NONCLUSTERED INDEX UserNameIndex ON dbo.AspNetUsers
(
	NormalizedUserName ASC
)
WHERE (NormalizedUserName IS NOT NULL)
go
ALTER TABLE dbo.AspNetRoleClaims  WITH CHECK ADD  CONSTRAINT FK_AspNetRoleClaims_AspNetRoles_RoleId FOREIGN KEY(RoleId)
REFERENCES dbo.AspNetRoles (Id)
ON DELETE CASCADE
go
ALTER TABLE dbo.AspNetRoleClaims CHECK CONSTRAINT FK_AspNetRoleClaims_AspNetRoles_RoleId
go
ALTER TABLE dbo.AspNetUserClaims  WITH CHECK ADD  CONSTRAINT FK_AspNetUserClaims_AspNetUsers_UserId FOREIGN KEY(UserId)
REFERENCES dbo.AspNetUsers (Id)
ON DELETE CASCADE
go
ALTER TABLE dbo.AspNetUserClaims CHECK CONSTRAINT FK_AspNetUserClaims_AspNetUsers_UserId
go
ALTER TABLE dbo.AspNetUserLogins  WITH CHECK ADD  CONSTRAINT FK_AspNetUserLogins_AspNetUsers_UserId FOREIGN KEY(UserId)
REFERENCES dbo.AspNetUsers (Id)
ON DELETE CASCADE
go
ALTER TABLE dbo.AspNetUserLogins CHECK CONSTRAINT FK_AspNetUserLogins_AspNetUsers_UserId
go
ALTER TABLE dbo.AspNetUserRoles  WITH CHECK ADD  CONSTRAINT FK_AspNetUserRoles_AspNetRoles_RoleId FOREIGN KEY(RoleId)
REFERENCES dbo.AspNetRoles (Id)
ON DELETE CASCADE
go
ALTER TABLE dbo.AspNetUserRoles CHECK CONSTRAINT FK_AspNetUserRoles_AspNetRoles_RoleId
go
ALTER TABLE dbo.AspNetUserRoles  WITH CHECK ADD  CONSTRAINT FK_AspNetUserRoles_AspNetUsers_UserId FOREIGN KEY(UserId)
REFERENCES dbo.AspNetUsers (Id)
ON DELETE CASCADE
go
ALTER TABLE dbo.AspNetUserRoles CHECK CONSTRAINT FK_AspNetUserRoles_AspNetUsers_UserId
go
ALTER TABLE dbo.AspNetUserTokens  WITH CHECK ADD  CONSTRAINT FK_AspNetUserTokens_AspNetUsers_UserId FOREIGN KEY(UserId)
REFERENCES dbo.AspNetUsers (Id)
ON DELETE CASCADE
go
ALTER TABLE dbo.AspNetUserTokens CHECK CONSTRAINT FK_AspNetUserTokens_AspNetUsers_UserId
go
CREATE OR ALTER TRIGGER dbo.AspNetUsers_TriggerInsert 
   ON dbo.AspNetUsers
   AFTER INSERT
AS 
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY
		IF EXISTS (SELECT * FROM inserted 
					JOIN Usr.tbUser ON inserted.UserName = Usr.tbUser.EmailAddress
					WHERE Usr.tbUser.IsAdministrator <> 0)
		BEGIN
			UPDATE AspNetUsers
			SET EmailConfirmed = 1
			FROM AspNetUsers 
				JOIN inserted ON AspNetUsers.Id = inserted.Id
				JOIN Usr.tbUser ON inserted.UserName = Usr.tbUser.EmailAddress
					WHERE Usr.tbUser.IsAdministrator <> 0;

			INSERT INTO AspNetUserRoles (UserId, RoleId)
			SELECT inserted.Id UserId, (SELECT Id FROM AspNetRoles WHERE [Name] = 'Administrators') RoleId 
				FROM inserted 
					JOIN Usr.tbUser ON inserted.UserName = Usr.tbUser.EmailAddress
			WHERE Usr.tbUser.IsAdministrator <> 0
		END

		UPDATE AspNetUsers
		SET PhoneNumber = Usr.tbUser.PhoneNumber, PhoneNumberConfirmed = 1
		FROM AspNetUsers 
			JOIN inserted ON AspNetUsers.Id = inserted.Id
			JOIN Usr.tbUser ON inserted.UserName = Usr.tbUser.EmailAddress;
	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH

END
go
CREATE OR ALTER TRIGGER dbo.AspNetUsers_TriggerUpdate 
   ON dbo.AspNetUsers
   AFTER UPDATE
AS 
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY

		IF UPDATE (EmailConfirmed)
			AND NOT EXISTS (SELECT * FROM inserted  JOIN Usr.tbUser ON inserted.Email = Usr.tbUser.EmailAddress )
		BEGIN			
			ROLLBACK TRANSACTION;
			EXEC App.proc_EventLog 'Unregistered ASP.NET users cannot be confirmed';
		END

		IF UPDATE (PhoneNumber)
		BEGIN
			UPDATE Usr.tbUser
			SET PhoneNumber = inserted.PhoneNumber
			FROM inserted
				JOIN Usr.tbUser u ON inserted.UserName = u.EmailAddress
		END

	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH

END
go
CREATE OR ALTER VIEW dbo.AspNetUserRegistrations
AS
	SELECT asp.Id, asp.UserName EmailAddress, u.UserName,
		asp.EmailConfirmed IsConfirmed, 
		CAST(CASE WHEN u.EmailAddress IS NULL THEN 0 ELSE 1 END as bit) IsRegistered,
		CAST(CASE WHEN 
			(SELECT COUNT(*) FROM AspNetUserRoles 
				JOIN AspNetRoles ON AspNetRoles.Id = AspNetUserRoles.RoleId 
				WHERE AspNetRoles.Name = 'Administrators' AND AspNetUserRoles.UserId = asp.Id) = 0 
		THEN 0 
		ELSE 1 
		END as bit) IsAdministrator,
		CAST(CASE WHEN 
			(SELECT COUNT(*) FROM AspNetUserRoles 
				JOIN AspNetRoles ON AspNetRoles.Id = AspNetUserRoles.RoleId 
				WHERE AspNetRoles.Name = 'Managers' AND AspNetUserRoles.UserId = asp.Id) = 0 
		THEN 0 
		ELSE 1 
		END as bit) IsManager
	FROM AspNetUsers asp
		LEFT OUTER JOIN Usr.tbUser u ON asp.Email = u.EmailAddress;
go
CREATE OR ALTER PROCEDURE dbo.AspNetGetUserId(@Id nvarchar(450), @UserId nvarchar(10) OUTPUT)
AS
	SET NOCOUNT, XACT_ABORT ON;
	BEGIN TRY
	
		WITH asp AS
		(
			SELECT Id, UserName
			FROM AspNetUsers 
			WHERE Id = @Id
		)
		SELECT @UserId = UserId 
		FROM asp JOIN Usr.tbUser u ON asp.UserName = u.EmailAddress;

	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
go
CREATE OR ALTER PROCEDURE dbo.AspNetGetUserName(@Id nvarchar(450), @UserName nvarchar(50) OUTPUT)
AS
	SET NOCOUNT, XACT_ABORT ON;
	BEGIN TRY
	
		SELECT @UserName = u.UserName
		FROM AspNetUsers asp JOIN Usr.tbUser u ON asp.UserName = u.EmailAddress
		WHERE asp.Id = @Id;

	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
go
CREATE OR ALTER PROCEDURE dbo.AspNetGetId(@UserId nvarchar(10), @Id nvarchar(450) OUTPUT)
AS
	SET NOCOUNT, XACT_ABORT ON;
	BEGIN TRY
	
		SELECT @Id = UserId 
		FROM AspNetUsers asp JOIN Usr.tbUser u ON asp.UserName = u.EmailAddress
		WHERE u.UserId = @UserId;

	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
go

	