CREATE   FUNCTION Project.fnIsExpense
	(
	@ProjectCode nvarchar(20)
	)
RETURNS bit
AS
	BEGIN
	/* An expense is a Project assigned to an outgoing cash code that is not linked to a sale */
	DECLARE @IsExpense bit
	IF EXISTS (SELECT     Project.tbProject.ProjectCode
	           FROM         Project.tbProject INNER JOIN
	                                 Cash.vwCodeActive ON Project.tbProject.CashCode = Cash.vwCodeActive.CashCode INNER JOIN
	                                 Cash.vwCategoryActive ON Cash.vwCodeActive.CategoryCode = Cash.vwCategoryActive.CategoryCode
	           WHERE     ( Cash.vwCategoryActive.CashPolarityCode = 1) AND ( Project.tbProject.ProjectCode = @ProjectCode))
		SET @IsExpense = 0			          
	ELSE IF EXISTS(SELECT     ParentProjectCode
	          FROM         Project.tbFlow
	          WHERE     (ChildProjectCode = @ProjectCode))
		BEGIN
		DECLARE @ParentProjectCode nvarchar(20)
		SELECT  @ParentProjectCode = ParentProjectCode
		FROM         Project.tbFlow
		WHERE     (ChildProjectCode = @ProjectCode)		
		SET @IsExpense = Project.fnIsExpense(@ParentProjectCode)		
		END	              
	ELSE
		SET @IsExpense = 1
			
	RETURN @IsExpense
	END

