﻿CREATE TABLE [dbo].[AspNetUsers] (
    [Id]                   NVARCHAR (450)     NOT NULL,
    [UserName]             NVARCHAR (256)     NULL,
    [NormalizedUserName]   NVARCHAR (256)     NULL,
    [Email]                NVARCHAR (256)     NULL,
    [NormalizedEmail]      NVARCHAR (256)     NULL,
    [EmailConfirmed]       BIT                NOT NULL,
    [PasswordHash]         NVARCHAR (MAX)     NULL,
    [SecurityStamp]        NVARCHAR (MAX)     NULL,
    [ConcurrencyStamp]     NVARCHAR (MAX)     NULL,
    [PhoneNumber]          NVARCHAR (MAX)     NULL,
    [PhoneNumberConfirmed] BIT                NOT NULL,
    [TwoFactorEnabled]     BIT                NOT NULL,
    [LockoutEnd]           DATETIMEOFFSET (7) NULL,
    [LockoutEnabled]       BIT                NOT NULL,
    [AccessFailedCount]    INT                NOT NULL,
    CONSTRAINT [PK_AspNetUsers] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO
CREATE NONCLUSTERED INDEX [EmailIndex]
    ON [dbo].[AspNetUsers]([NormalizedEmail] ASC);


GO
CREATE UNIQUE NONCLUSTERED INDEX [UserNameIndex]
    ON [dbo].[AspNetUsers]([NormalizedUserName] ASC) WHERE ([NormalizedUserName] IS NOT NULL);


GO
CREATE   TRIGGER dbo.AspNetUsers_TriggerInsert 
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

GO
CREATE   TRIGGER dbo.AspNetUsers_TriggerUpdate 
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
