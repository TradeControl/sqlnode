CREATE PROCEDURE App.proc_Template_ST_SOLE_CUR_STD_SA_2026
(
    @FinancialMonth      SMALLINT      = 4,
    @GovAccountName      NVARCHAR(255),
    @BankName            NVARCHAR(255) = NULL,
    @BankAddress         NVARCHAR(MAX) = NULL,
    @DummyAccount        NVARCHAR(50),
    @CurrentAccount      NVARCHAR(50)  = NULL,
    @CA_SortCode         NVARCHAR(10)  = NULL,
    @CA_AccountNumber    NVARCHAR(20)  = NULL,
    @ReserveAccount      NVARCHAR(50)  = NULL,
    @RA_SortCode         NVARCHAR(10)  = NULL,
    @RA_AccountNumber    NVARCHAR(20)  = NULL,
    @IsVATRegistered     BIT           = 0
)
AS
BEGIN TRY
DECLARE @RC int

    EXECUTE @RC = App.proc_Template_ST_SOLE_CUR_STD_2026
       @FinancialMonth = @FinancialMonth
      , @GovAccountName = @GovAccountName
      , @BankName = @BankName
      , @BankAddress = @BankAddress
      , @DummyAccount = @DummyAccount
      , @CurrentAccount = @CurrentAccount
      , @CA_SortCode = @CA_SortCode
      , @CA_AccountNumber = @CA_AccountNumber
      , @ReserveAccount = @ReserveAccount
      , @RA_SortCode = @RA_SortCode
      , @RA_AccountNumber = @RA_AccountNumber
      , @IsVATRegistered = @IsVATRegistered
      , @IsMTD = 0

    RETURN @RC;
END TRY
BEGIN CATCH
    EXEC App.proc_ErrorLog;
END CATCH
