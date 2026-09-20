CREATE TABLE [Cash].[tbTaxTagSource]
(
    TaxSourceCode      NVARCHAR(20)  NOT NULL,
    SourceName         NVARCHAR(50)  NOT NULL,   -- e.g. 'MTD Company'
    SourceDescription  NVARCHAR(255) NULL,

    [TaxTypeCode] SMALLINT NOT NULL, 
    [ReportingTypeCode] NVARCHAR(20) NOT NULL,
    CONSTRAINT PK_Cash_tbTaxTagSource
        PRIMARY KEY CLUSTERED (TaxSourceCode),

    CONSTRAINT FK_Cash_tbTaxTagSource_TaxTypeCode
        FOREIGN KEY (TaxTypeCode)
        REFERENCES Cash.tbTaxType(TaxTypeCode) ON DELETE CASCADE,

    CONSTRAINT FK_Cash_tbTaxTagSource_App_tbReportingType
        FOREIGN KEY (ReportingTypeCode)
        REFERENCES App.tbReportingType(ReportingTypeCode)
);
GO
