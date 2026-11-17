/*
    Common Project business-tax accrual contract consumed by statement, audit,
    summary and Cash Statement generation. Provider selection occurs once in
    fnTaxBizAccrualsSelected.
*/
CREATE VIEW Cash.vwTaxBizAccruals
AS
SELECT StartOn,
       ProjectCode,
       QuantityRemaining,
       OrderValue,
       TaxDue
FROM Cash.fnTaxBizAccrualsSelected();
GO
