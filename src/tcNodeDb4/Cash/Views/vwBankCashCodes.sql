CREATE VIEW Cash.vwBankCashCodes
AS
	SELECT Cash.vwCodeActive.CashCode, Cash.vwCodeActive.CashDescription, Cash.vwCodeActive.TaxCode, Cash.vwCategoryActive.CashPolarityCode
	FROM Cash.vwCodeActive
        INNER JOIN Cash.vwCategoryActive
            ON Cash.vwCodeActive.CategoryCode = Cash.vwCategoryActive.CategoryCode
        LEFT OUTER JOIN Cash.vwTransferCodeLookup
            ON Cash.vwCodeActive.CashCode = Cash.vwTransferCodeLookup.CashCode
	WHERE
        (Cash.vwCategoryActive.CashTypeCode = 2)
        AND (Cash.vwCategoryActive.IsEnabled != 0)
        AND (Cash.vwCodeActive.IsEnabled != 0)
        AND (Cash.vwTransferCodeLookup.CashCode IS NULL)
