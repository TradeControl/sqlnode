/**************************************************************************************
Trade Control
Upgrade script
Release: 3.28.2

Date: 01 July 2020
Author: IAM

Trade Control by Trade Control Ltd is licensed under GNU General Public License v3.0. 

You may obtain a copy of the License at

	https://www.gnu.org/licenses/gpl-3.0.en.html

Change log:

	https://github.com/tradecontrol/sqlnode

Instructions:
This script should be applied by the TC Node Configuration app.
It inserts the upgade into App.tbInstall.


***********************************************************************************/
go
ALTER VIEW App.vwIdentity
AS
SELECT        TOP (1) Org.tbOrg.AccountName, Org.tbAddress.Address, Org.tbOrg.PhoneNumber, Org.tbOrg.EmailAddress, Org.tbOrg.WebSite, Org.tbOrg.Logo, Usr.tbUser.UserName, Usr.tbUser.LogonName, Usr.tbUser.Avatar, 
                         Org.tbOrg.CompanyNumber, Org.tbOrg.VatNumber, App.tbUoc.UocName, App.tbUoc.UocSymbol
FROM            Org.tbOrg INNER JOIN
                         Org.tbAddress ON Org.tbOrg.AddressCode = Org.tbAddress.AddressCode INNER JOIN
                         App.tbOptions ON Org.tbOrg.AccountCode = App.tbOptions.AccountCode INNER JOIN
                         App.tbUoc ON App.tbOptions.UnitOfCharge = App.tbUoc.UnitOfCharge CROSS JOIN
                         Usr.vwCredentials INNER JOIN
                         Usr.tbUser ON Usr.vwCredentials.UserId = Usr.tbUser.UserId;

go
CREATE TABLE Cash.tbCoinType
(
	CoinTypeCode smallint NOT NULL,
	CoinType nvarchar(20) NOT NULL,
	CONSTRAINT PK_Cash_tbCoinType PRIMARY KEY CLUSTERED (CoinTypeCode)
);
go
INSERT INTO Cash.tbCoinType (CoinTypeCode, CoinType)
VALUES (0, 'Main'), (1, 'TestNet'), (2, 'Fiat');
go
ALTER TABLE Org.tbAccount WITH NOCHECK ADD
	CoinTypeCode smallint NOT NULL CONSTRAINT DF_Org_tbAccount_CoinTypeCode DEFAULT (2)
go
ALTER TABLE Org.tbAccount  WITH CHECK ADD CONSTRAINT FK_Org_tbAccount_Cash_tbCoinType FOREIGN KEY(CoinTypeCode)
REFERENCES Cash.tbCoinType (CoinTypeCode)
go
CREATE OR ALTER PROCEDURE Cash.proc_CoinType(@CoinTypeCode smallint output)
AS
	SET NOCOUNT, XACT_ABORT ON;

	BEGIN TRY
	
		DECLARE @CashAccountCode nvarchar(10);

		EXEC Cash.proc_CurrentAccount @CashAccountCode output
		SELECT @CoinTypeCode = CoinTypeCode FROM Org.tbAccount WHERE CashAccountCode = @CashAccountCode

	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
go
ALTER TABLE App.tbOptions WITH NOCHECK ADD
	MinerFeeCode nvarchar(50) NULL,
	MinerAccountCode nvarchar(10) NULL;
go
ALTER TABLE App.tbOptions  WITH CHECK ADD CONSTRAINT FK_App_tbOptions_Cash_tbCode FOREIGN KEY(MinerFeeCode)
REFERENCES Cash.tbCode (CashCode)
go
ALTER TABLE App.tbOptions  WITH CHECK ADD CONSTRAINT FK_App_tbOptions_Org_tbOrg FOREIGN KEY(MinerAccountCode)
REFERENCES Org.tbOrg (AccountCode)
go
ALTER VIEW Org.vwAccountLookup
AS
SELECT        Org.tbOrg.AccountCode, Org.tbOrg.AccountName, Org.tbType.OrganisationType, Cash.tbMode.CashMode, Cash.tbMode.CashModeCode
FROM            Org.tbOrg INNER JOIN
                         Org.tbType ON Org.tbOrg.OrganisationTypeCode = Org.tbType.OrganisationTypeCode INNER JOIN
                         Cash.tbMode ON Org.tbType.CashModeCode = Cash.tbMode.CashModeCode
WHERE        (Org.tbOrg.OrganisationStatusCode < 3);
go
ALTER VIEW Cash.vwCodeLookup
AS
	SELECT        Cash.tbCode.CashCode, Cash.tbCode.CashDescription, Cash.tbCategory.Category, Cash.tbMode.CashModeCode, Cash.tbMode.CashMode, Cash.tbCode.TaxCode, Cash.tbCategory.CashTypeCode, Cash.tbType.CashType
	FROM            Cash.tbCode INNER JOIN
							 Cash.tbCategory ON Cash.tbCode.CategoryCode = Cash.tbCategory.CategoryCode INNER JOIN
							 Cash.tbMode ON Cash.tbCategory.CashModeCode = Cash.tbMode.CashModeCode INNER JOIN
							 Cash.tbType ON Cash.tbCategory.CashTypeCode = Cash.tbType.CashTypeCode
	WHERE        (Cash.tbCode.IsEnabled <> 0) AND (Cash.tbCategory.IsEnabled <> 0)
go
CREATE TABLE Org.tbAccountKey
(
	CashAccountCode nvarchar(10) NOT NULL,
	HDPath hierarchyid NOT NULL,
	KeyName nvarchar(50) NOT NULL,
	HDLevel as HDPath.GetLevel(),
	CONSTRAINT PK_Org_tbAccountKey PRIMARY KEY NONCLUSTERED (CashAccountCode, HDPath)
);
go
CREATE NONCLUSTERED INDEX IX_Org_tbAccountKey_HDLevel ON Org.tbAccountKey (CashAccountCode, HDLevel, HDPath);
go
CREATE UNIQUE NONCLUSTERED INDEX IX_Org_tbAccountKey_KeyName ON Org.tbAccountKey (CashAccountCode, KeyName);
go
ALTER TABLE Org.tbAccountKey  WITH CHECK ADD CONSTRAINT FK_Org_tbAccountKey_Org_tbAccount FOREIGN KEY(CashAccountCode)
REFERENCES Org.tbAccount (CashAccountCode)
ON UPDATE CASCADE
ON DELETE CASCADE
go
ALTER TABLE Org.tbAccountKey CHECK CONSTRAINT FK_Org_tbAccountKey_Org_tbAccount
go
CREATE OR ALTER VIEW Org.vwWallets
AS
	SELECT        Org.tbAccount.CashAccountCode, Org.tbAccount.CashAccountName, Org.tbAccount.CashCode, Org.tbAccount.CoinTypeCode
	FROM            Org.tbAccount INNER JOIN
							 App.tbOptions ON Org.tbAccount.AccountCode = App.tbOptions.AccountCode LEFT OUTER JOIN
							 Cash.tbCode ON Org.tbAccount.CashCode = Cash.tbCode.CashCode
	WHERE        (Org.tbAccount.DummyAccount = 0) AND Org.tbAccount.CoinTypeCode < 2;
go
CREATE OR ALTER PROCEDURE Org.proc_WalletInitialise
AS
	SET NOCOUNT, XACT_ABORT OFF;

	BEGIN TRY
		WITH wallets AS
		(
			SELECT wallet.CashAccountCode
			FROM Org.vwWallets AS wallet 
				LEFT OUTER JOIN Org.tbAccountKey AS nspace ON wallet.CashAccountCode = nspace.CashAccountCode
			WHERE        (nspace.CashAccountCode IS NULL)
		), hdrootName AS
		(
			SELECT AccountName KeyName
			FROM Org.tbOrg orgs
				JOIN App.tbOptions opts ON opts.AccountCode = orgs.AccountCode
		)
		INSERT INTO Org.tbAccountKey (CashAccountCode, HDPath, KeyName)
		SELECT CashAccountCode, '/' HDPath, (SELECT KeyName FROM hdrootName) KeyName
		FROM wallets;
	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
go
CREATE OR ALTER PROCEDURE Org.proc_AccountKeyAdd (@CashAccountCode nvarchar (10), @ParentName nvarchar(50), @ChildName nvarchar(50), @ChildHDPath nvarchar(50) output)
AS
	SET NOCOUNT, XACT_ABORT OFF;

	BEGIN TRY

		DECLARE @ParentId hierarchyid = (SELECT HDPath FROM Org.tbAccountKey WHERE CashAccountCode = @CashAccountCode AND KeyName = @ParentName);
		DECLARE @ChildId hierarchyId = (SELECT MAX(HDPath) FROM Org.tbAccountKey WHERE HDPath.GetAncestor(1) = @ParentId);

		IF (App.fnParsePrimaryKey(@ChildName) <> 0 AND CHARINDEX('.', @ChildName) = 0)
			BEGIN
				SET @ChildId = @ParentId.GetDescendant(@ChildId, NULL);

				INSERT INTO Org.tbAccountKey (CashAccountCode, HDPath, KeyName)
				SELECT @CashAccountCode CashAccountCode, 
					@ChildId HDPath, 
					@ChildName KeyName;

				SET @ChildHDPath = REPLACE(@ChildId.ToString(), '/', '''/'); 
				SET @ChildHDPath = RIGHT(@ChildHDPath, LEN(@ChildHDPath) - 1);
				SET @ChildHDPath = ( SELECT CONCAT('44/', CoinTypeCode, '/0', @ChildHDPath) FROM Org.tbAccount WHERE CashAccountCode = @CashAccountCode)
				
			END
		ELSE
			BEGIN
				DECLARE @Msg nvarchar(MAX) = (SELECT TOP (1) [Message] FROM App.tbText WHERE TextId = 2004);
				THROW 50000, @Msg, 1;				
			END

	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
go
CREATE OR ALTER PROCEDURE Org.proc_AccountKeyRename(@CashAccountCode nvarchar (10), @OldKeyName nvarchar(50), @NewKeyName nvarchar(50), @KeyNamespace nvarchar(1024) output)
AS
	SET NOCOUNT, XACT_ABORT OFF;

	BEGIN TRY

		UPDATE Org.tbAccountKey
		SET KeyName = @NewKeyName
		WHERE CashAccountCode = @CashAccountCode AND KeyName = @OldKeyName;

		WITH namespaced AS
		(
			SELECT CashAccountCode, HDPath, CAST(KeyName as nvarchar(1024)) KeyNamespace, HDPath.GetLevel() HDLevel
			FROM Org.tbAccountKey
			WHERE CashAccountCode = @CashAccountCode AND KeyName = @NewKeyName

			UNION ALL

			SELECT parent.CashAccountCode, parent.HDPath, CAST(CONCAT(parent.KeyName, '.', namespaced.KeyNamespace) as nvarchar(1024)) KeyNamespace, parent.HDPath.GetLevel() HDLevel
			FROM Org.tbAccountKey parent
				JOIN namespaced ON parent.CashAccountCode = namespaced.CashAccountCode AND parent.HDPath = namespaced.HDPath.GetAncestor(1)
		)
		SELECT @KeyNamespace = REPLACE(UPPER(KeyNamespace), ' ', '_') 
		FROM namespaced
		WHERE HDLevel = 0;

	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
go
CREATE OR ALTER PROCEDURE Org.proc_AccountKeyDelete(@CashAccountCode nvarchar(10), @KeyName nvarchar(50))
AS
	SET NOCOUNT, XACT_ABORT OFF;

	BEGIN TRY	

		WITH root_level AS
		(
			SELECT CashAccountCode, CAST(NULL as hierarchyid) Ancestor, HDPath, HDPath.GetLevel() Lv
			FROM Org.tbAccountKey 
			WHERE CashAccountCode = @CashAccountCode AND KeyName = @KeyName
		), candidates AS
		(
			SELECT ns.CashAccountCode, ns.HDPath.GetAncestor(1) Ancestor, ns.HDPath, ns.HDPath.GetLevel() Lv
			FROM Org.tbAccountKey ns 
				JOIN root_level ON ns.CashAccountCode = root_level.CashAccountCode
			WHERE ns.HDPath.GetLevel() > root_level.Lv
		), selected AS
		(
			SELECT CashAccountCode, Ancestor, HDPath FROM root_level
		
			UNION ALL

			SELECT candidates.CashAccountCode, candidates.Ancestor, candidates.HDPath
			FROM candidates
				JOIN selected ON selected.HDPath = candidates.Ancestor
		)
		DELETE Org.tbAccountKey
		FROM selected
			JOIN Org.tbAccountKey ON Org.tbAccountKey.CashAccountCode = selected.CashAccountCode AND Org.tbAccountKey.HDPath = selected.HDPath;

	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
go
ALTER TABLE Invoice.tbMirror WITH NOCHECK ADD
	PaymentAddress nvarchar(42) null
go
ALTER TABLE Invoice.tbMirrorEvent WITH NOCHECK ADD
	PaymentAddress nvarchar(42) null
go
ALTER VIEW Invoice.vwRegisterPurchasesOverdue
AS
SELECT        TOP (100) PERCENT Invoice.tbInvoice.InvoiceNumber, Invoice.tbInvoice.AccountCode, Org.tbOrg.AccountName, Invoice.tbInvoice.InvoiceTypeCode, Invoice.tbInvoice.InvoiceStatusCode, Invoice.tbStatus.InvoiceStatus, 
                         Invoice.tbType.InvoiceType, DATEDIFF(DD, CURRENT_TIMESTAMP, Invoice.tbInvoice.InvoicedOn) AS UnpaidDays, Invoice.tbInvoice.InvoicedOn, Invoice.tbInvoice.DueOn, Invoice.tbInvoice.ExpectedOn, 
                         CASE Invoice.tbType.CashModeCode WHEN 0 THEN Invoice.tbInvoice.InvoiceValue ELSE Invoice.tbInvoice.InvoiceValue * - 1 END AS InvoiceValue, 
                         CASE Invoice.tbType.CashModeCode WHEN 0 THEN Invoice.tbInvoice.TaxValue ELSE Invoice.tbInvoice.TaxValue * - 1 END AS TaxValue, 
                         CASE Invoice.tbType.CashModeCode WHEN 0 THEN (Invoice.tbInvoice.InvoiceValue + Invoice.tbInvoice.TaxValue) - (Invoice.tbInvoice.PaidValue + Invoice.tbInvoice.PaidTaxValue) 
                         ELSE ((Invoice.tbInvoice.InvoiceValue + Invoice.tbInvoice.TaxValue) - (Invoice.tbInvoice.PaidValue + Invoice.tbInvoice.PaidTaxValue)) * - 1 END AS UnpaidValue, Invoice.tbMirror.PaymentAddress, 
                         Invoice.tbInvoice.PaymentTerms, Invoice.tbInvoice.Notes
FROM            Invoice.tbInvoice INNER JOIN
                         Invoice.tbStatus ON Invoice.tbInvoice.InvoiceStatusCode = Invoice.tbStatus.InvoiceStatusCode INNER JOIN
                         Invoice.tbType ON Invoice.tbInvoice.InvoiceTypeCode = Invoice.tbType.InvoiceTypeCode INNER JOIN
                         Org.tbOrg ON Invoice.tbInvoice.AccountCode = Org.tbOrg.AccountCode LEFT OUTER JOIN
                         Invoice.tbMirrorReference ON Invoice.tbInvoice.InvoiceNumber = Invoice.tbMirrorReference.InvoiceNumber LEFT OUTER JOIN
                         Invoice.tbMirror ON Invoice.tbMirrorReference.ContractAddress = Invoice.tbMirror.ContractAddress
WHERE        (Invoice.tbInvoice.InvoiceTypeCode > 1) AND (Invoice.tbInvoice.InvoiceStatusCode < 3)

go
INSERT INTO App.tbEventType (EventTypeCode, EventType)
VALUES (8, 'Pay Address');
go
INSERT INTO App.tbText (TextId, [Message], Arguments) VALUES (1224, 'Raise corresponding invoices?', 0);
go
CREATE TABLE Cash.tbChangeType
(
	ChangeTypeCode smallint NOT NULL,
	ChangeType nvarchar(20) NOT NULL,
	CONSTRAINT PK_Cash_tbChangeType PRIMARY KEY CLUSTERED (ChangeTypeCode)
);
go
INSERT INTO Cash.tbChangeType (ChangeTypeCode, ChangeType) 
VALUES (0, 'Receipt'), (1, 'Change');
go
CREATE TABLE Cash.tbChangeStatus
(
	ChangeStatusCode smallint NOT NULL,
	ChangeStatus nvarchar(20) NOT NULL,
	CONSTRAINT PK_Cash_tbChangeStatus PRIMARY KEY CLUSTERED (ChangeStatusCode)
);
go
INSERT INTO Cash.tbChangeStatus (ChangeStatusCode, ChangeStatus) 
VALUES (0, 'Unused'), (1, 'Paid'), (2, 'Spent');
go
CREATE TABLE Cash.tbChange
(
	PaymentAddress nvarchar(42) NOT NULL,
	CashAccountCode nvarchar(10) NOT NULL,
	HDPath hierarchyid NOT NULL,
	ChangeTypeCode smallint NOT NULL CONSTRAINT DF_Cash_tbChange_ChangeTypeCode DEFAULT (0),
	ChangeStatusCode smallint NOT NULL CONSTRAINT DF_Cash_tbChange_ChangeStatusCode DEFAULT (0),
	AddressIndex INT NOT NULL CONSTRAINT DF_Cash_tbChange_AddressIndex DEFAULT (0),
	Note nvarchar(256) NULL,
	UpdatedOn datetime NOT NULL CONSTRAINT DF_Cash_tbChange_UpdatedOn DEFAULT (getdate()),
	UpdatedBy nvarchar(50) NOT NULL CONSTRAINT DF_Cash_tbChange_UpdatedBy DEFAULT (suser_sname()),
	InsertedOn datetime NOT NULL CONSTRAINT DF_Cash_tbChange_InsertedOn DEFAULT (getdate()),
	InsertedBy nvarchar(50) NOT NULL CONSTRAINT DF_Cash_tbChange_InsertedBy DEFAULT (suser_sname()),
	RowVer timestamp NOT NULL,
	CONSTRAINT PK_Cash_tbChange PRIMARY KEY CLUSTERED (PaymentAddress)
);
go
CREATE UNIQUE INDEX IX_Cash_tbChange_ChangeTypeCode ON Cash.tbChange (CashAccountCode, HDPath, ChangeTypeCode, ChangeStatusCode, AddressIndex);
go
CREATE INDEX IX_Cash_tbChange_ChangeStatusCode ON Cash.tbChange (CashAccountCode, ChangeStatusCode, AddressIndex);
go
CREATE INDEX IX_Cash_tbChange_UpdatedOn ON Cash.tbChange(CashAccountCode, HDPath, UpdatedOn DESC);
go
ALTER TABLE Cash.tbChange  WITH CHECK ADD CONSTRAINT FK_Cash_tbChange_Org_tbAccountKey FOREIGN KEY(CashAccountCode, HDPath)
REFERENCES Org.tbAccountKey (CashAccountCode, HDPath)
ON UPDATE CASCADE
ON DELETE CASCADE;
go
ALTER TABLE Cash.tbChange WITH CHECK ADD CONSTRAINT FK__Cash_tbChange_Cash_tbChangeType FOREIGN KEY (ChangeTypeCode)
REFERENCES Cash.tbChangeType (ChangeTypeCode);
go
CREATE OR ALTER TRIGGER Cash.Cash_tbChange_TriggerUpdate
   ON  Cash.tbChange
   AFTER UPDATE
AS 
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY
		UPDATE Cash.tbChange
		SET UpdatedBy = SUSER_SNAME(), UpdatedOn = CURRENT_TIMESTAMP
		FROM Cash.tbChange INNER JOIN inserted AS i ON Cash.tbChange.PaymentAddress = i.PaymentAddress;
	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
END
go
CREATE TABLE Cash.tbChangeReference
(
	PaymentAddress nvarchar(42) NOT NULL,
	InvoiceNumber nvarchar(20) NOT NULL
	CONSTRAINT PK_Cash_tbChangeReference PRIMARY KEY CLUSTERED (PaymentAddress)
);
CREATE UNIQUE INDEX IX_Cash_tbChangeReference_InvoiceNumber ON Cash.tbChangeReference (InvoiceNumber);
go
ALTER TABLE Cash.tbChangeReference  WITH CHECK ADD CONSTRAINT FK_Cash_tbChangeReferencee_Cash_tbChange FOREIGN KEY(PaymentAddress)
REFERENCES Cash.tbChange (PaymentAddress);
go
ALTER TABLE Cash.tbChangeReference  WITH CHECK ADD CONSTRAINT FK_Cash_tbChangeReferencee_Invoice_tbInvoice FOREIGN KEY(InvoiceNumber)
REFERENCES Invoice.tbInvoice (InvoiceNumber);
go
CREATE OR ALTER TRIGGER Cash.Cash_tbChangeReference_TriggerInsert
ON Cash.tbChangeReference
FOR INSERT, UPDATE
AS
	SET NOCOUNT ON;
	BEGIN TRY
		INSERT INTO Invoice.tbChangeLog (InvoiceNumber, TransmitStatusCode, InvoiceStatusCode, DueOn, InvoiceValue, TaxValue, PaidValue, PaidTaxValue)
		SELECT invoices.InvoiceNumber, 2 TransmitStatusCode, InvoiceStatusCode, DueOn, InvoiceValue, TaxValue, PaidValue, PaidTaxValue
		FROM Cash.tbChangeReference inserted 
			JOIN Invoice.tbInvoice invoices ON inserted.InvoiceNumber = invoices.InvoiceNumber;
	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH

go
ALTER VIEW Invoice.vwRegisterSalesOverdue
AS
	SELECT        TOP (100) PERCENT Invoice.tbInvoice.InvoiceNumber, Invoice.tbInvoice.AccountCode, Org.tbOrg.AccountName, Invoice.tbInvoice.InvoiceTypeCode, Invoice.tbInvoice.InvoiceStatusCode, Invoice.tbStatus.InvoiceStatus, 
							 Invoice.tbType.InvoiceType, DATEDIFF(DD, CURRENT_TIMESTAMP, Invoice.tbInvoice.InvoicedOn) AS UnpaidDays, Invoice.tbInvoice.InvoicedOn, Invoice.tbInvoice.DueOn, Invoice.tbInvoice.ExpectedOn, 
							 CASE CashModeCode WHEN 1 THEN Invoice.tbInvoice.InvoiceValue ELSE Invoice.tbInvoice.InvoiceValue * - 1 END AS InvoiceValue, 
							 CASE CashModeCode WHEN 1 THEN Invoice.tbInvoice.TaxValue ELSE Invoice.tbInvoice.TaxValue * - 1 END AS TaxValue, CASE CashModeCode WHEN 1 THEN (Invoice.tbInvoice.InvoiceValue + Invoice.tbInvoice.TaxValue) 
							 - (Invoice.tbInvoice.PaidValue + Invoice.tbInvoice.PaidTaxValue) ELSE ((Invoice.tbInvoice.InvoiceValue + Invoice.tbInvoice.TaxValue) - (Invoice.tbInvoice.PaidValue + Invoice.tbInvoice.PaidTaxValue)) * - 1 END AS UnpaidValue, 
							 Cash.tbChangeReference.PaymentAddress, Invoice.tbInvoice.PaymentTerms, Invoice.tbInvoice.Notes
	FROM            Invoice.tbInvoice INNER JOIN
							 Invoice.tbStatus ON Invoice.tbInvoice.InvoiceStatusCode = Invoice.tbStatus.InvoiceStatusCode INNER JOIN
							 Invoice.tbType ON Invoice.tbInvoice.InvoiceTypeCode = Invoice.tbType.InvoiceTypeCode INNER JOIN
							 Org.tbOrg ON Invoice.tbInvoice.AccountCode = Org.tbOrg.AccountCode LEFT OUTER JOIN
							 Cash.tbChangeReference ON Invoice.tbInvoice.InvoiceNumber = Cash.tbChangeReference.InvoiceNumber
	WHERE        (Invoice.tbInvoice.InvoiceTypeCode < 2) AND (Invoice.tbInvoice.InvoiceStatusCode < 3)

go
CREATE OR ALTER VIEW Org.vwNamespace
AS

	WITH ancestors AS
	(
		SELECT CashAccountCode, HDPath.GetAncestor(1) Ancestor, HDPath, KeyName
		FROM Org.tbAccountKey
	), parent_child AS
	(
		SELECT nspace.CashAccountCode, nspace.HDPath parent, nspace.KeyName parentLoc, ancestors.HDPath child, ancestors.KeyName childLoc, ancestors.HDPath.GetLevel() KeyLevel
		FROM ancestors JOIN Org.tbAccountKey nspace ON ancestors.CashAccountCode = nspace.CashAccountCode AND ancestors.Ancestor = nspace.HDPath
	), namespaced AS
	(
		SELECT CashAccountCode, cast(NULL AS hierarchyid) ParentHDPath, HDPath ChildHDPath, cast(KeyName AS nvarchar(1024)) KeyNamespace, HDPath.GetLevel() KeyLevel
		FROM Org.tbAccountKey
		WHERE HDPath = (SELECT DISTINCT hierarchyid::GetRoot() r FROM Org.tbAccountKey)

		UNION ALL

		SELECT parent_child.CashAccountCode, parent_child.parent ParentHDPath, parent_child.child ChildHDPath, cast(namespaced.KeyNamespace + '.' + parent_child.childLoc AS nvarchar(1024)) KeyNamespace, parent_child.KeyLevel
		FROM parent_child JOIN namespaced ON parent_child.CashAccountCode = namespaced.CashAccountCode AND parent_child.parent = namespaced.ChildHDPath
	)
	, hardened AS
	(
		SELECT namespaced.CashAccountCode, account.CoinTypeCode, namespaced.ChildHDPath HDPath, 
			REPLACE(namespaced.ParentHDPath.ToString(), '/', '''/') ParentHDPath, 
			REPLACE(namespaced.ChildHDPath.ToString(), '/', '''/') ChildHDPath, 
			KeyName, 
			REPLACE(UPPER(KeyNamespace), ' ', '_') KeyNamespace, 
			KeyLevel
		FROM namespaced
			JOIN Org.tbAccount account ON namespaced.CashAccountCode = account.CashAccountCode
			JOIN  Org.tbAccountKey ON namespaced.CashAccountCode = Org.tbAccountKey.CashAccountCode 
				AND namespaced.ChildHDPath = Org.tbAccountKey.HDPath
	)
	SELECT CashAccountCode,  -- HDPath, not supported VS
		CONCAT('44', '''', '/', CoinTypeCode, '''', CAST(RIGHT(ParentHDPath, LEN(ParentHDPath) - 1) AS nvarchar(50))) ParentHDPath, 
		CONCAT('44', '''', '/', CoinTypeCode, '''', CAST(RIGHT(ChildHDPath, LEN(ChildHDPath) - 1) AS nvarchar(50))) ChildHDPath, 
		KeyName,
		CAST(KeyNamespace AS nvarchar(1024)) KeyNamespace, KeyLevel, COALESCE(ReceiptIndex, 0) ReceiptIndex, COALESCE(ChangeIndex, 0) ChangeIndex 
	FROM hardened
		OUTER APPLY
		(
			SELECT COUNT(*) ReceiptIndex 
			FROM Cash.tbChange change
			WHERE change.CashAccountCode = hardened.CashAccountCode AND change.HDPath = hardened.HDPath AND ChangeTypeCode = 0
		) receipts
		OUTER APPLY
		(
			SELECT COUNT(*) ChangeIndex 
			FROM Cash.tbChange change
			WHERE change.CashAccountCode = hardened.CashAccountCode AND change.HDPath = hardened.HDPath AND ChangeTypeCode = 1
		) change;
go
ALTER PROCEDURE Cash.proc_CurrentAccount(@CashAccountCode NVARCHAR(10) OUTPUT)
AS
	SET NOCOUNT, XACT_ABORT ON;
	BEGIN TRY
		SELECT  @CashAccountCode = Org.tbAccount.CashAccountCode
		FROM Org.tbAccount 
			JOIN Cash.tbCode ON Org.tbAccount.CashCode = Cash.tbCode.CashCode 
			JOIN Cash.tbCategory ON Cash.tbCode.CategoryCode = Cash.tbCategory.CategoryCode
		WHERE (Cash.tbCategory.CashTypeCode = 2);

	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
go

ALTER TRIGGER Invoice.Invoice_tbMirror_TriggerUpdate
ON Invoice.tbMirror
FOR UPDATE
AS
	SET NOCOUNT ON;

	BEGIN TRY

		IF UPDATE(InvoiceStatusCode)
		BEGIN
			INSERT INTO Invoice.tbMirrorEvent (ContractAddress, EventTypeCode, InvoiceStatusCode, DueOn, PaidValue, PaidTaxValue)
			SELECT i.ContractAddress, 6 EventTypeCode, i.InvoiceStatusCode, i.DueOn, i.PaidValue, i.PaidTaxValue
			FROM inserted i
				JOIN deleted d ON i.ContractAddress = d.ContractAddress
			WHERE d.InvoiceStatusCode <> i.InvoiceStatusCode;	
		END

		IF UPDATE(DueOn)
		BEGIN
			INSERT INTO Invoice.tbMirrorEvent (ContractAddress, EventTypeCode, InvoiceStatusCode, DueOn, PaidValue, PaidTaxValue)
			SELECT i.ContractAddress, 4 EventTypeCode, i.InvoiceStatusCode, i.DueOn, i.PaidValue, i.PaidTaxValue
			FROM inserted i
				JOIN deleted d ON i.ContractAddress = d.ContractAddress
			WHERE d.DueOn <> i.DueOn;
		END

		IF UPDATE(PaidValue) OR UPDATE(PaidTaxValue)
		BEGIN
			INSERT INTO Invoice.tbMirrorEvent (ContractAddress, EventTypeCode, InvoiceStatusCode, DueOn, PaidValue, PaidTaxValue)
			SELECT i.ContractAddress, 7 EventTypeCode, i.InvoiceStatusCode, i.DueOn, i.PaidValue, i.PaidTaxValue
			FROM inserted i
				JOIN deleted d ON i.ContractAddress = d.ContractAddress
			WHERE (d.PaidValue + d.PaidTaxValue) <> (i.PaidValue + i.PaidTaxValue);
		END

		IF UPDATE(PaymentAddress)
		BEGIN
			INSERT INTO Invoice.tbMirrorEvent (ContractAddress, EventTypeCode, InvoiceStatusCode, DueOn, PaidValue, PaidTaxValue, PaymentAddress)
			SELECT i.ContractAddress, 8 EventTypeCode, i.InvoiceStatusCode, i.DueOn, i.PaidValue, i.PaidTaxValue, i.PaymentAddress
			FROM inserted i
				JOIN deleted d ON i.ContractAddress = d.ContractAddress
			WHERE d.PaymentAddress <> i.PaymentAddress;
		END

	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
go

ALTER VIEW Invoice.vwMirrors
AS
SELECT        Invoice.tbMirror.ContractAddress, Invoice.tbMirror.AccountCode, Org.tbOrg.AccountName, CASE WHEN tbMirrorReference.ContractAddress IS NULL THEN CAST(0 AS BIT) ELSE CAST(1 AS BIT) END AS IsMirrored, 
                         Invoice.tbMirrorReference.InvoiceNumber, Invoice.tbMirror.InvoiceNumber AS MirrorNumber, Invoice.tbMirror.InvoiceTypeCode, Invoice.tbType.InvoiceType, Invoice.tbType.CashModeCode, Invoice.tbMirror.InvoiceStatusCode, 
                         Invoice.tbStatus.InvoiceStatus, Invoice.tbMirror.InvoicedOn, Invoice.tbMirror.DueOn, Invoice.tbMirror.UnitOfCharge, CASE CashModeCode WHEN 0 THEN InvoiceValue * - 1 ELSE InvoiceValue END AS InvoiceValue, 
                         CASE CashModeCode WHEN 0 THEN InvoiceTax * - 1 ELSE InvoiceTax END AS InvoiceTax, CASE CashModeCode WHEN 0 THEN PaidValue ELSE PaidValue * - 1 END AS PaidValue, 
                         CASE CashModeCode WHEN 0 THEN PaidTaxValue ELSE PaidTaxValue * - 1 END AS PaidTaxValue, Invoice.tbMirror.PaymentAddress, Invoice.tbMirror.PaymentTerms, Invoice.tbMirror.InsertedOn, Invoice.tbMirror.RowVer
FROM            Invoice.tbMirror INNER JOIN
                         Invoice.tbType ON Invoice.tbMirror.InvoiceTypeCode = Invoice.tbType.InvoiceTypeCode INNER JOIN
                         Invoice.tbStatus ON Invoice.tbMirror.InvoiceStatusCode = Invoice.tbStatus.InvoiceStatusCode INNER JOIN
                         Org.tbOrg ON Invoice.tbMirror.AccountCode = Org.tbOrg.AccountCode LEFT OUTER JOIN
                         Invoice.tbMirrorReference ON Invoice.tbMirror.ContractAddress = Invoice.tbMirrorReference.ContractAddress
go
ALTER VIEW Invoice.vwMirrorEvents
AS
	SELECT        Invoice.tbMirrorEvent.ContractAddress, Invoice.tbMirror.AccountCode, Org.tbOrg.AccountName, Invoice.tbMirror.InvoiceNumber, Invoice.tbMirrorEvent.LogId, Invoice.tbMirrorEvent.EventTypeCode, App.tbEventType.EventType, 
							 Invoice.tbMirrorEvent.InvoiceStatusCode, Invoice.tbStatus.InvoiceStatus, Invoice.tbMirrorEvent.DueOn, Invoice.tbMirrorEvent.PaidValue, Invoice.tbMirrorEvent.PaidTaxValue, 
							 Invoice.tbMirrorEvent.PaymentAddress, Invoice.tbMirrorEvent.InsertedOn, Invoice.tbMirrorEvent.RowVer
	FROM            Invoice.tbMirrorEvent INNER JOIN
							 Invoice.tbMirror ON Invoice.tbMirrorEvent.ContractAddress = Invoice.tbMirror.ContractAddress INNER JOIN
							 Invoice.tbType ON Invoice.tbMirror.InvoiceTypeCode = Invoice.tbType.InvoiceTypeCode INNER JOIN
							 App.tbEventType ON Invoice.tbMirrorEvent.EventTypeCode = App.tbEventType.EventTypeCode INNER JOIN
							 Invoice.tbStatus ON Invoice.tbMirrorEvent.InvoiceStatusCode = Invoice.tbStatus.InvoiceStatusCode INNER JOIN
							 Org.tbOrg ON Invoice.tbMirror.AccountCode = Org.tbOrg.AccountCode AND Invoice.tbMirror.AccountCode = Org.tbOrg.AccountCode AND Invoice.tbMirror.AccountCode = Org.tbOrg.AccountCode AND 
							 Invoice.tbMirror.AccountCode = Org.tbOrg.AccountCode AND Invoice.tbMirror.AccountCode = Org.tbOrg.AccountCode AND Invoice.tbMirror.AccountCode = Org.tbOrg.AccountCode;
go
ALTER VIEW Invoice.vwNetworkDeployments
AS
	SELECT Invoice.tbInvoice.InvoiceNumber, Invoice.tbInvoice.AccountCode, 
		Invoice.tbType.CashModeCode AS PaymentPolarity, 
		CASE Invoice.tbType.InvoiceTypeCode 
			WHEN 0 THEN Invoice.tbType.CashModeCode 
			WHEN 1 THEN 1
			WHEN 2 THEN Invoice.tbType.CashModeCode 
			WHEN 3 THEN 0
		END InvoicePolarity, 
		Invoice.tbInvoice.InvoiceStatusCode,
		Invoice.tbInvoice.DueOn, Invoice.tbInvoice.InvoicedOn, Invoice.tbInvoice.InvoiceValue, Invoice.tbInvoice.TaxValue, 
		Invoice.tbInvoice.PaymentTerms, (SELECT TOP 1 UnitOfCharge FROM App.tbOptions) UnitOfCharge, Cash.tbChangeReference.PaymentAddress,
		Invoice.tbMirrorReference.ContractAddress,
		Invoice.tbMirror.InvoiceNumber ContractNumber
	FROM Invoice.tbMirrorReference 
		RIGHT OUTER JOIN Invoice.tbChangeLog 
		INNER JOIN Invoice.tbInvoice ON Invoice.tbChangeLog.InvoiceNumber = Invoice.tbInvoice.InvoiceNumber
		INNER JOIN Invoice.tbType ON Invoice.tbInvoice.InvoiceTypeCode = Invoice.tbType.InvoiceTypeCode ON Invoice.tbMirrorReference.InvoiceNumber = Invoice.tbInvoice.InvoiceNumber 
		LEFT OUTER JOIN Invoice.tbMirror ON Invoice.tbMirrorReference.ContractAddress = Invoice.tbMirror.ContractAddress AND Invoice.tbMirrorReference.ContractAddress = Invoice.tbMirror.ContractAddress
		LEFT OUTER JOIN Cash.tbChangeReference ON Invoice.tbInvoice.InvoiceNumber = Cash.tbChangeReference.InvoiceNumber
	WHERE        (Invoice.tbChangeLog.TransmitStatusCode = 1)

go
ALTER VIEW Invoice.vwNetworkUpdates
AS
	WITH updates AS
	(
		SELECT DISTINCT InvoiceNumber FROM Invoice.tbChangeLog 
		WHERE TransmitStatusCode = 2
		EXCEPT
		SELECT DISTINCT InvoiceNumber FROM Invoice.tbChangeLog 
		WHERE TransmitStatusCode = 1
	)
	SELECT Invoice.tbInvoice.InvoiceNumber, Invoice.tbInvoice.AccountCode, Invoice.tbInvoice.InvoiceStatusCode,
			Invoice.tbInvoice.DueOn, Invoice.tbInvoice.PaidValue, Invoice.tbInvoice.PaidTaxValue, Cash.tbChangeReference.PaymentAddress
	FROM updates 
		JOIN Invoice.tbInvoice ON updates.InvoiceNumber = Invoice.tbInvoice.InvoiceNumber 
		JOIN Invoice.tbType ON Invoice.tbInvoice.InvoiceTypeCode = Invoice.tbType.InvoiceTypeCode
		LEFT OUTER JOIN Cash.tbChangeReference ON Invoice.tbInvoice.InvoiceNumber = Cash.tbChangeReference.InvoiceNumber
go
ALTER VIEW Invoice.vwRegisterPurchasesOverdue
AS
SELECT        TOP (100) PERCENT Invoice.tbInvoice.InvoiceNumber, Invoice.tbInvoice.AccountCode, Org.tbOrg.AccountName, Invoice.tbInvoice.InvoiceTypeCode, Invoice.tbInvoice.InvoiceStatusCode, Invoice.tbStatus.InvoiceStatus, 
                         Invoice.tbType.InvoiceType, DATEDIFF(DD, CURRENT_TIMESTAMP, Invoice.tbInvoice.InvoicedOn) AS UnpaidDays, Invoice.tbInvoice.InvoicedOn, Invoice.tbInvoice.DueOn, Invoice.tbInvoice.ExpectedOn, 
                         CASE Invoice.tbType.CashModeCode WHEN 0 THEN Invoice.tbInvoice.InvoiceValue ELSE Invoice.tbInvoice.InvoiceValue * - 1 END AS InvoiceValue, 
                         CASE Invoice.tbType.CashModeCode WHEN 0 THEN Invoice.tbInvoice.TaxValue ELSE Invoice.tbInvoice.TaxValue * - 1 END AS TaxValue, 
                         CASE Invoice.tbType.CashModeCode WHEN 0 THEN (Invoice.tbInvoice.InvoiceValue + Invoice.tbInvoice.TaxValue) - (Invoice.tbInvoice.PaidValue + Invoice.tbInvoice.PaidTaxValue) 
                         ELSE ((Invoice.tbInvoice.InvoiceValue + Invoice.tbInvoice.TaxValue) - (Invoice.tbInvoice.PaidValue + Invoice.tbInvoice.PaidTaxValue)) * - 1 END AS UnpaidValue, Invoice.tbMirror.PaymentAddress, 
                         Invoice.tbInvoice.PaymentTerms, Invoice.tbInvoice.Notes
FROM            Invoice.tbInvoice INNER JOIN
                         Invoice.tbStatus ON Invoice.tbInvoice.InvoiceStatusCode = Invoice.tbStatus.InvoiceStatusCode INNER JOIN
                         Invoice.tbType ON Invoice.tbInvoice.InvoiceTypeCode = Invoice.tbType.InvoiceTypeCode INNER JOIN
                         Org.tbOrg ON Invoice.tbInvoice.AccountCode = Org.tbOrg.AccountCode LEFT OUTER JOIN
                         Invoice.tbMirrorReference ON Invoice.tbInvoice.InvoiceNumber = Invoice.tbMirrorReference.InvoiceNumber LEFT OUTER JOIN
                         Invoice.tbMirror ON Invoice.tbMirrorReference.ContractAddress = Invoice.tbMirror.ContractAddress
WHERE        (Invoice.tbInvoice.InvoiceTypeCode > 1) AND (Invoice.tbInvoice.InvoiceStatusCode < 3)
go
ALTER VIEW Invoice.vwRegisterSalesOverdue
AS
	SELECT        TOP (100) PERCENT Invoice.tbInvoice.InvoiceNumber, Invoice.tbInvoice.AccountCode, Org.tbOrg.AccountName, Invoice.tbInvoice.InvoiceTypeCode, Invoice.tbInvoice.InvoiceStatusCode, Invoice.tbStatus.InvoiceStatus, 
							 Invoice.tbType.InvoiceType, DATEDIFF(DD, CURRENT_TIMESTAMP, Invoice.tbInvoice.InvoicedOn) AS UnpaidDays, Invoice.tbInvoice.InvoicedOn, Invoice.tbInvoice.DueOn, Invoice.tbInvoice.ExpectedOn, 
							 CASE CashModeCode WHEN 1 THEN Invoice.tbInvoice.InvoiceValue ELSE Invoice.tbInvoice.InvoiceValue * - 1 END AS InvoiceValue, 
							 CASE CashModeCode WHEN 1 THEN Invoice.tbInvoice.TaxValue ELSE Invoice.tbInvoice.TaxValue * - 1 END AS TaxValue, CASE CashModeCode WHEN 1 THEN (Invoice.tbInvoice.InvoiceValue + Invoice.tbInvoice.TaxValue) 
							 - (Invoice.tbInvoice.PaidValue + Invoice.tbInvoice.PaidTaxValue) ELSE ((Invoice.tbInvoice.InvoiceValue + Invoice.tbInvoice.TaxValue) - (Invoice.tbInvoice.PaidValue + Invoice.tbInvoice.PaidTaxValue)) * - 1 END AS UnpaidValue, 
							 Cash.tbChangeReference.PaymentAddress, Invoice.tbInvoice.PaymentTerms, Invoice.tbInvoice.Notes
	FROM            Invoice.tbInvoice INNER JOIN
							 Invoice.tbStatus ON Invoice.tbInvoice.InvoiceStatusCode = Invoice.tbStatus.InvoiceStatusCode INNER JOIN
							 Invoice.tbType ON Invoice.tbInvoice.InvoiceTypeCode = Invoice.tbType.InvoiceTypeCode INNER JOIN
							 Org.tbOrg ON Invoice.tbInvoice.AccountCode = Org.tbOrg.AccountCode LEFT OUTER JOIN
							 Cash.tbChangeReference ON Invoice.tbInvoice.InvoiceNumber = Cash.tbChangeReference.InvoiceNumber
	WHERE        (Invoice.tbInvoice.InvoiceTypeCode < 2) AND (Invoice.tbInvoice.InvoiceStatusCode < 3)
go
CREATE OR ALTER PROCEDURE Cash.proc_ChangeAddressIndex 
(
	@CashAccountCode nvarchar(10), 
	@KeyName nvarchar(50), 
	@ChangeTypeCode smallint,
	@AddressIndex int = 0 output
)
AS
	SET NOCOUNT, XACT_ABORT ON;
	BEGIN TRY

		SELECT @AddressIndex = COALESCE(MAX(change.AddressIndex) + 1, 0) 
		FROM Cash.tbChange change
			JOIN Org.tbAccountKey account_key ON change.CashAccountCode = account_key.CashAccountCode AND change.HDPath = account_key.HDPath
		WHERE account_key.CashAccountCode = @CashAccountCode AND KeyName = @KeyName AND change.ChangeTypeCode = @ChangeTypeCode

	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
go
CREATE OR ALTER PROCEDURE Cash.proc_ChangeNew 
(
	@CashAccountCode nvarchar(10), 
	@KeyName nvarchar(50), 
	@ChangeTypeCode smallint,
	@PaymentAddress nvarchar(42), 
	@AddressIndex int = 0, 
	@InvoiceNumber nvarchar(20) = NULL,
	@Note nvarchar(256) = NULL
)
AS
	SET NOCOUNT, XACT_ABORT ON;
	BEGIN TRY
		BEGIN TRAN

		INSERT INTO Cash.tbChange (PaymentAddress, CashAccountCode, HDPath, ChangeTypeCode, AddressIndex, Note)
		SELECT @PaymentAddress, @CashAccountCode, account_key.HDPath, @ChangeTypeCode, @AddressIndex, @Note
		FROM Org.tbAccountKey account_key
		WHERE account_key.CashAccountCode = @CashAccountCode AND KeyName = @KeyName;

		IF EXISTS (SELECT * FROM Invoice.tbInvoice inv 
						JOIN Invoice.tbType typ ON inv.InvoiceTypeCode = typ.InvoiceTypeCode  
						WHERE typ.CashModeCode = 1 AND InvoiceNumber = @InvoiceNumber)
		BEGIN
			IF EXISTS (SELECT * FROM Cash.tbChangeReference WHERE InvoiceNumber = @InvoiceNumber)
				DELETE FROM Cash.tbChangeReference WHERE InvoiceNumber = @InvoiceNumber;
			INSERT INTO Cash.tbChangeReference (PaymentAddress, InvoiceNumber)
			VALUES (@PaymentAddress, @InvoiceNumber);
		END

		COMMIT TRAN

	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
go
CREATE OR ALTER FUNCTION Org.fnAccountKeyNamespace
(
	@CashAccountCode nvarchar(10),
	@HDPath hierarchyid
) RETURNS NVARCHAR(512)
AS
BEGIN
	DECLARE @KeyNamespace nvarchar(512);

	WITH key_namespace AS
	(
		SELECT HDPath, HDPath.GetAncestor(1) Ancestor, CAST(KeyName as nvarchar(512)) KeyNamespace
		FROM Org.tbAccountKey
		WHERE CashAccountCode = @CashAccountCode AND HDPath = @HDPath

		UNION ALL

		SELECT parent_key.HDPath, parent_key.HDPath.GetAncestor(1) Ancestor, CAST(CONCAT(parent_key.KeyName, '.', key_namespace.KeyNamespace) as nvarchar(512)) KeyNamespace
		FROM Org.tbAccountKey parent_key
			JOIN key_namespace ON parent_key.HDPath = key_namespace.Ancestor
		WHERE CashAccountCode = @CashAccountCode
	)
	SELECT @KeyNamespace = REPLACE(UPPER(KeyNamespace), ' ', '_')
	FROM key_namespace

	RETURN @KeyNamespace
END
go
CREATE OR ALTER FUNCTION Org.fnKeyNamespace (@CashAccountCode nvarchar(10), @KeyName nvarchar(50))
RETURNS TABLE 
AS
	RETURN
	(
		WITH key_root AS
		(
			SELECT CashAccountCode, HDPath, HDLevel, KeyName
			FROM Org.tbAccountKey
			WHERE CashAccountCode = @CashAccountCode AND KeyName = @KeyName
		), candidates AS
		(
			SELECT CashAccountCode, HDPath.GetAncestor(1) ParentHDPath, HDPath ChildHDPath, KeyName
			FROM Org.tbAccountKey
			WHERE CashAccountCode = @CashAccountCode AND HDLevel > (SELECT HDLevel FROM key_root) 
		), namespace_set AS
		(
			SELECT CashAccountCode, cast(NULL AS hierarchyid) ParentHDPath, HDPath ChildHDPath, KeyName FROM key_root

			UNION ALL

			SELECT candidates.CashAccountCode, candidates.ParentHDPath, candidates.ChildHDPath, candidates.KeyName
			FROM candidates
				JOIN namespace_set ON candidates.ParentHDPath = namespace_set.ChildHDPath
		)
		SELECT CashAccountCode, ChildHDPath HDPath, KeyName, Org.fnAccountKeyNamespace(CashAccountCode, ChildHDPath) KeyNamespace
		FROM namespace_set
	)
go
CREATE OR ALTER FUNCTION Cash.fnChangeKeyPath (@CoinTypeCode smallint, @HDPath nvarchar(256), @ChangeTypeCode smallint, @AddressIndex int)
RETURNS nvarchar(256)
AS
BEGIN
	DECLARE @KeyPath nvarchar(256) = CONCAT('44', '''', '/', @CoinTypeCode, REPLACE(@HDPath, '/', '''/'), @ChangeTypeCode, '/', @AddressIndex);
	RETURN @KeyPath;
END
go

CREATE TABLE Cash.tbTxStatus
(
	TxStatusCode smallint NOT NULL,
	TxStatus nvarchar(10) NOT NULL,
	CONSTRAINT PK_Cash_tbTxStatus PRIMARY KEY CLUSTERED (TxStatusCode)
);
go
INSERT INTO Cash.tbTxStatus (TxStatusCode, TxStatus) VALUES (0, 'Received'), (1, 'UTXO'), (2, 'Spent');
go
CREATE TABLE Cash.tbTx
(
	TxNumber int IDENTITY(1, 1) NOT NULL,
	PaymentAddress nvarchar(42) NOT NULL,
	TxId nvarchar(64) NOT NULL,
	TransactedOn datetime NOT NULL CONSTRAINT DF_Cash_tbTx_TransactedOn DEFAULT (getdate()),
	TxStatusCode smallint NOT NULL CONSTRAINT DF_Cash_tbTx_TxStatusCode DEFAULT (0),
	MoneyIn decimal(18, 5) NOT NULL CONSTRAINT DF_Cash_tbTx_MoneyIn DEFAULT (0),
	MoneyOut decimal(18, 5) NOT NULL CONSTRAINT DF_Cash_tbTx_MoneyOut DEFAULT (0),
	Confirmations int NOT NULL CONSTRAINT DF_Cash_tbTx_Confirmations DEFAULT(0),
	TxMessage nvarchar(50) NULL,
	InsertedBy nvarchar(50) NOT NULL CONSTRAINT DF_Cash_tbTx_InsertedBy DEFAULT (suser_sname()),
	CONSTRAINT PK_Cash_tbTx PRIMARY KEY CLUSTERED (TxNumber),
	CONSTRAINT FK_Cash_tbTx_Cash_tbChange FOREIGN KEY (PaymentAddress) REFERENCES Cash.tbChange (PaymentAddress) ON DELETE CASCADE,
	CONSTRAINT FK_Cash_tbTx_Cash_tbTxStatus FOREIGN KEY (TxStatusCode) REFERENCES Cash.tbTxStatus (TxStatusCode)
);
CREATE UNIQUE NONCLUSTERED INDEX IX_Cash_tbTx_PaymentAddress ON Cash.tbTx (PaymentAddress, TxId);
go
CREATE NONCLUSTERED INDEX IX_Cash_tbTx_TxStatusCode ON Cash.tbTx (TxStatusCode, TransactedOn);
go
CREATE OR ALTER TRIGGER Cash.Cash_tbTx_Trigger
   ON  Cash.tbTx
   AFTER UPDATE, INSERT
AS 
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY

		WITH payment AS
		(
			SELECT PaymentAddress
			FROM inserted tx
		), balance_base AS
		(
			SELECT tx.PaymentAddress, tx.TxStatusCode, SUM(CASE WHEN tx.TxStatusCode > 0 THEN tx.MoneyIn ELSE 0 END) Balance
			FROM Cash.tbTx tx JOIN payment ON tx.PaymentAddress = payment.PaymentAddress
			GROUP BY tx.PaymentAddress, tx.TxStatusCode
		), tx_balance AS
		(
			SELECT  PaymentAddress, MIN(TxStatusCode) TxStatusCode, SUM(Balance) Balance
			FROM balance_base
			GROUP BY PaymentAddress
		)
		UPDATE change
		SET	ChangeStatusCode =	CASE
									WHEN tx_balance.TxStatusCode = 2 THEN tx_balance.TxStatusCode
									WHEN tx_balance.Balance > 0 THEN 1
									ELSE tx_balance.TxStatusCode
								END 
		FROM tx_balance
			JOIN Cash.tbChange change ON tx_balance.PaymentAddress = change.PaymentAddress;		

	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
END
go
CREATE OR ALTER TRIGGER [Cash].[Cash_tbTx_Trigger_Delete]
   ON  [Cash].[tbTx]
   AFTER DELETE
AS 
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY

		WITH payment AS
		(
			SELECT PaymentAddress, 0 Balance
			FROM deleted tx
		), balance_base AS
		(
			SELECT tx.PaymentAddress, tx.TxStatusCode, SUM(CASE WHEN tx.TxStatusCode > 0 THEN tx.MoneyIn ELSE 0 END) Balance
			FROM Cash.tbTx tx JOIN payment ON tx.PaymentAddress = payment.PaymentAddress
			GROUP BY tx.PaymentAddress, tx.TxStatusCode
		), tx_balance AS
		(
			SELECT  PaymentAddress, MIN(TxStatusCode) TxStatusCode, SUM(Balance) Balance
			FROM balance_base
			GROUP BY PaymentAddress
		)
		UPDATE change
		SET	ChangeStatusCode =	CASE
									WHEN tx_balance.TxStatusCode = 2 THEN tx_balance.TxStatusCode
									WHEN tx_balance.Balance > 0 THEN 1
									ELSE tx_balance.TxStatusCode
								END 
		FROM tx_balance
			JOIN Cash.tbChange change ON tx_balance.PaymentAddress = change.PaymentAddress;	

	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
END
go
CREATE TABLE Cash.tbTxReference
(
	TxNumber int NOT NULL,
	TxStatusCode smallint NOT NULL CONSTRAINT DF_Cash_tbTxReference_TxStatusCode DEFAULT (0),
	PaymentCode nvarchar(20) NOT NULL
	CONSTRAINT PK_Cash_tbTxReference PRIMARY KEY CLUSTERED (TxNumber, TxStatusCode)
);
CREATE INDEX IX_Cash_tbTxReference_PaymentCode ON Cash.tbTxReference (PaymentCode, TxNumber);
go
ALTER TABLE Cash.tbTxReference  WITH CHECK ADD CONSTRAINT FK_Cash_tbTxReference_Cash_tbTx FOREIGN KEY(TxNumber)
REFERENCES Cash.tbTx (TxNumber);
go
ALTER TABLE Cash.tbTxReference  WITH CHECK ADD CONSTRAINT FK_Cash_tbTxReference_Cash_tbPayment FOREIGN KEY(PaymentCode)
REFERENCES Cash.tbPayment (PaymentCode);
go
ALTER TABLE Cash.tbTxReference  WITH CHECK ADD CONSTRAINT FK_Cash_tbTxReference_Cash_tbTxStatus FOREIGN KEY(TxStatusCode)
REFERENCES Cash.tbTxStatus (TxStatusCode)
go
CREATE OR ALTER TRIGGER Cash.Cash_tbTxReference_TriggerDelete
   ON  Cash.tbTxReference
   AFTER DELETE
AS 
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY
		UPDATE Cash.tbTx
		SET 
			TxStatusCode = CASE change.ChangeTypeCode WHEN 0 THEN 0 ELSE 1 END
		FROM deleted 
			JOIN Cash.tbTx tx ON deleted.TxNumber = tx.TxNumber
			JOIN Cash.tbChange change ON tx.PaymentAddress = change.PaymentAddress
	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
END
go
CREATE OR ALTER FUNCTION Cash.fnChangeUnassigned (@CashAccountCode nvarchar(10))
RETURNS TABLE
AS
	RETURN
	(
		SELECT change.CashAccountCode, Org.fnAccountKeyNamespace(account_key.CashAccountCode, account_key.HDPath) AS KeyNamespace, 
			account_key.KeyName, change.PaymentAddress, change.Note, change.InsertedOn, change.UpdatedOn, COALESCE(change_balance.Balance, 0) Balance
		FROM Cash.tbChange AS change 
				OUTER APPLY
				(
					SELECT PaymentAddress, SUM(MoneyIn) Balance
					FROM Cash.tbTx tx
					WHERE tx.PaymentAddress = change.PaymentAddress AND tx.TxStatusCode = 1
					GROUP BY PaymentAddress			
				) change_balance
			JOIN Org.tbAccountKey account_key ON change.CashAccountCode = account_key.CashAccountCode AND change.HDPath = account_key.HDPath
			LEFT OUTER JOIN Cash.tbChangeReference ON change.PaymentAddress = Cash.tbChangeReference.PaymentAddress
		WHERE  (change.CashAccountCode = @CashAccountCode)  AND (change.ChangeTypeCode = 0) AND (Cash.tbChangeReference.PaymentAddress IS NULL) AND (change.ChangeStatusCode = 0)
	)
go
CREATE OR ALTER FUNCTION Cash.fnChange(@CashAccountCode nvarchar(10), @KeyName nvarchar(50), @ChangeTypeCode smallint)
RETURNS TABLE
AS
	RETURN
	(
		WITH account_reference AS
		(
			SELECT        Cash.tbChangeReference.PaymentAddress, Cash.tbChangeReference.InvoiceNumber, Invoice.tbInvoice.AccountCode, Org.tbOrg.AccountName, Invoice.tbType.InvoiceType, 
										Invoice.tbInvoice.InvoiceValue + Invoice.tbInvoice.TaxValue - Invoice.tbInvoice.PaidValue - Invoice.tbInvoice.PaidTaxValue AS AmountDue, Invoice.tbInvoice.ExpectedOn, Invoice.tbStatus.InvoiceStatus, Invoice.tbType.CashModeCode
			FROM            Cash.tbChangeReference INNER JOIN
										Invoice.tbInvoice ON Cash.tbChangeReference.InvoiceNumber = Invoice.tbInvoice.InvoiceNumber INNER JOIN
										Org.tbOrg ON Invoice.tbInvoice.AccountCode = Org.tbOrg.AccountCode INNER JOIN
										Invoice.tbType ON Invoice.tbInvoice.InvoiceTypeCode = Invoice.tbType.InvoiceTypeCode INNER JOIN
										Invoice.tbStatus ON Invoice.tbInvoice.InvoiceStatusCode = Invoice.tbStatus.InvoiceStatusCode
		), key_namespace AS
		(
			SELECT CashAccountCode, HDPath, KeyNamespace, KeyName
			FROM Org.fnKeyNamespace(@CashAccountCode, @KeyName) kn
		), change AS
		(
			SELECT Cash.fnChangeKeyPath(cash_account.CoinTypeCode, key_namespace.HDPath.ToString(), change.ChangeTypeCode, AddressIndex)  FullHDPath, 
				change.CashAccountCode, key_namespace.KeyName, key_namespace.KeyNamespace, change.AddressIndex, change.PaymentAddress, change.ChangeTypeCode, change_type.ChangeType, change.ChangeStatusCode, change_Status.ChangeStatus,
				change.Note, account_reference.InvoiceNumber, account_reference.AccountCode, account_reference.AccountName, account_reference.InvoiceType, account_reference.InvoiceStatus, account_reference.CashModeCode,
				account_reference.AmountDue, account_reference.ExpectedOn, change.UpdatedOn, change.UpdatedBy, change.InsertedOn, change.InsertedBy, change.RowVer
			FROM  key_namespace 
				JOIN Org.tbAccount AS cash_account ON key_namespace.CashAccountCode = cash_account.CashAccountCode AND key_namespace.CashAccountCode = cash_account.CashAccountCode 
				JOIN Cash.tbChange AS change ON key_namespace.CashAccountCode = change.CashAccountCode AND key_namespace.HDPath = change.HDPath 
				JOIN Cash.tbChangeType change_type ON change.ChangeTypeCode = change_type .ChangeTypeCode 
				JOIN Cash.tbChangeStatus change_status ON change.ChangeStatusCode = change_status .ChangeStatusCode 

				LEFT OUTER JOIN account_reference ON change.PaymentAddress = account_reference.PaymentAddress
			WHERE change.ChangeTypeCode = @ChangeTypeCode 
	)
	SELECT change.*, COALESCE(change_balance.Balance, 0) Balance
	FROM change
		OUTER APPLY
		(
			SELECT PaymentAddress, SUM(MoneyIn) Balance
			FROM Cash.tbTx tx
			WHERE tx.PaymentAddress = change.PaymentAddress AND tx.TxStatusCode = 1
			GROUP BY PaymentAddress
		) AS change_balance
	)
go
CREATE OR ALTER PROCEDURE Cash.proc_TxInvoice (@PaymentAddress nvarchar(42), @TxId nvarchar(64))
AS
	SET NOCOUNT, XACT_ABORT ON;
	BEGIN TRY

		DECLARE @PaymentCode nvarchar(20);

		IF EXISTS (
				SELECT * 
				FROM Cash.tbTx 
				WHERE TxId = @TxId AND PaymentAddress = @PaymentAddress AND TxStatusCode = 0
			)
			AND EXISTS (
				SELECT * 
				FROM Cash.tbTx tx
					JOIN Cash.tbChangeReference ref ON tx.PaymentAddress = ref.PaymentAddress 
					JOIN Invoice.tbInvoice inv ON ref.InvoiceNumber = inv.InvoiceNumber 
				WHERE tx.TxId = @TxId AND inv.InvoiceStatusCode < 3	
			)
			AND NOT EXISTS (
				SELECT * 
				FROM Cash.tbTxReference ref 
					JOIN Cash.tbTx tx ON tx.TxNumber = ref.TxNumber WHERE tx.TxId = @TxId AND tx.PaymentAddress = @PaymentAddress
			)		
		BEGIN
			EXEC Cash.proc_NextPaymentCode @PaymentCode output;

			INSERT INTO Cash.tbPayment (PaymentCode, UserId, PaymentStatusCode, AccountCode, CashAccountCode, PaidInValue, PaymentReference)
			SELECT @PaymentCode PaymentCode, (SELECT UserId FROM Usr.vwCredentials) UserId, 0 PaymentStatusCode, invoice.AccountCode, change.CashAccountCode, tx.MoneyIn - tx.MoneyOut PaidInValue, invoice.InvoiceNumber
			FROM Cash.tbTx tx
				JOIN Cash.tbChange change ON tx.PaymentAddress = change.PaymentAddress
				JOIN Cash.tbChangeReference ref ON change.PaymentAddress = ref.PaymentAddress
				JOIN Invoice.tbInvoice invoice ON ref.InvoiceNumber = invoice.InvoiceNumber
			WHERE tx.TxId = @TxId;

			UPDATE Cash.tbTx
			SET TxStatusCode = 1
			WHERE TxId = @TxId;

			INSERT INTO Cash.tbTxReference (TxNumber, TxStatusCode, PaymentCode)
			SELECT TxNumber, TxStatusCode, @PaymentCode PaymentCode
			FROM Cash.tbTx
			WHERE TxId = @TxId AND PaymentAddress = @PaymentAddress;

			Exec Cash.proc_PaymentPost;

		END

	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
go
CREATE OR ALTER PROCEDURE Cash.proc_ChangeAssign
(
	@CashAccountCode nvarchar(10), 
	@KeyName nvarchar(50), 
	@PaymentAddress nvarchar(42), 
	@InvoiceNumber nvarchar(20),
	@Note nvarchar(256) = NULL
)
AS
	SET NOCOUNT, XACT_ABORT ON;
	BEGIN TRY
		BEGIN TRAN

		UPDATE Cash.tbChange
		SET Note = @Note
		WHERE PaymentAddress = @PaymentAddress;

		IF EXISTS (SELECT * FROM Invoice.tbInvoice inv 
						JOIN Invoice.tbType typ ON inv.InvoiceTypeCode = typ.InvoiceTypeCode  
						WHERE typ.CashModeCode = 1 AND InvoiceNumber = @InvoiceNumber AND inv.InvoiceStatusCode BETWEEN 1 AND 2)
		BEGIN
			IF EXISTS (SELECT * FROM Cash.tbChangeReference WHERE InvoiceNumber = @InvoiceNumber)
				DELETE FROM Cash.tbChangeReference WHERE InvoiceNumber = @InvoiceNumber;

			INSERT INTO Cash.tbChangeReference (PaymentAddress, InvoiceNumber)
			VALUES (@PaymentAddress, @InvoiceNumber);

			DECLARE @TxId nvarchar(64);
			DECLARE txIds CURSOR LOCAL FOR
				SELECT TxId FROM Cash.tbTx tx
				WHERE TxStatusCode = 0 AND tx.PaymentAddress = @PaymentAddress;

			OPEN txIds;
			FETCH NEXT FROM txIds INTO @TxId

			WHILE @@FETCH_STATUS = 0
			BEGIN
				EXEC Cash.proc_TxInvoice @PaymentAddress, @TxId;
				FETCH NEXT FROM txIds INTO @TxId
			END

			CLOSE txIds;
			DEALLOCATE txIds;

		END

		COMMIT TRAN

	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
go
CREATE OR ALTER PROCEDURE Cash.proc_ChangeDelete (@PaymentAddress nvarchar(42))
AS
	SET NOCOUNT, XACT_ABORT ON;
	BEGIN TRY
		IF EXISTS (
			SELECT * FROM Cash.tbChange change
				OUTER APPLY
				(
					SELECT PaymentAddress, SUM(MoneyIn) Balance
					FROM Cash.tbTx tx
					WHERE tx.PaymentAddress = change.PaymentAddress AND tx.TxStatusCode = 1
					GROUP BY PaymentAddress			
				) change_balance
			WHERE change.PaymentAddress = @PaymentAddress AND ChangeStatusCode = 0 AND COALESCE(change_balance.Balance, 0) = 0)
		BEGIN
			DELETE FROM Cash.tbChangeReference WHERE PaymentAddress = @PaymentAddress;
			DELETE FROM Cash.tbChange WHERE PaymentAddress = @PaymentAddress;			
		END
		ELSE
			RETURN 1;
	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
go
CREATE OR ALTER PROCEDURE Cash.proc_ChangeNote (@PaymentAddress nvarchar(42), @Note nvarchar(256))
AS
	SET NOCOUNT, XACT_ABORT ON;
	BEGIN TRY
		UPDATE Cash.tbChange 
		SET Note = @Note
		WHERE PaymentAddress = @PaymentAddress;			
	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
go
ALTER TRIGGER Invoice.Invoice_tbItem_TriggerInsert
ON Invoice.tbItem
FOR INSERT, UPDATE
AS
	SET NOCOUNT ON;

	BEGIN TRY

		UPDATE item
		SET InvoiceValue = inserted.TotalValue / (1 + TaxRate),
			TaxValue = inserted.TotalValue - inserted.TotalValue / (1 + TaxRate)
		FROM inserted 
			INNER JOIN Invoice.tbItem item ON inserted.InvoiceNumber = item.InvoiceNumber 
					AND inserted.CashCode = item.CashCode
				INNER JOIN App.tbTaxCode ON inserted.TaxCode = App.tbTaxCode.TaxCode 
		WHERE inserted.TotalValue <> 0;

		UPDATE item
		SET TaxValue = CASE App.tbTaxCode.RoundingCode 
				WHEN 0 THEN item.InvoiceValue * App.tbTaxCode.TaxRate
				WHEN 1 THEN item.InvoiceValue * App.tbTaxCode.TaxRate 
				END
		FROM Invoice.tbItem item 
			INNER JOIN inserted ON inserted.InvoiceNumber = item.InvoiceNumber
					 AND inserted.CashCode = item.CashCode
				INNER JOIN App.tbTaxCode ON item.TaxCode = App.tbTaxCode.TaxCode
		WHERE inserted.TotalValue = 0; 

	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
go
ALTER TRIGGER Invoice.Invoice_tbTask_TriggerInsert
ON Invoice.tbTask
FOR INSERT, UPDATE
AS
	SET NOCOUNT ON;

	BEGIN TRY

		UPDATE task
		SET InvoiceValue = inserted.TotalValue / (1 + TaxRate),
			TaxValue = inserted.TotalValue - inserted.TotalValue / (1 + TaxRate)
		FROM inserted 
			INNER JOIN Invoice.tbTask task ON inserted.InvoiceNumber = task.InvoiceNumber 
					AND inserted.TaskCode = task.TaskCode
				INNER JOIN App.tbTaxCode ON inserted.TaxCode = App.tbTaxCode.TaxCode 
		WHERE inserted.TotalValue <> 0;

		UPDATE task
		SET TaxValue = CASE App.tbTaxCode.RoundingCode 
				WHEN 0 THEN task.InvoiceValue * App.tbTaxCode.TaxRate
				WHEN 1 THEN task.InvoiceValue * App.tbTaxCode.TaxRate END
		FROM Invoice.tbTask task 
			INNER JOIN inserted ON inserted.InvoiceNumber = task.InvoiceNumber
					 AND inserted.TaskCode = task.TaskCode
				INNER JOIN App.tbTaxCode ON task.TaxCode = App.tbTaxCode.TaxCode
		WHERE inserted.TotalValue = 0; 

	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
go
CREATE OR ALTER VIEW Cash.vwChangeCollection
AS
	SELECT        change.PaymentAddress, Cash.fnChangeKeyPath(account.CoinTypeCode, account_key.HDPath.ToString(), change.ChangeTypeCode, change.AddressIndex)  FullHDPath
	FROM            Cash.tbChange AS change INNER JOIN
							 Org.tbAccountKey AS account_key ON change.CashAccountCode = account_key.CashAccountCode AND change.HDPath = account_key.HDPath INNER JOIN
							 Org.tbAccount AS account ON account_key.CashAccountCode = account.CashAccountCode
	WHERE        (change.ChangeStatusCode < 2);
go
CREATE OR ALTER PROCEDURE Cash.proc_ChangeTxAdd(@PaymentAddress nvarchar(42), @TxId nvarchar(64), @TxStatusCode smallint, @MoneyIn decimal(18, 5), @Confirmations int, @TxMessage nvarchar(50) = null)
AS
	SET XACT_ABORT, NOCOUNT ON;
	BEGIN TRY

		BEGIN TRAN

		DECLARE @PaymentCode nvarchar(20);

		IF EXISTS (SELECT * FROM Cash.tbTx WHERE TxId = @TxId AND PaymentAddress = @PaymentAddress)
		BEGIN
			UPDATE Cash.tbTx
			SET 
				MoneyIn = @MoneyIn, 
				TxStatusCode = CASE WHEN @TxStatusCode = 2 THEN @TxStatusCode ELSE TxStatusCode END,
				Confirmations = @Confirmations
			WHERE TxId = @TxId AND PaymentAddress = @PaymentAddress;
		END
		ELSE
		BEGIN
			SELECT @TxStatusCode = CASE change.ChangeTypeCode WHEN 1 THEN 1 ELSE @TxStatusCode END
			FROM Cash.tbChange change
				JOIN Cash.tbTx tx ON change.PaymentAddress = tx.PaymentAddress
			WHERE tx.PaymentAddress = @PaymentAddress AND tx.TxId = @TxId;

			INSERT INTO Cash.tbTx (TxId, PaymentAddress, TxStatusCode, MoneyIn, Confirmations, TxMessage)
			VALUES (@TxId, @PaymentAddress, @TxStatusCode, @MoneyIn, @Confirmations, @TxMessage);
		END

		EXEC Cash.proc_TxInvoice @PaymentAddress, @TxId;

		COMMIT TRAN

	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH

go
CREATE OR ALTER VIEW Cash.vwTxReference
AS
	WITH tx AS
	(
		SELECT TxNumber
		FROM Cash.tbTx
	), pay_in AS
	(
		SELECT TxNumber, PaymentCode PaymentCodeIn
		FROM Cash.tbTxReference
		WHERE TxStatusCode = 1
	), pay_out AS
	(
		SELECT TxNumber, PaymentCode PaymentCodeOut
		FROM Cash.tbTxReference
		WHERE TxStatusCode = 2
	)
	SELECT tx.TxNumber, PaymentCodeIn, PaymentCodeOut
	FROM tx 
		LEFT OUTER JOIN pay_in ON tx.TxNumber = pay_in.TxNumber
		LEFT OUTER JOIN pay_out ON tx.TxNumber = pay_out.TxNumber;
go
CREATE OR ALTER FUNCTION Cash.fnChangeTx(@PaymentAddress nvarchar(42))
RETURNS TABLE
AS
	RETURN
	(
		SELECT Cash.tbTx.PaymentAddress, Cash.tbTx.TxId, Cash.tbTx.TransactedOn, Cash.tbTx.TxStatusCode, Cash.tbTxStatus.TxStatus, Cash.tbTx.MoneyIn, Cash.tbTx.MoneyOut, Cash.tbTx.Confirmations, Cash.tbTx.InsertedBy, payments.PaymentCodeIn, payments.PaymentCodeOut, Cash.tbTx.TxMessage
		FROM Cash.tbTx 
			INNER JOIN Cash.tbTxStatus ON Cash.tbTx.TxStatusCode = Cash.tbTxStatus.TxStatusCode 
			LEFT OUTER JOIN Cash.vwTxReference payments ON Cash.tbTx.TxNumber = payments.TxNumber
		WHERE        (Cash.tbTx.PaymentAddress = @PaymentAddress)		
	)
go
CREATE OR ALTER FUNCTION Cash.fnTx(@CashAccountCode nvarchar(10), @KeyName nvarchar(50))
RETURNS TABLE
AS
	RETURN
	(
		WITH tx AS
		(
			SELECT        change.CashAccountCode, Org.tbAccount.CoinTypeCode, change.PaymentAddress, change.HDPath, change.ChangeTypeCode, change_type.ChangeType, change.ChangeStatusCode, change_status.ChangeStatus, 
									 change.AddressIndex, tx.TxId, tx.TransactedOn, tx.TxStatusCode, tx_status.TxStatus, tx.MoneyIn, tx.MoneyOut, tx.Confirmations, tx.TxMessage, tx.InsertedBy, tx_ref.PaymentCodeIn, tx_ref.PaymentCodeOut
			FROM            Cash.tbTx AS tx INNER JOIN
                         Cash.tbTxStatus AS tx_status ON tx.TxStatusCode = tx_status.TxStatusCode AND tx.TxStatusCode = tx_status.TxStatusCode INNER JOIN
                         Cash.tbChange AS change ON tx.PaymentAddress = change.PaymentAddress AND tx.PaymentAddress = change.PaymentAddress INNER JOIN
                         Cash.tbChangeType AS change_type ON change.ChangeTypeCode = change_type.ChangeTypeCode AND change.ChangeTypeCode = change_type.ChangeTypeCode INNER JOIN
                         Cash.tbChangeStatus AS change_status ON change.ChangeStatusCode = change_status.ChangeStatusCode INNER JOIN
                         Org.tbAccount ON change.CashAccountCode = Org.tbAccount.CashAccountCode
						 LEFT OUTER JOIN vwTxReference tx_ref ON tx.TxNumber = tx_ref.TxNumber
		), key_namespace AS
		(
			SELECT CashAccountCode, HDPath, KeyNamespace, KeyName
			FROM Org.fnKeyNamespace(@CashAccountCode, @KeyName) kn
		)
		SELECT tx.CashAccountCode, KeyNamespace, KeyName, PaymentAddress, ChangeTypeCode, ChangeType, ChangeStatusCode, ChangeStatus, 
			Cash.fnChangeKeyPath(tx.CoinTypeCode, key_namespace.HDPath.ToString(), tx.ChangeTypeCode, tx.AddressIndex)  FullHDPath,
			TxId, TransactedOn, TxStatusCode, TxStatus, MoneyIn, MoneyOut, Confirmations, TxMessage, InsertedBy, PaymentCodeIn, PaymentCodeOut
		FROM  key_namespace 
			JOIN tx ON key_namespace.HDPath = tx.HDPath
	)
go
CREATE OR ALTER VIEW Org.vwListAll
AS
	WITH accounts AS
	(
		SELECT AccountCode, AccountName, OrganisationTypeCode, OrganisationStatusCode, TaxCode,
			(SELECT TOP 1 CashCode FROM Task.tbTask WHERE AccountCode = orgs.AccountCode ORDER BY ActionOn DESC) TaskCashCode,
			(SELECT TOP 1 CashCode FROM Cash.tbPayment WHERE AccountCode = orgs.AccountCode ORDER BY PaidOn DESC) PaymentCashCode
		FROM  Org.tbOrg orgs
	)
		SELECT accounts.AccountCode, accounts.AccountName, org_type.OrganisationType, accounts.TaxCode, org_type.CashModeCode, accounts.OrganisationStatusCode,
			COALESCE(accounts.TaskCashCode, accounts.PaymentCashCode) CashCode
		FROM accounts 
			INNER JOIN Org.tbType AS org_type ON accounts.OrganisationTypeCode = org_type.OrganisationTypeCode
go
CREATE OR ALTER PROCEDURE Cash.proc_PaymentAdd(@AccountCode nvarchar(10), @CashAccountCode AS nvarchar(10), @CashCode nvarchar(50), @PaidOn datetime, @ToPay decimal(18, 5), @PaymentReference nvarchar(50) = null, @PaymentCode nvarchar(20) output)
AS
	SET NOCOUNT, XACT_ABORT ON;
	BEGIN TRY
		
		EXECUTE Cash.proc_NextPaymentCode  @PaymentCode OUTPUT

		INSERT INTO Cash.tbPayment (PaymentCode, UserId, PaymentStatusCode, AccountCode, CashAccountCode, CashCode, TaxCode, PaidOn, PaidInValue, PaidOutValue, TaxInValue, TaxOutValue, PaymentReference)
		SELECT   @PaymentCode AS PaymentCode, 
			(SELECT UserId FROM Usr.vwCredentials) AS UserId,
			0 AS PaymentStatusCode,
			@AccountCode AS AccountCode,
			@CashAccountCode AS CashAccountCode,
			@CashCode AS CashCode,
			Cash.tbCode.TaxCode,
			@PaidOn As PaidOn,
			CASE WHEN @ToPay > 0 THEN @ToPay ELSE 0 END AS PaidInValue,
			CASE WHEN @ToPay < 0 THEN ABS(@ToPay) ELSE 0 END AS PaidOutValue,
			CASE WHEN @ToPay > 0 THEN @ToPay * App.tbTaxCode.TaxRate ELSE 0 END AS TaxInValue,
			CASE WHEN @ToPay < 0 THEN ABS(@ToPay) * App.tbTaxCode.TaxRate ELSE 0 END AS TaxOutValue,
			@PaymentReference PaymentReference
		FROM            Cash.tbCode INNER JOIN
								 Cash.tbCategory ON Cash.tbCode.CategoryCode = Cash.tbCategory.CategoryCode INNER JOIN
								 App.tbTaxCode ON Cash.tbCode.TaxCode = App.tbTaxCode.TaxCode
		WHERE        (Cash.tbCode.CashCode = @CashCode)


	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
go
CREATE OR ALTER PROCEDURE Cash.proc_TxPayIn
(
	@CashAccountCode nvarchar(10), 
	@PaymentAddress nvarchar(42),
	@TxId nvarchar(64),
	@AccountCode nvarchar(10), 
	@CashCode nvarchar(50), 
	@PaidOn datetime, 
	@PaymentReference nvarchar(50) = null, 
	@PaymentCode nvarchar(20) output)
AS
	SET NOCOUNT, XACT_ABORT ON;
	BEGIN TRY
		DECLARE @ToPay decimal(18, 5), @Confirmations int;

		SELECT @ToPay = MoneyIn - MoneyOut, @Confirmations = Confirmations 
		FROM Cash.tbTx 
		WHERE TxId = @TxId AND PaymentAddress = @PaymentAddress

		IF NOT EXISTS (SELECT * FROM Org.tbOrg WHERE AccountCode = @AccountCode)
			SELECT @AccountCode = AccountCode FROM App.vwHomeAccount;
		ELSE IF @Confirmations = 0 
			RETURN 1;

		BEGIN TRAN

		EXEC Cash.proc_PaymentAdd @AccountCode, @CashAccountCode, @CashCode, @PaidOn, @ToPay, @PaymentReference, @PaymentCode OUTPUT;

		UPDATE Cash.tbTx
		SET TxStatusCode = 1
		WHERE TxId = @TxId AND PaymentAddress = @PaymentAddress;

		INSERT INTO Cash.tbTxReference (TxNumber, PaymentCode, TxStatusCode)
		SELECT TxNumber, @PaymentCode PaymentCode, TxStatusCode
		FROM Cash.tbTx
		WHERE TxId = @TxId AND PaymentAddress = @PaymentAddress;

		IF EXISTS (SELECT * FROM Cash.tbPayment WHERE PaymentCode = @PaymentCode AND PaymentStatusCode = 2)
			EXEC Cash.proc_PayAccrual @PaymentCode;
		ELSE
			EXEC Cash.proc_PaymentPost;

		COMMIT TRAN

	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
go
CREATE OR ALTER PROCEDURE Cash.proc_TxPayInChange
(
	@CashAccountCode nvarchar(10), 
	@PaymentAddress nvarchar(42),
	@TxId nvarchar(64),
	@AccountCode nvarchar(10), 
	@CashCode nvarchar(50),
	@PaymentReference nvarchar(50) = null
)
AS
	SET NOCOUNT, XACT_ABORT ON;
	BEGIN TRY
		DECLARE 
			@PaymentCode nvarchar(20)
			, @TaxCode nvarchar(10) = (SELECT TaxCode FROM Cash.tbCode WHERE CashCode = @CashCode);
			
		BEGIN TRAN

		EXECUTE Cash.proc_NextPaymentCode  @PaymentCode OUTPUT

		INSERT INTO Cash.tbPayment (UserId, PaymentCode, CashAccountCode, PaidOn, AccountCode, PaymentStatusCode, PaidInValue, CashCode, TaxCode, PaymentReference)
		SELECT 
			(SELECT UserId FROM Usr.vwCredentials) UserId,
			@PaymentCode PaymentCode, @CashAccountCode CashAccountCode, CURRENT_TIMESTAMP PaidOn, @AccountCode AccountCode, 1 PaymentStatusCode, MoneyIn, 
			@CashCode CashCode, @TaxCode TaxCode, @PaymentReference PaymentReference
		FROM Cash.tbTx
		WHERE TxId = @TxId AND PaymentAddress = @PaymentAddress;

		UPDATE  Org.tbAccount
		SET CurrentBalance = Org.tbAccount.CurrentBalance + PaidInValue
		FROM         Org.tbAccount INNER JOIN
							  Cash.tbPayment ON Org.tbAccount.CashAccountCode = Cash.tbPayment.CashAccountCode
		WHERE Cash.tbPayment.PaymentCode = @PaymentCode

		UPDATE Cash.tbTx
		SET TxStatusCode = 1
		WHERE TxId = @TxId AND PaymentAddress = @PaymentAddress;

		INSERT INTO Cash.tbTxReference (TxNumber, PaymentCode, TxStatusCode)
		SELECT TxNumber, @PaymentCode PaymentCode, TxStatusCode
		FROM Cash.tbTx
		WHERE TxId = @TxId AND PaymentAddress = @PaymentAddress;

		COMMIT TRAN

	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
go
CREATE OR ALTER PROCEDURE Cash.proc_TxPayOutTransfer
(
	@PaymentAddress nvarchar(42)
	, @TxId nvarchar(64)
	, @Spent decimal(18, 5)
	, @MinerFee decimal(18, 5)
	, @CashCode nvarchar(50)
	, @PaymentReference nvarchar(50)
)
AS
	SET XACT_ABORT, NOCOUNT ON;

	BEGIN TRY

		DECLARE 						
			@AccountCode nvarchar(10)
			, @TaxCode nvarchar(10)
			, @PaymentCode nvarchar(20)
			, @TxNumber int
			, @PaidOutValue decimal(18, 5)
			, @CashAccountCode nvarchar(10) = (SELECT CashAccountCode FROM Cash.tbChange WHERE PaymentAddress = @PaymentAddress)
			, @UserId nvarchar(10) = (SELECT UserId FROM Usr.vwCredentials)
			;

		SELECT @TxNumber = TxNumber, @PaidOutValue = MoneyIn - @MinerFee
		FROM Cash.tbTx 
		WHERE PaymentAddress = @PaymentAddress AND TxId = @TxId;

		SELECT @AccountCode = AccountCode FROM App.vwHomeAccount;
		SELECT @TaxCode = TaxCode FROM Cash.tbCode WHERE CashCode = @CashCode;

		BEGIN TRAN

		UPDATE Cash.tbTx
		SET
			TxStatusCode = 2, 
			MoneyOut = @Spent
		WHERE PaymentAddress = @PaymentAddress AND TxNumber = @TxNumber;

		EXEC Cash.proc_NextPaymentCode @PaymentCode OUTPUT;
		
		INSERT INTO Cash.tbPayment (PaymentCode, UserId, PaidOn, AccountCode, CashAccountCode, CashCode, TaxCode, PaidOutValue, PaymentReference)
		VALUES (@PaymentCode, @UserId, CURRENT_TIMESTAMP, @AccountCode, @CashAccountCode, @CashCode, @TaxCode, @PaidOutValue, @PaymentReference);

		IF EXISTS (SELECT * FROM Cash.tbPayment WHERE PaymentCode = @PaymentCode AND PaymentStatusCode = 2)
			EXEC Cash.proc_PayAccrual @PaymentCode;
		ELSE
			EXEC Cash.proc_PaymentPost;

		INSERT INTO Cash.tbTxReference (TxNumber, TxStatusCode, PaymentCode)
		VALUES (@TxNumber, 2, @PaymentCode);

		IF @MinerFee > 0
		BEGIN
			EXEC Cash.proc_NextPaymentCode @PaymentCode OUTPUT;
		
			INSERT INTO Cash.tbPayment (PaymentCode, UserId, PaidOn, PaymentStatusCode, AccountCode, CashAccountCode, CashCode, TaxCode, PaidOutValue, PaymentReference)
			SELECT @PaymentCode PaymentCode, @UserId UserId, CURRENT_TIMESTAMP PaidOn, 0 PaymentStatusCode, options.MinerAccountCode AccountCode, @CashAccountCode CashAccountCode,
				cash_code.CashCode CashCode, cash_code.TaxCode TaxCode, @MinerFee PaidOutValue, @PaymentReference PaymentReference
			FROM App.tbOptions options
				JOIN Cash.tbCode cash_code ON options.MinerFeeCode = cash_code.CashCode;	

			EXEC Cash.proc_PaymentPost;
		END
		
		COMMIT TRAN

	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog
	END CATCH
go
CREATE OR ALTER PROCEDURE Cash.proc_TxPayOutMisc
(
	@PaymentAddress nvarchar(42)
	, @TxId nvarchar(64)
	, @Spent decimal(18, 5)
	, @MinerFee decimal(18, 5)
	, @AccountCode nvarchar(10)
	, @CashCode nvarchar(50)
	, @TaxCode nvarchar(10)
	, @PaymentReference nvarchar(50)
)
AS
	SET XACT_ABORT, NOCOUNT ON;

	BEGIN TRY

		DECLARE 						
			@PaymentCode nvarchar(20)
			, @TxNumber int
			, @PaidOutValue decimal(18, 5)
			, @CashAccountCode nvarchar(10) = (SELECT CashAccountCode FROM Cash.tbChange WHERE PaymentAddress = @PaymentAddress)
			, @UserId nvarchar(10) = (SELECT UserId FROM Usr.vwCredentials)
			;

		SELECT @TxNumber = TxNumber, @PaidOutValue = MoneyIn - @MinerFee
		FROM Cash.tbTx 
		WHERE PaymentAddress = @PaymentAddress AND TxId = @TxId;

		BEGIN TRAN

		UPDATE Cash.tbTx
		SET
			TxStatusCode = 2, 
			MoneyOut = @Spent
		WHERE PaymentAddress = @PaymentAddress AND TxNumber = @TxNumber;

		EXEC Cash.proc_NextPaymentCode @PaymentCode OUTPUT;
		
		INSERT INTO Cash.tbPayment (PaymentCode, UserId, PaidOn, AccountCode, CashAccountCode, CashCode, TaxCode, PaidOutValue, PaymentStatusCode)
		VALUES (@PaymentCode, @UserId, CURRENT_TIMESTAMP, @AccountCode, @CashAccountCode, @CashCode, @TaxCode, @PaidOutValue, 1);

		UPDATE  Org.tbAccount
		SET CurrentBalance = Org.tbAccount.CurrentBalance - PaidOutValue
		FROM         Org.tbAccount INNER JOIN
							  Cash.tbPayment ON Org.tbAccount.CashAccountCode = Cash.tbPayment.CashAccountCode
		WHERE Cash.tbPayment.PaymentCode = @PaymentCode

		INSERT INTO Cash.tbTxReference (TxNumber, TxStatusCode, PaymentCode)
		VALUES (@TxNumber, 2, @PaymentCode);

		IF @MinerFee > 0
		BEGIN
			EXEC Cash.proc_NextPaymentCode @PaymentCode OUTPUT;
		
			INSERT INTO Cash.tbPayment (PaymentCode, UserId, PaidOn, PaymentStatusCode, AccountCode, CashAccountCode, CashCode, TaxCode, PaidOutValue)
			SELECT @PaymentCode PaymentCode, @UserId UserId, CURRENT_TIMESTAMP PaidOn, 0 PaymentStatusCode, options.MinerAccountCode AccountCode, @CashAccountCode CashAccountCode,
				cash_code.CashCode CashCode, cash_code.TaxCode TaxCode, @MinerFee PaidOutValue
			FROM App.tbOptions options
				JOIN Cash.tbCode cash_code ON options.MinerFeeCode = cash_code.CashCode;				

			EXEC Cash.proc_PaymentPost;
		END
		
		COMMIT TRAN

	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog
	END CATCH
go
CREATE OR ALTER PROCEDURE Cash.proc_TxPayAccount
(
	@PaymentAddress nvarchar(42)
	, @TxId nvarchar(64)
	, @Spent decimal(18, 5)
	, @MinerFee decimal(18, 5)
	, @AccountCode nvarchar(10)
)
AS
	SET XACT_ABORT, NOCOUNT ON;

	BEGIN TRY

		DECLARE 						
			@PaymentCode nvarchar(20)
			, @TxNumber int
			, @PaidOutValue decimal(18, 5)
			, @CashAccountCode nvarchar(10) = (SELECT CashAccountCode FROM Cash.tbChange WHERE PaymentAddress = @PaymentAddress)
			, @UserId nvarchar(10) = (SELECT UserId FROM Usr.vwCredentials)
			;

		SELECT @TxNumber = TxNumber, @PaidOutValue = MoneyIn - @MinerFee
		FROM Cash.tbTx 
		WHERE PaymentAddress = @PaymentAddress AND TxId = @TxId;

		BEGIN TRAN

		UPDATE Cash.tbTx
		SET
			TxStatusCode = 2, 
			MoneyOut = @Spent
		WHERE PaymentAddress = @PaymentAddress AND TxNumber = @TxNumber;

		EXEC Cash.proc_NextPaymentCode @PaymentCode OUTPUT;
		
		INSERT INTO Cash.tbPayment (PaymentCode, UserId, PaidOn, AccountCode, CashAccountCode, PaidOutValue)
		VALUES (@PaymentCode, @UserId, CURRENT_TIMESTAMP, @AccountCode, @CashAccountCode, @PaidOutValue);

		EXEC Cash.proc_PaymentPost;

		INSERT INTO Cash.tbTxReference (TxNumber, TxStatusCode, PaymentCode)
		VALUES (@TxNumber, 2, @PaymentCode);

		IF @MinerFee > 0
		BEGIN
			EXEC Cash.proc_NextPaymentCode @PaymentCode OUTPUT;
		
			INSERT INTO Cash.tbPayment (PaymentCode, UserId, PaidOn, PaymentStatusCode, AccountCode, CashAccountCode, CashCode, TaxCode, PaidOutValue)
			SELECT @PaymentCode PaymentCode, @UserId UserId, CURRENT_TIMESTAMP PaidOn, 0 PaymentStatusCode, options.MinerAccountCode AccountCode, @CashAccountCode CashAccountCode,
				cash_code.CashCode CashCode, cash_code.TaxCode TaxCode, @MinerFee PaidOutValue
			FROM App.tbOptions options
				JOIN Cash.tbCode cash_code ON options.MinerFeeCode = cash_code.CashCode;				

			EXEC Cash.proc_PaymentPost;
		END
		
		COMMIT TRAN

	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog
	END CATCH
go
CREATE OR ALTER PROCEDURE Cash.proc_TxPayOutInvoice 
(
	@AccountCode nvarchar(10),
	@CashCode nvarchar(50),
	@TaxCode nvarchar(10),
	@ItemReference nvarchar(50),
	@PaidOutValue decimal(18,5)
)
AS
  SET NOCOUNT, XACT_ABORT ON;
	BEGIN TRY
		DECLARE @InvoiceNumber nvarchar(20)
		
		BEGIN TRANSACTION
		
		EXEC Invoice.proc_RaiseBlank @AccountCode, 2, @InvoiceNumber OUTPUT;
		
		INSERT INTO Invoice.tbItem (InvoiceNumber, CashCode, TaxCode, ItemReference, TotalValue)
		VALUES (@InvoiceNumber, @CashCode, @TaxCode, @ItemReference, @PaidOutValue);
		
		EXEC Invoice.proc_Accept @InvoiceNumber;

		COMMIT TRANSACTION
	
	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog
	END CATCH
go
CREATE OR ALTER FUNCTION Cash.fnNamespaceBalance(@CashAccountCode nvarchar(10), @KeyName nvarchar(50))
RETURNS float
AS
BEGIN
	DECLARE @Balance float;

	SELECT @Balance = SUM(COALESCE(change_balance.Balance, 0))
	FROM Org.fnKeyNamespace(@CashAccountCode, @KeyName) kn
		JOIN Cash.tbChange change
			ON kn.CashAccountCode = change.CashAccountCode AND kn.HDPath = change.HDPath
		OUTER APPLY
		(
			SELECT PaymentAddress, SUM(MoneyIn) Balance
			FROM Cash.tbTx tx
			WHERE tx.PaymentAddress = change.PaymentAddress AND tx.TxStatusCode = 1
			GROUP BY PaymentAddress			
		) change_balance

	RETURN @Balance;
END
go
CREATE OR ALTER FUNCTION Cash.fnKeyNameBalance(@CashAccountCode nvarchar(10), @KeyName nvarchar(50))
RETURNS float
AS
BEGIN
	DECLARE @Balance float;

	SELECT @Balance = SUM(COALESCE(change_balance.Balance, 0))
	FROM Org.tbAccountKey accountKey
		JOIN Cash.tbChange change
			ON accountKey.HDPath = change.HDPath AND accountKey.CashAccountCode = change.CashAccountCode
		OUTER APPLY
		(
			SELECT PaymentAddress, SUM(MoneyIn) Balance
			FROM Cash.tbTx tx
			WHERE tx.PaymentAddress = change.PaymentAddress AND tx.TxStatusCode = 1
			GROUP BY PaymentAddress			
		) change_balance
	WHERE accountKey.CashAccountCode = @CashAccountCode AND accountKey.KeyName = @KeyName;

	RETURN @Balance;
END
go
CREATE OR ALTER FUNCTION Cash.fnKeyAddresses(@CashAccountCode nvarchar(10), @KeyName nvarchar(50))
RETURNS TABLE
AS
	RETURN
	(
		SELECT        
			Cash.fnChangeKeyPath(cash_account.CoinTypeCode, key_name.HDPath.ToString(), change.ChangeTypeCode, AddressIndex)  HDPath, 
			change.PaymentAddress, change.AddressIndex
		FROM Cash.tbChange AS change 
			INNER JOIN Org.tbAccountKey AS key_name 
				ON change.CashAccountCode = key_name.CashAccountCode AND change.HDPath = key_name.HDPath AND change.CashAccountCode = key_name.CashAccountCode AND change.HDPath = key_name.HDPath 
			INNER JOIN Org.tbAccount AS cash_account 
				ON key_name.CashAccountCode = cash_account.CashAccountCode
		WHERE (change.ChangeStatusCode = 1) AND (key_name.CashAccountCode = @CashAccountCode) AND (key_name.KeyName = @KeyName)
	)
go

