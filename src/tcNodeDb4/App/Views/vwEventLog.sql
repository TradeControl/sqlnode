
CREATE   VIEW App.vwEventLog
AS
	SELECT eventLog.LogCode,
		eventLog.LoggedOn,
		eventLog.EventTypeCode,
		eventType.EventType,
		eventLog.EventMessage,
		COALESCE([user].UserName, eventLog.InsertedBy) AS InsertedBy,
		eventLog.RowVer
	FROM App.tbEventLog AS eventLog
	JOIN App.tbEventType AS eventType
	  ON eventType.EventTypeCode = eventLog.EventTypeCode
	LEFT JOIN Usr.tbUser AS [user]
	  ON [user].UserId = eventLog.InsertedBy;
