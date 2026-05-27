CREATE PROCEDURE Cash.proc_TxPayIn
(
    @AccountCode nvarchar(10),
    @PaymentAddress nvarchar(42),
    @TxId nvarchar(64),
    @SubjectCode nvarchar(50),
    @CashCode nvarchar(50),
    @PaidOn datetime,
    @PaymentReference nvarchar(50) = NULL,
    @PaymentCode nvarchar(20) OUTPUT,
    @ParentSubjectCode nvarchar(50) = NULL
)
AS
    SET NOCOUNT, XACT_ABORT ON;

    BEGIN TRY
        DECLARE
            @ToPay decimal(18, 5),
            @Confirmations int;

        SELECT
            @ToPay = tx.MoneyIn - tx.MoneyOut,
            @Confirmations = tx.Confirmations
        FROM Cash.tbTx AS tx
        WHERE tx.TxId = @TxId
          AND tx.PaymentAddress = @PaymentAddress;

        IF NOT EXISTS
        (
            SELECT 1
            FROM Subject.tbSubject AS subject
            WHERE subject.SubjectCode = @SubjectCode
        )
        BEGIN
            SELECT @SubjectCode = SubjectCode
            FROM App.vwHomeAccount;

            SET @ParentSubjectCode = NULL;
        END
        ELSE IF @Confirmations = 0
        BEGIN
            RETURN 1;
        END;

        BEGIN TRANSACTION;

        EXEC Cash.proc_PaymentAdd
            @SubjectCode = @SubjectCode,
            @AccountCode = @AccountCode,
            @CashCode = @CashCode,
            @PaidOn = @PaidOn,
            @ToPay = @ToPay,
            @PaymentReference = @PaymentReference,
            @PaymentCode = @PaymentCode OUTPUT,
            @ParentSubjectCode = @ParentSubjectCode;

        UPDATE Cash.tbTx
        SET TxStatusCode = 1
        WHERE TxId = @TxId
          AND PaymentAddress = @PaymentAddress;

        INSERT INTO Cash.tbTxReference
        (
            TxNumber,
            PaymentCode,
            TxStatusCode
        )
        SELECT
            tx.TxNumber,
            @PaymentCode,
            tx.TxStatusCode
        FROM Cash.tbTx AS tx
        WHERE tx.TxId = @TxId
          AND tx.PaymentAddress = @PaymentAddress;

        IF EXISTS
        (
            SELECT 1
            FROM Cash.tbPayment AS payment
            WHERE payment.PaymentCode = @PaymentCode
              AND payment.PaymentStatusCode = 2
        )
        BEGIN
            EXEC Cash.proc_PayAccrual @PaymentCode;
        END
        ELSE
        BEGIN
            EXEC Cash.proc_PaymentPost;
        END;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        EXEC App.proc_ErrorLog;
    END CATCH
