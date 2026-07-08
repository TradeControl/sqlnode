CREATE PROCEDURE Invoice.proc_RaiseDefaults
(
    @SubjectCode nvarchar(50),
    @ParentSubjectCode nvarchar(50) = NULL,
    @EntryId nvarchar(20) = NULL,
    @CashCode nvarchar(50) = NULL
)
AS
BEGIN
    SET NOCOUNT, XACT_ABORT ON;

    BEGIN TRY
        DECLARE
            @TaxCode nvarchar(10),
            @InvoiceTypeCode smallint,
            @ResolvedCashCode nvarchar(50),
            @ItemReference nvarchar(max),
            @TotalValue decimal(18, 5),
            @InvoiceValue decimal(18, 5),
            @CashPolarityCode smallint;

        SET @ParentSubjectCode = NULLIF(LTRIM(RTRIM(@ParentSubjectCode)), N'');
        SET @EntryId = NULLIF(LTRIM(RTRIM(@EntryId)), N'');
        SET @CashCode = NULLIF(LTRIM(RTRIM(@CashCode)), N'');

        SELECT
            @TaxCode = subject.TaxCode,
            @CashPolarityCode = subject_type.CashPolarityCode
        FROM Subject.tbSubject subject
            INNER JOIN Subject.tbType subject_type
                ON subject.SubjectTypeCode = subject_type.SubjectTypeCode
        WHERE subject.SubjectCode = @SubjectCode;

        SELECT TOP (1)
            @InvoiceTypeCode = invoice_type.InvoiceTypeCode
        FROM Invoice.tbType invoice_type
        WHERE invoice_type.InvoiceTypeCode IN (0, 2)
          AND invoice_type.CashPolarityCode = @CashPolarityCode
        ORDER BY invoice_type.InvoiceTypeCode;

        SELECT TOP (1)
            @ResolvedCashCode = entry.CashCode,
            @TotalValue = entry.TotalValue,
            @InvoiceValue = entry.InvoiceValue,
            @ItemReference = entry.ItemReference
        FROM Invoice.tbEntry entry
        WHERE entry.SubjectCode = @SubjectCode
          AND (
                (entry.ParentSubjectCode IS NULL AND @ParentSubjectCode IS NULL)
                OR entry.ParentSubjectCode = @ParentSubjectCode
              )
          AND (@EntryId IS NULL OR entry.EntryId <> @EntryId)
          AND (@CashCode IS NULL OR entry.CashCode = @CashCode)
        ORDER BY entry.InvoicedOn DESC, entry.EntryId DESC;

        IF @ResolvedCashCode IS NULL
        BEGIN
            SELECT TOP (1)
                @ResolvedCashCode = item.CashCode,
                @TotalValue = item.TotalValue,
                @InvoiceValue = item.InvoiceValue,
                @ItemReference = item.ItemReference
            FROM Invoice.tbInvoice invoice
                INNER JOIN Invoice.tbItem item
                    ON invoice.InvoiceNumber = item.InvoiceNumber
            WHERE invoice.InvoiceTypeCode = @InvoiceTypeCode
              AND invoice.SubjectCode = @SubjectCode
              AND (
                    (invoice.ParentSubjectCode IS NULL AND @ParentSubjectCode IS NULL)
                    OR invoice.ParentSubjectCode = @ParentSubjectCode
                  )
              AND (@CashCode IS NULL OR item.CashCode = @CashCode)
            ORDER BY invoice.InvoicedOn DESC, invoice.InvoiceNumber DESC, item.CashCode DESC;
        END

        SELECT
            SubjectCode = @SubjectCode,
            ParentSubjectCode = @ParentSubjectCode,
            TaxCode = ISNULL(@TaxCode, N''),
            InvoiceTypeCode = ISNULL(@InvoiceTypeCode, 0),
            CashCode = ISNULL(COALESCE(@CashCode, @ResolvedCashCode), N''),
            TotalValue = ISNULL(@TotalValue, 0),
            InvoiceValue = ISNULL(@InvoiceValue, 0),
            ItemReference = ISNULL(@ItemReference, N'');
    END TRY
    BEGIN CATCH
        EXEC App.proc_ErrorLog;
    END CATCH
END
GO
