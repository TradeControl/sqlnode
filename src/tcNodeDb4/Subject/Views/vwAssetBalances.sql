CREATE VIEW Subject.vwAssetBalances
AS
    WITH financial_periods AS
    (
        SELECT period.StartOn
        FROM App.tbYear AS year
            INNER JOIN App.tbYearPeriod AS period
                ON year.YearNumber = period.YearNumber
        WHERE year.CashStatusCode BETWEEN 1 AND 2
    ),
    subject_instances AS
    (
        SELECT
            ns.ChildSubjectCode AS SubjectCode,
            ns.ParentSubjectCode
        FROM Subject.tbNamespace AS ns

        UNION

        SELECT
            subject.SubjectCode,
            CAST(NULL AS nvarchar(50)) AS ParentSubjectCode
        FROM Subject.tbSubject AS subject
        WHERE NOT EXISTS
        (
            SELECT 1
            FROM Subject.tbNamespace AS ns
            WHERE ns.ChildSubjectCode = subject.SubjectCode
        )
    ),
    subject_periods AS
    (
        SELECT
            instance.SubjectCode,
            instance.ParentSubjectCode,
            period.StartOn
        FROM subject_instances AS instance
            CROSS JOIN financial_periods AS period
    ),
    subject_statements AS
    (
        SELECT
            statement.StartOn,
            statement.SubjectCode,
            statement.ParentSubjectCode,
            statement.RowNumber,
            statement.TransactedOn,
            statement.Balance,
            MAX(statement.RowNumber) OVER
            (
                PARTITION BY
                    statement.SubjectCode,
                    statement.ParentSubjectCode,
                    statement.StartOn
                ORDER BY statement.StartOn
            ) AS LastRowNumber
        FROM Subject.vwAssetStatement AS statement
        WHERE statement.TransactedOn >= (SELECT StartOn FROM Cash.vwBalanceStartOn)
    ),
    subject_balances AS
    (
        SELECT
            SubjectCode,
            ParentSubjectCode,
            StartOn,
            Balance
        FROM subject_statements
        WHERE RowNumber = LastRowNumber
    ),
    subject_ordered AS
    (
        SELECT
            ROW_NUMBER() OVER
            (
                ORDER BY
                    period.SubjectCode,
                    period.ParentSubjectCode,
                    period.StartOn
            ) AS EntryNumber,
            period.SubjectCode,
            period.ParentSubjectCode,
            period.StartOn,
            COALESCE(balance.Balance, 0) AS Balance,
            CASE
                WHEN balance.StartOn IS NULL THEN 0
                ELSE 1
            END AS IsEntry
        FROM subject_periods AS period
            LEFT OUTER JOIN subject_balances AS balance
                ON period.SubjectCode = balance.SubjectCode
               AND
               (
                   period.ParentSubjectCode = balance.ParentSubjectCode
                   OR
                   (
                       period.ParentSubjectCode IS NULL
                       AND balance.ParentSubjectCode IS NULL
                   )
               )
               AND period.StartOn = balance.StartOn
    ),
    subject_ranked AS
    (
        SELECT
            *,
            RANK() OVER
            (
                PARTITION BY
                    SubjectCode,
                    ParentSubjectCode,
                    IsEntry
                ORDER BY EntryNumber
            ) AS RNK
        FROM subject_ordered
    ),
    subject_grouped AS
    (
        SELECT
            EntryNumber,
            SubjectCode,
            ParentSubjectCode,
            StartOn,
            IsEntry,
            Balance,
            MAX(CASE IsEntry WHEN 0 THEN 0 ELSE RNK END) OVER
            (
                PARTITION BY
                    SubjectCode,
                    ParentSubjectCode
                ORDER BY EntryNumber
            ) AS RNK
        FROM subject_ranked
    ),
    subject_projected AS
    (
        SELECT
            EntryNumber,
            SubjectCode,
            ParentSubjectCode,
            StartOn,
            IsEntry,
            CASE IsEntry
                WHEN 0 THEN
                    MAX(Balance) OVER
                    (
                        PARTITION BY
                            SubjectCode,
                            ParentSubjectCode,
                            RNK
                        ORDER BY EntryNumber
                    ) +
                    MIN(Balance) OVER
                    (
                        PARTITION BY
                            SubjectCode,
                            ParentSubjectCode,
                            RNK
                        ORDER BY EntryNumber
                    )
                ELSE Balance
            END AS Balance
        FROM subject_grouped
    ),
    subject_entries AS
    (
        SELECT
            SubjectCode,
            ParentSubjectCode,
            EntryNumber,
            StartOn,
            Balance * -1 AS Balance,
            CASE
                WHEN Balance < 0 THEN 0
                ELSE 1
            END AS AssetTypeCode,
            CASE
                WHEN Balance <> 0 THEN 1
                ELSE IsEntry
            END AS IsEntry
        FROM subject_projected
    )
    SELECT
        SubjectCode,
        ParentSubjectCode,
        StartOn,
        Balance,
        CASE
            WHEN Balance <> 0 THEN AssetTypeCode
            ELSE COALESCE
            (
                LAG(AssetTypeCode) OVER
                (
                    PARTITION BY
                        SubjectCode,
                        ParentSubjectCode
                    ORDER BY EntryNumber
                ),
                0
            )
        END AS AssetTypeCode
    FROM subject_entries
    WHERE IsEntry = 1;
