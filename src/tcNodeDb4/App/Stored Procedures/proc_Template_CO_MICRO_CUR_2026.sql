CREATE PROCEDURE App.proc_Template_CO_MICRO_CUR_2026
(
    @FinancialMonth SMALLINT = 4,
    @GovAccountName NVARCHAR(255),
    @BankName NVARCHAR(255) = NULL,
    @BankAddress NVARCHAR(MAX) = NULL,
    @DummyAccount NVARCHAR(50),
    @CurrentAccount NVARCHAR(50) = NULL,
    @CA_SortCode NVARCHAR(10) = NULL,
    @CA_AccountNumber NVARCHAR(20) = NULL,
    @ReserveAccount NVARCHAR(50) = NULL,
    @RA_SortCode NVARCHAR(10) = NULL,
    @RA_AccountNumber NVARCHAR(20) = NULL
)
AS
    SET NOCOUNT, XACT_ABORT ON;

    BEGIN TRY

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
        -- 2. Registered office default
        -- Initial business setup supplies one operational address. A company
        -- starts with the same value in a distinct Registered address row so
        -- either address can subsequently change without changing its role.
        ----------------------------------------------------------------
        DECLARE
            @SubjectCode NVARCHAR(50) = (SELECT SubjectCode FROM App.tbOptions),
            @DefaultAddress NVARCHAR(MAX);

        SELECT @DefaultAddress = address.Address
        FROM Subject.tbSubject subject
        JOIN Subject.tbAddress address ON address.AddressCode = subject.AddressCode
        WHERE subject.SubjectCode = @SubjectCode;

        IF @DefaultAddress IS NOT NULL
           AND NOT EXISTS
           (
               SELECT 1
               FROM Subject.tbAddress
               WHERE SubjectCode = @SubjectCode AND AddressTypeCode = 2
           )
            EXEC Subject.proc_AddAddress
                @SubjectCode = @SubjectCode,
                @Address = @DefaultAddress,
                @AddressTypeCode = 2;

        ----------------------------------------------------------------
        -- 3. COMPANY ACCOUNTING CLASSIFICATION
        -- Statutory sources are composed by proc_Template_CO_MICRO_CUR_TAX_2026
        -- after the MIN/STD accounting profile has completed its refinements.
        ----------------------------------------------------------------
        INSERT INTO Cash.tbCategory
            (CategoryCode, Category, CategoryTypeCode, CashPolarityCode, CashTypeCode, DisplayOrder, IsEnabled)
        VALUES
            ('CA-DEPREC', 'Depreciation expense', 0, 0, 0, 145, 1);

        INSERT INTO Cash.tbCategoryTotal (ParentCode, ChildCode)
        VALUES ('CT-OVERHD', 'CA-DEPREC');

        UPDATE Cash.tbCode
        SET CategoryCode = 'CA-DEPREC'
        WHERE CashCode = 'CC-DEPRC';

        ----------------------------------------------------------------
        -- 4. Business Tax settings for Corporations
        ----------------------------------------------------------------
        UPDATE Cash.tbTaxType
        SET IsEnabled = 1
        WHERE TaxTypeCode = 0;

        UPDATE Cash.tbTaxType
        SET IsEnabled = 0
        WHERE TaxTypeCode IN (4, 5);

    END TRY
    BEGIN CATCH
        EXEC App.proc_ErrorLog;
    END CATCH;
