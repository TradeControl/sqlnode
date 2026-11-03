CREATE VIEW Project.vwNetworkChangeLog
AS
	SELECT Project.tbProject.SubjectCode, Subject.tbSubject.SubjectName, Project.tbProject.ProjectCode, Project.tbChangeLog.LogId, Project.tbChangeLog.ChangedOn, Project.tbChangeLog.TransmitStatusCode, Subject.tbTransmitStatus.TransmitStatus, 
				Project.tbChangeLog.ObjectCode, Object.tbMirror.AllocationCode, Project.tbChangeLog.ProjectStatusCode, Project.tbStatus.ProjectStatus, Cash.tbPolarity.CashPolarityCode, Cash.tbPolarity.CashPolarity, Project.tbChangeLog.ActionOn, 
				Project.tbChangeLog.TaxCode, Project.tbChangeLog.Quantity, Project.tbChangeLog.UnitCharge, Project.tbChangeLog.UpdatedBy, Project.tbChangeLog.RowVer
	FROM Project.tbChangeLog 
		INNER JOIN Project.tbProject ON Project.tbChangeLog.ProjectCode = Project.tbProject.ProjectCode INNER JOIN
				Cash.vwCodeActive ON Project.tbProject.CashCode = Cash.vwCodeActive.CashCode INNER JOIN
				Cash.vwCategoryActive ON Cash.vwCodeActive.CategoryCode = Cash.vwCategoryActive.CategoryCode AND Cash.vwCodeActive.CategoryCode = Cash.vwCategoryActive.CategoryCode INNER JOIN
				Cash.tbPolarity ON Cash.vwCategoryActive.CashPolarityCode = Cash.tbPolarity.CashPolarityCode AND Cash.vwCategoryActive.CashPolarityCode = Cash.tbPolarity.CashPolarityCode INNER JOIN
				Subject.tbSubject ON Project.tbProject.SubjectCode = Subject.tbSubject.SubjectCode AND Project.tbProject.SubjectCode = Subject.tbSubject.SubjectCode AND Project.tbProject.SubjectCode = Subject.tbSubject.SubjectCode INNER JOIN
				Subject.tbTransmitStatus ON Project.tbChangeLog.TransmitStatusCode = Subject.tbTransmitStatus.TransmitStatusCode AND Project.tbChangeLog.TransmitStatusCode = Subject.tbTransmitStatus.TransmitStatusCode AND 
				Project.tbChangeLog.TransmitStatusCode = Subject.tbTransmitStatus.TransmitStatusCode AND Project.tbChangeLog.TransmitStatusCode = Subject.tbTransmitStatus.TransmitStatusCode AND 
				Project.tbChangeLog.TransmitStatusCode = Subject.tbTransmitStatus.TransmitStatusCode INNER JOIN
				Project.tbStatus ON Project.tbChangeLog.ProjectStatusCode = Project.tbStatus.ProjectStatusCode LEFT OUTER JOIN
				Object.tbMirror ON Project.tbChangeLog.SubjectCode = Object.tbMirror.SubjectCode AND Project.tbChangeLog.ObjectCode = Object.tbMirror.ObjectCode
	WHERE Project.tbChangeLog.TransmitStatusCode > 0
