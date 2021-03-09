/**************************************************************************************
Trade Control
Upgrade script
Release: 3.34.2

Date: 9 March 2021
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
ALTER PROCEDURE Task.proc_Pay (@TaskCode NVARCHAR(20), @Post BIT = 0,	@PaymentCode nvarchar(20) NULL OUTPUT)
AS
	SET NOCOUNT, XACT_ABORT ON;

	BEGIN TRY
		
		DECLARE 
			@InvoiceTypeCode smallint
			, @InvoiceNumber NVARCHAR(20)
			, @InvoicedOn DATETIME = CURRENT_TIMESTAMP

		SELECT @InvoiceTypeCode = CASE CashModeCode WHEN 0 THEN 2 ELSE 0 END, @InvoicedOn = Task.tbTask.PaymentOn
		FROM  Task.tbTask INNER JOIN
				Cash.tbCode ON Task.tbTask.CashCode = Cash.tbCode.CashCode INNER JOIN
				Cash.tbCategory ON Cash.tbCode.CategoryCode = Cash.tbCategory.CategoryCode AND Cash.tbCode.CategoryCode = Cash.tbCategory.CategoryCode AND 
				Cash.tbCode.CategoryCode = Cash.tbCategory.CategoryCode
		WHERE Task.tbTask.TaskCode = @TaskCode
		
		EXEC Invoice.proc_Raise @TaskCode = @TaskCode, @InvoiceTypeCode = @InvoiceTypeCode, @InvoicedOn = @InvoicedOn, @InvoiceNumber = @InvoiceNumber OUTPUT
		EXEC Invoice.proc_Accept @InvoiceNumber
		EXEC Invoice.proc_Pay @InvoiceNumber = @InvoiceNumber, @PaidOn = @InvoicedOn, @Post = @Post, @PaymentCode = @PaymentCode OUTPUT

	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
go
