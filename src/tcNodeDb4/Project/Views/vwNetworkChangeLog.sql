CREATE VIEW Project.vwNetworkChangeLog
AS
	SELECT Project.tbProject.AccountCode, Subject.tbSubject.AccountName, Project.tbProject.ProjectCode, Project.tbChangeLog.LogId, Project.tbChangeLog.ChangedOn, Project.tbChangeLog.TransmitStatusCode, Subject.tbTransmitStatus.TransmitStatus, 
				Project.tbChangeLog.ObjectCode, Object.tbMirror.AllocationCode, Project.tbChangeLog.ProjectStatusCode, Project.tbStatus.ProjectStatus, Cash.tbPolarity.CashPolarityCode, Cash.tbPolarity.CashPolarity, Project.tbChangeLog.ActionOn, 
				Project.tbChangeLog.TaxCode, Project.tbChangeLog.Quantity, Project.tbChangeLog.UnitCharge, Project.tbChangeLog.UpdatedBy, Project.tbChangeLog.RowVer
	FROM Project.tbChangeLog 
		INNER JOIN Project.tbProject ON Project.tbChangeLog.ProjectCode = Project.tbProject.ProjectCode INNER JOIN
				Cash.tbCode ON Project.tbProject.CashCode = Cash.tbCode.CashCode INNER JOIN
				Cash.tbCategory ON Cash.tbCode.CategoryCode = Cash.tbCategory.CategoryCode AND Cash.tbCode.CategoryCode = Cash.tbCategory.CategoryCode INNER JOIN
				Cash.tbPolarity ON Cash.tbCategory.CashPolarityCode = Cash.tbPolarity.CashPolarityCode AND Cash.tbCategory.CashPolarityCode = Cash.tbPolarity.CashPolarityCode INNER JOIN
				Subject.tbSubject ON Project.tbProject.AccountCode = Subject.tbSubject.AccountCode AND Project.tbProject.AccountCode = Subject.tbSubject.AccountCode AND Project.tbProject.AccountCode = Subject.tbSubject.AccountCode INNER JOIN
				Subject.tbTransmitStatus ON Project.tbChangeLog.TransmitStatusCode = Subject.tbTransmitStatus.TransmitStatusCode AND Project.tbChangeLog.TransmitStatusCode = Subject.tbTransmitStatus.TransmitStatusCode AND 
				Project.tbChangeLog.TransmitStatusCode = Subject.tbTransmitStatus.TransmitStatusCode AND Project.tbChangeLog.TransmitStatusCode = Subject.tbTransmitStatus.TransmitStatusCode AND 
				Project.tbChangeLog.TransmitStatusCode = Subject.tbTransmitStatus.TransmitStatusCode INNER JOIN
				Project.tbStatus ON Project.tbChangeLog.ProjectStatusCode = Project.tbStatus.ProjectStatusCode LEFT OUTER JOIN
				Object.tbMirror ON Project.tbChangeLog.AccountCode = Object.tbMirror.AccountCode AND Project.tbChangeLog.ObjectCode = Object.tbMirror.ObjectCode
	WHERE Project.tbChangeLog.TransmitStatusCode > 0
