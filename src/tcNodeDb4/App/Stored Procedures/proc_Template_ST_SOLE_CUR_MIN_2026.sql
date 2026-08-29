CREATE PROCEDURE App.proc_Template_ST_SOLE_CUR_MIN_2026
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
    @IsVATRegistered     BIT           = 0     -- Sole traders default to non‑VAT
)
AS
    SET NOCOUNT, XACT_ABORT ON;
BEGIN TRY

    BEGIN TRAN SoleTraderTemplate;

    ----------------------------------------------------------------
    -- 1. Base template: Minimal Micro Business (current schema)
    ----------------------------------------------------------------
    EXEC App.proc_Template_BASE_MIN_2026
        @FinancialMonth   = @FinancialMonth,
        @GovAccountName   = @GovAccountName,
        @BankName         = @BankName,
        @BankAddress      = @BankAddress,
        @DummyAccount     = @DummyAccount,
        @CurrentAccount   = @CurrentAccount,
        @CA_SortCode      = @CA_SortCode,
        @CA_AccountNumber = @CA_AccountNumber,
        @ReserveAccount   = @ReserveAccount,
        @RA_SortCode      = @RA_SortCode,
        @RA_AccountNumber = @RA_AccountNumber;

    ----------------------------------------------------------------
    -- 2. Disable company-only categories/codes (do NOT delete)
    ----------------------------------------------------------------
    UPDATE Cash.tbCategory
    SET IsEnabled = 0
    WHERE CategoryCode IN ('CA-DIVID');

    UPDATE Cash.tbCode
    SET IsEnabled = 0
    WHERE CashCode IN ('CC-DEPRC', 'CC-DEPRJ', 'CC-SHCAP', 'CC-DIVID');

    UPDATE Cash.tbCode
    SET IsEnabled = 1
    WHERE CashCode = 'CC-EMPNI';

    ----------------------------------------------------------------
    -- 3. Cumulative reportable-expense accounting roll-up
    ----------------------------------------------------------------
    IF NOT EXISTS (SELECT 1 FROM Cash.tbCategory WHERE CategoryCode = 'CT-CUMEXP')
        INSERT INTO Cash.tbCategory
            (CategoryCode, Category, CategoryTypeCode, CashPolarityCode, CashTypeCode, DisplayOrder, IsEnabled)
        VALUES
            ('CT-CUMEXP', 'Cumulative Reportable Expenses', 1, 2, 0, 55, 1);

    INSERT INTO Cash.tbCategoryTotal (ParentCode, ChildCode)
    SELECT 'CT-CUMEXP', v.ChildCode
    FROM (VALUES ('CT-CSTSAL'), ('CT-STAFFC'), ('CT-OVERHD')) v(ChildCode)
    WHERE NOT EXISTS
    (
        SELECT 1 FROM Cash.tbCategoryTotal ct
        WHERE ct.ParentCode = 'CT-CUMEXP' AND ct.ChildCode = v.ChildCode
    );

    UPDATE Subject.tbAccount
    SET AccountClosed = 1
    WHERE AccountCode IN ('CALUP');

    UPDATE App.tbYearPeriod
    SET BusinessTaxRate = 0;

    ----------------------------------------------------------------
    -- 4. Business Tax settings for Sole Traders
    ----------------------------------------------------------------
    UPDATE Cash.tbTaxType
    SET IsEnabled = 0
    WHERE TaxTypeCode = 0;

    UPDATE Cash.tbTaxType
    SET IsEnabled = 1
    WHERE TaxTypeCode IN (4, 5);

    ----------------------------------------------------------------
    -- 5. Sole trader owner movements (single CASH CODE, polarity driven)
    ----------------------------------------------------------------

    -- Ensure the MONEY nominal category exists to hold the owner cash code.
    IF NOT EXISTS (SELECT 1 FROM Cash.tbCategory WHERE CategoryCode = 'CA-OWNER')
    BEGIN
        INSERT INTO Cash.tbCategory
            (CategoryCode, Category, CategoryTypeCode, CashPolarityCode, CashTypeCode, DisplayOrder, IsEnabled)
        VALUES
            ('CA-OWNER', 'Owner Capital Account', 0, 2, 2, 895, 1);
    END;

    -- Single owner capital asset cash code (polarity indicates introduced vs drawings).
    IF EXISTS (SELECT 1 FROM Cash.tbCode WHERE CashCode = 'CC-OWNCAP')
    BEGIN
        UPDATE Cash.tbCode
        SET CategoryCode = 'CA-OWNER',
            TaxCode = 'N/A',
            IsEnabled = 1
        WHERE CashCode = 'CC-OWNCAP';
    END
    ELSE
    BEGIN
        INSERT INTO Cash.tbCode
            (CashCode, CashDescription, CategoryCode, TaxCode, IsEnabled)
        VALUES
            ('CC-OWNCAP', 'Owner Capital', 'CA-OWNER', 'N/A', 1);
    END;

    ----------------------------------------------------------------
    -- 6. Dedicated cash account (ASSET-type) for owner capital balance
    ----------------------------------------------------------------
    DECLARE
        @SubjectCode    NVARCHAR(50) = (SELECT SubjectCode FROM App.tbOptions),
        @OwnerAccount   NVARCHAR(50) = N'OWNER CAPITAL ACCOUNT',
        @OwnerAccountCode NVARCHAR(10);

    EXEC Subject.proc_DefaultAccountCode
         @AccountName = @OwnerAccount,
         @AccountCode = @OwnerAccountCode OUTPUT;

    IF NOT EXISTS (SELECT 1 FROM Subject.tbAccount WHERE AccountCode = @OwnerAccountCode)
    BEGIN
        INSERT INTO Subject.tbAccount
            (AccountCode, SubjectCode, AccountName, AccountTypeCode, BalanceConstraintCode, LiquidityLevel, CashCode, AccountClosed)
        VALUES
            (@OwnerAccountCode, @SubjectCode, @OwnerAccount, 2, 2, 45, 'CC-OWNCAP', 0);
    END
    ELSE
    BEGIN
        UPDATE Subject.tbAccount
        SET CashCode = 'CC-OWNCAP'
        WHERE AccountCode = @OwnerAccountCode;
    END;

    ----------------------------------------------------------------
    -- 7. VAT handling for non-registered businesses
    ----------------------------------------------------------------
    IF @IsVATRegistered = 0
        EXEC App.proc_Template_DisableVAT;

    ----------------------------------------------------------------
    -- 8. Tax year alignment: financial year starts on April 6
    ----------------------------------------------------------------
    WITH year_start AS
    (
        SELECT YearNumber, MIN(StartOn) StartOn
        FROM App.tbYearPeriod
        GROUP BY YearNumber
    )
    UPDATE yp
    SET StartOn = DATEADD(DAY, 5, yp.StartOn)
    FROM year_start ys
        JOIN App.tbYearPeriod yp
            ON ys.YearNumber = yp.YearNumber
           AND ys.StartOn = yp.StartOn
           AND DATEPART(DAY, yp.StartOn) = 1;


    COMMIT TRAN SoleTraderTemplate;

END TRY
BEGIN CATCH
    EXEC App.proc_ErrorLog;
END CATCH;
GO
