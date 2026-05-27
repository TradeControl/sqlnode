CREATE PROCEDURE Cash.proc_PaymentPostById
    @UserId nvarchar(10)
AS
    SET NOCOUNT, XACT_ABORT ON;

    BEGIN TRY
        DECLARE @PaymentCode nvarchar(20);

        DECLARE curMisc CURSOR LOCAL FOR
            SELECT payment.PaymentCode
            FROM Cash.tbPayment AS payment
                INNER JOIN Cash.tbCode AS code
                    ON payment.CashCode = code.CashCode
                INNER JOIN Cash.tbCategory AS category
                    ON code.CategoryCode = category.CategoryCode
                INNER JOIN Subject.tbAccount AS account
                    ON account.AccountCode = payment.AccountCode
            WHERE account.AccountTypeCode < 2
              AND payment.PaymentStatusCode = 0
              AND payment.UserId = @UserId
            ORDER BY
                payment.SubjectCode,
                payment.ParentSubjectCode,
                payment.PaidOn,
                payment.PaymentCode;

        DECLARE curInv CURSOR LOCAL FOR
            SELECT payment.PaymentCode
            FROM Cash.tbPayment AS payment
            WHERE payment.PaymentStatusCode = 0
              AND payment.CashCode IS NULL
              AND payment.UserId = @UserId
            ORDER BY
                payment.SubjectCode,
                payment.ParentSubjectCode,
                payment.PaidOn,
                payment.PaymentCode;

        BEGIN TRANSACTION;

        OPEN curMisc;
        FETCH NEXT FROM curMisc INTO @PaymentCode;

        WHILE @@FETCH_STATUS = 0
        BEGIN
            EXEC Cash.proc_PaymentPostMisc @PaymentCode;
            FETCH NEXT FROM curMisc INTO @PaymentCode;
        END;

        CLOSE curMisc;
        DEALLOCATE curMisc;

        OPEN curInv;
        FETCH NEXT FROM curInv INTO @PaymentCode;

        WHILE @@FETCH_STATUS = 0
        BEGIN
            EXEC Cash.proc_PaymentPostInvoiced @PaymentCode;
            FETCH NEXT FROM curInv INTO @PaymentCode;
        END;

        CLOSE curInv;
        DEALLOCATE curInv;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        EXEC App.proc_ErrorLog;
    END CATCH
