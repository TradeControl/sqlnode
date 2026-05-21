CREATE VIEW Subject.vwTypeLookup
AS
    SELECT
        t.SubjectTypeCode,
        t.SubjectType,
        t.CashPolarityCode,
        p.CashPolarity,
        t.SubjectClassCode,
        c.SubjectClass
    FROM Subject.tbType t
        INNER JOIN Cash.tbPolarity p
            ON t.CashPolarityCode = p.CashPolarityCode
        INNER JOIN Subject.tbClass c
            ON t.SubjectClassCode = c.SubjectClassCode;
