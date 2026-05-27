CREATE PROCEDURE Cash.proc_PaymentAdd
    @SubjectCode nvarchar(50),
    @AccountCode nvarchar(10),
    @CashCode nvarchar(50),
    @PaidOn datetime,
    @ToPay decimal(18, 5),
    @PaymentReference nvarchar(50) = NULL,
    @PaymentCode nvarchar(20) OUTPUT,
    @ParentSubjectCode nvarchar(50) = NULL
AS
    SET NOCOUNT, XACT_ABORT ON;

    BEGIN TRY
        EXEC Cash.proc_NextPaymentCode @PaymentCode OUTPUT;

        INSERT INTO Cash.tbPayment
        (
            PaymentCode,
            UserId,
            PaymentStatusCode,
            SubjectCode,
            ParentSubjectCode,
            AccountCode,
            CashCode,
            TaxCode,
            PaidOn,
            PaidInValue,
            PaidOutValue,
            PaymentReference
        )
        SELECT
            @PaymentCode,
            (SELECT UserId FROM Usr.vwCredentials),
            0,
            @SubjectCode,
            @ParentSubjectCode,
            @AccountCode,
            @CashCode,
            code.TaxCode,
            @PaidOn,
            CASE WHEN @ToPay > 0 THEN @ToPay ELSE 0 END,
            CASE WHEN @ToPay < 0 THEN ABS(@ToPay) ELSE 0 END,
            @PaymentReference
        FROM Cash.tbCode AS code
        WHERE code.CashCode = @CashCode;
    END TRY
    BEGIN CATCH
        EXEC App.proc_ErrorLog;
    END CATCH
