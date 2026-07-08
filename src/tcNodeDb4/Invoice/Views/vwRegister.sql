CREATE VIEW Invoice.vwRegister
AS
WITH register AS (
    SELECT
        -- Period start
        (
            SELECT TOP (1) p.StartOn
            FROM App.tbYearPeriod p
            WHERE p.StartOn <= i.InvoicedOn
            ORDER BY p.StartOn DESC
        ) AS StartOn,

        -- Keys
        i.InvoiceNumber,
        i.SubjectCode,
        i.ParentSubjectCode,
        i.InvoiceTypeCode,
        i.InvoiceStatusCode,

        -- Dates
        i.InvoicedOn,
        i.DueOn,
        i.ExpectedOn,

        -- Polarity-adjusted values
        CASE WHEN t.CashPolarityCode = 0 THEN i.InvoiceValue * -1 ELSE i.InvoiceValue END AS InvoiceValue,
        CASE WHEN t.CashPolarityCode = 0 THEN i.TaxValue     * -1 ELSE i.TaxValue     END AS TaxValue,
        CASE WHEN t.CashPolarityCode = 0 THEN i.PaidValue    * -1 ELSE i.PaidValue    END AS PaidValue,
        CASE WHEN t.CashPolarityCode = 0 THEN i.PaidTaxValue * -1 ELSE i.PaidTaxValue END AS PaidTaxValue,

        -- Metadata
        i.PaymentTerms,
        i.Notes,
        i.Printed,
        s.SubjectName,
        u.UserName,
        i.UserId,
        st.InvoiceStatus,
        t.CashPolarityCode,
        t.InvoiceType
    FROM Invoice.tbInvoice i
    JOIN Subject.tbSubject s ON i.SubjectCode = s.SubjectCode
    JOIN Invoice.tbType t ON i.InvoiceTypeCode = t.InvoiceTypeCode
    JOIN Invoice.tbStatus st ON i.InvoiceStatusCode = st.InvoiceStatusCode
    JOIN Usr.tbUser u ON i.UserId = u.UserId
)
SELECT
    COALESCE(StartOn, CAST(GETDATE() AS date)) AS StartOn,
    InvoiceNumber,
    SubjectCode,
    ParentSubjectCode,
    InvoiceTypeCode,
    InvoiceStatusCode,
    InvoicedOn,
    DueOn,
    ExpectedOn,

    CAST(InvoiceValue AS float) AS InvoiceValue,
    CAST(TaxValue AS float) AS TaxValue,
    CAST(InvoiceValue + TaxValue AS float) AS TotalInvoiceValue,

    CAST(PaidValue AS float) AS PaidValue,
    CAST(PaidTaxValue AS float) AS PaidTaxValue,
    CAST(PaidValue + PaidTaxValue AS float) AS TotalPaidValue,

    PaymentTerms,
    Notes,
    Printed,
    SubjectName,
    UserName,
    UserId,
    InvoiceStatus,
    CashPolarityCode,
    InvoiceType
FROM register;
