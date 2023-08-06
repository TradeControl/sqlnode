
CREATE   VIEW Subject.vwAccountSources
AS
SELECT        AccountSource
FROM            Subject.tbSubject
GROUP BY AccountSource
HAVING        (AccountSource IS NOT NULL);
