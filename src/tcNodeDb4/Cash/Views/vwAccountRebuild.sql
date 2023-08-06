CREATE VIEW Cash.vwAccountRebuild
AS
	SELECT     Cash.tbPayment.CashAccountCode, Subject.tbAccount.OpeningBalance, 
						  Subject.tbAccount.OpeningBalance + SUM(Cash.tbPayment.PaidInValue - Cash.tbPayment.PaidOutValue) AS CurrentBalance
	FROM         Cash.tbPayment INNER JOIN
						  Subject.tbAccount ON Cash.tbPayment.CashAccountCode = Subject.tbAccount.CashAccountCode
	WHERE     (Cash.tbPayment.PaymentStatusCode = 1) 
	GROUP BY Cash.tbPayment.CashAccountCode, Subject.tbAccount.OpeningBalance
