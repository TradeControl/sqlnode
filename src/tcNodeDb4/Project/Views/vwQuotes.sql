CREATE   VIEW Project.vwQuotes
AS
	SELECT        Project.tbProject.UserId, Cash.vwCategoryActive.CashPolarityCode, Cash.tbPolarity.CashPolarity, Project.tbProject.ActionOn, Project.tbProject.ProjectCode, Project.tbProject.SubjectCode, Project.tbProject.ContactName, Project.tbProject.ObjectCode, 
							 Project.tbProject.ProjectTitle, Project.tbProject.SecondReference, Project.tbProject.TaxCode, Project.tbProject.Quantity, Project.tbProject.UnitCharge, Project.tbProject.TotalCharge, Project.vwBucket.Period, Project.vwBucket.BucketId, Project.tbProject.CashCode, 
							 Cash.vwCodeActive.CashDescription, tbUser_1.UserName AS OwnerName, Subject.tbSubject.SubjectName, Project.tbProject.RowVer
	FROM            Subject.tbSubject INNER JOIN
							 Project.tbProject ON Subject.tbSubject.SubjectCode = Project.tbProject.SubjectCode INNER JOIN
							 Usr.tbUser AS tbUser_1 ON Project.tbProject.UserId = tbUser_1.UserId INNER JOIN
							 Project.vwBucket ON Project.tbProject.ProjectCode = Project.vwBucket.ProjectCode INNER JOIN
							 Cash.vwCodeActive ON Project.tbProject.CashCode = Cash.vwCodeActive.CashCode INNER JOIN
							 Cash.vwCategoryActive ON Cash.vwCodeActive.CategoryCode = Cash.vwCategoryActive.CategoryCode INNER JOIN
							 Cash.tbPolarity ON Cash.vwCategoryActive.CashPolarityCode = Cash.tbPolarity.CashPolarityCode
	WHERE        (Project.tbProject.ProjectStatusCode = 0);
