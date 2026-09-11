CREATE TABLE [Subject].[tbAddressType]
(
	[AddressTypeCode] SMALLINT NOT NULL,
	[AddressType] NVARCHAR(50) NOT NULL,
	[RowVer] ROWVERSION NOT NULL,
	CONSTRAINT [PK_Subject_tbAddressType] PRIMARY KEY CLUSTERED ([AddressTypeCode])
);
