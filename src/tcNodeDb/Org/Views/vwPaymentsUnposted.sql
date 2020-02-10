
CREATE   VIEW Org.vwPaymentsUnposted
AS
SELECT        PaymentCode, UserId, PaymentStatusCode, AccountCode, CashAccountCode, CashCode, TaxCode, PaidOn, PaidInValue, PaidOutValue, TaxInValue, TaxOutValue, PaymentReference, InsertedBy, InsertedOn, 
                         UpdatedBy, UpdatedOn, RowVer
FROM            Org.tbPayment
WHERE        (PaymentStatusCode = 0)
