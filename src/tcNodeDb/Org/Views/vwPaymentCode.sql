
CREATE   VIEW Org.vwPaymentCode
AS
	SELECT CONCAT((SELECT UserId FROM Usr.vwCredentials), '_', FORMAT(CURRENT_TIMESTAMP, 'yyyymmdd_hhmmss')) AS PaymentCode
