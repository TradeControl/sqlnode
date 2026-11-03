
CREATE   VIEW Project.vwCashPolarity
  AS
SELECT     Project.tbProject.ProjectCode, CASE WHEN Cash.vwCategoryActive.CategoryCode IS NULL 
                      THEN Subject.tbType.CashPolarityCode ELSE Cash.vwCategoryActive.CashPolarityCode END AS CashPolarityCode
FROM         Project.tbProject INNER JOIN
                      Cash.vwCodeActive ON Project.tbProject.CashCode = Cash.vwCodeActive.CashCode INNER JOIN
                      Cash.vwCategoryActive ON Cash.vwCodeActive.CategoryCode = Cash.vwCategoryActive.CategoryCode INNER JOIN
                      Subject.tbSubject ON Project.tbProject.SubjectCode = Subject.tbSubject.SubjectCode INNER JOIN
                      Subject.tbType ON Subject.tbSubject.SubjectTypeCode = Subject.tbType.SubjectTypeCode
