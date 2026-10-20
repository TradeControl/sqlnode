
CREATE   VIEW App.vwDocSpool
 AS
SELECT     DocTypeCode, DocumentNumber
FROM         App.tbDocSpool
WHERE     (UserName = Usr.fnUserName())
