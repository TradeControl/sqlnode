CREATE FUNCTION Subject.fnCurrentAgedInvoices
(
    @AgedOn date
)
RETURNS TABLE
AS
RETURN
(
    WITH item_totals AS
    (
        SELECT
            item.SubjectCode,
            MAX(item.SubjectName) AS SubjectName,
            item.AgedOn,
            CAST(SUM(item.BusinessAmount) AS decimal(18, 5)) AS BusinessBalance,
            CAST(SUM(CASE item.AgeBandCode WHEN 0 THEN item.BusinessAmount ELSE 0 END) AS decimal(18, 5)) AS CurrentAmount,
            CAST(SUM(CASE item.AgeBandCode WHEN 1 THEN item.BusinessAmount ELSE 0 END) AS decimal(18, 5)) AS Days1To30Amount,
            CAST(SUM(CASE item.AgeBandCode WHEN 2 THEN item.BusinessAmount ELSE 0 END) AS decimal(18, 5)) AS Days31To60Amount,
            CAST(SUM(CASE item.AgeBandCode WHEN 3 THEN item.BusinessAmount ELSE 0 END) AS decimal(18, 5)) AS Days61To90Amount,
            CAST(SUM(CASE item.AgeBandCode WHEN 4 THEN item.BusinessAmount ELSE 0 END) AS decimal(18, 5)) AS Over90Amount
        FROM Subject.fnCurrentAgedInvoiceItems(@AgedOn) AS item
        GROUP BY
            item.SubjectCode,
            item.AgedOn
        HAVING SUM(item.BusinessAmount) <> 0
    )
    SELECT
        item.SubjectCode,
        item.SubjectName,
        item.AgedOn,
        item.BusinessBalance,
        CAST(CASE WHEN item.BusinessBalance > 0 THEN 0 ELSE 1 END AS smallint) AS PositionCode,
        CAST(item.CurrentAmount * SIGN(item.BusinessBalance) AS decimal(18, 5)) AS CurrentAmount,
        CAST(item.Days1To30Amount * SIGN(item.BusinessBalance) AS decimal(18, 5)) AS Days1To30Amount,
        CAST(item.Days31To60Amount * SIGN(item.BusinessBalance) AS decimal(18, 5)) AS Days31To60Amount,
        CAST(item.Days61To90Amount * SIGN(item.BusinessBalance) AS decimal(18, 5)) AS Days61To90Amount,
        CAST(item.Over90Amount * SIGN(item.BusinessBalance) AS decimal(18, 5)) AS Over90Amount,
        reconciliation.StatementBusinessBalance,
        reconciliation.ReconciliationResidual
    FROM item_totals AS item
        JOIN Subject.fnCurrentInvoiceReconciliation() AS reconciliation
            ON item.SubjectCode = reconciliation.SubjectCode
);
GO
