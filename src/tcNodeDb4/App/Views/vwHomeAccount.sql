
CREATE   VIEW App.vwHomeAccount
AS
	SELECT     Subject.tbSubject.AccountCode, Subject.tbSubject.AccountName
	FROM            App.tbOptions INNER JOIN
							 Subject.tbSubject ON App.tbOptions.AccountCode = Subject.tbSubject.AccountCode
