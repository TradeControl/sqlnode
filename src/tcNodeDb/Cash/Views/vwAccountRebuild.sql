
CREATE   VIEW Cash.vwAccountRebuild
  AS
SELECT     Org.tbPayment.CashAccountCode, Org.tbAccount.OpeningBalance, 
                      Org.tbAccount.OpeningBalance + SUM(Org.tbPayment.PaidInValue - Org.tbPayment.PaidOutValue) AS CurrentBalance
FROM         Org.tbPayment INNER JOIN
                      Org.tbAccount ON Org.tbPayment.CashAccountCode = Org.tbAccount.CashAccountCode
WHERE     (Org.tbPayment.PaymentStatusCode = 1) 
GROUP BY Org.tbPayment.CashAccountCode, Org.tbAccount.OpeningBalance
