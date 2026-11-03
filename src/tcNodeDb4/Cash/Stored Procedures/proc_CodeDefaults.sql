CREATE PROCEDURE Cash.proc_CodeDefaults 
	(
	@CashCode nvarchar(50)
	)
  AS
   	SET NOCOUNT, XACT_ABORT ON;

	BEGIN TRY

		SELECT     Cash.vwCodeActive.CashCode, Cash.vwCodeActive.CashDescription, Cash.vwCodeActive.CategoryCode, Cash.vwCodeActive.TaxCode, 
				App.tbTaxCode.TaxTypeCode, ISNULL( Cash.vwCategoryActive.CashPolarityCode, 0) AS CashPolarityCode, ISNULL(Cash.vwCategoryActive.CashTypeCode, 0) AS CashTypeCode
		FROM         Cash.vwCodeActive INNER JOIN
							  App.tbTaxCode ON Cash.vwCodeActive.TaxCode = App.tbTaxCode.TaxCode LEFT OUTER JOIN
							  Cash.vwCategoryActive ON Cash.vwCodeActive.CategoryCode = Cash.vwCategoryActive.CategoryCode
		WHERE     ( Cash.vwCodeActive.CashCode = @CashCode)
    END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH 
