CREATE PROCEDURE App.proc_Template_ST_SOLE_CUR_MIN_MTD_2026
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
SET NOCOUNT, XACT_ABORT ON;
BEGIN TRY
DECLARE @RC int

    BEGIN TRAN SoleTraderMinMtdTemplate;

    EXECUTE @RC = App.proc_Template_ST_SOLE_CUR_MIN_2026
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

    EXEC App.proc_Template_ST_SOLE_CUR_TAX_MTD_2026;

    DELETE FROM Cash.tbTaxTagMap WHERE TaxSourceCode = 'UK-ITSA-SE-CUM';

    INSERT INTO Cash.tbTaxTagMap
        (TaxSourceCode, TagCode, MapTypeCode, CategoryCode, CashCode, IsEnabled)
    VALUES
        ('UK-ITSA-SE-CUM', 'turnover', 0, 'CT-TURNOV', '', 1),
        ('UK-ITSA-SE-CUM', 'otherBusinessIncome', 0, 'CT-OTHRIN', '', 1),
        ('UK-ITSA-SE-CUM', 'consolidatedExpenses', 0, 'CT-CUMEXP', '', 1);

    EXEC Cash.proc_TaxTagMapValidate @TaxSourceCode = 'UK-ITSA-SE-CUM';

    COMMIT TRAN SoleTraderMinMtdTemplate;

    RETURN @RC;
END TRY
BEGIN CATCH
    EXEC App.proc_ErrorLog;
END CATCH
