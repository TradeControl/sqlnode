CREATE VIEW Project.vwNetworkDeployments
AS
	SELECT DISTINCT Project.tbProject.ProjectCode, Project.tbProject.SubjectCode, Project.tbProject.ObjectCode, Object.tbObject.ObjectDescription, Project.tbProject.ProjectTitle, Project.tbProject.ProjectStatusCode, Project.tbStatus.ProjectStatus, Project.tbProject.ActionOn, Project.tbProject.Quantity, 
							 Cash.vwCategoryActive.CashPolarityCode, Cash.tbPolarity.CashPolarity, App.tbTaxCode.TaxRate, Project.tbProject.UnitCharge, Object.tbObject.UnitOfMeasure,
								 (SELECT        UnitOfCharge
								   FROM            App.tbOptions) AS UnitOfCharge
	FROM            Project.tbChangeLog INNER JOIN
							 Project.tbProject ON Project.tbChangeLog.ProjectCode = Project.tbProject.ProjectCode INNER JOIN
							 Cash.vwCodeActive ON Project.tbProject.CashCode = Cash.vwCodeActive.CashCode INNER JOIN
							 Cash.vwCategoryActive ON Cash.vwCodeActive.CategoryCode = Cash.vwCategoryActive.CategoryCode AND Cash.vwCodeActive.CategoryCode = Cash.vwCategoryActive.CategoryCode INNER JOIN
							 App.tbTaxCode ON Project.tbProject.TaxCode = App.tbTaxCode.TaxCode AND Project.tbProject.TaxCode = App.tbTaxCode.TaxCode INNER JOIN
							 Object.tbObject ON Project.tbProject.ObjectCode = Object.tbObject.ObjectCode AND Project.tbProject.ObjectCode = Object.tbObject.ObjectCode INNER JOIN
							 Project.tbStatus ON Project.tbProject.ProjectStatusCode = Project.tbStatus.ProjectStatusCode INNER JOIN
							 Cash.tbPolarity ON Cash.vwCategoryActive.CashPolarityCode = Cash.tbPolarity.CashPolarityCode AND Cash.vwCategoryActive.CashPolarityCode = Cash.tbPolarity.CashPolarityCode
	WHERE        (Project.tbChangeLog.TransmitStatusCode = 1)
