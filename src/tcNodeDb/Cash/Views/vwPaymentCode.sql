﻿CREATE VIEW Cash.vwPaymentCode
AS
	SELECT CONCAT(LEFT((SELECT UserId FROM Usr.vwCredentials), 2), '_', FORMAT(CURRENT_TIMESTAMP, 'yyMMdd_HHmmss'), '_', DATEPART(MILLISECOND, CURRENT_TIMESTAMP)) AS PaymentCode
