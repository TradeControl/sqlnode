
CREATE   VIEW Subject.vwMailContacts
  AS
SELECT     AccountCode, ContactName, NickName, NameTitle + N' ' + ContactName AS FormalName, JobTitle, Department
FROM         Subject.tbContact
WHERE     (OnMailingList <> 0)

