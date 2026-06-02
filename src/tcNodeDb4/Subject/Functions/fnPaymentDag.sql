CREATE FUNCTION Subject.fnPaymentDag
(
    @SubjectCode nvarchar(50),
    @ParentSubjectCode nvarchar(50) = NULL
)
RETURNS TABLE
AS
RETURN
(
    WITH closure AS
    (
        SELECT
            SubjectCode,
            ParentSubjectCode,
            Depth
        FROM Subject.fnNamespaceClosure(@SubjectCode, @ParentSubjectCode)
    )
    SELECT
        payment.PaymentCode,
        payment.PaidOn,
        payment.PaymentReference,
        payment.PaidOutValue,
        payment.PaidInValue,
        account.AccountName,
        [user].UserName
    FROM Cash.tbPayment AS payment
        JOIN closure AS c
            ON c.SubjectCode = payment.SubjectCode
           AND ISNULL(c.ParentSubjectCode, N'') = ISNULL(payment.ParentSubjectCode, N'')
        JOIN Subject.tbAccount AS account
            ON payment.AccountCode = account.AccountCode
        JOIN Usr.tbUser AS [user]
            ON payment.UserId = [user].UserId
);
GO
