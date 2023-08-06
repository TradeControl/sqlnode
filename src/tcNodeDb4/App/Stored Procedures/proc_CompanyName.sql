
CREATE   PROCEDURE App.proc_CompanyName
	(
	@AccountName nvarchar(255) = null output
	)
  AS
	SELECT TOP 1 @AccountName = Subject.tbSubject.AccountName
	FROM         Subject.tbSubject INNER JOIN
	                      App.tbOptions ON Subject.tbSubject.AccountCode = App.tbOptions.AccountCode
	 
