﻿CREATE VIEW Cash.vwTransfersUnposted
AS
	SELECT        PaymentCode, UserId, PaymentStatusCode, AccountCode, CashAccountCode, CashCode, TaxCode, PaidOn, PaidInValue, PaidOutValue, TaxInValue, TaxOutValue, PaymentReference, InsertedBy, InsertedOn, 
							 UpdatedBy, UpdatedOn, RowVer
	FROM            Cash.tbPayment
	WHERE        (PaymentStatusCode = 2)
