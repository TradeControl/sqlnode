
CREATE   VIEW App.vwWarehouseSubject
AS
SELECT TOP (100) PERCENT Subject.tbSubject.AccountCode, Subject.tbDoc.DocumentName, Subject.tbSubject.AccountName, Subject.tbDoc.DocumentImage, Subject.tbDoc.DocumentDescription, Subject.tbDoc.InsertedBy, Subject.tbDoc.InsertedOn, Subject.tbDoc.UpdatedBy, 
                         Subject.tbDoc.UpdatedOn, Subject.tbDoc.RowVer
FROM            Subject.tbSubject INNER JOIN
                         Subject.tbDoc ON Subject.tbSubject.AccountCode = Subject.tbDoc.AccountCode
ORDER BY Subject.tbDoc.AccountCode, Subject.tbDoc.DocumentName;
