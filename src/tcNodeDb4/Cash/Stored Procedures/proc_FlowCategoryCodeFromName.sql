
CREATE   PROCEDURE Cash.proc_FlowCategoryCodeFromName
	(
		@Category nvarchar(100),
		@CategoryCode nvarchar(50) output
	)
AS
	SET NOCOUNT, XACT_ABORT ON;

	BEGIN TRY
		IF EXISTS (SELECT 1 FROM Cash.tbCategory WHERE CategoryCode = @Category)
			SET @CategoryCode = @Category;
		ELSE IF EXISTS (SELECT 1 FROM Cash.tbCode WHERE CashCode = @Category)
			SET @CategoryCode = @Category;
		ELSE IF (SELECT COUNT(*) FROM Cash.tbCategory WHERE Category = @Category) = 1
			SELECT @CategoryCode = CategoryCode FROM Cash.tbCategory WHERE Category = @Category;
		ELSE IF NOT EXISTS (SELECT 1 FROM Cash.tbCategory WHERE Category = @Category)
			AND (SELECT COUNT(*) FROM Cash.tbCode WHERE CashDescription = @Category) = 1
			SELECT @CategoryCode = CashCode FROM Cash.tbCode WHERE CashDescription = @Category;
		ELSE
			SET @CategoryCode = N'';
    END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH  
