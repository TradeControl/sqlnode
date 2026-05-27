CREATE PROCEDURE Subject.proc_BalanceOutstanding
(
    @SubjectCode nvarchar(50),
    @Balance decimal(18, 5) = 0 OUTPUT,
    @ParentSubjectCode nvarchar(50) = NULL
)
AS
    SET NOCOUNT, XACT_ABORT ON;

    BEGIN TRY
        SET @ParentSubjectCode = NULLIF(LTRIM(RTRIM(@ParentSubjectCode)), N'');

        SELECT
            @Balance = ISNULL(SUM(balance.Balance), 0)
        FROM Subject.vwBalanceOutstanding AS balance
        WHERE balance.SubjectCode = @SubjectCode
          AND
          (
              @ParentSubjectCode IS NULL
              OR balance.ParentSubjectCode = @ParentSubjectCode
          );

        IF EXISTS
        (
            SELECT 1
            FROM Cash.tbPayment AS payment
            WHERE payment.PaymentStatusCode = 0
              AND payment.SubjectCode = @SubjectCode
              AND
              (
                  @ParentSubjectCode IS NULL
                  OR payment.ParentSubjectCode = @ParentSubjectCode
              )
        )
        AND @Balance <> 0
        BEGIN
            SELECT
                @Balance = @Balance - SUM(payment.PaidInValue - payment.PaidOutValue)
            FROM Cash.tbPayment AS payment
            WHERE payment.PaymentStatusCode = 0
              AND payment.SubjectCode = @SubjectCode
              AND
              (
                  @ParentSubjectCode IS NULL
                  OR payment.ParentSubjectCode = @ParentSubjectCode
              );
        END
    END TRY
    BEGIN CATCH
        EXEC App.proc_ErrorLog;
    END CATCH
