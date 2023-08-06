CREATE VIEW Cash.vwUnMirrored
AS
	WITH charge_codes AS
	(
		SELECT DISTINCT Invoice.tbMirror.AccountCode, Invoice.tbMirrorItem.ChargeCode, Subject.tbSubject.AccountName, Invoice.tbMirrorItem.ChargeDescription, Invoice.tbType.CashPolarityCode, Cash.tbPolarity.CashPolarity, 
			Invoice.tbMirrorItem.TaxCode, ROUND(Invoice.tbMirrorItem.TaxValue / Invoice.tbMirrorItem.InvoiceValue, 3) AS TaxRate
		FROM            Invoice.tbMirrorItem INNER JOIN
								 Invoice.tbMirror ON Invoice.tbMirrorItem.ContractAddress = Invoice.tbMirror.ContractAddress INNER JOIN
								 Subject.tbSubject ON Invoice.tbMirror.AccountCode = Subject.tbSubject.AccountCode INNER JOIN
								 Invoice.tbType ON Invoice.tbMirror.InvoiceTypeCode = Invoice.tbType.InvoiceTypeCode INNER JOIN
								 Cash.tbPolarity ON Invoice.tbType.CashPolarityCode = Cash.tbPolarity.CashPolarityCode AND Invoice.tbType.CashPolarityCode = Cash.tbPolarity.CashPolarityCode
		WHERE        (Invoice.tbMirror.InvoiceTypeCode = 0) OR
								 (Invoice.tbMirror.InvoiceTypeCode = 2)
	)
	SELECT CAST(ROW_NUMBER() OVER (ORDER BY charge_codes.AccountCode, charge_codes.ChargeCode) AS int) CandidateId, charge_codes.*
	FROM charge_codes 
		LEFT OUTER JOIN Cash.tbMirror mirror ON charge_codes.AccountCode = mirror.AccountCode AND charge_codes.ChargeCode = mirror.ChargeCode
	WHERE mirror.ChargeCode IS NULL;

