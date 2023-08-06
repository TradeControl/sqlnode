CREATE VIEW Subject.vwInvoiceSummary
AS
	WITH ois AS
	(
		SELECT        AccountCode, StartOn, SUM(InvoiceValue) AS PeriodValue
		FROM            Invoice.vwRegister
		GROUP BY AccountCode, StartOn
	), acc AS
	(
		SELECT Subject.tbSubject.AccountCode, App.vwPeriods.StartOn
		FROM Subject.tbSubject CROSS JOIN App.vwPeriods
	)
	SELECT TOP (100) PERCENT acc.AccountCode, acc.StartOn, ois.PeriodValue 
	FROM ois RIGHT OUTER JOIN acc ON ois.AccountCode = acc.AccountCode AND ois.StartOn = acc.StartOn
	ORDER BY acc.AccountCode, acc.StartOn;

