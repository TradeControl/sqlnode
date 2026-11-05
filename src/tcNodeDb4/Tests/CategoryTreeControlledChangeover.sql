/*
    Category Tree Step 5.5 controlled local changeover

    Target only:
        IAM-01 / tcNodeDb4-COSIPFVT1-COSTD26

    The source guard must remain 0. Set @Execute = 1 only in a reviewed execution
    copy after the backup named by @ExpectedBackupSetUuid has passed RESTORE
    VERIFYONLY. The complete business scenario is one outer transaction; any
    executable postcondition failure rolls it back.

    Evidence narrative:
        docs/projects/Category Tree/category-tree-controlled-changeover-test.md
*/

USE [tcNodeDb4-COSIPFVT1-COSTD26];

SET NOCOUNT ON;
SET XACT_ABORT ON;

DECLARE @Execute bit = 0;

DECLARE
    @ExpectedBackupSetUuid uniqueidentifier = 'C9CBCC6A-2142-48FE-BAEA-038815C645C2',
    @ExpectedPredecessorVersionId nvarchar(10) = N'CV00000002',
    @ExpectedActivePeriodStart date = '2026-11-01',
    @EffectiveFromOn date = CONVERT(date, SYSUTCDATETIME()),
    @IndirectCategoryCode nvarchar(10) = N'CA-INDCST',
    @IndirectCategory nvarchar(50) = N'Indirect Costs',
    @PlantCashCode nvarchar(50) = N'CC-PLANT',
    @PlantCashDescription nvarchar(100) = N'Plant and Machinery',
    @SupplierName nvarchar(100) = N'Jones Machine Tools Ltd',
    @TransferAmount decimal(18,5) = 50000.00000,
    @LatheCost decimal(18,5) = 40000.00000,
    @AnnualDepreciation decimal(18,5) = 10000.00000,
    @DepreciationCount int = 4;

IF CONVERT(nvarchar(128), SERVERPROPERTY('MachineName')) <> N'IAM-01'
    THROW 51980, 'Refusing to operate: the controlled changeover is local to IAM-01.', 1;

IF DB_NAME() <> N'tcNodeDb4-COSIPFVT1-COSTD26'
    THROW 51981, 'Refusing to operate: the controlled changeover target database is incorrect.', 1;

IF NOT EXISTS
(
    SELECT 1
    FROM msdb.dbo.backupset
    WHERE backup_set_uuid = @ExpectedBackupSetUuid
      AND database_name = DB_NAME()
      AND type = N'D'
      AND is_copy_only = 1
      AND has_backup_checksums = 1
)
    THROW 51982, 'The reviewed pre-change COPY_ONLY backup evidence was not found.', 1;

DECLARE
    @PredecessorVersionId nvarchar(10) = (SELECT CategoryVersionId FROM App.tbOptions),
    @PredecessorStatusCode smallint,
    @ActivePeriodStart date,
    @ActivePeriodEnd date,
    @ActiveYearNumber smallint,
    @ActiveMonthNumber smallint,
    @UserId nvarchar(10) = (SELECT TOP (1) UserId FROM Usr.vwCredentials),
    @HomeSubjectCode nvarchar(50) = (SELECT SubjectCode FROM App.vwHomeAccount),
    @SellerRootCode nvarchar(50) = N'Seller',
    @CurrentAccountCode nvarchar(10) = (SELECT AccountCode FROM Cash.vwCurrentAccount),
    @ReserveAccountCode nvarchar(10) = (SELECT AccountCode FROM Cash.vwReserveAccount),
    @PlantAccountCode nvarchar(10),
    @PlantAccountCashCode nvarchar(50),
    @PurchaseOn date = CONVERT(date, SYSUTCDATETIME()),
    @PeriodEndOn date;

SELECT @PredecessorStatusCode = VersionStatusCode
FROM Cash.tbCategoryVersion
WHERE VersionId = @PredecessorVersionId;

SELECT
    @ActivePeriodStart = CONVERT(date, StartOn),
    @ActivePeriodEnd = CONVERT(date, EndOn),
    @ActiveYearNumber = YearNumber,
    @ActiveMonthNumber = MonthNumber
FROM App.fnActivePeriod();

SET @PeriodEndOn = DATEADD(day, -1, @ActivePeriodEnd);

SELECT TOP (1)
    @PlantAccountCode = AccountCode,
    @PlantAccountCashCode = CashCode
FROM Subject.tbAccount
WHERE AccountTypeCode = 2
  AND AccountClosed = 0
  AND CashCode = N'CC-DEPPL'
ORDER BY AccountCode;

IF @PredecessorVersionId <> @ExpectedPredecessorVersionId OR @PredecessorStatusCode <> 1
    THROW 51983, 'The expected Published predecessor is not active.', 1;

IF @ActivePeriodStart <> @ExpectedActivePeriodStart
    THROW 51984, 'The expected November 2026 period is not active.', 1;

IF @PurchaseOn < @ActivePeriodStart OR @PurchaseOn >= @ActivePeriodEnd
    THROW 51985, 'The execution date is outside the active November period.', 1;

IF @EffectiveFromOn <=
   (SELECT EffectiveFromOn FROM Cash.tbCategoryVersion WHERE VersionId = @PredecessorVersionId)
    THROW 51986, 'The successor effective date must follow its predecessor.', 1;

IF @UserId IS NULL OR @HomeSubjectCode IS NULL
    THROW 51987, 'The application actor or home subject could not be resolved.', 1;

IF NOT EXISTS (SELECT 1 FROM Subject.tbSubject WHERE SubjectCode = @SellerRootCode)
    THROW 51988, 'The Seller namespace root could not be resolved.', 1;

IF @CurrentAccountCode IS NULL OR @ReserveAccountCode IS NULL
    THROW 51989, 'The Current or Reserve account could not be resolved.', 1;

IF @PlantAccountCode IS NULL OR @PlantAccountCashCode <> N'CC-DEPPL'
    THROW 51990, 'The open PLANT & TOOLS asset account could not be resolved.', 1;

IF EXISTS (SELECT 1 FROM Cash.tbCategory WHERE CategoryCode = @IndirectCategoryCode)
   OR EXISTS (SELECT 1 FROM Cash.tbCode WHERE CashCode = @PlantCashCode)
   OR EXISTS (SELECT 1 FROM Subject.tbSubject WHERE SubjectName = @SupplierName)
   OR EXISTS (SELECT 1 FROM Cash.tbPayment WHERE PaymentReference LIKE N'Lathe%')
   OR EXISTS
   (
       SELECT 1
       FROM Cash.tbPayment
       WHERE PaymentReference = N'DS TRANSFER'
         AND CONVERT(date, PaidOn) = @PurchaseOn
         AND
         (
             (AccountCode = @ReserveAccountCode AND PaidOutValue = @TransferAmount)
             OR (AccountCode = @CurrentAccountCode AND PaidInValue = @TransferAmount)
         )
   )
    THROW 51991, 'Controlled changeover business data already exists; restore the reviewed backup before replay.', 1;

SELECT
    N'PRECHECK' AS EvidenceStage,
    @@SERVERNAME AS ServerName,
    DB_NAME() AS DatabaseName,
    @ExpectedBackupSetUuid AS BackupSetUuid,
    @PredecessorVersionId AS ActiveVersionId,
    @ActivePeriodStart AS ActivePeriodStart,
    @PeriodEndOn AS ActivePeriodEnd,
    @CurrentAccountCode AS CurrentAccountCode,
    @ReserveAccountCode AS ReserveAccountCode,
    @PlantAccountCode AS PlantAccountCode,
    @Execute AS ExecuteGuard;

IF @Execute = 0
BEGIN
    PRINT N'Preflight passed. Source guard is 0; no business data was changed.';
    RETURN;
END;

DECLARE
    @SuccessorVersionId nvarchar(10),
    @CanonicalSha256 binary(32),
    @CanonicalByteLength bigint,
    @SupplierCode nvarchar(50),
    @EdgeDisplayOrder smallint,
    @PurchasePaymentCode nvarchar(20),
    @CapitalPaymentCode nvarchar(20),
    @WriteOffOn date,
    @DepreciationIndex int = 0;

BEGIN TRY
    BEGIN TRANSACTION;

    EXEC Cash.proc_CategoryVersionClone
        @Description = N'Standard Company Accounts 2026 - indirect plant costs',
        @Notes = N'Step 5.5 controlled changeover: Indirect Costs, plant purchase and historical horizon evidence.',
        @EffectiveFromOn = @EffectiveFromOn,
        @VersionId = @SuccessorVersionId OUTPUT;

    EXEC Cash.proc_CategorySave
        @VersionId = @SuccessorVersionId,
        @CategoryCode = @IndirectCategoryCode,
        @Category = @IndirectCategory,
        @CategoryTypeCode = 0,
        @CashPolarityCode = 0,
        @CashTypeCode = 0,
        @DisplayOrder = 145,
        @IsEnabled = 1,
        @ChangeNote = N'Add the Indirect Costs classification for the controlled changeover.';

    SELECT @EdgeDisplayOrder = CONVERT(smallint, COALESCE(MAX(DisplayOrder), 0) + 10)
    FROM Cash.tbCategoryTotal
    WHERE VersionId = @SuccessorVersionId
      AND ParentCode = N'CT-OVERHD';

    EXEC Cash.proc_CategoryTotalSave
        @VersionId = @SuccessorVersionId,
        @ParentCode = N'CT-OVERHD',
        @ChildCode = @IndirectCategoryCode,
        @DisplayOrder = @EdgeDisplayOrder,
        @IsDelete = 0,
        @ChangeNote = N'Include Indirect Costs within Overheads.';

    EXEC Cash.proc_CategoryVersionValidate
        @VersionId = @SuccessorVersionId,
        @CanonicalSha256 = @CanonicalSha256 OUTPUT,
        @CanonicalByteLength = @CanonicalByteLength OUTPUT;

    EXEC Cash.proc_CategoryVersionPublish
        @VersionId = @SuccessorVersionId,
        @ChangeNote = N'Publish the controlled indirect-plant-cost successor.';

    EXEC Cash.proc_CodeAdd
        @VersionId = @SuccessorVersionId,
        @CashCode = @PlantCashCode,
        @CashDescription = @PlantCashDescription,
        @CategoryCode = @IndirectCategoryCode,
        @TaxCode = N'T1',
        @IsEnabled = 1;

    EXEC Cash.proc_CategoryVersionValidate
        @VersionId = @SuccessorVersionId,
        @CanonicalSha256 = @CanonicalSha256 OUTPUT,
        @CanonicalByteLength = @CanonicalByteLength OUTPUT;

    EXEC Subject.proc_AddNamespace
        @RootSubjectCode = @SellerRootCode,
        @SubjectName = @SupplierName,
        @SubjectTypeCode = 0,
        @SubjectCode = @SupplierCode OUTPUT;

    UPDATE Subject.tbSubject
    SET SubjectStatusCode = 1,
        TaxCode = N'T1',
        ExportTypeCode = 0,
        PaymentTerms = N'30 days',
        ExpectedDays = 0,
        PaymentDays = 30,
        PayDaysFromMonthEnd = 0,
        PayBalance = 1
    WHERE SubjectCode = @SupplierCode;

    IF NOT EXISTS
    (
        SELECT 1
        FROM Subject.tbSubject AS subject
        JOIN Subject.tbAddress AS address ON address.AddressCode = subject.AddressCode
        WHERE subject.SubjectCode = @SupplierCode
    )
    BEGIN
        EXEC Subject.proc_AddAddress
            @SubjectCode = @SupplierCode,
            @Address = N'Jones Machine Tools Ltd, controlled changeover test address';
    END;

    EXEC App.proc_DatasetSyntheticMIS_Transfer
        @PaidOn = @PurchaseOn,
        @Amount = @TransferAmount,
        @FromAccountCode = @ReserveAccountCode,
        @ToAccountCode = @CurrentAccountCode;

    EXEC Cash.proc_NextPaymentCode @PaymentCode = @PurchasePaymentCode OUTPUT;

    INSERT INTO Cash.tbPayment
    (
        PaymentCode, UserId, PaymentStatusCode, SubjectCode, AccountCode,
        CashCode, TaxCode, PaidOn, PaidInValue, PaidOutValue, PaymentReference
    )
    VALUES
    (
        @PurchasePaymentCode, @UserId, 0, @SupplierCode, @CurrentAccountCode,
        @PlantCashCode, N'T1', @PurchaseOn, 0, @LatheCost, N'Lathe purchase'
    );

    EXEC Cash.proc_PaymentPost;

    EXEC Cash.proc_NextPaymentCode @PaymentCode = @CapitalPaymentCode OUTPUT;

    INSERT INTO Cash.tbPayment
    (
        PaymentCode, UserId, PaymentStatusCode, SubjectCode, AccountCode,
        CashCode, TaxCode, PaidOn, PaidInValue, PaidOutValue, PaymentReference
    )
    VALUES
    (
        @CapitalPaymentCode, @UserId, 1, @HomeSubjectCode, @PlantAccountCode,
        @PlantAccountCashCode, N'N/A', @PurchaseOn, @LatheCost, 0, N'Lathe (Capitalised)'
    );

    SELECT @WriteOffOn = CONVERT(date, EOMONTH(MAX(CONVERT(date, StartOn))))
    FROM App.tbYearPeriod
    WHERE YearNumber = @ActiveYearNumber;

    WHILE @DepreciationIndex < @DepreciationCount
    BEGIN
        DECLARE
            @DepreciationPaymentCode nvarchar(20),
            @DepreciationStatusCode smallint =
            (
                SELECT TOP (1) CASE WHEN CashStatusCode = 2 THEN 1 ELSE 0 END
                FROM App.tbYearPeriod
                WHERE CONVERT(date, StartOn) <= @WriteOffOn
                ORDER BY StartOn DESC
            );

        EXEC Cash.proc_NextPaymentCode @PaymentCode = @DepreciationPaymentCode OUTPUT;

        INSERT INTO Cash.tbPayment
        (
            PaymentCode, UserId, PaymentStatusCode, SubjectCode, AccountCode,
            CashCode, TaxCode, PaidOn, PaidInValue, PaidOutValue, PaymentReference
        )
        VALUES
        (
            @DepreciationPaymentCode, @UserId, COALESCE(@DepreciationStatusCode, 0),
            @HomeSubjectCode, @PlantAccountCode, @PlantAccountCashCode, N'N/A',
            @WriteOffOn, 0, @AnnualDepreciation, N'Depreciation - Lathe'
        );

        SET @WriteOffOn = DATEADD(year, 1, @WriteOffOn);
        SET @DepreciationIndex += 1;
    END;

    EXEC App.proc_PeriodClose;

    IF (SELECT CategoryVersionId FROM App.tbOptions) <> @SuccessorVersionId
        THROW 51992, 'The successor is not the active Category Tree version.', 1;

    IF NOT EXISTS
    (
        SELECT 1
        FROM Cash.tbCategoryVersion
        WHERE VersionId = @PredecessorVersionId
          AND VersionStatusCode = 3
          AND EffectiveToOn = DATEADD(day, -1, @EffectiveFromOn)
    )
        THROW 51993, 'The predecessor was not archived with the expected inclusive end date.', 1;

    IF NOT EXISTS
    (
        SELECT 1
        FROM Cash.tbCategoryVersion
        WHERE VersionId = @SuccessorVersionId
          AND VersionStatusCode = 1
          AND EffectiveFromOn = @EffectiveFromOn
          AND EffectiveToOn IS NULL
          AND CanonicalSha256 IS NOT NULL
    )
        THROW 51994, 'The successor is not a validated open-ended Published version.', 1;

    IF NOT EXISTS
    (
        SELECT 1
        FROM Cash.tbCategoryCodeMap
        WHERE VersionId = @SuccessorVersionId
          AND CashCode = @PlantCashCode
          AND CategoryCode = @IndirectCategoryCode
    )
        THROW 51995, 'The successor does not classify the new Plant and Machinery Cash Code.', 1;

    IF NOT EXISTS
    (
        SELECT 1
        FROM Cash.tbCategory
        WHERE VersionId = @SuccessorVersionId
          AND CategoryCode = @IndirectCategoryCode
          AND CategoryTypeCode = 0
          AND CashPolarityCode = 0
          AND CashTypeCode = 0
    )
        THROW 52001, 'The successor does not contain the expected nominal Indirect Costs category.', 1;

    IF NOT EXISTS
    (
        SELECT 1
        FROM Cash.tbCategoryTotal
        WHERE VersionId = @SuccessorVersionId
          AND ParentCode = N'CT-OVERHD'
          AND ChildCode = @IndirectCategoryCode
    )
        THROW 52002, 'Indirect Costs is not linked beneath Overheads in the successor.', 1;

    IF EXISTS
    (
        SELECT 1
        FROM Cash.tbCategoryCodeMap
        WHERE VersionId = @PredecessorVersionId
          AND CashCode = @PlantCashCode
    )
        THROW 51996, 'The predecessor unexpectedly classifies the later Plant and Machinery Cash Code.', 1;

    IF NOT EXISTS
    (
        SELECT 1
        FROM Cash.fnCategoryVersionUnmappedCashCodes(
            @PredecessorVersionId, @ActiveYearNumber, @ActiveYearNumber, 0)
        WHERE CashCode = @PlantCashCode
    )
        THROW 51997, 'The predecessor did not expose the expected historical-horizon coverage failure.', 1;

    IF EXISTS
    (
        SELECT 1
        FROM Cash.fnCategoryVersionUnmappedCashCodes(
            @SuccessorVersionId, @ActiveYearNumber, @ActiveYearNumber, 0)
        WHERE CashCode = @PlantCashCode
    )
        THROW 51998, 'The successor unexpectedly reports its Plant and Machinery Cash Code as unmapped.', 1;

    IF (SELECT CashStatusCode FROM App.tbYearPeriod
        WHERE YearNumber = @ActiveYearNumber AND MonthNumber = @ActiveMonthNumber) <> 2
        THROW 51999, 'The November period did not close.', 1;

    IF (SELECT COUNT(*) FROM Cash.tbPayment
        WHERE AccountCode = @PlantAccountCode AND PaymentReference = N'Depreciation - Lathe') <> 4
        THROW 52000, 'The four-year lathe depreciation schedule is incomplete.', 1;

    IF NOT EXISTS
    (
        SELECT 1
        FROM Subject.tbSubject AS subject
        JOIN Subject.tbAddress AS address ON address.AddressCode = subject.AddressCode
        WHERE subject.SubjectCode = @SupplierCode
          AND subject.SubjectName = @SupplierName
    )
        THROW 52003, 'The Jones Machine Tools supplier or its address is incomplete.', 1;

    IF NOT EXISTS
    (
        SELECT 1
        FROM Cash.tbPayment
        WHERE PaymentReference = N'DS TRANSFER'
          AND CONVERT(date, PaidOn) = @PurchaseOn
          AND AccountCode = @ReserveAccountCode
          AND CashCode = N'CC-TRNPY'
          AND PaidOutValue = @TransferAmount
    )
       OR NOT EXISTS
    (
        SELECT 1
        FROM Cash.tbPayment
        WHERE PaymentReference = N'DS TRANSFER'
          AND CONVERT(date, PaidOn) = @PurchaseOn
          AND AccountCode = @CurrentAccountCode
          AND CashCode = N'CC-TRNRC'
          AND PaidInValue = @TransferAmount
    )
        THROW 52004, 'The two-sided Reserve-to-Current transfer is incomplete.', 1;

    IF NOT EXISTS
    (
        SELECT 1
        FROM Cash.tbPayment
        WHERE PaymentCode = @PurchasePaymentCode
          AND SubjectCode = @SupplierCode
          AND AccountCode = @CurrentAccountCode
          AND CashCode = @PlantCashCode
          AND PaidOutValue = @LatheCost
          AND PaymentReference = N'Lathe purchase'
    )
        THROW 52005, 'The supplier payment for the lathe is incomplete.', 1;

    IF NOT EXISTS
    (
        SELECT 1
        FROM Cash.tbPayment
        WHERE PaymentCode = @CapitalPaymentCode
          AND SubjectCode = @HomeSubjectCode
          AND AccountCode = @PlantAccountCode
          AND CashCode = @PlantAccountCashCode
          AND PaidInValue = @LatheCost
          AND PaymentReference = N'Lathe (Capitalised)'
    )
        THROW 52006, 'The lathe capitalisation entry is incomplete.', 1;

    IF (SELECT COALESCE(SUM(PaidOutValue), 0)
        FROM Cash.tbPayment
        WHERE AccountCode = @PlantAccountCode
          AND PaymentReference = N'Depreciation - Lathe') <> @LatheCost
        THROW 52007, 'The lathe depreciation entries do not write off the full capitalised cost.', 1;

    COMMIT TRANSACTION;

    SELECT
        N'CHANGEOVER' AS EvidenceStage,
        @PredecessorVersionId AS PredecessorVersionId,
        @SuccessorVersionId AS SuccessorVersionId,
        @EffectiveFromOn AS SuccessorEffectiveFromOn,
        DATEADD(day, -1, @EffectiveFromOn) AS PredecessorEffectiveToOn,
        CONVERT(varchar(64), @CanonicalSha256, 2) AS SuccessorCanonicalSha256,
        @CanonicalByteLength AS SuccessorCanonicalByteLength;

    SELECT
        N'BUSINESS_EVENT' AS EvidenceStage,
        @IndirectCategoryCode AS CategoryCode,
        @PlantCashCode AS CashCode,
        @SupplierCode AS SupplierCode,
        @CurrentAccountCode AS CurrentAccountCode,
        @ReserveAccountCode AS ReserveAccountCode,
        @PlantAccountCode AS PlantAccountCode,
        @PurchaseOn AS PurchaseOn,
        @TransferAmount AS TransferAmount,
        @LatheCost AS LatheCost,
        @AnnualDepreciation AS AnnualDepreciation,
        @DepreciationCount AS DepreciationCount,
        @PeriodEndOn AS ClosedPeriodEnd;

    SELECT
        N'HISTORICAL_HORIZON' AS EvidenceStage,
        @PredecessorVersionId AS SelectedVersionId,
        CashCode,
        CashDescription
    FROM Cash.fnCategoryVersionUnmappedCashCodes(
        @PredecessorVersionId, @ActiveYearNumber, @ActiveYearNumber, 0)
    WHERE CashCode = @PlantCashCode;
END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;
    THROW;
END CATCH;
