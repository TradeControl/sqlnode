﻿
CREATE   VIEW Subject.vwListActive
AS
	SELECT        TOP (100) PERCENT Subject.tbSubject.AccountCode, Subject.tbSubject.AccountName, Subject.tbType.CashPolarityCode
	FROM            Subject.tbSubject INNER JOIN
							 Project.tbProject ON Subject.tbSubject.AccountCode = Project.tbProject.AccountCode INNER JOIN
							 Subject.tbType ON Subject.tbSubject.SubjectTypeCode = Subject.tbType.SubjectTypeCode
	WHERE        (Project.tbProject.ProjectStatusCode = 1 OR
							 Project.tbProject.ProjectStatusCode = 2) AND (Project.tbProject.CashCode IS NOT NULL)
	GROUP BY Subject.tbSubject.AccountCode, Subject.tbSubject.AccountName, Subject.tbType.CashPolarityCode
	ORDER BY Subject.tbSubject.AccountName;
