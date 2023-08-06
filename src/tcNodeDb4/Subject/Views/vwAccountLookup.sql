CREATE VIEW Subject.vwAccountLookup
AS
SELECT        Subject.tbSubject.AccountCode, Subject.tbSubject.AccountName, Subject.tbType.SubjectType, Cash.tbPolarity.CashPolarity, Cash.tbPolarity.CashPolarityCode
FROM            Subject.tbSubject INNER JOIN
                         Subject.tbType ON Subject.tbSubject.SubjectTypeCode = Subject.tbType.SubjectTypeCode INNER JOIN
                         Cash.tbPolarity ON Subject.tbType.CashPolarityCode = Cash.tbPolarity.CashPolarityCode
WHERE        (Subject.tbSubject.SubjectStatusCode < 3);
