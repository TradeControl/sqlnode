CREATE PROCEDURE App.proc_Template_ST_SOLE_CUR_STD_2026
(
    @FinancialMonth SMALLINT = 4, @GovAccountName NVARCHAR(255),
    @BankName NVARCHAR(255) = NULL, @BankAddress NVARCHAR(MAX) = NULL,
    @DummyAccount NVARCHAR(50), @CurrentAccount NVARCHAR(50) = NULL,
    @CA_SortCode NVARCHAR(10) = NULL, @CA_AccountNumber NVARCHAR(20) = NULL,
    @ReserveAccount NVARCHAR(50) = NULL, @RA_SortCode NVARCHAR(10) = NULL,
    @RA_AccountNumber NVARCHAR(20) = NULL, @IsVATRegistered BIT = 0
)
AS
SET NOCOUNT, XACT_ABORT ON;
BEGIN TRY
    BEGIN TRAN SoleTraderStdTemplate;

    EXEC App.proc_Template_ST_SOLE_CUR_MIN_2026
        @FinancialMonth = @FinancialMonth, @GovAccountName = @GovAccountName,
        @BankName = @BankName, @BankAddress = @BankAddress, @DummyAccount = @DummyAccount,
        @CurrentAccount = @CurrentAccount, @CA_SortCode = @CA_SortCode,
        @CA_AccountNumber = @CA_AccountNumber, @ReserveAccount = @ReserveAccount,
        @RA_SortCode = @RA_SortCode, @RA_AccountNumber = @RA_AccountNumber,
        @IsVATRegistered = @IsVATRegistered;

    ;WITH Categories AS
    (
        SELECT * FROM (VALUES
            ('CA-COGS', 'Cost of Goods', 120), ('CA-SUBCON', 'Subcontractor Payments', 121),
            ('CA-TRAVEL', 'Travel and Subsistence', 149), ('CA-MOTOR', 'Motor Expenses', 150),
            ('CA-PREMS', 'Premises Running Costs', 151), ('CA-REPAIR', 'Repairs and Maintenance', 152),
            ('CA-OFFICE', 'Phone, Stationery and Office Costs', 153), ('CA-ADVERT', 'Advertising', 154),
            ('CA-ENTERT', 'Business Entertainment', 155), ('CA-LOANINT', 'Bank and Loan Interest', 156),
            ('CA-FINANCE', 'Other Financial Charges', 157),
            ('CA-PROF', 'Accountancy, Legal and Professional', 158),
            ('CA-OTHER', 'Other Business Expenses', 159)
        ) v(CategoryCode, Category, DisplayOrder)
    )
    INSERT INTO Cash.tbCategory
        (CategoryCode, Category, CategoryTypeCode, CashPolarityCode, CashTypeCode, DisplayOrder, IsEnabled)
    SELECT CategoryCode, Category, 0, 0, 0, DisplayOrder, 1
    FROM Categories c
    WHERE NOT EXISTS (SELECT 1 FROM Cash.tbCategory x WHERE x.CategoryCode = c.CategoryCode);

    INSERT INTO Cash.tbCategoryTotal (ParentCode, ChildCode)
    SELECT v.ParentCode, v.ChildCode
    FROM (VALUES
        ('CT-CSTSAL', 'CA-COGS'), ('CT-CSTSAL', 'CA-SUBCON'),
        ('CT-OVERHD', 'CA-TRAVEL'), ('CT-OVERHD', 'CA-MOTOR'), ('CT-OVERHD', 'CA-PREMS'),
        ('CT-OVERHD', 'CA-REPAIR'), ('CT-OVERHD', 'CA-OFFICE'), ('CT-OVERHD', 'CA-ADVERT'),
        ('CT-OVERHD', 'CA-ENTERT'), ('CT-OVERHD', 'CA-LOANINT'),
        ('CT-OVERHD', 'CA-FINANCE'), ('CT-OVERHD', 'CA-PROF'), ('CT-OVERHD', 'CA-OTHER')
    ) v(ParentCode, ChildCode)
    WHERE NOT EXISTS
    (
        SELECT 1 FROM Cash.tbCategoryTotal ct
        WHERE ct.ParentCode = v.ParentCode AND ct.ChildCode = v.ChildCode
    );

    ;WITH Codes AS
    (
        SELECT * FROM (VALUES
            ('CC-COGS', 'Goods and Materials', 'CA-COGS', 'T1'),
            ('CC-SUBCON', 'Subcontractor Payments', 'CA-SUBCON', 'T1'),
            ('CC-PARK', 'Parking and Tolls', 'CA-TRAVEL', 'T1'),
            ('CC-PUBTR', 'Public Transport', 'CA-TRAVEL', 'T1'),
            ('CC-HOTEL', 'Accommodation', 'CA-TRAVEL', 'T1'),
            ('CC-MEALS', 'Subsistence and Meals', 'CA-TRAVEL', 'N/A'),
            ('CC-MFUEL', 'Motor Fuel', 'CA-MOTOR', 'T1'),
            ('CC-MREPA', 'Motor Repairs and Servicing', 'CA-MOTOR', 'T1'),
            ('CC-MINSR', 'Motor Insurance', 'CA-MOTOR', 'N/A'),
            ('CC-MLICN', 'Road Tax and Licences', 'CA-MOTOR', 'N/A'),
            ('CC-MLEASE', 'Vehicle Lease and Hire', 'CA-MOTOR', 'T1'),
            ('CC-RENT', 'Rent', 'CA-PREMS', 'N/A'), ('CC-UTILS', 'Utilities', 'CA-PREMS', 'T1'),
            ('CC-CLEAN', 'Cleaning', 'CA-PREMS', 'T1'), ('CC-PREMS', 'Premises Costs', 'CA-PREMS', 'T1'),
            ('CC-INSUR', 'Insurance', 'CA-PREMS', 'N/A'),
            ('CC-REPA', 'Repairs and Maintenance', 'CA-REPAIR', 'T1'),
            ('CC-PHONE', 'Phone and Internet', 'CA-OFFICE', 'T1'),
            ('CC-OFFICE', 'Stationery and Office Costs', 'CA-OFFICE', 'T1'),
            ('CC-ADVT', 'Advertising and Marketing', 'CA-ADVERT', 'T1'),
            ('CC-ENTERT', 'Business Entertainment', 'CA-ENTERT', 'N/A'),
            ('CC-LOINT', 'Loan Interest', 'CA-LOANINT', 'INT'),
            ('CC-FINCH', 'Financial Charges', 'CA-FINANCE', 'N/A'),
            ('CC-BANKC', 'Bank Charges', 'CA-FINANCE', 'N/A'),
            ('CC-PROF', 'Professional Fees', 'CA-PROF', 'T1'),
            ('CC-OTHER', 'Other Business Expenses', 'CA-OTHER', 'T1')
        ) v(CashCode, CashDescription, CategoryCode, TaxCode)
    )
    INSERT INTO Cash.tbCode (CashCode, CashDescription, CategoryCode, TaxCode, IsEnabled)
    SELECT CashCode, CashDescription, CategoryCode, TaxCode, 1
    FROM Codes c
    WHERE NOT EXISTS (SELECT 1 FROM Cash.tbCode x WHERE x.CashCode = c.CashCode);

    UPDATE cc
    SET CategoryCode = c.CategoryCode, IsEnabled = 1
    FROM Cash.tbCode cc
    JOIN (VALUES
        ('CC-INSUR', 'CA-PREMS'), ('CC-REPA', 'CA-REPAIR'), ('CC-PHONE', 'CA-OFFICE'),
        ('CC-ADVT', 'CA-ADVERT'), ('CC-LOINT', 'CA-LOANINT'),
        ('CC-BANKC', 'CA-FINANCE'), ('CC-PROF', 'CA-PROF')
    ) c(CashCode, CategoryCode) ON c.CashCode = cc.CashCode;

    UPDATE Cash.tbCode SET IsEnabled = 0 WHERE CashCode IN ('CC-DIRCT', 'CC-ADMIN');

    COMMIT TRAN SoleTraderStdTemplate;
END TRY
BEGIN CATCH
    EXEC App.proc_ErrorLog;
END CATCH;
GO
