/**************************************************************************************
Trade Control
Upgrade script
Release: 3.31.2

Date: 15 January 2020
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
CREATE OR ALTER VIEW Invoice.vwAccountsMode
AS
	SELECT        Invoice.tbInvoice.InvoiceNumber, Invoice.tbInvoice.UserId, Invoice.tbInvoice.AccountCode, Invoice.tbInvoice.InvoiceTypeCode, Invoice.tbInvoice.InvoiceStatusCode, Invoice.tbInvoice.InvoicedOn, Invoice.tbInvoice.Notes, 
							 Invoice.tbItem.CashCode, Invoice.tbItem.TaxCode, Invoice.tbItem.ItemReference, Invoice.tbInvoice.RowVer AS InvoiceRowVer, Invoice.tbItem.RowVer AS ItemRowVer, Invoice.tbItem.TotalValue, Invoice.tbItem.InvoiceValue, 
							 Invoice.tbInvoice.PaidValue, Invoice.tbInvoice.PaidTaxValue, Invoice.tbInvoice.ExpectedOn, Invoice.tbInvoice.DueOn, Invoice.tbInvoice.PaymentTerms, Invoice.tbInvoice.Printed, Invoice.tbInvoice.Spooled
	FROM            Invoice.tbInvoice INNER JOIN
							 Invoice.tbItem ON Invoice.tbInvoice.InvoiceNumber = Invoice.tbItem.InvoiceNumber;
go
ALTER PROCEDURE Invoice.proc_PostEntries
AS
   	SET NOCOUNT, XACT_ABORT ON;

	BEGIN TRY
		DECLARE 
			@AccountCode nvarchar(10)
			, @InvoiceTypeCode smallint
			, @InvoiceNumber nvarchar(20);
			
		DECLARE c1 CURSOR LOCAL FOR
			SELECT AccountCode, InvoiceTypeCode
			FROM Invoice.tbEntry
			WHERE UserId = (SELECT UserId FROM Usr.vwCredentials)
			GROUP BY AccountCode, InvoiceTypeCode;

		OPEN c1;

		BEGIN TRAN;

		FETCH NEXT FROM c1 INTO @AccountCode, @InvoiceTypeCode;
		
		WHILE (@@FETCH_STATUS = 0)
		BEGIN
			EXEC Invoice.proc_RaiseBlank @AccountCode, @InvoiceTypeCode, @InvoiceNumber output;

			WITH invoice_entry AS
			(
				SELECT @InvoiceNumber InvoiceNumber, MIN(InvoicedOn) InvoicedOn
				FROM Invoice.tbEntry
				WHERE AccountCode = @AccountCode AND InvoiceTypeCode = @InvoiceTypeCode
			)
			UPDATE Invoice.tbInvoice
			SET 
				InvoicedOn = invoice_entry.InvoicedOn,
				Printed = CASE WHEN  @InvoiceTypeCode < 2 THEN 0 ELSE 1 END
			FROM Invoice.tbInvoice invoice_header 
				JOIN invoice_entry ON invoice_header.InvoiceNumber = invoice_entry.InvoiceNumber;

			INSERT INTO Invoice.tbItem (InvoiceNumber, CashCode, TaxCode, ItemReference, TotalValue, InvoiceValue)
			SELECT @InvoiceNumber InvoiceNumber, CashCode, TaxCode, ItemReference, TotalValue, InvoiceValue
			FROM Invoice.tbEntry
			WHERE AccountCode = @AccountCode AND InvoiceTypeCode = @InvoiceTypeCode

			EXEC Invoice.proc_Accept @InvoiceNumber;

			FETCH NEXT FROM c1 INTO @AccountCode, @InvoiceTypeCode;
		END

		DELETE FROM Invoice.tbEntry
		WHERE UserId = (SELECT UserId FROM Usr.vwCredentials);

		COMMIT TRAN;

		CLOSE c1;
		DEALLOCATE c1;

  	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
go
ALTER PROCEDURE Invoice.proc_RaiseBlank
	(
	@AccountCode nvarchar(10),
	@InvoiceTypeCode smallint,
	@InvoiceNumber nvarchar(20) = null output
	)
  AS
  SET NOCOUNT, XACT_ABORT ON;
	BEGIN TRY
		DECLARE 
			@UserId nvarchar(10)
			, @NextNumber int
			, @InvoiceSuffix nvarchar(4)
			, @InvoicedOn datetime

		SELECT @UserId = UserId FROM Usr.vwCredentials

		SET @InvoiceSuffix = '.' + @UserId
	
		SELECT @NextNumber = NextNumber
		FROM Invoice.tbType
		WHERE InvoiceTypeCode = @InvoiceTypeCode
	
		SELECT @InvoiceNumber = FORMAT(@NextNumber, '000000') + @InvoiceSuffix
	
		WHILE EXISTS (SELECT     InvoiceNumber
						FROM         Invoice.tbInvoice
						WHERE     (InvoiceNumber = @InvoiceNumber))
			BEGIN
			SET @NextNumber = @NextNumber + 1
			SET @InvoiceNumber = FORMAT(@NextNumber, '000000') + @InvoiceSuffix
			END
		
		SET @InvoicedOn = isnull(CAST(@InvoicedOn AS DATE), CAST(CURRENT_TIMESTAMP AS DATE))

		BEGIN TRANSACTION
	
		EXEC Invoice.proc_Cancel
	
		UPDATE    Invoice.tbType
		SET              NextNumber = @NextNumber + 1
		WHERE     (InvoiceTypeCode = @InvoiceTypeCode)
	
		INSERT INTO Invoice.tbInvoice
								(InvoiceNumber, UserId, AccountCode, InvoiceTypeCode, InvoicedOn, InvoiceStatusCode, PaymentTerms)
		 SELECT @InvoiceNumber, @UserId, @AccountCode, @InvoiceTypeCode, @InvoicedOn, 0, PaymentTerms
		 FROM Org.tbOrg
		 WHERE AccountCode = @AccountCode
	
		COMMIT TRANSACTION
	
	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog
	END CATCH
go
CREATE OR ALTER VIEW Invoice.vwSalesInvoiceSpoolByItem
AS
	SELECT  sales_invoice.InvoiceNumber, Invoice.tbType.InvoiceType, sales_invoice.InvoiceStatusCode, Usr.tbUser.UserName, sales_invoice.AccountCode, Org.tbOrg.AccountName, Invoice.tbStatus.InvoiceStatus, 
							 sales_invoice.InvoicedOn, sales_invoice.InvoiceValue AS InvoiceValueTotal, sales_invoice.TaxValue AS TaxValueTotal, sales_invoice.PaymentTerms, sales_invoice.DueOn, sales_invoice.Notes, Org.tbOrg.EmailAddress, 
							 Org.tbAddress.Address AS InvoiceAddress, tbInvoiceItem.CashCode, Cash.tbCode.CashDescription, tbInvoiceItem.ItemReference, tbInvoiceItem.TaxCode, tbInvoiceItem.InvoiceValue, tbInvoiceItem.TaxValue
	FROM            Invoice.tbInvoice AS sales_invoice INNER JOIN
							 Invoice.tbStatus ON sales_invoice.InvoiceStatusCode = Invoice.tbStatus.InvoiceStatusCode INNER JOIN
							 Org.tbOrg ON sales_invoice.AccountCode = Org.tbOrg.AccountCode INNER JOIN
							 Usr.tbUser ON sales_invoice.UserId = Usr.tbUser.UserId LEFT OUTER JOIN
							 Org.tbAddress ON Org.tbOrg.AddressCode = Org.tbAddress.AddressCode INNER JOIN
							 Invoice.tbItem AS tbInvoiceItem ON sales_invoice.InvoiceNumber = tbInvoiceItem.InvoiceNumber INNER JOIN
							 Invoice.tbType ON sales_invoice.InvoiceTypeCode = Invoice.tbType.InvoiceTypeCode INNER JOIN
							 Cash.tbCode ON tbInvoiceItem.CashCode = Cash.tbCode.CashCode
	WHERE        (sales_invoice.InvoiceTypeCode = 0) AND EXISTS
								 (SELECT        UserName, DocTypeCode, DocumentNumber, SpooledOn, RowVer
								   FROM            App.tbDocSpool AS doc
								   WHERE        (DocTypeCode = 4) AND (UserName = SUSER_SNAME()) AND (sales_invoice.InvoiceNumber = DocumentNumber))
go
CREATE OR ALTER PROCEDURE Org.proc_DefaultEmailAddress 
	(
	@AccountCode nvarchar(10),
	@EmailAddress nvarchar(255) OUTPUT
	)
  AS
   	SET NOCOUNT, XACT_ABORT ON;

	BEGIN TRY

	SELECT @EmailAddress = COALESCE(EmailAddress, '') FROM Org.tbOrg WHERE AccountCode = @AccountCode;

	IF (LEN(@EmailAddress) = 0)
		SELECT @EmailAddress = EmailAddress
		FROM Org.tbContact
		WHERE AccountCode = @AccountCode AND NOT (EmailAddress IS NULL);

	SET @EmailAddress = COALESCE(@EmailAddress, '');

  	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
go
