CREATE VIEW App.vwGraphProjectObject
AS
SELECT        CONCAT(Project.tbStatus.ProjectStatus, SPACE(1), Cash.tbPolarity.CashPolarity) AS Category, SUM(Project.tbProject.TotalCharge) AS SumOfTotalCharge
FROM            Project.tbProject INNER JOIN
                         Project.tbStatus ON Project.tbProject.ProjectStatusCode = Project.tbStatus.ProjectStatusCode INNER JOIN
                         Cash.vwCodeActive ON Project.tbProject.CashCode = Cash.vwCodeActive.CashCode INNER JOIN
                         Cash.vwCategoryActive ON Cash.vwCodeActive.CategoryCode = Cash.vwCategoryActive.CategoryCode INNER JOIN
                         Cash.tbPolarity ON Cash.vwCategoryActive.CashPolarityCode = Cash.tbPolarity.CashPolarityCode
WHERE        (Project.tbProject.ProjectStatusCode < 3) AND (Project.tbProject.ProjectStatusCode > 0)
GROUP BY CONCAT(Project.tbStatus.ProjectStatus, SPACE(1), Cash.tbPolarity.CashPolarity);
