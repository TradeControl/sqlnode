CREATE FUNCTION Subject.fnInvoiceDag
(
    @SubjectCode nvarchar(50),
    @ParentSubjectCode nvarchar(50) = NULL
)
RETURNS TABLE
AS
RETURN
(
    WITH closure AS
    (
        SELECT
            SubjectCode,
            ParentSubjectCode,
            Depth
        FROM Subject.fnNamespaceClosure(@SubjectCode, @ParentSubjectCode)
    )
    SELECT
        invoice.InvoiceNumber,
        type.InvoiceType,
        invoice.InvoicedOn,
        invoice.InvoiceValue,
        invoice.TaxValue,
        invoice.PaidValue + invoice.PaidTaxValue AS TotalPaidValue,
        status.InvoiceStatus
    FROM Invoice.tbInvoice AS invoice
        JOIN closure AS c
            ON c.SubjectCode = invoice.SubjectCode
           AND ISNULL(c.ParentSubjectCode, N'') = ISNULL(invoice.ParentSubjectCode, N'')
        JOIN Invoice.tbType AS type
            ON invoice.InvoiceTypeCode = type.InvoiceTypeCode
        JOIN Invoice.tbStatus AS status
            ON invoice.InvoiceStatusCode = status.InvoiceStatusCode
);
GO
