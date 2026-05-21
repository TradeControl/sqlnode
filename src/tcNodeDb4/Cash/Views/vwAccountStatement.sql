CREATE VIEW Cash.vwAccountStatement
AS
    WITH posted_entries AS
    (
        SELECT
            payment.AccountCode,
            payment.CashCode,
            ROW_NUMBER() OVER (PARTITION BY payment.AccountCode ORDER BY payment.PaidOn) AS EntryNumber,
            payment.PaymentCode,
            payment.PaidOn,
            CASE
                WHEN payment.PaidInValue > 0 THEN payment.PaidInValue
                ELSE payment.PaidOutValue * -1
            END AS Paid
        FROM Cash.tbPayment AS payment
            INNER JOIN Subject.tbAccount AS cash_account
                ON payment.AccountCode = cash_account.AccountCode
        WHERE payment.PaymentStatusCode = 1
          AND cash_account.AccountClosed = 0
    ),
    opening_entries AS
    (
        SELECT
            cash_account.AccountCode,
            COALESCE(
                cash_account.CashCode,
                (
                    SELECT TOP (1) bank_codes.CashCode
                    FROM Cash.vwBankCashCodes AS bank_codes
                    WHERE bank_codes.CashPolarityCode = 2
                )
            ) AS CashCode,
            0 AS EntryNumber,
            (
                SELECT CAST(app_text.Message AS NVARCHAR(30))
                FROM App.tbText AS app_text
                WHERE app_text.TextId = 3005
            ) AS PaymentCode,
            DATEADD(
                HOUR,
                -1,
                (
                    SELECT MIN(payment.PaidOn)
                    FROM Cash.tbPayment AS payment
                    WHERE payment.AccountCode = cash_account.AccountCode
                )
            ) AS PaidOn,
            cash_account.OpeningBalance AS Paid
        FROM Subject.tbAccount AS cash_account
        WHERE cash_account.AccountClosed = 0
    ),
    entries AS
    (
        SELECT
            AccountCode,
            CashCode,
            EntryNumber,
            PaymentCode,
            PaidOn,
            Paid
        FROM posted_entries

        UNION ALL

        SELECT
            AccountCode,
            CashCode,
            EntryNumber,
            PaymentCode,
            PaidOn,
            Paid
        FROM opening_entries
    ),
    running_balance AS
    (
        SELECT
            entries.AccountCode,
            entries.CashCode,
            entries.EntryNumber,
            entries.PaymentCode,
            entries.PaidOn,
            SUM(entries.Paid) OVER (
                PARTITION BY entries.AccountCode
                ORDER BY entries.EntryNumber
                ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
            ) AS PaidBalance
        FROM entries
    ),
    payment_details AS
    (
        SELECT
            payment.PaymentCode,
            payment.AccountCode,
            payment.SubjectCode,
            payment.ParentSubjectCode,
            subject.SubjectName,
            [user].UserName,
            payment.CashCode,
            cash_code.CashDescription,
            payment.TaxCode,
            tax_code.TaxDescription,
            payment.PaidInValue,
            payment.PaidOutValue,
            payment.PaymentReference,
            payment.InsertedBy,
            payment.InsertedOn,
            payment.UpdatedBy,
            payment.UpdatedOn
        FROM Cash.tbPayment AS payment
            INNER JOIN Usr.tbUser AS [user]
                ON payment.UserId = [user].UserId
            INNER JOIN Subject.tbSubject AS subject
                ON payment.SubjectCode = subject.SubjectCode
            LEFT OUTER JOIN App.tbTaxCode AS tax_code
                ON payment.TaxCode = tax_code.TaxCode
            LEFT OUTER JOIN Cash.tbCode AS cash_code
                ON payment.CashCode = cash_code.CashCode
    ),
    min_period AS
    (
        SELECT MIN(year_period.StartOn) AS StartOn
        FROM App.tbYearPeriod AS year_period
    )
    SELECT
        running_balance.AccountCode,
        COALESCE(period_lookup.StartOn, min_period.StartOn) AS StartOn,
        running_balance.EntryNumber,
        running_balance.PaymentCode,
        running_balance.PaidOn,
        payment_details.SubjectName,
        payment_details.PaymentReference,
        COALESCE(payment_details.PaidInValue, 0) AS PaidInValue,
        COALESCE(payment_details.PaidOutValue, 0) AS PaidOutValue,
        CAST(running_balance.PaidBalance AS DECIMAL(18, 5)) AS PaidBalance,
        payment_details.CashCode,
        payment_details.CashDescription,
        payment_details.TaxDescription,
        payment_details.UserName,
        payment_details.SubjectCode,
        payment_details.ParentSubjectCode,
        payment_details.TaxCode
    FROM running_balance
        LEFT OUTER JOIN payment_details
            ON running_balance.PaymentCode = payment_details.PaymentCode
        OUTER APPLY
        (
            SELECT TOP (1) year_period.StartOn
            FROM App.tbYearPeriod AS year_period
            WHERE year_period.StartOn <= running_balance.PaidOn
            ORDER BY year_period.StartOn DESC
        ) AS period_lookup
        CROSS JOIN min_period;
