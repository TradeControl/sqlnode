CREATE VIEW Subject.vwCurrentBalance
AS
    WITH current_balance AS
    (
        SELECT
            SubjectCode,
            ParentSubjectCode,
            MAX(RowNumber) AS CurrentBalanceRow
        FROM Subject.vwStatement
        GROUP BY
            SubjectCode,
            ParentSubjectCode
    )
    SELECT
        statement.SubjectCode,
        statement.ParentSubjectCode,
        statement.Balance
    FROM Subject.vwStatement AS statement
        JOIN current_balance
            ON statement.SubjectCode = current_balance.SubjectCode
           AND
           (
               statement.ParentSubjectCode = current_balance.ParentSubjectCode
               OR
               (
                   statement.ParentSubjectCode IS NULL
                   AND current_balance.ParentSubjectCode IS NULL
               )
           )
           AND statement.RowNumber = current_balance.CurrentBalanceRow;
