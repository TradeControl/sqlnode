CREATE TABLE [Subject].[tbAddressDetail]
(
    [AddressCode] NVARCHAR(15) NOT NULL,
    [AddressLine1] NVARCHAR(100) NOT NULL,
    [AddressLine2] NVARCHAR(100) NULL,
    [AddressLine3] NVARCHAR(100) NULL,
    [Locality] NVARCHAR(100) NOT NULL,
    [Region] NVARCHAR(100) NULL,
    [PostalCode] NVARCHAR(20) NOT NULL,
    [JurisdictionCode] NVARCHAR(10) NOT NULL,
    [ValueSourceCode] NVARCHAR(10) NOT NULL,
    [IsReviewed] BIT NOT NULL CONSTRAINT [DF_Subject_tbAddressDetail_IsReviewed] DEFAULT (0),
    [InsertedBy] NVARCHAR(50) NOT NULL CONSTRAINT [DF_Subject_tbAddressDetail_InsertedBy] DEFAULT (suser_sname()),
    [InsertedOn] DATETIME NOT NULL CONSTRAINT [DF_Subject_tbAddressDetail_InsertedOn] DEFAULT (getdate()),
    [UpdatedBy] NVARCHAR(50) NOT NULL CONSTRAINT [DF_Subject_tbAddressDetail_UpdatedBy] DEFAULT (suser_sname()),
    [UpdatedOn] DATETIME NOT NULL CONSTRAINT [DF_Subject_tbAddressDetail_UpdatedOn] DEFAULT (getdate()),
    [RowVer] ROWVERSION NOT NULL,
    CONSTRAINT [PK_Subject_tbAddressDetail] PRIMARY KEY CLUSTERED ([AddressCode]),
    CONSTRAINT [FK_Subject_tbAddressDetail_Subject_tbAddress] FOREIGN KEY ([AddressCode])
        REFERENCES [Subject].[tbAddress] ([AddressCode]) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT [FK_Subject_tbAddressDetail_App_tbJurisdiction] FOREIGN KEY ([JurisdictionCode])
        REFERENCES [App].[tbJurisdiction] ([JurisdictionCode]),
    CONSTRAINT [FK_Subject_tbAddressDetail_App_tbValueSource] FOREIGN KEY ([ValueSourceCode])
        REFERENCES [App].[tbValueSource] ([ValueSourceCode])
);
GO
CREATE TRIGGER [Subject].[Subject_tbAddressDetail_TriggerUpdate]
ON [Subject].[tbAddressDetail]
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE detail
    SET UpdatedBy = suser_sname(), UpdatedOn = current_timestamp
    FROM Subject.tbAddressDetail detail
    JOIN inserted i ON i.AddressCode = detail.AddressCode;
END;
