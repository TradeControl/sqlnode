/**************************************************************************************
Trade Control
Node Creation Script - SCHEMA + LOGIC + CONTROL DATA
Release: 3.23.1

Date: 1 August 2019
Author: Ian Monnox

Trade Control by Trade Control Ltd is licensed under GNU General Public License v3.0. 

You may obtain a copy of the License at

	https://www.gnu.org/licenses/gpl-3.0.en.html

***********************************************************************************/
go
CREATE SCHEMA Activity;
go
CREATE SCHEMA App;
go
CREATE SCHEMA Cash;
go
CREATE SCHEMA Invoice;
go
CREATE SCHEMA Org;
go
CREATE SCHEMA Task;
go
CREATE SCHEMA Usr;
go
CREATE TABLE Activity.tbActivity(
	ActivityCode nvarchar(50) NOT NULL,
	TaskStatusCode smallint NOT NULL,
	DefaultText ntext NULL,
	UnitOfMeasure nvarchar(15) NOT NULL,
	CashCode nvarchar(50) NULL,
	UnitCharge money NOT NULL,
	Printed bit NOT NULL,
	RegisterName nvarchar(50) NULL,
	InsertedBy nvarchar(50) NOT NULL,
	InsertedOn datetime NOT NULL,
	UpdatedBy nvarchar(50) NOT NULL,
	UpdatedOn datetime NOT NULL,
	RowVer timestamp NOT NULL,
 CONSTRAINT PK_Activity_tbActivityCode PRIMARY KEY NONCLUSTERED 
(
	ActivityCode ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
go

CREATE TABLE Activity.tbAttribute(
	ActivityCode nvarchar(50) NOT NULL,
	Attribute nvarchar(50) NOT NULL,
	PrintOrder smallint NOT NULL,
	AttributeTypeCode smallint NOT NULL,
	DefaultText nvarchar(400) NULL,
	InsertedBy nvarchar(50) NOT NULL,
	InsertedOn datetime NOT NULL,
	UpdatedBy nvarchar(50) NOT NULL,
	UpdatedOn datetime NOT NULL,
	RowVer timestamp NOT NULL,
 CONSTRAINT PK_Activity_tbAttribute PRIMARY KEY CLUSTERED 
(
	ActivityCode ASC,
	Attribute ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
go

CREATE TABLE Activity.tbAttributeType(
	AttributeTypeCode smallint NOT NULL,
	AttributeType nvarchar(20) NOT NULL,
 CONSTRAINT PK_Activity_tbAttributeType PRIMARY KEY CLUSTERED 
(
	AttributeTypeCode ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
go

CREATE TABLE Activity.tbFlow(
	ParentCode nvarchar(50) NOT NULL,
	StepNumber smallint NOT NULL,
	ChildCode nvarchar(50) NOT NULL,
	SyncTypeCode smallint NOT NULL,
	OffsetDays smallint NOT NULL,
	UsedOnQuantity float NOT NULL,
	InsertedBy nvarchar(50) NOT NULL,
	InsertedOn datetime NOT NULL,
	UpdatedBy nvarchar(50) NOT NULL,
	UpdatedOn datetime NOT NULL,
	RowVer timestamp NOT NULL,
 CONSTRAINT PK_Activity_tbFlow PRIMARY KEY NONCLUSTERED 
(
	ParentCode ASC,
	StepNumber ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
go
CREATE TABLE Activity.tbOp(
	ActivityCode nvarchar(50) NOT NULL,
	OperationNumber smallint NOT NULL,
	SyncTypeCode smallint NOT NULL,
	Operation nvarchar(50) NOT NULL,
	Duration float NOT NULL,
	OffsetDays smallint NOT NULL,
	InsertedBy nvarchar(50) NOT NULL,
	InsertedOn datetime NOT NULL,
	UpdatedBy nvarchar(50) NOT NULL,
	UpdatedOn datetime NOT NULL,
	RowVer timestamp NOT NULL,
 CONSTRAINT PK_Activity_tbOp PRIMARY KEY CLUSTERED 
(
	ActivityCode ASC,
	OperationNumber ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
go

CREATE TABLE Activity.tbSyncType(
	SyncTypeCode smallint NOT NULL,
	SyncType nvarchar(50) NOT NULL,
 CONSTRAINT PK_Activity_tbSyncType PRIMARY KEY CLUSTERED 
(
	SyncTypeCode ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
go

CREATE TABLE App.tbBucket(
	Period smallint NOT NULL,
	BucketId nvarchar(10) NOT NULL,
	BucketDescription nvarchar(50) NULL,
	AllowForecasts bit NOT NULL,
	RowVer timestamp NOT NULL,
 CONSTRAINT PK_App_tbBucket PRIMARY KEY CLUSTERED 
(
	Period ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
go

CREATE TABLE App.tbBucketInterval(
	BucketIntervalCode smallint NOT NULL,
	BucketInterval nvarchar(15) NOT NULL,
	RowVer timestamp NOT NULL,
 CONSTRAINT PK_App_tbBucketInterval PRIMARY KEY CLUSTERED 
(
	BucketIntervalCode ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
go

CREATE TABLE App.tbBucketType(
	BucketTypeCode smallint NOT NULL,
	BucketType nvarchar(25) NOT NULL,
 CONSTRAINT PK_App_tbBucketType PRIMARY KEY CLUSTERED 
(
	BucketTypeCode ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
go

CREATE TABLE App.tbCalendar(
	CalendarCode nvarchar(10) NOT NULL,
	Monday bit NOT NULL,
	Tuesday bit NOT NULL,
	Wednesday bit NOT NULL,
	Thursday bit NOT NULL,
	Friday bit NOT NULL,
	Saturday bit NOT NULL,
	Sunday bit NOT NULL,
	RowVer timestamp NOT NULL,
 CONSTRAINT PK_App_tbCalendar PRIMARY KEY CLUSTERED 
(
	CalendarCode ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
go

CREATE TABLE App.tbCalendarHoliday(
	CalendarCode nvarchar(10) NOT NULL,
	UnavailableOn datetime NOT NULL,
	RowVer timestamp NOT NULL,
 CONSTRAINT PK_App_tbCalendarHoliday PRIMARY KEY CLUSTERED 
(
	CalendarCode ASC,
	UnavailableOn ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
go

CREATE TABLE App.tbCodeExclusion(
	ExcludedTag nvarchar(100) NOT NULL,
	RowVer timestamp NOT NULL,
 CONSTRAINT PK_App_tbCodeExclusion PRIMARY KEY CLUSTERED 
(
	ExcludedTag ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
go

CREATE TABLE App.tbDoc(
	DocTypeCode smallint NOT NULL,
	ReportName nvarchar(50) NOT NULL,
	OpenMode smallint NOT NULL,
	Description nvarchar(50) NOT NULL,
	RowVer timestamp NOT NULL,
 CONSTRAINT PK_App_tbDoc PRIMARY KEY CLUSTERED 
(
	DocTypeCode ASC,
	ReportName ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
go

CREATE TABLE App.tbDocClass(
	DocClassCode smallint NOT NULL,
	DocClass nvarchar(50) NOT NULL,
 CONSTRAINT PK_App_tbDocClass PRIMARY KEY CLUSTERED 
(
	DocClassCode ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
go

CREATE TABLE App.tbDocSpool(
	UserName nvarchar(50) NOT NULL,
	DocTypeCode smallint NOT NULL,
	DocumentNumber nvarchar(25) NOT NULL,
	SpooledOn datetime NOT NULL,
	RowVer timestamp NOT NULL,
 CONSTRAINT PK_App_tbDocSpool PRIMARY KEY CLUSTERED 
(
	UserName ASC,
	DocTypeCode ASC,
	DocumentNumber ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
go

CREATE TABLE App.tbDocType(
	DocTypeCode smallint NOT NULL,
	DocType nvarchar(50) NOT NULL,
	DocClassCode smallint NOT NULL,
 CONSTRAINT PK_App_tbDocType PRIMARY KEY CLUSTERED 
(
	DocTypeCode ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
go

CREATE TABLE App.tbEventLog(
	LogCode nvarchar(20) NOT NULL,
	LoggedOn datetime NOT NULL,
	EventTypeCode smallint NOT NULL,
	EventMessage nvarchar(max) NULL,
	InsertedBy nvarchar(50) NOT NULL,
	RowVer timestamp NOT NULL,
 CONSTRAINT PK_App_tbEventLog_LogCode PRIMARY KEY CLUSTERED 
(
	LogCode ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
go

CREATE TABLE App.tbEventType(
	EventTypeCode smallint NOT NULL,
	EventType nvarchar(15) NOT NULL,
 CONSTRAINT PK_tbFeedLogEventCode PRIMARY KEY CLUSTERED 
(
	EventTypeCode ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
go

CREATE TABLE App.tbInstall
(
	InstallId INT NOT NULL IDENTITY,
	SQLDataVersion REAL NOT NULL,
	SQLRelease INT NOT NULL,
	InsertedBy nvarchar(50) NOT NULL CONSTRAINT DF_App_tbInstall_InsertedBy DEFAULT (SUSER_SNAME()),
	InsertedOn datetime NOT NULL CONSTRAINT DF_App_tbInstall_InsertedOn DEFAULT (GETDATE()),
	UpdatedBy nvarchar(50) NOT NULL CONSTRAINT DF_App_tbInstall_UpdatedBy DEFAULT (SUSER_SNAME()),
	UpdatedOn datetime NOT NULL CONSTRAINT DF_App_tbInstall_UpdatedOn DEFAULT (GETDATE()),
	CONSTRAINT PK_App_tbInstall PRIMARY KEY CLUSTERED 
	(
		InstallId ASC
	)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY];
go

CREATE TABLE App.tbMonth(
	MonthNumber smallint NOT NULL,
	MonthName nvarchar(10) NOT NULL,
 CONSTRAINT PK_App_tbMonth PRIMARY KEY CLUSTERED 
(
	MonthNumber ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
go

CREATE TABLE App.tbOptions(
	Identifier nvarchar(4) NOT NULL,
	IsInitialised bit NOT NULL,
	AccountCode nvarchar(10) NOT NULL,
	RegisterName nvarchar(50) NOT NULL,
	DefaultPrintMode smallint NOT NULL,
	BucketTypeCode smallint NOT NULL,
	BucketIntervalCode smallint NOT NULL,
	NetProfitCode nvarchar(10) NULL,
	VatCategoryCode nvarchar(10) NULL,
	TaxHorizon smallint NOT NULL,
	IsAutoOffsetDays bit NOT NULL,
	InsertedBy nvarchar(50) NOT NULL,
	InsertedOn datetime NOT NULL,
	UpdatedBy nvarchar(50) NOT NULL,
	UpdatedOn datetime NOT NULL,
	RowVer timestamp NOT NULL,
 CONSTRAINT PK_App_tbOptions PRIMARY KEY CLUSTERED 
(
	Identifier ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
go

CREATE TABLE App.tbRecurrence(
	RecurrenceCode smallint NOT NULL,
	Recurrence nvarchar(20) NOT NULL,
 CONSTRAINT PK_App_tbRecurrence PRIMARY KEY CLUSTERED 
(
	RecurrenceCode ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
go

CREATE TABLE App.tbRegister(
	RegisterName nvarchar(50) NOT NULL,
	NextNumber int NOT NULL,
	RowVer timestamp NOT NULL,
 CONSTRAINT PK_App_tbRegister PRIMARY KEY CLUSTERED 
(
	RegisterName ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
go

CREATE TABLE App.tbRounding(
	RoundingCode smallint NOT NULL,
	Rounding nvarchar(20) NOT NULL,
 CONSTRAINT PK_tbRounding PRIMARY KEY CLUSTERED 
(
	RoundingCode ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
go

CREATE TABLE App.tbTaxCode(
	TaxCode nvarchar(10) NOT NULL,
	TaxRate float NOT NULL,
	TaxDescription nvarchar(50) NOT NULL,
	TaxTypeCode smallint NOT NULL,
	RoundingCode smallint NOT NULL,
	UpdatedBy nvarchar(50) NOT NULL,
	UpdatedOn datetime NOT NULL,
	RowVer timestamp NOT NULL,
 CONSTRAINT PK_App_tbTaxCode PRIMARY KEY CLUSTERED 
(
	TaxCode ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
go

CREATE TABLE App.tbText(
	TextId int NOT NULL,
	Message ntext NOT NULL,
	Arguments smallint NOT NULL,
	RowVer timestamp NOT NULL,
 CONSTRAINT PK_App_tbText PRIMARY KEY CLUSTERED 
(
	TextId ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
go

CREATE TABLE App.tbUom(
	UnitOfMeasure nvarchar(15) NOT NULL,
	RowVer timestamp NOT NULL,
 CONSTRAINT PK_App_tbUom PRIMARY KEY CLUSTERED 
(
	UnitOfMeasure ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
go

CREATE TABLE App.tbYear(
	YearNumber smallint NOT NULL,
	StartMonth smallint NOT NULL,
	CashStatusCode smallint NOT NULL,
	Description nvarchar(10) NOT NULL,
	InsertedBy nvarchar(50) NOT NULL,
	InsertedOn datetime NOT NULL,
	RowVer timestamp NOT NULL,
 CONSTRAINT PK_App_tbYear PRIMARY KEY CLUSTERED 
(
	YearNumber ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
go

CREATE TABLE App.tbYearPeriod(
	YearNumber smallint NOT NULL,
	StartOn datetime NOT NULL,
	MonthNumber smallint NOT NULL,
	CashStatusCode smallint NOT NULL,
	InsertedBy nvarchar(50) NOT NULL,
	InsertedOn datetime NOT NULL,
	CorporationTaxRate real NOT NULL,
	TaxAdjustment money NOT NULL,
	VatAdjustment money NOT NULL,
	RowVer timestamp NOT NULL,
 CONSTRAINT PK_App_tbYearPeriod PRIMARY KEY CLUSTERED 
(
	YearNumber ASC,
	StartOn ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY],
 CONSTRAINT IX_App_tbYearPeriod_StartOn UNIQUE NONCLUSTERED 
(
	StartOn ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY],
 CONSTRAINT IX_App_tbYearPeriod_Year_MonthNumber UNIQUE NONCLUSTERED 
(
	YearNumber ASC,
	MonthNumber ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
go

CREATE TABLE Cash.tbCategory(
	CategoryCode nvarchar(10) NOT NULL,
	Category nvarchar(50) NOT NULL,
	CategoryTypeCode smallint NOT NULL,
	CashModeCode smallint NULL,
	CashTypeCode smallint NULL,
	DisplayOrder smallint NOT NULL,
	IsEnabled smallint NOT NULL,
	InsertedBy nvarchar(50) NOT NULL,
	InsertedOn datetime NOT NULL,
	UpdatedBy nvarchar(50) NOT NULL,
	UpdatedOn datetime NOT NULL,
	RowVer timestamp NOT NULL,
 CONSTRAINT PK_Cash_tbCategory PRIMARY KEY CLUSTERED 
(
	CategoryCode ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
go

CREATE TABLE Cash.tbCategoryExp(
	CategoryCode nvarchar(10) NOT NULL,
	Expression nvarchar(256) NOT NULL,
	Format nvarchar(100) NOT NULL,
	RowVer timestamp NOT NULL,
 CONSTRAINT PK_Cash_tbCategoryExp PRIMARY KEY CLUSTERED 
(
	CategoryCode ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
go

CREATE TABLE Cash.tbCategoryTotal(
	ParentCode nvarchar(10) NOT NULL,
	ChildCode nvarchar(10) NOT NULL,
	RowVer timestamp NOT NULL,
 CONSTRAINT PK_Cash_tbCategoryTotal PRIMARY KEY CLUSTERED 
(
	ParentCode ASC,
	ChildCode ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
go

CREATE TABLE Cash.tbCategoryType(
	CategoryTypeCode smallint NOT NULL,
	CategoryType nvarchar(20) NOT NULL,
 CONSTRAINT PK_Cash_tbCategoryType PRIMARY KEY CLUSTERED 
(
	CategoryTypeCode ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
go

CREATE TABLE Cash.tbCode(
	CashCode nvarchar(50) NOT NULL,
	CashDescription nvarchar(100) NOT NULL,
	CategoryCode nvarchar(10) NOT NULL,
	TaxCode nvarchar(10) NOT NULL,
	OpeningBalance money NOT NULL,
	IsEnabled smallint NOT NULL,
	InsertedBy nvarchar(50) NOT NULL,
	InsertedOn datetime NOT NULL,
	UpdatedBy nvarchar(50) NOT NULL,
	UpdatedOn datetime NOT NULL,
	RowVer timestamp NOT NULL,
 CONSTRAINT PK_Cash_tbCode PRIMARY KEY CLUSTERED 
(
	CashCode ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY],
 CONSTRAINT IX_Cash_tbCodeDescription UNIQUE NONCLUSTERED 
(
	CashDescription ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
go

CREATE TABLE Cash.tbEntryType(
	CashEntryTypeCode smallint NOT NULL,
	CashEntryType nvarchar(20) NOT NULL,
 CONSTRAINT PK_Cash_tbEntryType PRIMARY KEY CLUSTERED 
(
	CashEntryTypeCode ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
go

CREATE TABLE Cash.tbMode(
	CashModeCode smallint NOT NULL,
	CashMode nvarchar(10) NULL,
 CONSTRAINT PK_Cash_tbMode PRIMARY KEY CLUSTERED 
(
	CashModeCode ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
go

CREATE TABLE Cash.tbPeriod(
	CashCode nvarchar(50) NOT NULL,
	StartOn datetime NOT NULL,
	ForecastValue money NOT NULL,
	ForecastTax money NOT NULL,
	InvoiceValue money NOT NULL,
	InvoiceTax money NOT NULL,
	Note ntext NULL,
	RowVer timestamp NOT NULL,
 CONSTRAINT PK_Cash_tbPeriod PRIMARY KEY CLUSTERED 
(
	CashCode ASC,
	StartOn ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
go

CREATE TABLE Cash.tbStatus(
	CashStatusCode smallint NOT NULL,
	CashStatus nvarchar(15) NOT NULL,
 CONSTRAINT PK_Cash_tbStatus PRIMARY KEY CLUSTERED 
(
	CashStatusCode ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
go

CREATE TABLE Cash.tbTaxType(
	TaxTypeCode smallint NOT NULL,
	TaxType nvarchar(20) NOT NULL,
	CashCode nvarchar(50) NULL,
	MonthNumber smallint NOT NULL,
	RecurrenceCode smallint NOT NULL,
	AccountCode nvarchar(10) NULL,
	OffsetDays smallint NOT NULL,
	RowVer timestamp NOT NULL,
 CONSTRAINT PK_Cash_tbTaxType PRIMARY KEY CLUSTERED 
(
	TaxTypeCode ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
go

CREATE TABLE Cash.tbType(
	CashTypeCode smallint NOT NULL,
	CashType nvarchar(25) NULL,
 CONSTRAINT PK_Cash_tbType PRIMARY KEY CLUSTERED 
(
	CashTypeCode ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
go

CREATE TABLE Invoice.tbInvoice(
	InvoiceNumber nvarchar(20) NOT NULL,
	UserId nvarchar(10) NOT NULL,
	AccountCode nvarchar(10) NOT NULL,
	InvoiceTypeCode smallint NOT NULL,
	InvoiceStatusCode smallint NOT NULL,
	InvoicedOn datetime NOT NULL,
	ExpectedOn datetime NOT NULL,
	DueOn datetime NOT NULL,
	InvoiceValue money NOT NULL,
	TaxValue money NOT NULL,
	PaidValue money NOT NULL,
	PaidTaxValue money NOT NULL,
	PaymentTerms nvarchar(100) NULL,
	Notes ntext NULL,
	Printed bit NOT NULL,
	Spooled bit NOT NULL,
	RowVer timestamp NOT NULL,
 CONSTRAINT PK_Invoice_tbInvoicePK PRIMARY KEY CLUSTERED 
(
	InvoiceNumber ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
go

CREATE TABLE Invoice.tbItem(
	InvoiceNumber nvarchar(20) NOT NULL,
	CashCode nvarchar(50) NOT NULL,
	TaxCode nvarchar(10) NULL,
	TotalValue money NOT NULL,
	InvoiceValue money NOT NULL,
	TaxValue money NOT NULL,
	PaidValue money NOT NULL,
	PaidTaxValue money NOT NULL,
	ItemReference ntext NULL,
	RowVer timestamp NOT NULL,
 CONSTRAINT PK_Invoice_tbItem PRIMARY KEY CLUSTERED 
(
	InvoiceNumber ASC,
	CashCode ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
go

CREATE TABLE Invoice.tbStatus(
	InvoiceStatusCode smallint NOT NULL,
	InvoiceStatus nvarchar(50) NULL,
 CONSTRAINT PK_Invoice_tbStatus PRIMARY KEY NONCLUSTERED 
(
	InvoiceStatusCode ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
go

CREATE TABLE Invoice.tbTask(
	InvoiceNumber nvarchar(20) NOT NULL,
	TaskCode nvarchar(20) NOT NULL,
	Quantity float NOT NULL,
	TotalValue money NOT NULL,
	InvoiceValue money NOT NULL,
	TaxValue money NOT NULL,
	PaidValue money NOT NULL,
	PaidTaxValue money NOT NULL,
	CashCode nvarchar(50) NOT NULL,
	TaxCode nvarchar(10) NULL,
	RowVer timestamp NOT NULL,
 CONSTRAINT PK_Invoice_tbTask PRIMARY KEY CLUSTERED 
(
	InvoiceNumber ASC,
	TaskCode ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
go

CREATE TABLE Invoice.tbType(
	InvoiceTypeCode smallint NOT NULL,
	InvoiceType nvarchar(20) NOT NULL,
	CashModeCode smallint NOT NULL,
	NextNumber int NOT NULL,
	RowVer timestamp NOT NULL,
 CONSTRAINT PK_Invoice_tbType PRIMARY KEY CLUSTERED 
(
	InvoiceTypeCode ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
go

CREATE TABLE Org.tbAccount(
	CashAccountCode nvarchar(10) NOT NULL,
	AccountCode nvarchar(10) NOT NULL,
	CashAccountName nvarchar(50) NOT NULL,
	OpeningBalance money NOT NULL,
	CurrentBalance money NOT NULL,
	SortCode nvarchar(10) NULL,
	AccountNumber nvarchar(20) NULL,
	CashCode nvarchar(50) NULL,
	AccountClosed bit NOT NULL,
	DummyAccount bit NOT NULL,
	InsertedBy nvarchar(50) NOT NULL,
	InsertedOn datetime NOT NULL,
	UpdatedBy nvarchar(50) NOT NULL,
	UpdatedOn datetime NOT NULL,
	RowVer timestamp NOT NULL,
 CONSTRAINT PK_Org_tbAccount PRIMARY KEY CLUSTERED 
(
	CashAccountCode ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
go

CREATE TABLE Org.tbAddress(
	AddressCode nvarchar(15) NOT NULL,
	AccountCode nvarchar(10) NOT NULL,
	Address ntext NOT NULL,
	InsertedBy nvarchar(50) NOT NULL,
	InsertedOn datetime NOT NULL,
	UpdatedBy nvarchar(50) NOT NULL,
	UpdatedOn datetime NOT NULL,
	RowVer timestamp NOT NULL,
 CONSTRAINT PK_Org_tbAddress PRIMARY KEY CLUSTERED 
(
	AddressCode ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
go

CREATE TABLE Org.tbContact(
	AccountCode nvarchar(10) NOT NULL,
	ContactName nvarchar(100) NOT NULL,
	FileAs nvarchar(100) NULL,
	OnMailingList bit NOT NULL,
	NameTitle nvarchar(25) NULL,
	NickName nvarchar(100) NULL,
	JobTitle nvarchar(100) NULL,
	PhoneNumber nvarchar(50) NULL,
	MobileNumber nvarchar(50) NULL,
	FaxNumber nvarchar(50) NULL,
	EmailAddress nvarchar(255) NULL,
	Hobby nvarchar(50) NULL,
	DateOfBirth datetime NULL,
	Department nvarchar(50) NULL,
	SpouseName nvarchar(50) NULL,
	HomeNumber nvarchar(50) NULL,
	Information ntext NULL,
	Photo image NULL,
	InsertedBy nvarchar(50) NOT NULL,
	InsertedOn datetime NOT NULL,
	UpdatedBy nvarchar(50) NOT NULL,
	UpdatedOn datetime NOT NULL,
	RowVer timestamp NOT NULL,
 CONSTRAINT PK_Org_tbContact PRIMARY KEY NONCLUSTERED 
(
	AccountCode ASC,
	ContactName ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
go

CREATE TABLE Org.tbDoc(
	AccountCode nvarchar(10) NOT NULL,
	DocumentName nvarchar(255) NOT NULL,
	DocumentDescription ntext NULL,
	DocumentImage image NULL,
	InsertedBy nvarchar(50) NOT NULL,
	InsertedOn datetime NOT NULL,
	UpdatedBy nvarchar(50) NOT NULL,
	UpdatedOn datetime NOT NULL,
	RowVer timestamp NOT NULL,
 CONSTRAINT PK_Org_tbDoc PRIMARY KEY NONCLUSTERED 
(
	AccountCode ASC,
	DocumentName ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
go

CREATE TABLE Org.tbOrg(
	AccountCode nvarchar(10) NOT NULL,
	AccountName nvarchar(255) NOT NULL,
	OrganisationTypeCode smallint NOT NULL,
	OrganisationStatusCode smallint NOT NULL,
	TaxCode nvarchar(10) NULL,
	AddressCode nvarchar(15) NULL,
	AreaCode nvarchar(50) NULL,
	PhoneNumber nvarchar(50) NULL,
	FaxNumber nvarchar(50) NULL,
	EmailAddress nvarchar(255) NULL,
	WebSite nvarchar(255) NULL,
	IndustrySector nvarchar(255) NULL,
	AccountSource nvarchar(100) NULL,
	PaymentTerms nvarchar(100) NULL,
	ExpectedDays smallint NOT NULL,
	PaymentDays smallint NOT NULL,
	PayDaysFromMonthEnd bit NOT NULL,
	PayBalance bit NOT NULL,
	NumberOfEmployees int NOT NULL,
	CompanyNumber nvarchar(20) NULL,
	VatNumber nvarchar(50) NULL,
	Turnover money NOT NULL,
	OpeningBalance money NOT NULL,
	EUJurisdiction bit NOT NULL,
	BusinessDescription ntext NULL,
	Logo image NULL,
	InsertedBy nvarchar(50) NOT NULL,
	InsertedOn datetime NOT NULL,
	UpdatedBy nvarchar(50) NOT NULL,
	UpdatedOn datetime NOT NULL,
	RowVer timestamp NOT NULL,
 CONSTRAINT PK_Org_tbOrg PRIMARY KEY NONCLUSTERED 
(
	AccountCode ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
go

CREATE TABLE Org.tbPayment(
	PaymentCode nvarchar(20) NOT NULL,
	UserId nvarchar(10) NOT NULL,
	PaymentStatusCode smallint NOT NULL,
	AccountCode nvarchar(10) NOT NULL,
	CashAccountCode nvarchar(10) NOT NULL,
	CashCode nvarchar(50) NULL,
	TaxCode nvarchar(10) NULL,
	PaidOn datetime NOT NULL,
	PaidInValue money NOT NULL,
	PaidOutValue money NOT NULL,
	TaxInValue money NOT NULL,
	TaxOutValue money NOT NULL,
	PaymentReference nvarchar(50) NULL,
	InsertedBy nvarchar(50) NOT NULL,
	InsertedOn datetime NOT NULL,
	UpdatedBy nvarchar(50) NOT NULL,
	UpdatedOn datetime NOT NULL,
	RowVer timestamp NOT NULL,
 CONSTRAINT PK_Org_tbPayment PRIMARY KEY CLUSTERED 
(
	PaymentCode ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
go

CREATE TABLE Org.tbPaymentStatus(
	PaymentStatusCode smallint NOT NULL,
	PaymentStatus nvarchar(20) NOT NULL,
 CONSTRAINT PK_Org_tbPaymentStatus PRIMARY KEY CLUSTERED 
(
	PaymentStatusCode ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
go

CREATE TABLE Org.tbSector(
	AccountCode nvarchar(10) NOT NULL,
	IndustrySector nvarchar(50) NOT NULL,
	RowVer timestamp NOT NULL,
 CONSTRAINT PK_Org_tbSector PRIMARY KEY CLUSTERED 
(
	AccountCode ASC,
	IndustrySector ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
go

CREATE TABLE Org.tbStatus(
	OrganisationStatusCode smallint NOT NULL,
	OrganisationStatus nvarchar(255) NULL,
 CONSTRAINT PK_Org_tbStatus PRIMARY KEY NONCLUSTERED 
(
	OrganisationStatusCode ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
go

CREATE TABLE Org.tbType(
	OrganisationTypeCode smallint NOT NULL,
	CashModeCode smallint NOT NULL,
	OrganisationType nvarchar(50) NOT NULL,
	RowVer timestamp NOT NULL,
 CONSTRAINT PK_Org_tbType PRIMARY KEY NONCLUSTERED 
(
	OrganisationTypeCode ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
go

CREATE TABLE Task.tbAttribute(
	TaskCode nvarchar(20) NOT NULL,
	Attribute nvarchar(50) NOT NULL,
	PrintOrder smallint NOT NULL,
	AttributeTypeCode smallint NOT NULL,
	AttributeDescription nvarchar(400) NULL,
	InsertedBy nvarchar(50) NOT NULL,
	InsertedOn datetime NOT NULL,
	UpdatedBy nvarchar(50) NOT NULL,
	UpdatedOn datetime NOT NULL,
	RowVer timestamp NOT NULL,
 CONSTRAINT PK_Task_tbTaskAttribute PRIMARY KEY CLUSTERED 
(
	TaskCode ASC,
	Attribute ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
go

CREATE TABLE Task.tbDoc(
	TaskCode nvarchar(20) NOT NULL,
	DocumentName nvarchar(255) NOT NULL,
	DocumentDescription ntext NULL,
	DocumentImage image NOT NULL,
	InsertedBy nvarchar(50) NOT NULL,
	InsertedOn datetime NOT NULL,
	UpdatedBy nvarchar(50) NOT NULL,
	UpdatedOn datetime NOT NULL,
	RowVer timestamp NOT NULL,
 CONSTRAINT PK_Task_tbDoc PRIMARY KEY CLUSTERED 
(
	TaskCode ASC,
	DocumentName ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
go

CREATE TABLE Task.tbFlow(
	ParentTaskCode nvarchar(20) NOT NULL,
	StepNumber smallint NOT NULL,
	ChildTaskCode nvarchar(20) NULL,
	SyncTypeCode smallint NOT NULL,
	UsedOnQuantity float NOT NULL,
	OffsetDays real NOT NULL,
	InsertedBy nvarchar(50) NOT NULL,
	InsertedOn datetime NOT NULL,
	UpdatedBy nvarchar(50) NOT NULL,
	UpdatedOn datetime NOT NULL,
	RowVer timestamp NOT NULL,
 CONSTRAINT PK_Task_tbFlow PRIMARY KEY CLUSTERED 
(
	ParentTaskCode ASC,
	StepNumber ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
go

CREATE TABLE Task.tbOp(
	TaskCode nvarchar(20) NOT NULL,
	OperationNumber smallint NOT NULL,
	SyncTypeCode smallint NOT NULL,
	OpStatusCode smallint NOT NULL,
	UserId nvarchar(10) NOT NULL,
	Operation nvarchar(50) NOT NULL,
	Note ntext NULL,
	StartOn datetime NOT NULL,
	EndOn datetime NOT NULL,
	Duration float NOT NULL,
	OffsetDays smallint NOT NULL,
	InsertedBy nvarchar(50) NOT NULL,
	InsertedOn datetime NOT NULL,
	UpdatedBy nvarchar(50) NOT NULL,
	UpdatedOn datetime NOT NULL,
	RowVer timestamp NOT NULL,
 CONSTRAINT PK_Task_tbOp PRIMARY KEY CLUSTERED 
(
	TaskCode ASC,
	OperationNumber ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
go

CREATE TABLE Task.tbOpStatus(
	OpStatusCode smallint NOT NULL,
	OpStatus nvarchar(50) NOT NULL,
 CONSTRAINT PK_Task_tbOpStatus PRIMARY KEY CLUSTERED 
(
	OpStatusCode ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
go

CREATE TABLE Task.tbQuote(
	TaskCode nvarchar(20) NOT NULL,
	Quantity float NOT NULL,
	TotalPrice money NOT NULL,
	RunOnQuantity float NOT NULL,
	RunOnPrice money NOT NULL,
	RunBackQuantity float NOT NULL,
	RunBackPrice float NOT NULL,
	InsertedBy nvarchar(50) NOT NULL,
	InsertedOn datetime NOT NULL,
	UpdatedBy nvarchar(50) NOT NULL,
	UpdatedOn datetime NOT NULL,
	RowVer timestamp NOT NULL,
 CONSTRAINT PK_Task_tbQuote PRIMARY KEY CLUSTERED 
(
	TaskCode ASC,
	Quantity ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
go

CREATE TABLE Task.tbStatus(
	TaskStatusCode smallint NOT NULL,
	TaskStatus nvarchar(100) NOT NULL,
 CONSTRAINT PK_Task_tbStatus PRIMARY KEY NONCLUSTERED 
(
	TaskStatusCode ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
go

CREATE TABLE Task.tbTask(
	TaskCode nvarchar(20) NOT NULL,
	UserId nvarchar(10) NOT NULL,
	AccountCode nvarchar(10) NOT NULL,
	SecondReference nvarchar(20) NULL,
	TaskTitle nvarchar(100) NULL,
	ContactName nvarchar(100) NULL,
	ActivityCode nvarchar(50) NOT NULL,
	TaskStatusCode smallint NOT NULL,
	ActionById nvarchar(10) NOT NULL,
	ActionOn datetime NOT NULL,
	ActionedOn datetime NULL,
	PaymentOn datetime NOT NULL,
	TaskNotes nvarchar(255) NULL,
	Quantity float NOT NULL,
	CashCode nvarchar(50) NULL,
	TaxCode nvarchar(10) NULL,
	UnitCharge float NOT NULL,
	TotalCharge money NOT NULL,
	AddressCodeFrom nvarchar(15) NULL,
	AddressCodeTo nvarchar(15) NULL,
	Spooled bit NOT NULL,
	Printed bit NOT NULL,
	InsertedBy nvarchar(50) NOT NULL,
	InsertedOn datetime NOT NULL,
	UpdatedBy nvarchar(50) NOT NULL,
	UpdatedOn datetime NOT NULL,
	RowVer timestamp NOT NULL,
 CONSTRAINT PK_Task_tbTask PRIMARY KEY CLUSTERED 
(
	TaskCode ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
go

CREATE TABLE Usr.tbMenu(
	MenuId smallint IDENTITY(1,1) NOT NULL,
	MenuName nvarchar(50) NOT NULL,
	InsertedOn datetime NOT NULL,
	InsertedBy nvarchar(50) NOT NULL,
	RowVer timestamp NOT NULL,
 CONSTRAINT PK_Usr_tbMenu PRIMARY KEY CLUSTERED 
(
	MenuId ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY],
 CONSTRAINT IX_Usr_tbMenu UNIQUE NONCLUSTERED 
(
	MenuName ASC,
	MenuId ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
go

CREATE TABLE Usr.tbMenuCommand(
	Command smallint NOT NULL,
	CommandText nvarchar(50) NULL,
 CONSTRAINT PK_Usr_tbMenuCommand PRIMARY KEY CLUSTERED 
(
	Command ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
go

CREATE TABLE Usr.tbMenuEntry(
	MenuId smallint NOT NULL,
	EntryId int IDENTITY(1,1) NOT NULL,
	FolderId smallint NOT NULL,
	ItemId smallint NOT NULL,
	ItemText nvarchar(255) NULL,
	Command smallint NULL,
	ProjectName nvarchar(50) NULL,
	Argument nvarchar(50) NULL,
	OpenMode smallint NULL,
	UpdatedOn datetime NOT NULL,
	InsertedOn datetime NOT NULL,
	UpdatedBy nvarchar(50) NOT NULL,
	RowVer timestamp NOT NULL,
 CONSTRAINT PK_Usr_tbMenuEntry PRIMARY KEY CLUSTERED 
(
	MenuId ASC,
	EntryId ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY],
 CONSTRAINT IX_Usr_tbMenuEntry_MenuFolderItem UNIQUE NONCLUSTERED 
(
	MenuId ASC,
	FolderId ASC,
	ItemId ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
go

CREATE TABLE Usr.tbMenuOpenMode(
	OpenMode smallint NOT NULL,
	OpenModeDescription nvarchar(20) NULL,
 CONSTRAINT PK_Usr_tbMenuOpenMode PRIMARY KEY CLUSTERED 
(
	OpenMode ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
go

CREATE TABLE Usr.tbMenuUser(
	UserId nvarchar(10) NOT NULL,
	MenuId smallint NOT NULL,
	RowVer timestamp NOT NULL,
 CONSTRAINT PK_Usr_tbMenuUser PRIMARY KEY CLUSTERED 
(
	UserId ASC,
	MenuId ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
go

CREATE TABLE Usr.tbUser(
	UserId nvarchar(10) NOT NULL,
	UserName nvarchar(50) NOT NULL,
	LogonName nvarchar(50) NOT NULL,
	CalendarCode nvarchar(10) NULL,
	PhoneNumber nvarchar(50) NULL,
	MobileNumber nvarchar(50) NULL,
	FaxNumber nvarchar(50) NULL,
	EmailAddress nvarchar(255) NULL,
	Address ntext NULL,
	Avatar image NULL,
	Signature image NULL,
	IsAdministrator bit NOT NULL,
	IsEnabled smallint NOT NULL,
	NextTaskNumber int NOT NULL,
	InsertedBy nvarchar(50) NOT NULL,
	InsertedOn datetime NOT NULL,
	UpdatedBy nvarchar(50) NOT NULL,
	UpdatedOn datetime NOT NULL,
	RowVer timestamp NOT NULL,
 CONSTRAINT PK_Usr_tbUser PRIMARY KEY CLUSTERED 
(
	UserId ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
go
SET ANSI_PADDING ON
go
CREATE NONCLUSTERED INDEX IX_Activity_tbAttribute ON Activity.tbAttribute
(
	Attribute ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
go
SET ANSI_PADDING ON
go
CREATE NONCLUSTERED INDEX IX_Activity_tbAttribute_DefaultText ON Activity.tbAttribute
(
	DefaultText ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
go
SET ANSI_PADDING ON
go
CREATE NONCLUSTERED INDEX IX_Activity_tbAttribute_OrderBy ON Activity.tbAttribute
(
	ActivityCode ASC,
	PrintOrder ASC,
	Attribute ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
go
SET ANSI_PADDING ON
go
CREATE NONCLUSTERED INDEX IX_Activity_tbAttribute_Type_OrderBy ON Activity.tbAttribute
(
	ActivityCode ASC,
	AttributeTypeCode ASC,
	PrintOrder ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
go
SET ANSI_PADDING ON
go
CREATE UNIQUE NONCLUSTERED INDEX IX_Activity_tbFlow_ChildParent ON Activity.tbFlow
(
	ChildCode ASC,
	ParentCode ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
go
SET ANSI_PADDING ON
go
CREATE UNIQUE NONCLUSTERED INDEX IX_Activity_tbFlow_ParentChild ON Activity.tbFlow
(
	ParentCode ASC,
	ChildCode ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
go
SET ANSI_PADDING ON
go
CREATE NONCLUSTERED INDEX IX_Activity_tbOp_Operation ON Activity.tbOp
(
	Operation ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
go
SET ANSI_PADDING ON
go
CREATE NONCLUSTERED INDEX IX_App_tbCalendarHoliday_CalendarCode ON App.tbCalendarHoliday
(
	CalendarCode ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
go
CREATE NONCLUSTERED INDEX IX_App_tbDocSpool_DocTypeCode ON App.tbDocSpool
(
	DocTypeCode ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
go
CREATE NONCLUSTERED INDEX IX_App_tbEventLog_EventType ON App.tbEventLog
(
	EventTypeCode ASC,
	LoggedOn ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
go
CREATE NONCLUSTERED INDEX IX_App_tbEventLog_LoggedOn ON App.tbEventLog
(
	LoggedOn DESC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
go
SET ANSI_PADDING ON
go
CREATE NONCLUSTERED INDEX IX_App_tbTaxCodeByType ON App.tbTaxCode
(
	TaxTypeCode ASC,
	TaxCode ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
go
SET ANSI_PADDING ON
go
CREATE NONCLUSTERED INDEX IX_Cash_tbCategory_DisplayOrder ON Cash.tbCategory
(
	DisplayOrder ASC,
	Category ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
go
SET ANSI_PADDING ON
go
CREATE UNIQUE NONCLUSTERED INDEX IX_Cash_tbCategory_IsEnabled_Category ON Cash.tbCategory
(
	IsEnabled ASC,
	Category ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
go
SET ANSI_PADDING ON
go
CREATE UNIQUE NONCLUSTERED INDEX IX_Cash_tbCategory_IsEnabled_CategoryCode ON Cash.tbCategory
(
	IsEnabled ASC,
	CategoryCode ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
go
SET ANSI_PADDING ON
go
CREATE NONCLUSTERED INDEX IX_Cash_tbCategory_Name ON Cash.tbCategory
(
	Category ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
go
SET ANSI_PADDING ON
go
CREATE NONCLUSTERED INDEX IX_Cash_tbCategory_TypeCategory ON Cash.tbCategory
(
	CategoryTypeCode ASC,
	Category ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
go
SET ANSI_PADDING ON
go
CREATE NONCLUSTERED INDEX IX_Cash_tbCategory_TypeOrderCategory ON Cash.tbCategory
(
	CategoryTypeCode ASC,
	DisplayOrder ASC,
	Category ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
go
SET ANSI_PADDING ON
go
CREATE UNIQUE NONCLUSTERED INDEX IX_Cash_tbCode_Category_IsEnabled_Code ON Cash.tbCode
(
	CategoryCode ASC,
	IsEnabled ASC,
	CashCode ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
go
SET ANSI_PADDING ON
go
CREATE UNIQUE NONCLUSTERED INDEX IX_Cash_tbCode_IsEnabled_Code ON Cash.tbCode
(
	IsEnabled ASC,
	CashCode ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
go
SET ANSI_PADDING ON
go
CREATE UNIQUE NONCLUSTERED INDEX IX_Cash_tbCode_IsEnabled_Description ON Cash.tbCode
(
	IsEnabled ASC,
	CashDescription ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
go
SET ANSI_PADDING ON
go
CREATE NONCLUSTERED INDEX IX_tbTaxType_CashCode ON Cash.tbTaxType
(
	CashCode ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
go
SET ANSI_PADDING ON
go
CREATE NONCLUSTERED INDEX IX_Invoice_tb_AccountCode ON Invoice.tbInvoice
(
	AccountCode ASC,
	InvoicedOn ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
go
CREATE NONCLUSTERED INDEX IX_Invoice_tb_Status ON Invoice.tbInvoice
(
	InvoiceStatusCode ASC,
	InvoicedOn ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
go
SET ANSI_PADDING ON
go
CREATE NONCLUSTERED INDEX IX_Invoice_tb_UserId ON Invoice.tbInvoice
(
	UserId ASC,
	InvoiceNumber ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
go
SET ANSI_PADDING ON
go
CREATE NONCLUSTERED INDEX IX_Invoice_tbInvoice_AccountCode_DueOn ON Invoice.tbInvoice
(
	AccountCode ASC,
	InvoiceTypeCode ASC,
	DueOn ASC
)
INCLUDE ( 	InvoiceNumber) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
go
SET ANSI_PADDING ON
go
CREATE NONCLUSTERED INDEX IX_Invoice_tbInvoice_AccountCode_Status ON Invoice.tbInvoice
(
	AccountCode ASC,
	InvoiceStatusCode ASC,
	InvoiceNumber ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
go
SET ANSI_PADDING ON
go
CREATE NONCLUSTERED INDEX IX_Invoice_tbInvoice_AccountCode_Type ON Invoice.tbInvoice
(
	AccountCode ASC,
	InvoiceNumber ASC,
	InvoiceTypeCode ASC
)
INCLUDE ( 	InvoiceValue,
	TaxValue) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
go
SET ANSI_PADDING ON
go
CREATE NONCLUSTERED INDEX IX_Invoice_tbInvoice_AccountValues ON Invoice.tbInvoice
(
	AccountCode ASC,
	InvoiceStatusCode ASC,
	InvoiceNumber ASC
)
INCLUDE ( 	InvoiceValue,
	TaxValue) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
go
CREATE NONCLUSTERED INDEX IX_Invoice_tbInvoice_ExpectedOn ON Invoice.tbInvoice
(
	ExpectedOn ASC,
	InvoiceTypeCode ASC,
	InvoiceStatusCode ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
go
SET ANSI_PADDING ON
go
CREATE NONCLUSTERED INDEX IX_Invoice_tbInvoice_FlowInitialise ON Invoice.tbInvoice
(
	InvoiceTypeCode ASC,
	UserId ASC,
	InvoiceStatusCode ASC,
	AccountCode ASC,
	InvoiceNumber ASC,
	InvoicedOn ASC,
	PaymentTerms ASC,
	Printed ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
go
SET ANSI_PADDING ON
go
CREATE NONCLUSTERED INDEX IX_Invoice_tbItem_CashCode ON Invoice.tbItem
(
	CashCode ASC,
	InvoiceNumber ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
go
SET ANSI_PADDING ON
go
CREATE NONCLUSTERED INDEX IX_Invoice_tbItem_Full ON Invoice.tbItem
(
	InvoiceNumber ASC,
	CashCode ASC,
	InvoiceValue ASC,
	TaxValue ASC,
	TaxCode ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
go
SET ANSI_PADDING ON
go
CREATE NONCLUSTERED INDEX IX_Invoice_tbItem_InvoiceNumber_TaxCode ON Invoice.tbItem
(
	InvoiceNumber ASC,
	TaxCode ASC
)
INCLUDE ( 	CashCode,
	InvoiceValue,
	TaxValue) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
go
SET ANSI_PADDING ON
go
CREATE NONCLUSTERED INDEX IX_Invoice_tbItem_TaxCode ON Invoice.tbItem
(
	TaxCode ASC
)
INCLUDE ( 	InvoiceValue,
	TaxValue) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
go
SET ANSI_PADDING ON
go
CREATE NONCLUSTERED INDEX IX_Invoice_tbTask_CashCode ON Invoice.tbTask
(
	CashCode ASC,
	InvoiceNumber ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
go
SET ANSI_PADDING ON
go
CREATE NONCLUSTERED INDEX IX_Invoice_tbTask_Full ON Invoice.tbTask
(
	InvoiceNumber ASC,
	CashCode ASC,
	InvoiceValue ASC,
	TaxValue ASC,
	TaxCode ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
go
SET ANSI_PADDING ON
go
CREATE NONCLUSTERED INDEX IX_Invoice_tbTask_InvoiceNumber_TaxCode ON Invoice.tbTask
(
	InvoiceNumber ASC,
	TaxCode ASC
)
INCLUDE ( 	CashCode,
	InvoiceValue,
	TaxValue) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
go
SET ANSI_PADDING ON
go
CREATE NONCLUSTERED INDEX IX_Invoice_tbTask_TaskCode ON Invoice.tbTask
(
	TaskCode ASC,
	InvoiceNumber ASC
)
INCLUDE ( 	InvoiceValue,
	TaxValue) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
go
SET ANSI_PADDING ON
go
CREATE NONCLUSTERED INDEX IX_Invoice_tbTask_TaxCode ON Invoice.tbTask
(
	TaxCode ASC
)
INCLUDE ( 	InvoiceValue,
	TaxValue) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
go
SET ANSI_PADDING ON
go
CREATE UNIQUE NONCLUSTERED INDEX IX_Org_tbAccount ON Org.tbAccount
(
	AccountCode ASC,
	CashAccountCode ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
go
SET ANSI_PADDING ON
go
CREATE UNIQUE NONCLUSTERED INDEX IX_Org_tbAddress ON Org.tbAddress
(
	AccountCode ASC,
	AddressCode ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
go
SET ANSI_PADDING ON
go
CREATE NONCLUSTERED INDEX IX_Org_tbContactDepartment ON Org.tbContact
(
	Department ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
go
SET ANSI_PADDING ON
go
CREATE NONCLUSTERED INDEX IX_Org_tbContactJobTitle ON Org.tbContact
(
	JobTitle ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
go
SET ANSI_PADDING ON
go
CREATE NONCLUSTERED INDEX IX_Org_tbContactNameTitle ON Org.tbContact
(
	NameTitle ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
go
SET ANSI_PADDING ON
go
CREATE NONCLUSTERED INDEX IX_Org_tbContact_AccountCode ON Org.tbContact
(
	AccountCode ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
go
SET ANSI_PADDING ON
go
CREATE UNIQUE NONCLUSTERED INDEX IX_Org_tbDoc_DocName_AccountCode ON Org.tbDoc
(
	DocumentName ASC,
	AccountCode ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
go
SET ANSI_PADDING ON
go
CREATE NONCLUSTERED INDEX IX_Org_tbDoc_AccountCode ON Org.tbDoc
(
	AccountCode ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
go
SET ANSI_PADDING ON
go
CREATE UNIQUE NONCLUSTERED INDEX IX_Org_tb_AccountName ON Org.tbOrg
(
	AccountName ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
go
SET ANSI_PADDING ON
go
CREATE NONCLUSTERED INDEX IX_Org_tb_AccountSource ON Org.tbOrg
(
	AccountSource ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
go
SET ANSI_PADDING ON
go
CREATE NONCLUSTERED INDEX IX_Org_tb_AreaCode ON Org.tbOrg
(
	AreaCode ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
go
SET ANSI_PADDING ON
go
CREATE NONCLUSTERED INDEX IX_Org_tb_IndustrySector ON Org.tbOrg
(
	IndustrySector ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
go
CREATE NONCLUSTERED INDEX IX_Org_tb_OrganisationStatusCode ON Org.tbOrg
(
	OrganisationStatusCode ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
go
SET ANSI_PADDING ON
go
CREATE UNIQUE NONCLUSTERED INDEX IX_Org_tb_Status_AccountCode ON Org.tbOrg
(
	OrganisationStatusCode ASC,
	AccountName ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
go
CREATE NONCLUSTERED INDEX IX_Org_tb_OrganisationTypeCode ON Org.tbOrg
(
	OrganisationTypeCode ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
go
SET ANSI_PADDING ON
go
CREATE NONCLUSTERED INDEX IX_Org_tb_PaymentTerms ON Org.tbOrg
(
	PaymentTerms ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
go
SET ANSI_PADDING ON
go
CREATE NONCLUSTERED INDEX IX_Org_tbOrg_OpeningBalance ON Org.tbOrg
(
	AccountCode ASC
)
INCLUDE ( 	OpeningBalance) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
go
SET ANSI_PADDING ON
go
CREATE NONCLUSTERED INDEX IX_tbOrg_tb_AccountCode ON Org.tbOrg
(
	AccountCode ASC
)
INCLUDE ( 	AccountName) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
go
SET ANSI_PADDING ON
go
CREATE NONCLUSTERED INDEX IX_tbPayment_TaxCode ON Org.tbPayment
(
	TaxCode ASC
)
INCLUDE ( 	PaidInValue,
	PaidOutValue) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
go
SET ANSI_PADDING ON
go
CREATE NONCLUSTERED INDEX IX_Org_tbPayment ON Org.tbPayment
(
	PaymentReference ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
go
SET ANSI_PADDING ON
go
CREATE NONCLUSTERED INDEX IX_Org_tbPayment_AccountCode ON Org.tbPayment
(
	AccountCode ASC,
	PaidOn DESC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
go
SET ANSI_PADDING ON
go
CREATE NONCLUSTERED INDEX IX_Org_tbPayment_CashAccountCode ON Org.tbPayment
(
	CashAccountCode ASC,
	PaidOn ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
go
SET ANSI_PADDING ON
go
CREATE NONCLUSTERED INDEX IX_Org_tbPayment_CashCode ON Org.tbPayment
(
	CashCode ASC,
	PaidOn ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
go
SET ANSI_PADDING ON
go
CREATE NONCLUSTERED INDEX IX_Org_tbPayment_PaymentCode_Status ON Org.tbPayment
(
	AccountCode ASC,
	PaymentStatusCode ASC,
	PaymentCode ASC
)
INCLUDE ( 	PaidInValue,
	PaidOutValue) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
go
SET ANSI_PADDING ON
go
CREATE NONCLUSTERED INDEX IX_Org_tbPayment_PaymentCode_TaxCode ON Org.tbPayment
(
	AccountCode ASC,
	PaymentCode ASC,
	TaxCode ASC
)
INCLUDE ( 	PaymentStatusCode,
	PaidInValue,
	PaidOutValue) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
go
SET ANSI_PADDING ON
go
CREATE NONCLUSTERED INDEX IX_Org_tbPayment_Status ON Org.tbPayment
(
	PaymentStatusCode ASC
)
INCLUDE ( 	CashAccountCode,
	CashCode,
	PaidOn,
	PaidInValue,
	PaidOutValue) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
go
SET ANSI_PADDING ON
go
CREATE NONCLUSTERED INDEX IX_Org_tbPayment_Status_AccountCode ON Org.tbPayment
(
	PaymentStatusCode ASC,
	AccountCode ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
go
SET ANSI_PADDING ON
go
CREATE NONCLUSTERED INDEX IX_Org_tbPayment_Status_CashAccount_PaidOn ON Org.tbPayment
(
	PaymentStatusCode ASC,
	CashAccountCode ASC,
	PaidOn ASC
)
INCLUDE ( 	PaymentCode,
	PaidInValue,
	PaidOutValue) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
go
SET ANSI_PADDING ON
go
CREATE NONCLUSTERED INDEX IX_Org_tbSector_IndustrySector ON Org.tbSector
(
	IndustrySector ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
go
SET ANSI_PADDING ON
go
CREATE NONCLUSTERED INDEX IX_Task_tbAttribute ON Task.tbAttribute
(
	TaskCode ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
go
SET ANSI_PADDING ON
go
CREATE NONCLUSTERED INDEX IX_Task_tbAttribute_Description ON Task.tbAttribute
(
	Attribute ASC,
	AttributeDescription ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
go
SET ANSI_PADDING ON
go
CREATE NONCLUSTERED INDEX IX_Task_tbAttribute_OrderBy ON Task.tbAttribute
(
	TaskCode ASC,
	PrintOrder ASC,
	Attribute ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
go
SET ANSI_PADDING ON
go
CREATE NONCLUSTERED INDEX IX_Task_tbAttribute_Type_OrderBy ON Task.tbAttribute
(
	TaskCode ASC,
	AttributeTypeCode ASC,
	PrintOrder ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
go
SET ANSI_PADDING ON
go
CREATE UNIQUE NONCLUSTERED INDEX IX_Task_tbFlow_ChildParent ON Task.tbFlow
(
	ChildTaskCode ASC,
	ParentTaskCode ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
go
SET ANSI_PADDING ON
go
CREATE UNIQUE NONCLUSTERED INDEX IX_Task_tbFlow_ParentChild ON Task.tbFlow
(
	ParentTaskCode ASC,
	ChildTaskCode ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
go
CREATE NONCLUSTERED INDEX IX_Task_tbOp_OpStatusCode ON Task.tbOp
(
	OpStatusCode ASC,
	StartOn ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
go
SET ANSI_PADDING ON
go
CREATE NONCLUSTERED INDEX IX_Task_tbOp_UserIdOpStatus ON Task.tbOp
(
	UserId ASC,
	OpStatusCode ASC,
	StartOn ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
go
SET ANSI_PADDING ON
go
CREATE UNIQUE NONCLUSTERED INDEX IX_Task_tbStatus_TaskStatus ON Task.tbStatus
(
	TaskStatus ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
go
SET ANSI_PADDING ON
go
CREATE NONCLUSTERED INDEX IX_Task_tb_AccountCode ON Task.tbTask
(
	AccountCode ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
go
SET ANSI_PADDING ON
go
CREATE NONCLUSTERED INDEX IX_Task_tb_AccountCodeByActionOn ON Task.tbTask
(
	AccountCode ASC,
	ActionOn ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
go
SET ANSI_PADDING ON
go
CREATE NONCLUSTERED INDEX IX_Task_tb_AccountCodeByStatus ON Task.tbTask
(
	AccountCode ASC,
	TaskStatusCode ASC,
	ActionOn ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
go
SET ANSI_PADDING ON
go
CREATE NONCLUSTERED INDEX IX_Task_tb_ActionBy ON Task.tbTask
(
	ActionById ASC,
	TaskStatusCode ASC,
	ActionOn ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
go
SET ANSI_PADDING ON
go
CREATE NONCLUSTERED INDEX IX_Task_tb_ActionById ON Task.tbTask
(
	ActionById ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
go
CREATE NONCLUSTERED INDEX IX_Task_tb_ActionOn ON Task.tbTask
(
	ActionOn DESC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
go
SET ANSI_PADDING ON
go
CREATE NONCLUSTERED INDEX IX_Task_tb_ActionOnStatus ON Task.tbTask
(
	TaskStatusCode ASC,
	ActionOn ASC,
	AccountCode ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
go
SET ANSI_PADDING ON
go
CREATE NONCLUSTERED INDEX IX_Task_tb_ActivityCode ON Task.tbTask
(
	ActivityCode ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
go
SET ANSI_PADDING ON
go
CREATE NONCLUSTERED INDEX IX_Task_tb_ActivityCodeTaskTitle ON Task.tbTask
(
	ActivityCode ASC,
	TaskTitle ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
go
SET ANSI_PADDING ON
go
CREATE NONCLUSTERED INDEX IX_Task_tb_ActivityStatusCode ON Task.tbTask
(
	TaskStatusCode ASC,
	ActionOn ASC,
	AccountCode ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
go
SET ANSI_PADDING ON
go
CREATE NONCLUSTERED INDEX IX_Task_tb_CashCode ON Task.tbTask
(
	CashCode ASC,
	TaskStatusCode ASC,
	ActionOn ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
go
CREATE NONCLUSTERED INDEX IX_Task_tb_TaskStatusCode ON Task.tbTask
(
	TaskStatusCode ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
go
SET ANSI_PADDING ON
go
CREATE NONCLUSTERED INDEX IX_Task_tb_UserId ON Task.tbTask
(
	UserId ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
go
SET ANSI_PADDING ON
go
CREATE NONCLUSTERED INDEX IX_Task_tbTask_ActionOn_Status_CashCode ON Task.tbTask
(
	ActionOn ASC,
	TaskStatusCode ASC,
	CashCode ASC,
	TaskCode ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
go
SET ANSI_PADDING ON
go
CREATE NONCLUSTERED INDEX IX_Task_tbTask_ActionOn_TaskCode_CashCode ON Task.tbTask
(
	ActionOn ASC,
	TaskCode ASC,
	CashCode ASC,
	TaskStatusCode ASC,
	AccountCode ASC
)
INCLUDE ( 	TaskTitle,
	ActivityCode,
	ActionedOn,
	Quantity,
	UnitCharge,
	TotalCharge,
	PaymentOn) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
go
SET ANSI_PADDING ON
go
CREATE NONCLUSTERED INDEX IX_Task_tbTask_Status_TaxCode_TaskCode ON Task.tbTask
(
	TaskStatusCode ASC,
	TaxCode ASC,
	TaskCode ASC,
	CashCode ASC,
	ActionOn ASC
)
INCLUDE ( 	TotalCharge) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
go
SET ANSI_PADDING ON
go
CREATE NONCLUSTERED INDEX IX_Task_tbTask_TaskCode_CashCode ON Task.tbTask
(
	TaskCode ASC,
	CashCode ASC
)
INCLUDE ( 	Quantity,
	UnitCharge) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
go
SET ANSI_PADDING ON
go
CREATE NONCLUSTERED INDEX IX_Task_tbTask_TaskCode_TaxCode_CashCode ON Task.tbTask
(
	TaskCode ASC,
	TaxCode ASC,
	CashCode ASC,
	ActionOn ASC
)
INCLUDE ( 	TotalCharge) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
go
CREATE NONCLUSTERED INDEX IX_Usr_tbMenuEntry_Command ON Usr.tbMenuEntry
(
	Command ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
go
CREATE NONCLUSTERED INDEX IX_Usr_tbMenuEntry_OpenMode ON Usr.tbMenuEntry
(
	OpenMode ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
go
SET ANSI_PADDING ON
go
CREATE UNIQUE NONCLUSTERED INDEX IX_Usr_tbUser_IsEnabled_LogonName ON Usr.tbUser
(
	IsEnabled ASC,
	LogonName ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
go
SET ANSI_PADDING ON
go
CREATE UNIQUE NONCLUSTERED INDEX IX_Usr_tbUser_IsEnabled_UserName ON Usr.tbUser
(
	IsEnabled ASC,
	UserName ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
go
SET ANSI_PADDING ON
go
CREATE UNIQUE NONCLUSTERED INDEX IX_Usr_tbUser_LogonName ON Usr.tbUser
(
	LogonName ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
go
SET ANSI_PADDING ON
go
CREATE UNIQUE NONCLUSTERED INDEX IX_Usr_tbUser_UserName ON Usr.tbUser
(
	UserName ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
go
ALTER TABLE Activity.tbActivity ADD  CONSTRAINT DF_Activity_tbActivity_TaskStatusCode  DEFAULT ((1)) FOR TaskStatusCode
go
ALTER TABLE Activity.tbActivity ADD  CONSTRAINT DF_Activity_tbActivity_UnitCharge  DEFAULT ((0)) FOR UnitCharge
go
ALTER TABLE Activity.tbActivity ADD  CONSTRAINT DF_Activity_tbActivity_Printed  DEFAULT ((0)) FOR Printed
go
ALTER TABLE Activity.tbActivity ADD  CONSTRAINT DF_Activity_tbActivity_InsertedBy  DEFAULT (suser_sname()) FOR InsertedBy
go
ALTER TABLE Activity.tbActivity ADD  CONSTRAINT DF_Activity_tbActivity_InsertedOn  DEFAULT (getdate()) FOR InsertedOn
go
ALTER TABLE Activity.tbActivity ADD  CONSTRAINT DF_Activity_tbActivity_UpdatedBy  DEFAULT (suser_sname()) FOR UpdatedBy
go
ALTER TABLE Activity.tbActivity ADD  CONSTRAINT DF_Activity_tbActivity_UpdatedOn  DEFAULT (getdate()) FOR UpdatedOn
go
ALTER TABLE Activity.tbAttribute ADD  CONSTRAINT DF_Activity_tbAttribute_OrderBy  DEFAULT ((10)) FOR PrintOrder
go
ALTER TABLE Activity.tbAttribute ADD  CONSTRAINT DF_Activity_tbAttribute_AttributeTypeCode  DEFAULT ((0)) FOR AttributeTypeCode
go
ALTER TABLE Activity.tbAttribute ADD  CONSTRAINT DF_tbTemplateAttribute_InsertedBy  DEFAULT (suser_sname()) FOR InsertedBy
go
ALTER TABLE Activity.tbAttribute ADD  CONSTRAINT DF_tbTemplateAttribute_InsertedOn  DEFAULT (getdate()) FOR InsertedOn
go
ALTER TABLE Activity.tbAttribute ADD  CONSTRAINT DF_tbTemplateAttribute_UpdatedBy  DEFAULT (suser_sname()) FOR UpdatedBy
go
ALTER TABLE Activity.tbAttribute ADD  CONSTRAINT DF_tbTemplateAttribute_UpdatedOn  DEFAULT (getdate()) FOR UpdatedOn
go
ALTER TABLE Activity.tbFlow ADD  CONSTRAINT DF_Activity_tbFlow_StepNumber  DEFAULT ((10)) FOR StepNumber
go
ALTER TABLE Activity.tbFlow ADD CONSTRAINT DF_Activity_tbFlow_SyncTypeCode DEFAULT (0) FOR SyncTypeCode;
go
ALTER TABLE Activity.tbFlow ADD  CONSTRAINT DF_Activity_tbFlow_OffsetDays  DEFAULT ((0)) FOR OffsetDays
go
ALTER TABLE Activity.tbFlow ADD  CONSTRAINT DF_Activity_tbCodeFlow_Quantity  DEFAULT ((0)) FOR UsedOnQuantity
go
ALTER TABLE Activity.tbFlow ADD  CONSTRAINT DF_tbTemplateActivity_InsertedBy  DEFAULT (suser_sname()) FOR InsertedBy
go
ALTER TABLE Activity.tbFlow ADD  CONSTRAINT DF_tbTemplateActivity_InsertedOn  DEFAULT (getdate()) FOR InsertedOn
go
ALTER TABLE Activity.tbFlow ADD  CONSTRAINT DF_tbTemplateActivity_UpdatedBy  DEFAULT (suser_sname()) FOR UpdatedBy
go
ALTER TABLE Activity.tbFlow ADD  CONSTRAINT DF_tbTemplateActivity_UpdatedOn  DEFAULT (getdate()) FOR UpdatedOn
go
ALTER TABLE Activity.tbOp ADD  CONSTRAINT DF_Activity_tbOp_OperationNumber  DEFAULT ((0)) FOR OperationNumber
go
ALTER TABLE Activity.tbOp ADD  CONSTRAINT DF_Activity_tbOp_SyncTypeCode  DEFAULT ((1)) FOR SyncTypeCode
go
ALTER TABLE Activity.tbOp ADD  CONSTRAINT DF_Activity_tbOp_Duration  DEFAULT ((0)) FOR Duration
go
ALTER TABLE Activity.tbOp ADD  CONSTRAINT DF_Activity_tbOp_OffsetDays  DEFAULT ((0)) FOR OffsetDays
go
ALTER TABLE Activity.tbOp ADD  CONSTRAINT DF_Activity_tbOp_InsertedBy  DEFAULT (suser_sname()) FOR InsertedBy
go
ALTER TABLE Activity.tbOp ADD  CONSTRAINT DF_Activity_tbOp_InsertedOn  DEFAULT (getdate()) FOR InsertedOn
go
ALTER TABLE Activity.tbOp ADD  CONSTRAINT DF_Activity_tbOp_UpdatedBy  DEFAULT (suser_sname()) FOR UpdatedBy
go
ALTER TABLE Activity.tbOp ADD  CONSTRAINT DF_Activity_tbOp_UpdatedOn  DEFAULT (getdate()) FOR UpdatedOn
go
ALTER TABLE App.tbCalendar ADD  CONSTRAINT DF_App_tbCalendar_Monday  DEFAULT ((1)) FOR Monday
go
ALTER TABLE App.tbCalendar ADD  CONSTRAINT DF_App_tbCalendar_Tuesday  DEFAULT ((1)) FOR Tuesday
go
ALTER TABLE App.tbCalendar ADD  CONSTRAINT DF_App_tbCalendar_Wednesday  DEFAULT ((1)) FOR Wednesday
go
ALTER TABLE App.tbCalendar ADD  CONSTRAINT DF_App_tbCalendar_Thursday  DEFAULT ((1)) FOR Thursday
go
ALTER TABLE App.tbCalendar ADD  CONSTRAINT DF_App_tbCalendar_Friday  DEFAULT ((1)) FOR Friday
go
ALTER TABLE App.tbCalendar ADD  CONSTRAINT DF_App_tbCalendar_Saturday  DEFAULT ((0)) FOR Saturday
go
ALTER TABLE App.tbCalendar ADD  CONSTRAINT DF_App_tbCalendar_Sunday  DEFAULT ((0)) FOR Sunday
go
ALTER TABLE App.tbDoc ADD  CONSTRAINT DF_App_tbDoc_OpenMode  DEFAULT ((1)) FOR OpenMode
go
ALTER TABLE App.tbDocSpool ADD  CONSTRAINT DF_App_tbDocSpool_UserName  DEFAULT (suser_sname()) FOR UserName
go
ALTER TABLE App.tbDocSpool ADD  CONSTRAINT DF_App_tbDocSpool_DocTypeCode  DEFAULT ((1)) FOR DocTypeCode
go
ALTER TABLE App.tbDocSpool ADD  CONSTRAINT DF_App_tbDocSpool_SpooledOn  DEFAULT (getdate()) FOR SpooledOn
go
ALTER TABLE App.tbDocType ADD  CONSTRAINT DF_App_tbDocType_DocClassCode  DEFAULT ((0)) FOR DocClassCode
go
ALTER TABLE App.tbEventLog ADD  CONSTRAINT DF_App_tbLog_LoggedOn  DEFAULT (getdate()) FOR LoggedOn
go
ALTER TABLE App.tbEventLog ADD  CONSTRAINT DF_App_tbLog_EventTypeCode  DEFAULT ((2)) FOR EventTypeCode
go
ALTER TABLE App.tbEventLog ADD  CONSTRAINT DF_App_tbLog_InsertedBy  DEFAULT (suser_sname()) FOR InsertedBy
go
ALTER TABLE App.tbOptions ADD  CONSTRAINT DF_App_tbOptions_IsIntialised  DEFAULT ((0)) FOR IsInitialised
go
ALTER TABLE App.tbOptions ADD  CONSTRAINT DF_App_tbOptions_DefaultPrintMode  DEFAULT ((2)) FOR DefaultPrintMode
go
ALTER TABLE App.tbOptions ADD  CONSTRAINT DF_App_tbOptions_BucketTypeCode  DEFAULT ((1)) FOR BucketTypeCode
go
ALTER TABLE App.tbOptions ADD  CONSTRAINT DF_App_tbOptions_BucketIntervalCode  DEFAULT ((1)) FOR BucketIntervalCode
go
ALTER TABLE App.tbOptions ADD  CONSTRAINT DF_App_tbOptions_TaxHorizon  DEFAULT ((90)) FOR TaxHorizon
go
ALTER TABLE App.tbOptions ADD  CONSTRAINT DF_App_tbOptions_IsAutoOffsetDays DEFAULT ((0)) FOR IsAutoOffsetDays
go
ALTER TABLE App.tbOptions ADD  CONSTRAINT DF_App_tbOptions_InsertedBy  DEFAULT (suser_sname()) FOR InsertedBy
go
ALTER TABLE App.tbOptions ADD  CONSTRAINT DF_App_tbOptions_InsertedOn  DEFAULT (getdate()) FOR InsertedOn
go
ALTER TABLE App.tbOptions ADD  CONSTRAINT DF_App_tbOptions_UpdatedBy  DEFAULT (suser_sname()) FOR UpdatedBy
go
ALTER TABLE App.tbOptions ADD  CONSTRAINT DF_App_tbOptions_UpdatedOn  DEFAULT (getdate()) FOR UpdatedOn
go
ALTER TABLE App.tbRegister ADD  CONSTRAINT DF_App_tbRegister_NextNumber  DEFAULT ((1)) FOR NextNumber
go
ALTER TABLE App.tbTaxCode ADD  CONSTRAINT DF_App_tbTaxCode_VatRate  DEFAULT ((0)) FOR TaxRate
go
ALTER TABLE App.tbTaxCode ADD  CONSTRAINT DF_App_tbTaxCode_TaxTypeCode  DEFAULT ((2)) FOR TaxTypeCode
go
ALTER TABLE App.tbTaxCode ADD  CONSTRAINT DF_App_tbTaxCode_UpdatedBy  DEFAULT (suser_sname()) FOR UpdatedBy
go
ALTER TABLE App.tbTaxCode ADD  CONSTRAINT DF_App_tbTaxCode_UpdatedOn  DEFAULT (getdate()) FOR UpdatedOn
go
ALTER TABLE App.tbTaxCode ADD  CONSTRAINT DF_tbTaxCode_RoundingCode  DEFAULT ((0)) FOR RoundingCode
go
ALTER TABLE App.tbYear ADD  CONSTRAINT DF_App_tbYear_StartMonth  DEFAULT ((1)) FOR StartMonth
go
ALTER TABLE App.tbYear ADD  CONSTRAINT DF_App_tbYear_CashStatusCode  DEFAULT ((1)) FOR CashStatusCode
go
ALTER TABLE App.tbYear ADD  CONSTRAINT DF_App_tbYear_InsertedBy  DEFAULT (suser_sname()) FOR InsertedBy
go
ALTER TABLE App.tbYear ADD  CONSTRAINT DF_App_tbYear_InsertedOn  DEFAULT (getdate()) FOR InsertedOn
go
ALTER TABLE App.tbYearPeriod ADD  CONSTRAINT DF_App_tbYearPeriod_CashStatusCode  DEFAULT ((1)) FOR CashStatusCode
go
ALTER TABLE App.tbYearPeriod ADD  CONSTRAINT DF_App_tbYearPeriod_InsertedBy  DEFAULT (suser_sname()) FOR InsertedBy
go
ALTER TABLE App.tbYearPeriod ADD  CONSTRAINT DF_App_tbYearPeriod_InsertedOn  DEFAULT (getdate()) FOR InsertedOn
go
ALTER TABLE App.tbYearPeriod ADD  CONSTRAINT DF_App_tbYearPeriod_CorporationTaxRate  DEFAULT ((0)) FOR CorporationTaxRate
go
ALTER TABLE App.tbYearPeriod ADD  CONSTRAINT DF_App_tbYearPeriod_TaxAdjustment  DEFAULT ((0)) FOR TaxAdjustment
go
ALTER TABLE App.tbYearPeriod ADD  CONSTRAINT DF_App_tbYearPeriod_VatAdjustment  DEFAULT ((0)) FOR VatAdjustment
go
ALTER TABLE Cash.tbCategory ADD  CONSTRAINT DF_Cash_tbCategory_CategoryTypeCode  DEFAULT ((1)) FOR CategoryTypeCode
go
ALTER TABLE Cash.tbCategory ADD  CONSTRAINT DF_Cash_tbCategory_CashModeCode  DEFAULT ((1)) FOR CashModeCode
go
ALTER TABLE Cash.tbCategory ADD  CONSTRAINT DF_Cash_tbCategory_CashTypeCode  DEFAULT ((0)) FOR CashTypeCode
go
ALTER TABLE Cash.tbCategory ADD  CONSTRAINT DF_Cash_tbCategory_DisplayOrder  DEFAULT ((0)) FOR DisplayOrder
go
ALTER TABLE Cash.tbCategory ADD  CONSTRAINT DF_Cash_tbCategory_IsEnabled  DEFAULT ((1)) FOR IsEnabled
go
ALTER TABLE Cash.tbCategory ADD  CONSTRAINT DF_Cash_tbCategory_InsertedBy  DEFAULT (suser_sname()) FOR InsertedBy
go
ALTER TABLE Cash.tbCategory ADD  CONSTRAINT DF_Cash_tbCategory_InsertedOn  DEFAULT (getdate()) FOR InsertedOn
go
ALTER TABLE Cash.tbCategory ADD  CONSTRAINT DF_Cash_tbCategory_UpdatedBy  DEFAULT (suser_sname()) FOR UpdatedBy
go
ALTER TABLE Cash.tbCategory ADD  CONSTRAINT DF_Cash_tbCategory_UpdatedOn  DEFAULT (getdate()) FOR UpdatedOn
go
ALTER TABLE Cash.tbCode ADD  CONSTRAINT DF_Cash_tbCode_OpeningBalance  DEFAULT ((0)) FOR OpeningBalance
go
ALTER TABLE Cash.tbCode ADD  CONSTRAINT DF_Cash_tbCode_IsEnabled  DEFAULT ((1)) FOR IsEnabled
go
ALTER TABLE Cash.tbCode ADD  CONSTRAINT DF_Cash_tbCode_InsertedBy  DEFAULT (suser_sname()) FOR InsertedBy
go
ALTER TABLE Cash.tbCode ADD  CONSTRAINT DF_Cash_tbCode_InsertedOn  DEFAULT (getdate()) FOR InsertedOn
go
ALTER TABLE Cash.tbCode ADD  CONSTRAINT DF_Cash_tbCode_UpdatedBy  DEFAULT (suser_sname()) FOR UpdatedBy
go
ALTER TABLE Cash.tbCode ADD  CONSTRAINT DF_Cash_tbCode_UpdatedOn  DEFAULT (getdate()) FOR UpdatedOn
go
ALTER TABLE Cash.tbPeriod ADD  CONSTRAINT DF_Cash_tbPeriod_ForecastValue  DEFAULT ((0)) FOR ForecastValue
go
ALTER TABLE Cash.tbPeriod ADD  CONSTRAINT DF_Cash_tbPeriod_ForecastTax  DEFAULT ((0)) FOR ForecastTax
go
ALTER TABLE Cash.tbPeriod ADD  CONSTRAINT DF_Cash_tbPeriod_InvoiceValue  DEFAULT ((0)) FOR InvoiceValue
go
ALTER TABLE Cash.tbPeriod ADD  CONSTRAINT DF_Cash_tbPeriod_InvoiceTax  DEFAULT ((0)) FOR InvoiceTax
go
ALTER TABLE Cash.tbTaxType ADD  CONSTRAINT DF_App_tbOptions_MonthNumber  DEFAULT ((1)) FOR MonthNumber
go
ALTER TABLE Cash.tbTaxType ADD  CONSTRAINT DF_App_tbOptions_Recurrence  DEFAULT ((1)) FOR RecurrenceCode
go
ALTER TABLE Cash.tbTaxType ADD  CONSTRAINT DF_Cash_tbTaxType_OffsetDays  DEFAULT ((0)) FOR OffsetDays
go
ALTER TABLE Invoice.tbInvoice ADD  CONSTRAINT DF_Invoice_tb_InvoicedOn  DEFAULT (CONVERT(date,getdate())) FOR InvoicedOn
go
ALTER TABLE Invoice.tbInvoice ADD  CONSTRAINT DF_Invoice_tbInvoice_ExpectedOn  DEFAULT (dateadd(day,(1),CONVERT(date,getdate()))) FOR ExpectedOn
go
ALTER TABLE Invoice.tbInvoice ADD  CONSTRAINT DF_Invoice_tbInvoice_DueOn  DEFAULT (dateadd(day,(1),CONVERT(date,getdate()))) FOR DueOn
go
ALTER TABLE Invoice.tbInvoice ADD  CONSTRAINT DF_Invoice_tb_InvoiceValue  DEFAULT ((0)) FOR InvoiceValue
go
ALTER TABLE Invoice.tbInvoice ADD  CONSTRAINT DF_Invoice_tb_TaxValue  DEFAULT ((0)) FOR TaxValue
go
ALTER TABLE Invoice.tbInvoice ADD  CONSTRAINT DF_Invoice_tb_PaidValue  DEFAULT ((0)) FOR PaidValue
go
ALTER TABLE Invoice.tbInvoice ADD  CONSTRAINT DF_Invoice_tb_PaidTaxValue  DEFAULT ((0)) FOR PaidTaxValue
go
ALTER TABLE Invoice.tbInvoice ADD  CONSTRAINT DF_Invoice_tb_Printed  DEFAULT ((0)) FOR Printed
go
ALTER TABLE Invoice.tbInvoice ADD  CONSTRAINT DF_Invoice_tb_Spooled  DEFAULT ((0)) FOR Spooled
go
ALTER TABLE Invoice.tbItem ADD  CONSTRAINT DF_Invoice_tbItem_TotalValue  DEFAULT ((0)) FOR TotalValue
go
ALTER TABLE Invoice.tbItem ADD  CONSTRAINT DF_Invoice_tbItem_InvoiceValue  DEFAULT ((0)) FOR InvoiceValue
go
ALTER TABLE Invoice.tbItem ADD  CONSTRAINT DF_Invoice_tbItem_TaxValue  DEFAULT ((0)) FOR TaxValue
go
ALTER TABLE Invoice.tbItem ADD  CONSTRAINT DF_Invoice_tbItem_PaidValue  DEFAULT ((0)) FOR PaidValue
go
ALTER TABLE Invoice.tbItem ADD  CONSTRAINT DF_Invoice_tbItem_PaidTaxValue  DEFAULT ((0)) FOR PaidTaxValue
go
ALTER TABLE Invoice.tbTask ADD  CONSTRAINT DF_Invoice_tbTask_Quantity  DEFAULT ((0)) FOR Quantity
go
ALTER TABLE Invoice.tbTask ADD  CONSTRAINT DF_Invoice_tbTask_TotalValue  DEFAULT ((0)) FOR TotalValue
go
ALTER TABLE Invoice.tbTask ADD  CONSTRAINT DF_Invoice_tbActivity_InvoiceValue  DEFAULT ((0)) FOR InvoiceValue
go
ALTER TABLE Invoice.tbTask ADD  CONSTRAINT DF_Invoice_tbActivity_TaxValue  DEFAULT ((0)) FOR TaxValue
go
ALTER TABLE Invoice.tbTask ADD  CONSTRAINT DF_Invoice_tbTask_PaidValue  DEFAULT ((0)) FOR PaidValue
go
ALTER TABLE Invoice.tbTask ADD  CONSTRAINT DF_Invoice_tbTask_PaidTaxValue  DEFAULT ((0)) FOR PaidTaxValue
go
ALTER TABLE Invoice.tbType ADD  CONSTRAINT DF_Invoice_tbType_NextNumber  DEFAULT ((1000)) FOR NextNumber
go
ALTER TABLE Org.tbAccount ADD  CONSTRAINT DF_Org_tbAccount_OpeningBalance  DEFAULT ((0)) FOR OpeningBalance
go
ALTER TABLE Org.tbAccount ADD  CONSTRAINT DF_Org_tbAccount_CurrentBalance  DEFAULT ((0)) FOR CurrentBalance
go
ALTER TABLE Org.tbAccount ADD  CONSTRAINT DF_Org_tbAccount_AccountClosed  DEFAULT ((0)) FOR AccountClosed
go
ALTER TABLE Org.tbAccount ADD  CONSTRAINT DF_Org_tbAccount_IsDummyAccount  DEFAULT ((0)) FOR DummyAccount
go
ALTER TABLE Org.tbAccount ADD  CONSTRAINT DF_Org_tbAccount_InsertedBy  DEFAULT (suser_sname()) FOR InsertedBy
go
ALTER TABLE Org.tbAccount ADD  CONSTRAINT DF_Org_tbAccount_InsertedOn  DEFAULT (getdate()) FOR InsertedOn
go
ALTER TABLE Org.tbAccount ADD  CONSTRAINT DF_Org_tbAccount_UpdatedBy  DEFAULT (suser_sname()) FOR UpdatedBy
go
ALTER TABLE Org.tbAccount ADD  CONSTRAINT DF_Org_tbAccount_UpdatedOn  DEFAULT (getdate()) FOR UpdatedOn
go
ALTER TABLE Org.tbAddress ADD  CONSTRAINT DF_Org_tbAddress_InsertedBy  DEFAULT (suser_sname()) FOR InsertedBy
go
ALTER TABLE Org.tbAddress ADD  CONSTRAINT DF_Org_tbAddress_InsertedOn  DEFAULT (getdate()) FOR InsertedOn
go
ALTER TABLE Org.tbAddress ADD  CONSTRAINT DF_Org_tbAddress_UpdatedBy  DEFAULT (suser_sname()) FOR UpdatedBy
go
ALTER TABLE Org.tbAddress ADD  CONSTRAINT DF_Org_tbAddress_UpdatedOn  DEFAULT (getdate()) FOR UpdatedOn
go
ALTER TABLE Org.tbContact ADD  CONSTRAINT DF_Org_tbContact_OnMailingList  DEFAULT ((1)) FOR OnMailingList
go
ALTER TABLE Org.tbContact ADD  CONSTRAINT DF_Org_tbContact_InsertedBy  DEFAULT (suser_sname()) FOR InsertedBy
go
ALTER TABLE Org.tbContact ADD  CONSTRAINT DF_Org_tbContact_InsertedOn  DEFAULT (getdate()) FOR InsertedOn
go
ALTER TABLE Org.tbContact ADD  CONSTRAINT DF_Org_tbContact_UpdatedBy  DEFAULT (suser_sname()) FOR UpdatedBy
go
ALTER TABLE Org.tbContact ADD  CONSTRAINT DF_Org_tbContact_UpdatedOn  DEFAULT (getdate()) FOR UpdatedOn
go
ALTER TABLE Org.tbDoc ADD  CONSTRAINT DF_Org_tbDoc_InsertedBy  DEFAULT (suser_sname()) FOR InsertedBy
go
ALTER TABLE Org.tbDoc ADD  CONSTRAINT DF_Org_tbDoc_InsertedOn  DEFAULT (getdate()) FOR InsertedOn
go
ALTER TABLE Org.tbDoc ADD  CONSTRAINT DF_Org_tbDoc_UpdatedBy  DEFAULT (suser_sname()) FOR UpdatedBy
go
ALTER TABLE Org.tbDoc ADD  CONSTRAINT DF_Org_tbDoc_UpdatedOn  DEFAULT (getdate()) FOR UpdatedOn
go
ALTER TABLE Org.tbOrg ADD  CONSTRAINT DF_Org_tb_OrganisationTypeCode  DEFAULT ((1)) FOR OrganisationTypeCode
go
ALTER TABLE Org.tbOrg ADD  CONSTRAINT DF_Org_tb_OrganisationStatusCode  DEFAULT ((1)) FOR OrganisationStatusCode
go
ALTER TABLE Org.tbOrg ADD  CONSTRAINT DF_Org_tbOrg_ExpectedDays  DEFAULT ((0)) FOR ExpectedDays
go
ALTER TABLE Org.tbOrg ADD  CONSTRAINT DF_Org_tb_PaymentDays  DEFAULT ((0)) FOR PaymentDays
go
ALTER TABLE Org.tbOrg ADD  CONSTRAINT DF_Org_tb_PayDaysFromMonthEnd  DEFAULT ((0)) FOR PayDaysFromMonthEnd
go
ALTER TABLE Org.tbOrg ADD  CONSTRAINT DF_Org_tbOrg_PayBalance  DEFAULT ((1)) FOR PayBalance
go
ALTER TABLE Org.tbOrg ADD  CONSTRAINT DF_Org_tb_NumberOfEmployees  DEFAULT ((0)) FOR NumberOfEmployees
go
ALTER TABLE Org.tbOrg ADD  CONSTRAINT DF_Org_tb_Turnover  DEFAULT ((0)) FOR Turnover
go
ALTER TABLE Org.tbOrg ADD  CONSTRAINT DF_Org_tb_OpeningBalance  DEFAULT ((0)) FOR OpeningBalance
go
ALTER TABLE Org.tbOrg ADD  CONSTRAINT DF_Org_tb_EUJurisdiction  DEFAULT ((0)) FOR EUJurisdiction
go
ALTER TABLE Org.tbOrg ADD  CONSTRAINT DF_Org_tb_InsertedBy  DEFAULT (suser_sname()) FOR InsertedBy
go
ALTER TABLE Org.tbOrg ADD  CONSTRAINT DF_Org_tb_InsertedOn  DEFAULT (getdate()) FOR InsertedOn
go
ALTER TABLE Org.tbOrg ADD  CONSTRAINT DF_Org_tb_UpdatedBy  DEFAULT (suser_sname()) FOR UpdatedBy
go
ALTER TABLE Org.tbOrg ADD  CONSTRAINT DF_Org_tb_UpdatedOn  DEFAULT (getdate()) FOR UpdatedOn
go
ALTER TABLE Org.tbPayment ADD  CONSTRAINT DF_Org_tbPayment_PaymentStatusCode  DEFAULT ((0)) FOR PaymentStatusCode
go
ALTER TABLE Org.tbPayment ADD  CONSTRAINT DF_Org_tbPayment_PaidOn  DEFAULT (CONVERT(date,getdate())) FOR PaidOn
go
ALTER TABLE Org.tbPayment ADD  CONSTRAINT DF_Org_tbPayment_PaidInValue  DEFAULT ((0)) FOR PaidInValue
go
ALTER TABLE Org.tbPayment ADD  CONSTRAINT DF_Org_tbPayment_PaidOutValue  DEFAULT ((0)) FOR PaidOutValue
go
ALTER TABLE Org.tbPayment ADD  CONSTRAINT DF_Org_tbPayment_TaxInValue  DEFAULT ((0)) FOR TaxInValue
go
ALTER TABLE Org.tbPayment ADD  CONSTRAINT DF_Org_tbPayment_TaxOutValue  DEFAULT ((0)) FOR TaxOutValue
go
ALTER TABLE Org.tbPayment ADD  CONSTRAINT DF_Org_tbPayment_InsertedBy  DEFAULT (suser_sname()) FOR InsertedBy
go
ALTER TABLE Org.tbPayment ADD  CONSTRAINT DF_Org_tbPayment_InsertedOn  DEFAULT (getdate()) FOR InsertedOn
go
ALTER TABLE Org.tbPayment ADD  CONSTRAINT DF_Org_tbPayment_UpdatedBy  DEFAULT (suser_sname()) FOR UpdatedBy
go
ALTER TABLE Org.tbPayment ADD  CONSTRAINT DF_Org_tbPayment_UpdatedOn  DEFAULT (getdate()) FOR UpdatedOn
go
ALTER TABLE Org.tbStatus ADD  CONSTRAINT DF_Org_tbStatus_OrganisationStatusCode  DEFAULT ((1)) FOR OrganisationStatusCode
go
ALTER TABLE Org.tbType ADD  CONSTRAINT DF_Org_tbType_OrganisationTypeCode  DEFAULT ((1)) FOR OrganisationTypeCode
go
ALTER TABLE Task.tbAttribute ADD  CONSTRAINT DF_Task_tbAttribute_OrderBy  DEFAULT ((10)) FOR PrintOrder
go
ALTER TABLE Task.tbAttribute ADD  CONSTRAINT DF_Task_tbAttribute_AttributeTypeCode  DEFAULT ((0)) FOR AttributeTypeCode
go
ALTER TABLE Task.tbAttribute ADD  CONSTRAINT DF_tbJobAttribute_InsertedBy  DEFAULT (suser_sname()) FOR InsertedBy
go
ALTER TABLE Task.tbAttribute ADD  CONSTRAINT DF_tbJobAttribute_InsertedOn  DEFAULT (getdate()) FOR InsertedOn
go
ALTER TABLE Task.tbAttribute ADD  CONSTRAINT DF_tbJobAttribute_UpdatedBy  DEFAULT (suser_sname()) FOR UpdatedBy
go
ALTER TABLE Task.tbAttribute ADD  CONSTRAINT DF_tbJobAttribute_UpdatedOn  DEFAULT (getdate()) FOR UpdatedOn
go
ALTER TABLE Task.tbDoc ADD  CONSTRAINT DF_Task_tbDoc_InsertedBy  DEFAULT (suser_sname()) FOR InsertedBy
go
ALTER TABLE Task.tbDoc ADD  CONSTRAINT DF_Task_tbDoc_InsertedOn  DEFAULT (getdate()) FOR InsertedOn
go
ALTER TABLE Task.tbDoc ADD  CONSTRAINT DF_Task_tbDoc_UpdatedBy  DEFAULT (suser_sname()) FOR UpdatedBy
go
ALTER TABLE Task.tbDoc ADD  CONSTRAINT DF_Task_tbDoc_UpdatedOn  DEFAULT (getdate()) FOR UpdatedOn
go
ALTER TABLE Task.tbFlow ADD  CONSTRAINT DF_Task_tbFlow_StepNumber  DEFAULT ((10)) FOR StepNumber
go
ALTER TABLE Task.tbFlow ADD  CONSTRAINT DF_Task_tbFlow_SyncTypeCode DEFAULT (0) FOR SyncTypeCode
go
ALTER TABLE Task.tbFlow ADD  CONSTRAINT DF_Task_tbFlow_UsedOnQuantity  DEFAULT ((0)) FOR UsedOnQuantity
go
ALTER TABLE Task.tbFlow ADD  CONSTRAINT DF_Task_tbFlow_OffsetDays  DEFAULT ((0)) FOR OffsetDays
go
ALTER TABLE Task.tbFlow ADD  CONSTRAINT DF_Task_tbFlow_InsertedBy  DEFAULT (suser_sname()) FOR InsertedBy
go
ALTER TABLE Task.tbFlow ADD  CONSTRAINT DF_Task_tbFlow_InsertedOn  DEFAULT (getdate()) FOR InsertedOn
go
ALTER TABLE Task.tbFlow ADD  CONSTRAINT DF_Task_tbFlow_UpdatedBy  DEFAULT (suser_sname()) FOR UpdatedBy
go
ALTER TABLE Task.tbFlow ADD  CONSTRAINT DF_Task_tbFlow_UpdatedOn  DEFAULT (getdate()) FOR UpdatedOn
go
ALTER TABLE Task.tbOp ADD  CONSTRAINT DF_Task_tbOp_SyncTypeCode  DEFAULT ((0)) FOR SyncTypeCode
go
ALTER TABLE Task.tbOp ADD  CONSTRAINT DF_Task_tbOp_OpStatusCode  DEFAULT ((0)) FOR OpStatusCode
go
ALTER TABLE Task.tbOp ADD  CONSTRAINT DF_Task_tbOp_StartOn  DEFAULT (getdate()) FOR StartOn
go
ALTER TABLE Task.tbOp ADD  CONSTRAINT DF_Task_tbOp_EndOn  DEFAULT (getdate()) FOR EndOn
go
ALTER TABLE Task.tbOp ADD  CONSTRAINT DF_Task_tbOp_Duration  DEFAULT ((0)) FOR Duration
go
ALTER TABLE Task.tbOp ADD  CONSTRAINT DF_Task_tbOp_OffsetDays  DEFAULT ((0)) FOR OffsetDays
go
ALTER TABLE Task.tbOp ADD  CONSTRAINT DF_Task_tbOp_InsertedBy  DEFAULT (suser_sname()) FOR InsertedBy
go
ALTER TABLE Task.tbOp ADD  CONSTRAINT DF_Task_tbOp_InsertedOn  DEFAULT (getdate()) FOR InsertedOn
go
ALTER TABLE Task.tbOp ADD  CONSTRAINT DF_Task_tbOp_UpdatedBy  DEFAULT (suser_sname()) FOR UpdatedBy
go
ALTER TABLE Task.tbOp ADD  CONSTRAINT DF_Task_tbOp_UpdatedOn  DEFAULT (getdate()) FOR UpdatedOn
go
ALTER TABLE Task.tbQuote ADD  CONSTRAINT DF_Task_tbQuote_Quantity  DEFAULT ((0)) FOR Quantity
go
ALTER TABLE Task.tbQuote ADD  CONSTRAINT DF_Task_tbQuote_TotalPrice  DEFAULT ((0)) FOR TotalPrice
go
ALTER TABLE Task.tbQuote ADD  CONSTRAINT DF_Task_tbQuote_RunOnQuantity  DEFAULT ((0)) FOR RunOnQuantity
go
ALTER TABLE Task.tbQuote ADD  CONSTRAINT DF_Task_tbQuote_RunOnPrice  DEFAULT ((0)) FOR RunOnPrice
go
ALTER TABLE Task.tbQuote ADD  CONSTRAINT DF_Task_tbQuote_RunBackQuantity  DEFAULT ((0)) FOR RunBackQuantity
go
ALTER TABLE Task.tbQuote ADD  CONSTRAINT DF_Task_tbQuote_RunBackPrice  DEFAULT ((0)) FOR RunBackPrice
go
ALTER TABLE Task.tbQuote ADD  CONSTRAINT DF_Task_tbQuote_InsertedBy  DEFAULT (suser_sname()) FOR InsertedBy
go
ALTER TABLE Task.tbQuote ADD  CONSTRAINT DF_Task_tbQuote_InsertedOn  DEFAULT (getdate()) FOR InsertedOn
go
ALTER TABLE Task.tbQuote ADD  CONSTRAINT DF_Task_tbQuote_UpdatedBy  DEFAULT (suser_sname()) FOR UpdatedBy
go
ALTER TABLE Task.tbQuote ADD  CONSTRAINT DF_Task_tbQuote_UpdatedOn  DEFAULT (getdate()) FOR UpdatedOn
go
ALTER TABLE Task.tbTask ADD  CONSTRAINT DF_Task_tbTask_ActionOn  DEFAULT (getdate()) FOR ActionOn
go
ALTER TABLE Task.tbTask ADD  CONSTRAINT DF_Task_tbTask_Quantity  DEFAULT ((0)) FOR Quantity
go
ALTER TABLE Task.tbTask ADD  CONSTRAINT DF_Task_tb_UnitCharge  DEFAULT ((0)) FOR UnitCharge
go
ALTER TABLE Task.tbTask ADD  CONSTRAINT DF_Task_tb_TotalCharge  DEFAULT ((0)) FOR TotalCharge
go
ALTER TABLE Task.tbTask ADD  CONSTRAINT DF_Task_tb_Printed  DEFAULT ((0)) FOR Printed
go
ALTER TABLE Task.tbTask ADD  CONSTRAINT DF_Task_tb_InsertedBy  DEFAULT (suser_sname()) FOR InsertedBy
go
ALTER TABLE Task.tbTask ADD  CONSTRAINT DF_Task_tb_InsertedOn  DEFAULT (getdate()) FOR InsertedOn
go
ALTER TABLE Task.tbTask ADD  CONSTRAINT DF_Task_tb_UpdatedBy  DEFAULT (suser_sname()) FOR UpdatedBy
go
ALTER TABLE Task.tbTask ADD  CONSTRAINT DF_Task_tb_UpdatedOn  DEFAULT (getdate()) FOR UpdatedOn
go
ALTER TABLE Task.tbTask ADD  CONSTRAINT DF_Task_tb_PaymentOn  DEFAULT (getdate()) FOR PaymentOn
go
ALTER TABLE Task.tbTask ADD  CONSTRAINT DF_Task_tb_Spooled  DEFAULT ((0)) FOR Spooled
go
ALTER TABLE Usr.tbMenu ADD  CONSTRAINT DF_Usr_tbMenu_InsertedOn  DEFAULT (getdate()) FOR InsertedOn
go
ALTER TABLE Usr.tbMenu ADD  CONSTRAINT DF_Usr_tbMenu_InsertedBy  DEFAULT (suser_sname()) FOR InsertedBy
go
ALTER TABLE Usr.tbMenuCommand ADD  CONSTRAINT DF_Usr_tbMenuCommand_Command  DEFAULT ((0)) FOR Command
go
ALTER TABLE Usr.tbMenuEntry ADD  CONSTRAINT DF_Usr_tbMenuEntry_MenuId  DEFAULT ((0)) FOR MenuId
go
ALTER TABLE Usr.tbMenuEntry ADD  CONSTRAINT DF_Usr_tbMenuEntry_FolderId  DEFAULT ((0)) FOR FolderId
go
ALTER TABLE Usr.tbMenuEntry ADD  CONSTRAINT DF_Usr_tbMenuEntry_ItemId  DEFAULT ((0)) FOR ItemId
go
ALTER TABLE Usr.tbMenuEntry ADD  CONSTRAINT DF_Usr_tbMenuEntry_Command  DEFAULT ((0)) FOR Command
go
ALTER TABLE Usr.tbMenuEntry ADD  CONSTRAINT DF_Usr_tbMenuEntry_OpenMode  DEFAULT ((1)) FOR OpenMode
go
ALTER TABLE Usr.tbMenuEntry ADD  CONSTRAINT DF_Usr_tbMenuEntry_UpdatedOn  DEFAULT (getdate()) FOR UpdatedOn
go
ALTER TABLE Usr.tbMenuEntry ADD  CONSTRAINT DF_Usr_tbMenuEntry_InsertedOn  DEFAULT (getdate()) FOR InsertedOn
go
ALTER TABLE Usr.tbMenuEntry ADD  CONSTRAINT DF_Usr_tbMenuEntry_UpdatedBy  DEFAULT (suser_sname()) FOR UpdatedBy
go
ALTER TABLE Usr.tbMenuOpenMode ADD  CONSTRAINT DF_Usr_tbMenuOpenMode_OpenMode  DEFAULT ((0)) FOR OpenMode
go
ALTER TABLE Usr.tbUser ADD  CONSTRAINT DF_Usr_tb_LogonName  DEFAULT (suser_sname()) FOR LogonName
go
ALTER TABLE Usr.tbUser ADD  CONSTRAINT DF_Usr_tbUser_IsAdministrator  DEFAULT ((0)) FOR IsAdministrator
go
ALTER TABLE Usr.tbUser ADD  CONSTRAINT DF_Usr_tbUser_IsEnabled  DEFAULT ((1)) FOR IsEnabled
go
ALTER TABLE Usr.tbUser ADD  CONSTRAINT DF_Usr_tb_NextTaskNumber  DEFAULT ((1)) FOR NextTaskNumber
go
ALTER TABLE Usr.tbUser ADD  CONSTRAINT DF_Usr_tb_InsertedBy  DEFAULT (suser_sname()) FOR InsertedBy
go
ALTER TABLE Usr.tbUser ADD  CONSTRAINT DF_Usr_tb_InsertedOn  DEFAULT (getdate()) FOR InsertedOn
go
ALTER TABLE Usr.tbUser ADD  CONSTRAINT DF_Usr_tb_UpdatedBy  DEFAULT (suser_sname()) FOR UpdatedBy
go
ALTER TABLE Usr.tbUser ADD  CONSTRAINT DF_Usr_tb_UpdatedOn  DEFAULT (getdate()) FOR UpdatedOn
go
ALTER TABLE App.tbOptions  WITH CHECK ADD  CONSTRAINT FK_App_tbOptions_App_tbRegister FOREIGN KEY(RegisterName)
REFERENCES App.tbRegister (RegisterName)
ON UPDATE CASCADE
go
ALTER TABLE App.tbOptions CHECK CONSTRAINT FK_App_tbOptions_App_tbRegister
go
ALTER TABLE Activity.tbActivity  WITH CHECK ADD  CONSTRAINT FK_Activity_tbActivity_App_tbRegister FOREIGN KEY(RegisterName)
REFERENCES App.tbRegister (RegisterName)
ON UPDATE CASCADE
go
ALTER TABLE Activity.tbActivity CHECK CONSTRAINT FK_Activity_tbActivity_App_tbRegister
go
ALTER TABLE Activity.tbActivity  WITH CHECK ADD  CONSTRAINT FK_Activity_tbActivity_App_tbUom FOREIGN KEY(UnitOfMeasure)
REFERENCES App.tbUom (UnitOfMeasure)
go
ALTER TABLE Activity.tbActivity CHECK CONSTRAINT FK_Activity_tbActivity_App_tbUom
go
ALTER TABLE Activity.tbActivity  WITH CHECK ADD  CONSTRAINT FK_Activity_tbActivity_Cash_tbCode FOREIGN KEY(CashCode)
REFERENCES Cash.tbCode (CashCode)
ON UPDATE CASCADE
go
ALTER TABLE Activity.tbActivity CHECK CONSTRAINT FK_Activity_tbActivity_Cash_tbCode
go
ALTER TABLE Activity.tbAttribute  WITH CHECK ADD  CONSTRAINT FK_Activity_tbAttribute_Activity_tbAttributeType FOREIGN KEY(AttributeTypeCode)
REFERENCES Activity.tbAttributeType (AttributeTypeCode)
go
ALTER TABLE Activity.tbAttribute CHECK CONSTRAINT FK_Activity_tbAttribute_Activity_tbAttributeType
go
ALTER TABLE Activity.tbAttribute  WITH CHECK ADD  CONSTRAINT FK_Activity_tbAttribute_tbActivity FOREIGN KEY(ActivityCode)
REFERENCES Activity.tbActivity (ActivityCode)
ON UPDATE CASCADE
ON DELETE CASCADE
go
ALTER TABLE Activity.tbAttribute CHECK CONSTRAINT FK_Activity_tbAttribute_tbActivity
go
ALTER TABLE Activity.tbFlow  WITH CHECK ADD  CONSTRAINT FK_Activity_tbFlow_Activity_tbSyncType FOREIGN KEY(SyncTypeCode)
REFERENCES Activity.tbSyncType (SyncTypeCode)
go
ALTER TABLE Activity.tbFlow CHECK CONSTRAINT FK_Activity_tbFlow_Activity_tbSyncType
go
ALTER TABLE Activity.tbFlow  WITH CHECK ADD  CONSTRAINT FK_Activity_tbFlow_Activity_tbChild FOREIGN KEY(ChildCode)
REFERENCES Activity.tbActivity (ActivityCode)
go
ALTER TABLE Activity.tbFlow CHECK CONSTRAINT FK_Activity_tbFlow_Activity_tbChild
go
ALTER TABLE Activity.tbFlow  WITH CHECK ADD  CONSTRAINT FK_Activity_tbFlow_tbActivityParent FOREIGN KEY(ParentCode)
REFERENCES Activity.tbActivity (ActivityCode)
go
ALTER TABLE Activity.tbFlow CHECK CONSTRAINT FK_Activity_tbFlow_tbActivityParent
go
ALTER TABLE Activity.tbOp  WITH CHECK ADD  CONSTRAINT FK_Activity_tbOp_Activity_tbSyncType FOREIGN KEY(SyncTypeCode)
REFERENCES Activity.tbSyncType (SyncTypeCode)
go
ALTER TABLE Activity.tbOp CHECK CONSTRAINT FK_Activity_tbOp_Activity_tbSyncType
go
ALTER TABLE Activity.tbOp  WITH CHECK ADD  CONSTRAINT FK_Activity_tbOp_tbActivity FOREIGN KEY(ActivityCode)
REFERENCES Activity.tbActivity (ActivityCode)
ON UPDATE CASCADE
ON DELETE CASCADE
go
ALTER TABLE Activity.tbOp CHECK CONSTRAINT FK_Activity_tbOp_tbActivity
go
ALTER TABLE App.tbCalendarHoliday  WITH CHECK ADD  CONSTRAINT App_tbCalendarHoliday_FK00 FOREIGN KEY(CalendarCode)
REFERENCES App.tbCalendar (CalendarCode)
ON UPDATE CASCADE
ON DELETE CASCADE
go
ALTER TABLE App.tbCalendarHoliday CHECK CONSTRAINT App_tbCalendarHoliday_FK00
go
ALTER TABLE App.tbDoc  WITH CHECK ADD  CONSTRAINT FK_App_tbDoc_Usr_tbMenuOpenMode FOREIGN KEY(OpenMode)
REFERENCES Usr.tbMenuOpenMode (OpenMode)
go
ALTER TABLE App.tbDoc CHECK CONSTRAINT FK_App_tbDoc_Usr_tbMenuOpenMode
go
ALTER TABLE App.tbDocSpool  WITH CHECK ADD  CONSTRAINT FK_App_tbDocSpool_App_tbDocType FOREIGN KEY(DocTypeCode)
REFERENCES App.tbDocType (DocTypeCode)
go
ALTER TABLE App.tbDocSpool CHECK CONSTRAINT FK_App_tbDocSpool_App_tbDocType
go
ALTER TABLE App.tbDocType  WITH CHECK ADD  CONSTRAINT FK_App_tbDocType_App_tbDocClass FOREIGN KEY(DocClassCode)
REFERENCES App.tbDocClass (DocClassCode)
go
ALTER TABLE App.tbDocType CHECK CONSTRAINT FK_App_tbDocType_App_tbDocClass
go
ALTER TABLE App.tbEventLog  WITH CHECK ADD FOREIGN KEY(EventTypeCode)
REFERENCES App.tbEventType (EventTypeCode)
go
ALTER TABLE App.tbOptions  WITH CHECK ADD  CONSTRAINT FK_App_tbOption_Cash_tbCategory FOREIGN KEY(NetProfitCode)
REFERENCES Cash.tbCategory (CategoryCode)
go
ALTER TABLE App.tbOptions CHECK CONSTRAINT FK_App_tbOption_Cash_tbCategory
go
ALTER TABLE App.tbOptions  WITH CHECK ADD  CONSTRAINT FK_App_tbOptions_App_tbBucketInterval FOREIGN KEY(BucketIntervalCode)
REFERENCES App.tbBucketInterval (BucketIntervalCode)
go
ALTER TABLE App.tbOptions CHECK CONSTRAINT FK_App_tbOptions_App_tbBucketInterval
go
ALTER TABLE App.tbOptions  WITH CHECK ADD  CONSTRAINT FK_App_tbOptions_App_tbBucketType FOREIGN KEY(BucketTypeCode)
REFERENCES App.tbBucketType (BucketTypeCode)
go
ALTER TABLE App.tbOptions CHECK CONSTRAINT FK_App_tbOptions_App_tbBucketType
go
ALTER TABLE App.tbOptions  WITH CHECK ADD  CONSTRAINT FK_App_tbOptions_Org_tb FOREIGN KEY(AccountCode)
REFERENCES Org.tbOrg (AccountCode)
ON UPDATE CASCADE
go
ALTER TABLE App.tbOptions CHECK CONSTRAINT FK_App_tbOptions_Org_tb
go
ALTER TABLE App.tbTaxCode  WITH NOCHECK ADD  CONSTRAINT FK_App_tbTaxCode_App_tbRounding FOREIGN KEY(RoundingCode)
REFERENCES App.tbRounding (RoundingCode)
go
ALTER TABLE App.tbTaxCode CHECK CONSTRAINT FK_App_tbTaxCode_App_tbRounding
go
ALTER TABLE App.tbTaxCode  WITH NOCHECK ADD  CONSTRAINT FK_App_tbTaxCode_Cash_tbTaxType FOREIGN KEY(TaxTypeCode)
REFERENCES Cash.tbTaxType (TaxTypeCode)
go
ALTER TABLE App.tbTaxCode CHECK CONSTRAINT FK_App_tbTaxCode_Cash_tbTaxType
go
ALTER TABLE App.tbYear  WITH CHECK ADD  CONSTRAINT FK_App_tbYear_App_tbMonth FOREIGN KEY(StartMonth)
REFERENCES App.tbMonth (MonthNumber)
go
ALTER TABLE App.tbYear CHECK CONSTRAINT FK_App_tbYear_App_tbMonth
go
ALTER TABLE App.tbYearPeriod  WITH CHECK ADD  CONSTRAINT FK_App_tbYearPeriod_App_tbMonth FOREIGN KEY(MonthNumber)
REFERENCES App.tbMonth (MonthNumber)
go
ALTER TABLE App.tbYearPeriod CHECK CONSTRAINT FK_App_tbYearPeriod_App_tbMonth
go
ALTER TABLE App.tbYearPeriod  WITH CHECK ADD  CONSTRAINT FK_App_tbYearPeriod_App_tbYear FOREIGN KEY(YearNumber)
REFERENCES App.tbYear (YearNumber)
ON UPDATE CASCADE
ON DELETE CASCADE
go
ALTER TABLE App.tbYearPeriod CHECK CONSTRAINT FK_App_tbYearPeriod_App_tbYear
go
ALTER TABLE App.tbYearPeriod  WITH CHECK ADD  CONSTRAINT FK_App_tbYearPeriod_Cash_tbStatus FOREIGN KEY(CashStatusCode)
REFERENCES Cash.tbStatus (CashStatusCode)
go
ALTER TABLE App.tbYearPeriod CHECK CONSTRAINT FK_App_tbYearPeriod_Cash_tbStatus
go
ALTER TABLE Cash.tbCategory  WITH CHECK ADD  CONSTRAINT FK_Cash_tbCategory_Cash_tbCategoryType FOREIGN KEY(CategoryTypeCode)
REFERENCES Cash.tbCategoryType (CategoryTypeCode)
go
ALTER TABLE Cash.tbCategory CHECK CONSTRAINT FK_Cash_tbCategory_Cash_tbCategoryType
go
ALTER TABLE Cash.tbCategory  WITH CHECK ADD  CONSTRAINT FK_Cash_tbCategory_Cash_tbMode FOREIGN KEY(CashModeCode)
REFERENCES Cash.tbMode (CashModeCode)
go
ALTER TABLE Cash.tbCategory CHECK CONSTRAINT FK_Cash_tbCategory_Cash_tbMode
go
ALTER TABLE Cash.tbCategory  WITH CHECK ADD  CONSTRAINT FK_Cash_tbCategory_Cash_tbType FOREIGN KEY(CashTypeCode)
REFERENCES Cash.tbType (CashTypeCode)
go
ALTER TABLE Cash.tbCategory CHECK CONSTRAINT FK_Cash_tbCategory_Cash_tbType
go
ALTER TABLE Cash.tbCategoryExp  WITH CHECK ADD  CONSTRAINT FK_Cash_tbCategoryExp_Cash_tbCategory FOREIGN KEY(CategoryCode)
REFERENCES Cash.tbCategory (CategoryCode)
ON UPDATE CASCADE
ON DELETE CASCADE
go
ALTER TABLE Cash.tbCategoryExp CHECK CONSTRAINT FK_Cash_tbCategoryExp_Cash_tbCategory
go
ALTER TABLE Cash.tbCategoryTotal  WITH CHECK ADD  CONSTRAINT FK_Cash_tbCategoryTotal_Cash_tbCategory_Child FOREIGN KEY(ChildCode)
REFERENCES Cash.tbCategory (CategoryCode)
go
ALTER TABLE Cash.tbCategoryTotal CHECK CONSTRAINT FK_Cash_tbCategoryTotal_Cash_tbCategory_Child
go
ALTER TABLE Cash.tbCategoryTotal  WITH CHECK ADD  CONSTRAINT FK_Cash_tbCategoryTotal_Cash_tbCategory_Parent FOREIGN KEY(ParentCode)
REFERENCES Cash.tbCategory (CategoryCode)
go
ALTER TABLE Cash.tbCategoryTotal CHECK CONSTRAINT FK_Cash_tbCategoryTotal_Cash_tbCategory_Parent
go
ALTER TABLE Cash.tbCode  WITH NOCHECK ADD  CONSTRAINT FK_Cash_tbCode_App_tbTaxCode FOREIGN KEY(TaxCode)
REFERENCES App.tbTaxCode (TaxCode)
go
ALTER TABLE Cash.tbCode CHECK CONSTRAINT FK_Cash_tbCode_App_tbTaxCode
go
ALTER TABLE Cash.tbCode  WITH CHECK ADD  CONSTRAINT FK_Cash_tbCode_Cash_tbCategory1 FOREIGN KEY(CategoryCode)
REFERENCES Cash.tbCategory (CategoryCode)
ON UPDATE CASCADE
go
ALTER TABLE Cash.tbCode CHECK CONSTRAINT FK_Cash_tbCode_Cash_tbCategory1
go
ALTER TABLE Cash.tbPeriod  WITH CHECK ADD  CONSTRAINT FK_Cash_tbPeriod_App_tbYearPeriod FOREIGN KEY(StartOn)
REFERENCES App.tbYearPeriod (StartOn)
ON UPDATE CASCADE
ON DELETE CASCADE
go
ALTER TABLE Cash.tbPeriod CHECK CONSTRAINT FK_Cash_tbPeriod_App_tbYearPeriod
go
ALTER TABLE Cash.tbPeriod  WITH CHECK ADD  CONSTRAINT FK_Cash_tbPeriod_Cash_tbCode FOREIGN KEY(CashCode)
REFERENCES Cash.tbCode (CashCode)
ON UPDATE CASCADE
ON DELETE CASCADE
go
ALTER TABLE Cash.tbPeriod CHECK CONSTRAINT FK_Cash_tbPeriod_Cash_tbCode
go
ALTER TABLE Cash.tbTaxType  WITH CHECK ADD  CONSTRAINT FK_Cash_tbTaxType_App_tbMonth FOREIGN KEY(MonthNumber)
REFERENCES App.tbMonth (MonthNumber)
go
ALTER TABLE Cash.tbTaxType CHECK CONSTRAINT FK_Cash_tbTaxType_App_tbMonth
go
ALTER TABLE Cash.tbTaxType  WITH CHECK ADD  CONSTRAINT FK_Cash_tbTaxType_App_tbRecurrence FOREIGN KEY(RecurrenceCode)
REFERENCES App.tbRecurrence (RecurrenceCode)
go
ALTER TABLE Cash.tbTaxType CHECK CONSTRAINT FK_Cash_tbTaxType_App_tbRecurrence
go
ALTER TABLE Cash.tbTaxType  WITH CHECK ADD  CONSTRAINT FK_Cash_tbTaxType_Cash_tbCode FOREIGN KEY(CashCode)
REFERENCES Cash.tbCode (CashCode)
go
ALTER TABLE Cash.tbTaxType CHECK CONSTRAINT FK_Cash_tbTaxType_Cash_tbCode
go
ALTER TABLE Cash.tbTaxType  WITH CHECK ADD  CONSTRAINT FK_Cash_tbTaxType_Org_tb FOREIGN KEY(AccountCode)
REFERENCES Org.tbOrg (AccountCode)
ON UPDATE CASCADE
go
ALTER TABLE Cash.tbTaxType CHECK CONSTRAINT FK_Cash_tbTaxType_Org_tb
go
ALTER TABLE Invoice.tbInvoice  WITH CHECK ADD  CONSTRAINT FK_Invoice_tb_Invoice_tbStatus FOREIGN KEY(InvoiceStatusCode)
REFERENCES Invoice.tbStatus (InvoiceStatusCode)
go
ALTER TABLE Invoice.tbInvoice CHECK CONSTRAINT FK_Invoice_tb_Invoice_tbStatus
go
ALTER TABLE Invoice.tbInvoice  WITH CHECK ADD  CONSTRAINT FK_Invoice_tb_Invoice_tbType FOREIGN KEY(InvoiceTypeCode)
REFERENCES Invoice.tbType (InvoiceTypeCode)
go
ALTER TABLE Invoice.tbInvoice CHECK CONSTRAINT FK_Invoice_tb_Invoice_tbType
go
ALTER TABLE Invoice.tbInvoice  WITH CHECK ADD  CONSTRAINT FK_Invoice_tb_Org_tb FOREIGN KEY(AccountCode)
REFERENCES Org.tbOrg (AccountCode)
go
ALTER TABLE Invoice.tbInvoice CHECK CONSTRAINT FK_Invoice_tb_Org_tb
go
ALTER TABLE Invoice.tbInvoice  WITH CHECK ADD  CONSTRAINT FK_Invoice_tb_Usr_tb FOREIGN KEY(UserId)
REFERENCES Usr.tbUser (UserId)
ON UPDATE CASCADE
go
ALTER TABLE Invoice.tbInvoice CHECK CONSTRAINT FK_Invoice_tb_Usr_tb
go
ALTER TABLE Invoice.tbItem  WITH NOCHECK ADD  CONSTRAINT FK_Invoice_tbItem_App_tbTaxCode FOREIGN KEY(TaxCode)
REFERENCES App.tbTaxCode (TaxCode)
go
ALTER TABLE Invoice.tbItem CHECK CONSTRAINT FK_Invoice_tbItem_App_tbTaxCode
go
ALTER TABLE Invoice.tbItem  WITH CHECK ADD  CONSTRAINT FK_Invoice_tbItem_Cash_tbCode FOREIGN KEY(CashCode)
REFERENCES Cash.tbCode (CashCode)
ON UPDATE CASCADE
go
ALTER TABLE Invoice.tbItem CHECK CONSTRAINT FK_Invoice_tbItem_Cash_tbCode
go
ALTER TABLE Invoice.tbItem  WITH CHECK ADD  CONSTRAINT FK_Invoice_tbItem_Invoice_tb FOREIGN KEY(InvoiceNumber)
REFERENCES Invoice.tbInvoice (InvoiceNumber)
ON UPDATE CASCADE
ON DELETE CASCADE
go
ALTER TABLE Invoice.tbItem CHECK CONSTRAINT FK_Invoice_tbItem_Invoice_tb
go
ALTER TABLE Invoice.tbTask  WITH NOCHECK ADD  CONSTRAINT FK_Invoice_tbTask_App_tbTaxCode FOREIGN KEY(TaxCode)
REFERENCES App.tbTaxCode (TaxCode)
go
ALTER TABLE Invoice.tbTask CHECK CONSTRAINT FK_Invoice_tbTask_App_tbTaxCode
go
ALTER TABLE Invoice.tbTask  WITH CHECK ADD  CONSTRAINT FK_Invoice_tbTask_Cash_tbCode FOREIGN KEY(CashCode)
REFERENCES Cash.tbCode (CashCode)
go
ALTER TABLE Invoice.tbTask CHECK CONSTRAINT FK_Invoice_tbTask_Cash_tbCode
go
ALTER TABLE Invoice.tbTask  WITH CHECK ADD  CONSTRAINT FK_Invoice_tbTask_Invoice_tb FOREIGN KEY(InvoiceNumber)
REFERENCES Invoice.tbInvoice (InvoiceNumber)
ON UPDATE CASCADE
ON DELETE CASCADE
go
ALTER TABLE Invoice.tbTask CHECK CONSTRAINT FK_Invoice_tbTask_Invoice_tb
go
ALTER TABLE Invoice.tbTask  WITH NOCHECK ADD  CONSTRAINT FK_Invoice_tbTask_Task_tb FOREIGN KEY(TaskCode)
REFERENCES Task.tbTask (TaskCode)
go
ALTER TABLE Invoice.tbTask CHECK CONSTRAINT FK_Invoice_tbTask_Task_tb
go
ALTER TABLE Invoice.tbType  WITH CHECK ADD  CONSTRAINT FK_Invoice_tbType_Cash_tbMode FOREIGN KEY(CashModeCode)
REFERENCES Cash.tbMode (CashModeCode)
go
ALTER TABLE Invoice.tbType CHECK CONSTRAINT FK_Invoice_tbType_Cash_tbMode
go
ALTER TABLE Org.tbAccount  WITH CHECK ADD  CONSTRAINT FK_Org_tbAccount_Cash_tbCode FOREIGN KEY(CashCode)
REFERENCES Cash.tbCode (CashCode)
go
ALTER TABLE Org.tbAccount CHECK CONSTRAINT FK_Org_tbAccount_Cash_tbCode
go
ALTER TABLE Org.tbAccount  WITH CHECK ADD  CONSTRAINT FK_Org_tbAccount_Org_tb FOREIGN KEY(AccountCode)
REFERENCES Org.tbOrg (AccountCode)
ON UPDATE CASCADE
go
ALTER TABLE Org.tbAccount CHECK CONSTRAINT FK_Org_tbAccount_Org_tb
go
ALTER TABLE Org.tbAddress  WITH CHECK ADD  CONSTRAINT FK_Org_tbAddress_Org_tb FOREIGN KEY(AccountCode)
REFERENCES Org.tbOrg (AccountCode)
ON UPDATE CASCADE
ON DELETE CASCADE
go
ALTER TABLE Org.tbAddress CHECK CONSTRAINT FK_Org_tbAddress_Org_tb
go
ALTER TABLE Org.tbContact  WITH CHECK ADD  CONSTRAINT FK_Org_tbContact_AccountCode FOREIGN KEY(AccountCode)
REFERENCES Org.tbOrg (AccountCode)
ON UPDATE CASCADE
ON DELETE CASCADE
go
ALTER TABLE Org.tbContact CHECK CONSTRAINT FK_Org_tbContact_AccountCode
go
ALTER TABLE Org.tbDoc  WITH CHECK ADD  CONSTRAINT FK_Org_tbDoc_AccountCode FOREIGN KEY(AccountCode)
REFERENCES Org.tbOrg (AccountCode)
ON UPDATE CASCADE
ON DELETE CASCADE
go
ALTER TABLE Org.tbDoc CHECK CONSTRAINT FK_Org_tbDoc_AccountCode
go
ALTER TABLE Org.tbOrg  WITH NOCHECK ADD  CONSTRAINT FK_Org_tb_App_tbTaxCode FOREIGN KEY(TaxCode)
REFERENCES App.tbTaxCode (TaxCode)
ON UPDATE CASCADE
go
ALTER TABLE Org.tbOrg CHECK CONSTRAINT FK_Org_tb_App_tbTaxCode
go
ALTER TABLE Org.tbOrg  WITH NOCHECK ADD  CONSTRAINT FK_Org_tb_Org_tbAddress FOREIGN KEY(AddressCode)
REFERENCES Org.tbAddress (AddressCode)
NOT FOR REPLICATION 
go
ALTER TABLE Org.tbOrg NOCHECK CONSTRAINT FK_Org_tb_Org_tbAddress
go
ALTER TABLE Org.tbOrg  WITH CHECK ADD  CONSTRAINT FK_tbOrg_Org_tbStatus FOREIGN KEY(OrganisationStatusCode)
REFERENCES Org.tbStatus (OrganisationStatusCode)
go
ALTER TABLE Org.tbOrg CHECK CONSTRAINT FK_tbOrg_Org_tbStatus
go
ALTER TABLE Org.tbOrg  WITH CHECK ADD  CONSTRAINT FK_tbOrg_Org_tbType FOREIGN KEY(OrganisationTypeCode)
REFERENCES Org.tbType (OrganisationTypeCode)
go
ALTER TABLE Org.tbOrg CHECK CONSTRAINT FK_tbOrg_Org_tbType
go
ALTER TABLE Org.tbSector  WITH CHECK ADD  CONSTRAINT FK_Org_tbSector_Org_tb FOREIGN KEY(AccountCode)
REFERENCES Org.tbOrg (AccountCode)
ON UPDATE CASCADE
ON DELETE CASCADE
go
ALTER TABLE Org.tbSector CHECK CONSTRAINT FK_Org_tbSector_Org_tb
go
ALTER TABLE Org.tbType  WITH CHECK ADD  CONSTRAINT FK_Org_tbType_Cash_tbMode FOREIGN KEY(CashModeCode)
REFERENCES Cash.tbMode (CashModeCode)
go
ALTER TABLE Org.tbType CHECK CONSTRAINT FK_Org_tbType_Cash_tbMode
go
ALTER TABLE Org.tbPayment  WITH CHECK ADD  CONSTRAINT FK_Org_tbPayment_Cash_tbCode FOREIGN KEY(CashCode)
REFERENCES Cash.tbCode (CashCode)
ON UPDATE CASCADE
go
ALTER TABLE Org.tbPayment CHECK CONSTRAINT FK_Org_tbPayment_Cash_tbCode
go
ALTER TABLE Org.tbPayment  WITH CHECK ADD  CONSTRAINT FK_Org_tbPayment_tbOrg FOREIGN KEY(AccountCode)
REFERENCES Org.tbOrg (AccountCode)
go
ALTER TABLE Org.tbPayment CHECK CONSTRAINT FK_Org_tbPayment_tbOrg
go
ALTER TABLE Org.tbPayment  WITH CHECK ADD  CONSTRAINT FK_Org_tbPayment_Org_tbAccount FOREIGN KEY(CashAccountCode)
REFERENCES Org.tbAccount (CashAccountCode)
ON UPDATE CASCADE
go
ALTER TABLE Org.tbPayment CHECK CONSTRAINT FK_Org_tbPayment_Org_tbAccount
go
ALTER TABLE Org.tbPayment  WITH CHECK ADD  CONSTRAINT FK_Org_tbPayment_Org_tbPaymentStatus FOREIGN KEY(PaymentStatusCode)
REFERENCES Org.tbPaymentStatus (PaymentStatusCode)
go
ALTER TABLE Org.tbPayment CHECK CONSTRAINT FK_Org_tbPayment_Org_tbPaymentStatus
go
ALTER TABLE Org.tbPayment  WITH NOCHECK ADD  CONSTRAINT FK_Org_tbPayment_App_tbTaxCode FOREIGN KEY(TaxCode)
REFERENCES App.tbTaxCode (TaxCode)
go
ALTER TABLE Org.tbPayment CHECK CONSTRAINT FK_Org_tbPayment_App_tbTaxCode
go
ALTER TABLE Org.tbPayment  WITH CHECK ADD  CONSTRAINT FK_Org_tbPayment_Usr_tbUser FOREIGN KEY(UserId)
REFERENCES Usr.tbUser (UserId)
ON UPDATE CASCADE
go
ALTER TABLE Org.tbPayment CHECK CONSTRAINT FK_Org_tbPayment_Usr_tbUser
go
ALTER TABLE Task.tbAttribute  WITH NOCHECK ADD  CONSTRAINT FK_Task_tbAttrib_Task_tb FOREIGN KEY(TaskCode)
REFERENCES Task.tbTask (TaskCode)
ON UPDATE CASCADE
ON DELETE CASCADE
go
ALTER TABLE Task.tbAttribute CHECK CONSTRAINT FK_Task_tbAttrib_Task_tb
go
ALTER TABLE Task.tbAttribute  WITH CHECK ADD  CONSTRAINT FK_Task_tbAttribute_Activity_tbAttributeType FOREIGN KEY(AttributeTypeCode)
REFERENCES Activity.tbAttributeType (AttributeTypeCode)
go
ALTER TABLE Task.tbAttribute CHECK CONSTRAINT FK_Task_tbAttribute_Activity_tbAttributeType
go
ALTER TABLE Task.tbDoc  WITH NOCHECK ADD  CONSTRAINT FK_Task_tbDoc_Task_tb FOREIGN KEY(TaskCode)
REFERENCES Task.tbTask (TaskCode)
go
ALTER TABLE Task.tbDoc CHECK CONSTRAINT FK_Task_tbDoc_Task_tb
go
ALTER TABLE Task.tbFlow  WITH NOCHECK ADD  CONSTRAINT FK_Task_tbFlow_Task_tb_Child FOREIGN KEY(ChildTaskCode)
REFERENCES Task.tbTask (TaskCode)
go
ALTER TABLE Task.tbFlow CHECK CONSTRAINT FK_Task_tbFlow_Task_tb_Child
go
ALTER TABLE Task.tbFlow  WITH NOCHECK ADD  CONSTRAINT FK_Task_tbFlow_Task_tb_Parent FOREIGN KEY(ParentTaskCode)
REFERENCES Task.tbTask (TaskCode)
go
ALTER TABLE Task.tbFlow CHECK CONSTRAINT FK_Task_tbFlow_Task_tb_Parent
go
ALTER TABLE Task.tbFlow  WITH CHECK ADD  CONSTRAINT FK_Task_tbFlow_Activity_tbSyncType FOREIGN KEY(SyncTypeCode)
REFERENCES Activity.tbSyncType (SyncTypeCode)
go
ALTER TABLE Task.tbFlow CHECK CONSTRAINT FK_Task_tbFlow_Activity_tbSyncType
go
ALTER TABLE Task.tbOp  WITH CHECK ADD  CONSTRAINT FK_Task_tbOp_Activity_tbSyncType FOREIGN KEY(SyncTypeCode)
REFERENCES Activity.tbSyncType (SyncTypeCode)
go
ALTER TABLE Task.tbOp CHECK CONSTRAINT FK_Task_tbOp_Activity_tbSyncType
go
ALTER TABLE Task.tbOp  WITH NOCHECK ADD  CONSTRAINT FK_Task_tbOp_Task_tb FOREIGN KEY(TaskCode)
REFERENCES Task.tbTask (TaskCode)
ON UPDATE CASCADE
ON DELETE CASCADE
go
ALTER TABLE Task.tbOp CHECK CONSTRAINT FK_Task_tbOp_Task_tb
go
ALTER TABLE Task.tbOp  WITH CHECK ADD  CONSTRAINT FK_Task_tbOp_Task_tbOpStatus FOREIGN KEY(OpStatusCode)
REFERENCES Task.tbOpStatus (OpStatusCode)
go
ALTER TABLE Task.tbOp CHECK CONSTRAINT FK_Task_tbOp_Task_tbOpStatus
go
ALTER TABLE Task.tbOp  WITH CHECK ADD  CONSTRAINT FK_Task_tbOp_Usr_tb FOREIGN KEY(UserId)
REFERENCES Usr.tbUser (UserId)
go
ALTER TABLE Task.tbOp CHECK CONSTRAINT FK_Task_tbOp_Usr_tb
go
ALTER TABLE Task.tbQuote  WITH NOCHECK ADD  CONSTRAINT FK_Task_tbQuote_Task_tb FOREIGN KEY(TaskCode)
REFERENCES Task.tbTask (TaskCode)
ON UPDATE CASCADE
ON DELETE CASCADE
go
ALTER TABLE Task.tbQuote CHECK CONSTRAINT FK_Task_tbQuote_Task_tb
go
ALTER TABLE Task.tbTask  WITH NOCHECK ADD  CONSTRAINT Activity_tb_FK00 FOREIGN KEY(ActivityCode)
REFERENCES Activity.tbActivity (ActivityCode)
ON UPDATE CASCADE
go
ALTER TABLE Task.tbTask CHECK CONSTRAINT Activity_tb_FK00
go
ALTER TABLE Task.tbTask  WITH NOCHECK ADD  CONSTRAINT Activity_tb_FK01 FOREIGN KEY(TaskStatusCode)
REFERENCES Task.tbStatus (TaskStatusCode)
go
ALTER TABLE Task.tbTask CHECK CONSTRAINT Activity_tb_FK01
go
ALTER TABLE Task.tbTask  WITH NOCHECK ADD  CONSTRAINT Activity_tb_FK02 FOREIGN KEY(AccountCode)
REFERENCES Org.tbOrg (AccountCode)
ON UPDATE CASCADE
go
ALTER TABLE Task.tbTask CHECK CONSTRAINT Activity_tb_FK02
go
ALTER TABLE Task.tbTask  WITH NOCHECK ADD  CONSTRAINT FK_Task_tb_App_tbTaxCode FOREIGN KEY(TaxCode)
REFERENCES App.tbTaxCode (TaxCode)
go
ALTER TABLE Task.tbTask CHECK CONSTRAINT FK_Task_tb_App_tbTaxCode
go
ALTER TABLE Task.tbTask  WITH NOCHECK ADD  CONSTRAINT FK_Task_tb_Cash_tbCode FOREIGN KEY(CashCode)
REFERENCES Cash.tbCode (CashCode)
go
ALTER TABLE Task.tbTask CHECK CONSTRAINT FK_Task_tb_Cash_tbCode
go
ALTER TABLE Task.tbTask  WITH NOCHECK ADD  CONSTRAINT FK_Task_tb_Org_tbAddress_From FOREIGN KEY(AddressCodeFrom)
REFERENCES Org.tbAddress (AddressCode)
go
ALTER TABLE Task.tbTask CHECK CONSTRAINT FK_Task_tb_Org_tbAddress_From
go
ALTER TABLE Task.tbTask  WITH NOCHECK ADD  CONSTRAINT FK_Task_tb_Org_tbAddress_To FOREIGN KEY(AddressCodeTo)
REFERENCES Org.tbAddress (AddressCode)
go
ALTER TABLE Task.tbTask CHECK CONSTRAINT FK_Task_tb_Org_tbAddress_To
go
ALTER TABLE Task.tbTask  WITH NOCHECK ADD  CONSTRAINT FK_Task_tb_Usr_tb FOREIGN KEY(UserId)
REFERENCES Usr.tbUser (UserId)
ON UPDATE CASCADE
go
ALTER TABLE Task.tbTask CHECK CONSTRAINT FK_Task_tb_Usr_tb
go
ALTER TABLE Task.tbTask  WITH NOCHECK ADD  CONSTRAINT FK_Task_tb_Usr_tb_ActionById FOREIGN KEY(ActionById)
REFERENCES Usr.tbUser (UserId)
go
ALTER TABLE Task.tbTask CHECK CONSTRAINT FK_Task_tb_Usr_tb_ActionById
go
ALTER TABLE Usr.tbMenuEntry  WITH CHECK ADD  CONSTRAINT FK_Usr_tbMenuEntry_Usr_tbMenu FOREIGN KEY(MenuId)
REFERENCES Usr.tbMenu (MenuId)
ON UPDATE CASCADE
ON DELETE CASCADE
go
ALTER TABLE Usr.tbMenuEntry CHECK CONSTRAINT FK_Usr_tbMenuEntry_Usr_tbMenu
go
ALTER TABLE Usr.tbMenuEntry  WITH CHECK ADD  CONSTRAINT Usr_tbMenuEntry_FK01 FOREIGN KEY(Command)
REFERENCES Usr.tbMenuCommand (Command)
go
ALTER TABLE Usr.tbMenuEntry CHECK CONSTRAINT Usr_tbMenuEntry_FK01
go
ALTER TABLE Usr.tbMenuEntry  WITH CHECK ADD  CONSTRAINT Usr_tbMenuEntry_FK02 FOREIGN KEY(OpenMode)
REFERENCES Usr.tbMenuOpenMode (OpenMode)
go
ALTER TABLE Usr.tbMenuEntry CHECK CONSTRAINT Usr_tbMenuEntry_FK02
go
ALTER TABLE Usr.tbMenuUser  WITH CHECK ADD  CONSTRAINT FK_Usr_tbMenu_Usr_tb FOREIGN KEY(UserId)
REFERENCES Usr.tbUser (UserId)
ON UPDATE CASCADE
go
ALTER TABLE Usr.tbMenuUser CHECK CONSTRAINT FK_Usr_tbMenu_Usr_tb
go
ALTER TABLE Usr.tbMenuUser  WITH CHECK ADD  CONSTRAINT FK_Usr_tbMenu_Usr_tbMenu FOREIGN KEY(MenuId)
REFERENCES Usr.tbMenu (MenuId)
go
ALTER TABLE Usr.tbMenuUser CHECK CONSTRAINT FK_Usr_tbMenu_Usr_tbMenu
go
ALTER TABLE Usr.tbUser  WITH CHECK ADD  CONSTRAINT FK_Usr_tb_App_tbCalendar FOREIGN KEY(CalendarCode)
REFERENCES App.tbCalendar (CalendarCode)
ON UPDATE CASCADE
go
ALTER TABLE Usr.tbUser CHECK CONSTRAINT FK_Usr_tb_App_tbCalendar
go

/**************** BUSINESS LOGIC *************************************/

-- SCALER VALUED FUNCTIONS
go
--SVF dependencies
go
CREATE VIEW App.vwVersion
AS
	SELECT CONCAT(ROUND(SQLDataVersion, 3), '.', SQLRelease) AS VersionString, ROUND(SQLDataVersion, 3) SQLDataVersion, SQLRelease
	FROM App.tbInstall
	WHERE InstallId = (SELECT MAX(InstallId) FROM App.tbInstall)
go

CREATE FUNCTION App.fnVersion()
RETURNS NVARCHAR(10)
AS
BEGIN
	DECLARE @Version NVARCHAR(10) = '0.0.0'
	SELECT @Version = VersionString
	FROM App.vwVersion
	RETURN @Version
END
go
CREATE VIEW Usr.vwCredentials
  AS
SELECT     UserId, UserName, LogonName, IsAdministrator
FROM         Usr.tbUser
WHERE     (LogonName = SUSER_SNAME()) AND (IsEnabled <> 0)
go
CREATE FUNCTION App.fnAdjustDateToBucket
	(
	@BucketDay smallint,
	@CurrentDate datetime
	)
RETURNS datetime
  AS
	BEGIN
	DECLARE @CurrentDay smallint
	DECLARE @Offset smallint
	DECLARE @AdjustedDay smallint
	
	SET @CurrentDay = DATEPART(dw, @CurrentDate)
	
	SET @AdjustedDay = CASE WHEN @CurrentDay > (7 - @@DATEFIRST + 1) THEN
				@CurrentDay - (7 - @@DATEFIRST + 1)
			ELSE
				@CurrentDay + (@@DATEFIRST - 1)
			END

	SET @Offset = CASE WHEN @BucketDay <= @AdjustedDay THEN
				@BucketDay - @AdjustedDay
			ELSE
				(7 - (@BucketDay - @AdjustedDay)) * -1
			END
	
		
	RETURN DATEADD(dd, @Offset, @CurrentDate)
	END
go
CREATE FUNCTION App.fnWeekDay
	(
	@Date datetime
	)
RETURNS smallint
    AS
	BEGIN
	DECLARE @CurrentDay smallint
	SET @CurrentDay = DATEPART(dw, @Date)
	RETURN 	CASE WHEN @CurrentDay > (7 - @@DATEFIRST + 1) THEN
				@CurrentDay - (7 - @@DATEFIRST + 1)
			ELSE
				@CurrentDay + (@@DATEFIRST - 1)
			END
	END
go
CREATE FUNCTION App.fnAdjustToCalendar
	(
	@SourceDate datetime,
	@OffsetDays int
	)
RETURNS DATETIME
AS
BEGIN
	
	DECLARE 
		  @OutputDate datetime = @SourceDate
		, @CalendarCode nvarchar(10)
		, @WorkingDay bit
		, @CurrentDay smallint
		, @Monday smallint
		, @Tuesday smallint
		, @Wednesday smallint
		, @Thursday smallint
		, @Friday smallint
		, @Saturday smallint
		, @Sunday smallint
			

	SELECT     @CalendarCode = App.tbCalendar.CalendarCode, @Monday = Monday, @Tuesday = Tuesday, @Wednesday = Wednesday, @Thursday = Thursday, @Friday = Friday, @Saturday = Saturday, @Sunday = Sunday
	FROM         App.tbCalendar INNER JOIN
							Usr.tbUser ON App.tbCalendar.CalendarCode = Usr.tbUser.CalendarCode
	WHERE UserId = (SELECT TOP (1) UserId FROM Usr.vwCredentials)
	
	WHILE @OffsetDays > -1
		BEGIN
		SET @CurrentDay = App.fnWeekDay(@OutputDate)
		IF @CurrentDay = 1				
			SET @WorkingDay = CASE WHEN @Monday != 0 THEN 1 ELSE 0 END
		ELSE IF @CurrentDay = 2
			SET @WorkingDay = CASE WHEN @Tuesday != 0 THEN 1 ELSE 0 END
		ELSE IF @CurrentDay = 3
			SET @WorkingDay = CASE WHEN @Wednesday != 0 THEN 1 ELSE 0 END
		ELSE IF @CurrentDay = 4
			SET @WorkingDay = CASE WHEN @Thursday != 0 THEN 1 ELSE 0 END
		ELSE IF @CurrentDay = 5
			SET @WorkingDay = CASE WHEN @Friday != 0 THEN 1 ELSE 0 END
		ELSE IF @CurrentDay = 6
			SET @WorkingDay = CASE WHEN @Saturday != 0 THEN 1 ELSE 0 END
		ELSE IF @CurrentDay = 7
			SET @WorkingDay = CASE WHEN @Sunday != 0 THEN 1 ELSE 0 END
		
		IF @WorkingDay = 1
			BEGIN
			IF NOT EXISTS(SELECT     UnavailableOn
						FROM         App.tbCalendarHoliday
						WHERE     (CalendarCode = @CalendarCode) AND (UnavailableOn = @OutputDate))
				SET @OffsetDays -= 1
			END
			
		IF @OffsetDays > -1
			SET @OutputDate = DATEADD(d, -1, @OutputDate)
		END
	
	RETURN @OutputDate				
END
go
CREATE FUNCTION App.fnDocInvoiceType
	(
	@InvoiceTypeCode SMALLINT
	)
RETURNS SMALLINT
AS
	BEGIN
	DECLARE @DocTypeCode SMALLINT
	
	SET @DocTypeCode = CASE @InvoiceTypeCode
		WHEN 0 THEN 4		--sales invoice
		WHEN 1 THEN 5		--credit note
		WHEN 3 THEN 6		--debit note
		ELSE 8				--error
		END
	
	RETURN @DocTypeCode
	END

go
CREATE FUNCTION App.fnOffsetDays(@StartOn DATE, @EndOn DATE)
RETURNS SMALLINT
AS
BEGIN

	DECLARE 
		@OffsetDays SMALLINT = 0		  
		, @CalendarCode nvarchar(10)
		, @WorkingDay bit
		, @CurrentDay smallint
		, @Monday smallint
		, @Tuesday smallint
		, @Wednesday smallint
		, @Thursday smallint
		, @Friday smallint
		, @Saturday smallint
		, @Sunday smallint
			
	
	IF DATEDIFF(DAY, @StartOn, @EndOn) <= 0
		RETURN 0

	SELECT     @CalendarCode = App.tbCalendar.CalendarCode, @Monday = Monday, @Tuesday = Tuesday, @Wednesday = Wednesday, @Thursday = Thursday, @Friday = Friday, @Saturday = Saturday, @Sunday = Sunday
	FROM         App.tbCalendar INNER JOIN
							Usr.tbUser ON App.tbCalendar.CalendarCode = Usr.tbUser.CalendarCode
	WHERE UserId = (SELECT TOP (1) UserId FROM Usr.vwCredentials)
	
	WHILE @EndOn <> @StartOn
		BEGIN
		
		SET @CurrentDay = App.fnWeekDay(@EndOn)
		IF @CurrentDay = 1				
			SET @WorkingDay = CASE WHEN @Monday != 0 THEN 1 ELSE 0 END
		ELSE IF @CurrentDay = 2
			SET @WorkingDay = CASE WHEN @Tuesday != 0 THEN 1 ELSE 0 END
		ELSE IF @CurrentDay = 3
			SET @WorkingDay = CASE WHEN @Wednesday != 0 THEN 1 ELSE 0 END
		ELSE IF @CurrentDay = 4
			SET @WorkingDay = CASE WHEN @Thursday != 0 THEN 1 ELSE 0 END
		ELSE IF @CurrentDay = 5
			SET @WorkingDay = CASE WHEN @Friday != 0 THEN 1 ELSE 0 END
		ELSE IF @CurrentDay = 6
			SET @WorkingDay = CASE WHEN @Saturday != 0 THEN 1 ELSE 0 END
		ELSE IF @CurrentDay = 7
			SET @WorkingDay = CASE WHEN @Sunday != 0 THEN 1 ELSE 0 END
		
		IF @WorkingDay = 1
			BEGIN
			IF NOT EXISTS(SELECT     UnavailableOn
						FROM         App.tbCalendarHoliday
						WHERE     (CalendarCode = @CalendarCode) AND (UnavailableOn = @EndOn))
				SET @OffsetDays += 1
			END
			
		SET @EndOn = DATEADD(d, -1, @EndOn)
		END

	
	RETURN @OffsetDays

END
go
CREATE FUNCTION App.fnParsePrimaryKey(@PK NVARCHAR(50)) RETURNS BIT
AS
	BEGIN
		DECLARE @ParseOk BIT = 0;

		SET @ParseOk = CASE		
				WHEN CHARINDEX('"', @PK) > 0 THEN 0	
				WHEN CHARINDEX('''', @PK) > 0 THEN 0	
				WHEN CHARINDEX(',', @PK) > 0 THEN 0	
				WHEN CHARINDEX('<', @PK) > 0 THEN 0	
				WHEN CHARINDEX('>', @PK) > 0 THEN 0	
				WHEN CHARINDEX('@', @PK) > 0 THEN 0	
				WHEN CHARINDEX(':', @PK) > 0 THEN 0	
				WHEN CHARINDEX('*', @PK) > 0 THEN 0	
				WHEN CHARINDEX('', @PK) > 0 THEN 0	
				WHEN CHARINDEX('', @PK) > 0 THEN 0	
				WHEN CHARINDEX('{', @PK) > 0 THEN 0	
				WHEN CHARINDEX('}', @PK) > 0 THEN 0	
				--WHEN CHARINDEX('_', @PK) > 0 THEN 0	
				--WHEN CHARINDEX('&', @PK) > 0 THEN 0	
				--WHEN CHARINDEX('/', @PK) > 0 THEN 0	
				--WHEN CHARINDEX('\', @PK) > 0 THEN 0	
				--WHEN CHARINDEX(' ', @PK) > 0 THEN 0	
				--WHEN CHARINDEX('(', @PK) > 0 THEN 0	
				--WHEN CHARINDEX(')', @PK) > 0 THEN 0	
				ELSE 1 END;

		RETURN @ParseOk;
	END
go
CREATE FUNCTION Org.fnContactFileAs(@ContactName nvarchar(100))
RETURNS NVARCHAR(100)
AS
BEGIN
	DECLARE @FileAs nvarchar(100)
		, @FirstNames nvarchar(100)
		, @LastName nvarchar(100)
		, @LastWordPos int;

	IF CHARINDEX(' ', @ContactName) = 0
		SET @FileAs = @ContactName
	ELSE
		BEGIN		
		SET @LastWordPos = CHARINDEX(' ', @ContactName) + 1
		WHILE CHARINDEX(' ', @ContactName, @LastWordPos) != 0
			SET @LastWordPos = CHARINDEX(' ', @ContactName, @LastWordPos) + 1
		
		SET @FirstNames = LEFT(@ContactName, @LastWordPos - 2)
		SET @LastName = RIGHT(@ContactName, LEN(@ContactName) - @LastWordPos + 1)
		SET @FileAs = @LastName + ', ' + @FirstNames
		END

	RETURN @FileAs
END
go
CREATE FUNCTION Task.fnEmailAddress
	(
	@TaskCode nvarchar(20)
	)
RETURNS nvarchar(255)
AS
	BEGIN
	DECLARE @EmailAddress nvarchar(255)

	IF EXISTS(SELECT     Org.tbContact.EmailAddress
		  FROM         Org.tbContact INNER JOIN
								tbTask ON Org.tbContact.AccountCode = Task.tbTask.AccountCode AND Org.tbContact.ContactName = Task.tbTask.ContactName
		  WHERE     ( Task.tbTask.TaskCode = @TaskCode)
		  GROUP BY Org.tbContact.EmailAddress
		  HAVING      (NOT ( Org.tbContact.EmailAddress IS NULL)))
		BEGIN
		SELECT    @EmailAddress = Org.tbContact.EmailAddress
		FROM         Org.tbContact INNER JOIN
							tbTask ON Org.tbContact.AccountCode = Task.tbTask.AccountCode AND Org.tbContact.ContactName = Task.tbTask.ContactName
		WHERE     ( Task.tbTask.TaskCode = @TaskCode)
		GROUP BY Org.tbContact.EmailAddress
		HAVING      (NOT ( Org.tbContact.EmailAddress IS NULL))	
		END
	ELSE
		BEGIN
		SELECT    @EmailAddress =  Org.tbOrg.EmailAddress
		FROM         Org.tbOrg INNER JOIN
							 Task.tbTask ON Org.tbOrg.AccountCode = Task.tbTask.AccountCode
		WHERE     ( Task.tbTask.TaskCode = @TaskCode)
		END
	
	RETURN @EmailAddress
	END

go
CREATE FUNCTION Task.fnIsExpense
	(
	@TaskCode nvarchar(20)
	)
RETURNS bit
AS
	BEGIN
	/* An expense is a task assigned to an outgoing cash code that is not linked to a sale */
	DECLARE @IsExpense bit
	IF EXISTS (SELECT     Task.tbTask.TaskCode
	           FROM         Task.tbTask INNER JOIN
	                                 Cash.tbCode ON Task.tbTask.CashCode = Cash.tbCode.CashCode INNER JOIN
	                                 Cash.tbCategory ON Cash.tbCode.CategoryCode = Cash.tbCategory.CategoryCode
	           WHERE     ( Cash.tbCategory.CashModeCode = 1) AND ( Task.tbTask.TaskCode = @TaskCode))
		SET @IsExpense = 0			          
	ELSE IF EXISTS(SELECT     ParentTaskCode
	          FROM         Task.tbFlow
	          WHERE     (ChildTaskCode = @TaskCode))
		BEGIN
		DECLARE @ParentTaskCode nvarchar(20)
		SELECT  @ParentTaskCode = ParentTaskCode
		FROM         Task.tbFlow
		WHERE     (ChildTaskCode = @TaskCode)		
		SET @IsExpense = Task.fnIsExpense(@ParentTaskCode)		
		END	              
	ELSE
		SET @IsExpense = 1
			
	RETURN @IsExpense
	END

go

-- VIEWS
go
--VIEW dependencies
go
CREATE FUNCTION App.fnBuckets
	(@CurrentDate datetime)
RETURNS  @tbBkn TABLE (Period smallint, BucketId nvarchar(10), StartDate datetime, EndDate datetime)
  AS
	BEGIN
	DECLARE @BucketTypeCode smallint
	DECLARE @UnitOfTimeCode smallint
	DECLARE @Period smallint	
	DECLARE @CurrentPeriod smallint
	DECLARE @Offset smallint
	
	DECLARE @StartDate datetime
	DECLARE @EndDate datetime
	DECLARE @BucketId nvarchar(10)
		
	SELECT     TOP 1 @BucketTypeCode = BucketTypeCode, @UnitOfTimeCode = BucketIntervalCode
	FROM         App.tbOptions
		
	SET @EndDate = 
		CASE @BucketTypeCode
			WHEN 0 THEN
				@CurrentDate
			WHEN 8 THEN
				DATEADD(d, Day(@CurrentDate) * -1 + 1, @CurrentDate)
			ELSE
				App.fnAdjustDateToBucket(@BucketTypeCode, @CurrentDate)
		END
			
	SET @EndDate = CAST(@EndDate AS date)
	SET @StartDate = DATEADD(yyyy, -100, @EndDate)
	SET @CurrentPeriod = 0
	
	DECLARE curBk cursor for			
		SELECT     Period, BucketId
		FROM         App.tbBucket
		ORDER BY Period

	OPEN curBk
	FETCH NEXT FROM curBk INTO @Period, @BucketId
	WHILE @@FETCH_STATUS = 0
		BEGIN
		IF @Period > 0
			BEGIN
			SET @StartDate = @EndDate
			SET @Offset = @Period - @CurrentPeriod
			SET @EndDate = CASE @UnitOfTimeCode
				WHEN 0 THEN		--day
					DATEADD(d, @Offset, @StartDate) 					
				WHEN 1 THEN		--week
					DATEADD(d, @Offset * 7, @StartDate)
				WHEN 2 THEN		--month
					DATEADD(m, @Offset, @StartDate)
				END
			END
		
		INSERT INTO @tbBkn(Period, BucketId, StartDate, EndDate)
		VALUES (@Period, @BucketId, @StartDate, @EndDate)
		
		SET @CurrentPeriod = @Period
		
		FETCH NEXT FROM curBk INTO @Period, @BucketId
		END		
			
	RETURN
	END
go
CREATE FUNCTION Cash.fnTaxTypeDueDates(@TaxTypeCode smallint)
RETURNS @tbDueDate TABLE (PayOn datetime, PayFrom datetime, PayTo datetime)
 AS
	BEGIN
	DECLARE @MonthNumber smallint
			, @TaxMonth smallint
			, @MonthInterval smallint
			, @StartOn datetime
	
		SELECT 
			@TaxMonth = MonthNumber, 
			@MonthInterval = CASE RecurrenceCode
								WHEN 0 THEN 1
								WHEN 1 THEN 1
								WHEN 2 THEN 3
								WHEN 3 THEN 6
								WHEN 4 THEN 12
							END
		FROM Cash.tbTaxType
		WHERE TaxTypeCode = @TaxTypeCode
				
		IF @TaxTypeCode = 0
			GOTO CorporationTax;
		ELSE
			GOTO DefaultTaxType;

	Finalise:

		UPDATE @tbDueDate
		SET PayOn = DATEADD(DAY, (SELECT OffsetDays FROM Cash.tbTaxType WHERE TaxTypeCode = @TaxTypeCode), PayOn)

		RETURN;

	DefaultTaxType:
	
		SET @MonthNumber = @TaxMonth

		SELECT   @StartOn = MIN(StartOn)
		FROM         App.tbYearPeriod
		WHERE     (MonthNumber = @MonthNumber)

		INSERT INTO @tbDueDate (PayOn) VALUES (@StartOn)
	
		SET @MonthNumber = CASE 
			WHEN (@MonthNumber + @MonthInterval) <= 12 THEN @MonthNumber + @MonthInterval
			ELSE (@MonthNumber + @MonthInterval) % 12
			END
	
		WHILE EXISTS(SELECT     *
					 FROM         App.tbYearPeriod
					 WHERE     (StartOn > @StartOn) AND (MonthNumber = @MonthNumber))
		BEGIN
			SELECT @StartOn = MIN(StartOn)
			FROM         App.tbYearPeriod
			WHERE     (StartOn > @StartOn) AND (MonthNumber = @MonthNumber)
			ORDER BY MIN(StartOn)		
			INSERT INTO @tbDueDate (PayOn) VALUES (@StartOn)
		
			SET @MonthNumber = CASE WHEN (@MonthNumber + @MonthInterval) <= 12 THEN @MonthNumber + @MonthInterval
									ELSE (@MonthNumber + @MonthInterval) % 12 END;	
		END;

		WITH dd AS
		(
			SELECT PayOn, LAG(PayOn) OVER (ORDER BY PayOn) AS PayFrom
			FROM @tbDueDate 
		)
		UPDATE @tbDueDate
		SET PayTo = dd.PayOn, PayFrom = dd.PayFrom
		FROM @tbDueDate tbDueDate JOIN dd ON tbDueDate.PayOn = dd.PayOn;

		UPDATE @tbDueDate
		SET PayFrom = DATEADD(MONTH, @MonthInterval * -1, PayTo)
		WHERE PayTo = (SELECT MIN(PayTo) FROM @tbDueDate);

		GOTO Finalise

	CorporationTax:

		SELECT   @StartOn = StartOn, @MonthNumber = MonthNumber
		FROM         App.tbYearPeriod
		WHERE StartOn = (SELECT MIN(StartOn) FROM App.tbYearPeriod)

		INSERT INTO @tbDueDate (PayFrom) VALUES (@StartOn)

		SET @MonthNumber = CASE 
			WHEN (@MonthNumber + @MonthInterval) <= 12 THEN @MonthNumber + @MonthInterval
			ELSE (@MonthNumber + @MonthInterval) % 12
			END
	
		WHILE EXISTS(SELECT     *
					 FROM         App.tbYearPeriod
					 WHERE     (StartOn > @StartOn) AND (MonthNumber = @MonthNumber))
		BEGIN
			SELECT @StartOn = MIN(StartOn)
			FROM         App.tbYearPeriod
			WHERE     (StartOn > @StartOn) AND (MonthNumber = @MonthNumber)
			ORDER BY MIN(StartOn)		
			INSERT INTO @tbDueDate (PayFrom) VALUES (@StartOn)
		
			SET @MonthNumber = CASE WHEN (@MonthNumber + @MonthInterval) <= 12 THEN @MonthNumber + @MonthInterval
									ELSE (@MonthNumber + @MonthInterval) % 12 END;	
		END;

		WITH dd AS
		(
			SELECT PayFrom, LEAD(PayFrom) OVER (ORDER BY PayFrom) AS PayTo
			FROM @tbDueDate 
		)
		UPDATE @tbDueDate
		SET PayTo = dd.PayTo
		FROM @tbDueDate tbDueDate JOIN dd ON tbDueDate.PayFrom = dd.PayFrom;

		DELETE FROM @tbDueDate WHERE PayTo IS NULL;

		SET @StartOn = (SELECT MIN(PayFrom) FROM @tbDueDate)		
		SELECT @MonthNumber = DATEDIFF(MONTH, @StartOn, MIN(StartOn)) FROM App.tbYearPeriod
		WHERE MonthNumber = @TaxMonth AND StartOn >= @StartOn

		UPDATE @tbDueDate
		SET PayOn = DATEADD(MONTH, @MonthNumber, PayTo)

		GOTO Finalise
	RETURN	
	END
go
CREATE FUNCTION App.fnActivePeriod	()
RETURNS @tbSystemYearPeriod TABLE (YearNumber smallint, StartOn datetime, EndOn datetime, MonthName nvarchar(10), Description nvarchar(10), MonthNumber smallint) 
   AS
	BEGIN
	DECLARE @StartOn datetime
	DECLARE @EndOn datetime
	
	IF EXISTS (	SELECT     StartOn	FROM App.tbYearPeriod WHERE (CashStatusCode < 2))
		BEGIN
		SELECT @StartOn = MIN(StartOn)
		FROM         App.tbYearPeriod
		WHERE     (CashStatusCode < 2)
		
		IF EXISTS (SELECT StartOn FROM App.tbYearPeriod WHERE StartOn > @StartOn)
			SELECT TOP 1 @EndOn = StartOn FROM App.tbYearPeriod WHERE StartOn > @StartOn order by StartOn
		ELSE
			SET @EndOn = DATEADD(m, 1, @StartOn)
			
		INSERT INTO @tbSystemYearPeriod (YearNumber, StartOn, EndOn, MonthName, Description, MonthNumber)
		SELECT     App.tbYearPeriod.YearNumber, App.tbYearPeriod.StartOn, @EndOn, App.tbMonth.MonthName, App.tbYear.Description, App.tbMonth.MonthNumber
		FROM         App.tbYearPeriod INNER JOIN
		                      App.tbMonth ON App.tbYearPeriod.MonthNumber = App.tbMonth.MonthNumber INNER JOIN
		                      App.tbYear ON App.tbYearPeriod.YearNumber = App.tbYear.YearNumber
		WHERE     ( App.tbYearPeriod.StartOn = @StartOn)
		END	
	RETURN
	END
go
--end
go
CREATE VIEW Task.vwBucket
AS
SELECT        task.TaskCode, task.ActionOn, buckets.Period, buckets.BucketId
FROM            Task.tbTask AS task CROSS APPLY
			(	SELECT  buckets.Period, buckets.BucketId
				FROM        App.fnBuckets(CURRENT_TIMESTAMP) buckets 
				WHERE     (StartDate <= task.ActionOn) AND (EndDate > task.ActionOn)) AS buckets
go
CREATE VIEW Task.vwTasks
AS
SELECT        Task.tbTask.TaskCode, Task.tbTask.UserId, Task.tbTask.AccountCode, Task.tbTask.ContactName, Task.tbTask.ActivityCode, Task.tbTask.TaskTitle, Task.tbTask.TaskStatusCode, Task.tbTask.ActionById, 
                         Task.tbTask.ActionOn, Task.tbTask.ActionedOn, Task.tbTask.PaymentOn, Task.tbTask.SecondReference, Task.tbTask.TaskNotes, Task.tbTask.TaxCode, Task.tbTask.Quantity, Task.tbTask.UnitCharge, 
                         Task.tbTask.TotalCharge, Task.tbTask.AddressCodeFrom, Task.tbTask.AddressCodeTo, Task.tbTask.Printed, Task.tbTask.Spooled, Task.tbTask.InsertedBy, Task.tbTask.InsertedOn, Task.tbTask.UpdatedBy, 
                         Task.tbTask.UpdatedOn, Task.vwBucket.Period, Task.vwBucket.BucketId, TaskStatus.TaskStatus, Task.tbTask.CashCode, Cash.tbCode.CashDescription, tbUser_1.UserName AS OwnerName, 
                         Usr.tbUser.UserName AS ActionName, Org.tbOrg.AccountName, OrgStatus.OrganisationStatus, Org.tbType.OrganisationType, CASE WHEN Cash.tbCategory.CategoryCode IS NULL 
                         THEN Org.tbType.CashModeCode ELSE Cash.tbCategory.CashModeCode END AS CashModeCode, Task.tbTask.RowVer
FROM            Usr.tbUser INNER JOIN
                         Task.tbStatus AS TaskStatus INNER JOIN
                         Org.tbType INNER JOIN
                         Org.tbOrg ON Org.tbType.OrganisationTypeCode = Org.tbOrg.OrganisationTypeCode INNER JOIN
                         Org.tbStatus AS OrgStatus ON Org.tbOrg.OrganisationStatusCode = OrgStatus.OrganisationStatusCode INNER JOIN
                         Task.tbTask ON Org.tbOrg.AccountCode = Task.tbTask.AccountCode ON TaskStatus.TaskStatusCode = Task.tbTask.TaskStatusCode ON Usr.tbUser.UserId = Task.tbTask.ActionById INNER JOIN
                         Usr.tbUser AS tbUser_1 ON Task.tbTask.UserId = tbUser_1.UserId INNER JOIN
                         Task.vwBucket ON Task.tbTask.TaskCode = Task.vwBucket.TaskCode LEFT OUTER JOIN
                         Cash.tbCode ON Task.tbTask.CashCode = Cash.tbCode.CashCode LEFT OUTER JOIN
                         Cash.tbCategory ON Cash.tbCode.CategoryCode = Cash.tbCategory.CategoryCode
go
CREATE VIEW Invoice.vwCandidateSales
AS
SELECT TOP 100 PERCENT TaskCode, AccountCode, ContactName, ActivityCode, ActionOn, ActionedOn, TaskTitle, Quantity, UnitCharge, TotalCharge, TaskNotes, CashDescription, ActionName, OwnerName, TaskStatus, InsertedBy, 
                         InsertedOn, UpdatedBy, UpdatedOn, TaskStatusCode
FROM            Task.vwTasks
WHERE        (TaskStatusCode = 1 OR
                         TaskStatusCode = 2) AND (CashModeCode = 1) AND (CashCode IS NOT NULL)
ORDER BY ActionOn;
go
CREATE VIEW Invoice.vwCandidatePurchases
AS
SELECT TOP 100 PERCENT  TaskCode, AccountCode, ContactName, ActivityCode, ActionOn, ActionedOn, Quantity, UnitCharge, TotalCharge, TaskTitle, TaskNotes, CashDescription, ActionName, OwnerName, TaskStatus, InsertedBy, 
                         InsertedOn, UpdatedBy, UpdatedOn, TaskStatusCode
FROM            Task.vwTasks
WHERE        (TaskStatusCode = 1 OR
                         TaskStatusCode = 2) AND (CashModeCode = 0) AND (CashCode IS NOT NULL)
ORDER BY ActionOn;
go
CREATE VIEW Invoice.vwRegisterItems
AS
	SELECT       (SELECT TOP (1) p.StartOn FROM App.tbYearPeriod p WHERE (p.StartOn <= Invoice.tbInvoice.InvoicedOn) ORDER BY p.StartOn DESC) AS StartOn,  
					Invoice.tbInvoice.InvoiceNumber, Invoice.tbItem.CashCode AS TaskCode, Cash.tbCode.CashCode, Cash.tbCode.CashDescription, 
							 Invoice.tbItem.TaxCode, App.tbTaxCode.TaxDescription, Invoice.tbInvoice.AccountCode, Invoice.tbInvoice.InvoiceTypeCode, Invoice.tbInvoice.InvoiceStatusCode, Invoice.tbInvoice.InvoicedOn, 
							 CASE WHEN Invoice.tbType.CashModeCode = 0 THEN Invoice.tbItem.InvoiceValue * - 1 ELSE Invoice.tbItem.InvoiceValue END AS InvoiceValue, 
							 CASE WHEN Invoice.tbType.CashModeCode = 0 THEN Invoice.tbItem.TaxValue * - 1 ELSE Invoice.tbItem.TaxValue END AS TaxValue, 
							 CASE WHEN Invoice.tbType.CashModeCode = 0 THEN Invoice.tbItem.PaidValue * - 1 ELSE Invoice.tbItem.PaidValue END AS PaidValue, 
							 CASE WHEN Invoice.tbType.CashModeCode = 0 THEN Invoice.tbItem.PaidTaxValue * - 1 ELSE Invoice.tbItem.PaidTaxValue END AS PaidTaxValue, Invoice.tbInvoice.PaymentTerms, Invoice.tbInvoice.Printed, 
							 Org.tbOrg.AccountName, Usr.tbUser.UserName, Invoice.tbStatus.InvoiceStatus, Invoice.tbType.CashModeCode, Invoice.tbType.InvoiceType
	FROM            Invoice.tbInvoice INNER JOIN
							 Org.tbOrg ON Invoice.tbInvoice.AccountCode = Org.tbOrg.AccountCode INNER JOIN
							 Invoice.tbType ON Invoice.tbInvoice.InvoiceTypeCode = Invoice.tbType.InvoiceTypeCode INNER JOIN
							 Invoice.tbStatus ON Invoice.tbInvoice.InvoiceStatusCode = Invoice.tbStatus.InvoiceStatusCode INNER JOIN
							 Usr.tbUser ON Invoice.tbInvoice.UserId = Usr.tbUser.UserId INNER JOIN
							 Invoice.tbItem ON Invoice.tbInvoice.InvoiceNumber = Invoice.tbItem.InvoiceNumber INNER JOIN
							 Cash.tbCode ON Invoice.tbItem.CashCode = Cash.tbCode.CashCode LEFT OUTER JOIN
							 App.tbTaxCode ON Invoice.tbItem.TaxCode = App.tbTaxCode.TaxCode;
go
CREATE VIEW Invoice.vwRegisterTasks
AS
	SELECT       (SELECT TOP (1) p.StartOn FROM App.tbYearPeriod p WHERE (p.StartOn <= Invoice.tbInvoice.InvoicedOn) ORDER BY p.StartOn DESC) AS StartOn,  
			Invoice.tbInvoice.InvoiceNumber, InvoiceTask.TaskCode, Task.TaskTitle, Cash.tbCode.CashCode, Cash.tbCode.CashDescription, 
							 InvoiceTask.TaxCode, App.tbTaxCode.TaxDescription, Invoice.tbInvoice.AccountCode, Invoice.tbInvoice.InvoiceTypeCode, Invoice.tbInvoice.InvoiceStatusCode, Invoice.tbInvoice.InvoicedOn, 
							 CASE WHEN Invoice.tbType.CashModeCode = 0 THEN InvoiceTask.InvoiceValue * - 1 ELSE InvoiceTask.InvoiceValue END AS InvoiceValue, 
							 CASE WHEN Invoice.tbType.CashModeCode = 0 THEN InvoiceTask.TaxValue * - 1 ELSE InvoiceTask.TaxValue END AS TaxValue, 
							 CASE WHEN Invoice.tbType.CashModeCode = 0 THEN InvoiceTask.PaidValue * - 1 ELSE InvoiceTask.PaidValue END AS PaidValue, 
							 CASE WHEN Invoice.tbType.CashModeCode = 0 THEN InvoiceTask.PaidTaxValue * - 1 ELSE InvoiceTask.PaidTaxValue END AS PaidTaxValue, Invoice.tbInvoice.PaymentTerms, Invoice.tbInvoice.Printed, 
							 Org.tbOrg.AccountName, Usr.tbUser.UserName, Invoice.tbStatus.InvoiceStatus, Invoice.tbType.CashModeCode, Invoice.tbType.InvoiceType
	FROM            Invoice.tbInvoice INNER JOIN
							 Org.tbOrg ON Invoice.tbInvoice.AccountCode = Org.tbOrg.AccountCode INNER JOIN
							 Invoice.tbType ON Invoice.tbInvoice.InvoiceTypeCode = Invoice.tbType.InvoiceTypeCode INNER JOIN
							 Invoice.tbStatus ON Invoice.tbInvoice.InvoiceStatusCode = Invoice.tbStatus.InvoiceStatusCode INNER JOIN
							 Usr.tbUser ON Invoice.tbInvoice.UserId = Usr.tbUser.UserId INNER JOIN
							 Invoice.tbTask AS InvoiceTask ON Invoice.tbInvoice.InvoiceNumber = InvoiceTask.InvoiceNumber INNER JOIN
							 Cash.tbCode ON InvoiceTask.CashCode = Cash.tbCode.CashCode INNER JOIN
							 Task.tbTask AS Task ON InvoiceTask.TaskCode = Task.TaskCode AND InvoiceTask.TaskCode = Task.TaskCode LEFT OUTER JOIN
							 App.tbTaxCode ON InvoiceTask.TaxCode = App.tbTaxCode.TaxCode;
go
CREATE VIEW Invoice.vwRegisterDetail
AS
	WITH register AS
	(
		SELECT     StartOn, InvoiceNumber, TaskCode, CashCode, CashDescription, TaxCode, TaxDescription, AccountCode, InvoiceTypeCode, InvoiceStatusCode, 
							  InvoicedOn, InvoiceValue, TaxValue, PaidValue, PaidTaxValue, PaymentTerms, Printed, AccountName, UserName, InvoiceStatus, CashModeCode, 
							  InvoiceType
		FROM         Invoice.vwRegisterTasks
		UNION
		SELECT     StartOn, InvoiceNumber, TaskCode, CashCode, CashDescription, TaxCode, TaxDescription, AccountCode, InvoiceTypeCode, InvoiceStatusCode, 
							  InvoicedOn, InvoiceValue, TaxValue, PaidValue, PaidTaxValue, PaymentTerms, Printed, AccountName, UserName, InvoiceStatus, CashModeCode, 
							  InvoiceType
		FROM         Invoice.vwRegisterItems
	)
	SELECT *, (InvoiceValue)+TaxValue-(PaidValue+PaidTaxValue) AS UnpaidValue FROM register;
go
CREATE VIEW Invoice.vwRegisterCashCodes
AS
	SELECT TOP 100 PERCENT StartOn, CashCode, CashDescription, SUM(InvoiceValue) AS TotalInvoiceValue, SUM(TaxValue) AS TotalTaxValue
	FROM            Invoice.vwRegisterDetail
	GROUP BY StartOn, CashCode, CashDescription
	ORDER BY StartOn, CashCode;
go
CREATE VIEW Invoice.vwRegister
AS
	SELECT       (SELECT TOP (1) p.StartOn FROM App.tbYearPeriod p WHERE (p.StartOn <= Invoice.tbInvoice.InvoicedOn) ORDER BY p.StartOn DESC) AS StartOn,  
			Invoice.tbInvoice.InvoiceNumber, Invoice.tbInvoice.AccountCode, Invoice.tbInvoice.InvoiceTypeCode, Invoice.tbInvoice.InvoiceStatusCode, 
							 Invoice.tbInvoice.InvoicedOn, CASE WHEN Invoice.tbType.CashModeCode = 0 THEN Invoice.tbInvoice.InvoiceValue * - 1 ELSE Invoice.tbInvoice.InvoiceValue END AS InvoiceValue, 
							 CASE WHEN Invoice.tbType.CashModeCode = 0 THEN Invoice.tbInvoice.TaxValue * - 1 ELSE Invoice.tbInvoice.TaxValue END AS TaxValue, 
							 CASE WHEN Invoice.tbType.CashModeCode = 0 THEN Invoice.tbInvoice.PaidValue * - 1 ELSE Invoice.tbInvoice.PaidValue END AS PaidValue, 
							 CASE WHEN Invoice.tbType.CashModeCode = 0 THEN Invoice.tbInvoice.PaidTaxValue * - 1 ELSE Invoice.tbInvoice.PaidTaxValue END AS PaidTaxValue, Invoice.tbInvoice.PaymentTerms, Invoice.tbInvoice.Notes, 
							 Invoice.tbInvoice.Printed, Org.tbOrg.AccountName, Usr.tbUser.UserName, Invoice.tbStatus.InvoiceStatus, Invoice.tbType.CashModeCode, Invoice.tbType.InvoiceType
	FROM            Invoice.tbInvoice INNER JOIN
							 Org.tbOrg ON Invoice.tbInvoice.AccountCode = Org.tbOrg.AccountCode INNER JOIN
							 Invoice.tbType ON Invoice.tbInvoice.InvoiceTypeCode = Invoice.tbType.InvoiceTypeCode INNER JOIN
							 Invoice.tbStatus ON Invoice.tbInvoice.InvoiceStatusCode = Invoice.tbStatus.InvoiceStatusCode INNER JOIN
							 Usr.tbUser ON Invoice.tbInvoice.UserId = Usr.tbUser.UserId
	WHERE        (Invoice.tbInvoice.AccountCode <> (SELECT AccountCode FROM App.tbOptions));
go
CREATE VIEW Invoice.vwRegisterPurchases
AS
SELECT        StartOn, InvoiceNumber, AccountCode, InvoiceTypeCode, InvoiceStatusCode, InvoicedOn, InvoiceValue, TaxValue, PaidValue, PaidTaxValue, PaymentTerms, Notes, Printed, AccountName, UserName, 
                         InvoiceStatus, CashModeCode, InvoiceType, (InvoiceValue + TaxValue) - (PaidValue + PaidTaxValue) AS UnpaidValue
FROM            Invoice.vwRegister
WHERE        (InvoiceTypeCode > 1);
go
CREATE VIEW Invoice.vwRegisterPurchaseTasks
AS
SELECT        StartOn, InvoiceNumber, TaskCode, CashCode, CashDescription, TaxCode, TaxDescription, AccountCode, InvoiceTypeCode, InvoiceStatusCode, InvoicedOn, InvoiceValue, TaxValue, PaidValue, PaidTaxValue, 
                         PaymentTerms, Printed, AccountName, UserName, InvoiceStatus, CashModeCode, InvoiceType, (InvoiceValue + TaxValue) - (PaidValue + PaidTaxValue) AS UnpaidValue
FROM            Invoice.vwRegisterDetail
WHERE        (InvoiceTypeCode > 1);
go
CREATE VIEW Invoice.vwRegisterSales
AS
SELECT        StartOn, InvoiceNumber, AccountCode, InvoiceTypeCode, InvoiceStatusCode, InvoicedOn, InvoiceValue, TaxValue, PaidValue, PaidTaxValue, PaymentTerms, Notes, Printed, AccountName, UserName, 
                         InvoiceStatus, CashModeCode, InvoiceType, (InvoiceValue + TaxValue) - (PaidValue + PaidTaxValue) AS UnpaidValue
FROM            Invoice.vwRegister
WHERE        (InvoiceTypeCode < 2);
go
CREATE VIEW Invoice.vwRegisterSaleTasks
AS
SELECT        StartOn, InvoiceNumber, TaskCode, CashCode, CashDescription, TaxCode, TaxDescription, AccountCode, InvoiceTypeCode, InvoiceStatusCode, InvoicedOn, InvoiceValue, TaxValue, PaidValue, PaidTaxValue, 
                         PaymentTerms, Printed, AccountName, UserName, InvoiceStatus, CashModeCode, InvoiceType, (InvoiceValue + TaxValue) - (PaidValue + PaidTaxValue) AS UnpaidValue
FROM            Invoice.vwRegisterDetail
WHERE        (InvoiceTypeCode < 2);
go
CREATE VIEW Org.vwPurchases
AS
SELECT        AccountCode, TaskCode, UserId, ContactName, ActivityCode, TaskTitle, TaskStatusCode, ActionById, ActionOn, ActionedOn, PaymentOn, SecondReference, TaskNotes, TaxCode, Quantity, UnitCharge, TotalCharge, 
                         AddressCodeFrom, AddressCodeTo, Printed, Spooled, InsertedBy, InsertedOn, UpdatedBy, UpdatedOn, Period, BucketId, TaskStatus, CashCode, CashDescription, OwnerName, ActionName, AccountName, 
                         OrganisationStatus, OrganisationType, CashModeCode
FROM            Task.vwTasks
WHERE        (CashModeCode = 0) AND (CashCode IS NOT NULL);
go
CREATE VIEW Org.vwSales
AS
SELECT        AccountCode, TaskCode, UserId, ContactName, ActivityCode, TaskTitle, TaskStatusCode, ActionById, ActionOn, ActionedOn, PaymentOn, SecondReference, TaskNotes, TaxCode, Quantity, UnitCharge, TotalCharge, 
                         AddressCodeFrom, AddressCodeTo, Printed, Spooled, InsertedBy, InsertedOn, UpdatedBy, UpdatedOn, Period, BucketId, TaskStatus, CashCode, CashDescription, OwnerName, ActionName, AccountName, 
                         OrganisationStatus, OrganisationType, CashModeCode
FROM            Task.vwTasks
WHERE        (CashModeCode = 1) AND (CashCode IS NOT NULL);
go
CREATE VIEW Task.vwOrgActivity
AS
SELECT AccountCode, TaskStatusCode, ActionOn, TaskTitle, ActivityCode, ActionById, TaskCode, Period, BucketId, ContactName, TaskStatus, TaskNotes, ActionedOn, OwnerName, CashCode, CashDescription, Quantity, 
                         UnitCharge, TotalCharge, AddressCodeFrom, AddressCodeTo, Printed, InsertedBy, InsertedOn, UpdatedBy, UpdatedOn, AccountName, ActionName
FROM            Task.vwTasks
WHERE        (TaskStatusCode < 2);

go
CREATE VIEW Task.vwActiveData
AS
SELECT        TaskCode, UserId, AccountCode, ContactName, ActivityCode, TaskTitle, TaskStatusCode, ActionById, ActionOn, ActionedOn, PaymentOn, SecondReference, TaskNotes, TaxCode, Quantity, UnitCharge, TotalCharge, 
                         AddressCodeFrom, AddressCodeTo, Printed, Spooled, InsertedBy, InsertedOn, UpdatedBy, UpdatedOn, Period, BucketId, TaskStatus, CashCode, CashDescription, OwnerName, ActionName, AccountName, 
                         OrganisationStatus, OrganisationType, CashModeCode
FROM            Task.vwTasks
WHERE        (TaskStatusCode = 1);
go
CREATE VIEW Task.vwPurchases
AS
SELECT        Task.vwTasks.TaskCode, Task.vwTasks.ActivityCode, Task.vwTasks.TaskStatusCode, Task.vwTasks.ActionOn, Task.vwTasks.ActionById, Task.vwTasks.TaskTitle, Task.vwTasks.Period, Task.vwTasks.BucketId, 
                         Task.vwTasks.AccountCode, Task.vwTasks.ContactName, Task.vwTasks.TaskStatus, Task.vwTasks.TaskNotes, Task.vwTasks.ActionedOn, Task.vwTasks.OwnerName, Task.vwTasks.CashCode, 
                         Task.vwTasks.CashDescription, Task.vwTasks.Quantity, Activity.tbActivity.UnitOfMeasure, Task.vwTasks.UnitCharge, Task.vwTasks.TotalCharge, Org_tbAddress_1.Address AS FromAddress, 
                         Org.tbAddress.Address AS ToAddress, Task.vwTasks.Printed, Task.vwTasks.InsertedBy, Task.vwTasks.InsertedOn, Task.vwTasks.UpdatedBy, Task.vwTasks.UpdatedOn, Task.vwTasks.AccountName, 
                         Task.vwTasks.ActionName, Task.vwTasks.SecondReference
FROM            Task.vwTasks LEFT OUTER JOIN
                         Org.tbAddress AS Org_tbAddress_1 ON Task.vwTasks.AddressCodeFrom = Org_tbAddress_1.AddressCode LEFT OUTER JOIN
                         Org.tbAddress ON Task.vwTasks.AddressCodeTo = Org.tbAddress.AddressCode INNER JOIN
                         Activity.tbActivity ON Task.vwTasks.ActivityCode = Activity.tbActivity.ActivityCode
WHERE        (Task.vwTasks.CashCode IS NOT NULL) AND (Task.vwTasks.CashModeCode = 0);
go
CREATE VIEW Task.vwSales
AS
SELECT        Task.vwTasks.TaskCode, Task.vwTasks.ActivityCode, Task.vwTasks.TaskStatusCode, Task.vwTasks.ActionOn, Task.vwTasks.ActionById, Task.vwTasks.TaskTitle, Task.vwTasks.Period, Task.vwTasks.BucketId, 
                         Task.vwTasks.AccountCode, Task.vwTasks.ContactName, Task.vwTasks.TaskStatus, Task.vwTasks.TaskNotes, Task.vwTasks.ActionedOn, Task.vwTasks.OwnerName, Task.vwTasks.CashCode, 
                         Task.vwTasks.CashDescription, Task.vwTasks.Quantity, Activity.tbActivity.UnitOfMeasure, Task.vwTasks.UnitCharge, Task.vwTasks.TotalCharge, Org_tbAddress_1.Address AS FromAddress, 
                         Org.tbAddress.Address AS ToAddress, Task.vwTasks.Printed, Task.vwTasks.InsertedBy, Task.vwTasks.InsertedOn, Task.vwTasks.UpdatedBy, Task.vwTasks.UpdatedOn, Task.vwTasks.AccountName, 
                         Task.vwTasks.ActionName, Task.vwTasks.SecondReference
FROM            Task.vwTasks LEFT OUTER JOIN
                         Org.tbAddress AS Org_tbAddress_1 ON Task.vwTasks.AddressCodeFrom = Org_tbAddress_1.AddressCode LEFT OUTER JOIN
                         Org.tbAddress ON Task.vwTasks.AddressCodeTo = Org.tbAddress.AddressCode INNER JOIN
                         Activity.tbActivity ON Task.vwTasks.ActivityCode = Activity.tbActivity.ActivityCode
WHERE        (Task.vwTasks.CashCode IS NOT NULL) AND (Task.vwTasks.CashModeCode = 1);
go

CREATE VIEW Org.vwPaymentCode
AS
	SELECT CONCAT((SELECT UserId FROM Usr.vwCredentials), '_', FORMAT(CURRENT_TIMESTAMP, 'yyyymmdd_hhmmss')) AS PaymentCode
go
CREATE VIEW Cash.vwBankCashCodes
AS
SELECT        Cash.tbCode.CashCode, Cash.tbCode.CashDescription, Cash.tbCode.TaxCode, Cash.tbCategory.CashModeCode
FROM            Cash.tbCode INNER JOIN
                         Cash.tbCategory ON Cash.tbCode.CategoryCode = Cash.tbCategory.CategoryCode
WHERE        (Cash.tbCategory.CashTypeCode = 2)
go
CREATE VIEW Cash.vwAccountStatement
  AS
	WITH entries AS
	(
		SELECT  payment.CashAccountCode, payment.CashCode, ROW_NUMBER() OVER (PARTITION BY payment.CashAccountCode ORDER BY PaidOn) AS EntryNumber, PaymentCode, PaidOn, 
			CASE WHEN PaidInValue > 0 THEN PaidInValue ELSE PaidOutValue * - 1 END AS Paid
		FROM         Org.tbPayment payment INNER JOIN Org.tbAccount ON payment.CashAccountCode = Org.tbAccount.CashAccountCode
		WHERE     (PaymentStatusCode = 1) AND (AccountClosed = 0)		
		UNION
		SELECT        
			CashAccountCode, 
			CASE WHEN OpeningBalance< 0 THEN (SELECT CashCode FROM Cash.vwBankCashCodes WHERE CashModeCode = 0)
				WHEN OpeningBalance > 0 THEN  (SELECT CashCode FROM Cash.vwBankCashCodes WHERE CashModeCode = 1)
				ELSE 
					(SELECT CashCode FROM Cash.vwBankCashCodes WHERE CashModeCode = 2)
				END AS CashCode, 
			0 AS EntryNumber, 
			(SELECT CAST(Message AS NVARCHAR(30)) FROM App.tbText WHERE TextId = 3005) AS PaymentCode, 
			DATEADD(HOUR, - 1, (SELECT MIN(PaidOn) FROM Org.tbPayment WHERE CashAccountCode = cash_account.CashAccountCode)) AS PaidOn, OpeningBalance AS Paid
		FROM            Org.tbAccount cash_account 								 
		WHERE        (AccountClosed = 0)
	), running_balance AS
	(
		SELECT CashAccountCode, CashCode, EntryNumber, PaymentCode, PaidOn, 
			SUM(Paid) OVER (PARTITION BY CashAccountCode ORDER BY EntryNumber ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS PaidBalance
		FROM entries
	), payments AS
	(
		SELECT     Org.tbPayment.PaymentCode, Org.tbPayment.CashAccountCode, Usr.tbUser.UserName, Org.tbPayment.AccountCode, 
							  Org.tbOrg.AccountName, Org.tbPayment.CashCode, Cash.tbCode.CashDescription, App.tbTaxCode.TaxDescription, 
							  Org.tbPayment.PaidInValue, Org.tbPayment.PaidOutValue, Org.tbPayment.TaxInValue, 
							  Org.tbPayment.TaxOutValue, Org.tbPayment.PaymentReference, Org.tbPayment.InsertedBy, Org.tbPayment.InsertedOn, 
							  Org.tbPayment.UpdatedBy, Org.tbPayment.UpdatedOn, Org.tbPayment.TaxCode
		FROM         Org.tbPayment INNER JOIN
							  Usr.tbUser ON Org.tbPayment.UserId = Usr.tbUser.UserId INNER JOIN
							  Org.tbOrg ON Org.tbPayment.AccountCode = Org.tbOrg.AccountCode LEFT OUTER JOIN
							  App.tbTaxCode ON Org.tbPayment.TaxCode = App.tbTaxCode.TaxCode LEFT OUTER JOIN
							  Cash.tbCode ON Org.tbPayment.CashCode = Cash.tbCode.CashCode
	)
	SELECT running_balance.CashAccountCode, (SELECT TOP 1 StartOn FROM App.tbYearPeriod	WHERE (StartOn <= running_balance.PaidOn) ORDER BY StartOn DESC) AS StartOn, 
							running_balance.EntryNumber, running_balance.PaymentCode, running_balance.PaidOn, 
							payments.AccountName, payments.PaymentReference, payments.PaidInValue, 
							payments.PaidOutValue, running_balance.PaidBalance, payments.TaxInValue, 
							payments.TaxOutValue, payments.CashCode, 
							payments.CashDescription, payments.TaxDescription, payments.UserName, 
							payments.AccountCode, payments.TaxCode
	FROM   running_balance LEFT OUTER JOIN
							payments ON running_balance.PaymentCode = payments.PaymentCode;	
go
CREATE VIEW Cash.vwAccountStatementListing
AS
	SELECT        App.tbYear.YearNumber, Org.tbOrg.AccountName AS Bank, Org.tbAccount.CashAccountCode, Org.tbAccount.CashAccountName, Org.tbAccount.SortCode, Org.tbAccount.AccountNumber, CONCAT(App.tbYear.Description, SPACE(1), 
							 App.tbMonth.MonthName) AS PeriodName, Cash.vwAccountStatement.StartOn, Cash.vwAccountStatement.EntryNumber, Cash.vwAccountStatement.PaymentCode, Cash.vwAccountStatement.PaidOn, 
							 Cash.vwAccountStatement.AccountName, Cash.vwAccountStatement.PaymentReference, Cash.vwAccountStatement.PaidInValue, Cash.vwAccountStatement.PaidOutValue, 
							 Cash.vwAccountStatement.PaidBalance, Cash.vwAccountStatement.TaxInValue, Cash.vwAccountStatement.TaxOutValue, Cash.vwAccountStatement.CashCode, 
							 Cash.vwAccountStatement.CashDescription, Cash.vwAccountStatement.TaxDescription, Cash.vwAccountStatement.UserName, Cash.vwAccountStatement.AccountCode, 
							 Cash.vwAccountStatement.TaxCode
	FROM            App.tbYearPeriod INNER JOIN
							 App.tbMonth ON App.tbYearPeriod.MonthNumber = App.tbMonth.MonthNumber INNER JOIN
							 Cash.vwAccountStatement INNER JOIN
							 Org.tbAccount ON Cash.vwAccountStatement.CashAccountCode = Org.tbAccount.CashAccountCode INNER JOIN
							 Org.tbOrg ON Org.tbAccount.AccountCode = Org.tbOrg.AccountCode ON App.tbYearPeriod.StartOn = Cash.vwAccountStatement.StartOn INNER JOIN
							 App.tbYear ON App.tbYearPeriod.YearNumber = App.tbYear.YearNumber;
go
CREATE VIEW Cash.vwTaxVatAccruals
AS
	WITH task_invoiced_quantity AS
	(
		SELECT        Invoice.tbTask.TaskCode, SUM(Invoice.tbTask.Quantity) AS InvoiceQuantity
		FROM            Invoice.tbTask INNER JOIN
								 Invoice.tbInvoice ON Invoice.tbTask.InvoiceNumber = Invoice.tbInvoice.InvoiceNumber
		WHERE        (Invoice.tbInvoice.InvoiceTypeCode = 0) OR
								 (Invoice.tbInvoice.InvoiceTypeCode = 2)
		GROUP BY Invoice.tbTask.TaskCode
	), task_transactions AS
	(
		SELECT  (SELECT TOP (1) p.StartOn FROM App.tbYearPeriod p WHERE (p.StartOn <= Task.tbTask.ActionOn) ORDER BY p.StartOn DESC) AS StartOn,  
				Task.tbTask.TaskCode, Task.tbTask.TaxCode,
				Task.tbTask.Quantity - ISNULL(task_invoiced_quantity.InvoiceQuantity, 0) AS QuantityRemaining,
				Task.tbTask.UnitCharge * (Task.tbTask.Quantity - ISNULL(task_invoiced_quantity.InvoiceQuantity, 0)) AS TotalValue, 
				Task.tbTask.UnitCharge * (Task.tbTask.Quantity - ISNULL(task_invoiced_quantity.InvoiceQuantity, 0)) * App.tbTaxCode.TaxRate AS TaxValue,
				App.tbTaxCode.TaxRate,
				Org.tbOrg.EUJurisdiction,
				Cash.tbCategory.CashModeCode
		FROM    Task.tbTask INNER JOIN
				Org.tbOrg ON Task.tbTask.AccountCode = Org.tbOrg.AccountCode INNER JOIN
				Cash.tbCode ON Task.tbTask.CashCode = Cash.tbCode.CashCode INNER JOIN
				Cash.tbCategory ON Cash.tbCode.CategoryCode = Cash.tbCategory.CategoryCode INNER JOIN
				App.tbTaxCode ON Task.tbTask.TaxCode = App.tbTaxCode.TaxCode LEFT OUTER JOIN
				task_invoiced_quantity ON Task.tbTask.TaskCode = task_invoiced_quantity.TaskCode
		WHERE        (App.tbTaxCode.TaxTypeCode = 1) AND (Task.tbTask.TaskStatusCode > 0) AND (Task.tbTask.TaskStatusCode < 3) AND (App.tbTaxCode.TaxTypeCode = 1)
			AND (Task.tbTask.ActionOn <= (SELECT DATEADD(d, TaxHorizon, CURRENT_TIMESTAMP) FROM App.tbOptions))
	), task_dataset AS
	(
		SELECT StartOn, TaskCode, TaxCode, QuantityRemaining, TotalValue, TaxValue, TaxRate,
					CASE WHEN EUJurisdiction = 0 THEN (CASE CashModeCode WHEN 1 THEN TotalValue ELSE 0 END) ELSE 0 END AS HomeSales, 
					CASE WHEN EUJurisdiction = 0 THEN (CASE CashModeCode WHEN 0 THEN TotalValue ELSE 0 END) ELSE 0 END AS HomePurchases, 
					CASE WHEN EUJurisdiction != 0 THEN (CASE CashModeCode WHEN 1 THEN TotalValue ELSE 0 END) ELSE 0 END AS ExportSales, 
					CASE WHEN EUJurisdiction != 0 THEN (CASE CashModeCode WHEN 0 THEN TotalValue ELSE 0 END) ELSE 0 END AS ExportPurchases, 
					CASE WHEN EUJurisdiction = 0 THEN (CASE CashModeCode WHEN 1 THEN TaxValue ELSE 0 END) ELSE 0 END AS HomeSalesVat, 
					CASE WHEN EUJurisdiction = 0 THEN (CASE CashModeCode WHEN 0 THEN TaxValue ELSE 0 END) ELSE 0 END AS HomePurchasesVat, 
					CASE WHEN EUJurisdiction != 0 THEN (CASE CashModeCode WHEN 1 THEN TaxValue ELSE 0 END) ELSE 0 END AS ExportSalesVat, 
					CASE WHEN EUJurisdiction != 0 THEN (CASE CashModeCode WHEN 0 THEN TaxValue ELSE 0 END)  ELSE 0 END AS ExportPurchasesVat
		FROM task_transactions
	)
	SELECT task_dataset.*,
		 (HomeSalesVat + ExportSalesVat) - (HomePurchasesVat + ExportPurchasesVat) AS VatDue
	FROM task_dataset
		JOIN App.tbYearPeriod AS year_period ON task_dataset.StartOn = year_period.StartOn INNER JOIN
                         App.tbYear ON year_period.YearNumber = App.tbYear.YearNumber INNER JOIN
                         App.tbMonth ON year_period.MonthNumber = App.tbMonth.MonthNumber;
go
CREATE VIEW Cash.vwTaxVatAuditAccruals
AS
SELECT       App.tbYear.YearNumber, CONCAT(App.tbYear.Description, ' ', App.tbMonth.MonthName) AS YearPeriod, vat_accruals.StartOn, Task.tbTask.ActionOn, Task.tbTask.TaskTitle, Task.tbTask.TaskCode, Cash.tbCode.CashCode, 
                         Cash.tbCode.CashDescription, Activity.tbActivity.ActivityCode, Task.tbStatus.TaskStatus, Task.tbStatus.TaskStatusCode, vat_accruals.TaxCode, vat_accruals.TaxRate, vat_accruals.TotalValue, 
                         vat_accruals.TaxValue, vat_accruals.QuantityRemaining, Activity.tbActivity.UnitOfMeasure, vat_accruals.HomePurchases, vat_accruals.ExportSales, vat_accruals.ExportPurchases, vat_accruals.HomeSalesVat, 
                         vat_accruals.HomePurchasesVat, vat_accruals.ExportSalesVat, vat_accruals.ExportPurchasesVat, vat_accruals.VatDue, vat_accruals.HomeSales
FROM            Cash.vwTaxVatAccruals AS vat_accruals INNER JOIN
                         App.tbYearPeriod AS year_period ON vat_accruals.StartOn = year_period.StartOn INNER JOIN
                         App.tbYear ON year_period.YearNumber = App.tbYear.YearNumber INNER JOIN
                         App.tbMonth ON year_period.MonthNumber = App.tbMonth.MonthNumber INNER JOIN
                         Task.tbTask ON vat_accruals.TaskCode = Task.tbTask.TaskCode INNER JOIN
                         Task.tbStatus ON Task.tbTask.TaskStatusCode = Task.tbStatus.TaskStatusCode AND Task.tbTask.TaskStatusCode = Task.tbStatus.TaskStatusCode AND 
                         Task.tbTask.TaskStatusCode = Task.tbStatus.TaskStatusCode AND Task.tbTask.TaskStatusCode = Task.tbStatus.TaskStatusCode AND Task.tbTask.TaskStatusCode = Task.tbStatus.TaskStatusCode AND 
                         Task.tbTask.TaskStatusCode = Task.tbStatus.TaskStatusCode INNER JOIN
                         Org.tbOrg ON Task.tbTask.AccountCode = Org.tbOrg.AccountCode AND Task.tbTask.AccountCode = Org.tbOrg.AccountCode AND Task.tbTask.AccountCode = Org.tbOrg.AccountCode AND 
                         Task.tbTask.AccountCode = Org.tbOrg.AccountCode AND Task.tbTask.AccountCode = Org.tbOrg.AccountCode AND Task.tbTask.AccountCode = Org.tbOrg.AccountCode INNER JOIN
                         Activity.tbActivity ON Task.tbTask.ActivityCode = Activity.tbActivity.ActivityCode AND Task.tbTask.ActivityCode = Activity.tbActivity.ActivityCode AND Task.tbTask.ActivityCode = Activity.tbActivity.ActivityCode AND 
                         Task.tbTask.ActivityCode = Activity.tbActivity.ActivityCode AND Task.tbTask.ActivityCode = Activity.tbActivity.ActivityCode AND Task.tbTask.ActivityCode = Activity.tbActivity.ActivityCode INNER JOIN
                         Cash.tbCode ON Task.tbTask.CashCode = Cash.tbCode.CashCode AND Task.tbTask.CashCode = Cash.tbCode.CashCode AND Task.tbTask.CashCode = Cash.tbCode.CashCode AND 
                         Task.tbTask.CashCode = Cash.tbCode.CashCode AND Task.tbTask.CashCode = Cash.tbCode.CashCode AND Task.tbTask.CashCode = Cash.tbCode.CashCode
go
CREATE VIEW Invoice.vwHistoryCashCodes
AS
SELECT        App.tbYearPeriod.YearNumber, CONCAT(App.tbMonth.MonthName, SPACE(1), YEAR(App.tbYearPeriod.StartOn)) AS Period, Invoice.vwRegisterDetail.StartOn, Invoice.vwRegisterDetail.CashCode, 
                         Invoice.vwRegisterDetail.CashDescription, SUM(Invoice.vwRegisterDetail.InvoiceValue) AS TotalInvoiceValue, SUM(Invoice.vwRegisterDetail.TaxValue) AS TotalTaxValue
FROM            Invoice.vwRegisterDetail INNER JOIN
                         App.tbYearPeriod INNER JOIN
                         App.tbMonth ON App.tbYearPeriod.MonthNumber = App.tbMonth.MonthNumber ON Invoice.vwRegisterDetail.StartOn = App.tbYearPeriod.StartOn INNER JOIN
                         App.tbYear ON App.tbYearPeriod.YearNumber = App.tbYear.YearNumber
GROUP BY App.tbYearPeriod.YearNumber, CONCAT(App.tbMonth.MonthName, SPACE(1), YEAR(App.tbYearPeriod.StartOn)), Invoice.vwRegisterDetail.StartOn, Invoice.vwRegisterDetail.CashCode, 
                         Invoice.vwRegisterDetail.CashDescription;
go
CREATE VIEW Invoice.vwHistoryPurchaseItems
AS
SELECT        CONCAT(App.tbMonth.MonthName, SPACE(1), YEAR(App.tbYearPeriod.StartOn)) AS PeriodName, App.tbYearPeriod.YearNumber, Invoice.vwRegisterDetail.StartOn, Invoice.vwRegisterDetail.InvoiceNumber, 
                         Invoice.vwRegisterDetail.TaskCode, Invoice.vwRegisterDetail.CashCode, Invoice.vwRegisterDetail.CashDescription, Invoice.vwRegisterDetail.TaxCode, Invoice.vwRegisterDetail.TaxDescription, 
                         Invoice.vwRegisterDetail.AccountCode, Invoice.vwRegisterDetail.InvoiceTypeCode, Invoice.vwRegisterDetail.InvoiceStatusCode, Invoice.vwRegisterDetail.InvoicedOn, Invoice.vwRegisterDetail.InvoiceValue, 
                         Invoice.vwRegisterDetail.TaxValue, Invoice.vwRegisterDetail.PaidValue, Invoice.vwRegisterDetail.PaidTaxValue, Invoice.vwRegisterDetail.PaymentTerms, Invoice.vwRegisterDetail.Printed, 
                         Invoice.vwRegisterDetail.AccountName, Invoice.vwRegisterDetail.UserName, Invoice.vwRegisterDetail.InvoiceStatus, Invoice.vwRegisterDetail.CashModeCode, Invoice.vwRegisterDetail.InvoiceType, 
                         Invoice.vwRegisterDetail.UnpaidValue
FROM            Invoice.vwRegisterDetail INNER JOIN
                         App.tbYearPeriod ON Invoice.vwRegisterDetail.StartOn = App.tbYearPeriod.StartOn INNER JOIN
                         App.tbYear ON App.tbYearPeriod.YearNumber = App.tbYear.YearNumber INNER JOIN
                         App.tbMonth ON App.tbYearPeriod.MonthNumber = App.tbMonth.MonthNumber
WHERE        (Invoice.vwRegisterDetail.InvoiceTypeCode > 1);
go
CREATE VIEW App.vwPeriods
AS
	SELECT        TOP (100) PERCENT App.tbYear.YearNumber, App.tbYearPeriod.StartOn, App.tbYear.Description + SPACE(1) + App.tbMonth.MonthName AS Description, App.tbYearPeriod.RowVer
	FROM            App.tbYearPeriod INNER JOIN
							 App.tbMonth ON App.tbYearPeriod.MonthNumber = App.tbMonth.MonthNumber INNER JOIN
							 App.tbYear ON App.tbYearPeriod.YearNumber = App.tbYear.YearNumber
	WHERE        (App.tbYear.CashStatusCode < 3) AND (App.tbYearPeriod.CashStatusCode < 3)
go
CREATE VIEW Cash.vwFlowVatPeriodAccruals
AS
	WITH active_periods AS
	(
		SELECT App.tbYear.YearNumber, App.tbYearPeriod.StartOn
		FROM            App.tbYearPeriod INNER JOIN
								 App.tbMonth ON App.tbYearPeriod.MonthNumber = App.tbMonth.MonthNumber INNER JOIN
								 App.tbYear ON App.tbYearPeriod.YearNumber = App.tbYear.YearNumber
		WHERE        (App.tbYear.CashStatusCode < 3)
	),	 vat_accruals AS
	(
		SELECT   active_periods.YearNumber, active_periods.StartOn, ISNULL(SUM(vat_audit.HomeSales), 0) AS HomeSales, ISNULL(SUM(vat_audit.HomePurchases), 0) AS HomePurchases, ISNULL(SUM(vat_audit.ExportSales), 0) AS ExportSales, ISNULL(SUM(vat_audit.ExportPurchases), 0) 
								 AS ExportPurchases, ISNULL(SUM(vat_audit.HomeSalesVat), 0) AS HomeSalesVat, ISNULL(SUM(vat_audit.HomePurchasesVat), 0) AS HomePurchasesVat, ISNULL(SUM(vat_audit.ExportSalesVat), 0) AS ExportSalesVat, 
								 ISNULL(SUM(vat_audit.ExportPurchasesVat), 0) AS ExportPurchasesVat
		FROM            Cash.vwTaxVatAuditAccruals AS vat_audit RIGHT OUTER JOIN
								 active_periods ON active_periods.StartOn = vat_audit.StartOn
		GROUP BY active_periods.YearNumber, active_periods.StartOn
	)
	SELECT YearNumber, StartOn, HomeSales, HomePurchases, ExportSales, ExportPurchases, HomeSalesVat, HomePurchasesVat, ExportSalesVat, ExportPurchasesVat,
		 (HomeSalesVat + ExportSalesVat) - (HomePurchasesVat + ExportPurchasesVat) AS VatDue
	FROM vat_accruals;
go
CREATE VIEW Invoice.vwHistoryPurchases
AS
SELECT        App.tbYearPeriod.YearNumber, App.tbYear.Description, CONCAT(App.tbMonth.MonthName, SPACE(1), YEAR(App.tbYearPeriod.StartOn)) AS PeriodName, Invoice.vwRegister.StartOn, 
                         Invoice.vwRegister.InvoiceNumber, Invoice.vwRegister.AccountCode, Invoice.vwRegister.InvoiceTypeCode, Invoice.vwRegister.InvoiceStatusCode, Invoice.vwRegister.InvoicedOn, 
                         Invoice.vwRegister.InvoiceValue, Invoice.vwRegister.TaxValue, Invoice.vwRegister.PaidValue, Invoice.vwRegister.PaidTaxValue, Invoice.vwRegister.PaymentTerms, Invoice.vwRegister.Notes, 
                         Invoice.vwRegister.Printed, Invoice.vwRegister.AccountName, Invoice.vwRegister.UserName, Invoice.vwRegister.InvoiceStatus, Invoice.vwRegister.CashModeCode, Invoice.vwRegister.InvoiceType, 
                         (Invoice.vwRegister.InvoiceValue + Invoice.vwRegister.TaxValue) - (Invoice.vwRegister.PaidValue + Invoice.vwRegister.PaidTaxValue) AS UnpaidValue
FROM            App.tbYearPeriod INNER JOIN
                         App.tbMonth ON App.tbYearPeriod.MonthNumber = App.tbMonth.MonthNumber INNER JOIN
                         App.tbYear ON App.tbYearPeriod.YearNumber = App.tbYear.YearNumber INNER JOIN
                         Invoice.vwRegister ON App.tbYearPeriod.StartOn = Invoice.vwRegister.StartOn
WHERE        (Invoice.vwRegister.InvoiceTypeCode > 1);
go
CREATE VIEW Invoice.vwHistorySalesItems
AS
SELECT        App.tbYearPeriod.YearNumber, CONCAT(App.tbMonth.MonthName, SPACE(1), YEAR(App.tbYearPeriod.StartOn)) AS PeriodName, Invoice.vwRegisterDetail.StartOn, Invoice.vwRegisterDetail.InvoiceNumber, 
                         (Invoice.vwRegisterDetail.InvoiceValue + Invoice.vwRegisterDetail.TaxValue) - (Invoice.vwRegisterDetail.PaidValue + Invoice.vwRegisterDetail.PaidTaxValue) AS UnpaidValue, Invoice.vwRegisterDetail.TaskCode, 
                         Invoice.vwRegisterDetail.CashCode, Invoice.vwRegisterDetail.CashDescription, Invoice.vwRegisterDetail.TaxCode, Invoice.vwRegisterDetail.AccountCode, Invoice.vwRegisterDetail.InvoicedOn, 
                         Invoice.vwRegisterDetail.InvoiceValue, Invoice.vwRegisterDetail.TaxValue, Invoice.vwRegisterDetail.PaidValue, Invoice.vwRegisterDetail.PaidTaxValue, Invoice.vwRegisterDetail.PaymentTerms, 
                         Invoice.vwRegisterDetail.AccountName, Invoice.vwRegisterDetail.InvoiceStatus, Invoice.vwRegisterDetail.InvoiceType, Invoice.vwRegisterDetail.InvoiceTypeCode, 
                         Invoice.vwRegisterDetail.InvoiceStatusCode
FROM            Invoice.vwRegisterDetail INNER JOIN
                         App.tbYearPeriod ON Invoice.vwRegisterDetail.StartOn = App.tbYearPeriod.StartOn INNER JOIN
                         App.tbYear ON App.tbYearPeriod.YearNumber = App.tbYear.YearNumber INNER JOIN
                         App.tbMonth ON App.tbYearPeriod.MonthNumber = App.tbMonth.MonthNumber
WHERE        (Invoice.vwRegisterDetail.InvoiceTypeCode < 2);
go
CREATE VIEW Cash.vwFlowVatRecurrenceAccruals
AS	
	WITH active_periods AS
	(
		SELECT App.tbYear.YearNumber, App.tbYearPeriod.StartOn
		FROM            App.tbYearPeriod INNER JOIN
								 App.tbMonth ON App.tbYearPeriod.MonthNumber = App.tbMonth.MonthNumber INNER JOIN
								 App.tbYear ON App.tbYearPeriod.YearNumber = App.tbYear.YearNumber
		WHERE        (App.tbYear.CashStatusCode < 3)
	),	vat_dates AS
	(
		SELECT PayFrom, PayTo FROM Cash.fnTaxTypeDueDates(1)
	), vatPeriod AS
	(
		SELECT        StartOn, y.YearNumber, p.MonthNumber,
			(SELECT PayTo FROM vat_dates WHERE p.StartOn >= PayFrom AND p.StartOn < PayTo) AS VatStartOn, VatAdjustment
		FROM            App.tbYearPeriod AS p JOIN App.tbYear AS y ON p.YearNumber = y.YearNumber 
	)
	, vat_accruals AS
	(
		SELECT  vatPeriod.VatStartOn AS StartOn,
				SUM(HomeSales) AS HomeSales, SUM(HomePurchases) AS HomePurchases, SUM(ExportSales) AS ExportSales, SUM(ExportPurchases) AS ExportPurchases, 
				SUM(HomeSalesVat) AS HomeSalesVat, SUM(HomePurchasesVat) AS HomePurchasesVat, 
				SUM(ExportSalesVat) AS ExportSalesVat, SUM(ExportPurchasesVat) AS ExportPurchasesVat, SUM(VatDue) AS VatDue
		FROM Cash.vwFlowVatPeriodAccruals accruals JOIN vatPeriod ON accruals.StartOn = vatPeriod.StartOn
		GROUP BY vatPeriod.VatStartOn
	)
	SELECT active_periods.YearNumber, active_periods.StartOn, ISNULL(HomeSales, 0) AS HomeSales, ISNULL(HomePurchases, 0) AS HomePurchases, ISNULL(ExportSales, 0) AS ExportSales, ISNULL(ExportPurchases, 0) AS ExportPurchases, ISNULL(HomeSalesVat, 0) AS HomeSalesVat, ISNULL(HomePurchasesVat, 0) AS HomePurchasesVat, ISNULL(ExportSalesVat, 0) AS ExportSalesVat, ISNULL(ExportPurchasesVat, 0) AS ExportPurchasesVat, ISNULL(VatDue, 0) AS VatDue 
	FROM vat_accruals 
		RIGHT OUTER JOIN active_periods ON active_periods.StartOn = vat_accruals.StartOn;		
go

CREATE VIEW App.vwCorpTaxCashCodes
AS
	WITH category_relations AS
	(
		SELECT Cash.tbCategoryTotal.ParentCode, Cash.tbCategoryTotal.ChildCode, Cash.tbCategory.CategoryTypeCode, Cash.tbCode.CashCode
		FROM  Cash.tbCategoryTotal 
			INNER JOIN Cash.tbCategory ON Cash.tbCategoryTotal.ChildCode = Cash.tbCategory.CategoryCode 
			LEFT OUTER JOIN Cash.tbCode ON Cash.tbCategory.CategoryCode = Cash.tbCode.CategoryCode
	), cashcode_candidates AS
	(
		SELECT     ChildCode, CashCode
		FROM category_relations
		WHERE     ( CategoryTypeCode = 1) AND ( ParentCode = (SELECT NetProfitCode FROM App.tbOptions))

		UNION ALL

		SELECT     category_relations.ChildCode, category_relations.CashCode
		FROM  category_relations JOIN cashcode_candidates ON category_relations.ParentCode = cashcode_candidates.ChildCode
	), cashcode_selected AS
	(
		SELECT CashCode FROM cashcode_candidates
		UNION
		SELECT CashCode FROM category_relations WHERE ParentCode = (SELECT NetProfitCode FROM App.tbOptions)
	)
	SELECT CashCode FROM cashcode_selected WHERE NOT CashCode IS NULL;
go

CREATE VIEW Cash.vwTaxCorpTotalsByPeriod
AS
	WITH invoiced_tasks AS
	(
		SELECT (SELECT TOP (1) StartOn FROM App.tbYearPeriod WHERE (StartOn <= Invoice.tbInvoice.InvoicedOn) ORDER BY StartOn DESC) AS StartOn,  
								 CASE WHEN Invoice.tbType.CashModeCode = 0 THEN Invoice.tbTask.InvoiceValue * - 1 ELSE Invoice.tbTask.InvoiceValue END AS InvoiceValue
		FROM            Invoice.tbTask INNER JOIN
								 App.vwCorpTaxCashCodes CashCodes  ON Invoice.tbTask.CashCode = CashCodes.CashCode INNER JOIN
								 Invoice.tbInvoice ON Invoice.tbTask.InvoiceNumber = Invoice.tbInvoice.InvoiceNumber INNER JOIN
								 Invoice.tbType ON Invoice.tbInvoice.InvoiceTypeCode = Invoice.tbType.InvoiceTypeCode
	), invoiced_items AS
	(
		SELECT (SELECT TOP (1) StartOn FROM App.tbYearPeriod WHERE (StartOn <= Invoice.tbInvoice.InvoicedOn) ORDER BY StartOn DESC) AS StartOn,  
							  CASE WHEN Invoice.tbType.CashModeCode = 0 THEN Invoice.tbItem.InvoiceValue * - 1 ELSE Invoice.tbItem.InvoiceValue END AS InvoiceValue
		FROM         Invoice.tbItem INNER JOIN
							  App.vwCorpTaxCashCodes CashCodes ON Invoice.tbItem.CashCode = CashCodes.CashCode INNER JOIN
							  Invoice.tbInvoice ON Invoice.tbItem.InvoiceNumber = Invoice.tbInvoice.InvoiceNumber INNER JOIN
							  Invoice.tbType ON Invoice.tbInvoice.InvoiceTypeCode = Invoice.tbType.InvoiceTypeCode
	), netprofits AS	
	(
		SELECT StartOn, SUM(InvoiceValue) AS NetProfit FROM invoiced_tasks GROUP BY StartOn
		UNION
		SELECT StartOn, SUM(InvoiceValue) AS NetProfit FROM invoiced_items GROUP BY StartOn
	)
	, netprofit_consolidated AS
	(
		SELECT StartOn, SUM(NetProfit) AS NetProfit FROM netprofits GROUP BY StartOn
	)
	SELECT App.tbYearPeriod.StartOn, netprofit_consolidated.NetProfit, 
							netprofit_consolidated.NetProfit * App.tbYearPeriod.CorporationTaxRate + App.tbYearPeriod.TaxAdjustment AS CorporationTax, 
							App.tbYearPeriod.TaxAdjustment
	FROM         netprofit_consolidated INNER JOIN
							App.tbYearPeriod ON netprofit_consolidated.StartOn = App.tbYearPeriod.StartOn;
go

CREATE VIEW Cash.vwTaxCorpStatement
AS
	WITH tax_dates AS
	(
		SELECT PayOn, PayFrom, PayTo FROM Cash.fnTaxTypeDueDates(0)
	), period_totals AS
	(
		SELECT (SELECT PayOn FROM tax_dates WHERE totals.StartOn >= PayFrom AND totals.StartOn < PayTo) AS StartOn, CorporationTax
		FROM Cash.vwTaxCorpTotalsByPeriod totals
	), tax_entries AS
	(
		SELECT StartOn, SUM(CorporationTax) AS TaxDue, 0 AS TaxPaid
		FROM period_totals
		WHERE NOT StartOn IS NULL
		GROUP BY StartOn
		
		UNION

		SELECT Org.tbPayment.PaidOn AS StartOn, 0 As TaxDue, ( Org.tbPayment.PaidOutValue * -1) + Org.tbPayment.PaidInValue AS TaxPaid
		FROM Org.tbPayment 
			JOIN Cash.tbTaxType tt ON Org.tbPayment.CashCode = tt.CashCode
		WHERE (tt.TaxTypeCode = 0)

	), tax_statement AS
	(
		SELECT StartOn, TaxDue, TaxPaid,
			SUM(TaxDue + TaxPaid) OVER (ORDER BY StartOn, TaxDue ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS Balance
		FROM tax_entries
	)
	SELECT StartOn, CAST(TaxDue AS MONEY) TaxDue, CAST(TaxPaid AS MONEY) TaxPaid, CAST(Balance AS MONEY) Balance FROM tax_statement 
	WHERE StartOn >= (SELECT MIN(StartOn) FROM App.tbYearPeriod p JOIN App.tbYear y ON p.YearNumber = y.YearNumber  WHERE y.CashStatusCode < 3);
go

CREATE VIEW App.vwVatTaxCashCodes
AS
	WITH category_relations AS
	(
		SELECT Cash.tbCategoryTotal.ParentCode, Cash.tbCategoryTotal.ChildCode, Cash.tbCategory.CategoryTypeCode, Cash.tbCode.CashCode
		FROM  Cash.tbCategoryTotal 
			INNER JOIN Cash.tbCategory ON Cash.tbCategoryTotal.ChildCode = Cash.tbCategory.CategoryCode 
			LEFT OUTER JOIN Cash.tbCode ON Cash.tbCategory.CategoryCode = Cash.tbCode.CategoryCode
		WHERE Cash.tbCategory.CashTypeCode = 0
	), cashcode_candidates AS
	(
		SELECT     ChildCode, CashCode
		FROM category_relations
		WHERE     ( CategoryTypeCode = 1) AND ( ParentCode = (SELECT VatCategoryCode FROM App.tbOptions))

		UNION ALL

		SELECT     category_relations.ChildCode, category_relations.CashCode
		FROM  category_relations JOIN cashcode_candidates ON category_relations.ParentCode = cashcode_candidates.ChildCode
	), cashcode_selected AS
	(
		SELECT CashCode FROM cashcode_candidates
		UNION
		SELECT CashCode FROM category_relations WHERE ParentCode = (SELECT VatCategoryCode FROM App.tbOptions)
	)
	SELECT CashCode FROM cashcode_selected WHERE NOT CashCode IS NULL;

go
CREATE VIEW Cash.vwTaxVatSummary
AS

	WITH vat_transactions AS
	(	
		SELECT  (SELECT TOP (1) p.StartOn FROM App.tbYearPeriod p WHERE (p.StartOn <= Invoice.tbInvoice.InvoicedOn) ORDER BY p.StartOn DESC) AS StartOn,  
				Invoice.tbInvoice.InvoiceNumber, Invoice.tbInvoice.InvoiceTypeCode, Invoice.tbItem.TaxCode, Invoice.tbItem.InvoiceValue, 
								 Invoice.tbItem.TaxValue, Org.tbOrg.EUJurisdiction, Invoice.tbItem.CashCode AS IdentityCode
		FROM   App.vwVatTaxCashCodes cash_codes INNER JOIN  Invoice.tbItem ON cash_codes.CashCode = Invoice.tbItem.CashCode 
				INNER JOIN Invoice.tbInvoice ON Invoice.tbItem.InvoiceNumber = Invoice.tbInvoice.InvoiceNumber INNER JOIN
								 Org.tbOrg ON Invoice.tbInvoice.AccountCode = Org.tbOrg.AccountCode INNER JOIN
								 App.tbTaxCode ON Invoice.tbItem.TaxCode = App.tbTaxCode.TaxCode
		WHERE        (App.tbTaxCode.TaxTypeCode = 1)
		UNION
		SELECT  (SELECT TOP (1) p.StartOn FROM App.tbYearPeriod p WHERE (p.StartOn <= Invoice.tbInvoice.InvoicedOn) ORDER BY p.StartOn DESC) AS StartOn,  
					Invoice.tbTask.InvoiceNumber, Invoice.tbInvoice.InvoiceTypeCode, Invoice.tbTask.TaxCode, Invoice.tbTask.InvoiceValue, 
								 Invoice.tbTask.TaxValue, Org.tbOrg.EUJurisdiction, Invoice.tbTask.TaskCode AS IdentityCode
		FROM    App.vwVatTaxCashCodes cash_codes INNER JOIN  Invoice.tbTask ON cash_codes.CashCode = Invoice.tbTask.CashCode 
					INNER JOIN Invoice.tbInvoice ON Invoice.tbTask.InvoiceNumber = Invoice.tbInvoice.InvoiceNumber INNER JOIN
								 Org.tbOrg ON Invoice.tbInvoice.AccountCode = Org.tbOrg.AccountCode INNER JOIN
								 App.tbTaxCode ON Invoice.tbTask.TaxCode = App.tbTaxCode.TaxCode
		WHERE        (App.tbTaxCode.TaxTypeCode = 1)
	), vat_detail AS
	(
		SELECT        StartOn, TaxCode, 
								 CASE WHEN EUJurisdiction = 0 THEN CASE InvoiceTypeCode WHEN 0 THEN InvoiceValue WHEN 1 THEN
								  InvoiceValue * - 1 ELSE 0 END ELSE 0 END AS HomeSales, 
								 CASE WHEN EUJurisdiction = 0 THEN CASE InvoiceTypeCode WHEN 2 THEN InvoiceValue WHEN 3 THEN
								  InvoiceValue * - 1 ELSE 0 END ELSE 0 END AS HomePurchases, 
								 CASE WHEN EUJurisdiction != 0 THEN CASE InvoiceTypeCode WHEN 0 THEN InvoiceValue WHEN 1 THEN
								  InvoiceValue * - 1 ELSE 0 END ELSE 0 END AS ExportSales, 
								 CASE WHEN EUJurisdiction != 0 THEN CASE InvoiceTypeCode WHEN 2 THEN InvoiceValue WHEN 3 THEN
								  InvoiceValue * - 1 ELSE 0 END ELSE 0 END AS ExportPurchases, 
								 CASE WHEN EUJurisdiction = 0 THEN CASE InvoiceTypeCode WHEN 0 THEN TaxValue WHEN 1 THEN TaxValue
								  * - 1 ELSE 0 END ELSE 0 END AS HomeSalesVat, 
								 CASE WHEN EUJurisdiction = 0 THEN CASE InvoiceTypeCode WHEN 2 THEN TaxValue WHEN 3 THEN TaxValue
								  * - 1 ELSE 0 END ELSE 0 END AS HomePurchasesVat, 
								 CASE WHEN EUJurisdiction != 0 THEN CASE InvoiceTypeCode WHEN 0 THEN TaxValue WHEN 1 THEN TaxValue
								  * - 1 ELSE 0 END ELSE 0 END AS ExportSalesVat, 
								 CASE WHEN EUJurisdiction != 0 THEN CASE InvoiceTypeCode WHEN 2 THEN TaxValue WHEN 3 THEN TaxValue
								  * - 1 ELSE 0 END ELSE 0 END AS ExportPurchasesVat
		FROM  vat_transactions
	), vatcode_summary AS
	(
		SELECT        StartOn, TaxCode, SUM(HomeSales) AS HomeSales, SUM(HomePurchases) AS HomePurchases, SUM(ExportSales) AS ExportSales, SUM(ExportPurchases) AS ExportPurchases, SUM(HomeSalesVat) 
								AS HomeSalesVat, SUM(HomePurchasesVat) AS HomePurchasesVat, SUM(ExportSalesVat) AS ExportSalesVat, SUM(ExportPurchasesVat) AS ExportPurchasesVat
		FROM            vat_detail
		GROUP BY StartOn, TaxCode
	)
	SELECT   StartOn, 
		TaxCode, HomeSales, HomePurchases, ExportSales, ExportPurchases, HomeSalesVat, HomePurchasesVat, ExportSalesVat, ExportPurchasesVat
			, (HomeSalesVat + ExportSalesVat) - (HomePurchasesVat + ExportPurchasesVat) AS VatDue
	FROM vatcode_summary;

go


CREATE VIEW Cash.vwTaxVatStatement
AS
	WITH vat_dates AS
	(
		SELECT PayOn, PayFrom, PayTo FROM Cash.fnTaxTypeDueDates(1)
	), vatPeriod AS
	(
		SELECT        StartOn, 
			(SELECT PayTo FROM vat_dates WHERE StartOn >= PayFrom AND StartOn < PayTo) AS VatStartOn, VatAdjustment
		FROM            App.tbYearPeriod 
	), vat_codes AS
	(
		SELECT     CashCode
		FROM         Cash.tbTaxType
		WHERE     (TaxTypeCode = 1)
	)
	, vat_results AS
	(
		SELECT VatStartOn AS StartOn,
			SUM(HomeSales) AS HomeSales, SUM(HomePurchases) AS HomePurchases, SUM(ExportSales) AS ExportSales, SUM(ExportPurchases) AS ExportPurchases, 
			SUM(HomeSalesVat) AS HomeSalesVat, SUM(HomePurchasesVat) AS HomePurchasesVat, 
			SUM(ExportSalesVat) AS ExportSalesVat, SUM(ExportPurchasesVat) AS ExportPurchasesVat, SUM(VatDue) AS VatDue
		FROM Cash.vwTaxVatSummary vatCodeDue JOIN vatPeriod ON vatCodeDue.StartOn = vatPeriod.StartOn
		GROUP BY VatStartOn
	), vat_adjustments AS
	(
		SELECT VatStartOn AS StartOn, SUM(VatAdjustment) AS VatAdjustment
		FROM vatPeriod
		GROUP BY VatStartOn
	), vat_unordered AS
	(
		SELECT vat_dates.PayOn AS StartOn, VatDue - a.VatAdjustment AS VatDue, 0 As VatPaid		
		FROM vat_results r JOIN vat_adjustments a ON r.StartOn = a.StartOn
			JOIN vat_dates ON r.StartOn = vat_dates.PayTo
			UNION
		SELECT     Org.tbPayment.PaidOn AS StartOn, 0 As VatDue, ( Org.tbPayment.PaidOutValue * -1) + Org.tbPayment.PaidInValue AS VatPaid
		FROM         Org.tbPayment INNER JOIN
							  vat_codes ON Org.tbPayment.CashCode = vat_codes.CashCode	
	), vat_ordered AS
	(
		SELECT ROW_NUMBER() OVER (ORDER BY StartOn, VatDue) AS RowNumber,
			StartOn, VatDue, VatPaid
		FROM vat_unordered
	), vat_statement AS
	(
		SELECT RowNumber, StartOn, VatDue, VatPaid,
			SUM(VatDue+VatPaid) OVER (ORDER BY RowNumber ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS Balance
		FROM vat_ordered
	)
	SELECT RowNumber, StartOn, VatDue, VatPaid, Balance
	FROM vat_statement
	WHERE StartOn >= (SELECT MIN(StartOn) FROM App.tbYearPeriod p JOIN App.tbYear y ON p.YearNumber = y.YearNumber  WHERE y.CashStatusCode < 3);


go

CREATE VIEW Cash.vwTaxCorpAccruals
AS
	WITH corptax_ordered_confirmed AS
	(
		SELECT        task.TaskCode, task.ActionOn, task.Quantity, CASE WHEN Cash.tbCategory.CashModeCode = 0 THEN task.TotalCharge * - 1 ELSE task.TotalCharge END AS TotalCharge
		FROM            Task.tbTask AS task INNER JOIN
								 Cash.tbCode ON task.CashCode = Cash.tbCode.CashCode INNER JOIN
								 Cash.tbCategory ON Cash.tbCode.CategoryCode = Cash.tbCategory.CategoryCode AND Cash.tbCode.CategoryCode = Cash.tbCategory.CategoryCode
		WHERE        (task.TaskStatusCode BETWEEN 1 AND 2) AND (task.ActionOn <= (SELECT DATEADD(d, TaxHorizon, CURRENT_TIMESTAMP) AS HorizonOn FROM App.tbOptions))
	), corptax_ordered_invoices AS
	(
		SELECT corptax_ordered_confirmed.TaskCode, task_invoice.Quantity,
			CASE WHEN invoice_type.CashModeCode = 0 THEN task_invoice.InvoiceValue * -1 ELSE task_invoice.InvoiceValue END AS InvoiceValue
		FROM corptax_ordered_confirmed JOIN Invoice.tbTask task_invoice ON corptax_ordered_confirmed.TaskCode = task_invoice.TaskCode
			JOIN Invoice.tbInvoice invoice ON task_invoice.InvoiceNumber = invoice.InvoiceNumber
			JOIN Invoice.tbType invoice_type ON invoice_type.InvoiceTypeCode = invoice.InvoiceTypeCode
	), corptax_ordered AS
	(
		SELECT (SELECT TOP (1) StartOn FROM App.tbYearPeriod WHERE (StartOn <= corptax_ordered_confirmed.ActionOn) ORDER BY StartOn DESC) AS StartOn, 
			corptax_ordered_confirmed.TaskCode,
			corptax_ordered_confirmed.Quantity - ISNULL(corptax_ordered_invoices.Quantity, 0) AS QuantityRemaining,
			corptax_ordered_confirmed.TotalCharge - ISNULL(corptax_ordered_invoices.InvoiceValue, 0) AS OrderValue
		FROM corptax_ordered_confirmed 
			LEFT JOIN corptax_ordered_invoices ON corptax_ordered_confirmed.TaskCode = corptax_ordered_invoices.TaskCode
	)
	SELECT corptax_ordered.StartOn, TaskCode, QuantityRemaining, OrderValue, OrderValue * CorporationTaxRate AS TaxDue
	FROM corptax_ordered JOIN App.tbYearPeriod year_period ON corptax_ordered.StartOn = year_period.StartOn;


go

CREATE VIEW Cash.vwStatement
AS
	--invoiced taxes
	WITH corp_taxcode AS
	(
		SELECT TOP (1) AccountCode, CashCode 
		FROM Cash.tbTaxType WHERE (TaxTypeCode = 0)
	), corptax_invoiced_entries AS
	(
		SELECT AccountCode, CashCode, StartOn, TaxDue, Balance,
			ROW_NUMBER() OVER (ORDER BY StartOn) AS RowNumber 
		FROM Cash.vwTaxCorpStatement CROSS JOIN corp_taxcode
		WHERE (Balance <> 0) AND (StartOn >= (SELECT MIN(StartOn) FROM App.tbYearPeriod WHERE CashStatusCode < 2)) --AND (TaxDue > 0) 
	), corptax_invoiced_owing AS
	(
		SELECT AccountCode, CashCode, StartOn AS TransactOn, 4 AS CashEntryTypeCode, 
			(SELECT CAST(Message AS NVARCHAR) FROM App.tbText WHERE TextId = 1214) ReferenceCode, 0 AS PayIn,
			CASE RowNumber WHEN 1 THEN Balance ELSE TaxDue END AS PayOut
		FROM corptax_invoiced_entries
	), vat_taxcode AS
	(
		SELECT TOP (1) AccountCode, CashCode 
		FROM Cash.tbTaxType WHERE (TaxTypeCode = 1)
	), vat_totals AS
	(
		SELECT ROW_NUMBER() OVER (ORDER BY RowNumber DESC) AS Id, StartOn AS TransactOn, VatDue,
			CASE WHEN VatPaid  < 0 THEN NULL ELSE 1 END IsLive
		FROM Cash.vwTaxVatStatement
	), vat_invoiced_owing AS
	(
		SELECT AccountCode, CashCode, TransactOn, 5 AS CashEntryTypeCode, 
			(SELECT CAST(Message AS NVARCHAR) FROM App.tbText WHERE TextId = 1214) ReferenceCode, 
			CASE WHEN VatDue < 0 THEN ABS(VatDue) ELSE 0 END AS PayIn,
			CASE WHEN VatDue >= 0 THEN VatDue ELSE 0 END AS PayOut
		FROM vat_totals CROSS JOIN vat_taxcode
		WHERE Id <  (SELECT TOP 1 t.Id FROM vat_totals t WHERE t.IsLive IS NULL ORDER BY Id)
	)
	--uninvoiced taxes
	,  corptax_dates AS
	(
		SELECT PayOn, PayFrom, PayTo FROM Cash.fnTaxTypeDueDates(0)
	), corptax_accrual_entries AS
	(
		SELECT StartOn, SUM(TaxDue) AS TaxDue
		FROM Cash.vwTaxCorpAccruals
		GROUP BY StartOn
	), corptax_accrual_candidates AS
	(
			SELECT (SELECT PayOn FROM corptax_dates WHERE corptax_accrual_entries.StartOn >= PayFrom AND corptax_accrual_entries.StartOn < PayTo) AS TransactOn, TaxDue			
		FROM corptax_accrual_entries 
	), corptax_accrual_totals AS
	(
		SELECT TransactOn, SUM(TaxDue) AS TaxDue
		FROM corptax_accrual_candidates
		GROUP BY TransactOn
	)	
	, corptax_accruals AS
	(	
		SELECT AccountCode, CashCode, TransactOn, 4 AS CashEntryTypeCode, 
				(SELECT CAST(Message AS NVARCHAR) FROM App.tbText WHERE TextId = 1215) ReferenceCode, 
				CASE WHEN TaxDue < 0 THEN ABS(TaxDue) ELSE 0 END AS PayIn,
				CASE WHEN TaxDue >= 0 THEN TaxDue ELSE 0 END AS PayOut
		FROM corptax_accrual_totals CROSS JOIN corp_taxcode
	), vat_dates AS
	(
		SELECT PayOn, PayFrom, PayTo FROM Cash.fnTaxTypeDueDates(1)
	), vat_accrual_entries AS
	(
		SELECT StartOn, SUM(VatDue) AS TaxDue 
		FROM Cash.vwTaxVatAccruals vat_audit
		WHERE vat_audit.VatDue <> 0
		GROUP BY StartOn
	), vat_accrual_candidates AS
	(
		SELECT (SELECT PayOn FROM vat_dates WHERE vat_accrual_entries.StartOn >= PayFrom AND vat_accrual_entries.StartOn < PayTo) AS TransactOn, TaxDue			
		FROM vat_accrual_entries 
	), vat_accrual_totals AS
	(
		SELECT TransactOn, SUM(TaxDue) AS TaxDue
		FROM vat_accrual_candidates
		GROUP BY TransactOn
	), vat_accruals AS
	(
		SELECT vat_taxcode.AccountCode, vat_taxcode.CashCode, TransactOn, 5 AS CashEntryTypeCode, 
				(SELECT CAST(Message AS NVARCHAR) FROM App.tbText WHERE TextId = 1215) ReferenceCode,
				CASE WHEN TaxDue < 0 THEN ABS(TaxDue) ELSE 0 END AS PayIn,
				CASE WHEN TaxDue >= 0 THEN TaxDue ELSE 0 END AS PayOut
		FROM vat_accrual_totals
			CROSS JOIN vat_taxcode
	)
	--unpaid invoices
	, invoices_unpaid_items AS
	(
		SELECT     Invoice.tbInvoice.AccountCode, Invoice.tbItem.CashCode, Invoice.tbInvoice.ExpectedOn AS TransactOn, 1 AS CashEntryTypeCode, Invoice.tbItem.InvoiceNumber AS ReferenceCode, 
							  SUM(CASE WHEN InvoiceTypeCode = 0 OR
							  InvoiceTypeCode = 3 THEN ( Invoice.tbItem.InvoiceValue + Invoice.tbItem.TaxValue) - ( Invoice.tbItem.PaidValue + Invoice.tbItem.PaidTaxValue) 
							  ELSE 0 END) AS PayIn, SUM(CASE WHEN InvoiceTypeCode = 1 OR
							  InvoiceTypeCode = 2 THEN ( Invoice.tbItem.InvoiceValue + Invoice.tbItem.TaxValue) - ( Invoice.tbItem.PaidValue + Invoice.tbItem.PaidTaxValue) 
							  ELSE 0 END) AS PayOut
		FROM         Invoice.tbItem INNER JOIN
							  Invoice.tbInvoice ON Invoice.tbItem.InvoiceNumber = Invoice.tbInvoice.InvoiceNumber INNER JOIN
							  Cash.tbCode ON Invoice.tbItem.CashCode = Cash.tbCode.CashCode INNER JOIN
							  Cash.tbCategory ON Cash.tbCode.CategoryCode = Cash.tbCategory.CategoryCode
		WHERE  (InvoiceStatusCode < 3) AND (( Invoice.tbItem.InvoiceValue + Invoice.tbItem.TaxValue) - ( Invoice.tbItem.PaidValue + Invoice.tbItem.PaidTaxValue) > 0)
		GROUP BY Invoice.tbItem.InvoiceNumber, Invoice.tbInvoice.AccountCode, Invoice.tbInvoice.ExpectedOn, Invoice.tbItem.CashCode
	), invoices_unpaid_tasks AS
	(
		SELECT     Invoice.tbInvoice.AccountCode, Invoice.tbTask.CashCode, Invoice.tbInvoice.ExpectedOn AS TransactOn, 1 AS CashEntryTypeCode, Invoice.tbTask.InvoiceNumber AS ReferenceCode, 
							  SUM(CASE WHEN InvoiceTypeCode = 0 OR
							  InvoiceTypeCode = 3 THEN ( Invoice.tbTask.InvoiceValue + Invoice.tbTask.TaxValue) - ( Invoice.tbTask.PaidValue + Invoice.tbTask.PaidTaxValue) 
							  ELSE 0 END) AS PayIn, SUM(CASE WHEN InvoiceTypeCode = 1 OR
							  InvoiceTypeCode = 2 THEN ( Invoice.tbTask.InvoiceValue + Invoice.tbTask.TaxValue) - ( Invoice.tbTask.PaidValue + Invoice.tbTask.PaidTaxValue) 
							  ELSE 0 END) AS PayOut
		FROM         Invoice.tbTask INNER JOIN
							  Invoice.tbInvoice ON Invoice.tbTask.InvoiceNumber = Invoice.tbInvoice.InvoiceNumber INNER JOIN
							  Cash.tbCode ON Invoice.tbTask.CashCode = Cash.tbCode.CashCode INNER JOIN
							  Cash.tbCategory ON Cash.tbCode.CategoryCode = Cash.tbCategory.CategoryCode
		WHERE  (InvoiceStatusCode < 3) AND  (( Invoice.tbTask.InvoiceValue + Invoice.tbTask.TaxValue) - ( Invoice.tbTask.PaidValue + Invoice.tbTask.PaidTaxValue) > 0)
		GROUP BY Invoice.tbTask.InvoiceNumber, Invoice.tbInvoice.AccountCode, Invoice.tbInvoice.ExpectedOn, Invoice.tbTask.CashCode
	), task_invoiced_quantity AS
	(
		SELECT        Invoice.tbTask.TaskCode, SUM(Invoice.tbTask.Quantity) AS InvoiceQuantity
		FROM            Invoice.tbTask INNER JOIN
								 Invoice.tbInvoice ON Invoice.tbTask.InvoiceNumber = Invoice.tbInvoice.InvoiceNumber
		WHERE        (Invoice.tbInvoice.InvoiceTypeCode = 0) OR
								 (Invoice.tbInvoice.InvoiceTypeCode = 2)
		GROUP BY Invoice.tbTask.TaskCode
	), tasks_confirmed AS
	(
		SELECT        TOP (100) PERCENT Task.tbTask.TaskCode AS ReferenceCode, Task.tbTask.AccountCode, Task.tbTask.PaymentOn AS TransactOn, Task.tbTask.PaymentOn, 2 AS CashEntryTypeCode, 
								 CASE WHEN Cash.tbCategory.CashModeCode = 0 THEN (Task.tbTask.UnitCharge + Task.tbTask.UnitCharge * App.tbTaxCode.TaxRate) * (Task.tbTask.Quantity - ISNULL(task_invoiced_quantity.InvoiceQuantity, 
								 0)) ELSE 0 END AS PayOut, CASE WHEN Cash.tbCategory.CashModeCode = 1 THEN (Task.tbTask.UnitCharge + Task.tbTask.UnitCharge * App.tbTaxCode.TaxRate) 
								 * (Task.tbTask.Quantity - ISNULL(task_invoiced_quantity.InvoiceQuantity, 0)) ELSE 0 END AS PayIn, Cash.tbCode.CashCode
		FROM            App.tbTaxCode INNER JOIN
								 Task.tbTask ON App.tbTaxCode.TaxCode = Task.tbTask.TaxCode INNER JOIN
								 Cash.tbCode ON Task.tbTask.CashCode = Cash.tbCode.CashCode INNER JOIN
								 Cash.tbCategory ON Cash.tbCode.CategoryCode = Cash.tbCategory.CategoryCode LEFT OUTER JOIN
								 task_invoiced_quantity ON Task.tbTask.TaskCode = task_invoiced_quantity.TaskCode
		WHERE        (Task.tbTask.TaskStatusCode > 0) AND (Task.tbTask.TaskStatusCode < 3) AND (Task.tbTask.Quantity - ISNULL(task_invoiced_quantity.InvoiceQuantity, 0) > 0)
	)
	--interbank transfers
	, transfer_current_account AS
	(
		SELECT        Org.tbAccount.CashAccountCode
		FROM            Org.tbAccount INNER JOIN
								 Cash.tbCode ON Org.tbAccount.CashCode = Cash.tbCode.CashCode INNER JOIN
								 Cash.tbCategory ON Cash.tbCode.CategoryCode = Cash.tbCategory.CategoryCode AND Cash.tbCode.CategoryCode = Cash.tbCategory.CategoryCode
		WHERE        (Cash.tbCategory.CashTypeCode = 2)
	), transfer_accruals AS
	(
		SELECT        Org.tbPayment.AccountCode, Org.tbPayment.CashCode, Org.tbPayment.PaidOn AS TransactOn, Org.tbPayment.PaymentCode AS ReferenceCode, 
			6 AS CashEntryTypeCode, Org.tbPayment.PaidInValue AS PayIn, Org.tbPayment.PaidOutValue AS PayOut
		FROM            transfer_current_account INNER JOIN
								 Org.tbPayment ON transfer_current_account.CashAccountCode = Org.tbPayment.CashAccountCode
		WHERE        (Org.tbPayment.PaymentStatusCode = 2)
	)
	, statement_unsorted AS
	(
		SELECT AccountCode, CashCode, TransactOn, ReferenceCode, CashEntryTypeCode, PayIn, PayOut FROM corptax_invoiced_owing
		UNION
		SELECT AccountCode, CashCode, TransactOn, ReferenceCode, CashEntryTypeCode, PayIn, PayOut FROM vat_invoiced_owing
		UNION
		SELECT AccountCode, CashCode, TransactOn, ReferenceCode, CashEntryTypeCode, PayIn, PayOut FROM corptax_accruals
		UNION
		SELECT AccountCode, CashCode, TransactOn, ReferenceCode, CashEntryTypeCode, PayIn, PayOut FROM vat_accruals
		UNION
		SELECT AccountCode, CashCode, TransactOn, ReferenceCode, CashEntryTypeCode, PayIn, PayOut FROM invoices_unpaid_items
		UNION 
		SELECT AccountCode, CashCode, TransactOn, ReferenceCode, CashEntryTypeCode, PayIn, PayOut FROM invoices_unpaid_tasks
		UNION 
		SELECT AccountCode, CashCode, TransactOn, ReferenceCode, CashEntryTypeCode, PayIn, PayOut FROM tasks_confirmed
		UNION
		SELECT AccountCode, CashCode, TransactOn, ReferenceCode, CashEntryTypeCode, PayIn, PayOut FROM transfer_accruals
	), statement_sorted AS
	(
		SELECT ROW_NUMBER() OVER(ORDER BY TransactOn, CashEntryTypeCode DESC) AS RowNumber,
		 AccountCode, CashCode, TransactOn, ReferenceCode, CashEntryTypeCode, PayIn, PayOut FROM statement_unsorted			
	), opening_balance AS
	(	
		SELECT SUM( Org.tbAccount.CurrentBalance) AS OpeningBalance
		FROM         Org.tbAccount INNER JOIN
							  Cash.tbCode ON Org.tbAccount.CashCode = Cash.tbCode.CashCode
		WHERE     ( Org.tbAccount.AccountClosed = 0) AND (Org.tbAccount.DummyAccount = 0)
	), statement_data AS
	(
		SELECT 
			0 AS RowNumber,
			(SELECT TOP (1) AccountCode FROM App.tbOptions) AS AccountCode,
			NULL AS CashCode,
			NULL AS TransactOn,    
			(SELECT CAST(Message AS NVARCHAR) FROM App.tbText WHERE TextId = 3013) AS ReferenceCode,	
			1 AS CashEntryTypeCode,
			PayIn = (SELECT OpeningBalance FROM opening_balance),
			0 AS PayOut
		UNION 
		SELECT RowNumber, AccountCode, CashCode, TransactOn, ReferenceCode, CashEntryTypeCode, PayIn, PayOut FROM statement_sorted
	), company_statement AS
	(
		SELECT RowNumber, AccountCode, CashCode, TransactOn, ReferenceCode, CashEntryTypeCode, PayIn, PayOut,
			SUM(PayIn + (PayOut * -1)) OVER (ORDER BY RowNumber ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS Balance
		FROM statement_data
	)
	SELECT RowNumber, cs.AccountCode, org.AccountName, cs.CashCode, cc.CashDescription,
			TransactOn, ReferenceCode, cs.CashEntryTypeCode, et.CashEntryType, CAST(PayIn AS MONEY) PayIn, CAST(PayOut AS MONEY) PayOut, CAST(Balance AS MONEY) Balance
	FROM company_statement cs 
		JOIN Org.tbOrg org ON cs.AccountCode = org.AccountCode
		JOIN Cash.tbEntryType et ON cs.CashEntryTypeCode = et.CashEntryTypeCode
		LEFT OUTER JOIN Cash.tbCode cc ON cs.CashCode = cc.CashCode;
go

CREATE VIEW Cash.vwTaxCorpAuditAccruals
AS
	SELECT     App.tbYear.YearNumber, CONCAT(App.tbYear.Description, ' ', App.tbMonth.MonthName) AS YearPeriod, Cash.vwTaxCorpAccruals.StartOn, Task.tbTask.TaskCode, Task.tbTask.AccountCode, Org.tbOrg.AccountName, 
							 Task.tbTask.TaskTitle, Activity.tbActivity.ActivityCode, Task.tbStatus.TaskStatusCode, Task.tbStatus.TaskStatus, Task.tbTask.CashCode, Cash.tbCode.CashDescription, Activity.tbActivity.UnitOfMeasure, 
							 Cash.vwTaxCorpAccruals.QuantityRemaining, Cash.vwTaxCorpAccruals.OrderValue, Cash.vwTaxCorpAccruals.TaxDue
	FROM            Task.tbTask INNER JOIN
							 Org.tbOrg ON Task.tbTask.AccountCode = Org.tbOrg.AccountCode INNER JOIN
							 Cash.vwTaxCorpAccruals ON Task.tbTask.TaskCode = Cash.vwTaxCorpAccruals.TaskCode INNER JOIN
							 Task.tbStatus ON Task.tbTask.TaskStatusCode = Task.tbStatus.TaskStatusCode AND Task.tbTask.TaskStatusCode = Task.tbStatus.TaskStatusCode INNER JOIN
							 Activity.tbActivity ON Task.tbTask.ActivityCode = Activity.tbActivity.ActivityCode AND Task.tbTask.ActivityCode = Activity.tbActivity.ActivityCode INNER JOIN
							 Cash.tbCode ON Task.tbTask.CashCode = Cash.tbCode.CashCode AND Task.tbTask.CashCode = Cash.tbCode.CashCode INNER JOIN
							 App.tbYearPeriod ON Cash.vwTaxCorpAccruals.StartOn = App.tbYearPeriod.StartOn INNER JOIN
							 App.tbYear ON App.tbYearPeriod.YearNumber = App.tbYear.YearNumber AND App.tbYearPeriod.YearNumber = App.tbYear.YearNumber AND App.tbYearPeriod.YearNumber = App.tbYear.YearNumber AND 
							 App.tbYearPeriod.YearNumber = App.tbYear.YearNumber AND App.tbYearPeriod.YearNumber = App.tbYear.YearNumber AND App.tbYearPeriod.YearNumber = App.tbYear.YearNumber AND 
							 App.tbYearPeriod.YearNumber = App.tbYear.YearNumber INNER JOIN
							 App.tbMonth ON App.tbYearPeriod.MonthNumber = App.tbMonth.MonthNumber AND App.tbYearPeriod.MonthNumber = App.tbMonth.MonthNumber AND 
							 App.tbYearPeriod.MonthNumber = App.tbMonth.MonthNumber AND App.tbYearPeriod.MonthNumber = App.tbMonth.MonthNumber AND App.tbYearPeriod.MonthNumber = App.tbMonth.MonthNumber AND 
							 App.tbYearPeriod.MonthNumber = App.tbMonth.MonthNumber AND App.tbYearPeriod.MonthNumber = App.tbMonth.MonthNumber
go

CREATE VIEW Invoice.vwHistorySales
AS
SELECT        App.tbYearPeriod.YearNumber, CONCAT(App.tbMonth.MonthName, SPACE(1), YEAR(App.tbYearPeriod.StartOn)) AS PeriodName, Invoice.vwRegister.StartOn, 
                         Invoice.vwRegister.InvoiceNumber, Invoice.vwRegister.AccountCode, Invoice.vwRegister.InvoiceTypeCode, Invoice.vwRegister.InvoiceStatusCode, Invoice.vwRegister.InvoicedOn, 
                         Invoice.vwRegister.InvoiceValue, Invoice.vwRegister.TaxValue, Invoice.vwRegister.PaidValue, Invoice.vwRegister.PaidTaxValue, Invoice.vwRegister.PaymentTerms, Invoice.vwRegister.Notes, 
                         Invoice.vwRegister.Printed, Invoice.vwRegister.AccountName, Invoice.vwRegister.UserName, Invoice.vwRegister.InvoiceStatus, Invoice.vwRegister.CashModeCode, Invoice.vwRegister.InvoiceType, 
                         (Invoice.vwRegister.InvoiceValue + Invoice.vwRegister.TaxValue) - (Invoice.vwRegister.PaidValue + Invoice.vwRegister.PaidTaxValue) AS UnpaidValue
FROM            App.tbYearPeriod INNER JOIN
                         App.tbMonth ON App.tbYearPeriod.MonthNumber = App.tbMonth.MonthNumber INNER JOIN
                         App.tbYear ON App.tbYearPeriod.YearNumber = App.tbYear.YearNumber INNER JOIN
                         Invoice.vwRegister ON App.tbYearPeriod.StartOn = Invoice.vwRegister.StartOn
WHERE        (Invoice.vwRegister.InvoiceTypeCode < 2);
go

CREATE VIEW Org.vwMailContacts
  AS
SELECT     AccountCode, ContactName, NickName, NameTitle + N' ' + ContactName AS FormalName, JobTitle, Department
FROM         Org.tbContact
WHERE     (OnMailingList <> 0)

go

CREATE VIEW Org.vwAddresses
  AS
SELECT     TOP 100 PERCENT Org.tbOrg.AccountName, Org.tbAddress.Address, Org.tbOrg.OrganisationTypeCode, Org.tbOrg.OrganisationStatusCode, 
                      Org.tbType.OrganisationType, Org.tbStatus.OrganisationStatus, Org.vwMailContacts.ContactName, Org.vwMailContacts.NickName, 
                      Org.vwMailContacts.FormalName, Org.vwMailContacts.JobTitle, Org.vwMailContacts.Department
FROM         Org.tbOrg INNER JOIN
                      Org.tbAddress ON Org.tbOrg.AddressCode = Org.tbAddress.AddressCode INNER JOIN
                      Org.tbType ON Org.tbOrg.OrganisationTypeCode = Org.tbType.OrganisationTypeCode INNER JOIN
                      Org.tbStatus ON Org.tbOrg.OrganisationStatusCode = Org.tbStatus.OrganisationStatusCode LEFT OUTER JOIN
                      Org.vwMailContacts ON Org.tbOrg.AccountCode = Org.vwMailContacts.AccountCode
ORDER BY Org.tbOrg.AccountName

go

CREATE VIEW Task.vwOpBucket
AS
SELECT        op.TaskCode, op.OperationNumber, op.EndOn, buckets.Period, buckets.BucketId
FROM            Task.tbOp AS op CROSS APPLY
			(	SELECT  buckets.Period, buckets.BucketId
				FROM        App.fnBuckets(CURRENT_TIMESTAMP) buckets 
				WHERE     (StartDate <= op.EndOn) AND (EndDate > op.EndOn)) AS buckets
go

CREATE VIEW Task.vwOps
AS
SELECT        Task.tbOp.TaskCode, Task.tbTask.ActivityCode, Task.tbOp.OperationNumber, Task.vwOpBucket.Period, Task.vwOpBucket.BucketId, Task.tbOp.UserId, Task.tbOp.SyncTypeCode, Task.tbOp.OpStatusCode, 
                         Task.tbOp.Operation, Task.tbOp.Note, Task.tbOp.StartOn, Task.tbOp.EndOn, Task.tbOp.Duration, Task.tbOp.OffsetDays, Task.tbOp.InsertedBy, Task.tbOp.InsertedOn, Task.tbOp.UpdatedBy, Task.tbOp.UpdatedOn, 
                         Task.tbTask.TaskTitle, Task.tbTask.TaskStatusCode, Task.tbStatus.TaskStatus, Task.tbTask.ActionOn, Task.tbTask.Quantity, Cash.tbCode.CashDescription, Task.tbTask.TotalCharge, Task.tbTask.AccountCode, 
                         Org.tbOrg.AccountName, Task.tbOp.RowVer AS OpRowVer, Task.tbTask.RowVer AS TaskRowVer
FROM            Task.tbOp INNER JOIN
                         Task.tbTask ON Task.tbOp.TaskCode = Task.tbTask.TaskCode INNER JOIN
                         Org.tbOrg ON Task.tbTask.AccountCode = Org.tbOrg.AccountCode INNER JOIN
                         Task.tbStatus ON Task.tbTask.TaskStatusCode = Task.tbStatus.TaskStatusCode INNER JOIN
                         Task.vwOpBucket ON Task.tbOp.TaskCode = Task.vwOpBucket.TaskCode AND Task.tbOp.OperationNumber = Task.vwOpBucket.OperationNumber LEFT OUTER JOIN
                         Cash.tbCode ON Task.tbTask.CashCode = Cash.tbCode.CashCode
go

CREATE VIEW Cash.vwTaxVatTotals
AS
	WITH vat_dates AS
	(
		SELECT PayFrom, PayTo FROM Cash.fnTaxTypeDueDates(1)
	), vatPeriod AS
	(
		SELECT        StartOn, y.YearNumber, p.MonthNumber,
			(SELECT PayTo FROM vat_dates WHERE p.StartOn >= PayFrom AND p.StartOn < PayTo) AS VatStartOn, VatAdjustment
		FROM            App.tbYearPeriod AS p JOIN App.tbYear AS y ON p.YearNumber = y.YearNumber 
		WHERE     (y.CashStatusCode = 1) OR (y.CashStatusCode = 2)
	), vat_results AS
	(
		SELECT VatStartOn AS PayTo, DATEADD(MONTH, -1, VatStartOn) AS PostOn,
			SUM(HomeSales) AS HomeSales, SUM(HomePurchases) AS HomePurchases, SUM(ExportSales) AS ExportSales, SUM(ExportPurchases) AS ExportPurchases, 
			SUM(HomeSalesVat) AS HomeSalesVat, SUM(HomePurchasesVat) AS HomePurchasesVat, 
			SUM(ExportSalesVat) AS ExportSalesVat, SUM(ExportPurchasesVat) AS ExportPurchasesVat, SUM(VatDue) AS VatDue
		FROM Cash.vwTaxVatSummary vatCodeDue JOIN vatPeriod ON vatCodeDue.StartOn = vatPeriod.StartOn
		GROUP BY VatStartOn
	), vat_adjustments AS
	(
		SELECT VatStartOn AS PayTo, SUM(VatAdjustment) AS VatAdjustment
		FROM vatPeriod p 
		GROUP BY VatStartOn
	)
	SELECT active_year.YearNumber, active_year.Description, active_month.MonthName AS Period, vat_results.PostOn AS StartOn, HomeSales, HomePurchases, ExportSales, ExportPurchases, HomeSalesVat, HomePurchasesVat, ExportSalesVat, ExportPurchasesVat,
		vat_adjustments.VatAdjustment, VatDue - vat_adjustments.VatAdjustment AS VatDue
	FROM vat_results JOIN vat_adjustments ON vat_results.PayTo = vat_adjustments.PayTo
		JOIN App.tbYearPeriod year_period ON vat_results.PostOn = year_period.StartOn
		JOIN App.tbMonth active_month ON year_period.MonthNumber = active_month.MonthNumber
		JOIN App.tbYear active_year ON year_period.YearNumber = active_year.YearNumber;
go


CREATE VIEW Org.vwDatasheet
AS
	With task_count AS
	(
		SELECT        AccountCode, COUNT(TaskCode) AS TaskCount
		FROM            Task.tbTask
		WHERE        (TaskStatusCode = 1)
		GROUP BY AccountCode
	)
	SELECT        o.AccountCode, o.AccountName, ISNULL(task_count.TaskCount, 0) AS Tasks, o.OrganisationTypeCode, Org.tbType.OrganisationType, Org.tbType.CashModeCode, o.OrganisationStatusCode, 
							 Org.tbStatus.OrganisationStatus, Org.tbAddress.Address, App.tbTaxCode.TaxDescription, o.TaxCode, o.AddressCode, o.AreaCode, o.PhoneNumber, o.FaxNumber, o.EmailAddress, o.WebSite,
								 (SELECT        TOP (1) IndustrySector
								   FROM            Org.tbSector AS sector
								   WHERE        (AccountCode = o.AccountCode)) AS IndustrySector, o.AccountSource, o.PaymentTerms, o.PaymentDays, o.ExpectedDays, o.PayDaysFromMonthEnd, o.PayBalance, o.NumberOfEmployees, o.CompanyNumber, o.VatNumber, o.Turnover, 
							 o.OpeningBalance, o.EUJurisdiction, o.BusinessDescription, o.InsertedBy, o.InsertedOn, o.UpdatedBy, o.UpdatedOn 
	FROM            Org.tbOrg AS o INNER JOIN
							 Org.tbStatus ON o.OrganisationStatusCode = Org.tbStatus.OrganisationStatusCode INNER JOIN
							 Org.tbType ON o.OrganisationTypeCode = Org.tbType.OrganisationTypeCode LEFT OUTER JOIN
							 App.tbTaxCode ON o.TaxCode = App.tbTaxCode.TaxCode LEFT OUTER JOIN
							 Org.tbAddress ON o.AddressCode = Org.tbAddress.AddressCode LEFT OUTER JOIN
							 task_count ON o.AccountCode = task_count.AccountCode
go

CREATE VIEW Org.vwStatusReport
AS
SELECT        Org.vwDatasheet.AccountCode, Org.vwDatasheet.AccountName, Org.vwDatasheet.OrganisationType, Org.vwDatasheet.OrganisationStatus, Org.vwDatasheet.TaxDescription, Org.vwDatasheet.Address, 
                         Org.vwDatasheet.AreaCode, Org.vwDatasheet.PhoneNumber, Org.vwDatasheet.FaxNumber, Org.vwDatasheet.EmailAddress, Org.vwDatasheet.WebSite, Org.vwDatasheet.IndustrySector, 
                         Org.vwDatasheet.AccountSource, Org.vwDatasheet.PaymentTerms, Org.vwDatasheet.PaymentDays, Org.vwDatasheet.ExpectedDays, Org.vwDatasheet.NumberOfEmployees, Org.vwDatasheet.CompanyNumber, Org.vwDatasheet.VatNumber, 
                         Org.vwDatasheet.Turnover, Org.vwDatasheet.OpeningBalance, Org.vwDatasheet.EUJurisdiction, Org.vwDatasheet.BusinessDescription, 
                         Org.tbPayment.PaymentCode, Usr.tbUser.UserName, App.tbTaxCode.TaxDescription AS PaymentTaxDescription, Org.tbAccount.CashAccountName, Cash.tbCode.CashDescription, Org.tbPayment.UserId, 
                         Org.tbPayment.CashAccountCode, Org.tbPayment.CashCode, Org.tbPayment.TaxCode, Org.tbPayment.PaidOn, Org.tbPayment.PaidInValue, Org.tbPayment.PaidOutValue, Org.tbPayment.TaxInValue, 
                         Org.tbPayment.TaxOutValue, Org.tbPayment.InsertedBy, Org.tbPayment.InsertedOn, Org.tbPayment.UpdatedBy, Org.tbPayment.UpdatedOn, Org.tbPayment.PaymentReference
FROM            Org.tbPayment INNER JOIN
                         Usr.tbUser ON Org.tbPayment.UserId = Usr.tbUser.UserId INNER JOIN
                         Org.tbAccount ON Org.tbPayment.CashAccountCode = Org.tbAccount.CashAccountCode INNER JOIN
                         Cash.tbCode ON Org.tbPayment.CashCode = Cash.tbCode.CashCode LEFT OUTER JOIN
                         App.tbTaxCode ON Org.tbPayment.TaxCode = App.tbTaxCode.TaxCode INNER JOIN
                         Org.vwDatasheet ON Org.tbPayment.AccountCode = Org.vwDatasheet.AccountCode
WHERE        (Org.tbPayment.PaymentStatusCode = 1);
go

CREATE VIEW Cash.vwTaxCorpTotals
AS
	WITH totals AS
	(
		SELECT netprofit_totals.StartOn, YEAR(App.tbYearPeriod.StartOn) AS PeriodYear, App.tbYear.Description, 
						  App.tbMonth.MonthName + ' ' + LTRIM(STR(YEAR(App.tbYearPeriod.StartOn))) AS Period, App.tbYearPeriod.CorporationTaxRate, 
						  App.tbYearPeriod.TaxAdjustment, SUM(netprofit_totals.NetProfit) AS NetProfit, SUM(netprofit_totals.CorporationTax) AS CorporationTax
		FROM       Cash.vwTaxCorpTotalsByPeriod  netprofit_totals INNER JOIN
							  App.tbYearPeriod ON netprofit_totals.StartOn = App.tbYearPeriod.StartOn INNER JOIN
							  App.tbYear ON App.tbYearPeriod.YearNumber = App.tbYear.YearNumber INNER JOIN
							  App.tbMonth ON App.tbYearPeriod.MonthNumber = App.tbMonth.MonthNumber
		WHERE     (App.tbYear.CashStatusCode BETWEEN 1 AND 2)
		GROUP BY App.tbYear.Description, App.tbMonth.MonthName, netprofit_totals.StartOn, YEAR(App.tbYearPeriod.StartOn), 
							  App.tbYearPeriod.CorporationTaxRate, App.tbYearPeriod.TaxAdjustment
	)
	SELECT StartOn, PeriodYear, [Description], [Period], CorporationTaxRate, TaxAdjustment, CAST(NetProfit AS MONEY) NetProfit, CAST(CorporationTax AS MONEY) CorporationTax
	FROM totals;
go

CREATE VIEW Invoice.vwRegisterExpenses
 AS
SELECT     Invoice.vwRegisterTasks.StartOn, Invoice.vwRegisterTasks.InvoiceNumber, Invoice.vwRegisterTasks.TaskCode, App.tbYearPeriod.YearNumber, 
                      App.tbYear.Description, App.tbMonth.MonthName + ' ' + LTRIM(STR(YEAR( App.tbYearPeriod.StartOn))) AS Period, Invoice.vwRegisterTasks.TaskTitle, 
                      Invoice.vwRegisterTasks.CashCode, Invoice.vwRegisterTasks.CashDescription, Invoice.vwRegisterTasks.TaxCode, Invoice.vwRegisterTasks.TaxDescription, 
                      Invoice.vwRegisterTasks.AccountCode, Invoice.vwRegisterTasks.InvoiceTypeCode, Invoice.vwRegisterTasks.InvoiceStatusCode, Invoice.vwRegisterTasks.InvoicedOn, 
                      Invoice.vwRegisterTasks.InvoiceValue, Invoice.vwRegisterTasks.TaxValue, Invoice.vwRegisterTasks.PaidValue, Invoice.vwRegisterTasks.PaidTaxValue, 
                      Invoice.vwRegisterTasks.PaymentTerms, Invoice.vwRegisterTasks.Printed, Invoice.vwRegisterTasks.AccountName, Invoice.vwRegisterTasks.UserName, 
                      Invoice.vwRegisterTasks.InvoiceStatus, Invoice.vwRegisterTasks.CashModeCode, Invoice.vwRegisterTasks.InvoiceType, 
                      (Invoice.vwRegisterTasks.InvoiceValue + Invoice.vwRegisterTasks.TaxValue) - (Invoice.vwRegisterTasks.PaidValue + Invoice.vwRegisterTasks.PaidTaxValue) 
                      AS UnpaidValue
FROM         Invoice.vwRegisterTasks INNER JOIN
                      App.tbYearPeriod ON Invoice.vwRegisterTasks.StartOn = App.tbYearPeriod.StartOn INNER JOIN
                      App.tbYear ON App.tbYearPeriod.YearNumber = App.tbYear.YearNumber INNER JOIN
                      App.tbMonth ON App.tbYearPeriod.MonthNumber = App.tbMonth.MonthNumber
WHERE     (Task.fnIsExpense(Invoice.vwRegisterTasks.TaskCode) = 1)

go

CREATE VIEW Cash.vwSummary
AS
	WITH company AS
	(
		SELECT 0 AS SummaryId, SUM( Org.tbAccount.CurrentBalance) AS CompanyBalance 
		FROM Org.tbAccount WHERE ( Org.tbAccount.AccountClosed = 0) AND (Org.tbAccount.DummyAccount = 0)
	), corp_tax_invoiced AS
	(
		SELECT TOP (1)  0 AS SummaryId, Balance AS CorpTaxBalance 
		FROM Cash.vwTaxCorpStatement 
		ORDER BY StartOn DESC
	), corp_tax_ordered AS
	(
		SELECT 0 AS SummaryId, SUM(TaxDue) AS CorpTaxBalance
		FROM Cash.vwTaxCorpAccruals
	), vat_invoiced AS
	(
		SELECT TOP (1)  0 AS SummaryId, Balance AS VatBalance 
		FROM Cash.vwTaxVatStatement 
		ORDER BY StartOn DESC, VatDue DESC
	), vat_accruals AS
	(
		SELECT 0 AS SummaryId, SUM(VatDue) AS VatBalance
		FROM Cash.vwTaxVatAccruals
	), invoices AS
	(
		SELECT     Invoice.tbInvoice.InvoiceNumber, CASE Invoice.tbInvoice.InvoiceTypeCode WHEN 0 THEN (InvoiceValue + TaxValue) - (PaidValue + PaidTaxValue) 
						  WHEN 3 THEN (InvoiceValue + TaxValue) - (PaidValue + PaidTaxValue) ELSE 0 END AS ToCollect, 
						  CASE Invoice.tbInvoice.InvoiceTypeCode WHEN 1 THEN (InvoiceValue + TaxValue) - (PaidValue + PaidTaxValue) WHEN 2 THEN (InvoiceValue + TaxValue) 
						  - (PaidValue + PaidTaxValue) ELSE 0 END AS ToPay, CASE Invoice.tbType.CashModeCode WHEN 0 THEN (TaxValue - PaidTaxValue) 
						  * - 1 WHEN 1 THEN TaxValue - PaidTaxValue END AS TaxValue
		FROM         Invoice.tbInvoice INNER JOIN
							  Invoice.tbType ON Invoice.tbInvoice.InvoiceTypeCode = Invoice.tbType.InvoiceTypeCode
		WHERE     (Invoice.tbInvoice.InvoiceStatusCode = 1) OR
						  (Invoice.tbInvoice.InvoiceStatusCode = 2)
	), invoice_totals AS
	(
		SELECT 0 AS SummaryId, ISNULL(SUM(ToCollect), 0) AS Collect, ISNULL(SUM(ToPay), 0) AS Pay, ISNULL(SUM(TaxValue), 0) AS TaxValue
		FROM  invoices
	), summary_base AS
	(
		SELECT Collect, Pay, TaxValue + vat_invoiced.VatBalance + vat_accruals.VatBalance + corp_tax_invoiced.CorpTaxBalance + corp_tax_ordered.CorpTaxBalance AS Tax, CompanyBalance
		FROM company 
				JOIN corp_tax_invoiced ON company.SummaryId = corp_tax_invoiced.SummaryId
				JOIN corp_tax_ordered ON company.SummaryId = corp_tax_ordered.SummaryId
				JOIN vat_invoiced ON company.SummaryId = vat_invoiced.SummaryId
				JOIN vat_accruals ON company.SummaryId = vat_accruals.SummaryId
				JOIN invoice_totals ON company.SummaryId = invoice_totals.SummaryId
	)
	SELECT CURRENT_TIMESTAMP AS Timestamp, Collect, Pay, Tax, CompanyBalance AS Cash, CompanyBalance + Collect - Pay - Tax AS Balance
	FROM    summary_base;
go

CREATE VIEW App.vwHomeAccount
AS
	SELECT     Org.tbOrg.AccountCode, Org.tbOrg.AccountName
	FROM            App.tbOptions INNER JOIN
							 Org.tbOrg ON App.tbOptions.AccountCode = Org.tbOrg.AccountCode
go

CREATE VIEW Cash.vwBankAccounts
AS
	SELECT CashAccountCode, CashAccountName, OpeningBalance, CASE WHEN NOT CashCode IS NULL THEN 0 ELSE 1 END AS DisplayOrder
	FROM Org.tbAccount  
	WHERE AccountCode <> (SELECT AccountCode FROM App.vwHomeAccount)
go

CREATE VIEW Cash.vwAccountPeriodClosingBalance
AS
	WITH last_entries AS
	(
		SELECT     CashAccountCode, StartOn, MAX(EntryNumber) AS LastEntry
		FROM         Cash.vwAccountStatement
		GROUP BY CashAccountCode, StartOn
		HAVING      (NOT (StartOn IS NULL))
	)
	SELECT        Org.tbAccount.CashAccountCode, Org.tbAccount.CashCode, last_entries.StartOn, SUM(Cash.vwAccountStatement.PaidBalance) AS ClosingBalance
	FROM            last_entries INNER JOIN
							 Cash.vwAccountStatement ON last_entries.CashAccountCode = Cash.vwAccountStatement.CashAccountCode AND 
							 last_entries.StartOn = Cash.vwAccountStatement.StartOn AND 
							 last_entries.LastEntry = Cash.vwAccountStatement.EntryNumber INNER JOIN
							 Org.tbAccount ON last_entries.CashAccountCode = Org.tbAccount.CashAccountCode
	GROUP BY Org.tbAccount.CashAccountCode, Org.tbAccount.CashCode, last_entries.StartOn
go

CREATE VIEW App.vwGraphBankBalance
AS
SELECT        Format(Cash.vwAccountPeriodClosingBalance.StartOn, 'yyyy-MM') AS PeriodOn, SUM(Cash.vwAccountPeriodClosingBalance.ClosingBalance) AS SumOfClosingBalance
FROM            Cash.vwAccountPeriodClosingBalance INNER JOIN
                         Cash.tbCode ON Cash.vwAccountPeriodClosingBalance.CashCode = Cash.tbCode.CashCode
WHERE        (Cash.vwAccountPeriodClosingBalance.StartOn > DATEADD(m, - 6, CURRENT_TIMESTAMP))
GROUP BY Format(Cash.vwAccountPeriodClosingBalance.StartOn, 'yyyy-MM');
go

CREATE VIEW Usr.vwUserMenus
AS
SELECT Usr.tbMenuUser.MenuId
FROM Usr.vwCredentials INNER JOIN Usr.tbMenuUser ON Usr.vwCredentials.UserId = Usr.tbMenuUser.UserId;
go

CREATE VIEW Org.vwInvoiceSummary
AS
	WITH ois AS
	(
		SELECT        AccountCode, StartOn, SUM(InvoiceValue) AS PeriodValue
		FROM            Invoice.vwRegister
		GROUP BY AccountCode, StartOn
	), acc AS
	(
		SELECT Org.tbOrg.AccountCode, App.vwPeriods.StartOn
		FROM Org.tbOrg CROSS JOIN App.vwPeriods
	)
	SELECT TOP (100) PERCENT acc.AccountCode, acc.StartOn, ois.PeriodValue 
	FROM ois RIGHT OUTER JOIN acc ON ois.AccountCode = acc.AccountCode AND ois.StartOn = acc.StartOn
	ORDER BY acc.AccountCode, acc.StartOn;
go

CREATE VIEW App.vwDocPurchaseEnquiry
AS
SELECT        TOP (100) PERCENT Task.vwTasks.TaskCode, Task.vwTasks.ActionOn, Task.vwTasks.ActivityCode, Task.vwTasks.ActionById, Task.vwTasks.BucketId, Task.vwTasks.TaskTitle, Task.vwTasks.AccountCode, 
                         Task.vwTasks.ContactName, Task.vwTasks.TaskNotes, Task.vwTasks.OwnerName, Task.vwTasks.CashCode, Task.vwTasks.CashDescription, Task.vwTasks.Quantity, Activity.tbActivity.UnitOfMeasure, 
                         Task.vwTasks.UnitCharge, Task.vwTasks.TotalCharge, Org_tbAddress_1.Address AS FromAddress, Org.tbAddress.Address AS ToAddress, Task.vwTasks.InsertedBy, Task.vwTasks.InsertedOn, 
                         Task.vwTasks.UpdatedBy, Task.vwTasks.UpdatedOn, Task.vwTasks.AccountName, Task.vwTasks.ActionName, Task.vwTasks.Period, Task.vwTasks.Printed, Task.vwTasks.Spooled, Task.vwTasks.RowVer
FROM            Task.vwTasks LEFT OUTER JOIN
                         Org.tbAddress AS Org_tbAddress_1 ON Task.vwTasks.AddressCodeFrom = Org_tbAddress_1.AddressCode LEFT OUTER JOIN
                         Org.tbAddress ON Task.vwTasks.AddressCodeTo = Org.tbAddress.AddressCode INNER JOIN
                         Activity.tbActivity ON Task.vwTasks.ActivityCode = Activity.tbActivity.ActivityCode
WHERE        (Task.vwTasks.CashCode IS NOT NULL) AND (Task.vwTasks.CashModeCode = 0) AND (Task.vwTasks.TaskStatusCode = 0);
go

CREATE VIEW App.vwDocPurchaseOrder
AS
SELECT        TOP (100) PERCENT Task.vwTasks.TaskCode, Task.vwTasks.ActionOn, Task.vwTasks.ActivityCode, Task.vwTasks.ActionById, Task.vwTasks.BucketId, Task.vwTasks.TaskTitle, Task.vwTasks.AccountCode, 
                         Task.vwTasks.ContactName, Task.vwTasks.TaskNotes, Task.vwTasks.OwnerName, Task.vwTasks.CashCode, Task.vwTasks.CashDescription, Task.vwTasks.Quantity, Activity.tbActivity.UnitOfMeasure, 
                         Task.vwTasks.UnitCharge, Task.vwTasks.TotalCharge, Org_tbAddress_1.Address AS FromAddress, Org.tbAddress.Address AS ToAddress, Task.vwTasks.InsertedBy, Task.vwTasks.InsertedOn, 
                         Task.vwTasks.UpdatedBy, Task.vwTasks.UpdatedOn, Task.vwTasks.AccountName, Task.vwTasks.ActionName, Task.vwTasks.Period, Task.vwTasks.Printed, Task.vwTasks.Spooled, Task.vwTasks.RowVer
FROM            Task.vwTasks LEFT OUTER JOIN
                         Org.tbAddress AS Org_tbAddress_1 ON Task.vwTasks.AddressCodeFrom = Org_tbAddress_1.AddressCode LEFT OUTER JOIN
                         Org.tbAddress ON Task.vwTasks.AddressCodeTo = Org.tbAddress.AddressCode INNER JOIN
                         Activity.tbActivity ON Task.vwTasks.ActivityCode = Activity.tbActivity.ActivityCode
WHERE        (Task.vwTasks.CashCode IS NOT NULL) AND (Task.vwTasks.CashModeCode = 0) AND (Task.vwTasks.TaskStatusCode > 0);
go

CREATE VIEW App.vwDocQuotation
AS
SELECT        TOP (100) PERCENT Task.vwTasks.TaskCode, Task.vwTasks.ActionOn, Task.vwTasks.ActivityCode, Task.vwTasks.ActionById, Task.vwTasks.BucketId, Task.vwTasks.TaskTitle, Task.vwTasks.AccountCode, 
                         Task.vwTasks.ContactName, Task.vwTasks.TaskNotes, Task.vwTasks.OwnerName, Task.vwTasks.CashCode, Task.vwTasks.CashDescription, Task.vwTasks.Quantity, Activity.tbActivity.UnitOfMeasure, 
                         Task.vwTasks.UnitCharge, Task.vwTasks.TotalCharge, Org_tbAddress_1.Address AS FromAddress, Org.tbAddress.Address AS ToAddress, Task.vwTasks.InsertedBy, Task.vwTasks.InsertedOn, 
                         Task.vwTasks.UpdatedBy, Task.vwTasks.UpdatedOn, Task.vwTasks.AccountName, Task.vwTasks.ActionName, Task.vwTasks.Period, Task.vwTasks.Printed, Task.vwTasks.Spooled, Task.vwTasks.RowVer
FROM            Task.vwTasks LEFT OUTER JOIN
                         Org.tbAddress AS Org_tbAddress_1 ON Task.vwTasks.AddressCodeFrom = Org_tbAddress_1.AddressCode LEFT OUTER JOIN
                         Org.tbAddress ON Task.vwTasks.AddressCodeTo = Org.tbAddress.AddressCode INNER JOIN
                         Activity.tbActivity ON Task.vwTasks.ActivityCode = Activity.tbActivity.ActivityCode
WHERE        (Task.vwTasks.CashCode IS NOT NULL) AND (Task.vwTasks.CashModeCode = 1) AND (Task.vwTasks.TaskStatusCode = 0);
go

CREATE VIEW App.vwDocSalesOrder
AS
SELECT        TOP (100) PERCENT Task.vwTasks.TaskCode, Task.vwTasks.ActionOn, Task.vwTasks.ActivityCode, Task.vwTasks.ActionById, Task.vwTasks.BucketId, Task.vwTasks.AccountCode, Task.vwTasks.TaskTitle, 
                         Task.vwTasks.ContactName, Task.vwTasks.TaskNotes, Task.vwTasks.OwnerName, Task.vwTasks.CashCode, Task.vwTasks.CashDescription, Task.vwTasks.Quantity, Activity.tbActivity.UnitOfMeasure, 
                         Task.vwTasks.UnitCharge, Task.vwTasks.TotalCharge, Org_tbAddress_1.Address AS FromAddress, Org.tbAddress.Address AS ToAddress, Task.vwTasks.InsertedBy, Task.vwTasks.InsertedOn, 
                         Task.vwTasks.UpdatedBy, Task.vwTasks.UpdatedOn, Task.vwTasks.AccountName, Task.vwTasks.ActionName, Task.vwTasks.Period, Task.vwTasks.Printed, Task.vwTasks.Spooled, Task.vwTasks.RowVer
FROM            Task.vwTasks LEFT OUTER JOIN
                         Org.tbAddress AS Org_tbAddress_1 ON Task.vwTasks.AddressCodeFrom = Org_tbAddress_1.AddressCode LEFT OUTER JOIN
                         Org.tbAddress ON Task.vwTasks.AddressCodeTo = Org.tbAddress.AddressCode INNER JOIN
                         Activity.tbActivity ON Task.vwTasks.ActivityCode = Activity.tbActivity.ActivityCode
WHERE        (Task.vwTasks.CashCode IS NOT NULL) AND (Task.vwTasks.CashModeCode = 1) AND (Task.vwTasks.TaskStatusCode > 0);
go

CREATE VIEW Cash.vwTaxVatDetails
AS
SELECT        App.tbYearPeriod.YearNumber, App.tbYear.Description, CONCAT(App.tbMonth.MonthName, SPACE(1), YEAR(App.tbYearPeriod.StartOn)) AS PeriodName, Cash.vwTaxVatSummary.StartOn, 
                         Cash.vwTaxVatSummary.TaxCode, Cash.vwTaxVatSummary.HomeSales, Cash.vwTaxVatSummary.HomePurchases, Cash.vwTaxVatSummary.ExportSales, Cash.vwTaxVatSummary.ExportPurchases, 
                         Cash.vwTaxVatSummary.HomeSalesVat, Cash.vwTaxVatSummary.HomePurchasesVat, Cash.vwTaxVatSummary.ExportSalesVat, Cash.vwTaxVatSummary.ExportPurchasesVat, Cash.vwTaxVatSummary.VatDue                         
FROM            Cash.vwTaxVatSummary INNER JOIN
                         App.tbYearPeriod INNER JOIN
                         App.tbMonth ON App.tbYearPeriod.MonthNumber = App.tbMonth.MonthNumber ON Cash.vwTaxVatSummary.StartOn = App.tbYearPeriod.StartOn INNER JOIN
                         App.tbYear ON App.tbYearPeriod.YearNumber = App.tbYear.YearNumber;
go

CREATE VIEW App.vwIdentity
AS
SELECT TOP (1) Org.tbOrg.AccountName, Org.tbAddress.Address, Org.tbOrg.PhoneNumber, Org.tbOrg.FaxNumber, Org.tbOrg.EmailAddress, Org.tbOrg.WebSite, Org.tbOrg.Logo, Usr.tbUser.UserName, Usr.tbUser.LogonName, 
                         Usr.tbUser.Avatar, Org.tbOrg.CompanyNumber, Org.tbOrg.VatNumber
FROM            Org.tbOrg INNER JOIN
                         Org.tbAddress ON Org.tbOrg.AddressCode = Org.tbAddress.AddressCode INNER JOIN
                         App.tbOptions ON Org.tbOrg.AccountCode = App.tbOptions.AccountCode CROSS JOIN
                         Usr.vwCredentials INNER JOIN
                         Usr.tbUser ON Usr.vwCredentials.UserId = Usr.tbUser.UserId;
go

CREATE VIEW Cash.vwFlowVatPeriodTotals
AS
	WITH active_periods AS
	(
		SELECT App.tbYear.YearNumber, App.tbYearPeriod.StartOn
		FROM            App.tbYearPeriod INNER JOIN
								 App.tbMonth ON App.tbYearPeriod.MonthNumber = App.tbMonth.MonthNumber INNER JOIN
								 App.tbYear ON App.tbYearPeriod.YearNumber = App.tbYear.YearNumber
		WHERE        (App.tbYear.CashStatusCode < 3)
	)
	SELECT     active_periods.YearNumber, active_periods.StartOn, ISNULL(SUM(vat.HomeSales), 0) AS HomeSales, ISNULL(SUM(vat.HomePurchases), 0) AS HomePurchases, ISNULL(SUM(vat.ExportSales), 0) AS ExportSales, ISNULL(SUM(vat.ExportPurchases), 0) AS ExportPurchases, 
							 ISNULL(SUM(vat.HomeSalesVat), 0) AS HomeSalesVat, ISNULL(SUM(vat.HomePurchasesVat), 0) AS HomePurchasesVat, ISNULL(SUM(vat.ExportSalesVat), 0) AS ExportSalesVat, ISNULL(SUM(vat.ExportPurchasesVat), 0) AS ExportPurchasesVat, 
							 ISNULL(SUM(vat.VatDue), 0) AS VatDue
	FROM            active_periods LEFT OUTER JOIN
							 Cash.vwTaxVatSummary AS vat ON active_periods.StartOn = vat.StartOn
	GROUP BY active_periods.YearNumber, active_periods.StartOn;
go

CREATE VIEW Cash.vwFlowVatRecurrence
AS
		WITH active_periods AS
	(
		SELECT App.tbYear.YearNumber, App.tbYearPeriod.StartOn
		FROM            App.tbYearPeriod INNER JOIN
								 App.tbMonth ON App.tbYearPeriod.MonthNumber = App.tbMonth.MonthNumber INNER JOIN
								 App.tbYear ON App.tbYearPeriod.YearNumber = App.tbYear.YearNumber
		WHERE        (App.tbYear.CashStatusCode < 3)
	)
	SELECT        active_periods.YearNumber, active_periods.StartOn, ISNULL(SUM(vat.HomeSales), 0) AS HomeSales, ISNULL(SUM(vat.HomePurchases), 0) AS HomePurchases, ISNULL(SUM(vat.ExportSales), 0) AS ExportSales, ISNULL(SUM(vat.ExportPurchases), 0) AS ExportPurchases, 
							 ISNULL(SUM(vat.HomeSalesVat), 0) AS HomeSalesVat, ISNULL(SUM(vat.HomePurchasesVat), 0) AS HomePurchasesVat, ISNULL(SUM(vat.ExportSalesVat), 0) AS ExportSalesVat, ISNULL(SUM(vat.ExportPurchasesVat), 0) AS ExportPurchasesVat, 
							 ISNULL(SUM(vat.VatAdjustment), 0) AS VatAdjustment, ISNULL(SUM(vat.VatDue), 0) AS VatDue
	FROM            active_periods LEFT OUTER JOIN
							 Cash.vwTaxVatTotals AS vat ON active_periods.StartOn = vat.StartOn
	GROUP BY active_periods.YearNumber, active_periods.StartOn;
go


CREATE VIEW Activity.vwCandidateCashCodes
AS
SELECT TOP 100 PERCENT Cash.tbCode.CashCode, Cash.tbCode.CashDescription, Cash.tbCategory.Category
FROM            Cash.tbCode INNER JOIN
                         Cash.tbCategory ON Cash.tbCode.CategoryCode = Cash.tbCategory.CategoryCode
WHERE        (Cash.tbCategory.CashTypeCode < 2)  AND (Cash.tbCategory.IsEnabled <> 0) AND (Cash.tbCode.IsEnabled <> 0)
ORDER BY Cash.tbCode.CashCode;
go

CREATE VIEW Activity.vwCodes
AS
SELECT        Activity.tbActivity.ActivityCode, Activity.tbActivity.UnitOfMeasure, Activity.tbActivity.CashCode
FROM            Activity.tbActivity LEFT OUTER JOIN
                         Cash.tbCode ON Activity.tbActivity.CashCode = Cash.tbCode.CashCode;
go

CREATE VIEW Activity.vwDefaultText
AS
SELECT TOP 100 PERCENT  DefaultText
FROM            Activity.tbAttribute
GROUP BY DefaultText
HAVING        (DefaultText IS NOT NULL)
ORDER BY DefaultText;
go

CREATE VIEW App.vwActivePeriod
AS
SELECT App.tbYearPeriod.YearNumber, App.tbYearPeriod.StartOn, App.tbYear.Description, App.tbMonth.MonthNumber, App.tbMonth.MonthName, fnActivePeriod.EndOn
FROM            App.tbYear INNER JOIN
                         App.fnActivePeriod() AS fnActivePeriod INNER JOIN
                         App.tbYearPeriod INNER JOIN
                         App.tbMonth ON App.tbYearPeriod.MonthNumber = App.tbMonth.MonthNumber ON fnActivePeriod.StartOn = App.tbYearPeriod.StartOn AND fnActivePeriod.YearNumber = App.tbYearPeriod.YearNumber ON 
                         App.tbYear.YearNumber = App.tbYearPeriod.YearNumber
go

CREATE VIEW App.vwActiveYears
   AS
SELECT     TOP 100 PERCENT App.tbYear.YearNumber, App.tbYear.Description, Cash.tbStatus.CashStatus
FROM         App.tbYear INNER JOIN
                      Cash.tbStatus ON App.tbYear.CashStatusCode = Cash.tbStatus.CashStatusCode
WHERE     (App.tbYear.CashStatusCode < 3)
ORDER BY App.tbYear.YearNumber
go

CREATE VIEW App.vwCandidateHomeAccounts
AS
SELECT        Org.tbOrg.AccountCode, Org.tbOrg.AccountName, Org.tbType.OrganisationType, Cash.tbMode.CashMode
FROM            Org.tbOrg INNER JOIN
                         Org.tbType ON Org.tbOrg.OrganisationTypeCode = Org.tbType.OrganisationTypeCode INNER JOIN
                         Cash.tbMode ON Org.tbType.CashModeCode = Cash.tbMode.CashModeCode
WHERE        (Org.tbOrg.OrganisationStatusCode < 3);
go

CREATE VIEW App.vwCandidateCategoryCodes
AS
	SELECT TOP 100 PERCENT CategoryCode, Category
	FROM            Cash.tbCategory
	WHERE        (CategoryTypeCode = 1)
	ORDER BY CategoryCode;
go

CREATE VIEW App.vwDocCreditNote
AS
SELECT        TOP (100) PERCENT Invoice.tbInvoice.InvoiceNumber, Invoice.tbInvoice.Printed, Invoice.tbInvoice.Spooled, Invoice.tbInvoice.InvoiceStatusCode, Usr.tbUser.UserName, Invoice.tbInvoice.AccountCode, 
                         Org.tbOrg.AccountName, Invoice.tbStatus.InvoiceStatus, Invoice.tbInvoice.InvoicedOn, Invoice.tbInvoice.InvoiceValue, Invoice.tbInvoice.TaxValue, Invoice.tbInvoice.PaymentTerms, Invoice.tbInvoice.Notes, 
                         Org.tbOrg.EmailAddress, Invoice.tbInvoice.RowVer
FROM            Invoice.tbInvoice INNER JOIN
                         Invoice.tbStatus ON Invoice.tbInvoice.InvoiceStatusCode = Invoice.tbStatus.InvoiceStatusCode INNER JOIN
                         Org.tbOrg ON Invoice.tbInvoice.AccountCode = Org.tbOrg.AccountCode INNER JOIN
                         Usr.tbUser ON Invoice.tbInvoice.UserId = Usr.tbUser.UserId
WHERE        (Invoice.tbInvoice.InvoiceTypeCode = 1);
go

CREATE VIEW App.vwDocDebitNote
AS
SELECT        TOP (100) PERCENT Invoice.tbInvoice.InvoiceNumber, Invoice.tbInvoice.Printed, Invoice.tbInvoice.Spooled, Invoice.tbInvoice.InvoiceStatusCode, Usr.tbUser.UserName, Invoice.tbInvoice.AccountCode, 
                         Org.tbOrg.AccountName, Invoice.tbStatus.InvoiceStatus, Invoice.tbInvoice.InvoicedOn, Invoice.tbInvoice.InvoiceValue, Invoice.tbInvoice.TaxValue, Invoice.tbInvoice.PaymentTerms, Invoice.tbInvoice.Notes, 
                         Org.tbOrg.EmailAddress, Invoice.tbInvoice.RowVer
FROM            Invoice.tbInvoice INNER JOIN
                         Invoice.tbStatus ON Invoice.tbInvoice.InvoiceStatusCode = Invoice.tbStatus.InvoiceStatusCode INNER JOIN
                         Org.tbOrg ON Invoice.tbInvoice.AccountCode = Org.tbOrg.AccountCode INNER JOIN
                         Usr.tbUser ON Invoice.tbInvoice.UserId = Usr.tbUser.UserId
WHERE        (Invoice.tbInvoice.InvoiceTypeCode = 3);
go


CREATE VIEW App.vwDocOpenModes
AS
SELECT TOP 100 PERCENT OpenMode, OpenModeDescription
FROM            Usr.tbMenuOpenMode
WHERE        (OpenMode > 1)
ORDER BY OpenMode;
go

CREATE VIEW App.vwDocSalesInvoice
AS
SELECT        TOP (100) PERCENT Invoice.tbInvoice.InvoiceNumber, Invoice.tbInvoice.Printed, Invoice.tbInvoice.Spooled, Invoice.tbInvoice.InvoiceStatusCode, Usr.tbUser.UserName, Invoice.tbInvoice.AccountCode, 
                         Org.tbOrg.AccountName, Invoice.tbStatus.InvoiceStatus, Invoice.tbInvoice.InvoicedOn, Invoice.tbInvoice.InvoiceValue, Invoice.tbInvoice.TaxValue, Invoice.tbInvoice.PaymentTerms, Invoice.tbInvoice.Notes, 
                         Org.tbOrg.EmailAddress, Invoice.tbInvoice.RowVer
FROM            Invoice.tbInvoice INNER JOIN
                         Invoice.tbStatus ON Invoice.tbInvoice.InvoiceStatusCode = Invoice.tbStatus.InvoiceStatusCode INNER JOIN
                         Org.tbOrg ON Invoice.tbInvoice.AccountCode = Org.tbOrg.AccountCode INNER JOIN
                         Usr.tbUser ON Invoice.tbInvoice.UserId = Usr.tbUser.UserId
WHERE        (Invoice.tbInvoice.InvoiceTypeCode = 0);
go

CREATE VIEW App.vwDocSpool
 AS
SELECT     DocTypeCode, DocumentNumber
FROM         App.tbDocSpool
WHERE     (UserName = SUSER_SNAME())
go

CREATE VIEW App.vwEventLog
AS
	SELECT        App.tbEventLog.LogCode, App.tbEventLog.LoggedOn, App.tbEventLog.EventTypeCode, App.tbEventType.EventType, App.tbEventLog.EventMessage, App.tbEventLog.InsertedBy, App.tbEventLog.RowVer
	FROM            App.tbEventLog INNER JOIN
							 App.tbEventType ON App.tbEventLog.EventTypeCode = App.tbEventType.EventTypeCode
go

CREATE VIEW App.vwGraphTaskActivity
AS
SELECT        CONCAT(Task.tbStatus.TaskStatus, SPACE(1), Cash.tbMode.CashMode) AS Category, SUM(Task.tbTask.TotalCharge) AS SumOfTotalCharge
FROM            Task.tbTask INNER JOIN
                         Task.tbStatus ON Task.tbTask.TaskStatusCode = Task.tbStatus.TaskStatusCode INNER JOIN
                         Cash.tbCode ON Task.tbTask.CashCode = Cash.tbCode.CashCode INNER JOIN
                         Cash.tbCategory ON Cash.tbCode.CategoryCode = Cash.tbCategory.CategoryCode INNER JOIN
                         Cash.tbMode ON Cash.tbCategory.CashModeCode = Cash.tbMode.CashModeCode
WHERE        (Task.tbTask.TaskStatusCode < 3) AND (Task.tbTask.TaskStatusCode > 0)
GROUP BY CONCAT(Task.tbStatus.TaskStatus, SPACE(1), Cash.tbMode.CashMode);
go

CREATE VIEW App.vwMonths
AS
	SELECT DISTINCT CAST(App.tbYearPeriod.StartOn AS float) AS StartOn, App.tbMonth.MonthName, App.tbYearPeriod.MonthNumber
	FROM         App.tbYearPeriod INNER JOIN
						  App.fnActivePeriod() AS fnSystemActivePeriod ON App.tbYearPeriod.YearNumber = fnSystemActivePeriod.YearNumber INNER JOIN
						  App.tbMonth ON App.tbYearPeriod.MonthNumber = App.tbMonth.MonthNumber
go

CREATE VIEW App.vwPeriodEndListing
AS
SELECT        TOP (100) PERCENT App.tbYear.YearNumber, App.tbYear.Description, App.tbYear.InsertedBy AS YearInsertedBy, App.tbYear.InsertedOn AS YearInsertedOn, App.tbYearPeriod.StartOn, App.tbMonth.MonthName, 
                         App.tbYearPeriod.InsertedBy AS PeriodInsertedBy, App.tbYearPeriod.InsertedOn AS PeriodInsertedOn, Cash.tbStatus.CashStatus
FROM            Cash.tbStatus INNER JOIN
                         App.tbYear INNER JOIN
                         App.tbYearPeriod ON App.tbYear.YearNumber = App.tbYearPeriod.YearNumber INNER JOIN
                         App.tbMonth ON App.tbYearPeriod.MonthNumber = App.tbMonth.MonthNumber ON Cash.tbStatus.CashStatusCode = App.tbYearPeriod.CashStatusCode
ORDER BY App.tbYearPeriod.StartOn;
go


CREATE VIEW App.vwTaxCodes
AS
SELECT        App.tbTaxCode.TaxCode, App.tbTaxCode.TaxDescription, Cash.tbTaxType.TaxType
FROM            App.tbTaxCode INNER JOIN
                         Cash.tbTaxType ON App.tbTaxCode.TaxTypeCode = Cash.tbTaxType.TaxTypeCode;
go

CREATE VIEW App.vwTaxCodeTypes
AS
SELECT        TaxTypeCode, TaxType
FROM            Cash.tbTaxType
WHERE        (TaxTypeCode > 0);
go

CREATE VIEW App.vwWarehouseOrg
AS
SELECT TOP (100) PERCENT Org.tbOrg.AccountCode, Org.tbDoc.DocumentName, Org.tbOrg.AccountName, Org.tbDoc.DocumentImage, Org.tbDoc.DocumentDescription, Org.tbDoc.InsertedBy, Org.tbDoc.InsertedOn, Org.tbDoc.UpdatedBy, 
                         Org.tbDoc.UpdatedOn, Org.tbDoc.RowVer
FROM            Org.tbOrg INNER JOIN
                         Org.tbDoc ON Org.tbOrg.AccountCode = Org.tbDoc.AccountCode
ORDER BY Org.tbDoc.AccountCode, Org.tbDoc.DocumentName;
go

CREATE VIEW App.vwWarehouseTask
AS
SELECT TOP (100) PERCENT Task.tbDoc.TaskCode, Task.tbDoc.DocumentName, Org.tbOrg.AccountName, Task.tbTask.TaskTitle, Task.tbDoc.DocumentImage, Task.tbDoc.DocumentDescription, Task.tbDoc.InsertedBy, Task.tbDoc.InsertedOn, 
                         Task.tbDoc.UpdatedBy, Task.tbDoc.UpdatedOn, Task.tbDoc.RowVer
FROM            Org.tbOrg INNER JOIN
                         Task.tbTask ON Org.tbOrg.AccountCode = Task.tbTask.AccountCode INNER JOIN
                         Task.tbDoc ON Task.tbTask.TaskCode = Task.tbDoc.TaskCode
ORDER BY Task.tbDoc.TaskCode, Task.tbDoc.DocumentName;
go

CREATE VIEW App.vwYearPeriod
AS
SELECT TOP (100) PERCENT App.tbYear.Description, App.tbMonth.MonthName, App.tbYearPeriod.CashStatusCode, App.tbYearPeriod.YearNumber, App.tbYearPeriod.StartOn, App.tbYearPeriod.RowVer
FROM            App.tbYearPeriod INNER JOIN
                         App.tbMonth ON App.tbYearPeriod.MonthNumber = App.tbMonth.MonthNumber INNER JOIN
                         App.tbYear ON App.tbYearPeriod.YearNumber = App.tbYear.YearNumber
ORDER BY App.tbYearPeriod.YearNumber, App.tbYearPeriod.StartOn;
go

CREATE VIEW Cash.vwAccountRebuild
  AS
SELECT     Org.tbPayment.CashAccountCode, Org.tbAccount.OpeningBalance, 
                      Org.tbAccount.OpeningBalance + SUM(Org.tbPayment.PaidInValue - Org.tbPayment.PaidOutValue) AS CurrentBalance
FROM         Org.tbPayment INNER JOIN
                      Org.tbAccount ON Org.tbPayment.CashAccountCode = Org.tbAccount.CashAccountCode
WHERE     (Org.tbPayment.PaymentStatusCode = 1) 
GROUP BY Org.tbPayment.CashAccountCode, Org.tbAccount.OpeningBalance
go

CREATE VIEW Cash.vwBudget
AS
SELECT TOP 100 PERCENT Cash.tbCode.CategoryCode, Cash.tbPeriod.CashCode, Cash.tbCode.CashDescription, 
	Cash.tbPeriod.StartOn, App.tbYearPeriod.YearNumber, App.tbMonth.MonthName, Format(App.tbYearPeriod.StartOn, 'yy-MM') AS Period,  
	Cash.tbPeriod.ForecastValue, Cash.tbPeriod.ForecastTax, Cash.tbPeriod.InvoiceValue, Cash.tbPeriod.InvoiceTax, Cash.tbPeriod.Note, Cash.tbMode.CashMode, App.tbTaxCode.TaxRate
FROM            App.tbYearPeriod INNER JOIN
                         Cash.tbPeriod ON App.tbYearPeriod.StartOn = Cash.tbPeriod.StartOn INNER JOIN
                         App.tbMonth ON App.tbYearPeriod.MonthNumber = App.tbMonth.MonthNumber INNER JOIN
                         Cash.tbCode ON Cash.tbPeriod.CashCode = Cash.tbCode.CashCode INNER JOIN
                         Cash.tbCategory ON Cash.tbCode.CategoryCode = Cash.tbCategory.CategoryCode INNER JOIN
						 Cash.tbMode ON Cash.tbCategory.CashModeCode = Cash.tbMode.CashModeCode INNER JOIN
                         App.tbTaxCode ON Cash.tbCode.TaxCode = App.tbTaxCode.TaxCode

go

CREATE VIEW Cash.vwBudgetDataEntry
AS
SELECT        TOP (100) PERCENT App.tbYearPeriod.YearNumber, Cash.tbPeriod.CashCode, Cash.tbPeriod.StartOn, App.tbMonth.MonthName, Cash.tbPeriod.ForecastValue, Cash.tbPeriod.ForecastTax, Cash.tbPeriod.Note, 
                         Cash.tbPeriod.RowVer
FROM            App.tbYearPeriod INNER JOIN
                         Cash.tbPeriod ON App.tbYearPeriod.StartOn = Cash.tbPeriod.StartOn INNER JOIN
                         App.tbMonth ON App.tbYearPeriod.MonthNumber = App.tbMonth.MonthNumber
go

CREATE VIEW Cash.vwCashFlowTypes
AS
SELECT        CashTypeCode, CashType
FROM            Cash.tbType
WHERE        (CashTypeCode < 2)
go

CREATE VIEW Cash.vwCategoryBudget
AS
	SELECT CategoryCode, Category, CategoryTypeCode, CashModeCode, CashTypeCode, DisplayOrder, IsEnabled, InsertedBy, InsertedOn, UpdatedBy, UpdatedOn, RowVer
	FROM            Cash.tbCategory
	WHERE        (CategoryTypeCode = 0) AND (CashTypeCode = 0) AND (IsEnabled <> 0)
go

CREATE VIEW Cash.vwCategoryCodesExpressions
AS
SELECT        CategoryCode, Category, DisplayOrder, CategoryTypeCode, CashModeCode, CashTypeCode
FROM            Cash.tbCategory
WHERE        (CategoryTypeCode = 2);
go


CREATE VIEW Cash.vwCategoryCodesTotals
AS
SELECT        CategoryCode, Category, DisplayOrder, CategoryTypeCode, CashModeCode, CashTypeCode
FROM            Cash.tbCategory
WHERE        (CategoryTypeCode = 1);
go

CREATE VIEW Cash.vwCategoryCodesTrade
AS
SELECT        CategoryCode, Category, DisplayOrder, CategoryTypeCode, CashModeCode, CashTypeCode
FROM            Cash.tbCategory
WHERE        (CategoryTypeCode = 0);
go

CREATE VIEW Cash.vwCategoryExpressions
AS
	SELECT     TOP 100 PERCENT Cash.tbCategory.DisplayOrder, Cash.tbCategory.CategoryCode, Cash.tbCategory.Category, Cash.tbCategoryExp.Expression, 
						  Cash.tbCategoryExp.Format
	FROM         Cash.tbCategory INNER JOIN
						  Cash.tbCategoryExp ON Cash.tbCategory.CategoryCode = Cash.tbCategoryExp.CategoryCode
	WHERE     (Cash.tbCategory.CategoryTypeCode = 2)
go

CREATE VIEW Cash.vwCategoryTotalCandidates
AS
SELECT        Cash.tbCategory.CategoryCode, Cash.tbCategory.Category, Cash.tbCategoryType.CategoryType, Cash.tbType.CashType, Cash.tbMode.CashMode
FROM            Cash.tbCategory INNER JOIN
                         Cash.tbCategoryType ON Cash.tbCategory.CategoryTypeCode = Cash.tbCategoryType.CategoryTypeCode INNER JOIN
                         Cash.tbType ON Cash.tbCategory.CashTypeCode = Cash.tbType.CashTypeCode INNER JOIN
                         Cash.tbMode ON Cash.tbCategory.CashModeCode = Cash.tbMode.CashModeCode
WHERE        (Cash.tbCategory.CashTypeCode < 2) AND (Cash.tbCategory.IsEnabled <> 0);
go

CREATE VIEW Cash.vwCategoryTotals
AS
	SELECT CategoryCode, Category, CategoryTypeCode, CashModeCode, CashTypeCode, DisplayOrder, IsEnabled, InsertedBy, InsertedOn, UpdatedBy, UpdatedOn, RowVer
	FROM            Cash.tbCategory
	WHERE       (CategoryTypeCode = 1)
go

CREATE VIEW Cash.vwCategoryTrade
AS
SELECT        CategoryCode, Category, CategoryTypeCode, CashModeCode, CashTypeCode, DisplayOrder, IsEnabled, InsertedBy, InsertedOn, UpdatedBy, UpdatedOn, RowVer
FROM            Cash.tbCategory
WHERE        (CategoryTypeCode = 0) AND (CashTypeCode = 0)
go

CREATE VIEW Cash.vwCodeLookup
AS
SELECT        Cash.tbCode.CashCode, Cash.tbCode.CashDescription, Cash.tbCategory.Category, Cash.tbMode.CashMode, Cash.tbCode.TaxCode
FROM            Cash.tbCode INNER JOIN
                         Cash.tbCategory ON Cash.tbCode.CategoryCode = Cash.tbCategory.CategoryCode INNER JOIN
                         Cash.tbMode ON Cash.tbCategory.CashModeCode = Cash.tbMode.CashModeCode
WHERE (Cash.tbCode.IsEnabled <> 0) AND (Cash.tbCategory.IsEnabled <> 0);
go

CREATE VIEW Cash.vwExternalCodesLookup
AS
SELECT        Cash.tbCode.CashCode, Cash.tbCode.CashDescription, Cash.tbCategory.Category
FROM            Cash.tbCode INNER JOIN
                         Cash.tbCategory ON Cash.tbCode.CategoryCode = Cash.tbCategory.CategoryCode
WHERE        (Cash.tbCategory.CashTypeCode = 1);
go

CREATE VIEW Cash.vwFlowTaxType
AS
	SELECT       Cash.tbTaxType.TaxTypeCode, Cash.tbTaxType.TaxType, Cash.tbTaxType.RecurrenceCode, App.tbRecurrence.Recurrence, Cash.tbTaxType.CashCode, Cash.tbCode.CashDescription, Cash.tbTaxType.MonthNumber, App.tbMonth.MonthName, Cash.tbTaxType.AccountCode, 
								Cash.tbTaxType.OffsetDays
	FROM            Cash.tbTaxType INNER JOIN
								App.tbRecurrence ON Cash.tbTaxType.RecurrenceCode = App.tbRecurrence.RecurrenceCode INNER JOIN
								Cash.tbCode ON Cash.tbTaxType.CashCode = Cash.tbCode.CashCode INNER JOIN
								App.tbMonth ON Cash.tbTaxType.MonthNumber = App.tbMonth.MonthNumber
go

CREATE VIEW Cash.vwPeriods
   AS
SELECT     Cash.tbCode.CashCode, App.tbYearPeriod.StartOn
FROM         App.tbYearPeriod CROSS JOIN
                      Cash.tbCode
go

CREATE VIEW Cash.vwStatementReserves
AS
	WITH reserve_account AS
	(
		SELECT  Org.tbAccount.CashAccountCode, Org.tbAccount.CashAccountName, Org.tbAccount.CurrentBalance
		FROM            Org.tbAccount LEFT OUTER JOIN
								 Cash.tbCode ON Org.tbAccount.CashCode = Cash.tbCode.CashCode 
		WHERE        (Org.tbAccount.AccountCode <> (SELECT AccountCode FROM App.tbOptions))
			AND (Cash.tbCode.CashCode IS NULL) AND (Org.tbAccount.DummyAccount = 0)
	), last_payment AS
	(
		SELECT MAX( payments.PaidOn) AS TransactOn
		FROM reserve_account JOIN Org.tbPayment payments 
						ON reserve_account.CashAccountCode = payments.CashAccountCode 
		WHERE payments.PaymentStatusCode = 1
	
	), opening_balance AS
	(
		SELECT 	
			(SELECT AccountCode FROM App.tbOptions) AS AccountCode,		
			(SELECT TransactOn FROM last_payment) AS TransactOn,
			0 AS CashEntryTypeCode,
			(SELECT CAST(Message AS NVARCHAR) FROM App.tbText WHERE TextId = 1219) AS ReferenceCode,
			CASE WHEN SUM(CurrentBalance) > 0 THEN SUM(CurrentBalance) ELSE 0 END AS PayIn, 
			CASE WHEN SUM(CurrentBalance) < 0 THEN SUM(CurrentBalance) ELSE 0 END  AS PayOut
		FROM reserve_account 

	), unbalanced_reserves AS
	(
		SELECT  0 AS RowNumber, org.AccountCode, org.AccountName, TransactOn, CashEntryTypeCode, ReferenceCode, 
					PayOut, PayIn, NULL AS CashCode, NULL AS CashDescription
		FROM opening_balance
			JOIN Org.tbOrg org ON opening_balance.AccountCode = org.AccountCode

		UNION
	
		SELECT ROW_NUMBER() OVER (ORDER BY payments.PaidOn) AS RowNumber, reserve_account.CashAccountCode AS AccountCode,
			reserve_account.CashAccountName AS AccountName,
			payments.PaidOn AS TransactOn, 6 AS CashEntryTypeCode, payments.PaymentCode AS ReferenceCode,  
			payments.PaidOutValue, payments.PaidInValue, payments.CashCode, cash_code.CashDescription 
		FROM reserve_account 
			JOIN Org.tbPayment payments ON reserve_account.CashAccountCode = payments.CashAccountCode
			JOIN Cash.tbCode cash_code ON payments.CashCode = cash_code.CashCode
		WHERE payments.PaymentStatusCode = 2
	)
	SELECT RowNumber, TransactOn, entry_type.CashEntryTypeCode, entry_type.CashEntryType, ReferenceCode, unbalanced_reserves.AccountCode, unbalanced_reserves.AccountName,
		PayOut, PayIn,
		SUM(PayIn + (PayOut * -1)) OVER (ORDER BY RowNumber) AS Balance,
		CashCode, CashDescription
	FROM unbalanced_reserves 
		JOIN Cash.tbEntryType entry_type ON unbalanced_reserves.CashEntryTypeCode = entry_type.CashEntryTypeCode
go

CREATE VIEW Cash.vwTaxVatAuditInvoices
AS
	WITH vat_transactions AS
	(
		SELECT   Invoice.tbInvoice.InvoicedOn, Invoice.tbInvoice.InvoiceNumber, Invoice.tbInvoice.InvoiceTypeCode, Invoice.tbItem.TaxCode, Invoice.tbItem.InvoiceValue, Invoice.tbItem.TaxValue,
								  ROUND((Invoice.tbItem.TaxValue /  Invoice.tbItem.InvoiceValue), 3) As CalcRate,
								 App.tbTaxCode.TaxRate, Org.tbOrg.EUJurisdiction, Invoice.tbItem.CashCode AS IdentityCode, Cash.tbCode.CashDescription As ItemDescription
		FROM            Invoice.tbItem INNER JOIN
								 Invoice.tbInvoice ON Invoice.tbItem.InvoiceNumber = Invoice.tbInvoice.InvoiceNumber INNER JOIN
								 Org.tbOrg ON Invoice.tbInvoice.AccountCode = Org.tbOrg.AccountCode INNER JOIN
								 App.tbTaxCode ON Invoice.tbItem.TaxCode = App.tbTaxCode.TaxCode INNER JOIN
								 Cash.tbCode ON Invoice.tbItem.CashCode = Cash.tbCode.CashCode
		WHERE        (App.tbTaxCode.TaxTypeCode = 1) AND (Invoice.tbItem.InvoiceValue <> 0)
		UNION
		SELECT   Invoice.tbInvoice.InvoicedOn, Invoice.tbTask.InvoiceNumber, Invoice.tbInvoice.InvoiceTypeCode, Invoice.tbTask.TaxCode, Invoice.tbTask.InvoiceValue, Invoice.tbTask.TaxValue, 
								 ROUND(Invoice.tbTask.TaxValue / Invoice.tbTask.InvoiceValue, 3) AS CalcRate, App.tbTaxCode.TaxRate, Org.tbOrg.EUJurisdiction, Invoice.tbTask.TaskCode AS IdentityCode, tbTask_1.TaskTitle As ItemDescription
		FROM            Invoice.tbTask INNER JOIN
								 Invoice.tbInvoice ON Invoice.tbTask.InvoiceNumber = Invoice.tbInvoice.InvoiceNumber INNER JOIN
								 Org.tbOrg ON Invoice.tbInvoice.AccountCode = Org.tbOrg.AccountCode INNER JOIN
								 App.tbTaxCode ON Invoice.tbTask.TaxCode = App.tbTaxCode.TaxCode INNER JOIN
								 Task.tbTask AS tbTask_1 ON Invoice.tbTask.TaskCode = tbTask_1.TaskCode
		WHERE        (App.tbTaxCode.TaxTypeCode = 1) AND (Invoice.tbTask.InvoiceValue <> 0)
	)
	, vat_dataset AS
	(
		SELECT  (SELECT PayTo FROM Cash.fnTaxTypeDueDates(1) due_dates WHERE vat_transactions.InvoicedOn >= PayFrom AND vat_transactions.InvoicedOn < PayTo) AS StartOn,
		 vat_transactions.InvoicedOn, InvoiceNumber, invoice_type.InvoiceType, vat_transactions.InvoiceTypeCode, TaxCode, InvoiceValue, TaxValue, TaxRate, EUJurisdiction, IdentityCode, ItemDescription,
				CASE WHEN EUJurisdiction = 0 THEN CASE vat_transactions.InvoiceTypeCode WHEN 0 THEN InvoiceValue WHEN 1 THEN
				InvoiceValue * - 1 ELSE 0 END ELSE 0 END AS HomeSales, 
				CASE WHEN EUJurisdiction = 0 THEN CASE vat_transactions.InvoiceTypeCode WHEN 2 THEN InvoiceValue WHEN 3 THEN
				InvoiceValue * - 1 ELSE 0 END ELSE 0 END AS HomePurchases, 
				CASE WHEN EUJurisdiction != 0 THEN CASE vat_transactions.InvoiceTypeCode WHEN 0 THEN InvoiceValue WHEN 1 THEN
				InvoiceValue * - 1 ELSE 0 END ELSE 0 END AS ExportSales, 
				CASE WHEN EUJurisdiction != 0 THEN CASE vat_transactions.InvoiceTypeCode WHEN 2 THEN InvoiceValue WHEN 3 THEN
				InvoiceValue * - 1 ELSE 0 END ELSE 0 END AS ExportPurchases, 
				CASE WHEN EUJurisdiction = 0 THEN CASE vat_transactions.InvoiceTypeCode WHEN 0 THEN TaxValue WHEN 1 THEN TaxValue
				* - 1 ELSE 0 END ELSE 0 END AS HomeSalesVat, 
				CASE WHEN EUJurisdiction = 0 THEN CASE vat_transactions.InvoiceTypeCode WHEN 2 THEN TaxValue WHEN 3 THEN TaxValue
				* - 1 ELSE 0 END ELSE 0 END AS HomePurchasesVat, 
				CASE WHEN EUJurisdiction != 0 THEN CASE vat_transactions.InvoiceTypeCode WHEN 0 THEN TaxValue WHEN 1 THEN TaxValue
				* - 1 ELSE 0 END ELSE 0 END AS ExportSalesVat, 
				CASE WHEN EUJurisdiction != 0 THEN CASE vat_transactions.InvoiceTypeCode WHEN 2 THEN TaxValue WHEN 3 THEN TaxValue
				* - 1 ELSE 0 END ELSE 0 END AS ExportPurchasesVat
		FROM  vat_transactions 
			JOIN Invoice.tbType invoice_type ON vat_transactions.InvoiceTypeCode = invoice_type.InvoiceTypeCode
	)
	SELECT CONCAT(App.tbYear.Description, ' ', App.tbMonth.MonthName) AS YearPeriod, vat_dataset.*,
		 (HomeSalesVat + ExportSalesVat) - (HomePurchasesVat + ExportPurchasesVat) AS VatDue
	FROM vat_dataset
		JOIN App.tbYearPeriod AS year_period ON vat_dataset.StartOn = year_period.StartOn INNER JOIN
                         App.tbYear ON year_period.YearNumber = App.tbYear.YearNumber INNER JOIN
                         App.tbMonth ON year_period.MonthNumber = App.tbMonth.MonthNumber;
go

CREATE VIEW Cash.vwTransferCodeLookup
AS
SELECT        Cash.tbCode.CashCode, Cash.tbCode.CashDescription, Cash.tbCategory.Category, Cash.tbMode.CashMode
FROM            Cash.tbCode INNER JOIN
                         Cash.tbCategory ON Cash.tbCode.CategoryCode = Cash.tbCategory.CategoryCode INNER JOIN
                         Cash.tbMode ON Cash.tbCategory.CashModeCode = Cash.tbMode.CashModeCode
WHERE (Cash.tbCode.IsEnabled <> 0) AND (Cash.tbCategory.IsEnabled <> 0) AND (Cash.tbCategory.CashTypeCode = 2);
go

CREATE VIEW Cash.vwTransfersUnposted
AS
	SELECT        PaymentCode, UserId, PaymentStatusCode, AccountCode, CashAccountCode, CashCode, TaxCode, PaidOn, PaidInValue, PaidOutValue, TaxInValue, TaxOutValue, PaymentReference, InsertedBy, InsertedOn, 
							 UpdatedBy, UpdatedOn, RowVer
	FROM            Org.tbPayment
	WHERE        (PaymentStatusCode = 2)
go

CREATE VIEW Cash.vwVATCodes
AS
SELECT        TaxCode, TaxDescription
FROM            App.tbTaxCode
WHERE        (TaxTypeCode = 1);
go

CREATE VIEW Invoice.vwAgedDebtPurchases
AS
SELECT TOP 100 PERCENT Invoice.tbInvoice.InvoiceNumber, Invoice.tbInvoice.AccountCode, Org.tbOrg.AccountName, Invoice.tbInvoice.InvoiceTypeCode, Invoice.tbInvoice.InvoiceStatusCode, Invoice.tbStatus.InvoiceStatus, 
                         Invoice.tbType.InvoiceType, (Invoice.tbInvoice.InvoiceValue + Invoice.tbInvoice.TaxValue) - (Invoice.tbInvoice.PaidValue + Invoice.tbInvoice.PaidTaxValue) AS UnpaidValue, DATEDIFF(DD, CURRENT_TIMESTAMP, 
                         Invoice.tbInvoice.InvoicedOn) AS UnpaidDays, Invoice.tbInvoice.InvoicedOn, Invoice.tbInvoice.DueOn, Invoice.tbInvoice.ExpectedOn, Invoice.tbInvoice.InvoiceValue, Invoice.tbInvoice.TaxValue, Invoice.tbInvoice.PaymentTerms, 
                         Invoice.tbInvoice.Notes
FROM            Invoice.tbInvoice INNER JOIN
                         Invoice.tbStatus ON Invoice.tbInvoice.InvoiceStatusCode = Invoice.tbStatus.InvoiceStatusCode INNER JOIN
                         Invoice.tbType ON Invoice.tbInvoice.InvoiceTypeCode = Invoice.tbType.InvoiceTypeCode INNER JOIN
                         Org.tbOrg ON Invoice.tbInvoice.AccountCode = Org.tbOrg.AccountCode
WHERE        (Invoice.tbInvoice.InvoiceTypeCode > 1) AND (Invoice.tbInvoice.InvoiceStatusCode < 3)
ORDER BY Invoice.tbInvoice.ExpectedOn;
go

CREATE VIEW Invoice.vwAgedDebtSales
AS
SELECT TOP 100 PERCENT  Invoice.tbInvoice.InvoiceNumber, Invoice.tbInvoice.AccountCode, Org.tbOrg.AccountName, Invoice.tbInvoice.InvoiceTypeCode, Invoice.tbInvoice.InvoiceStatusCode, Invoice.tbStatus.InvoiceStatus, 
                         Invoice.tbType.InvoiceType, (Invoice.tbInvoice.InvoiceValue + Invoice.tbInvoice.TaxValue) - (Invoice.tbInvoice.PaidValue + Invoice.tbInvoice.PaidTaxValue) AS UnpaidValue, DATEDIFF(DD, CURRENT_TIMESTAMP, 
                         Invoice.tbInvoice.InvoicedOn) AS UnpaidDays, Invoice.tbInvoice.InvoicedOn, Invoice.tbInvoice.DueOn, Invoice.tbInvoice.ExpectedOn, Invoice.tbInvoice.InvoiceValue, Invoice.tbInvoice.TaxValue, Invoice.tbInvoice.PaymentTerms, 
                         Invoice.tbInvoice.Notes
FROM            Invoice.tbInvoice INNER JOIN
                         Invoice.tbStatus ON Invoice.tbInvoice.InvoiceStatusCode = Invoice.tbStatus.InvoiceStatusCode INNER JOIN
                         Invoice.tbType ON Invoice.tbInvoice.InvoiceTypeCode = Invoice.tbType.InvoiceTypeCode INNER JOIN
                         Org.tbOrg ON Invoice.tbInvoice.AccountCode = Org.tbOrg.AccountCode
WHERE        (Invoice.tbInvoice.InvoiceTypeCode < 2) AND (Invoice.tbInvoice.InvoiceStatusCode < 3)
ORDER BY Invoice.tbInvoice.ExpectedOn;
go

CREATE VIEW Invoice.vwCandidateCredits
AS
SELECT TOP 100 PERCENT Invoice.tbInvoice.InvoiceNumber, Invoice.tbInvoice.UserId, Invoice.tbInvoice.AccountCode, Invoice.tbInvoice.InvoiceTypeCode, Invoice.tbInvoice.InvoiceStatusCode, Invoice.tbInvoice.InvoicedOn, 
                         Invoice.tbInvoice.InvoiceValue, Invoice.tbInvoice.TaxValue, Invoice.tbInvoice.PaidValue, Invoice.tbInvoice.PaidTaxValue, Invoice.tbInvoice.PaymentTerms, Invoice.tbInvoice.Notes, Invoice.tbInvoice.Printed, 
                         Invoice.tbInvoice.DueOn, Invoice.tbInvoice.Spooled, Usr.tbUser.UserName, Invoice.tbStatus.InvoiceStatus, Invoice.tbType.InvoiceType
FROM            Invoice.tbInvoice INNER JOIN
                         Invoice.tbStatus ON Invoice.tbInvoice.InvoiceStatusCode = Invoice.tbStatus.InvoiceStatusCode INNER JOIN
                         Invoice.tbType ON Invoice.tbInvoice.InvoiceTypeCode = Invoice.tbType.InvoiceTypeCode INNER JOIN
                         Usr.tbUser ON Invoice.tbInvoice.UserId = Usr.tbUser.UserId
WHERE        (Invoice.tbInvoice.InvoiceTypeCode = 0)
ORDER BY Invoice.tbInvoice.AccountCode, Invoice.tbInvoice.InvoicedOn DESC
go

CREATE VIEW Invoice.vwCandidateDebits
AS
SELECT TOP 100 PERCENT Invoice.tbInvoice.InvoiceNumber, Invoice.tbInvoice.UserId, Invoice.tbInvoice.AccountCode, Invoice.tbInvoice.InvoiceTypeCode, Invoice.tbInvoice.InvoiceStatusCode, Invoice.tbInvoice.InvoicedOn, 
                         Invoice.tbInvoice.InvoiceValue, Invoice.tbInvoice.TaxValue, Invoice.tbInvoice.PaidValue, Invoice.tbInvoice.PaidTaxValue, Invoice.tbInvoice.PaymentTerms, Invoice.tbInvoice.Notes, Invoice.tbInvoice.Printed, 
                         Invoice.tbInvoice.DueOn, Invoice.tbInvoice.Spooled, Usr.tbUser.UserName, Invoice.tbStatus.InvoiceStatus, Invoice.tbType.InvoiceType
FROM            Invoice.tbInvoice INNER JOIN
                         Invoice.tbStatus ON Invoice.tbInvoice.InvoiceStatusCode = Invoice.tbStatus.InvoiceStatusCode INNER JOIN
                         Invoice.tbType ON Invoice.tbInvoice.InvoiceTypeCode = Invoice.tbType.InvoiceTypeCode INNER JOIN
                         Usr.tbUser ON Invoice.tbInvoice.UserId = Usr.tbUser.UserId
WHERE        (Invoice.tbInvoice.InvoiceTypeCode = 2)
ORDER BY Invoice.tbInvoice.AccountCode, Invoice.tbInvoice.InvoicedOn DESC
go

CREATE VIEW Invoice.vwCreditNoteSpool
AS
SELECT        credit_note.InvoiceNumber, credit_note.Printed, Invoice.tbType.InvoiceType, credit_note.InvoiceStatusCode, Usr.tbUser.UserName, credit_note.AccountCode, Org.tbOrg.AccountName, Invoice.tbStatus.InvoiceStatus, 
                         credit_note.InvoicedOn, credit_note.InvoiceValue AS InvoiceValueTotal, credit_note.TaxValue AS TaxValueTotal, credit_note.PaymentTerms, credit_note.Notes, Org.tbOrg.EmailAddress, 
                         Org.tbAddress.Address AS InvoiceAddress, tbInvoiceTask.TaskCode, Task.tbTask.TaskTitle, Task.tbTask.ActionedOn, tbInvoiceTask.Quantity, Activity.tbActivity.UnitOfMeasure, tbInvoiceTask.TaxCode, 
                         tbInvoiceTask.InvoiceValue, tbInvoiceTask.TaxValue
FROM            Invoice.tbInvoice AS credit_note INNER JOIN
                         Invoice.tbStatus ON credit_note.InvoiceStatusCode = Invoice.tbStatus.InvoiceStatusCode INNER JOIN
                         Org.tbOrg ON credit_note.AccountCode = Org.tbOrg.AccountCode INNER JOIN
                         Usr.tbUser ON credit_note.UserId = Usr.tbUser.UserId LEFT OUTER JOIN
                         Org.tbAddress ON Org.tbOrg.AddressCode = Org.tbAddress.AddressCode INNER JOIN
                         Invoice.tbTask AS tbInvoiceTask ON credit_note.InvoiceNumber = tbInvoiceTask.InvoiceNumber INNER JOIN
                         Task.tbTask ON tbInvoiceTask.TaskCode = Task.tbTask.TaskCode INNER JOIN
                         Activity.tbActivity ON Task.tbTask.ActivityCode = Activity.tbActivity.ActivityCode INNER JOIN
                         Invoice.tbType ON credit_note.InvoiceTypeCode = Invoice.tbType.InvoiceTypeCode
WHERE credit_note.InvoiceTypeCode = 1 
	AND EXISTS (SELECT * FROM App.tbDocSpool AS doc WHERE DocTypeCode = 5 AND UserName = SUSER_SNAME() AND credit_note.InvoiceNumber = doc.DocumentNumber);
go

CREATE VIEW Invoice.vwDebitNoteSpool
AS
SELECT        debit_note.Printed, debit_note.InvoiceNumber, Invoice.tbType.InvoiceType, debit_note.InvoiceStatusCode, Usr.tbUser.UserName, debit_note.AccountCode, Org.tbOrg.AccountName, Invoice.tbStatus.InvoiceStatus, 
                         debit_note.InvoicedOn, debit_note.InvoiceValue AS InvoiceValueTotal, debit_note.TaxValue AS TaxValueTotal, debit_note.PaymentTerms, debit_note.Notes, Org.tbOrg.EmailAddress, 
                         Org.tbAddress.Address AS InvoiceAddress, tbInvoiceTask.TaskCode, Task.tbTask.TaskTitle, Task.tbTask.ActionedOn, tbInvoiceTask.Quantity, Activity.tbActivity.UnitOfMeasure, tbInvoiceTask.TaxCode, 
                         tbInvoiceTask.InvoiceValue, tbInvoiceTask.TaxValue
FROM            Invoice.tbInvoice AS debit_note INNER JOIN
                         Invoice.tbStatus ON debit_note.InvoiceStatusCode = Invoice.tbStatus.InvoiceStatusCode INNER JOIN
                         Org.tbOrg ON debit_note.AccountCode = Org.tbOrg.AccountCode INNER JOIN
                         Usr.tbUser ON debit_note.UserId = Usr.tbUser.UserId LEFT OUTER JOIN
                         Org.tbAddress ON Org.tbOrg.AddressCode = Org.tbAddress.AddressCode INNER JOIN
                         Invoice.tbTask AS tbInvoiceTask ON debit_note.InvoiceNumber = tbInvoiceTask.InvoiceNumber INNER JOIN
                         Task.tbTask ON tbInvoiceTask.TaskCode = Task.tbTask.TaskCode INNER JOIN
                         Activity.tbActivity ON Task.tbTask.ActivityCode = Activity.tbActivity.ActivityCode INNER JOIN
                         Invoice.tbType ON debit_note.InvoiceTypeCode = Invoice.tbType.InvoiceTypeCode
WHERE debit_note.InvoiceTypeCode = 3 AND
	EXISTS (SELECT * FROM App.tbDocSpool AS doc WHERE DocTypeCode = 6 AND UserName = SUSER_SNAME() AND debit_note.InvoiceNumber = doc.DocumentNumber);
go

CREATE VIEW Invoice.vwDoc
AS
SELECT     Org.tbOrg.EmailAddress, Usr.tbUser.UserName, Org.tbOrg.AccountCode, Org.tbOrg.AccountName, Org.tbAddress.Address AS InvoiceAddress, 
                      Invoice.tbInvoice.InvoiceNumber, Invoice.tbType.InvoiceType, Invoice.tbStatus.InvoiceStatus, Invoice.tbInvoice.InvoicedOn, Invoice.tbInvoice.DueOn, 
                      Invoice.tbInvoice.InvoiceValue, Invoice.tbInvoice.TaxValue, Invoice.tbInvoice.PaymentTerms, Invoice.tbInvoice.Notes
FROM         Invoice.tbInvoice INNER JOIN
                      Org.tbOrg ON Invoice.tbInvoice.AccountCode = Org.tbOrg.AccountCode INNER JOIN
                      Invoice.tbType ON Invoice.tbInvoice.InvoiceTypeCode = Invoice.tbType.InvoiceTypeCode INNER JOIN
                      Usr.tbUser ON Invoice.tbInvoice.UserId = Usr.tbUser.UserId INNER JOIN
                      Invoice.tbStatus ON Invoice.tbInvoice.InvoiceStatusCode = Invoice.tbStatus.InvoiceStatusCode LEFT OUTER JOIN
                      Org.tbAddress ON Org.tbOrg.AddressCode = Org.tbAddress.AddressCode
go

CREATE VIEW Invoice.vwDocItem
AS
SELECT     Invoice.tbItem.InvoiceNumber, Invoice.tbItem.CashCode, Cash.tbCode.CashDescription, Invoice.tbInvoice.InvoicedOn AS ActionedOn, 
                      Invoice.tbItem.TaxCode, Invoice.tbItem.InvoiceValue, Invoice.tbItem.TaxValue, Invoice.tbItem.ItemReference
FROM         Invoice.tbItem INNER JOIN
                      Cash.tbCode ON Invoice.tbItem.CashCode = Cash.tbCode.CashCode INNER JOIN
                      Invoice.tbInvoice ON Invoice.tbItem.InvoiceNumber = Invoice.tbInvoice.InvoiceNumber
go

CREATE VIEW Invoice.vwDocTask
AS
SELECT        tbTaskInvoice.InvoiceNumber, tbTaskInvoice.TaskCode, Task.tbTask.TaskTitle, Task.tbTask.ActivityCode, tbTaskInvoice.CashCode, Cash.tbCode.CashDescription, Task.tbTask.ActionedOn, tbTaskInvoice.Quantity, 
                         Activity.tbActivity.UnitOfMeasure, tbTaskInvoice.InvoiceValue, tbTaskInvoice.TaxValue, tbTaskInvoice.TaxCode, Task.tbTask.SecondReference
FROM            Invoice.tbTask AS tbTaskInvoice INNER JOIN
                         Task.tbTask ON tbTaskInvoice.TaskCode = Task.tbTask.TaskCode AND tbTaskInvoice.TaskCode = Task.tbTask.TaskCode INNER JOIN
                         Cash.tbCode ON tbTaskInvoice.CashCode = Cash.tbCode.CashCode INNER JOIN
                         Activity.tbActivity ON Task.tbTask.ActivityCode = Activity.tbActivity.ActivityCode
go

CREATE VIEW Invoice.vwItems
AS
SELECT        Invoice.tbItem.InvoiceNumber, Invoice.tbItem.CashCode, Cash.tbCode.CashDescription, Invoice.tbItem.TaxCode, Invoice.tbItem.TaxValue, Invoice.tbItem.InvoiceValue, Invoice.tbItem.ItemReference, 
                         Invoice.tbInvoice.InvoicedOn
FROM            Invoice.tbItem INNER JOIN
                         Invoice.tbInvoice ON Invoice.tbItem.InvoiceNumber = Invoice.tbInvoice.InvoiceNumber INNER JOIN
                         Cash.tbCode ON Invoice.tbItem.CashCode = Cash.tbCode.CashCode;
go

CREATE VIEW Invoice.vwOutstanding
AS
	WITH invoiced_items AS
	(
		SELECT        Invoice.tbItem.InvoiceNumber, '' AS TaskCode, Invoice.tbItem.CashCode, Invoice.tbItem.TaxCode, (Invoice.tbItem.InvoiceValue + Invoice.tbItem.TaxValue) - (Invoice.tbItem.PaidValue + Invoice.tbItem.PaidTaxValue)
								  AS OutstandingValue, CASE WHEN InvoiceValue = 0 THEN 0 ELSE TaxValue / InvoiceValue END AS TaxRate, App.tbTaxCode.RoundingCode
		FROM            Invoice.tbItem INNER JOIN
								 App.tbTaxCode ON Invoice.tbItem.TaxCode = App.tbTaxCode.TaxCode
	), invoiced_tasks AS
	(
		SELECT        Invoice.tbTask.InvoiceNumber, Invoice.tbTask.TaskCode, Invoice.tbTask.CashCode, Invoice.tbTask.TaxCode, (Invoice.tbTask.InvoiceValue + Invoice.tbTask.TaxValue) 
								 - (Invoice.tbTask.PaidValue + Invoice.tbTask.PaidTaxValue) AS OutstandingValue, CASE WHEN InvoiceValue = 0 THEN 0 ELSE TaxValue / InvoiceValue END AS TaxRate, App.tbTaxCode.RoundingCode
		FROM            Invoice.tbTask INNER JOIN
								 App.tbTaxCode ON Invoice.tbTask.TaxCode = App.tbTaxCode.TaxCode
	), invoices_outstanding AS
	(
		SELECT        InvoiceNumber AS InvoiceNumber, TaskCode AS TaskCode, CashCode AS CashCode, TaxCode AS TaxCode, OutstandingValue, TaxRate, RoundingCode
		FROM            invoiced_items
		UNION
		SELECT        InvoiceNumber AS InvoiceNumber, TaskCode AS TaskCode, CashCode AS CashCode, TaxCode AS TaxCode, OutstandingValue, TaxRate, RoundingCode
		FROM            invoiced_tasks
	)
	SELECT Invoice.tbInvoice.AccountCode, Invoice.tbInvoice.DueOn, Invoice.tbInvoice.ExpectedOn, Invoice.tbInvoice.InvoiceNumber, invoices_outstanding.TaskCode, Invoice.tbInvoice.InvoiceStatusCode, 
							 Invoice.tbType.CashModeCode, invoices_outstanding.CashCode, invoices_outstanding.TaxCode, invoices_outstanding.TaxRate, invoices_outstanding.RoundingCode, 
							 CASE WHEN Invoice.tbType.CashModeCode = 0 THEN OutstandingValue * - 1 ELSE OutstandingValue END AS ItemValue
	FROM            invoices_outstanding INNER JOIN
							 Invoice.tbInvoice ON invoices_outstanding.InvoiceNumber = Invoice.tbInvoice.InvoiceNumber INNER JOIN
							 Invoice.tbType ON Invoice.tbInvoice.InvoiceTypeCode = Invoice.tbType.InvoiceTypeCode
	WHERE        (Invoice.tbInvoice.InvoiceStatusCode = 1) OR
							 (Invoice.tbInvoice.InvoiceStatusCode = 2);
go

CREATE VIEW Invoice.vwRegisterPurchasesOverdue
AS
SELECT TOP 100 PERCENT Invoice.tbInvoice.InvoiceNumber, Invoice.tbInvoice.AccountCode, Org.tbOrg.AccountName, Invoice.tbInvoice.InvoiceTypeCode, Invoice.tbInvoice.InvoiceStatusCode, Invoice.tbStatus.InvoiceStatus, 
                         Invoice.tbType.InvoiceType, (Invoice.tbInvoice.InvoiceValue + Invoice.tbInvoice.TaxValue) - (Invoice.tbInvoice.PaidValue + Invoice.tbInvoice.PaidTaxValue) AS UnpaidValue, 
						DATEDIFF(DD, CURRENT_TIMESTAMP, Invoice.tbInvoice.InvoicedOn) AS UnpaidDays, Invoice.tbInvoice.InvoicedOn, Invoice.tbInvoice.DueOn, Invoice.tbInvoice.ExpectedOn, Invoice.tbInvoice.InvoiceValue, Invoice.tbInvoice.TaxValue, Invoice.tbInvoice.PaymentTerms, 
                         Invoice.tbInvoice.Notes
FROM            Invoice.tbInvoice INNER JOIN
                         Invoice.tbStatus ON Invoice.tbInvoice.InvoiceStatusCode = Invoice.tbStatus.InvoiceStatusCode INNER JOIN
                         Invoice.tbType ON Invoice.tbInvoice.InvoiceTypeCode = Invoice.tbType.InvoiceTypeCode INNER JOIN
                         Org.tbOrg ON Invoice.tbInvoice.AccountCode = Org.tbOrg.AccountCode
WHERE        (Invoice.tbInvoice.InvoiceTypeCode > 1) AND (Invoice.tbInvoice.InvoiceStatusCode < 3)
ORDER BY Invoice.tbInvoice.ExpectedOn;
go

CREATE VIEW Invoice.vwRegisterSalesOverdue
AS
SELECT TOP 100 PERCENT Invoice.tbInvoice.InvoiceNumber, Invoice.tbInvoice.AccountCode, Org.tbOrg.AccountName, Invoice.tbInvoice.InvoiceTypeCode, Invoice.tbInvoice.InvoiceStatusCode, Invoice.tbStatus.InvoiceStatus, 
                         Invoice.tbType.InvoiceType, (Invoice.tbInvoice.InvoiceValue + Invoice.tbInvoice.TaxValue) - (Invoice.tbInvoice.PaidValue + Invoice.tbInvoice.PaidTaxValue) AS UnpaidValue, DATEDIFF(DD, CURRENT_TIMESTAMP, 
                         Invoice.tbInvoice.InvoicedOn) AS UnpaidDays, Invoice.tbInvoice.InvoicedOn, Invoice.tbInvoice.DueOn, Invoice.tbInvoice.ExpectedOn, Invoice.tbInvoice.InvoiceValue, Invoice.tbInvoice.TaxValue, Invoice.tbInvoice.PaymentTerms, 
                         Invoice.tbInvoice.Notes
FROM            Invoice.tbInvoice INNER JOIN
                         Invoice.tbStatus ON Invoice.tbInvoice.InvoiceStatusCode = Invoice.tbStatus.InvoiceStatusCode INNER JOIN
                         Invoice.tbType ON Invoice.tbInvoice.InvoiceTypeCode = Invoice.tbType.InvoiceTypeCode INNER JOIN
                         Org.tbOrg ON Invoice.tbInvoice.AccountCode = Org.tbOrg.AccountCode
WHERE        (Invoice.tbInvoice.InvoiceTypeCode < 2) AND (Invoice.tbInvoice.InvoiceStatusCode < 3)
ORDER BY Invoice.tbInvoice.ExpectedOn;
go

CREATE VIEW Invoice.vwSalesInvoiceSpool
AS
SELECT        sales_invoice.InvoiceNumber, Invoice.tbType.InvoiceType, sales_invoice.InvoiceStatusCode, Usr.tbUser.UserName, sales_invoice.AccountCode, Org.tbOrg.AccountName, Invoice.tbStatus.InvoiceStatus, 
                         sales_invoice.InvoicedOn, sales_invoice.InvoiceValue AS InvoiceValueTotal, sales_invoice.TaxValue AS TaxValueTotal, sales_invoice.PaymentTerms, sales_invoice.DueOn, sales_invoice.Notes, 
                         Org.tbOrg.EmailAddress, Org.tbAddress.Address AS InvoiceAddress, tbInvoiceTask.TaskCode, Task.tbTask.TaskTitle, Task.tbTask.ActionedOn, tbInvoiceTask.Quantity, Activity.tbActivity.UnitOfMeasure, 
                         tbInvoiceTask.TaxCode, tbInvoiceTask.InvoiceValue, tbInvoiceTask.TaxValue
FROM            Invoice.tbInvoice AS sales_invoice INNER JOIN
                         Invoice.tbStatus ON sales_invoice.InvoiceStatusCode = Invoice.tbStatus.InvoiceStatusCode INNER JOIN
                         Org.tbOrg ON sales_invoice.AccountCode = Org.tbOrg.AccountCode INNER JOIN
                         Usr.tbUser ON sales_invoice.UserId = Usr.tbUser.UserId LEFT OUTER JOIN
                         Org.tbAddress ON Org.tbOrg.AddressCode = Org.tbAddress.AddressCode INNER JOIN
                         Invoice.tbTask AS tbInvoiceTask ON sales_invoice.InvoiceNumber = tbInvoiceTask.InvoiceNumber INNER JOIN
                         Task.tbTask ON tbInvoiceTask.TaskCode = Task.tbTask.TaskCode INNER JOIN
                         Activity.tbActivity ON Task.tbTask.ActivityCode = Activity.tbActivity.ActivityCode INNER JOIN
                         Invoice.tbType ON sales_invoice.InvoiceTypeCode = Invoice.tbType.InvoiceTypeCode
WHERE sales_invoice.InvoiceTypeCode = 0 AND
	 EXISTS (SELECT * FROM App.tbDocSpool AS doc WHERE DocTypeCode = 4 AND UserName = SUSER_SNAME() AND sales_invoice.InvoiceNumber = doc.DocumentNumber);
go

CREATE VIEW Invoice.vwSalesInvoiceSpoolByActivity
AS
WITH invoice AS 
(
	SELECT        sales_invoice.InvoiceNumber, Invoice.tbType.InvoiceType, sales_invoice.InvoiceStatusCode, Usr.tbUser.UserName, sales_invoice.AccountCode, Org.tbOrg.AccountName, 
							Invoice.tbStatus.InvoiceStatus, sales_invoice.InvoicedOn, sales_invoice.InvoiceValue AS InvoiceValueTotal, sales_invoice.TaxValue AS TaxValueTotal, sales_invoice.PaymentTerms, 
							Org.tbOrg.EmailAddress, Org.tbOrg.AddressCode, Activity.tbActivity.ActivityCode, Activity.tbActivity.UnitOfMeasure, MIN(Task.tbTask.ActionedOn) AS FirstActionedOn, 
							SUM(tbInvoiceTask.Quantity) AS ActivityQuantity, tbInvoiceTask.TaxCode, SUM(tbInvoiceTask.InvoiceValue) AS ActivityInvoiceValue, SUM(tbInvoiceTask.TaxValue) AS ActivityTaxValue
	FROM            Invoice.tbInvoice AS sales_invoice INNER JOIN
							Invoice.tbStatus ON sales_invoice.InvoiceStatusCode = Invoice.tbStatus.InvoiceStatusCode INNER JOIN
							Org.tbOrg ON sales_invoice.AccountCode = Org.tbOrg.AccountCode INNER JOIN
							Usr.tbUser ON sales_invoice.UserId = Usr.tbUser.UserId INNER JOIN
							Invoice.tbTask AS tbInvoiceTask ON sales_invoice.InvoiceNumber = tbInvoiceTask.InvoiceNumber INNER JOIN
							Task.tbTask ON tbInvoiceTask.TaskCode = Task.tbTask.TaskCode INNER JOIN
							Activity.tbActivity ON Task.tbTask.ActivityCode = Activity.tbActivity.ActivityCode INNER JOIN
							Invoice.tbType ON sales_invoice.InvoiceTypeCode = Invoice.tbType.InvoiceTypeCode
	WHERE        EXISTS
								(SELECT        UserName, DocTypeCode, DocumentNumber, SpooledOn
									FROM            App.tbDocSpool AS doc
									WHERE        (DocTypeCode = 4) AND (UserName = SUSER_SNAME()) AND (sales_invoice.InvoiceNumber = DocumentNumber))
	GROUP BY sales_invoice.InvoiceNumber, Invoice.tbType.InvoiceType, sales_invoice.InvoiceStatusCode, Usr.tbUser.UserName, sales_invoice.AccountCode, Org.tbOrg.AccountName, 
							Invoice.tbStatus.InvoiceStatus, sales_invoice.InvoicedOn, sales_invoice.InvoiceValue, sales_invoice.TaxValue, sales_invoice.PaymentTerms, Org.tbOrg.EmailAddress, Org.tbOrg.AddressCode, 
							Activity.tbActivity.ActivityCode, Activity.tbActivity.UnitOfMeasure, tbInvoiceTask.TaxCode
)
SELECT        invoice_1.InvoiceNumber, invoice_1.InvoiceType, invoice_1.InvoiceStatusCode, invoice_1.UserName, invoice_1.AccountCode, invoice_1.AccountName, invoice_1.InvoiceStatus, invoice_1.InvoicedOn, 
                        Invoice.tbInvoice.Notes, Org.tbAddress.Address AS InvoiceAddress, invoice_1.InvoiceValueTotal, invoice_1.TaxValueTotal, invoice_1.PaymentTerms, invoice_1.EmailAddress, invoice_1.AddressCode, 
                        invoice_1.ActivityCode, invoice_1.UnitOfMeasure, invoice_1.FirstActionedOn, invoice_1.ActivityQuantity, invoice_1.TaxCode, invoice_1.ActivityInvoiceValue, invoice_1.ActivityTaxValue
FROM            invoice AS invoice_1 INNER JOIN
                        Invoice.tbInvoice ON invoice_1.InvoiceNumber = Invoice.tbInvoice.InvoiceNumber LEFT OUTER JOIN
                        Org.tbAddress ON invoice_1.AddressCode = Org.tbAddress.AddressCode;
go

CREATE VIEW Invoice.vwSummary
AS
	WITH tasks AS
	(
		SELECT  (SELECT TOP (1) p.StartOn FROM App.tbYearPeriod p WHERE (p.StartOn <= Invoice.tbInvoice.InvoicedOn) ORDER BY p.StartOn DESC) AS StartOn,  
								 CASE WHEN Invoice.tbInvoice.InvoiceTypeCode = 1 THEN 0 ELSE CASE WHEN Invoice.tbInvoice.InvoiceTypeCode = 3 THEN 2 ELSE Invoice.tbInvoice.InvoiceTypeCode END END AS InvoiceTypeCode, 
								 CASE WHEN Invoice.tbType.CashModeCode = 0 THEN Invoice.tbTask.InvoiceValue * - 1 ELSE Invoice.tbTask.InvoiceValue END AS InvoiceValue, 
								 CASE WHEN Invoice.tbType.CashModeCode = 0 THEN Invoice.tbTask.TaxValue * - 1 ELSE Invoice.tbTask.TaxValue END AS TaxValue
		FROM            Invoice.tbTask INNER JOIN
								 Invoice.tbInvoice ON Invoice.tbTask.InvoiceNumber = Invoice.tbInvoice.InvoiceNumber INNER JOIN
								 Invoice.tbType ON Invoice.tbInvoice.InvoiceTypeCode = Invoice.tbType.InvoiceTypeCode
		WHERE        (Invoice.tbInvoice.InvoicedOn >= (	
						SELECT MIN( App.tbYearPeriod.StartOn) FROM App.tbYear 
						INNER JOIN App.tbYearPeriod ON App.tbYear.YearNumber = App.tbYearPeriod.YearNumber 
						WHERE ( App.tbYear.CashStatusCode < 3)))
	), items AS
	(
		SELECT  (SELECT TOP (1) p.StartOn FROM App.tbYearPeriod p WHERE (p.StartOn <= Invoice.tbInvoice.InvoicedOn) ORDER BY p.StartOn DESC) AS StartOn,  
								 CASE WHEN Invoice.tbInvoice.InvoiceTypeCode = 1 THEN 0 ELSE CASE WHEN Invoice.tbInvoice.InvoiceTypeCode = 3 THEN 2 ELSE Invoice.tbInvoice.InvoiceTypeCode END END AS InvoiceTypeCode, 
								 CASE WHEN Invoice.tbType.CashModeCode = 0 THEN Invoice.tbItem.InvoiceValue * - 1 ELSE Invoice.tbItem.InvoiceValue END AS InvoiceValue, 
								 CASE WHEN Invoice.tbType.CashModeCode = 0 THEN Invoice.tbItem.TaxValue * - 1 ELSE Invoice.tbItem.TaxValue END AS TaxValue
		FROM            Invoice.tbItem INNER JOIN
								 Invoice.tbInvoice ON Invoice.tbItem.InvoiceNumber = Invoice.tbInvoice.InvoiceNumber INNER JOIN
								 Invoice.tbType ON Invoice.tbInvoice.InvoiceTypeCode = Invoice.tbType.InvoiceTypeCode
		WHERE        (Invoice.tbInvoice.InvoicedOn >= (	
						SELECT MIN( App.tbYearPeriod.StartOn) FROM App.tbYear 
						INNER JOIN App.tbYearPeriod ON App.tbYear.YearNumber = App.tbYearPeriod.YearNumber 
						WHERE ( App.tbYear.CashStatusCode < 3)))
	), invoice_entries AS
	(
		SELECT     StartOn, InvoiceTypeCode, InvoiceValue, TaxValue
		FROM         items
		UNION
		SELECT     StartOn, InvoiceTypeCode, InvoiceValue, TaxValue
		FROM         tasks
	), invoice_totals AS
	(
		SELECT     invoice_entries.StartOn, invoice_entries.InvoiceTypeCode, Invoice.tbType.InvoiceType, 
							  SUM(invoice_entries.InvoiceValue) AS TotalInvoiceValue, SUM(invoice_entries.TaxValue) AS TotalTaxValue
		FROM         invoice_entries INNER JOIN
							  Invoice.tbType ON invoice_entries.InvoiceTypeCode = Invoice.tbType.InvoiceTypeCode
		GROUP BY invoice_entries.StartOn, invoice_entries.InvoiceTypeCode, Invoice.tbType.InvoiceType
	), invoice_margin AS
	(
		SELECT     StartOn, 4 AS InvoiceTypeCode, (SELECT CAST(Message AS NVARCHAR(10)) FROM App.tbText WHERE TextId = 3004) AS InvoiceType, SUM(TotalInvoiceValue) AS TotalInvoiceValue, SUM(TotalTaxValue) 
							  AS TotalTaxValue
		FROM         invoice_totals
		GROUP BY StartOn
	)
	SELECT     CONCAT(DATENAME(yyyy, StartOn), '/', FORMAT(MONTH(StartOn), '00')) AS PeriodOn, StartOn, InvoiceTypeCode, InvoiceType AS InvoiceType, 
						  ABS(TotalInvoiceValue) AS TotalInvoiceValue, ABS(TotalTaxValue) AS TotalTaxValue
	FROM         invoice_totals
	UNION
	SELECT     CONCAT(DATENAME(yyyy, StartOn), '/', FORMAT(MONTH(StartOn), '00')) AS PeriodOn, StartOn, InvoiceTypeCode, InvoiceType AS InvoiceType, 
						  TotalInvoiceValue, TotalTaxValue
	FROM         invoice_margin;
go

CREATE VIEW Invoice.vwTaxSummary
AS
	WITH base AS
	(
		SELECT        InvoiceNumber, TaxCode, SUM(InvoiceValue) AS InvoiceValueTotal, SUM(TaxValue) AS TaxValueTotal
		FROM            Invoice.tbItem
		GROUP BY InvoiceNumber, TaxCode
		HAVING        (NOT (TaxCode IS NULL))
		UNION
		SELECT        InvoiceNumber, TaxCode, SUM(InvoiceValue) AS InvoiceValueTotal, SUM(TaxValue) AS TaxValueTotal
		FROM            Invoice.tbTask
		GROUP BY InvoiceNumber, TaxCode
		HAVING        (NOT (TaxCode IS NULL))
	)
	SELECT        InvoiceNumber, TaxCode, SUM(InvoiceValueTotal) AS InvoiceValueTotal, SUM(TaxValueTotal) AS TaxValueTotal, 
	 CASE WHEN SUM(InvoiceValueTotal) <> 0 THEN SUM(TaxValueTotal) / SUM(InvoiceValueTotal) ELSE 0 END AS TaxRate
	FROM            base
	GROUP BY InvoiceNumber, TaxCode;
go

CREATE VIEW Org.vwAccountLookup
AS
SELECT        Org.tbOrg.AccountCode, Org.tbOrg.AccountName, Org.tbType.OrganisationType, Cash.tbMode.CashMode
FROM            Org.tbOrg INNER JOIN
                         Org.tbType ON Org.tbOrg.OrganisationTypeCode = Org.tbType.OrganisationTypeCode INNER JOIN
                         Cash.tbMode ON Org.tbType.CashModeCode = Cash.tbMode.CashModeCode
WHERE        (Org.tbOrg.OrganisationStatusCode < 3);
go

CREATE VIEW Org.vwAccountSources
AS
SELECT        AccountSource
FROM            Org.tbOrg
GROUP BY AccountSource
HAVING        (AccountSource IS NOT NULL);
go

CREATE VIEW Org.vwAreaCodes
AS
SELECT        AreaCode
FROM            Org.tbOrg
GROUP BY AreaCode
HAVING        (AreaCode IS NOT NULL);
go

CREATE VIEW Org.vwBalanceOutstanding
AS
	WITH invoices_unpaid AS
	(
		SELECT        Invoice.tbInvoice.AccountCode, 
			CASE Invoice.tbType.CashModeCode 
				WHEN 0 THEN ((InvoiceValue + TaxValue) - (PaidValue + PaidTaxValue)) * - 1 
				WHEN 1 THEN (InvoiceValue + TaxValue) - (PaidValue + PaidTaxValue) END AS OutstandingValue
		FROM            Invoice.tbInvoice INNER JOIN
								 Invoice.tbType ON Invoice.tbInvoice.InvoiceTypeCode = Invoice.tbType.InvoiceTypeCode
		WHERE        (Invoice.tbInvoice.InvoiceStatusCode > 0) AND (Invoice.tbInvoice.InvoiceStatusCode < 3) 
	), current_balance AS
	(
		SELECT AccountCode, SUM(OutstandingValue) AS Balance
		FROM   invoices_unpaid	
		GROUP BY AccountCode
	)
	SELECT org.AccountCode, ISNULL(current_balance.Balance, 0) AS Balance
	FROM Org.tbOrg org 
		LEFT OUTER JOIN current_balance ON org.AccountCode = current_balance.AccountCode;


go

CREATE VIEW Org.vwCashAccounts
AS
SELECT        Org.tbAccount.CashAccountCode, Org.tbAccount.CashAccountName, Org.tbOrg.AccountName, Org.tbType.OrganisationType, Org.tbAccount.OpeningBalance, Org.tbAccount.CurrentBalance, Org.tbAccount.SortCode, 
                         Org.tbAccount.AccountNumber, Org.tbAccount.AccountClosed, Org.tbAccount.RowVer
FROM            Org.tbOrg INNER JOIN
                         Org.tbAccount ON Org.tbOrg.AccountCode = Org.tbAccount.AccountCode INNER JOIN
                         Org.tbType ON Org.tbOrg.OrganisationTypeCode = Org.tbType.OrganisationTypeCode;
go

CREATE VIEW Org.vwCashAccountsLive
AS
SELECT        Org.tbAccount.CashAccountCode, Org.tbAccount.CashAccountName, Org.tbAccount.RowVer
FROM            Org.tbAccount INNER JOIN
                         Org.tbOrg ON Org.tbAccount.AccountCode = Org.tbOrg.AccountCode
WHERE        (Org.tbAccount.AccountClosed = 0);
go

CREATE VIEW Org.vwCompanyHeader
AS
SELECT        TOP (1) Org.tbOrg.AccountName AS CompanyName, Org.tbAddress.Address AS CompanyAddress, Org.tbOrg.PhoneNumber AS CompanyPhoneNumber, Org.tbOrg.FaxNumber AS CompanyFaxNumber, 
                         Org.tbOrg.EmailAddress AS CompanyEmailAddress, Org.tbOrg.WebSite AS CompanyWebsite, Org.tbOrg.CompanyNumber, Org.tbOrg.VatNumber
FROM            Org.tbOrg INNER JOIN
                         App.tbOptions ON Org.tbOrg.AccountCode = App.tbOptions.AccountCode LEFT OUTER JOIN
                         Org.tbAddress ON Org.tbOrg.AddressCode = Org.tbAddress.AddressCode;
go

CREATE VIEW Org.vwCompanyLogo
AS
SELECT        TOP (1) Org.tbOrg.Logo
FROM            Org.tbOrg INNER JOIN
                         App.tbOptions ON Org.tbOrg.AccountCode = App.tbOptions.AccountCode;
go

CREATE VIEW Org.vwContacts
AS
	WITH ContactCount AS (SELECT        ContactName, COUNT(TaskCode) AS Tasks
                                                   FROM            Task.tbTask
                                                   WHERE        (TaskStatusCode < 2)
                                                   GROUP BY ContactName
                                                   HAVING         (ContactName IS NOT NULL))
    SELECT TOP (100) PERCENT   Org.tbContact.ContactName, Org.tbOrg.AccountCode, ContactCount_1.Tasks, Org.tbContact.PhoneNumber, Org.tbContact.HomeNumber, Org.tbContact.MobileNumber, Org.tbContact.FaxNumber, 
                              Org.tbContact.EmailAddress, Org.tbOrg.AccountName, Org.tbType.OrganisationType, Org.tbStatus.OrganisationStatus, Org.tbContact.NameTitle, Org.tbContact.NickName, Org.tbContact.JobTitle, 
                              Org.tbContact.Department
     FROM            Org.tbOrg INNER JOIN
                              Org.tbType ON Org.tbOrg.OrganisationTypeCode = Org.tbType.OrganisationTypeCode INNER JOIN
                              Org.tbStatus ON Org.tbOrg.OrganisationStatusCode = Org.tbStatus.OrganisationStatusCode INNER JOIN
                              Org.tbContact ON Org.tbOrg.AccountCode = Org.tbContact.AccountCode LEFT OUTER JOIN
                              ContactCount AS ContactCount_1 ON Org.tbContact.ContactName = ContactCount_1.ContactName
     WHERE        (Org.tbOrg.OrganisationStatusCode < 3)
     ORDER BY Org.tbContact.ContactName;
go

CREATE VIEW Org.vwDepartments
AS
SELECT        Department
FROM            Org.tbContact
GROUP BY Department
HAVING        (Department IS NOT NULL);
go

CREATE VIEW Org.vwInvoiceItems
AS
SELECT        Invoice.tbInvoice.AccountCode, Invoice.tbItem.InvoiceNumber, Invoice.tbItem.CashCode, Invoice.tbInvoice.InvoicedOn, Invoice.tbInvoice.InvoiceTypeCode, Invoice.tbStatus.InvoiceStatus, 
                         Cash.tbCode.CashDescription, Org.tbOrg.AccountName, Invoice.tbInvoice.InvoiceStatusCode, Invoice.tbType.InvoiceType, Invoice.tbItem.TaxCode, Invoice.tbItem.TaxValue, 
                         Invoice.tbItem.InvoiceValue, Invoice.tbItem.PaidValue, Invoice.tbItem.PaidTaxValue, Invoice.tbItem.ItemReference
FROM            Invoice.tbInvoice INNER JOIN
                         Invoice.tbStatus ON Invoice.tbInvoice.InvoiceStatusCode = Invoice.tbStatus.InvoiceStatusCode INNER JOIN
                         Org.tbOrg ON Invoice.tbInvoice.AccountCode = Org.tbOrg.AccountCode INNER JOIN
                         Invoice.tbType ON Invoice.tbInvoice.InvoiceTypeCode = Invoice.tbType.InvoiceTypeCode INNER JOIN
                         Invoice.tbItem ON Invoice.tbInvoice.InvoiceNumber = Invoice.tbItem.InvoiceNumber INNER JOIN
                         Cash.tbCode ON Invoice.tbItem.CashCode = Cash.tbCode.CashCode
WHERE        (Invoice.tbInvoice.InvoiceStatusCode > 0);
go

CREATE VIEW Org.vwJobTitles
AS
SELECT        JobTitle
FROM            Org.tbContact
GROUP BY JobTitle
HAVING        (JobTitle IS NOT NULL);
go

CREATE VIEW Org.vwListActive
AS
	SELECT        TOP (100) PERCENT Org.tbOrg.AccountCode, Org.tbOrg.AccountName, Org.tbType.CashModeCode
	FROM            Org.tbOrg INNER JOIN
							 Task.tbTask ON Org.tbOrg.AccountCode = Task.tbTask.AccountCode INNER JOIN
							 Org.tbType ON Org.tbOrg.OrganisationTypeCode = Org.tbType.OrganisationTypeCode
	WHERE        (Task.tbTask.TaskStatusCode = 1 OR
							 Task.tbTask.TaskStatusCode = 2) AND (Task.tbTask.CashCode IS NOT NULL)
	GROUP BY Org.tbOrg.AccountCode, Org.tbOrg.AccountName, Org.tbType.CashModeCode
	ORDER BY Org.tbOrg.AccountName;
go

CREATE VIEW Org.vwListAll
AS
	SELECT TOP (100) PERCENT Org.tbOrg.AccountCode, Org.tbOrg.AccountName, Org.tbType.CashModeCode
	FROM Org.tbOrg INNER JOIN Org.tbType ON Org.tbOrg.OrganisationTypeCode = Org.tbType.OrganisationTypeCode
	ORDER BY Org.tbOrg.AccountName;
go

CREATE VIEW Org.vwNameTitles
AS
SELECT        NameTitle
FROM            Org.tbContact
GROUP BY NameTitle
HAVING        (NameTitle IS NOT NULL);
go

CREATE VIEW Org.vwPayments
AS
SELECT        Org.tbPayment.AccountCode, Org.tbPayment.PaymentCode, Org.tbPayment.UserId, Org.tbPayment.PaymentStatusCode, Org.tbPayment.CashAccountCode, Org.tbPayment.CashCode, Org.tbPayment.TaxCode, 
                         Org.tbPayment.PaidOn, Org.tbPayment.PaidInValue, Org.tbPayment.PaidOutValue, Org.tbPayment.TaxInValue, Org.tbPayment.TaxOutValue, Org.tbPayment.PaymentReference, Org.tbPayment.InsertedBy, 
                         Org.tbPayment.InsertedOn, Org.tbPayment.UpdatedBy, Org.tbPayment.UpdatedOn, Usr.tbUser.UserName, App.tbTaxCode.TaxDescription, Org.tbAccount.CashAccountName, Cash.tbCode.CashDescription
FROM            Org.tbPayment INNER JOIN
                         Usr.tbUser ON Org.tbPayment.UserId = Usr.tbUser.UserId INNER JOIN
                         Org.tbAccount ON Org.tbPayment.CashAccountCode = Org.tbAccount.CashAccountCode INNER JOIN
                         Cash.tbCode ON Org.tbPayment.CashCode = Cash.tbCode.CashCode LEFT OUTER JOIN
                         App.tbTaxCode ON Org.tbPayment.TaxCode = App.tbTaxCode.TaxCode
WHERE        (Org.tbPayment.PaymentStatusCode = 1);
go

CREATE VIEW Org.vwPaymentsListing
AS
SELECT        TOP (100) PERCENT Org.tbOrg.AccountCode, Org.tbOrg.AccountName, Org.tbType.OrganisationType, Org.tbStatus.OrganisationStatus, Org.tbPayment.PaymentCode, Usr.tbUser.UserName, 
                         App.tbTaxCode.TaxDescription AS PaymentTaxDescription, Org.tbAccount.CashAccountName, Cash.tbCode.CashDescription, Org.tbPayment.UserId, Org.tbPayment.CashAccountCode, Org.tbPayment.CashCode, 
                         Org.tbPayment.TaxCode, CONCAT(YEAR(Org.tbPayment.PaidOn), Format(MONTH(Org.tbPayment.PaidOn), '00')) AS Period, Org.tbPayment.PaidOn, Org.tbPayment.PaidInValue, Org.tbPayment.PaidOutValue, 
                         Org.tbPayment.TaxInValue, Org.tbPayment.TaxOutValue, Org.tbPayment.InsertedBy, Org.tbPayment.InsertedOn, Org.tbPayment.UpdatedBy, Org.tbPayment.UpdatedOn, Org.tbPayment.PaymentReference
FROM            Org.tbPayment INNER JOIN
                         Usr.tbUser ON Org.tbPayment.UserId = Usr.tbUser.UserId INNER JOIN
                         Org.tbAccount ON Org.tbPayment.CashAccountCode = Org.tbAccount.CashAccountCode INNER JOIN
                         Cash.tbCode ON Org.tbPayment.CashCode = Cash.tbCode.CashCode LEFT OUTER JOIN
                         App.tbTaxCode ON Org.tbPayment.TaxCode = App.tbTaxCode.TaxCode INNER JOIN
                         Org.tbOrg ON Org.tbPayment.AccountCode = Org.tbOrg.AccountCode INNER JOIN
                         Org.tbType ON Org.tbOrg.OrganisationTypeCode = Org.tbType.OrganisationTypeCode INNER JOIN
                         Org.tbStatus ON Org.tbOrg.OrganisationStatusCode = Org.tbStatus.OrganisationStatusCode
WHERE        (Org.tbPayment.PaymentStatusCode = 1) 
ORDER BY Org.tbPayment.AccountCode, Org.tbPayment.PaidOn DESC;
go

CREATE VIEW Org.vwPaymentsUnposted
AS
SELECT        PaymentCode, UserId, PaymentStatusCode, AccountCode, CashAccountCode, CashCode, TaxCode, PaidOn, PaidInValue, PaidOutValue, TaxInValue, TaxOutValue, PaymentReference, InsertedBy, InsertedOn, 
                         UpdatedBy, UpdatedOn, RowVer
FROM            Org.tbPayment
WHERE        (PaymentStatusCode = 0)
go


CREATE VIEW Org.vwPaymentTerms
AS
SELECT        PaymentTerms
FROM            Org.tbOrg
GROUP BY PaymentTerms
HAVING         LEN(ISNULL(PaymentTerms, '')) > 0;
go

CREATE VIEW Org.vwPurchaseInvoices
AS
SELECT        Invoice.tbInvoice.AccountCode, tbInvoiceTask.InvoiceNumber, tbInvoiceTask.TaskCode, Task.tbTask.ContactName, Invoice.tbInvoice.InvoicedOn, tbInvoiceTask.Quantity, tbInvoiceTask.InvoiceValue, 
                         tbInvoiceTask.TaxValue, tbInvoiceTask.CashCode, tbInvoiceTask.TaxCode, Invoice.tbStatus.InvoiceStatus, Task.tbTask.TaskNotes, Cash.tbCode.CashDescription, Invoice.tbInvoice.InvoiceStatusCode, 
                         Task.tbTask.TaskTitle, Org.tbOrg.AccountName, Invoice.tbInvoice.InvoiceTypeCode, Invoice.tbType.InvoiceType
FROM            Invoice.tbInvoice INNER JOIN
                         Invoice.tbTask AS tbInvoiceTask ON Invoice.tbInvoice.InvoiceNumber = tbInvoiceTask.InvoiceNumber INNER JOIN
                         Task.tbTask ON tbInvoiceTask.TaskCode = Task.tbTask.TaskCode INNER JOIN
                         Cash.tbCode ON tbInvoiceTask.CashCode = Cash.tbCode.CashCode INNER JOIN
                         Invoice.tbStatus ON Invoice.tbInvoice.InvoiceStatusCode = Invoice.tbStatus.InvoiceStatusCode INNER JOIN
                         Org.tbOrg ON Invoice.tbInvoice.AccountCode = Org.tbOrg.AccountCode INNER JOIN
                         Invoice.tbType ON Invoice.tbInvoice.InvoiceTypeCode = Invoice.tbType.InvoiceTypeCode
WHERE        (Invoice.tbInvoice.InvoiceStatusCode > 0) AND (Invoice.tbInvoice.InvoiceTypeCode > 1);
go

CREATE VIEW Org.vwSalesInvoices
AS
SELECT        Invoice.tbInvoice.AccountCode, tbInvoiceTask.InvoiceNumber, tbInvoiceTask.TaskCode, Task.tbTask.ContactName, Invoice.tbInvoice.InvoicedOn, tbInvoiceTask.Quantity, tbInvoiceTask.InvoiceValue, 
                         tbInvoiceTask.TaxValue, tbInvoiceTask.CashCode, tbInvoiceTask.TaxCode, Invoice.tbStatus.InvoiceStatus, Task.tbTask.TaskNotes, Cash.tbCode.CashDescription, Invoice.tbInvoice.InvoiceStatusCode, 
                         Task.tbTask.TaskTitle, Org.tbOrg.AccountName, Invoice.tbInvoice.InvoiceTypeCode, Invoice.tbType.InvoiceType, tbInvoiceTask.PaidValue, tbInvoiceTask.PaidTaxValue
FROM            Invoice.tbInvoice INNER JOIN
                         Invoice.tbTask AS tbInvoiceTask ON Invoice.tbInvoice.InvoiceNumber = tbInvoiceTask.InvoiceNumber INNER JOIN
                         Task.tbTask ON tbInvoiceTask.TaskCode = Task.tbTask.TaskCode INNER JOIN
                         Cash.tbCode ON tbInvoiceTask.CashCode = Cash.tbCode.CashCode INNER JOIN
                         Invoice.tbStatus ON Invoice.tbInvoice.InvoiceStatusCode = Invoice.tbStatus.InvoiceStatusCode INNER JOIN
                         Org.tbOrg ON Invoice.tbInvoice.AccountCode = Org.tbOrg.AccountCode INNER JOIN
                         Invoice.tbType ON Invoice.tbInvoice.InvoiceTypeCode = Invoice.tbType.InvoiceTypeCode
WHERE        (Invoice.tbInvoice.InvoiceStatusCode > 0) AND (Invoice.tbInvoice.InvoiceTypeCode = 0);
go

CREATE VIEW Org.vwStatement 
AS
	WITH payment_data AS
	(
		SELECT Org.tbPayment.AccountCode, Org.tbPayment.PaidOn AS TransactedOn, 2 AS OrderBy, 
							  Org.tbPayment.PaymentReference AS Reference, Org.tbPaymentStatus.PaymentStatus AS StatementType, 
							  CASE WHEN PaidInValue > 0 THEN PaidInValue ELSE PaidOutValue * - 1 END AS Charge
		FROM         Org.tbPayment INNER JOIN
							  Org.tbPaymentStatus ON Org.tbPayment.PaymentStatusCode = Org.tbPaymentStatus.PaymentStatusCode
	), payments AS
	(
		SELECT     AccountCode, TransactedOn, OrderBy, Reference, StatementType, SUM(Charge) AS Charge
		FROM     payment_data
		GROUP BY AccountCode, TransactedOn, OrderBy, Reference, StatementType
	), invoices AS
	(
		SELECT Invoice.tbInvoice.AccountCode, Invoice.tbInvoice.InvoicedOn AS TransactedOn, 1 AS OrderBy, Invoice.tbInvoice.InvoiceNumber AS Reference, 
							  Invoice.tbType.InvoiceType AS StatementType, 
							  CASE CashModeCode WHEN 0 THEN Invoice.tbInvoice.InvoiceValue + Invoice.tbInvoice.TaxValue WHEN 1 THEN (Invoice.tbInvoice.InvoiceValue + Invoice.tbInvoice.TaxValue)
							   * - 1 END AS Charge
		FROM         Invoice.tbInvoice INNER JOIN
							  Invoice.tbType ON Invoice.tbInvoice.InvoiceTypeCode = Invoice.tbType.InvoiceTypeCode
	), transactions_union AS
	(
		SELECT     AccountCode, TransactedOn, OrderBy, Reference, StatementType, Charge
		FROM         payments
		UNION
		SELECT     AccountCode, TransactedOn, OrderBy, Reference, StatementType, Charge
		FROM         invoices
	), transactions AS
	(
		SELECT AccountCode, ROW_NUMBER() OVER (PARTITION BY AccountCode ORDER BY TransactedOn, OrderBy) AS RowNumber, TransactedOn, OrderBy, Reference, StatementType, Charge 
		FROM transactions_union
	), opening_balance AS
	(
		SELECT AccountCode, 0 AS RowNumber, InsertedOn AS TransactedOn, 0 AS OrderBy, NULL AS Reference, 
			(SELECT CAST(Message AS NVARCHAR) FROM App.tbText WHERE TextId = 3005) AS StatementType, OpeningBalance AS Charge
		FROM Org.tbOrg org
	), statement_data AS
	( 
		SELECT AccountCode, RowNumber, TransactedOn, OrderBy, Reference, StatementType, Charge FROM transactions
		UNION
		SELECT AccountCode, RowNumber, TransactedOn, OrderBy, Reference, StatementType, Charge FROM opening_balance
	)
		SELECT AccountCode, CAST(RowNumber AS INT) AS RowNumber, TransactedOn, OrderBy, Reference, StatementType, Charge,
			SUM(Charge) OVER (PARTITION BY AccountCode ORDER BY RowNumber ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS Balance
		FROM statement_data;
go

CREATE VIEW Org.vwTypeLookup
AS
SELECT        Org.tbType.OrganisationTypeCode, Org.tbType.OrganisationType, Cash.tbMode.CashMode
FROM            Org.tbType INNER JOIN
                         Cash.tbMode ON Org.tbType.CashModeCode = Cash.tbMode.CashModeCode;
go

CREATE VIEW Task.vwActiveStatusCodes
AS
SELECT        TaskStatusCode, TaskStatus
FROM            Task.tbStatus
WHERE        (TaskStatusCode < 3);
go

CREATE VIEW Task.vwAttributeDescriptions
AS
SELECT        Attribute, AttributeDescription
FROM            Task.tbAttribute
GROUP BY Attribute, AttributeDescription
HAVING        (AttributeDescription IS NOT NULL);
go


CREATE VIEW Task.vwAttributesForOrder
AS
SELECT        TaskCode, Attribute, PrintOrder, AttributeDescription
FROM            Task.tbAttribute
WHERE        (AttributeTypeCode = 0);
go


CREATE VIEW Task.vwAttributesForQuote
AS
SELECT        TaskCode, Attribute, PrintOrder, AttributeDescription
FROM            Task.tbAttribute
WHERE        (AttributeTypeCode = 1);
go

CREATE VIEW Task.vwCashMode
  AS
SELECT     Task.tbTask.TaskCode, CASE WHEN Cash.tbCategory.CategoryCode IS NULL 
                      THEN Org.tbType.CashModeCode ELSE Cash.tbCategory.CashModeCode END AS CashModeCode
FROM         Task.tbTask INNER JOIN
                      Cash.tbCode ON Task.tbTask.CashCode = Cash.tbCode.CashCode INNER JOIN
                      Cash.tbCategory ON Cash.tbCode.CategoryCode = Cash.tbCategory.CategoryCode INNER JOIN
                      Org.tbOrg ON Task.tbTask.AccountCode = Org.tbOrg.AccountCode INNER JOIN
                      Org.tbType ON Org.tbOrg.OrganisationTypeCode = Org.tbType.OrganisationTypeCode
go

CREATE VIEW Task.vwDoc
AS
SELECT     Task.fnEmailAddress(Task.tbTask.TaskCode) AS EmailAddress, Task.tbTask.TaskCode, Task.tbTask.TaskStatusCode, Task.tbStatus.TaskStatus, 
                      Task.tbTask.ContactName, Org.tbContact.NickName, Usr.tbUser.UserName, Org.tbOrg.AccountName, Org.tbAddress.Address AS InvoiceAddress, 
                      Org_tb1.AccountName AS DeliveryAccountName, Org_tbAddress1.Address AS DeliveryAddress, Org_tb2.AccountName AS CollectionAccountName, 
                      Org_tbAddress2.Address AS CollectionAddress, Task.tbTask.AccountCode, Task.tbTask.TaskNotes, Task.tbTask.ActivityCode, Task.tbTask.ActionOn, 
                      Activity.tbActivity.UnitOfMeasure, Task.tbTask.Quantity, App.tbTaxCode.TaxCode, App.tbTaxCode.TaxRate, Task.tbTask.UnitCharge, Task.tbTask.TotalCharge, 
                      Usr.tbUser.MobileNumber, Usr.tbUser.Signature, Task.tbTask.TaskTitle, Task.tbTask.PaymentOn, Task.tbTask.SecondReference, Org.tbOrg.PaymentTerms
FROM         Org.tbOrg AS Org_tb2 RIGHT OUTER JOIN
                      Org.tbAddress AS Org_tbAddress2 ON Org_tb2.AccountCode = Org_tbAddress2.AccountCode RIGHT OUTER JOIN
                      Task.tbStatus INNER JOIN
                      Usr.tbUser INNER JOIN
                      Activity.tbActivity INNER JOIN
                      Task.tbTask ON Activity.tbActivity.ActivityCode = Task.tbTask.ActivityCode INNER JOIN
                      Org.tbOrg ON Task.tbTask.AccountCode = Org.tbOrg.AccountCode LEFT OUTER JOIN
                      Org.tbAddress ON Org.tbOrg.AddressCode = Org.tbAddress.AddressCode ON Usr.tbUser.UserId = Task.tbTask.ActionById ON 
                      Task.tbStatus.TaskStatusCode = Task.tbTask.TaskStatusCode LEFT OUTER JOIN
                      Org.tbAddress AS Org_tbAddress1 LEFT OUTER JOIN
                      Org.tbOrg AS Org_tb1 ON Org_tbAddress1.AccountCode = Org_tb1.AccountCode ON Task.tbTask.AddressCodeTo = Org_tbAddress1.AddressCode ON 
                      Org_tbAddress2.AddressCode = Task.tbTask.AddressCodeFrom LEFT OUTER JOIN
                      Org.tbContact ON Task.tbTask.ContactName = Org.tbContact.ContactName AND Task.tbTask.AccountCode = Org.tbContact.AccountCode LEFT OUTER JOIN
                      App.tbTaxCode ON Task.tbTask.TaxCode = App.tbTaxCode.TaxCode
go

CREATE VIEW Task.vwEdit
AS
SELECT        Task.tbTask.TaskCode, Task.tbTask.UserId, Task.tbTask.AccountCode, Task.tbTask.TaskTitle, Task.tbTask.ContactName, Task.tbTask.ActivityCode, Task.tbTask.TaskStatusCode, Task.tbTask.ActionById, 
                         Task.tbTask.ActionOn, Task.tbTask.ActionedOn, Task.tbTask.TaskNotes, Task.tbTask.Quantity, Task.tbTask.CashCode, Task.tbTask.TaxCode, Task.tbTask.UnitCharge, Task.tbTask.TotalCharge, 
                         Task.tbTask.AddressCodeFrom, Task.tbTask.AddressCodeTo, Task.tbTask.Printed, Task.tbTask.InsertedBy, Task.tbTask.InsertedOn, Task.tbTask.UpdatedBy, Task.tbTask.UpdatedOn, Task.tbTask.PaymentOn, 
                         Task.tbTask.SecondReference, Task.tbTask.Spooled, Activity.tbActivity.UnitOfMeasure, Task.tbStatus.TaskStatus
FROM            Task.tbTask INNER JOIN
                         Activity.tbActivity ON Task.tbTask.ActivityCode = Activity.tbActivity.ActivityCode INNER JOIN
                         Task.tbStatus ON Task.tbTask.TaskStatusCode = Task.tbStatus.TaskStatusCode;

go

CREATE VIEW Task.vwFlow
AS
SELECT        Task.tbFlow.ParentTaskCode, Task.tbFlow.StepNumber, Task.tbTask.TaskCode, Task.tbTask.ActivityCode, Task.tbTask.TaskTitle, Task.tbTask.TaskNotes, Task.tbStatus.TaskStatus, Task.tbTask.ActionOn, 
                         Task.tbTask.Quantity, Task.tbTask.ActionedOn, Org.tbOrg.AccountCode, Usr.tbUser.UserName AS Owner, tbUser_1.UserName AS ActionBy, Org.tbOrg.AccountName, Task.tbTask.UnitCharge, 
                         Task.tbTask.TotalCharge, Task.tbTask.InsertedBy, Task.tbTask.InsertedOn, Task.tbTask.UpdatedBy, Task.tbTask.UpdatedOn, Task.tbTask.TaskStatusCode
FROM            Usr.tbUser AS tbUser_1 INNER JOIN
                         Task.tbTask INNER JOIN
                         Task.tbStatus ON Task.tbTask.TaskStatusCode = Task.tbStatus.TaskStatusCode INNER JOIN
                         Usr.tbUser ON Task.tbTask.UserId = Usr.tbUser.UserId INNER JOIN
                         Org.tbOrg ON Task.tbTask.AccountCode = Org.tbOrg.AccountCode ON tbUser_1.UserId = Task.tbTask.ActionById INNER JOIN
                         Task.tbFlow ON Task.tbTask.TaskCode = Task.tbFlow.ChildTaskCode;
go

CREATE VIEW Task.vwProfit 
AS
	WITH orders AS
	(
		SELECT        task.TaskCode, task.Quantity, task.UnitCharge,
									 (SELECT        TOP (1) StartOn
									   FROM            App.tbYearPeriod AS p
									   WHERE        (StartOn <= task.ActionOn)
									   ORDER BY StartOn DESC) AS StartOn
		FROM            Task.tbFlow RIGHT OUTER JOIN
								 Task.tbTask ON Task.tbFlow.ParentTaskCode = Task.tbTask.TaskCode AND Task.tbFlow.ParentTaskCode = Task.tbTask.TaskCode AND Task.tbFlow.ParentTaskCode = Task.tbTask.TaskCode RIGHT OUTER JOIN
								 Task.tbTask AS task INNER JOIN
								 Cash.tbCode AS cashcode ON task.CashCode = cashcode.CashCode INNER JOIN
								 Cash.tbCategory AS category ON category.CategoryCode = cashcode.CategoryCode ON Task.tbFlow.ChildTaskCode = task.TaskCode AND Task.tbFlow.ChildTaskCode = task.TaskCode
		WHERE        (category.CashModeCode = 1) AND (task.TaskStatusCode BETWEEN 1 AND 3) AND 
			(task.ActionOn >= (SELECT        MIN(StartOn)
											FROM            App.tbYearPeriod p JOIN
																	  App.tbYear y ON p.YearNumber = y.YearNumber
											WHERE        y.CashStatusCode < 3)) AND	
			((Task.tbFlow.ParentTaskCode IS NULL) OR (Task.tbTask.CashCode IS NULL))

	), invoices AS
	(
		SELECT tasks.TaskCode, ISNULL(invoice.InvoiceValue, 0) AS InvoiceValue, ISNULL(invoice.InvoicePaid, 0) AS InvoicePaid 
		FROM Task.tbTask tasks LEFT OUTER JOIN 
			(
				SELECT Invoice.tbTask.TaskCode, 
					 SUM(CASE CashModeCode WHEN 0 THEN Invoice.tbTask.InvoiceValue * -1 ELSE Invoice.tbTask.InvoiceValue END) AS InvoiceValue, 
					 SUM(CASE CashModeCode WHEN 0 THEN Invoice.tbTask.PaidValue * -1 ELSE Invoice.tbTask.PaidValue END) AS InvoicePaid
				FROM Invoice.tbTask 
					INNER JOIN Invoice.tbInvoice ON Invoice.tbTask.InvoiceNumber = Invoice.tbInvoice.InvoiceNumber
					INNER JOIN Invoice.tbType ON Invoice.tbType.InvoiceTypeCode = Invoice.tbInvoice.InvoiceTypeCode 
				GROUP BY Invoice.tbTask.TaskCode
			) invoice 
		ON tasks.TaskCode = invoice.TaskCode
	), task_flow AS
	(
		SELECT orders.TaskCode, child.ParentTaskCode, child.ChildTaskCode, 
			CASE WHEN child.UsedOnQuantity <> 0 THEN orders.Quantity * child.UsedOnQuantity ELSE task.Quantity END AS Quantity
		FROM Task.tbFlow child 
			JOIN orders ON child.ParentTaskCode = orders.TaskCode
			JOIN Task.tbTask task ON child.ChildTaskCode = task.TaskCode

		UNION ALL

		SELECT parent.TaskCode, child.ParentTaskCode, child.ChildTaskCode, 
			CASE WHEN child.UsedOnQuantity <> 0 THEN parent.Quantity * child.UsedOnQuantity ELSE task.Quantity END AS Quantity
		FROM Task.tbFlow child 
			JOIN task_flow parent ON child.ParentTaskCode = parent.ChildTaskCode
			JOIN Task.tbTask task ON child.ChildTaskCode = task.TaskCode

	), tasks AS
	(
		SELECT task_flow.TaskCode, task.Quantity,
				CASE category.CashModeCode 
					WHEN NULL THEN 0 
					WHEN 0 THEN task.UnitCharge * -1 
					ELSE task.UnitCharge 
				END AS UnitCharge,
				invoices.InvoiceValue, invoices.InvoicePaid
		FROM task_flow
			JOIN Task.tbTask task ON task_flow.ChildTaskCode = task.TaskCode
			JOIN invoices ON invoices.TaskCode = task.TaskCode
			LEFT OUTER JOIN Cash.tbCode cashcode ON cashcode.CashCode = task.CashCode 
			LEFT OUTER JOIN Cash.tbCategory category ON category.CategoryCode = cashcode.CategoryCode
	)
	, task_costs AS
	(
		SELECT TaskCode, ROUND(SUM(Quantity * UnitCharge), 2) AS TotalCost, 
				ROUND(SUM(InvoiceValue), 2) AS InvoicedCost, ROUND(SUM(InvoicePaid), 2) AS InvoicedCostPaid
		FROM tasks
		GROUP BY TaskCode
		UNION
		SELECT TaskCode, 0 AS TotalCost, 0 AS InvoicedCost, 0 AS InvoicedCostPaid
		FROM orders LEFT OUTER JOIN Task.tbFlow AS flow ON orders.TaskCode = flow.ParentTaskCode
		WHERE (flow.ParentTaskCode IS NULL)
	), profits AS
	(
		SELECT orders.StartOn, task.AccountCode, orders.TaskCode, 
			yearperiod.YearNumber, yr.Description, 
			CONCAT(mn.MonthName, ' ', YEAR(yearperiod.StartOn)) AS Period,
			task.ActivityCode, cashcode.CashCode, task.TaskTitle, org.AccountName, cashcode.CashDescription,
			taskstatus.TaskStatus, task.TotalCharge, invoices.InvoiceValue AS InvoicedCharge,
			invoices.InvoicePaid AS InvoicedChargePaid,
			task_costs.TotalCost, task_costs.InvoicedCost, task_costs.InvoicedCostPaid,
			task.TotalCharge + task_costs.TotalCost AS Profit,
			task.TotalCharge - invoices.InvoiceValue AS UninvoicedCharge,
			invoices.InvoiceValue - invoices.InvoicePaid AS UnpaidCharge,
			task_costs.TotalCost - task_costs.InvoicedCost AS UninvoicedCost,
			task_costs.InvoicedCost - task_costs.InvoicedCostPaid AS UnpaidCost,
			task.ActionOn, task.ActionedOn, task.PaymentOn
		FROM orders 
			JOIN Task.tbTask task ON task.TaskCode = orders.TaskCode
			JOIN invoices ON invoices.TaskCode = task.TaskCode
			JOIN task_costs ON orders.TaskCode = task_costs.TaskCode	
			JOIN Cash.tbCode cashcode ON task.CashCode = cashcode.CashCode
			JOIN Task.tbStatus taskstatus ON taskstatus.TaskStatusCode = task.TaskStatusCode
			JOIN Org.tbOrg org ON org.AccountCode = task.AccountCode
			JOIN App.tbYearPeriod yearperiod ON yearperiod.StartOn = orders.StartOn
			JOIN App.tbYear yr ON yr.YearNumber = yearperiod.YearNumber
			JOIN App.tbMonth mn ON mn.MonthNumber = yearperiod.MonthNumber
		)
		SELECT StartOn, AccountCode, TaskCode, YearNumber, [Description], [Period], ActivityCode, CashCode,
			TaskTitle, AccountName, CashDescription, TaskStatus, TotalCharge, InvoicedCharge, InvoicedChargePaid,
			CAST(TotalCost AS MONEY) TotalCost, InvoicedCost, InvoicedCostPaid, CAST(Profit AS MONEY) Profit,
			CAST(UninvoicedCharge AS MONEY) UninvoicedCharge, CAST(UnpaidCharge AS MONEY) UnpaidCharge,
			CAST(UninvoicedCost AS MONEY) UninvoicedCost, CAST(UnpaidCost AS MONEY) UnpaidCost,
			ActionOn, ActionedOn, PaymentOn
		FROM profits;
go

CREATE VIEW Task.vwProfitToDate
AS
	WITH TaskProfitToDate AS 
		(SELECT        MAX(PaymentOn) AS LastPaymentOn
		 FROM            Task.tbTask)
	SELECT TOP (100) PERCENT App.tbYearPeriod.StartOn, App.tbYear.Description + SPACE(1) + App.tbMonth.MonthName AS Description
	FROM            TaskProfitToDate INNER JOIN
							App.tbYearPeriod INNER JOIN
							App.tbMonth ON App.tbYearPeriod.MonthNumber = App.tbMonth.MonthNumber INNER JOIN
							App.tbYear ON App.tbYearPeriod.YearNumber = App.tbYear.YearNumber ON DATEADD(m, 1, TaskProfitToDate.LastPaymentOn) > App.tbYearPeriod.StartOn
	WHERE        (App.tbYear.CashStatusCode < 3)
	ORDER BY App.tbYearPeriod.StartOn DESC;
go


CREATE VIEW Task.vwPurchaseEnquiryDeliverySpool
AS
SELECT        purchase_enquiry.TaskCode, purchase_enquiry.ContactName, Org.tbContact.NickName, Usr.tbUser.UserName, Org.tbOrg.AccountName, Org.tbAddress.Address AS InvoiceAddress, 
                         collection_account.AccountName AS CollectAccount, collection_address.Address AS CollectAddress, delivery_account.AccountName AS DeliveryAccount, delivery_address.Address AS DeliveryAddress, 
                         purchase_enquiry.AccountCode, purchase_enquiry.TaskNotes, purchase_enquiry.ActivityCode, purchase_enquiry.ActionOn, Activity.tbActivity.UnitOfMeasure, purchase_enquiry.Quantity, App.tbTaxCode.TaxCode, 
                         App.tbTaxCode.TaxRate, purchase_enquiry.UnitCharge, purchase_enquiry.TotalCharge, Usr.tbUser.MobileNumber, Usr.tbUser.Signature, purchase_enquiry.TaskTitle
FROM            Org.tbOrg AS delivery_account INNER JOIN
                         Org.tbOrg AS collection_account INNER JOIN
                         Usr.tbUser INNER JOIN
                         Activity.tbActivity INNER JOIN
                         Task.tbTask AS purchase_enquiry ON Activity.tbActivity.ActivityCode = purchase_enquiry.ActivityCode INNER JOIN
                         Org.tbOrg ON purchase_enquiry.AccountCode = Org.tbOrg.AccountCode LEFT OUTER JOIN
                         Org.tbAddress ON Org.tbOrg.AddressCode = Org.tbAddress.AddressCode ON Usr.tbUser.UserId = purchase_enquiry.ActionById INNER JOIN
                         Org.tbAddress AS delivery_address ON purchase_enquiry.AddressCodeTo = delivery_address.AddressCode LEFT OUTER JOIN
                         App.tbTaxCode ON purchase_enquiry.TaxCode = App.tbTaxCode.TaxCode LEFT OUTER JOIN
                         Org.tbContact ON purchase_enquiry.ContactName = Org.tbContact.ContactName AND purchase_enquiry.AccountCode = Org.tbContact.AccountCode INNER JOIN
                         Org.tbAddress AS collection_address ON purchase_enquiry.AddressCodeFrom = collection_address.AddressCode ON collection_account.AccountCode = collection_address.AccountCode ON 
                         delivery_account.AccountCode = delivery_address.AccountCode
WHERE EXISTS (SELECT * FROM App.tbDocSpool AS doc WHERE DocTypeCode = 2 AND UserName = SUSER_SNAME() AND purchase_enquiry.TaskCode = doc.DocumentNumber);
go

CREATE VIEW Task.vwPurchaseEnquirySpool
AS
SELECT        purchase_enquiry.TaskCode, purchase_enquiry.ContactName, Org.tbContact.NickName, Usr.tbUser.UserName, Org.tbOrg.AccountName, Org.tbAddress.Address AS InvoiceAddress, 
                         Org_tbAddress_1.Address AS DeliveryAddress, purchase_enquiry.AccountCode, purchase_enquiry.TaskNotes, purchase_enquiry.ActivityCode, purchase_enquiry.ActionOn, Activity.tbActivity.UnitOfMeasure, 
                         purchase_enquiry.Quantity, App.tbTaxCode.TaxCode, App.tbTaxCode.TaxRate, purchase_enquiry.UnitCharge, purchase_enquiry.TotalCharge, Usr.tbUser.MobileNumber, Usr.tbUser.Signature, 
                         purchase_enquiry.TaskTitle
FROM            Usr.tbUser INNER JOIN
                         Activity.tbActivity INNER JOIN
                         Task.tbTask AS purchase_enquiry ON Activity.tbActivity.ActivityCode = purchase_enquiry.ActivityCode INNER JOIN
                         Org.tbOrg ON purchase_enquiry.AccountCode = Org.tbOrg.AccountCode LEFT OUTER JOIN
                         Org.tbAddress ON Org.tbOrg.AddressCode = Org.tbAddress.AddressCode ON Usr.tbUser.UserId = purchase_enquiry.ActionById LEFT OUTER JOIN
                         Org.tbAddress AS Org_tbAddress_1 ON purchase_enquiry.AddressCodeTo = Org_tbAddress_1.AddressCode LEFT OUTER JOIN
                         App.tbTaxCode ON purchase_enquiry.TaxCode = App.tbTaxCode.TaxCode LEFT OUTER JOIN
                         Org.tbContact ON purchase_enquiry.AccountCode = Org.tbContact.AccountCode AND purchase_enquiry.ContactName = Org.tbContact.ContactName
WHERE EXISTS (SELECT * FROM App.tbDocSpool AS doc WHERE DocTypeCode = 2 AND UserName = SUSER_SNAME() AND purchase_enquiry.TaskCode = doc.DocumentNumber);
go

CREATE VIEW Task.vwPurchaseOrderDeliverySpool
AS
SELECT        purchase_order.TaskCode, purchase_order.ContactName, Org.tbContact.NickName, Usr.tbUser.UserName, Org.tbOrg.AccountName, invoice_address.Address AS InvoiceAddress, 
                         delivery_account.AccountName AS CollectAccount, delivery_address.Address AS CollectAddress, collection_account.AccountName AS DeliveryAccount, collection_address.Address AS DeliveryAddress, 
                         purchase_order.AccountCode, purchase_order.TaskNotes, purchase_order.ActivityCode, purchase_order.ActionOn, Activity.tbActivity.UnitOfMeasure, purchase_order.Quantity, App.tbTaxCode.TaxCode, 
                         App.tbTaxCode.TaxRate, purchase_order.UnitCharge, purchase_order.TotalCharge, Usr.tbUser.MobileNumber, Usr.tbUser.Signature, purchase_order.TaskTitle
FROM            Org.tbOrg AS collection_account INNER JOIN
                         Org.tbOrg AS delivery_account INNER JOIN
                         Usr.tbUser INNER JOIN
                         Activity.tbActivity INNER JOIN
                         Task.tbTask AS purchase_order ON Activity.tbActivity.ActivityCode = purchase_order.ActivityCode INNER JOIN
                         Org.tbOrg ON purchase_order.AccountCode = Org.tbOrg.AccountCode LEFT OUTER JOIN
                         Org.tbAddress AS invoice_address ON Org.tbOrg.AddressCode = invoice_address.AddressCode ON Usr.tbUser.UserId = purchase_order.ActionById INNER JOIN
                         Org.tbAddress AS collection_address ON purchase_order.AddressCodeTo = collection_address.AddressCode LEFT OUTER JOIN
                         App.tbTaxCode ON purchase_order.TaxCode = App.tbTaxCode.TaxCode LEFT OUTER JOIN
                         Org.tbContact ON purchase_order.ContactName = Org.tbContact.ContactName AND purchase_order.AccountCode = Org.tbContact.AccountCode INNER JOIN
                         Org.tbAddress AS delivery_address ON purchase_order.AddressCodeFrom = delivery_address.AddressCode ON delivery_account.AccountCode = delivery_address.AccountCode ON 
                         collection_account.AccountCode = collection_address.AccountCode
WHERE EXISTS (
	SELECT        UserName, DocTypeCode, DocumentNumber, SpooledOn
    FROM            App.tbDocSpool AS doc
    WHERE        (DocTypeCode = 3) AND (UserName = SUSER_SNAME()) AND (purchase_order.TaskCode = DocumentNumber));
go

CREATE VIEW Task.vwPurchaseOrderSpool
AS
SELECT        purchase_order.TaskCode, purchase_order.ContactName, Org.tbContact.NickName, Usr.tbUser.UserName, Org.tbOrg.AccountName, invoice_address.Address AS InvoiceAddress, 
                         delivery_address.Address AS DeliveryAddress, purchase_order.AccountCode, purchase_order.TaskNotes, purchase_order.ActivityCode, purchase_order.ActionOn, Activity.tbActivity.UnitOfMeasure, 
                         purchase_order.Quantity, App.tbTaxCode.TaxCode, App.tbTaxCode.TaxRate, purchase_order.UnitCharge, purchase_order.TotalCharge, Usr.tbUser.MobileNumber, Usr.tbUser.Signature, 
                         purchase_order.TaskTitle
FROM            Usr.tbUser INNER JOIN
                         Activity.tbActivity INNER JOIN
                         Task.tbTask AS purchase_order ON Activity.tbActivity.ActivityCode = purchase_order.ActivityCode INNER JOIN
                         Org.tbOrg ON purchase_order.AccountCode = Org.tbOrg.AccountCode LEFT OUTER JOIN
                         Org.tbAddress AS invoice_address ON Org.tbOrg.AddressCode = invoice_address.AddressCode ON Usr.tbUser.UserId = purchase_order.ActionById LEFT OUTER JOIN
                         Org.tbAddress AS delivery_address ON purchase_order.AddressCodeTo = delivery_address.AddressCode LEFT OUTER JOIN
                         App.tbTaxCode ON purchase_order.TaxCode = App.tbTaxCode.TaxCode LEFT OUTER JOIN
                         Org.tbContact ON purchase_order.AccountCode = Org.tbContact.AccountCode AND purchase_order.ContactName = Org.tbContact.ContactName
WHERE EXISTS (SELECT * FROM App.tbDocSpool AS doc WHERE DocTypeCode = 3 AND UserName = SUSER_SNAME() AND purchase_order.TaskCode = doc.DocumentNumber);
go

CREATE VIEW Task.vwQuotationSpool
AS
SELECT        sales_order.TaskCode, sales_order.ContactName, Org.tbContact.NickName, Usr.tbUser.UserName, Org.tbOrg.AccountName, invoice_address.Address AS InvoiceAddress, 
                         delivery_address.Address AS DeliveryAddress, sales_order.AccountCode, sales_order.TaskNotes, sales_order.ActivityCode, sales_order.ActionOn, Activity.tbActivity.UnitOfMeasure, sales_order.Quantity, 
                         App.tbTaxCode.TaxCode, App.tbTaxCode.TaxRate, sales_order.UnitCharge, sales_order.TotalCharge, Usr.tbUser.MobileNumber, Usr.tbUser.Signature, sales_order.TaskTitle
FROM            Usr.tbUser INNER JOIN
                         Activity.tbActivity INNER JOIN
                         Task.tbTask AS sales_order ON Activity.tbActivity.ActivityCode = sales_order.ActivityCode INNER JOIN
                         Org.tbOrg ON sales_order.AccountCode = Org.tbOrg.AccountCode LEFT OUTER JOIN
                         Org.tbAddress AS invoice_address ON Org.tbOrg.AddressCode = invoice_address.AddressCode ON Usr.tbUser.UserId = sales_order.ActionById LEFT OUTER JOIN
                         Org.tbAddress AS delivery_address ON sales_order.AddressCodeTo = delivery_address.AddressCode LEFT OUTER JOIN
                         App.tbTaxCode ON sales_order.TaxCode = App.tbTaxCode.TaxCode LEFT OUTER JOIN
                         Org.tbContact ON sales_order.AccountCode = Org.tbContact.AccountCode AND sales_order.ContactName = Org.tbContact.ContactName
WHERE EXISTS (
	SELECT        UserName, DocTypeCode, DocumentNumber, SpooledOn
    FROM            App.tbDocSpool AS doc
    WHERE        (DocTypeCode = 0) AND (UserName = SUSER_SNAME()) AND (sales_order.TaskCode = DocumentNumber));
go

CREATE VIEW Task.vwSalesOrderSpool
AS
SELECT        sales_order.TaskCode, sales_order.ContactName, Org.tbContact.NickName, Usr.tbUser.UserName, Org.tbOrg.AccountName, invoice_address.Address AS InvoiceAddress, 
                         delivery_address.Address AS DeliveryAddress, sales_order.AccountCode, sales_order.TaskNotes, sales_order.TaskTitle, sales_order.ActivityCode, sales_order.ActionOn, Activity.tbActivity.UnitOfMeasure, 
                         sales_order.Quantity, App.tbTaxCode.TaxCode, App.tbTaxCode.TaxRate, sales_order.UnitCharge, sales_order.TotalCharge, Usr.tbUser.MobileNumber, Usr.tbUser.Signature
FROM            Usr.tbUser INNER JOIN
                         Activity.tbActivity INNER JOIN
                         Task.tbTask AS sales_order ON Activity.tbActivity.ActivityCode = sales_order.ActivityCode INNER JOIN
                         Org.tbOrg ON sales_order.AccountCode = Org.tbOrg.AccountCode LEFT OUTER JOIN
                         Org.tbAddress AS invoice_address ON Org.tbOrg.AddressCode = invoice_address.AddressCode ON Usr.tbUser.UserId = sales_order.ActionById LEFT OUTER JOIN
                         Org.tbAddress AS delivery_address ON sales_order.AddressCodeTo = delivery_address.AddressCode LEFT OUTER JOIN
                         App.tbTaxCode ON sales_order.TaxCode = App.tbTaxCode.TaxCode LEFT OUTER JOIN
                         Org.tbContact ON sales_order.AccountCode = Org.tbContact.AccountCode AND sales_order.ContactName = Org.tbContact.ContactName
WHERE EXISTS (
	SELECT        UserName, DocTypeCode, DocumentNumber, SpooledOn
    FROM            App.tbDocSpool AS doc
    WHERE        (DocTypeCode = 1) AND (UserName = SUSER_SNAME()) AND (sales_order.TaskCode = DocumentNumber));
go

CREATE VIEW Task.vwTitles
AS
SELECT        ActivityCode, TaskTitle
FROM            Task.tbTask
GROUP BY TaskTitle, ActivityCode
HAVING        (TaskTitle IS NOT NULL);
go

CREATE VIEW Usr.vwDoc
AS
	WITH bank AS 
	(
		SELECT        TOP (1) (SELECT AccountCode FROM App.tbOptions) AS AccountCode, CONCAT(Org.tbOrg.AccountName, SPACE(1), Org.tbAccount.CashAccountName) AS BankAccount, Org.tbAccount.SortCode AS BankSortCode, 
															  Org.tbAccount.AccountNumber AS BankAccountNumber
									 FROM            Org.tbAccount INNER JOIN
															  Org.tbOrg ON Org.tbAccount.AccountCode = Org.tbOrg.AccountCode
									 WHERE        (NOT (Org.tbAccount.CashCode IS NULL))
	)
    SELECT        TOP (1) company.AccountName AS CompanyName, Org.tbAddress.Address AS CompanyAddress, company.PhoneNumber AS CompanyPhoneNumber, company.FaxNumber AS CompanyFaxNumber, 
                              company.EmailAddress AS CompanyEmailAddress, company.WebSite AS CompanyWebsite, company.CompanyNumber, company.VatNumber, company.Logo, bank_details.BankAccount, 
                              bank_details.BankAccountNumber, bank_details.BankSortCode
     FROM            Org.tbOrg AS company INNER JOIN
                              App.tbOptions ON company.AccountCode = App.tbOptions.AccountCode LEFT OUTER JOIN
                              bank AS bank_details ON company.AccountCode = bank_details.AccountCode LEFT OUTER JOIN
                              Org.tbAddress ON company.AddressCode = Org.tbAddress.AddressCode;
go

CREATE VIEW Usr.vwMenuItemFormMode
AS
	SELECT        OpenMode, OpenModeDescription
	FROM            Usr.tbMenuOpenMode
	WHERE        (OpenMode < 2);
go

CREATE VIEW Usr.vwMenuItemReportMode
AS
	SELECT        OpenMode, OpenModeDescription
	FROM            Usr.tbMenuOpenMode
	WHERE        (OpenMode > 1) AND (OpenMode < 5);
go

--TABLE VALUED FUNCTIONS
go
CREATE FUNCTION Cash.fnFlowBankBalances (@CashAccountCode NVARCHAR(10))
RETURNS TABLE
AS
	RETURN
	WITH account_periods AS
	(
		SELECT    @CashAccountCode AS CashAccountCode, App.tbYear.YearNumber, App.tbYearPeriod.StartOn
		FROM            App.tbYearPeriod INNER JOIN
								 App.tbYear ON App.tbYearPeriod.YearNumber = App.tbYear.YearNumber
		WHERE        (App.tbYear.CashStatusCode < 3)
	), last_entries AS
	(
		SELECT account_statement.CashAccountCode, account_statement.StartOn, MAX(account_statement.EntryNumber) As EntryNumber
		FROM Cash.vwAccountStatement account_statement 
		WHERE account_statement.CashAccountCode = @CashAccountCode
		GROUP BY account_statement.CashAccountCode, account_statement.StartOn
	), closing_balance AS
	(
		SELECT account_statement.CashAccountCode,  account_statement.StartOn, account_statement.PaidBalance 
		FROM last_entries 
			JOIN Cash.vwAccountStatement account_statement ON last_entries.CashAccountCode = account_statement.CashAccountCode
				AND last_entries.EntryNumber = account_statement.EntryNumber
	)
	SELECT account_periods.CashAccountCode, account_periods.YearNumber, account_periods.StartOn, closing_balance.PaidBalance
	FROM account_periods
		LEFT OUTER JOIN closing_balance ON account_periods.CashAccountCode = closing_balance.CashAccountCode
												AND account_periods.StartOn = closing_balance.StartOn;
go
CREATE FUNCTION Cash.fnFlowCashCodeValues(@CashCode nvarchar(50), @YearNumber smallint, @IncludeActivePeriods BIT = 0, @IncludeOrderBook BIT = 0, @IncludeTaxAccruals BIT = 0)
RETURNS TABLE
AS
	--ref Cash.proc_FlowCashCodeValues() for live implementation including accruals
   	RETURN (
		WITH invoice_history AS
		(
			SELECT        Cash.tbPeriod.CashCode, Cash.tbPeriod.StartOn, App.tbYearPeriod.CashStatusCode,
				CASE WHEN App.tbYearPeriod.CashStatusCode = 2 OR @IncludeActivePeriods <> 0 THEN Cash.tbPeriod.ForecastValue ELSE 0 END AS ForecastValue, 
				CASE WHEN App.tbYearPeriod.CashStatusCode = 2 OR @IncludeActivePeriods <> 0 THEN Cash.tbPeriod.ForecastTax ELSE 0 END AS ForecastTax, 
				CASE App.tbYearPeriod.CashStatusCode WHEN 2 THEN Cash.tbPeriod.InvoiceValue ELSE 0 END AS InvoiceValue, 
				CASE App.tbYearPeriod.CashStatusCode WHEN 2 THEN Cash.tbPeriod.InvoiceTax ELSE 0 END AS InvoiceTax
			FROM            Cash.tbPeriod INNER JOIN
									 App.tbYearPeriod ON Cash.tbPeriod.StartOn = App.tbYearPeriod.StartOn INNER JOIN
									 App.tbYear ON App.tbYearPeriod.YearNumber = App.tbYear.YearNumber
			WHERE        (App.tbYear.CashStatusCode < 3) AND (App.tbYearPeriod.YearNumber = @YearNumber) AND (Cash.tbPeriod.CashCode = @CashCode)
		), live_tasks AS
		(
			SELECT items.CashCode,
					(SELECT TOP (1) StartOn FROM App.tbYearPeriod AS p WHERE (StartOn <= invoices.InvoicedOn) ORDER BY StartOn DESC) AS StartOn,
					CASE WHEN invoice_type.CashModeCode = 0 THEN items.InvoiceValue * - 1 ELSE items.InvoiceValue END AS InvoiceValue, 
					CASE WHEN invoice_type.CashModeCode = 0 THEN items.TaxValue * - 1 ELSE items.TaxValue END AS InvoiceTax,
					0 AS ForecastValue,
					0 As ForecastTax 
			FROM Invoice.tbInvoice invoices
				JOIN Invoice.tbType invoice_type ON invoices.InvoiceTypeCode = invoice_type.InvoiceTypeCode
				JOIN Invoice.tbTask items ON invoices.InvoiceNumber = items.InvoiceNumber
			WHERE @IncludeActivePeriods <> 0 
				AND invoices.InvoicedOn >= (SELECT MIN(StartOn) FROM invoice_history WHERE CashStatusCode < 2)
				AND items.CashCode = @CashCode
		), live_items AS
		(
			SELECT items.CashCode,
					(SELECT TOP (1) StartOn FROM App.tbYearPeriod AS p WHERE (StartOn <= invoices.InvoicedOn) ORDER BY StartOn DESC) AS StartOn,
					CASE WHEN invoice_type.CashModeCode = 0 THEN items.InvoiceValue * - 1 ELSE items.InvoiceValue END AS InvoiceValue, 
					CASE WHEN invoice_type.CashModeCode = 0 THEN items.TaxValue * - 1 ELSE items.TaxValue END AS InvoiceTax,
					0 AS ForecastValue,
					0 As ForecastTax 
			FROM Invoice.tbInvoice invoices
				JOIN Invoice.tbType invoice_type ON invoices.InvoiceTypeCode = invoice_type.InvoiceTypeCode
				JOIN Invoice.tbItem items ON invoices.InvoiceNumber = items.InvoiceNumber
			WHERE @IncludeActivePeriods <> 0 
				AND invoices.InvoicedOn >= (SELECT MIN(StartOn) FROM invoice_history WHERE CashStatusCode < 2)
				AND items.CashCode = @CashCode
		), tasks AS
		(
			SELECT task.TaskCode,
					(SELECT        TOP (1) StartOn
					FROM            App.tbYearPeriod
					WHERE        (StartOn <= task.ActionOn)
					ORDER BY StartOn DESC) AS StartOn, task.TotalCharge, ISNULL(tax.TaxRate, 0) AS TaxRate
			FROM            Task.tbTask AS task INNER JOIN
										App.tbTaxCode AS tax ON task.TaxCode = tax.TaxCode
			WHERE   (@IncludeOrderBook <> 0) AND (task.CashCode = @CashCode) AND ((task.TaskStatusCode = 1) OR (task.TaskStatusCode = 2))
		), tasks_foryear AS
		(
			SELECT tasks.TaskCode, tasks.StartOn, tasks.TotalCharge, tasks.TaxRate
			FROM tasks
				JOIN invoice_history ON tasks.StartOn = invoice_history.StartOn		
		)
		, order_invoice_value AS
		(
			SELECT   invoices.TaskCode, tasks_foryear.StartOn, SUM(invoices.InvoiceValue) AS InvoiceValue, SUM(invoices.TaxValue) AS InvoiceTax
			FROM  Invoice.tbTask invoices
				JOIN tasks_foryear ON invoices.TaskCode = tasks_foryear.TaskCode 
			GROUP BY invoices.TaskCode, StartOn
		), orders AS
		(
			SELECT tasks_foryear.StartOn, 
				tasks_foryear.TotalCharge - ISNULL(order_invoice_value.InvoiceValue, 0) AS InvoiceValue,
				(tasks_foryear.TotalCharge * tasks_foryear.TaxRate) - ISNULL(order_invoice_value.InvoiceTax, 0) AS InvoiceTax
			FROM tasks_foryear LEFT OUTER JOIN order_invoice_value ON tasks_foryear.TaskCode = order_invoice_value.TaskCode
		), live_orders AS
		(
			SELECT StartOn, SUM(InvoiceValue) As InvoiceValue, SUM(InvoiceTax) As InvoiceTax, 0 AS ForecastValue, 0 As ForecastTax 
			FROM orders
			GROUP BY StartOn
		), corptax_due AS
		(
			SELECT corp_statement.StartOn, Balance AS InvoiceValue, 0 AS InvoiceTax, 0 AS ForecastValue, 0 As ForecastTax 
			FROM Cash.vwTaxCorpStatement corp_statement
				JOIN invoice_history ON invoice_history.StartOn = corp_statement.StartOn
			WHERE (@IncludeOrderBook <> 0) AND EXISTS (SELECT CashCode FROM Cash.tbTaxType WHERE CashCode = @CashCode AND TaxTypeCode = 0)			
				AND invoice_history.StartOn >= (SELECT MIN(StartOn) FROM invoice_history WHERE CashStatusCode < 2)
		), vat_balances AS
		(
			SELECT (SELECT TOP (1) StartOn FROM App.tbYearPeriod AS p WHERE (StartOn <= vat_statement.StartOn) ORDER BY StartOn DESC) AS StartOn, Balance 
			FROM Cash.vwTaxVatStatement vat_statement
			WHERE (@IncludeOrderBook <> 0) AND EXISTS (SELECT CashCode FROM Cash.tbTaxType WHERE CashCode = @CashCode AND TaxTypeCode = 1)			
				AND vat_statement.StartOn >= (SELECT MIN(StartOn) FROM invoice_history WHERE CashStatusCode < 2)
		), vat_due AS
		(
			SELECT invoice_history.StartOn, Balance AS InvoiceValue, 0 AS InvoiceTax, 0 AS ForecastValue, 0 As ForecastTax 
			FROM vat_balances
				JOIN invoice_history ON invoice_history.StartOn = vat_balances.StartOn
		)
		, resultset AS
		(
			SELECT StartOn, InvoiceValue, InvoiceTax, ForecastValue, ForecastTax FROM invoice_history
			UNION
			SELECT StartOn, InvoiceValue, InvoiceTax, ForecastValue, ForecastTax FROM live_tasks
			UNION
			SELECT StartOn, InvoiceValue, InvoiceTax, ForecastValue, ForecastTax FROM live_tasks
			UNION
			SELECT StartOn, InvoiceValue, InvoiceTax, ForecastValue, ForecastTax FROM live_orders
			UNION
			SELECT StartOn, InvoiceValue, InvoiceTax, ForecastValue, ForecastTax FROM corptax_due
			UNION
			SELECT StartOn, InvoiceValue, InvoiceTax, ForecastValue, ForecastTax FROM vat_due
		)
		SELECT StartOn, CAST(SUM(InvoiceValue) AS MONEY) AS InvoiceValue, CAST(SUM(InvoiceTax) AS MONEY) AS InvoiceTax, SUM(ForecastValue) AS ForecastValue, SUM(ForecastTax) AS ForecastTax
		FROM resultset
		GROUP BY StartOn
	)
go
CREATE FUNCTION Cash.fnFlowCategoriesByType
	(
	@CashTypeCode smallint,
	@CategoryTypeCode smallint = 1
	)
RETURNS TABLE
AS
	RETURN (
		SELECT     Cash.tbCategory.DisplayOrder, Cash.tbCategory.Category, Cash.tbType.CashType, Cash.tbCategory.CategoryCode
		FROM         Cash.tbCategory INNER JOIN
							  Cash.tbType ON Cash.tbCategory.CashTypeCode = Cash.tbType.CashTypeCode
		WHERE     ( Cash.tbCategory.CashTypeCode = @CashTypeCode) AND ( Cash.tbCategory.CategoryTypeCode = @CategoryTypeCode)
		)

go
CREATE FUNCTION Cash.fnFlowCategory(@CashTypeCode SMALLINT)
RETURNS TABLE
AS
	RETURN
	(
		SELECT        CategoryCode, Category, CategoryTypeCode, CashModeCode, CashTypeCode, DisplayOrder, IsEnabled, InsertedBy, InsertedOn, UpdatedBy, UpdatedOn, RowVer
		FROM            Cash.tbCategory
		WHERE        (CategoryTypeCode = 0) AND (CashTypeCode = @CashTypeCode) AND (IsEnabled <> 0)		
	)
go
CREATE FUNCTION Cash.fnFlowCategoryCashCodes
	(
	@CategoryCode nvarchar(10)
	)
RETURNS TABLE
AS
	RETURN (
		SELECT     CashCode, CashDescription
		FROM         Cash.tbCode
		WHERE     (CategoryCode = @CategoryCode) AND (IsEnabled <> 0)			 
	)
go
CREATE FUNCTION Cash.fnFlowCategoryTotalCodes(@CategoryCode NVARCHAR(10))
RETURNS TABLE
AS
	RETURN
	(
		SELECT ChildCode AS CategoryCode FROM Cash.tbCategoryTotal WHERE ParentCode = @CategoryCode
	)
go
CREATE FUNCTION Invoice.fnEditCreditCandidates (@InvoiceNumber nvarchar(20), @AccountCode nvarchar(10))
RETURNS TABLE
AS
	RETURN 
	(		
		WITH InvoiceEditTasks AS 
		(
			SELECT        TaskCode
			FROM            Invoice.tbTask
			WHERE        (InvoiceNumber = @InvoiceNumber)
		)
		SELECT TOP (100) PERCENT tbInvoiceTask.TaskCode, tbInvoiceTask.InvoiceNumber, tbTask.ActivityCode, Invoice.tbStatus.InvoiceStatus, Usr.tbUser.UserName, Invoice.tbInvoice.InvoicedOn, tbInvoiceTask.InvoiceValue, 
								tbTask.TaskTitle
		FROM            Usr.tbUser INNER JOIN
								Invoice.tbInvoice INNER JOIN
								Invoice.tbTask AS tbInvoiceTask ON Invoice.tbInvoice.InvoiceNumber = tbInvoiceTask.InvoiceNumber INNER JOIN
								Task.tbTask AS tbTask ON tbInvoiceTask.TaskCode = tbTask.TaskCode INNER JOIN
								Invoice.tbStatus ON Invoice.tbInvoice.InvoiceStatusCode = Invoice.tbStatus.InvoiceStatusCode ON Usr.tbUser.UserId = Invoice.tbInvoice.UserId LEFT OUTER JOIN
								InvoiceEditTasks AS InvoiceEditTasks ON tbTask.TaskCode = InvoiceEditTasks.TaskCode
		WHERE        (Invoice.tbInvoice.AccountCode = @AccountCode) AND (Invoice.tbInvoice.InvoiceTypeCode = 0) AND (InvoiceEditTasks.TaskCode IS NULL)
		ORDER BY Invoice.tbInvoice.InvoicedOn DESC
	);
go
CREATE FUNCTION Invoice.fnEditDebitCandidates (@InvoiceNumber nvarchar(20), @AccountCode nvarchar(10))
RETURNS TABLE
AS
	RETURN 
	(		
		WITH InvoiceEditTasks AS 
		(
			SELECT        TaskCode
			FROM            Invoice.tbTask
			WHERE        (InvoiceNumber = @InvoiceNumber)
		)
		SELECT TOP (100) PERCENT tbInvoiceTask.TaskCode, tbInvoiceTask.InvoiceNumber, tbTask.ActivityCode, Invoice.tbStatus.InvoiceStatus, Usr.tbUser.UserName, Invoice.tbInvoice.InvoicedOn, tbInvoiceTask.InvoiceValue, 
								tbTask.TaskTitle
		FROM            Usr.tbUser INNER JOIN
								Invoice.tbInvoice INNER JOIN
								Invoice.tbTask AS tbInvoiceTask ON Invoice.tbInvoice.InvoiceNumber = tbInvoiceTask.InvoiceNumber INNER JOIN
								Task.tbTask ON tbInvoiceTask.TaskCode = tbTask.TaskCode INNER JOIN
								Invoice.tbStatus ON Invoice.tbInvoice.InvoiceStatusCode = Invoice.tbStatus.InvoiceStatusCode ON Usr.tbUser.UserId = Invoice.tbInvoice.UserId LEFT OUTER JOIN
								InvoiceEditTasks  ON tbTask.TaskCode = InvoiceEditTasks.TaskCode
		WHERE        (Invoice.tbInvoice.AccountCode = @AccountCode) AND (Invoice.tbInvoice.InvoiceTypeCode = 2) AND (InvoiceEditTasks.TaskCode IS NULL)
		ORDER BY Invoice.tbInvoice.InvoicedOn DESC
	);
go
CREATE FUNCTION Invoice.fnEditTasks (@InvoiceNumber nvarchar(20), @AccountCode nvarchar(10))
RETURNS TABLE
AS
	RETURN 
	(		
		WITH InvoiceEditTasks AS 
		(	SELECT        TaskCode
			FROM            Invoice.tbTask
			WHERE        (InvoiceNumber = @InvoiceNumber)
		)
		SELECT TOP (100) PERCENT Task.tbTask.TaskCode, Task.tbTask.ActivityCode, Task.tbStatus.TaskStatus, Usr.tbUser.UserName, Task.tbTask.ActionOn, Task.tbTask.ActionedOn, Task.tbTask.TaskTitle
		FROM            Usr.tbUser INNER JOIN
								Task.tbTask INNER JOIN
								Task.tbStatus ON Task.tbTask.TaskStatusCode = Task.tbStatus.TaskStatusCode ON Usr.tbUser.UserId = Task.tbTask.ActionById LEFT OUTER JOIN
								InvoiceEditTasks ON Task.tbTask.TaskCode = InvoiceEditTasks.TaskCode
		WHERE        (Task.tbTask.AccountCode = @AccountCode) AND (Task.tbTask.TaskStatusCode = 1 OR
								Task.tbTask.TaskStatusCode = 2) AND (Task.tbTask.CashCode IS NOT NULL) AND (InvoiceEditTasks.TaskCode IS NULL)
		ORDER BY Task.tbTask.ActionOn DESC
	);
go

/********** STORED PROCEDURES *****************/
go
CREATE PROCEDURE App.proc_EventLog (@EventMessage NVARCHAR(MAX), @EventTypeCode SMALLINT = 0, @LogCode NVARCHAR(20) = NULL OUTPUT)
AS
	SET XACT_ABORT, NOCOUNT ON;

	BEGIN TRY

		DECLARE 
			@UserId nvarchar(10)
			, @LogNumber INT
			, @RegisterName nvarchar(50) = (SELECT RegisterName FROM App.tbOptions);
	
		SET @UserId = (SELECT TOP 1 Usr.tbUser.UserId FROM Usr.vwCredentials c INNER JOIN
								Usr.tbUser ON c.UserId = Usr.tbUser.UserId);

		BEGIN TRANSACTION;
		
		WHILE (1 = 1)
			BEGIN
			SET @LogNumber = FORMAT((SELECT TOP 1 r.NextNumber
						FROM App.tbRegister r
						WHERE r.RegisterName = @RegisterName), '00000');
				
			UPDATE App.tbRegister
			SET NextNumber += 1
			WHERE RegisterName = @RegisterName;

			SET @LogCode = CONCAT(@UserId, @LogNumber);

			IF NOT EXISTS (SELECT * FROM App.tbEventLog WHERE LogCode = @LogCode)
				BREAK;
			END

		INSERT INTO App.tbEventLog (LogCode, EventTypeCode, EventMessage)
		VALUES (@LogCode, @EventTypeCode, @EventMessage);

		COMMIT TRANSACTION;

		RETURN;
					
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0 
			ROLLBACK TRANSACTION;
		THROW;
	END CATCH

go

CREATE PROCEDURE App.proc_ErrorLog 
AS
DECLARE 
	@ErrorMessage NVARCHAR(MAX)
	, @ErrorSeverity TINYINT
	, @ErrorState TINYINT
	, @MessagePrefix nvarchar(4) = '*** ';
	
	IF @@TRANCOUNT > 0 
		ROLLBACK TRANSACTION;

	SET @ErrorSeverity = ERROR_SEVERITY();
	SET @ErrorState = ERROR_STATE();
	SET @ErrorMessage = ERROR_MESSAGE();

	IF @ErrorMessage NOT LIKE CONCAT(@MessagePrefix, '%')
		BEGIN
		SET @ErrorMessage = CONCAT(@MessagePrefix, ERROR_NUMBER(), ': ', QUOTENAME(ERROR_PROCEDURE()) + '.' + FORMAT(ERROR_LINE(), '0'),
			' Severity ', @ErrorSeverity, ', State ', @ErrorState, ' => ' + LEFT(ERROR_MESSAGE(), 1500));		

		EXEC App.proc_EventLog @ErrorMessage;
		END

	RAISERROR ('%s', @ErrorSeverity, @ErrorState, @ErrorMessage);
go

CREATE PROCEDURE Activity.proc_Mode
	(
	@ActivityCode nvarchar(50)
	)
  AS
   	SET NOCOUNT, XACT_ABORT ON;

	BEGIN TRY
		SELECT     Activity.tbActivity.ActivityCode, Activity.tbActivity.UnitOfMeasure, Task.tbStatus.TaskStatus, ISNULL(Cash.tbCategory.CashModeCode, 2) AS CashModeCode
		FROM         Activity.tbActivity INNER JOIN
							  Task.tbStatus ON Activity.tbActivity.TaskStatusCode = Task.tbStatus.TaskStatusCode LEFT OUTER JOIN
							  Cash.tbCode ON Activity.tbActivity.CashCode = Cash.tbCode.CashCode LEFT OUTER JOIN
							  Cash.tbCategory ON Cash.tbCode.CategoryCode = Cash.tbCategory.CategoryCode
		WHERE     ( Activity.tbActivity.ActivityCode = @ActivityCode)
		 
  	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
go
CREATE PROCEDURE Activity.proc_NextAttributeOrder 
	(
	@ActivityCode nvarchar(50),
	@PrintOrder smallint = 10 output
	)
  AS
    SET NOCOUNT, XACT_ABORT ON;

	BEGIN TRY
		IF EXISTS(SELECT     TOP 1 PrintOrder
				  FROM         Activity.tbAttribute
				  WHERE     (ActivityCode = @ActivityCode))
			BEGIN
			SELECT  @PrintOrder = MAX(PrintOrder) 
			FROM         Activity.tbAttribute
			WHERE     (ActivityCode = @ActivityCode)
			SET @PrintOrder = @PrintOrder - (@PrintOrder % 10) + 10		
			END
		ELSE
			SET @PrintOrder = 10
		
		
  	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
go

CREATE PROCEDURE Activity.proc_NextOperationNumber 
	(
	@ActivityCode nvarchar(50),
	@OperationNumber smallint = 10 output
	)
AS
    SET NOCOUNT, XACT_ABORT ON;

	BEGIN TRY
		IF EXISTS(SELECT     TOP 1 OperationNumber
				  FROM         Activity.tbOp
				  WHERE     (ActivityCode = @ActivityCode))
			BEGIN
			SELECT  @OperationNumber = MAX(OperationNumber) 
			FROM         Activity.tbOp
			WHERE     (ActivityCode = @ActivityCode)
			SET @OperationNumber = @OperationNumber - (@OperationNumber % 10) + 10		
			END
		ELSE
			SET @OperationNumber = 10
		
		
  	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
go
CREATE PROCEDURE Activity.proc_NextStepNumber 
	(
	@ActivityCode nvarchar(50),
	@StepNumber smallint = 10 output
	)
AS
    SET NOCOUNT, XACT_ABORT ON;

	BEGIN TRY
		IF EXISTS(SELECT     TOP 1 StepNumber
				  FROM         Activity.tbFlow
				  WHERE     (ParentCode = @ActivityCode))
			BEGIN
			SELECT  @StepNumber = MAX(StepNumber) 
			FROM         Activity.tbFlow
			WHERE     (ParentCode = @ActivityCode)
			SET @StepNumber = @StepNumber - (@StepNumber % 10) + 10		
			END
		ELSE
			SET @StepNumber = 10
		
		
  	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
go

CREATE PROCEDURE Activity.proc_Parent
	(
	@ActivityCode nvarchar(50),
	@ParentCode nvarchar(50) = null output
	)
AS
    SET NOCOUNT, XACT_ABORT ON;

	BEGIN TRY
		SET @ParentCode = @ActivityCode;
		
		IF EXISTS(SELECT ParentCode FROM Activity.tbFlow WHERE (ParentCode = @ActivityCode))
			OR NOT EXISTS(SELECT COUNT(*) FROM Activity.tbFlow WHERE ChildCode = @ActivityCode GROUP BY ChildCode HAVING COUNT(*) > 1)
		BEGIN		
			WHILE EXISTS (SELECT COUNT(*) FROM Activity.tbFlow WHERE ChildCode = @ParentCode GROUP BY ChildCode HAVING COUNT(*) = 1)
				SELECT @ParentCode = ParentCode, @ActivityCode = ParentCode 
				FROM Activity.tbFlow		
				WHERE ChildCode = @ActivityCode;	 
		END
  	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
go

CREATE PROCEDURE Activity.proc_WorkFlow
	(
	@ParentActivityCode nvarchar(50),
	@ActivityCode nvarchar(50)
	)
AS
    SET NOCOUNT, XACT_ABORT ON;

	BEGIN TRY

		IF EXISTS(SELECT * FROM Activity.tbFlow WHERE (ParentCode = @ParentActivityCode))
			AND NOT EXISTS(SELECT COUNT(*) FROM Activity.tbFlow WHERE ChildCode = @ParentActivityCode GROUP BY ChildCode HAVING COUNT(*) > 1)			
		BEGIN
			SELECT     Activity.tbActivity.ActivityCode, Task.tbStatus.TaskStatus, ISNULL(Cash.tbCategory.CashModeCode, 2) AS CashModeCode, Activity.tbActivity.UnitOfMeasure, Activity.tbFlow.OffsetDays, Activity.tbFlow.UsedOnQuantity
			FROM         Activity.tbActivity INNER JOIN
								  Task.tbStatus ON Activity.tbActivity.TaskStatusCode = Task.tbStatus.TaskStatusCode INNER JOIN
								  Activity.tbFlow ON Activity.tbActivity.ActivityCode = Activity.tbFlow.ChildCode LEFT OUTER JOIN
								  Cash.tbCode ON Activity.tbActivity.CashCode = Cash.tbCode.CashCode LEFT OUTER JOIN
								  Cash.tbCategory ON Cash.tbCode.CategoryCode = Cash.tbCategory.CategoryCode
			WHERE     ( Activity.tbFlow.ParentCode = @ActivityCode)
			ORDER BY Activity.tbFlow.StepNumber	
		END
		ELSE
		BEGIN
			SELECT     Activity.tbActivity.ActivityCode, Task.tbStatus.TaskStatus, ISNULL(Cash.tbCategory.CashModeCode, 2) AS CashModeCode, Activity.tbActivity.UnitOfMeasure, Activity.tbFlow.OffsetDays, Activity.tbFlow.UsedOnQuantity
			FROM         Activity.tbActivity INNER JOIN
								  Task.tbStatus ON Activity.tbActivity.TaskStatusCode = Task.tbStatus.TaskStatusCode INNER JOIN
								  Activity.tbFlow ON Activity.tbActivity.ActivityCode = Activity.tbFlow.ParentCode LEFT OUTER JOIN
								  Cash.tbCode ON Activity.tbActivity.CashCode = Cash.tbCode.CashCode LEFT OUTER JOIN
								  Cash.tbCategory ON Cash.tbCode.CategoryCode = Cash.tbCategory.CategoryCode
			WHERE     ( Activity.tbFlow.ChildCode = @ActivityCode)
			ORDER BY Activity.tbFlow.StepNumber	
		END
			 
  	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
go
CREATE PROCEDURE Activity.proc_WorkFlowMultiLevel
	(
	@ActivityCode nvarchar(50)
	)
AS
    SET NOCOUNT, XACT_ABORT ON;

	BEGIN TRY

		IF EXISTS(SELECT * FROM Activity.tbFlow WHERE (ParentCode = @ActivityCode))
		BEGIN
			WITH workflow AS
			(
				SELECT  parent_flow.ParentCode, parent_flow.ChildCode, parent_flow.OffsetDays, parent_flow.UsedOnQuantity, 1 AS Depth
				FROM Activity.tbFlow parent_flow
				WHERE (parent_flow.ParentCode = @ActivityCode)

				UNION ALL

				SELECT  child_flow.ParentCode, child_flow.ChildCode, child_flow.OffsetDays, child_flow.UsedOnQuantity, workflow.Depth + 1 AS Depth
				FROM workflow 
					JOIN Activity.tbFlow child_flow ON workflow.ChildCode = child_flow.ParentCode
			)
			SELECT workflow.ParentCode, workflow.ChildCode,
						task_status.TaskStatus, ISNULL(cash_category.CashModeCode, 2) AS CashModeCode,
						activity.UnitOfMeasure, workflow.OffsetDays, workflow.UsedOnQuantity, Depth
			FROM workflow
					JOIN Activity.tbActivity activity ON workflow.ChildCode = activity.ActivityCode
					JOIN Task.tbStatus task_status ON activity.TaskStatusCode = task_status.TaskStatusCode 
					LEFT OUTER JOIN Cash.tbCode cash_code ON activity.CashCode = cash_code.CashCode 
					LEFT OUTER JOIN Cash.tbCategory cash_category ON cash_code.CategoryCode = cash_category.CategoryCode
			ORDER BY Depth, ParentCode, ChildCode;
		END
		ELSE
		BEGIN
			WITH workflow AS
			(
				SELECT  child_flow.ParentCode, child_flow.ChildCode, child_flow.OffsetDays, child_flow.UsedOnQuantity, -1 AS Depth
				FROM Activity.tbFlow child_flow
				WHERE (child_flow.ChildCode = @ActivityCode)

				UNION ALL

				SELECT  parent_flow.ParentCode, parent_flow.ChildCode, parent_flow.OffsetDays, parent_flow.UsedOnQuantity, workflow.Depth - 1 AS Depth
				FROM workflow 
					JOIN Activity.tbFlow parent_flow ON workflow.ParentCode = parent_flow.ChildCode
			)
			SELECT workflow.ChildCode AS ParentCode, workflow.ParentCode AS ChildCode, 
						task_status.TaskStatus, ISNULL(cash_category.CashModeCode, 2) AS CashModeCode,
						activity.UnitOfMeasure, workflow.OffsetDays, workflow.UsedOnQuantity, Depth
			FROM workflow
					JOIN Activity.tbActivity activity ON workflow.ParentCode = activity.ActivityCode
					JOIN Task.tbStatus task_status ON activity.TaskStatusCode = task_status.TaskStatusCode 
					LEFT OUTER JOIN Cash.tbCode cash_code ON activity.CashCode = cash_code.CashCode 
					LEFT OUTER JOIN Cash.tbCategory cash_category ON cash_code.CategoryCode = cash_category.CategoryCode
			ORDER BY Depth DESC, ParentCode, ChildCode;		
		END
			 
  	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
go

CREATE PROCEDURE App.proc_AddCalDateRange
	(
		@CalendarCode nvarchar(10),
		@FromDate datetime,
		@ToDate datetime
	)
AS
	SET NOCOUNT, XACT_ABORT ON;

	BEGIN TRY
		DECLARE @UnavailableDate datetime

		SELECT @UnavailableDate = @FromDate
	
		BEGIN TRANSACTION

		WHILE @UnavailableDate <= @ToDate
		BEGIN
			INSERT INTO App.tbCalendarHoliday (CalendarCode, UnavailableOn)
			VALUES (@CalendarCode, @UnavailableDate)
			SELECT @UnavailableDate = DateAdd(d, 1, @UnavailableDate)
		END

		COMMIT TRANSACTION

		
  	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
go

CREATE PROCEDURE App.proc_AdjustToCalendar
	(
	@SourceDate datetime,
	@OffsetDays int,
	@OutputDate datetime output
	)
AS
	SET NOCOUNT, XACT_ABORT ON;

	BEGIN TRY
		DECLARE 
			@CalendarCode nvarchar(10)
			, @WorkingDay bit
			, @UserId nvarchar(10)
	
		DECLARE
			 @CurrentDay smallint
			, @Monday smallint
			, @Tuesday smallint
			, @Wednesday smallint
			, @Thursday smallint
			, @Friday smallint
			, @Saturday smallint
			, @Sunday smallint
		
		SELECT @UserId = UserId
		FROM         Usr.vwCredentials	

		SET @OutputDate = @SourceDate

		SELECT     @CalendarCode = App.tbCalendar.CalendarCode, @Monday = Monday, @Tuesday = Tuesday, @Wednesday = Wednesday, @Thursday = Thursday, @Friday = Friday, @Saturday = Saturday, @Sunday = Sunday
		FROM         App.tbCalendar INNER JOIN
							  Usr.tbUser ON App.tbCalendar.CalendarCode = Usr.tbUser.CalendarCode
		WHERE UserId = @UserId
	
		WHILE @OffsetDays > -1
			BEGIN
			SET @CurrentDay = App.fnWeekDay(@OutputDate)
			IF @CurrentDay = 1				
				SET @WorkingDay = CASE WHEN @Monday != 0 THEN 1 ELSE 0 END
			ELSE IF @CurrentDay = 2
				SET @WorkingDay = CASE WHEN @Tuesday != 0 THEN 1 ELSE 0 END
			ELSE IF @CurrentDay = 3
				SET @WorkingDay = CASE WHEN @Wednesday != 0 THEN 1 ELSE 0 END
			ELSE IF @CurrentDay = 4
				SET @WorkingDay = CASE WHEN @Thursday != 0 THEN 1 ELSE 0 END
			ELSE IF @CurrentDay = 5
				SET @WorkingDay = CASE WHEN @Friday != 0 THEN 1 ELSE 0 END
			ELSE IF @CurrentDay = 6
				SET @WorkingDay = CASE WHEN @Saturday != 0 THEN 1 ELSE 0 END
			ELSE IF @CurrentDay = 7
				SET @WorkingDay = CASE WHEN @Sunday != 0 THEN 1 ELSE 0 END
		
			IF @WorkingDay = 1
				BEGIN
				IF NOT EXISTS(SELECT     UnavailableOn
							FROM         App.tbCalendarHoliday
							WHERE     (CalendarCode = @CalendarCode) AND (UnavailableOn = @OutputDate))
					SET @OffsetDays -= 1
				END
			
			IF @OffsetDays > -1
				SET @OutputDate = DATEADD(d, -1, @OutputDate)
			END
					
		

	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH

go

CREATE PROCEDURE App.proc_CompanyName
	(
	@AccountName nvarchar(255) = null output
	)
  AS
	SELECT TOP 1 @AccountName = Org.tbOrg.AccountName
	FROM         Org.tbOrg INNER JOIN
	                      App.tbOptions ON Org.tbOrg.AccountCode = App.tbOptions.AccountCode
	 
go

CREATE PROCEDURE App.proc_DelCalDateRange
	(
		@CalendarCode nvarchar(10),
		@FromDate datetime,
		@ToDate datetime
	)
AS
	SET NOCOUNT, XACT_ABORT ON;

	BEGIN TRY
		DELETE FROM App.tbCalendarHoliday
			WHERE UnavailableOn >= @FromDate
				AND UnavailableOn <= @ToDate
				AND CalendarCode = @CalendarCode
	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
go

CREATE PROCEDURE App.proc_DocDespool
	(
	@DocTypeCode SMALLINT
	)
AS
	SET NOCOUNT, XACT_ABORT ON;

	BEGIN TRY
		IF @DocTypeCode = 0
		--Quotations:
			UPDATE       Task.tbTask
			SET           Spooled = 0, Printed = 1
			FROM            Task.tbTask INNER JOIN
									 Cash.tbCode ON Task.tbTask.CashCode = Cash.tbCode.CashCode INNER JOIN
									 Cash.tbCategory ON Cash.tbCode.CategoryCode = Cash.tbCategory.CategoryCode
			WHERE        ( Task.tbTask.TaskStatusCode = 0) AND ( Cash.tbCategory.CashModeCode = 1) AND ( Task.tbTask.Spooled <> 0)
		ELSE IF @DocTypeCode = 1
		--SalesOrder:
			UPDATE       Task.tbTask
			SET           Spooled = 0, Printed = 1
			FROM            Task.tbTask INNER JOIN
									 Cash.tbCode ON Task.tbTask.CashCode = Cash.tbCode.CashCode INNER JOIN
									 Cash.tbCategory ON Cash.tbCode.CategoryCode = Cash.tbCategory.CategoryCode
			WHERE        ( Task.tbTask.TaskStatusCode > 0) AND ( Cash.tbCategory.CashModeCode = 1) AND ( Task.tbTask.Spooled <> 0)
		ELSE IF @DocTypeCode = 2
		--PurchaseEnquiry:
			UPDATE       Task.tbTask
			SET           Spooled = 0, Printed = 1
			FROM            Task.tbTask INNER JOIN
									 Cash.tbCode ON Task.tbTask.CashCode = Cash.tbCode.CashCode INNER JOIN
									 Cash.tbCategory ON Cash.tbCode.CategoryCode = Cash.tbCategory.CategoryCode
			WHERE        ( Task.tbTask.TaskStatusCode = 0) AND ( Cash.tbCategory.CashModeCode = 0) AND ( Task.tbTask.Spooled <> 0)	
		ELSE IF @DocTypeCode = 3
		--PurchaseOrder:
			UPDATE       Task.tbTask
			SET           Spooled = 0, Printed = 1
			FROM            Task.tbTask INNER JOIN
									 Cash.tbCode ON Task.tbTask.CashCode = Cash.tbCode.CashCode INNER JOIN
									 Cash.tbCategory ON Cash.tbCode.CategoryCode = Cash.tbCategory.CategoryCode
			WHERE        ( Task.tbTask.TaskStatusCode > 0) AND ( Cash.tbCategory.CashModeCode = 0) AND ( Task.tbTask.Spooled <> 0)
		ELSE IF @DocTypeCode = 4
		--SalesInvoice:
			UPDATE       Invoice.tbInvoice
			SET                Spooled = 0, Printed = 1
			WHERE        (InvoiceTypeCode = 0) AND (Spooled <> 0)
		ELSE IF @DocTypeCode = 5
		--CreditNote:
			UPDATE       Invoice.tbInvoice
			SET                Spooled = 0, Printed = 1
			WHERE        (InvoiceTypeCode = 1) AND (Spooled <> 0)
		ELSE IF @DocTypeCode = 6
		--DebitNote:
			UPDATE       Invoice.tbInvoice
			SET                Spooled = 0, Printed = 1
			WHERE        (InvoiceTypeCode = 3) AND (Spooled <> 0)
	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
go

CREATE PROCEDURE App.proc_Initialised
(@Setting bit)
  AS
	SET NOCOUNT, XACT_ABORT ON;

	BEGIN TRY
		IF @Setting = 1
			AND (EXISTS (SELECT     Org.tbOrg.AccountCode
						FROM         Org.tbOrg INNER JOIN
											  App.tbOptions ON Org.tbOrg.AccountCode = App.tbOptions.AccountCode)
			OR EXISTS (SELECT     Org.tbAddress.AddressCode
						   FROM         Org.tbOrg INNER JOIN
												 App.tbOptions ON Org.tbOrg.AccountCode = App.tbOptions.AccountCode INNER JOIN
												 Org.tbAddress ON Org.tbOrg.AddressCode = Org.tbAddress.AddressCode)
			OR EXISTS (SELECT     TOP 1 UserId
							   FROM         Usr.tbUser))
			BEGIN
			UPDATE App.tbOptions Set IsInitialised = 1
			RETURN
			END
		ELSE
			BEGIN
			UPDATE App.tbOptions Set IsInitialised = 0
			RETURN 1
			END
 	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
go

CREATE PROCEDURE Cash.proc_GeneratePeriods
AS
 	SET NOCOUNT, XACT_ABORT ON;

	BEGIN TRY
	DECLARE 
		@YearNumber smallint
		, @StartOn datetime
		, @PeriodStartOn datetime
		, @CashStatusCode smallint
		, @Period smallint
	
		DECLARE curYr cursor for	
			SELECT     YearNumber, CAST(CONCAT(FORMAT(YearNumber, '0000'), FORMAT(StartMonth, '00'), FORMAT(1, '00')) AS DATE) AS StartOn, CashStatusCode
			FROM         App.tbYear
			WHERE CashStatusCode < 2

		OPEN curYr
	
		FETCH NEXT FROM curYr INTO @YearNumber, @StartOn, @CashStatusCode
		WHILE @@FETCH_STATUS = 0
			BEGIN
			SET @PeriodStartOn = @StartOn
			SET @Period = 1
			WHILE @Period < 13
				BEGIN
				IF not EXISTS (SELECT MonthNumber FROM App.tbYearPeriod WHERE YearNumber = @YearNumber and MonthNumber = DATEPART(m, @PeriodStartOn))
					BEGIN
					INSERT INTO App.tbYearPeriod (YearNumber, StartOn, MonthNumber, CashStatusCode)
					VALUES (@YearNumber, @PeriodStartOn, DATEPART(m, @PeriodStartOn), 0)				
					END
				SET @PeriodStartOn = DATEADD(m, 1, @PeriodStartOn)	
				SET @Period = @Period + 1
				END		
				
			FETCH NEXT FROM curYr INTO @YearNumber, @StartOn, @CashStatusCode
			END
	
		CLOSE curYr
		DEALLOCATE curYr
	
		INSERT INTO Cash.tbPeriod
							  (CashCode, StartOn)
		SELECT     Cash.vwPeriods.CashCode, Cash.vwPeriods.StartOn
		FROM         Cash.vwPeriods LEFT OUTER JOIN
							  Cash.tbPeriod ON Cash.vwPeriods.CashCode = Cash.tbPeriod.CashCode AND Cash.vwPeriods.StartOn = Cash.tbPeriod.StartOn
		WHERE     ( Cash.tbPeriod.CashCode IS NULL)
		 
  	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
go

CREATE PROCEDURE App.proc_PeriodClose
AS
 	SET NOCOUNT, XACT_ABORT ON;

	BEGIN TRY
		IF EXISTS(SELECT * FROM App.fnActivePeriod())
			BEGIN
			DECLARE @StartOn datetime, @YearNumber smallint

			SELECT @StartOn = StartOn, @YearNumber = YearNumber
			FROM App.fnActivePeriod() fnSystemActivePeriod
		 	
			EXEC Cash.proc_GeneratePeriods

			BEGIN TRAN

			UPDATE       Cash.tbPeriod
			SET                InvoiceValue = 0, InvoiceTax = 0
			FROM            Cash.tbPeriod 
			WHERE        (Cash.tbPeriod.StartOn = @StartOn);

			WITH invoice_summary AS
			(
				SELECT        Invoice.vwRegisterDetail.CashCode, Invoice.vwRegisterDetail.StartOn, ABS(SUM(Invoice.vwRegisterDetail.InvoiceValue)) AS InvoiceValue, ABS(SUM(Invoice.vwRegisterDetail.TaxValue)) AS TaxValue
				FROM            Invoice.vwRegisterDetail 
						JOIN Cash.tbCode ON Invoice.vwRegisterDetail.CashCode = Cash.tbCode.CashCode 
						JOIN Cash.tbCategory ON Cash.tbCode.CategoryCode = Cash.tbCategory.CategoryCode
				WHERE Invoice.vwRegisterDetail.StartOn = @StartOn
				GROUP BY Invoice.vwRegisterDetail.StartOn, Invoice.vwRegisterDetail.CashCode
			)
			UPDATE Cash.tbPeriod
			SET InvoiceValue = invoice_summary.InvoiceValue, 
				InvoiceTax = invoice_summary.TaxValue
			FROM    Cash.tbPeriod 
				JOIN invoice_summary ON Cash.tbPeriod.CashCode = invoice_summary.CashCode AND Cash.tbPeriod.StartOn = invoice_summary.StartOn;
	
			UPDATE App.tbYearPeriod
			SET CashStatusCode = 2
			WHERE StartOn = @StartOn			
		
			IF NOT EXISTS (SELECT     CashStatusCode
						FROM         App.tbYearPeriod
						WHERE     (YearNumber = @YearNumber) AND (CashStatusCode < 2)) 
				BEGIN
				UPDATE App.tbYear
				SET CashStatusCode = 2
				WHERE YearNumber = @YearNumber	
				END
			IF EXISTS(SELECT * FROM App.fnActivePeriod())
				BEGIN
				UPDATE App.tbYearPeriod
				SET CashStatusCode = 1
				FROM App.fnActivePeriod() fnSystemActivePeriod INNER JOIN
									App.tbYearPeriod ON fnSystemActivePeriod.YearNumber = App.tbYearPeriod.YearNumber AND fnSystemActivePeriod.MonthNumber = App.tbYearPeriod.MonthNumber
			
				END		
			IF EXISTS(SELECT * FROM App.fnActivePeriod())
				BEGIN
				UPDATE App.tbYear
				SET CashStatusCode = 1
				FROM App.fnActivePeriod() fnSystemActivePeriod INNER JOIN
									App.tbYear ON fnSystemActivePeriod.YearNumber = App.tbYear.YearNumber  
				END

			COMMIT TRAN

			END
					
  	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
go

CREATE PROCEDURE App.proc_PeriodGetYear
	(
	@StartOn DATETIME,
	@YearNumber INTEGER OUTPUT
	)
AS
 	SET NOCOUNT, XACT_ABORT ON;

	BEGIN TRY
		SELECT @YearNumber = YearNumber
		FROM            App.tbYearPeriod
		WHERE        (StartOn = @StartOn)
	
		IF @YearNumber IS NULL
			SELECT @YearNumber = YearNumber FROM App.fnActivePeriod()
		
  	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH	 
go

CREATE PROCEDURE App.proc_ReassignUser 
	(
	@UserId nvarchar(10)
	)
  AS
   	SET NOCOUNT, XACT_ABORT ON;

	BEGIN TRY
		UPDATE    Usr.tbUser
		SET       LogonName = (SUSER_SNAME())
		WHERE     (UserId = @UserId)
	
   	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
go

CREATE PROCEDURE App.proc_SystemRebuild
AS
  	SET NOCOUNT, XACT_ABORT ON;

	DECLARE @tbPartialInvoice TABLE (
			AccountCode NVARCHAR(10), 
			InvoiceNumber NVARCHAR(10),
			RefType SMALLINT,
			RefCode NVARCHAR(20),
			TotalPaidValue MONEY
			);

	BEGIN TRY
		BEGIN TRANSACTION;

		UPDATE Task.tbFlow
		SET UsedOnQuantity = task.Quantity / parent_task.Quantity
		FROM            Task.tbFlow AS flow 
			JOIN Task.tbTask AS task ON flow.ChildTaskCode = task.TaskCode 
			JOIN Task.tbTask AS parent_task ON flow.ParentTaskCode = parent_task.TaskCode
			JOIN Cash.tbCode ON parent_task.CashCode = Cash.tbCode.CashCode
		WHERE        (flow.UsedOnQuantity <> 0) AND (task.Quantity <> 0) 
			AND (task.Quantity / parent_task.Quantity <> flow.UsedOnQuantity);

		WITH parent_task AS
		(
			SELECT        ParentTaskCode
			FROM            Task.tbFlow flow
				JOIN Task.tbTask task ON flow.ParentTaskCode = task.TaskCode
				JOIN Cash.tbCode cash ON task.CashCode = cash.CashCode
		), task_flow AS
		(
			SELECT        flow.ParentTaskCode, flow.StepNumber, task.ActionOn,
					LAG(task.ActionOn, 1, task.ActionOn) OVER (PARTITION BY flow.ParentTaskCode ORDER BY StepNumber) AS PrevActionOn
			FROM Task.tbFlow flow
				JOIN Task.tbTask task ON flow.ChildTaskCode = task.TaskCode
				JOIN parent_task ON flow.ParentTaskCode = parent_task.ParentTaskCode
		), step_disordered AS
		(
			SELECT ParentTaskCode 
			FROM task_flow
			WHERE ActionOn < PrevActionOn
			GROUP BY ParentTaskCode
		), step_ordered AS
		(
			SELECT flow.ParentTaskCode, flow.ChildTaskCode,
				ROW_NUMBER() OVER (PARTITION BY flow.ParentTaskCode ORDER BY task.ActionOn, flow.StepNumber) * 10 AS StepNumber 
			FROM step_disordered
				JOIN Task.tbFlow flow ON step_disordered.ParentTaskCode = flow.ParentTaskCode
				JOIN Task.tbTask task ON flow.ChildTaskCode = task.TaskCode
		)
		UPDATE flow
		SET
			StepNumber = step_ordered.StepNumber
		FROM Task.tbFlow flow
			JOIN step_ordered ON flow.ParentTaskCode = step_ordered.ParentTaskCode AND flow.ChildTaskCode = step_ordered.ChildTaskCode;

		UPDATE Org.tbPayment
		SET
			TaxInValue = PaidInValue - CASE App.tbTaxCode.RoundingCode 
				WHEN 0 THEN ROUND((PaidInValue / (1 + TaxRate)), 2)
				WHEN 1 THEN ROUND((PaidInValue / (1 + TaxRate)), 2, 1) END, 
			TaxOutValue = PaidOutValue - CASE App.tbTaxCode.RoundingCode 
				WHEN 0 THEN ROUND((PaidOutValue / (1 + TaxRate)), 2)
				WHEN 1 THEN ROUND((PaidOutValue / (1 + TaxRate)), 2, 1) END
		FROM         Org.tbPayment INNER JOIN
								App.tbTaxCode ON Org.tbPayment.TaxCode = App.tbTaxCode.TaxCode;

		--Invoice Items									
		UPDATE Invoice.tbItem
		SET InvoiceValue =  ROUND(Invoice.tbItem.TotalValue / (1 + App.tbTaxCode.TaxRate), 2),
			TaxValue = TotalValue - ROUND(Invoice.tbItem.TotalValue / (1 + App.tbTaxCode.TaxRate), 2)
		FROM         Invoice.tbItem INNER JOIN
								App.tbTaxCode ON Invoice.tbItem.TaxCode = App.tbTaxCode.TaxCode INNER JOIN
								Invoice.tbInvoice ON Invoice.tbItem.InvoiceNumber = Invoice.tbInvoice.InvoiceNumber
		WHERE     ( Invoice.tbInvoice.InvoiceStatusCode <> 0) AND Invoice.tbItem.TotalValue <> 0;

		UPDATE Invoice.tbItem
		SET TaxValue = CASE App.tbTaxCode.RoundingCode 
				WHEN 0 THEN ROUND(Invoice.tbItem.InvoiceValue * App.tbTaxCode.TaxRate, 2)
				WHEN 1 THEN ROUND( Invoice.tbItem.InvoiceValue * App.tbTaxCode.TaxRate, 2, 1) END,
			InvoiceValue = CASE WHEN Invoice.tbItem.TotalValue = 0 THEN Invoice.tbItem.InvoiceValue ELSE ROUND(Invoice.tbItem.TotalValue / (1 + App.tbTaxCode.TaxRate), 2) END
		FROM         Invoice.tbItem INNER JOIN
								App.tbTaxCode ON Invoice.tbItem.TaxCode = App.tbTaxCode.TaxCode 
								INNER JOIN Invoice.tbInvoice ON Invoice.tbItem.InvoiceNumber = Invoice.tbInvoice.InvoiceNumber
		WHERE     ( Invoice.tbInvoice.InvoiceStatusCode <> 0) AND Invoice.tbItem.TotalValue = 0;

		WITH accounts_paid AS
		(
			SELECT AccountCode
			FROM Org.tbPayment
			GROUP BY AccountCode
		)
		UPDATE Invoice.tbItem
		SET PaidValue = Invoice.tbItem.InvoiceValue,
			PaidTaxValue = Invoice.tbItem.TaxValue
		FROM Invoice.tbItem 
			JOIN Invoice.tbInvoice ON Invoice.tbItem.InvoiceNumber = Invoice.tbInvoice.InvoiceNumber
			JOIN accounts_paid ON Invoice.tbInvoice.AccountCode = accounts_paid.AccountCode 
		WHERE     ( Invoice.tbInvoice.InvoiceStatusCode <> 0);

		WITH accounts_paid AS
		(
			SELECT AccountCode
			FROM Org.tbPayment
			GROUP BY AccountCode
		)
		UPDATE Invoice.tbItem
		SET PaidValue = 0,
			PaidTaxValue = 0
		FROM Invoice.tbItem 
			JOIN Invoice.tbInvoice ON Invoice.tbItem.InvoiceNumber = Invoice.tbInvoice.InvoiceNumber
			LEFT OUTER JOIN accounts_paid ON Invoice.tbInvoice.AccountCode = accounts_paid.AccountCode 
		WHERE (Invoice.tbInvoice.InvoiceStatusCode <> 0)
			AND (accounts_paid.AccountCode IS NULL);
                   
		UPDATE Invoice.tbTask
		SET InvoiceValue =  ROUND(Invoice.tbTask.TotalValue / (1 + App.tbTaxCode.TaxRate), 2),
			TaxValue = TotalValue - ROUND(Invoice.tbTask.TotalValue / (1 + App.tbTaxCode.TaxRate), 2)
		FROM         Invoice.tbTask INNER JOIN
								App.tbTaxCode ON Invoice.tbTask.TaxCode = App.tbTaxCode.TaxCode INNER JOIN
								Invoice.tbInvoice ON Invoice.tbTask.InvoiceNumber = Invoice.tbInvoice.InvoiceNumber
		WHERE     ( Invoice.tbInvoice.InvoiceStatusCode <> 0) AND Invoice.tbTask.TotalValue <> 0;

		UPDATE Invoice.tbTask
		SET TaxValue = CASE App.tbTaxCode.RoundingCode 
				WHEN 0 THEN ROUND(Invoice.tbTask.InvoiceValue * App.tbTaxCode.TaxRate, 2)
				WHEN 1 THEN ROUND( Invoice.tbTask.InvoiceValue * App.tbTaxCode.TaxRate, 2, 1) END,
			InvoiceValue = CASE WHEN Invoice.tbTask.TotalValue = 0 THEN Invoice.tbTask.InvoiceValue ELSE ROUND(Invoice.tbTask.TotalValue / (1 + App.tbTaxCode.TaxRate), 2) END
		FROM         Invoice.tbTask INNER JOIN
								App.tbTaxCode ON Invoice.tbTask.TaxCode = App.tbTaxCode.TaxCode 
								INNER JOIN Invoice.tbInvoice ON Invoice.tbTask.InvoiceNumber = Invoice.tbInvoice.InvoiceNumber
		WHERE     ( Invoice.tbInvoice.InvoiceStatusCode <> 0) AND Invoice.tbTask.TotalValue = 0;

		WITH accounts_paid AS
		(
			SELECT AccountCode
			FROM Org.tbPayment
			GROUP BY AccountCode
		)
		UPDATE Invoice.tbTask
		SET PaidValue = Invoice.tbTask.InvoiceValue,
			PaidTaxValue = Invoice.tbTask.TaxValue
		FROM Invoice.tbTask 
			JOIN Invoice.tbInvoice ON Invoice.tbTask.InvoiceNumber = Invoice.tbInvoice.InvoiceNumber
			JOIN accounts_paid ON Invoice.tbInvoice.AccountCode = accounts_paid.AccountCode 
		WHERE ( Invoice.tbInvoice.InvoiceStatusCode <> 0);
				
		WITH accounts_paid AS
		(
			SELECT AccountCode
			FROM Org.tbPayment
			GROUP BY AccountCode
		)
		UPDATE Invoice.tbTask
		SET PaidValue = 0,
			PaidTaxValue = 0
		FROM Invoice.tbTask 
			JOIN Invoice.tbInvoice ON Invoice.tbTask.InvoiceNumber = Invoice.tbInvoice.InvoiceNumber
			LEFT OUTER JOIN accounts_paid ON Invoice.tbInvoice.AccountCode = accounts_paid.AccountCode 
		WHERE (Invoice.tbInvoice.InvoiceStatusCode <> 0)
			AND (accounts_paid.AccountCode IS NULL);				
				   	
		UPDATE Invoice.tbInvoice
		SET InvoiceValue = 0, TaxValue = 0, PaidValue = 0, PaidTaxValue = 0, InvoiceStatusCode = 1
		WHERE     ( Invoice.tbInvoice.InvoiceStatusCode <> 0);
	
		WITH items AS
		(
			SELECT     Invoice.tbInvoice.InvoiceNumber, SUM( Invoice.tbItem.InvoiceValue) AS TotalInvoiceValue, SUM( Invoice.tbItem.TaxValue) AS TotalTaxValue
			FROM         Invoice.tbItem INNER JOIN
								Invoice.tbInvoice ON Invoice.tbItem.InvoiceNumber = Invoice.tbInvoice.InvoiceNumber
			WHERE     ( Invoice.tbInvoice.InvoiceStatusCode <> 0)
			GROUP BY Invoice.tbItem.InvoiceNumber, Invoice.tbInvoice.InvoiceNumber
		)
		UPDATE Invoice.tbInvoice
		SET InvoiceValue = items.TotalInvoiceValue, 
			TaxValue = items.TotalTaxValue
		FROM         Invoice.tbInvoice INNER JOIN items 
								ON Invoice.tbInvoice.InvoiceNumber = items.InvoiceNumber;

		WITH tasks AS
		(
			SELECT     Invoice.tbInvoice.InvoiceNumber, SUM( Invoice.tbTask.InvoiceValue) AS TotalInvoiceValue, SUM( Invoice.tbTask.TaxValue) AS TotalTaxValue
			FROM         Invoice.tbTask INNER JOIN
								Invoice.tbInvoice ON Invoice.tbTask.InvoiceNumber = Invoice.tbInvoice.InvoiceNumber
			WHERE   ( Invoice.tbInvoice.InvoiceStatusCode <> 0)
			GROUP BY Invoice.tbTask.InvoiceNumber, Invoice.tbInvoice.InvoiceNumber
		)
		UPDATE Invoice.tbInvoice
		SET InvoiceValue = InvoiceValue + tasks.TotalInvoiceValue, 
			TaxValue = TaxValue + tasks.TotalTaxValue
		FROM         Invoice.tbInvoice INNER JOIN tasks ON Invoice.tbInvoice.InvoiceNumber = tasks.InvoiceNumber;

		WITH accounts_paid AS
		(
			SELECT AccountCode
			FROM Org.tbPayment
			GROUP BY AccountCode
		)
		UPDATE invoice_header
		SET              
			PaidValue = InvoiceValue, PaidTaxValue = TaxValue, InvoiceStatusCode = 3
		FROM Invoice.tbInvoice invoice_header
			JOIN accounts_paid ON invoice_header.AccountCode = accounts_paid.AccountCode
		WHERE InvoiceStatusCode > 0;

		WITH accounts_paid AS
		(
			SELECT AccountCode
			FROM Org.tbPayment
			GROUP BY AccountCode
		)
		UPDATE invoice_header
		SET     
			PaidValue = 0, PaidTaxValue = 0, InvoiceStatusCode = 1
		FROM Invoice.tbInvoice invoice_header
			LEFT OUTER JOIN accounts_paid ON invoice_header.AccountCode = accounts_paid.AccountCode
		WHERE accounts_paid.AccountCode IS NULL AND InvoiceStatusCode > 0;


		--unpaid invoices
		WITH paid_balance AS
		(
			SELECT  AccountCode, SUM(PaidInValue + (PaidOutValue * -1)) AS PaidBalance
			FROM         Org.tbPayment
			WHERE     (PaymentStatusCode = 1)
			GROUP BY AccountCode
		), invoice_balance AS
		(
			SELECT AccountCode, SUM(CASE Invoice.tbType.CashModeCode WHEN 0 THEN (InvoiceValue + TaxValue) * - 1 WHEN 1 THEN InvoiceValue + TaxValue ELSE 0 END) AS InvoicedBalance
			FROM         Invoice.tbInvoice INNER JOIN
								  Invoice.tbType ON Invoice.tbInvoice.InvoiceTypeCode = Invoice.tbType.InvoiceTypeCode
			GROUP BY AccountCode
		), account_balance AS
		(
			SELECT paid_balance.AccountCode, PaidBalance, InvoicedBalance, PaidBalance - InvoicedBalance AS CurrentBalance
			FROM paid_balance JOIN invoice_balance ON paid_balance.AccountCode = invoice_balance.AccountCode
		), current_balance AS
		(
			SELECT account_balance.AccountCode, ROUND(OpeningBalance + account_balance.CurrentBalance, 2) AS CurrentBalance
			FROM Org.tbOrg JOIN
				account_balance ON Org.tbOrg.AccountCode = account_balance.AccountCode
		), closing_balance AS
		(
			SELECT AccountCode, 0 AS RowNumber,
				CurrentBalance,
					CASE WHEN CurrentBalance < 0 THEN 0 
						WHEN CurrentBalance > 0 THEN 1
						ELSE 2 END AS CashModeCode
			FROM current_balance
			WHERE ROUND(CurrentBalance, 0) <> 0 
		), invoice_entries AS
		(
			SELECT        Invoice.tbInvoice.AccountCode, Invoice.tbInvoice.ExpectedOn, Invoice.tbInvoice.InvoiceNumber, Invoice.tbTask.TaskCode AS RefCode, 1 AS RefType, 
				CASE WHEN Invoice.tbType.CashModeCode = 0 THEN Invoice.tbTask.InvoiceValue * -1 ELSE Invoice.tbTask.InvoiceValue END AS InvoiceValue, 
				CASE WHEN Invoice.tbType.CashModeCode = 0 THEN Invoice.tbTask.TaxValue * -1 ELSE Invoice.tbTask.TaxValue END AS TaxValue, Invoice.tbType.CashModeCode
			FROM   closing_balance JOIN Invoice.tbInvoice ON closing_balance.AccountCode = Invoice.tbInvoice.AccountCode
				JOIN  Invoice.tbTask ON Invoice.tbTask.InvoiceNumber = Invoice.tbInvoice.InvoiceNumber
				JOIN Invoice.tbType ON Invoice.tbInvoice.InvoiceTypeCode = Invoice.tbType.InvoiceTypeCode
			UNION
			SELECT        Invoice.tbInvoice.AccountCode, Invoice.tbInvoice.ExpectedOn, Invoice.tbInvoice.InvoiceNumber, CashCode AS RefCode, 2 AS RefType,
				CASE WHEN Invoice.tbType.CashModeCode = 0 THEN Invoice.tbItem.InvoiceValue * -1 ELSE Invoice.tbItem.InvoiceValue END AS InvoiceValue, 
				CASE WHEN Invoice.tbType.CashModeCode = 0 THEN Invoice.tbItem.TaxValue * -1 ELSE Invoice.tbItem.TaxValue END AS TaxValue, Invoice.tbType.CashModeCode
			FROM   closing_balance JOIN Invoice.tbInvoice ON closing_balance.AccountCode = Invoice.tbInvoice.AccountCode
				JOIN Invoice.tbItem ON Invoice.tbItem.InvoiceNumber = Invoice.tbInvoice.InvoiceNumber
				JOIN Invoice.tbType ON Invoice.tbInvoice.InvoiceTypeCode = Invoice.tbType.InvoiceTypeCode
		), invoices AS
		(
			SELECT AccountCode, ROW_NUMBER() OVER (PARTITION BY AccountCode ORDER BY ExpectedOn DESC, CashModeCode DESC) AS RowNumber, 
				InvoiceNumber, RefCode, RefType, (InvoiceValue + TaxValue) AS ValueToPay
			FROM invoice_entries
		), invoices_and_cb AS
		( 
			SELECT AccountCode, RowNumber, '' AS InvoiceNumber, '' AS RefCode, 0 AS RefType, CurrentBalance AS ValueToPay
			FROM closing_balance
			UNION
			SELECT AccountCode, RowNumber, InvoiceNumber, RefCode, RefType, ValueToPay
			FROM invoices	
		), unbalanced_cashmode AS
		(
			SELECT invoices_and_cb.AccountCode, invoices_and_cb.RowNumber, invoices_and_cb.InvoiceNumber, invoices_and_cb.RefCode, 
				invoices_and_cb.RefType, invoices_and_cb.ValueToPay, closing_balance.CashModeCode
			FROM invoices_and_cb JOIN closing_balance ON invoices_and_cb.AccountCode = closing_balance.AccountCode
		), invoice_balances AS
		(
			SELECT AccountCode, RowNumber, InvoiceNumber, RefCode, RefType, ValueToPay, CashModeCode, 
				SUM(ValueToPay) OVER (PARTITION BY AccountCode ORDER BY RowNumber ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS Balance
			FROM unbalanced_cashmode
		), selected_row AS
		(
			SELECT AccountCode, MIN(RowNumber) AS RowNumber
			FROM invoice_balances
			WHERE (CashModeCode = 0 AND Balance >= 0) OR (CashModeCode = 1 AND Balance <= 0)
			GROUP BY AccountCode
		), result_set AS
		(
			SELECT invoice_unpaid.AccountCode, invoice_unpaid.InvoiceNumber, invoice_unpaid.RefType, invoice_unpaid.RefCode, 
				CASE WHEN CashModeCode = 0 THEN
						CASE WHEN Balance < 0 THEN 0 ELSE Balance END
					WHEN CashModeCode = 1 THEN
						CASE WHEN Balance > 0 THEN 0 ELSE ABS(Balance) END
					END AS TotalPaidValue
			FROM selected_row
				CROSS APPLY (SELECT invoice_balances.*
							FROM invoice_balances
							WHERE invoice_balances.AccountCode = selected_row.AccountCode
								AND invoice_balances.RowNumber <= selected_row.RowNumber
								AND invoice_balances.RefType > 0) AS invoice_unpaid
		)
		INSERT INTO @tbPartialInvoice
			(AccountCode, InvoiceNumber, RefType, RefCode, TotalPaidValue)
		SELECT AccountCode, InvoiceNumber, RefType, RefCode, TotalPaidValue
		FROM result_set;

		UPDATE task
		SET PaidValue = 0, PaidTaxValue = 0
		FROM @tbPartialInvoice unpaid_task
			JOIN Invoice.tbTask task ON unpaid_task.InvoiceNumber = task.InvoiceNumber
				AND unpaid_task.RefCode = task.TaskCode	
		WHERE unpaid_task.RefType = 1 AND unpaid_task.TotalPaidValue = 0;

		UPDATE task
		SET 
			PaidTaxValue = CASE RoundingCode 
								WHEN 0 THEN ROUND((TotalPaidValue - (TotalPaidValue / (1 + TaxRate))), 2)
								WHEN 1 THEN ROUND((TotalPaidValue - (TotalPaidValue / (1 + TaxRate))), 2, 1)
							END,
			PaidValue = TotalPaidValue -
							CASE RoundingCode 
								WHEN 0 THEN ROUND((TotalPaidValue - (TotalPaidValue / (1 + TaxRate))), 2)
								WHEN 1 THEN ROUND((TotalPaidValue - (TotalPaidValue / (1 + TaxRate))), 2, 1)
							END
		FROM @tbPartialInvoice unpaid_task
			JOIN Invoice.tbTask task ON unpaid_task.InvoiceNumber = task.InvoiceNumber
				AND unpaid_task.RefCode = task.TaskCode	
			JOIN App.tbTaxCode tax ON tax.TaxCode = task.TaxCode
		WHERE unpaid_task.RefType = 1 AND unpaid_task.TotalPaidValue <> 0;

		UPDATE item
		SET PaidValue = 0, PaidTaxValue = 0
		FROM @tbPartialInvoice unpaid_task
			JOIN Invoice.tbItem item ON unpaid_task.InvoiceNumber = item.InvoiceNumber
				AND unpaid_task.RefCode = item.CashCode
		WHERE unpaid_task.RefType = 1 AND unpaid_task.TotalPaidValue = 0;

		UPDATE item
		SET 
			PaidTaxValue = CASE RoundingCode 
								WHEN 0 THEN ROUND((TotalPaidValue - (TotalPaidValue / (1 + TaxRate))), 2)
								WHEN 1 THEN ROUND((TotalPaidValue - (TotalPaidValue / (1 + TaxRate))), 2, 1)
							END,
			PaidValue = TotalPaidValue -
							CASE RoundingCode 
								WHEN 0 THEN ROUND((TotalPaidValue - (TotalPaidValue / (1 + TaxRate))), 2)
								WHEN 1 THEN ROUND((TotalPaidValue - (TotalPaidValue / (1 + TaxRate))), 2, 1)
							END
		FROM @tbPartialInvoice unpaid_item
			JOIN Invoice.tbItem item ON unpaid_item.InvoiceNumber = item.InvoiceNumber
				AND unpaid_item.RefCode = item.CashCode	
			JOIN App.tbTaxCode tax ON tax.TaxCode = item.TaxCode
		WHERE unpaid_item.RefType = 1 AND unpaid_item.TotalPaidValue <> 0;

		WITH invoices AS
		(
			SELECT        task.InvoiceNumber, InvoiceValue, TaxValue, PaidValue, PaidTaxValue
			FROM       @tbPartialInvoice unpaid_task
			JOIN Invoice.tbTask task ON unpaid_task.InvoiceNumber = task.InvoiceNumber
				AND unpaid_task.RefCode = task.TaskCode	
			UNION
			SELECT        item.InvoiceNumber, InvoiceValue, TaxValue, PaidValue, PaidTaxValue
			FROM @tbPartialInvoice unpaid_item
				JOIN Invoice.tbItem item ON unpaid_item.InvoiceNumber = item.InvoiceNumber
					AND unpaid_item.RefCode = item.CashCode
		), totals AS
		(
			SELECT        InvoiceNumber, SUM(InvoiceValue) AS TotalInvoiceValue, SUM(TaxValue) AS TotalTaxValue, SUM(PaidValue) AS TotalPaidValue, SUM(PaidTaxValue) AS TotalPaidTaxValue
			FROM            invoices
			GROUP BY InvoiceNumber
		), selected AS
		(
			SELECT InvoiceNumber, 		
				TotalInvoiceValue, TotalTaxValue, TotalPaidValue, TotalPaidTaxValue, 
				(TotalPaidValue + TotalPaidTaxValue) AS TotalPaid
			FROM totals
			WHERE (TotalInvoiceValue + TotalTaxValue) > (TotalPaidValue + TotalPaidTaxValue)
		)
		UPDATE Invoice.tbInvoice
		SET InvoiceStatusCode = CASE WHEN TotalPaid > 0 THEN 2 ELSE 1 END,
			PaidValue = selected.TotalPaidValue, 
			PaidTaxValue = selected.TotalPaidTaxValue
		FROM         Invoice.tbInvoice INNER JOIN
							selected ON Invoice.tbInvoice.InvoiceNumber = selected.InvoiceNumber;

		--cash accounts
		UPDATE Org.tbAccount
		SET CurrentBalance = Cash.vwAccountRebuild.CurrentBalance
		FROM         Cash.vwAccountRebuild INNER JOIN
							Org.tbAccount ON Cash.vwAccountRebuild.CashAccountCode = Org.tbAccount.CashAccountCode;
	
		UPDATE Org.tbAccount
		SET CurrentBalance = 0
		FROM         Cash.vwAccountRebuild RIGHT OUTER JOIN
							  Org.tbAccount ON Cash.vwAccountRebuild.CashAccountCode = Org.tbAccount.CashAccountCode
		WHERE     (Cash.vwAccountRebuild.CashAccountCode IS NULL);


		--CASH FLOW Initialize all
		UPDATE       Cash.tbPeriod
		SET                InvoiceValue = 0, InvoiceTax = 0;
	
		WITH invoice_summary AS
		(
			SELECT        Invoice.vwRegisterDetail.CashCode, Invoice.vwRegisterDetail.StartOn, ABS(SUM(Invoice.vwRegisterDetail.InvoiceValue)) AS InvoiceValue, ABS(SUM(Invoice.vwRegisterDetail.TaxValue)) AS TaxValue
			FROM            Invoice.vwRegisterDetail INNER JOIN
									 Cash.tbCode ON Invoice.vwRegisterDetail.CashCode = Cash.tbCode.CashCode INNER JOIN
									 Cash.tbCategory ON Cash.tbCode.CategoryCode = Cash.tbCategory.CategoryCode
			WHERE Invoice.vwRegisterDetail.StartOn < (SELECT StartOn FROM App.fnActivePeriod())
			GROUP BY Invoice.vwRegisterDetail.StartOn, Invoice.vwRegisterDetail.CashCode
		)
		UPDATE Cash.tbPeriod
		SET InvoiceValue = invoice_summary.InvoiceValue, 
			InvoiceTax = invoice_summary.TaxValue
		FROM    Cash.tbPeriod INNER JOIN
				invoice_summary ON Cash.tbPeriod.CashCode = invoice_summary.CashCode AND Cash.tbPeriod.StartOn = invoice_summary.StartOn;


		UPDATE Cash.tbPeriod
		SET 
			InvoiceValue = Cash.vwAccountPeriodClosingBalance.ClosingBalance
		FROM         Cash.vwAccountPeriodClosingBalance INNER JOIN
							  Cash.tbPeriod ON Cash.vwAccountPeriodClosingBalance.CashCode = Cash.tbPeriod.CashCode AND 
							  Cash.vwAccountPeriodClosingBalance.StartOn = Cash.tbPeriod.StartOn;	            

		COMMIT TRANSACTION

		--log successful rebuild
		DECLARE @Msg NVARCHAR(MAX);
		SELECT @Msg = Message FROM App.tbText WHERE TextId = 3006;
		EXEC App.proc_EventLog @EventMessage = @Msg, @EventTypeCode = 2;

  	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
go


CREATE PROCEDURE App.proc_YearPeriods
	(
	@YearNumber int
	)
AS
   	SET NOCOUNT, XACT_ABORT ON;

	BEGIN TRY
		SELECT     App.tbYear.Description, App.tbMonth.MonthName
					FROM         App.tbYearPeriod INNER JOIN
										App.tbYear ON App.tbYearPeriod.YearNumber = App.tbYear.YearNumber INNER JOIN
										App.tbMonth ON App.tbYearPeriod.MonthNumber = App.tbMonth.MonthNumber
					WHERE     ( App.tbYearPeriod.YearNumber = @YearNumber)
					ORDER BY App.tbYearPeriod.YearNumber, App.tbYearPeriod.StartOn
    END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
go

CREATE PROCEDURE Cash.proc_AccountRebuild
	(
	@CashAccountCode nvarchar(10)
	)
  AS
	SET NOCOUNT, XACT_ABORT ON;

	BEGIN TRY
		
		UPDATE Org.tbAccount
		SET CurrentBalance = Cash.vwAccountRebuild.CurrentBalance
		FROM         Cash.vwAccountRebuild INNER JOIN
							Org.tbAccount ON Cash.vwAccountRebuild.CashAccountCode = Org.tbAccount.CashAccountCode
		WHERE Cash.vwAccountRebuild.CashAccountCode = @CashAccountCode 

		UPDATE Org.tbAccount
		SET CurrentBalance = 0
		FROM         Cash.vwAccountRebuild RIGHT OUTER JOIN
							  Org.tbAccount ON Cash.vwAccountRebuild.CashAccountCode = Org.tbAccount.CashAccountCode
		WHERE     (Cash.vwAccountRebuild.CashAccountCode IS NULL) AND Org.tbAccount.CashAccountCode = @CashAccountCode
    END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH 
go

CREATE PROCEDURE Cash.proc_CodeDefaults 
	(
	@CashCode nvarchar(50)
	)
  AS
   	SET NOCOUNT, XACT_ABORT ON;

	BEGIN TRY

		SELECT     Cash.tbCode.CashCode, Cash.tbCode.CashDescription, Cash.tbCode.CategoryCode, Cash.tbCode.TaxCode, 
				App.tbTaxCode.TaxTypeCode, Cash.tbCode.OpeningBalance, 
							  ISNULL( Cash.tbCategory.CashModeCode, 0) AS CashModeCode, ISNULL(Cash.tbCategory.CashTypeCode, 0) AS CashTypeCode
		FROM         Cash.tbCode INNER JOIN
							  App.tbTaxCode ON Cash.tbCode.TaxCode = App.tbTaxCode.TaxCode LEFT OUTER JOIN
							  Cash.tbCategory ON Cash.tbCode.CategoryCode = Cash.tbCategory.CategoryCode
		WHERE     ( Cash.tbCode.CashCode = @CashCode)
    END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH 
go

CREATE PROCEDURE Cash.proc_CurrentAccount(@CashAccountCode NVARCHAR(10) OUTPUT)
AS
	SET NOCOUNT, XACT_ABORT ON;
	BEGIN TRY
		SELECT  @CashAccountCode = Org.tbAccount.CashAccountCode
		FROM            Org.tbAccount INNER JOIN
								 Cash.tbCode ON Org.tbAccount.CashCode = Cash.tbCode.CashCode INNER JOIN
								 Cash.tbCategory ON Cash.tbCode.CategoryCode = Cash.tbCategory.CategoryCode
		WHERE        (Org.tbAccount.AccountCode <> (SELECT AccountCode FROM App.tbOptions))
			AND (Cash.tbCategory.CashTypeCode = 2);

	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
go

CREATE PROCEDURE Cash.proc_FlowCashCodeValues(@CashCode nvarchar(50), @YearNumber smallint, @IncludeActivePeriods BIT = 0, @IncludeOrderBook BIT = 0, @IncludeTaxAccruals BIT = 0)
AS
	--ref Cash.fnFlowCashCodeValues() for a sample inline function implementation 

	SET NOCOUNT, XACT_ABORT ON;

	BEGIN TRY
		DECLARE @StartOn DATE
			, @IsTaxCode BIT = 0;

		DECLARE @tbReturn AS TABLE (
			StartOn DATETIME NOT NULL, 
			CashStatusCode SMALLINT NOT NULL, 
			ForecastValue MONEY NOT NULL, 
			ForecastTax MONEY NOT NULL, 
			InvoiceValue MONEY NOT NULL, 
			InvoiceTax MONEY NOT NULL);

		INSERT INTO @tbReturn (StartOn, CashStatusCode, ForecastValue, ForecastTax, InvoiceValue, InvoiceTax)
		SELECT   Cash.tbPeriod.StartOn, App.tbYearPeriod.CashStatusCode,
			Cash.tbPeriod.ForecastValue, 
			Cash.tbPeriod.ForecastTax, 
			CASE App.tbYearPeriod.CashStatusCode WHEN 2 THEN Cash.tbPeriod.InvoiceValue ELSE 0 END AS InvoiceValue, 
			CASE App.tbYearPeriod.CashStatusCode WHEN 2 THEN Cash.tbPeriod.InvoiceTax ELSE 0 END AS InvoiceTax
		FROM            Cash.tbPeriod INNER JOIN
									App.tbYearPeriod ON Cash.tbPeriod.StartOn = App.tbYearPeriod.StartOn INNER JOIN
									App.tbYear ON App.tbYearPeriod.YearNumber = App.tbYear.YearNumber
		WHERE        (App.tbYear.CashStatusCode < 3) AND (App.tbYearPeriod.YearNumber = @YearNumber) AND (Cash.tbPeriod.CashCode = @CashCode);

	
		SELECT @StartOn = (SELECT CAST(MIN(StartOn) AS DATE) FROM @tbReturn WHERE CashStatusCode < 2);
		IF EXISTS(SELECT * FROM Cash.tbTaxType tt WHERE tt.CashCode = @CashCode) SET @IsTaxCode = 1;

		IF (@IncludeActivePeriods <> 0)
			BEGIN		
			WITH active_tasks AS
			(
				SELECT (SELECT TOP (1) StartOn FROM App.tbYearPeriod AS p WHERE (StartOn <= invoices.InvoicedOn) ORDER BY StartOn DESC) AS StartOn,
						CASE WHEN invoice_type.CashModeCode = 0 THEN tasks.InvoiceValue * - 1 ELSE tasks.InvoiceValue END AS InvoiceValue, 
						CASE WHEN invoice_type.CashModeCode = 0 THEN tasks.TaxValue * - 1 ELSE tasks.TaxValue END AS InvoiceTax
				FROM Invoice.tbInvoice invoices
					JOIN Invoice.tbType invoice_type ON invoices.InvoiceTypeCode = invoice_type.InvoiceTypeCode
					JOIN Invoice.tbTask tasks ON invoices.InvoiceNumber = tasks.InvoiceNumber
				WHERE invoices.InvoicedOn >= @StartOn
					AND tasks.CashCode = @CashCode
			), active_items AS
			(
				SELECT (SELECT TOP (1) StartOn FROM App.tbYearPeriod AS p WHERE (StartOn <= invoices.InvoicedOn) ORDER BY StartOn DESC) AS StartOn,
						CASE WHEN invoice_type.CashModeCode = 0 THEN items.InvoiceValue * - 1 ELSE items.InvoiceValue END AS InvoiceValue, 
						CASE WHEN invoice_type.CashModeCode = 0 THEN items.TaxValue * - 1 ELSE items.TaxValue END AS InvoiceTax
				FROM Invoice.tbInvoice invoices
					JOIN Invoice.tbType invoice_type ON invoices.InvoiceTypeCode = invoice_type.InvoiceTypeCode
					JOIN Invoice.tbItem items ON invoices.InvoiceNumber = items.InvoiceNumber
				WHERE invoices.InvoicedOn >= @StartOn AND items.CashCode = @CashCode
			), active_invoices AS
			(
				SELECT StartOn, InvoiceValue, InvoiceTax FROM active_tasks
				UNION
				SELECT StartOn, InvoiceValue, InvoiceTax FROM active_items
			), active_periods AS
			(
				SELECT StartOn, SUM(InvoiceValue) AS InvoiceValue, SUM(InvoiceTax) AS InvoiceTax
				FROM active_invoices
				GROUP BY StartOn
			)
			UPDATE cashcode_values
			SET InvoiceValue += ABS(active_periods.InvoiceValue), InvoiceTax += ABS(active_periods.InvoiceTax)
			FROM @tbReturn cashcode_values JOIN active_periods ON cashcode_values.StartOn = active_periods.StartOn;

			IF @IsTaxCode <> 0
				BEGIN
				IF EXISTS (SELECT CashCode FROM Cash.tbTaxType WHERE CashCode = @CashCode AND TaxTypeCode = 0)
					BEGIN	
					WITH ct_due AS
					(
						SELECT (SELECT TOP (1) StartOn FROM App.tbYearPeriod AS p WHERE (StartOn <= ct_statement.StartOn) ORDER BY StartOn DESC) AS StartOn, TaxDue 
						FROM Cash.vwTaxCorpStatement ct_statement
						WHERE ct_statement.StartOn >= @StartOn
					)							
					UPDATE cashcode_values
					SET InvoiceValue += TaxDue
					FROM ct_due
						JOIN @tbReturn cashcode_values ON ct_due.StartOn = cashcode_values.StartOn;	
					END

				IF EXISTS (SELECT CashCode FROM Cash.tbTaxType WHERE CashCode = @CashCode AND TaxTypeCode = 1)
					BEGIN			
					WITH vat_due AS
					(
						SELECT (SELECT TOP (1) StartOn FROM App.tbYearPeriod AS p WHERE (StartOn <= vat_statement.StartOn) ORDER BY StartOn DESC) AS StartOn, VatDue 
						FROM Cash.vwTaxVatStatement vat_statement
						WHERE vat_statement.StartOn >= @StartOn
					)
					UPDATE cashcode_values
					SET InvoiceValue += VatDue
					FROM vat_due
						JOIN @tbReturn cashcode_values ON vat_due.StartOn = cashcode_values.StartOn;		
					END
				END
			END

		IF (@IncludeOrderBook <> 0)
			BEGIN
			WITH tasks AS
			(
				SELECT task.TaskCode,
						(SELECT        TOP (1) StartOn
						FROM            App.tbYearPeriod
						WHERE        (StartOn <= task.ActionOn)
						ORDER BY StartOn DESC) AS StartOn, task.TotalCharge, ISNULL(tax.TaxRate, 0) AS TaxRate
				FROM            Task.tbTask AS task INNER JOIN
											App.tbTaxCode AS tax ON task.TaxCode = tax.TaxCode
				WHERE     (task.CashCode = @CashCode) AND ((task.TaskStatusCode = 1) OR (task.TaskStatusCode = 2))
			), tasks_foryear AS
			(
				SELECT tasks.TaskCode, tasks.StartOn, tasks.TotalCharge, tasks.TaxRate
				FROM tasks
					JOIN @tbReturn invoice_history ON tasks.StartOn = invoice_history.StartOn		
			)
			, order_invoice_value AS
			(
				SELECT   invoices.TaskCode, tasks_foryear.StartOn, SUM(invoices.InvoiceValue) AS InvoiceValue, SUM(invoices.TaxValue) AS InvoiceTax
				FROM  Invoice.tbTask invoices
					JOIN tasks_foryear ON invoices.TaskCode = tasks_foryear.TaskCode 
				GROUP BY invoices.TaskCode, StartOn
			), orders AS
			(
				SELECT tasks_foryear.StartOn, 
					tasks_foryear.TotalCharge - ISNULL(order_invoice_value.InvoiceValue, 0) AS InvoiceValue,
					(tasks_foryear.TotalCharge * tasks_foryear.TaxRate) - ISNULL(order_invoice_value.InvoiceTax, 0) AS InvoiceTax
				FROM tasks_foryear LEFT OUTER JOIN order_invoice_value ON tasks_foryear.TaskCode = order_invoice_value.TaskCode
			), order_summary AS
			(
				SELECT StartOn, SUM(InvoiceValue) As InvoiceValue, SUM(InvoiceTax) As InvoiceTax
				FROM orders
				GROUP BY StartOn
			)
			UPDATE cashcode_values
			SET InvoiceValue += order_summary.InvoiceValue, InvoiceTax += order_summary.InvoiceTax
			FROM @tbReturn cashcode_values JOIN order_summary ON cashcode_values.StartOn = order_summary.StartOn;

			END
	
		IF (@IncludeTaxAccruals <> 0) AND (@IsTaxCode <> 0)
			BEGIN
			IF EXISTS (SELECT CashCode FROM Cash.tbTaxType WHERE CashCode = @CashCode AND TaxTypeCode = 0)
				BEGIN
				WITH ct_dates AS
				(
					SELECT PayOn, PayFrom, PayTo FROM Cash.fnTaxTypeDueDates(0)
				), ct_period AS
				(
					SELECT (SELECT TOP (1) StartOn FROM App.tbYearPeriod WHERE (StartOn <= PayOn) ORDER BY StartOn DESC) AS StartOn, PayOn, PayFrom, PayTo
					FROM  ct_dates 
						JOIN  App.tbYearPeriod AS year_period ON ct_dates.PayTo = year_period.StartOn 
						JOIN App.tbYear AS y ON year_period.YearNumber = y.YearNumber 
					WHERE     year_period.StartOn >= (SELECT StartOn FROM App.vwActivePeriod)
				), ct_accrual_details AS
				(		
					SELECT StartOn, SUM(TaxDue) AS TaxDue 
					FROM Cash.vwTaxCorpAccruals
					WHERE TaxDue <> 0
					GROUP BY StartOn
				), ct_accruals AS
				(
					SELECT (SELECT ct_period.StartOn FROM ct_period WHERE ct_accrual_details.StartOn >= ct_period.PayFrom AND ct_accrual_details.StartOn < ct_period.PayTo) AS StartOn, TaxDue
					FROM ct_accrual_details
				), ct_due AS
				(
					SELECT StartOn, SUM(TaxDue) AS TaxDue
					FROM ct_accruals
					GROUP BY StartOn
				)
				UPDATE cashcode_values
				SET InvoiceValue += TaxDue
				FROM ct_due
					JOIN @tbReturn cashcode_values ON ct_due.StartOn = cashcode_values.StartOn;	

				END

			IF EXISTS (SELECT CashCode FROM Cash.tbTaxType WHERE CashCode = @CashCode AND TaxTypeCode = 1)
				BEGIN
				WITH vat_dates AS
				(
					SELECT PayOn, PayFrom, PayTo FROM Cash.fnTaxTypeDueDates(1)
				), vat_period AS
				(
					SELECT (SELECT TOP (1) StartOn FROM App.tbYearPeriod WHERE (StartOn <= PayOn) ORDER BY StartOn DESC) AS StartOn, PayOn, PayFrom, PayTo
					FROM  vat_dates 
						JOIN  App.tbYearPeriod AS year_period ON vat_dates.PayTo = year_period.StartOn 
						JOIN App.tbYear AS y ON year_period.YearNumber = y.YearNumber 
					WHERE     (y.CashStatusCode = 1) OR (y.CashStatusCode = 2)
				), vat_accrual_details AS
				(		
					SELECT StartOn, SUM(VatDue) AS VatDue 
					FROM Cash.vwTaxVatAccruals
					WHERE VatDue <> 0
					GROUP BY StartOn
				), vat_accruals AS
				(
					SELECT (SELECT vat_period.StartOn FROM vat_period WHERE vat_accrual_details.StartOn >= vat_period.PayFrom AND vat_accrual_details.StartOn < vat_period.PayTo) AS StartOn, VatDue
					FROM vat_accrual_details
				), vat_due AS
				(
					SELECT StartOn, SUM(VatDue) AS VatDue
					FROM vat_accruals
					GROUP BY StartOn
				)
				UPDATE cashcode_values
				SET InvoiceValue += VatDue
				FROM vat_due
					JOIN @tbReturn cashcode_values ON vat_due.StartOn = cashcode_values.StartOn;	
				END
			END

		SELECT StartOn, InvoiceValue, InvoiceTax, ForecastValue, ForecastTax FROM @tbReturn;

	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
go

CREATE PROCEDURE Cash.proc_FlowCategoryCodeFromName
	(
		@Category nvarchar(50),
		@CategoryCode nvarchar(10) output
	)
AS
	SET NOCOUNT, XACT_ABORT ON;

	BEGIN TRY
		IF EXISTS (SELECT CategoryCode
					FROM         Cash.tbCategory
					WHERE     (Category = @Category))
			SELECT @CategoryCode = CategoryCode
			FROM         Cash.tbCategory
			WHERE     (Category = @Category)
		ELSE
			SET @CategoryCode = 0 
    END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH  
go

CREATE PROCEDURE Org.proc_PaymentPostMisc
	(
	@PaymentCode nvarchar(20) 
	)
 AS
 	SET NOCOUNT, XACT_ABORT ON;

	BEGIN TRY
		DECLARE 
			@InvoiceNumber nvarchar(20), 
			@NextNumber int, 
			@InvoiceTypeCode smallint;

		IF NOT EXISTS (SELECT        Org.tbPayment.PaymentCode
						FROM            Org.tbPayment INNER JOIN
												 Cash.tbCode ON Org.tbPayment.CashCode = Cash.tbCode.CashCode INNER JOIN
												 Cash.tbCategory ON Cash.tbCode.CategoryCode = Cash.tbCategory.CategoryCode
						WHERE        (Org.tbPayment.PaymentStatusCode <> 1)  
							AND Org.tbPayment.UserId = (SELECT UserId FROM Usr.vwCredentials))
			RETURN 

		SELECT @InvoiceTypeCode = CASE WHEN PaidInValue != 0 THEN 0 ELSE 2 END 
		FROM         Org.tbPayment
		WHERE     (PaymentCode = @PaymentCode)
	
		SELECT @NextNumber = NextNumber
		FROM Invoice.tbType
		WHERE InvoiceTypeCode = @InvoiceTypeCode;
		
		SET @InvoiceNumber = FORMAT(@NextNumber, '000000') + '.' + (SELECT UserId FROM Usr.vwCredentials)

		WHILE EXISTS (SELECT     InvoiceNumber
					  FROM         Invoice.tbInvoice
					  WHERE     (InvoiceNumber = @InvoiceNumber))
			BEGIN
			SET @NextNumber += @NextNumber 
			SET @InvoiceNumber = FORMAT(@NextNumber, '000000') + '.' + (SELECT UserId FROM Usr.vwCredentials)
			END
		
		BEGIN TRANSACTION

		UPDATE    Invoice.tbType
		SET              NextNumber = @NextNumber + 1
		WHERE     (InvoiceTypeCode = @InvoiceTypeCode)

		UPDATE    Org.tbPayment
		SET		PaymentStatusCode = 1,
			TaxInValue = (CASE App.tbTaxCode.RoundingCode WHEN 0 THEN ROUND(Org.tbPayment.PaidInValue - ( Org.tbPayment.PaidInValue / (1 + App.tbTaxCode.TaxRate)), 2) WHEN 1 THEN ROUND(Org.tbPayment.PaidInValue - ( Org.tbPayment.PaidInValue / (1 + App.tbTaxCode.TaxRate)), 2, 1) END), 
			TaxOutValue = (CASE App.tbTaxCode.RoundingCode WHEN 0 THEN ROUND(Org.tbPayment.PaidOutValue - ( Org.tbPayment.PaidOutValue / (1 + App.tbTaxCode.TaxRate)), 2) WHEN 1 THEN ROUND(Org.tbPayment.PaidOutValue - ( Org.tbPayment.PaidOutValue / (1 + App.tbTaxCode.TaxRate)), 2, 1) END)
		FROM         Org.tbPayment INNER JOIN
							  App.tbTaxCode ON Org.tbPayment.TaxCode = App.tbTaxCode.TaxCode
		WHERE     (PaymentCode = @PaymentCode)

		INSERT INTO Invoice.tbInvoice
								 (InvoiceNumber, UserId, AccountCode, InvoiceTypeCode, InvoiceStatusCode, InvoicedOn, DueOn, ExpectedOn, InvoiceValue, TaxValue, PaidValue, PaidTaxValue, Printed)
		SELECT        @InvoiceNumber AS InvoiceNumber, Org.tbPayment.UserId, Org.tbPayment.AccountCode, @InvoiceTypeCode AS InvoiceTypeCode, 3 AS InvoiceStatusCode, 
								Org.tbPayment.PaidOn, Org.tbPayment.PaidOn AS DueOn, Org.tbPayment.PaidOn AS ExpectedOn,
								CASE WHEN PaidInValue > 0 THEN PaidInValue - TaxInValue
									WHEN PaidOutValue > 0 THEN PaidOutValue - TaxOutValue
								END AS InvoiceValue, 
								CASE WHEN Org.tbPayment.PaidInValue > 0 THEN Org.tbPayment.TaxInValue 
									WHEN Org.tbPayment.PaidOutValue > 0 THEN Org.tbPayment.TaxOutValue
								END AS TaxValue, 
								CASE WHEN PaidInValue > 0 THEN PaidInValue - TaxInValue
									WHEN PaidOutValue > 0 THEN PaidOutValue - TaxOutValue
								END AS PaidValue, 
								CASE WHEN Org.tbPayment.PaidInValue > 0 THEN Org.tbPayment.TaxInValue 
									WHEN Org.tbPayment.PaidOutValue > 0 THEN Org.tbPayment.TaxOutValue
								END AS PaidTaxValue, 
								1 AS Printed
		FROM            Org.tbPayment INNER JOIN
								 App.tbTaxCode ON Org.tbPayment.TaxCode = App.tbTaxCode.TaxCode
		WHERE        ( Org.tbPayment.PaymentCode = @PaymentCode)


		INSERT INTO Invoice.tbItem
							(InvoiceNumber, CashCode, InvoiceValue, TaxValue, PaidValue, PaidTaxValue, TaxCode)
		SELECT     @InvoiceNumber AS InvoiceNumber, Org.tbPayment.CashCode, 
								CASE WHEN PaidInValue > 0 THEN PaidInValue - TaxInValue
									WHEN PaidOutValue > 0 THEN PaidOutValue - TaxOutValue
								END AS InvoiceValue, 
								CASE WHEN Org.tbPayment.PaidInValue > 0 THEN Org.tbPayment.TaxInValue 
									WHEN Org.tbPayment.PaidOutValue > 0 THEN Org.tbPayment.TaxOutValue
								END AS TaxValue, 
								CASE WHEN PaidInValue > 0 THEN PaidInValue - TaxInValue
									WHEN PaidOutValue > 0 THEN PaidOutValue - TaxOutValue
								END AS PaidValue, 
								CASE WHEN Org.tbPayment.PaidInValue > 0 THEN Org.tbPayment.TaxInValue 
									WHEN Org.tbPayment.PaidOutValue > 0 THEN Org.tbPayment.TaxOutValue
								END AS PaidTaxValue, 
							Org.tbPayment.TaxCode
		FROM         Org.tbPayment INNER JOIN
							  App.tbTaxCode ON Org.tbPayment.TaxCode = App.tbTaxCode.TaxCode
		WHERE     ( Org.tbPayment.PaymentCode = @PaymentCode)

		UPDATE Invoice.tbItem
		SET PaidValue = InvoiceValue, PaidTaxValue = TaxValue
		WHERE InvoiceNumber = @InvoiceNumber

		UPDATE  Org.tbAccount
		SET CurrentBalance = CASE WHEN PaidInValue > 0 THEN Org.tbAccount.CurrentBalance + PaidInValue ELSE Org.tbAccount.CurrentBalance - PaidOutValue END
		FROM         Org.tbAccount INNER JOIN
							  Org.tbPayment ON Org.tbAccount.CashAccountCode = Org.tbPayment.CashAccountCode
		WHERE Org.tbPayment.PaymentCode = @PaymentCode

		COMMIT TRANSACTION

  	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
go

CREATE PROCEDURE Cash.proc_PayAccrual (@PaymentCode NVARCHAR(20))
AS
    SET NOCOUNT, XACT_ABORT ON;

	BEGIN TRY
		
		IF EXISTS (	SELECT        *
					FROM            Org.tbPayment 
					WHERE        (PaymentStatusCode = 2) 
						AND UserId = (SELECT UserId FROM Usr.vwCredentials))
			BEGIN

			BEGIN TRANSACTION
			EXEC Org.proc_PaymentPostMisc @PaymentCode	
			COMMIT TRANSACTION
			
			END

  	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
go

CREATE PROCEDURE Cash.proc_ReserveAccount(@CashAccountCode NVARCHAR(10) OUTPUT)
AS
	SET NOCOUNT, XACT_ABORT ON;
	BEGIN TRY
		SELECT  @CashAccountCode = Org.tbAccount.CashAccountCode
		FROM            Org.tbAccount LEFT OUTER JOIN
								 Cash.tbCode ON Org.tbAccount.CashCode = Cash.tbCode.CashCode 
		WHERE (Cash.tbCode.CashCode IS NULL) AND (Org.tbAccount.DummyAccount = 0);
	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
go

CREATE PROCEDURE Task.proc_DefaultPaymentOn
	(
		@AccountCode nvarchar(10),
		@ActionOn datetime,
		@PaymentOn datetime output
	)
AS
   	SET NOCOUNT, XACT_ABORT ON;

	BEGIN TRY

		SELECT @ActionOn = CASE WHEN org.PayDaysFromMonthEnd <> 0 
				THEN 
					DATEADD(d, -1, DATEADD(d,  org.ExpectedDays, DATEADD(m, 1, CONCAT(FORMAT(DATEADD(d, org.PaymentDays, @ActionOn), 'yyyyMM'), '01'))))												
				ELSE
					DATEADD(d, org.PaymentDays + org.ExpectedDays, @ActionOn)	
				END
		FROM Org.tbOrg org 
		WHERE org.AccountCode = @AccountCode

		SELECT @PaymentOn = App.fnAdjustToCalendar(@ActionOn, 0) 					
	 
  	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH

go

CREATE PROCEDURE Cash.proc_VatBalance(@Balance money output)
 AS
  	SET NOCOUNT, XACT_ABORT ON;

	BEGIN TRY
		SELECT TOP (1)  @Balance = Balance FROM Cash.vwTaxVatStatement ORDER BY StartOn DESC, VatDue DESC
  	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
go

CREATE PROCEDURE Invoice.proc_Total 
	(
	@InvoiceNumber nvarchar(20)
	)
  AS
   	SET NOCOUNT, XACT_ABORT ON;

	BEGIN TRY

		WITH totals AS
		(
			SELECT InvoiceNumber, SUM(InvoiceValue) AS InvoiceValue, 
				SUM(TaxValue) AS TaxValue,
				SUM(PaidValue) AS PaidValue, 
				SUM(PaidTaxValue) AS PaidTaxValue
			FROM         Invoice.tbTask
			GROUP BY InvoiceNumber
			HAVING      (InvoiceNumber = @InvoiceNumber)
			UNION
			SELECT InvoiceNumber, SUM(InvoiceValue) AS InvoiceValue, 
				SUM(TaxValue) AS TaxValue,
				SUM(PaidValue) AS PaidValue, 
				SUM(PaidTaxValue) AS PaidTaxValue
			FROM         Invoice.tbItem
			GROUP BY InvoiceNumber
			HAVING      (InvoiceNumber = @InvoiceNumber)
		), grand_total AS
		(
			SELECT InvoiceNumber, ISNULL(SUM(InvoiceValue), 0) AS InvoiceValue, 
				ISNULL(SUM(TaxValue), 0) AS TaxValue, 
				ISNULL(SUM(PaidValue), 0) AS PaidValue, 
				ISNULL(SUM(PaidTaxValue), 0) AS PaidTaxValue
			FROM totals
			GROUP BY InvoiceNumber
		) 
		UPDATE    Invoice.tbInvoice
		SET InvoiceValue = grand_total.InvoiceValue, TaxValue = grand_total.TaxValue,
			PaidValue = grand_total.PaidValue, PaidTaxValue = grand_total.PaidTaxValue,
			InvoiceStatusCode = CASE 
					WHEN grand_total.PaidValue >= grand_total.InvoiceValue THEN 3 
					WHEN grand_total.PaidValue > 0 THEN 2 
					ELSE 1 END
		FROM Invoice.tbInvoice INNER JOIN grand_total ON Invoice.tbInvoice.InvoiceNumber = grand_total.InvoiceNumber;
		
  	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
go

CREATE PROCEDURE Invoice.proc_Accept 
	(
	@InvoiceNumber nvarchar(20)
	)
AS
 	SET NOCOUNT, XACT_ABORT ON;

	BEGIN TRY
		IF EXISTS(SELECT     InvoiceNumber
	          FROM         Invoice.tbItem
	          WHERE     (InvoiceNumber = @InvoiceNumber)) 
		or EXISTS(SELECT     InvoiceNumber
	          FROM         Invoice.tbTask
	          WHERE     (InvoiceNumber = @InvoiceNumber))
		BEGIN
			BEGIN TRANSACTION
			
			EXEC Invoice.proc_Total @InvoiceNumber
			
			UPDATE    Invoice.tbInvoice
			SET              InvoiceStatusCode = 1
			WHERE     (InvoiceNumber = @InvoiceNumber) AND (InvoiceStatusCode = 0); 
	
			WITH invoiced_quantity AS
			(
				SELECT        Invoice.tbTask.TaskCode, SUM(Invoice.tbTask.Quantity) AS InvoiceQuantity
				FROM            Invoice.tbTask INNER JOIN
										 Invoice.tbInvoice ON Invoice.tbTask.InvoiceNumber = Invoice.tbInvoice.InvoiceNumber
				WHERE        (Invoice.tbInvoice.InvoiceTypeCode = 0) OR
										 (Invoice.tbInvoice.InvoiceTypeCode = 2)
				GROUP BY Invoice.tbTask.TaskCode
			)
			UPDATE       Task
			SET                TaskStatusCode = 3
			FROM            Task.tbTask AS Task INNER JOIN
									 invoiced_quantity ON Task.TaskCode = invoiced_quantity.TaskCode AND Task.Quantity <= invoiced_quantity.InvoiceQuantity INNER JOIN
									 Invoice.tbTask AS InvoiceTask ON Task.TaskCode = InvoiceTask.TaskCode AND Task.TaskCode = InvoiceTask.TaskCode
			WHERE        (InvoiceTask.InvoiceNumber = @InvoiceNumber) AND (Task.TaskStatusCode < 3);
			
			COMMIT TRANSACTION
		END
			
  	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
go

CREATE PROCEDURE Invoice.proc_AddTask 
	(
	@InvoiceNumber nvarchar(20),
	@TaskCode nvarchar(20)	
	)
 AS
  	SET NOCOUNT, XACT_ABORT ON;

	BEGIN TRY
	DECLARE 
		@InvoiceTypeCode smallint
		, @InvoiceQuantity float
		, @QuantityInvoiced float

		IF EXISTS(SELECT     InvoiceNumber, TaskCode
				  FROM         Invoice.tbTask
				  WHERE     (InvoiceNumber = @InvoiceNumber) AND (TaskCode = @TaskCode))
			RETURN
		
		SELECT   @InvoiceTypeCode = InvoiceTypeCode
		FROM         Invoice.tbInvoice
		WHERE     (InvoiceNumber = @InvoiceNumber) 

		IF EXISTS(SELECT     SUM( Invoice.tbTask.Quantity) AS QuantityInvoiced
				  FROM         Invoice.tbTask INNER JOIN
										Invoice.tbInvoice ON Invoice.tbTask.InvoiceNumber = Invoice.tbInvoice.InvoiceNumber
				  WHERE     ( Invoice.tbInvoice.InvoiceTypeCode = 0 OR
										Invoice.tbInvoice.InvoiceTypeCode = 2) AND ( Invoice.tbTask.TaskCode = @TaskCode) AND ( Invoice.tbInvoice.InvoiceStatusCode > 0))
			BEGIN
			SELECT TOP 1 @QuantityInvoiced = isnull(SUM( Invoice.tbTask.Quantity), 0)
			FROM         Invoice.tbTask INNER JOIN
					tbInvoice ON Invoice.tbTask.InvoiceNumber = Invoice.tbInvoice.InvoiceNumber
			WHERE     ( Invoice.tbInvoice.InvoiceTypeCode = 0 OR
					tbInvoice.InvoiceTypeCode = 2) AND ( Invoice.tbTask.TaskCode = @TaskCode) AND ( Invoice.tbInvoice.InvoiceStatusCode > 0)				
			END
		ELSE
			SET @QuantityInvoiced = 0
		
		IF @InvoiceTypeCode = 1 or @InvoiceTypeCode = 3
			BEGIN
			IF EXISTS(SELECT     SUM( Invoice.tbTask.Quantity) AS QuantityInvoiced
					  FROM         Invoice.tbTask INNER JOIN
											tbInvoice ON Invoice.tbTask.InvoiceNumber = Invoice.tbInvoice.InvoiceNumber
					  WHERE     ( Invoice.tbInvoice.InvoiceTypeCode = 1 OR
											tbInvoice.InvoiceTypeCode = 3) AND ( Invoice.tbTask.TaskCode = @TaskCode) AND ( Invoice.tbInvoice.InvoiceStatusCode > 0))
				BEGIN
				SELECT TOP 1 @InvoiceQuantity = isnull(@QuantityInvoiced, 0) - isnull(SUM( Invoice.tbTask.Quantity), 0)
				FROM         Invoice.tbTask INNER JOIN
						tbInvoice ON Invoice.tbTask.InvoiceNumber = Invoice.tbInvoice.InvoiceNumber
				WHERE     ( Invoice.tbInvoice.InvoiceTypeCode = 1 OR
						tbInvoice.InvoiceTypeCode = 3) AND ( Invoice.tbTask.TaskCode = @TaskCode) AND ( Invoice.tbInvoice.InvoiceStatusCode > 0)										
				END
			ELSE
				SET @InvoiceQuantity = isnull(@QuantityInvoiced, 0)
			END
		ELSE
			BEGIN
			SELECT  @InvoiceQuantity = Quantity - isnull(@QuantityInvoiced, 0)
			FROM         Task.tbTask
			WHERE     (TaskCode = @TaskCode)
			END
			
		IF isnull(@InvoiceQuantity, 0) <= 0
			SET @InvoiceQuantity = 1
		
		INSERT INTO Invoice.tbTask
							  (InvoiceNumber, TaskCode, Quantity, InvoiceValue, CashCode, TaxCode)
		SELECT     @InvoiceNumber AS InvoiceNumber, TaskCode, @InvoiceQuantity AS Quantity, UnitCharge * @InvoiceQuantity AS InvoiceValue, CashCode, 
							  TaxCode
		FROM         Task.tbTask
		WHERE     (TaskCode = @TaskCode)

		UPDATE Task.tbTask
		SET ActionedOn = CURRENT_TIMESTAMP
		WHERE TaskCode = @TaskCode;
	
		EXEC Invoice.proc_Total @InvoiceNumber	

  	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
go

CREATE PROCEDURE Invoice.proc_Cancel 
AS
  	SET NOCOUNT, XACT_ABORT ON;

	BEGIN TRY

		BEGIN TRAN

		UPDATE       Task
		SET                TaskStatusCode = 2
		FROM            Task.tbTask AS Task INNER JOIN
								 Invoice.tbTask AS InvoiceTask ON Task.TaskCode = InvoiceTask.TaskCode AND Task.TaskCode = InvoiceTask.TaskCode INNER JOIN
								 Invoice.tbInvoice ON InvoiceTask.InvoiceNumber = Invoice.tbInvoice.InvoiceNumber INNER JOIN
								 Usr.vwCredentials ON Invoice.tbInvoice.UserId = Usr.vwCredentials.UserId
		WHERE        (Invoice.tbInvoice.InvoiceTypeCode = 0 OR
								 Invoice.tbInvoice.InvoiceTypeCode = 2) AND (Invoice.tbInvoice.InvoiceStatusCode = 0)
	                      
		DELETE Invoice.tbInvoice
		FROM         Invoice.tbInvoice INNER JOIN
							  Usr.vwCredentials ON Invoice.tbInvoice.UserId = Usr.vwCredentials.UserId
		WHERE     ( Invoice.tbInvoice.InvoiceStatusCode = 0)
		
		COMMIT TRAN

  	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
go

CREATE PROCEDURE Invoice.proc_Credit
	(
		@InvoiceNumber nvarchar(20) output
	)
AS
 	SET NOCOUNT, XACT_ABORT ON;

	BEGIN TRY
	DECLARE 
		@InvoiceTypeCode smallint
		, @CreditNumber nvarchar(20)
		, @UserId nvarchar(10)
		, @NextNumber int
		, @InvoiceSuffix nvarchar(4)

		SELECT @UserId = UserId FROM Usr.vwCredentials
	
		SELECT @InvoiceTypeCode =	CASE InvoiceTypeCode 
										WHEN 0 THEN 1 
										WHEN 2 THEN 3 
										ELSE 3 
									END 
		FROM Invoice.tbInvoice WHERE InvoiceNumber = @InvoiceNumber
	
	
		SELECT @UserId = UserId FROM Usr.vwCredentials

		SET @InvoiceSuffix = '.' + @UserId
	
		SELECT @NextNumber = NextNumber
		FROM Invoice.tbType
		WHERE InvoiceTypeCode = @InvoiceTypeCode
	
		SELECT @CreditNumber = FORMAT(@NextNumber, '000000') + @InvoiceSuffix
	
		WHILE EXISTS (SELECT     InvoiceNumber
					  FROM         Invoice.tbInvoice
					  WHERE     (InvoiceNumber = @CreditNumber))
			BEGIN
			SET @NextNumber = @NextNumber + 1
			SET @CreditNumber = FORMAT(@NextNumber, '000000') + @InvoiceSuffix
			END

		BEGIN TRANSACTION

		EXEC Invoice.proc_Cancel
	
		UPDATE    Invoice.tbType
		SET              NextNumber = @NextNumber + 1
		WHERE     (InvoiceTypeCode = @InvoiceTypeCode)	
	
		INSERT INTO Invoice.tbInvoice	
							(InvoiceNumber, InvoiceStatusCode, AccountCode, InvoiceValue, TaxValue, UserId, InvoiceTypeCode, InvoicedOn)
		SELECT     @CreditNumber AS InvoiceNumber, 0 AS InvoiceStatusCode, AccountCode, InvoiceValue, TaxValue, @UserId AS UserId, 
							@InvoiceTypeCode AS InvoiceTypeCode, CURRENT_TIMESTAMP AS InvoicedOn
		FROM         Invoice.tbInvoice
		WHERE     (InvoiceNumber = @InvoiceNumber)
	
		INSERT INTO Invoice.tbItem
							  (InvoiceNumber, CashCode, TaxCode, InvoiceValue, TaxValue)
		SELECT     @CreditNumber AS InvoiceNumber, CashCode, TaxCode, InvoiceValue, TaxValue
		FROM         Invoice.tbItem
		WHERE     (InvoiceNumber = @InvoiceNumber)
	
		INSERT INTO Invoice.tbTask
							  (InvoiceNumber, TaskCode, Quantity, InvoiceValue, TaxValue, CashCode, TaxCode)
		SELECT     @CreditNumber AS InvoiceNumber, TaskCode, Quantity, InvoiceValue, TaxValue, CashCode, TaxCode
		FROM         Invoice.tbTask
		WHERE     (InvoiceNumber = @InvoiceNumber)

		SET @InvoiceNumber = @CreditNumber
	
		COMMIT TRANSACTION
	 
  	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
go

CREATE PROCEDURE Invoice.proc_DefaultDocType
	(
		@InvoiceNumber nvarchar(20),
		@DocTypeCode smallint OUTPUT
	)
AS
 	SET NOCOUNT, XACT_ABORT ON;

	BEGIN TRY
		DECLARE @InvoiceTypeCode smallint

			SELECT  @InvoiceTypeCode = InvoiceTypeCode
			FROM         Invoice.tbInvoice
			WHERE     (InvoiceNumber = @InvoiceNumber)
	
			SET @DocTypeCode = CASE @InvoiceTypeCode
									WHEN 0 THEN 4
									WHEN 1 THEN 5							
									WHEN 3 THEN 6
									ELSE 4
									END
							
  	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
go

CREATE PROCEDURE Org.proc_BalanceOutstanding 
	(
	@AccountCode nvarchar(10),
	@Balance money = 0 OUTPUT
	)
AS
   	SET NOCOUNT, XACT_ABORT ON;

	BEGIN TRY		
		
		SELECT @Balance = ISNULL(Balance, 0) FROM Org.vwBalanceOutstanding WHERE AccountCode = @AccountCode

		IF EXISTS(SELECT     AccountCode
				  FROM         Org.tbPayment
				  WHERE     (PaymentStatusCode = 0) AND (AccountCode = @AccountCode)) AND (@Balance <> 0)
			BEGIN
			SELECT  @Balance = @Balance - SUM(PaidInValue - PaidOutValue) 
			FROM         Org.tbPayment
			WHERE     (PaymentStatusCode = 0) AND (AccountCode = @AccountCode)		
			END
		
  	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
go

CREATE PROCEDURE Org.proc_PaymentPostPaidIn
	(
	@PaymentCode nvarchar(20),
	@PostValue money  
	)
 AS
  	SET NOCOUNT, XACT_ABORT ON;

	BEGIN TRY
		DECLARE 
			@InvoiceNumber nvarchar(20)
			, @TaskCode nvarchar(20)
			, @TaxRate real
			, @ItemValue money
			, @RoundingCode smallint
			, @PaidValue money	
			, @PaidTaxValue money
			, @TaxInValue money = 0
			, @TaxOutValue money = 0
			, @CashCode nvarchar(50)	
			, @TaxCode nvarchar(10)

	
		DECLARE curPaidIn CURSOR LOCAL FOR
			SELECT     Invoice.vwOutstanding.InvoiceNumber, Invoice.vwOutstanding.TaskCode, Invoice.vwOutstanding.CashCode, Invoice.vwOutstanding.TaxCode, 
								  Invoice.vwOutstanding.TaxRate, Invoice.vwOutstanding.ItemValue, Invoice.vwOutstanding.RoundingCode
			FROM         Invoice.vwOutstanding INNER JOIN
								  Org.tbPayment ON Invoice.vwOutstanding.AccountCode = Org.tbPayment.AccountCode
			WHERE     ( Org.tbPayment.PaymentCode = @PaymentCode)
			ORDER BY Invoice.vwOutstanding.CashModeCode, Invoice.vwOutstanding.ExpectedOn

		OPEN curPaidIn
		FETCH NEXT FROM curPaidIn INTO @InvoiceNumber, @TaskCode, @CashCode, @TaxCode, @TaxRate, @ItemValue, @RoundingCode
		WHILE @@FETCH_STATUS = 0 and @PostValue < 0
			BEGIN
			IF (@PostValue + @ItemValue) > 0
				SET @ItemValue = @PostValue * -1

			SET @PaidTaxValue = (CASE @RoundingCode WHEN 0 THEN ROUND(ABS(@ItemValue) - (ABS(@ItemValue) / (1 + @TaxRate)), 2) WHEN 1 THEN ROUND(ABS(@ItemValue) - (ABS(@ItemValue) / (1 + @TaxRate)), 2, 1) END)
			SET @PaidValue = ABS(@ItemValue) - @PaidTaxValue
				
			SET @PostValue = @PostValue + @ItemValue
		
			IF @TaskCode IS NULL
				BEGIN
				UPDATE    Invoice.tbItem
				SET              PaidValue = PaidValue + @PaidValue, PaidTaxValue = PaidTaxValue + @PaidTaxValue
				WHERE     (InvoiceNumber = @InvoiceNumber) AND (CashCode = @CashCode)
				END
			ELSE
				BEGIN
				UPDATE   Invoice.tbTask
				SET              PaidValue = PaidValue + @PaidValue, PaidTaxValue = PaidTaxValue + @PaidTaxValue
				WHERE     (InvoiceNumber = @InvoiceNumber) AND (TaskCode = @TaskCode)				
				END

			EXEC Invoice.proc_Total @InvoiceNumber
		        		  
			SET @TaxInValue += CASE WHEN @ItemValue > 0 THEN @PaidTaxValue ELSE 0 END
			SET @TaxOutValue += CASE WHEN @ItemValue < 0 THEN @PaidTaxValue ELSE 0 END	
				
			FETCH NEXT FROM curPaidIn INTO @InvoiceNumber, @TaskCode, @CashCode, @TaxCode, @TaxRate, @ItemValue, @RoundingCode
			END
	
		CLOSE curPaidIn
		DEALLOCATE curPaidIn
	
	
		IF NOT @CashCode IS NULL
			BEGIN
			UPDATE    Org.tbPayment
			SET      PaymentStatusCode = 1, TaxInValue = @TaxInValue, TaxOutValue = @TaxOutValue, 
				CashCode = ISNULL(@CashCode, Org.tbPayment.CashCode), 
				TaxCode = ISNULL(@TaxCode, Org.tbPayment.TaxCode)
			WHERE     (PaymentCode = @PaymentCode)
			END	
			
  	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
go

CREATE PROCEDURE Org.proc_PaymentPostPaidOut
	(
	@PaymentCode nvarchar(20),
	@PostValue money  
	)
 AS
  	SET NOCOUNT, XACT_ABORT ON;

	BEGIN TRY
		DECLARE 
			@InvoiceNumber nvarchar(20)	
			, @TaskCode nvarchar(20)
			, @TaxRate real
			, @ItemValue money
			, @RoundingCode smallint
			, @PaidValue money	
			, @PaidTaxValue money
			, @TaxInValue money = 0
			, @TaxOutValue money = 0
			, @CashCode nvarchar(50)	
			, @TaxCode nvarchar(10)


		DECLARE curPaidOut CURSOR LOCAL FOR
			SELECT     Invoice.vwOutstanding.InvoiceNumber, Invoice.vwOutstanding.TaskCode, Invoice.vwOutstanding.CashCode, Invoice.vwOutstanding.TaxCode, 
								  Invoice.vwOutstanding.TaxRate, Invoice.vwOutstanding.ItemValue, Invoice.vwOutstanding.RoundingCode
			FROM         Invoice.vwOutstanding INNER JOIN
								  Org.tbPayment ON Invoice.vwOutstanding.AccountCode = Org.tbPayment.AccountCode
			WHERE     ( Org.tbPayment.PaymentCode = @PaymentCode)
			ORDER BY Invoice.vwOutstanding.CashModeCode DESC, Invoice.vwOutstanding.ExpectedOn

		OPEN curPaidOut
		FETCH NEXT FROM curPaidOut INTO @InvoiceNumber, @TaskCode, @CashCode, @TaxCode, @TaxRate, @ItemValue, @RoundingCode
		WHILE @@FETCH_STATUS = 0 and @PostValue > 0
			BEGIN
			IF (@PostValue + @ItemValue) < 0
				SET @ItemValue = @PostValue * -1

			SET @PaidTaxValue = (CASE @RoundingCode WHEN 0 THEN ROUND(ABS(@ItemValue) - (ABS(@ItemValue) / (1 + @TaxRate)), 2) WHEN 1 THEN ROUND(ABS(@ItemValue) - (ABS(@ItemValue) / (1 + @TaxRate)), 2, 1) END)
			SET @PaidValue = ABS(@ItemValue) - @PaidTaxValue
				
			SET @PostValue = @PostValue + @ItemValue
		
			IF @TaskCode IS NULL
				BEGIN
				UPDATE    Invoice.tbItem
				SET              PaidValue = PaidValue + @PaidValue, PaidTaxValue = PaidTaxValue + @PaidTaxValue
				WHERE     (InvoiceNumber = @InvoiceNumber) AND (CashCode = @CashCode)
				END
			ELSE
				BEGIN
				UPDATE   Invoice.tbTask
				SET              PaidValue = PaidValue + @PaidValue, PaidTaxValue = PaidTaxValue + @PaidTaxValue
				WHERE     (InvoiceNumber = @InvoiceNumber) AND (TaskCode = @TaskCode)				
				END

			EXEC Invoice.proc_Total @InvoiceNumber
		        		  
			SET @TaxInValue += CASE WHEN @ItemValue > 0 THEN @PaidTaxValue ELSE 0 END
			SET @TaxOutValue += CASE WHEN @ItemValue < 0 THEN @PaidTaxValue ELSE 0 END	
				
			FETCH NEXT FROM curPaidOut INTO @InvoiceNumber, @TaskCode, @CashCode, @TaxCode, @TaxRate, @ItemValue, @RoundingCode
			END
		
		CLOSE curPaidOut
		DEALLOCATE curPaidOut

		IF NOT @CashCode IS NULL
			BEGIN
			UPDATE    Org.tbPayment
			SET      PaymentStatusCode = 1, TaxInValue = @TaxInValue, TaxOutValue = @TaxOutValue, 
				CashCode = ISNULL(@CashCode, Org.tbPayment.CashCode), 
				TaxCode = ISNULL(@TaxCode, Org.tbPayment.TaxCode)
			WHERE     (PaymentCode = @PaymentCode)
			END
	
  	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
go

CREATE PROCEDURE Org.proc_PaymentPostInvoiced (@PaymentCode nvarchar(20))
AS
	SET NOCOUNT, XACT_ABORT ON;

	BEGIN TRY
		DECLARE 
			@AccountCode nvarchar(10)
			, @CashModeCode smallint
			, @PostValue money

		SELECT   @PostValue = CASE WHEN PaidInValue = 0 THEN PaidOutValue ELSE PaidInValue * -1 END,
			@AccountCode = Org.tbOrg.AccountCode,
			@CashModeCode = CASE WHEN PaidInValue = 0 THEN 0 ELSE 1 END
		FROM         Org.tbPayment INNER JOIN
							  Org.tbOrg ON Org.tbPayment.AccountCode = Org.tbOrg.AccountCode
		WHERE     ( Org.tbPayment.PaymentCode = @PaymentCode);

		BEGIN TRANSACTION

		IF @CashModeCode = 1
			EXEC Org.proc_PaymentPostPaidIn @PaymentCode, @PostValue 
		ELSE
			EXEC Org.proc_PaymentPostPaidOut @PaymentCode, @PostValue

		UPDATE  Org.tbAccount
		SET CurrentBalance = Org.tbAccount.CurrentBalance + (@PostValue * -1)
		FROM         Org.tbAccount INNER JOIN
							  Org.tbPayment ON Org.tbAccount.CashAccountCode = Org.tbPayment.CashAccountCode
		WHERE Org.tbPayment.PaymentCode = @PaymentCode
		
		COMMIT TRANSACTION

  	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
go

CREATE PROCEDURE Invoice.proc_Pay
	(
	@InvoiceNumber nvarchar(20),
	@PaidOn datetime,
	@Post bit = 1,
	@PaymentCode nvarchar(20) NULL OUTPUT
	)
AS
 	SET NOCOUNT, XACT_ABORT ON;

	BEGIN TRY
	DECLARE 
		@PaidOut money = 0
		, @PaidIn money = 0
		, @BalanceOutstanding money = 0
		, @TaskOutstanding money = 0
		, @ItemOutstanding money = 0
		, @CashModeCode smallint
		, @AccountCode nvarchar(10)
		, @CashAccountCode nvarchar(10)
		, @InvoiceStatusCode smallint
		, @UserId nvarchar(10)
		, @PaymentReference nvarchar(20)
		, @PayBalance BIT

		SELECT 
			@CashModeCode = Invoice.tbType.CashModeCode, 
			@AccountCode = Invoice.tbInvoice.AccountCode, 
			@PayBalance = Org.tbOrg.PayBalance,
			@InvoiceStatusCode = Invoice.tbInvoice.InvoiceStatusCode
		FROM Invoice.tbInvoice 
			INNER JOIN Invoice.tbType ON Invoice.tbInvoice.InvoiceTypeCode = Invoice.tbType.InvoiceTypeCode
			INNER JOIN Org.tbOrg ON Invoice.tbInvoice.AccountCode = Org.tbOrg.AccountCode
		WHERE     ( Invoice.tbInvoice.InvoiceNumber = @InvoiceNumber)
	
		EXEC Org.proc_BalanceOutstanding @AccountCode, @BalanceOutstanding OUTPUT
		IF @BalanceOutstanding = 0 
		BEGIN
			DECLARE @Msg NVARCHAR(MAX);
			SELECT @Msg = Message FROM App.tbText WHERE TextId = 3018;
			RAISERROR (@Msg, 10, 1)
		END
		ELSE IF @InvoiceStatusCode > 2
			RETURN 1

		SELECT @UserId = UserId FROM Usr.vwCredentials	
		SET @PaidOn = CAST(@PaidOn AS DATE)

		SET @PaymentCode = CONCAT(@UserId, '_', FORMAT(@PaidOn, 'yyyymmdd_hhmmss'))

		WHILE EXISTS (SELECT * FROM Org.tbPayment WHERE PaymentCode = @PaymentCode)
			BEGIN
			SET @PaidOn = DATEADD(s, 1, @PaidOn)
			SET @PaymentCode = CONCAT(@UserId, '_', FORMAT(@PaidOn, 'yyyymmdd_hhmmss'))
			END
			
		IF @PayBalance = 0
			BEGIN	
			SET @PaymentReference = @InvoiceNumber
															
			SELECT  @TaskOutstanding = SUM( Invoice.tbTask.InvoiceValue + Invoice.tbTask.TaxValue - Invoice.tbTask.PaidValue - Invoice.tbTask.PaidTaxValue)
			FROM         Invoice.tbInvoice INNER JOIN
								  Invoice.tbTask ON Invoice.tbInvoice.InvoiceNumber = Invoice.tbTask.InvoiceNumber INNER JOIN
								  Invoice.tbType ON Invoice.tbInvoice.InvoiceTypeCode = Invoice.tbType.InvoiceTypeCode
			WHERE     ( Invoice.tbInvoice.InvoiceNumber = @InvoiceNumber)
			GROUP BY Invoice.tbType.CashModeCode


			SELECT @ItemOutstanding = SUM( Invoice.tbItem.InvoiceValue + Invoice.tbItem.TaxValue - Invoice.tbItem.PaidValue - Invoice.tbItem.PaidTaxValue)
			FROM         Invoice.tbInvoice INNER JOIN
								  Invoice.tbItem ON Invoice.tbInvoice.InvoiceNumber = Invoice.tbItem.InvoiceNumber
			WHERE     ( Invoice.tbInvoice.InvoiceNumber = @InvoiceNumber)

			IF @CashModeCode = 0
				BEGIN
				SET @PaidOut = ISNULL(@TaskOutstanding, 0) + ISNULL(@ItemOutstanding, 0)
				SET @PaidIn = 0
				END
			ELSE
				BEGIN
				SET @PaidIn = ISNULL(@TaskOutstanding, 0) + ISNULL(@ItemOutstanding, 0)
				SET @PaidOut = 0
				END
			END
		ELSE
			BEGIN
			SET @PaidIn = CASE WHEN @BalanceOutstanding > 0 THEN @BalanceOutstanding ELSE 0 END
			SET @PaidOut = CASE WHEN @BalanceOutstanding < 0 THEN ABS(@BalanceOutstanding) ELSE 0 END
			END
	
		EXEC Cash.proc_CurrentAccount @CashAccountCode OUTPUT

		BEGIN TRANSACTION

		IF @PaidIn + @PaidOut > 0
			BEGIN			

			INSERT INTO Org.tbPayment
								  (PaymentCode, UserId, PaymentStatusCode, AccountCode, CashAccountCode, PaidOn, PaidInValue, PaidOutValue, PaymentReference)
			VALUES     (@PaymentCode,@UserId, 0, @AccountCode, @CashAccountCode, @PaidOn, @PaidIn, @PaidOut, @PaymentReference)		
		
			IF @Post <> 0
				EXEC Org.proc_PaymentPostInvoiced @PaymentCode			
			END
		
		IF @@TRANCOUNT > 0
			COMMIT TRANSACTION

  	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
go
CREATE PROCEDURE Invoice.proc_DefaultPaymentOn
	(
		@AccountCode nvarchar(10),
		@ActionOn datetime,
		@PaymentOn datetime output
	)
AS
   	SET NOCOUNT, XACT_ABORT ON;

	BEGIN TRY

		SELECT @ActionOn = CASE WHEN org.PayDaysFromMonthEnd <> 0 
				THEN 
					DATEADD(d, -1, DATEADD(m, 1, CONCAT(FORMAT(DATEADD(d, org.PaymentDays, @ActionOn), 'yyyyMM'), '01')))												
				ELSE
					DATEADD(d, org.PaymentDays, @ActionOn)	
				END
		FROM Org.tbOrg org 
		WHERE org.AccountCode = @AccountCode

		SELECT @PaymentOn = App.fnAdjustToCalendar(@ActionOn, 0) 					
	 
  	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
go

CREATE PROCEDURE Invoice.proc_Raise
	(
	@TaskCode nvarchar(20),
	@InvoiceTypeCode smallint,
	@InvoicedOn datetime,
	@InvoiceNumber nvarchar(20) = null output
	)
AS
 	SET NOCOUNT, XACT_ABORT ON;

	BEGIN TRY
	DECLARE 
		@UserId nvarchar(10)
		, @NextNumber int
		, @InvoiceSuffix nvarchar(4)
		, @AccountCode nvarchar(10)
	
		SELECT @UserId = UserId FROM Usr.vwCredentials

		SET @InvoiceSuffix = '.' + @UserId
	
		SELECT @NextNumber = NextNumber
		FROM Invoice.tbType
		WHERE InvoiceTypeCode = @InvoiceTypeCode
	
		SELECT @InvoiceNumber = FORMAT(@NextNumber, '000000') + @InvoiceSuffix
	
		WHILE EXISTS (SELECT     InvoiceNumber
					  FROM         Invoice.tbInvoice
					  WHERE     (InvoiceNumber = @InvoiceNumber))
			BEGIN
			SET @NextNumber = @NextNumber + 1
			SET @InvoiceNumber = FORMAT(@NextNumber, '000000') + @InvoiceSuffix
			END

		SET @InvoicedOn = isnull(CAST(@InvoicedOn AS DATE), CAST(CURRENT_TIMESTAMP AS DATE))
		SELECT @AccountCode = AccountCode FROM Task.tbTask WHERE TaskCode = @TaskCode


		BEGIN TRANSACTION
	
		EXEC Invoice.proc_Cancel
	
		UPDATE    Invoice.tbType
		SET              NextNumber = @NextNumber + 1
		WHERE     (InvoiceTypeCode = @InvoiceTypeCode)
	
		INSERT INTO Invoice.tbInvoice
							(InvoiceNumber, UserId, AccountCode, InvoiceTypeCode, InvoicedOn, InvoiceStatusCode, PaymentTerms)
		SELECT     @InvoiceNumber AS InvoiceNumber, @UserId AS UserId, Task.tbTask.AccountCode, @InvoiceTypeCode AS InvoiceTypeCode, @InvoicedOn AS InvoicedOn, 
							0 AS InvoiceStatusCode, Org.tbOrg.PaymentTerms
		FROM         Task.tbTask INNER JOIN
							Org.tbOrg ON Task.tbTask.AccountCode = Org.tbOrg.AccountCode
		WHERE     ( Task.tbTask.TaskCode = @TaskCode)

		EXEC Invoice.proc_AddTask @InvoiceNumber, @TaskCode
	
		IF @@TRANCOUNT > 0		
			COMMIT TRANSACTION
	
  	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
go

CREATE PROCEDURE Invoice.proc_RaiseBlank
	(
	@AccountCode nvarchar(10),
	@InvoiceTypeCode smallint,
	@InvoiceNumber nvarchar(20) = null output
	)
  AS
  SET NOCOUNT, XACT_ABORT ON;
	BEGIN TRY
		DECLARE 
			@UserId nvarchar(10)
			, @NextNumber int
			, @InvoiceSuffix nvarchar(4)
			, @InvoicedOn datetime

		SELECT @UserId = UserId FROM Usr.vwCredentials

		SET @InvoiceSuffix = '.' + @UserId
	
		SELECT @NextNumber = NextNumber
		FROM Invoice.tbType
		WHERE InvoiceTypeCode = @InvoiceTypeCode
	
		SELECT @InvoiceNumber = FORMAT(@NextNumber, '000000') + @InvoiceSuffix
	
		WHILE EXISTS (SELECT     InvoiceNumber
						FROM         Invoice.tbInvoice
						WHERE     (InvoiceNumber = @InvoiceNumber))
			BEGIN
			SET @NextNumber = @NextNumber + 1
			SET @InvoiceNumber = FORMAT(@NextNumber, '000000') + @InvoiceSuffix
			END
		
		SET @InvoicedOn = isnull(CAST(@InvoicedOn AS DATE), CAST(CURRENT_TIMESTAMP AS DATE))

		BEGIN TRANSACTION
	
		EXEC Invoice.proc_Cancel
	
		UPDATE    Invoice.tbType
		SET              NextNumber = @NextNumber + 1
		WHERE     (InvoiceTypeCode = @InvoiceTypeCode)
	
		INSERT INTO Invoice.tbInvoice
								(InvoiceNumber, UserId, AccountCode, InvoiceTypeCode, InvoicedOn, InvoiceStatusCode)
		VALUES     (@InvoiceNumber, @UserId, @AccountCode, @InvoiceTypeCode, @InvoicedOn, 0)
	
		COMMIT TRANSACTION
	
	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog
	END CATCH

go

CREATE PROCEDURE Org.proc_NextAddressCode 
	(
	@AccountCode nvarchar(10),
	@AddressCode nvarchar(15) OUTPUT
	)
  AS
   	SET NOCOUNT, XACT_ABORT ON;

	BEGIN TRY
		DECLARE @AddCount int

		SELECT @AddCount = ISNULL(COUNT(AddressCode), 0) 
		FROM         Org.tbAddress
		WHERE     (AccountCode = @AccountCode)
	
		SET @AddCount += 1
		SET @AddressCode = CONCAT(UPPER(@AccountCode), '_', FORMAT(@AddCount, '000'))
	
  	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
go

CREATE PROCEDURE Org.proc_AddAddress 
	(
	@AccountCode nvarchar(10),
	@Address ntext
	)
AS
 	SET NOCOUNT, XACT_ABORT ON;

	BEGIN TRY
		DECLARE @AddressCode nvarchar(15)
	
		EXECUTE Org.proc_NextAddressCode @AccountCode, @AddressCode OUTPUT
	
		INSERT INTO Org.tbAddress
							  (AddressCode, AccountCode, Address)
		VALUES     (@AddressCode, @AccountCode, @Address)
	
		IF NOT EXISTS (SELECT * FROM Org.tbOrg org JOIN Org.tbAddress org_addr ON org.AddressCode = org_addr.AddressCode WHERE org.AccountCode = @AccountCode)
		BEGIN
			UPDATE Org.tbOrg
			SET AddressCode = @AddressCode
			WHERE Org.tbOrg.AccountCode = @AccountCode
		END

  	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
go

CREATE PROCEDURE Org.proc_AddContact 
	(
	@AccountCode nvarchar(10),
	@ContactName nvarchar(100)	 
	)
  AS
   	SET NOCOUNT, XACT_ABORT ON;

	BEGIN TRY
	
		INSERT INTO Org.tbContact
								(AccountCode, ContactName, PhoneNumber, EmailAddress)
		SELECT     AccountCode, @ContactName AS ContactName, PhoneNumber, EmailAddress
		FROM         Org.tbOrg
		WHERE AccountCode = @AccountCode
	
  	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
go

CREATE PROCEDURE Org.proc_BalanceToPay(@AccountCode NVARCHAR(10), @Balance MONEY = 0 OUTPUT)
AS
	SET NOCOUNT, XACT_ABORT ON;

	BEGIN TRY
		DECLARE @PayBalance BIT

		SELECT @PayBalance = PayBalance FROM Org.tbOrg WHERE AccountCode = @AccountCode

		IF @PayBalance <> 0
			EXEC Org.proc_BalanceOutstanding @AccountCode, @Balance OUTPUT
		ELSE
			BEGIN
			SELECT TOP (1)   @Balance = CASE Invoice.tbType.CashModeCode 
											WHEN 0 THEN ((InvoiceValue + TaxValue) - (PaidValue + PaidTaxValue)) * - 1 
											WHEN 1 THEN (InvoiceValue + TaxValue) - (PaidValue + PaidTaxValue) END 
			FROM            Invoice.tbInvoice INNER JOIN
									 Invoice.tbType ON Invoice.tbInvoice.InvoiceTypeCode = Invoice.tbType.InvoiceTypeCode
			WHERE  Invoice.tbInvoice.AccountCode = @AccountCode AND (Invoice.tbInvoice.InvoiceStatusCode > 0) AND (Invoice.tbInvoice.InvoiceStatusCode < 3) 
			ORDER BY ExpectedOn
			END

		SET @Balance = ISNULL(@Balance, 0)

	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
go

CREATE PROCEDURE Org.proc_DefaultAccountCode 
	(
	@AccountName nvarchar(100),
	@AccountCode nvarchar(10) OUTPUT 
	)
AS
   	SET NOCOUNT, XACT_ABORT ON;

	BEGIN TRY
		DECLARE 
			@ParsedName nvarchar(100)
			, @FirstWord nvarchar(100)
			, @SecondWord nvarchar(100)
			, @ValidatedCode nvarchar(10)
			, @c char(1)
			, @ASCII smallint
			, @pos int
			, @ok bit
			, @Suffix smallint
			, @Rows int
		
		SET @pos = 1
		SET @ParsedName = ''

		WHILE @pos <= datalength(@AccountName)
		BEGIN
			SET @ASCII = ASCII(SUBSTRING(@AccountName, @pos, 1))
			SET @ok = CASE 
				WHEN @ASCII = 32 THEN 1
				WHEN @ASCII = 45 THEN 1
				WHEN (@ASCII >= 48 and @ASCII <= 57) THEN 1
				WHEN (@ASCII >= 65 and @ASCII <= 90) THEN 1
				WHEN (@ASCII >= 97 and @ASCII <= 122) THEN 1
				ELSE 0
			END
			IF @ok = 1
				SELECT @ParsedName = @ParsedName + char(ASCII(SUBSTRING(@AccountName, @pos, 1)))
			SET @pos = @pos + 1
		END

		--print @ParsedName
		
		IF CHARINDEX(' ', @ParsedName) = 0
			BEGIN
			SET @FirstWord = @ParsedName
			SET @SecondWord = ''
			END
		ELSE
			BEGIN
			SET @FirstWord = left(@ParsedName, CHARINDEX(' ', @ParsedName) - 1)
			SET @SecondWord = right(@ParsedName, LEN(@ParsedName) - CHARINDEX(' ', @ParsedName))
			IF CHARINDEX(' ', @SecondWord) > 0
				SET @SecondWord = left(@SecondWord, CHARINDEX(' ', @SecondWord) - 1)
			END

		IF EXISTS(SELECT ExcludedTag FROM App.tbCodeExclusion WHERE ExcludedTag = @SecondWord)
			BEGIN
			SET @SecondWord = ''
			END

		--print @FirstWord
		--print @SecondWord

		IF LEN(@SecondWord) > 0
			SET @AccountCode = UPPER(left(@FirstWord, 3)) + UPPER(left(@SecondWord, 3))		
		ELSE
			SET @AccountCode = UPPER(left(@FirstWord, 6))

		SET @ValidatedCode = @AccountCode
		SELECT @rows = COUNT(AccountCode) FROM Org.tbOrg WHERE AccountCode = @ValidatedCode
		SET @Suffix = 0
	
		WHILE @rows > 0
		BEGIN
			SET @Suffix = @Suffix + 1
			SET @ValidatedCode = @AccountCode + LTRIM(STR(@Suffix))
			SELECT @rows = COUNT(AccountCode) FROM Org.tbOrg WHERE AccountCode = @ValidatedCode
		END
	
		SET @AccountCode = @ValidatedCode
	
  	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
go

CREATE PROCEDURE Org.proc_DefaultTaxCode 
	(
	@AccountCode nvarchar(10),
	@TaxCode nvarchar(10) OUTPUT
	)
  AS
   	SET NOCOUNT, XACT_ABORT ON;

	BEGIN TRY
		IF EXISTS(SELECT     Org.tbOrg.AccountCode
				  FROM         Org.tbOrg INNER JOIN
										App.tbOptions ON Org.tbOrg.AccountCode = App.tbOptions.AccountCode)
			BEGIN
			SELECT @TaxCode = Org.tbOrg.TaxCode
				  FROM         Org.tbOrg INNER JOIN
										App.tbOptions ON Org.tbOrg.AccountCode = App.tbOptions.AccountCode
		
			END	                              

  	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
go

CREATE PROCEDURE Org.proc_NextPaymentCode (@PaymentCode NVARCHAR(20) OUTPUT)
AS
	SET NOCOUNT, XACT_ABORT ON;

	BEGIN TRY
		SELECT @PaymentCode = PaymentCode FROM Org.vwPaymentCode;
	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
go

CREATE PROCEDURE Org.proc_PaymentAdd(@AccountCode nvarchar(10), @CashAccountCode AS nvarchar(10), @CashCode nvarchar(50), @PaidOn datetime, @ToPay money, @PaymentCode nvarchar(20) output)
AS
	SET NOCOUNT, XACT_ABORT ON;
	BEGIN TRY
		
		EXECUTE Org.proc_NextPaymentCode  @PaymentCode OUTPUT

		INSERT INTO Org.tbPayment (PaymentCode, UserId, PaymentStatusCode, AccountCode, CashAccountCode, CashCode, TaxCode, PaidOn, PaidInValue, PaidOutValue, TaxInValue, TaxOutValue)
		SELECT   @PaymentCode AS PaymentCode, 
			(SELECT UserId FROM Usr.vwCredentials) AS UserId,
			0 AS PaymentStatusCode,
			@AccountCode AS AccountCode,
			@CashAccountCode AS CashAccountCode,
			@CashCode AS CashCode,
			Cash.tbCode.TaxCode,
			@PaidOn As PaidOn,
			CASE WHEN @ToPay > 0 THEN @ToPay ELSE 0 END AS PaidInValue,
			CASE WHEN @ToPay < 0 THEN ABS(@ToPay) ELSE 0 END AS PaidOutValue,
			CASE WHEN @ToPay > 0 THEN @ToPay * App.tbTaxCode.TaxRate ELSE 0 END AS TaxInValue,
			CASE WHEN @ToPay < 0 THEN ABS(@ToPay) * App.tbTaxCode.TaxRate ELSE 0 END AS TaxOutValue
		FROM            Cash.tbCode INNER JOIN
								 Cash.tbCategory ON Cash.tbCode.CategoryCode = Cash.tbCategory.CategoryCode INNER JOIN
								 App.tbTaxCode ON Cash.tbCode.TaxCode = App.tbTaxCode.TaxCode
		WHERE        (Cash.tbCode.CashCode = @CashCode)


	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH

go

CREATE PROCEDURE Org.proc_Rebuild (@AccountCode NVARCHAR(10))
AS
  	SET NOCOUNT, XACT_ABORT ON;

	DECLARE @tbPartialInvoice TABLE (
			AccountCode NVARCHAR(10), 
			InvoiceNumber NVARCHAR(10),
			RefType SMALLINT,
			RefCode NVARCHAR(20),
			TotalPaidValue MONEY
			);

	BEGIN TRY
		BEGIN TRANSACTION;
		--payments
		UPDATE Org.tbPayment
		SET
			TaxInValue = PaidInValue - CASE App.tbTaxCode.RoundingCode 
				WHEN 0 THEN ROUND((PaidInValue / (1 + TaxRate)), 2)
				WHEN 1 THEN ROUND((PaidInValue / (1 + TaxRate)), 2, 1) END, 
			TaxOutValue = PaidOutValue - CASE App.tbTaxCode.RoundingCode 
				WHEN 0 THEN ROUND((PaidOutValue / (1 + TaxRate)), 2)
				WHEN 1 THEN ROUND((PaidOutValue / (1 + TaxRate)), 2, 1) END
		FROM         Org.tbPayment INNER JOIN
								App.tbTaxCode ON Org.tbPayment.TaxCode = App.tbTaxCode.TaxCode
		WHERE AccountCode = @AccountCode;

		--invoices
		IF EXISTS(SELECT * FROM Org.tbPayment WHERE AccountCode = @AccountCode)
		BEGIN
			UPDATE Invoice.tbItem
			SET TaxValue = CASE App.tbTaxCode.RoundingCode 
					WHEN 0 THEN ROUND(Invoice.tbItem.InvoiceValue * App.tbTaxCode.TaxRate, 2)
					WHEN 1 THEN ROUND( Invoice.tbItem.InvoiceValue * App.tbTaxCode.TaxRate, 2, 1) END,
				PaidValue = Invoice.tbItem.InvoiceValue, 
				PaidTaxValue = CASE App.tbTaxCode.RoundingCode 
					WHEN 0 THEN ROUND(Invoice.tbItem.InvoiceValue * App.tbTaxCode.TaxRate, 2)
					WHEN 1 THEN ROUND( Invoice.tbItem.InvoiceValue * App.tbTaxCode.TaxRate, 2, 1) END
			FROM         Invoice.tbItem INNER JOIN
									App.tbTaxCode ON Invoice.tbItem.TaxCode = App.tbTaxCode.TaxCode INNER JOIN
									Invoice.tbInvoice ON Invoice.tbItem.InvoiceNumber = Invoice.tbInvoice.InvoiceNumber
			WHERE     ( Invoice.tbInvoice.InvoiceStatusCode <> 0)
				AND (AccountCode = @AccountCode);
                      
			UPDATE Invoice.tbTask
			SET TaxValue = CASE App.tbTaxCode.RoundingCode 
					WHEN 0 THEN ROUND(Invoice.tbTask.InvoiceValue * App.tbTaxCode.TaxRate, 2)
					WHEN 1 THEN ROUND( Invoice.tbTask.InvoiceValue * App.tbTaxCode.TaxRate, 2, 1) END,
				PaidValue = Invoice.tbTask.InvoiceValue,
				PaidTaxValue = CASE App.tbTaxCode.RoundingCode 
					WHEN 0 THEN ROUND(Invoice.tbTask.InvoiceValue * App.tbTaxCode.TaxRate, 2)
					WHEN 1 THEN ROUND( Invoice.tbTask.InvoiceValue * App.tbTaxCode.TaxRate, 2, 1) END
			FROM         Invoice.tbTask INNER JOIN
									App.tbTaxCode ON Invoice.tbTask.TaxCode = App.tbTaxCode.TaxCode INNER JOIN
									Invoice.tbInvoice ON Invoice.tbTask.InvoiceNumber = Invoice.tbInvoice.InvoiceNumber
			WHERE     ( Invoice.tbInvoice.InvoiceStatusCode <> 0)
				AND (AccountCode = @AccountCode);
		END
		ELSE
		BEGIN
			UPDATE Invoice.tbItem
			SET TaxValue = CASE App.tbTaxCode.RoundingCode 
					WHEN 0 THEN ROUND(Invoice.tbItem.InvoiceValue * App.tbTaxCode.TaxRate, 2)
					WHEN 1 THEN ROUND( Invoice.tbItem.InvoiceValue * App.tbTaxCode.TaxRate, 2, 1) END,
				PaidValue = 0,
				PaidTaxValue = 0
			FROM         Invoice.tbItem INNER JOIN
									App.tbTaxCode ON Invoice.tbItem.TaxCode = App.tbTaxCode.TaxCode INNER JOIN
									Invoice.tbInvoice ON Invoice.tbItem.InvoiceNumber = Invoice.tbInvoice.InvoiceNumber
			WHERE     ( Invoice.tbInvoice.InvoiceStatusCode <> 0)
				AND (AccountCode = @AccountCode);
                      
			UPDATE Invoice.tbTask
			SET TaxValue = CASE App.tbTaxCode.RoundingCode 
					WHEN 0 THEN ROUND(Invoice.tbTask.InvoiceValue * App.tbTaxCode.TaxRate, 2)
					WHEN 1 THEN ROUND( Invoice.tbTask.InvoiceValue * App.tbTaxCode.TaxRate, 2, 1) END,
				PaidValue = 0,
				PaidTaxValue = 0
			FROM         Invoice.tbTask INNER JOIN
									App.tbTaxCode ON Invoice.tbTask.TaxCode = App.tbTaxCode.TaxCode INNER JOIN
									Invoice.tbInvoice ON Invoice.tbTask.InvoiceNumber = Invoice.tbInvoice.InvoiceNumber
			WHERE     ( Invoice.tbInvoice.InvoiceStatusCode <> 0)
				AND (AccountCode = @AccountCode);		
		END	

		UPDATE Invoice.tbInvoice
		SET InvoiceValue = 0, TaxValue = 0, PaidValue = 0, PaidTaxValue = 0, InvoiceStatusCode = 1
		WHERE     ( Invoice.tbInvoice.InvoiceStatusCode <> 0)
			AND (AccountCode = @AccountCode);
	
		WITH items AS
		(
			SELECT     Invoice.tbInvoice.InvoiceNumber, SUM( Invoice.tbItem.InvoiceValue) AS TotalInvoiceValue, SUM( Invoice.tbItem.TaxValue) AS TotalTaxValue
			FROM         Invoice.tbItem INNER JOIN
								Invoice.tbInvoice ON Invoice.tbItem.InvoiceNumber = Invoice.tbInvoice.InvoiceNumber
			WHERE     ( Invoice.tbInvoice.InvoiceStatusCode <> 0)
			GROUP BY Invoice.tbItem.InvoiceNumber, Invoice.tbInvoice.InvoiceNumber
		)
		UPDATE Invoice.tbInvoice
		SET InvoiceValue = items.TotalInvoiceValue, 
			TaxValue = items.TotalTaxValue
		FROM         Invoice.tbInvoice INNER JOIN items 
								ON Invoice.tbInvoice.InvoiceNumber = items.InvoiceNumber
		WHERE (AccountCode = @AccountCode);


		WITH tasks AS
		(
			SELECT     Invoice.tbInvoice.InvoiceNumber, SUM( Invoice.tbTask.InvoiceValue) AS TotalInvoiceValue, SUM( Invoice.tbTask.TaxValue) AS TotalTaxValue
			FROM         Invoice.tbTask INNER JOIN
								Invoice.tbInvoice ON Invoice.tbTask.InvoiceNumber = Invoice.tbInvoice.InvoiceNumber
			WHERE   ( Invoice.tbInvoice.InvoiceStatusCode <> 0) AND (AccountCode = @AccountCode)
			GROUP BY Invoice.tbTask.InvoiceNumber, Invoice.tbInvoice.InvoiceNumber
		)
		UPDATE Invoice.tbInvoice
		SET InvoiceValue = InvoiceValue + tasks.TotalInvoiceValue, 
			TaxValue = TaxValue + tasks.TotalTaxValue
		FROM         Invoice.tbInvoice INNER JOIN tasks ON Invoice.tbInvoice.InvoiceNumber = tasks.InvoiceNumber;

		IF EXISTS(SELECT * FROM Org.tbPayment WHERE AccountCode = @AccountCode)
			UPDATE    Invoice.tbInvoice
			SET              PaidValue = InvoiceValue, PaidTaxValue = TaxValue, InvoiceStatusCode = 3
			WHERE (AccountCode = @AccountCode);
			
		WITH paid_balance AS
		(
			SELECT  AccountCode, SUM(PaidInValue + (PaidOutValue * -1)) AS PaidBalance
			FROM         Org.tbPayment
			WHERE     (PaymentStatusCode <> 0) AND (AccountCode = @AccountCode)
			GROUP BY AccountCode
		), invoice_balance AS
		(
			SELECT AccountCode, SUM(CASE Invoice.tbType.CashModeCode WHEN 0 THEN (InvoiceValue + TaxValue) * - 1 WHEN 1 THEN InvoiceValue + TaxValue ELSE 0 END) AS InvoicedBalance
			FROM         Invoice.tbInvoice INNER JOIN
								  Invoice.tbType ON Invoice.tbInvoice.InvoiceTypeCode = Invoice.tbType.InvoiceTypeCode
			WHERE (AccountCode = @AccountCode)
			GROUP BY AccountCode
		), account_balance AS
		(
			SELECT paid_balance.AccountCode, PaidBalance, InvoicedBalance, PaidBalance - InvoicedBalance AS CurrentBalance
			FROM paid_balance JOIN invoice_balance ON paid_balance.AccountCode = invoice_balance.AccountCode
		), current_balance AS
		(
			SELECT account_balance.AccountCode, 
				ROUND(OpeningBalance + account_balance.CurrentBalance, 2)AS CurrentBalance
			FROM Org.tbOrg JOIN
				account_balance ON Org.tbOrg.AccountCode = account_balance.AccountCode
		), closing_balance AS
		(
			SELECT AccountCode, 0 AS RowNumber,
				CurrentBalance,
					CASE WHEN CurrentBalance < 0 THEN 0 
						WHEN CurrentBalance > 0 THEN 1
						ELSE 2 END AS CashModeCode
			FROM current_balance
			WHERE ROUND(CurrentBalance, 0) <> 0
		), invoice_entries AS
		(
			SELECT        Invoice.tbInvoice.AccountCode, Invoice.tbInvoice.ExpectedOn, Invoice.tbInvoice.InvoiceNumber, Invoice.tbTask.TaskCode AS RefCode, 1 AS RefType, 
				CASE WHEN Invoice.tbType.CashModeCode = 0 THEN Invoice.tbTask.InvoiceValue * -1 ELSE Invoice.tbTask.InvoiceValue END AS InvoiceValue, 
				CASE WHEN Invoice.tbType.CashModeCode = 0 THEN Invoice.tbTask.TaxValue * -1 ELSE Invoice.tbTask.TaxValue END AS TaxValue, Invoice.tbType.CashModeCode
			FROM   closing_balance JOIN Invoice.tbInvoice ON closing_balance.AccountCode = Invoice.tbInvoice.AccountCode
				JOIN  Invoice.tbTask ON Invoice.tbTask.InvoiceNumber = Invoice.tbInvoice.InvoiceNumber
				JOIN Invoice.tbType ON Invoice.tbInvoice.InvoiceTypeCode = Invoice.tbType.InvoiceTypeCode
			UNION
			SELECT        Invoice.tbInvoice.AccountCode, Invoice.tbInvoice.ExpectedOn, Invoice.tbInvoice.InvoiceNumber, CashCode AS RefCode, 2 AS RefType,
				CASE WHEN Invoice.tbType.CashModeCode = 0 THEN Invoice.tbItem.InvoiceValue * -1 ELSE Invoice.tbItem.InvoiceValue END AS InvoiceValue, 
				CASE WHEN Invoice.tbType.CashModeCode = 0 THEN Invoice.tbItem.TaxValue * -1 ELSE Invoice.tbItem.TaxValue END AS TaxValue, Invoice.tbType.CashModeCode
			FROM   closing_balance JOIN Invoice.tbInvoice ON closing_balance.AccountCode = Invoice.tbInvoice.AccountCode
				JOIN Invoice.tbItem ON Invoice.tbItem.InvoiceNumber = Invoice.tbInvoice.InvoiceNumber
				JOIN Invoice.tbType ON Invoice.tbInvoice.InvoiceTypeCode = Invoice.tbType.InvoiceTypeCode
		), invoices AS
		(
			SELECT AccountCode, ROW_NUMBER() OVER (PARTITION BY AccountCode ORDER BY ExpectedOn DESC, CashModeCode DESC) AS RowNumber, 
				InvoiceNumber, RefCode, RefType, (InvoiceValue + TaxValue) AS ValueToPay
			FROM invoice_entries
		), invoices_and_cb AS
		( 
			SELECT AccountCode, RowNumber, '' AS InvoiceNumber, '' AS RefCode, 0 AS RefType, CurrentBalance AS ValueToPay
			FROM closing_balance
			UNION
			SELECT AccountCode, RowNumber, InvoiceNumber, RefCode, RefType, ValueToPay
			FROM invoices	
		), unbalanced_cashmode AS
		(
			SELECT invoices_and_cb.AccountCode, invoices_and_cb.RowNumber, invoices_and_cb.InvoiceNumber, invoices_and_cb.RefCode, 
				invoices_and_cb.RefType, invoices_and_cb.ValueToPay, closing_balance.CashModeCode
			FROM invoices_and_cb JOIN closing_balance ON invoices_and_cb.AccountCode = closing_balance.AccountCode
		), invoice_balances AS
		(
			SELECT AccountCode, RowNumber, InvoiceNumber, RefCode, RefType, ValueToPay, CashModeCode, 
				SUM(ValueToPay) OVER (PARTITION BY AccountCode ORDER BY RowNumber ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS Balance
			FROM unbalanced_cashmode
		), selected_row AS
		(
			SELECT AccountCode, MIN(RowNumber) AS RowNumber
			FROM invoice_balances
			WHERE (CashModeCode = 0 AND Balance >= 0) OR (CashModeCode = 1 AND Balance <= 0)
			GROUP BY AccountCode
		), result_set AS
		(
			SELECT invoice_unpaid.AccountCode, invoice_unpaid.InvoiceNumber, invoice_unpaid.RefType, invoice_unpaid.RefCode, 
				CASE WHEN CashModeCode = 0 THEN
						CASE WHEN Balance < 0 THEN 0 ELSE Balance END
					WHEN CashModeCode = 1 THEN
						CASE WHEN Balance > 0 THEN 0 ELSE ABS(Balance) END
					END AS TotalPaidValue
			FROM selected_row
				CROSS APPLY (SELECT invoice_balances.*
							FROM invoice_balances
							WHERE invoice_balances.AccountCode = selected_row.AccountCode
								AND invoice_balances.RowNumber <= selected_row.RowNumber
								AND invoice_balances.RefType > 0) AS invoice_unpaid
		)
		INSERT INTO @tbPartialInvoice
			(AccountCode, InvoiceNumber, RefType, RefCode, TotalPaidValue)
		SELECT AccountCode, InvoiceNumber, RefType, RefCode, TotalPaidValue
		FROM result_set;

		--SELECT * FROM @tbPartialInvoice

		UPDATE task
		SET PaidValue = 0, PaidTaxValue = 0
		FROM @tbPartialInvoice unpaid_task
			JOIN Invoice.tbTask task ON unpaid_task.InvoiceNumber = task.InvoiceNumber
				AND unpaid_task.RefCode = task.TaskCode	
		WHERE unpaid_task.RefType = 1 AND unpaid_task.TotalPaidValue = 0;

		UPDATE task
		SET 
			PaidTaxValue = CASE RoundingCode 
								WHEN 0 THEN ROUND((TotalPaidValue - (TotalPaidValue / (1 + TaxRate))), 2)
								WHEN 1 THEN ROUND((TotalPaidValue - (TotalPaidValue / (1 + TaxRate))), 2, 1)
							END,
			PaidValue = TotalPaidValue -
							CASE RoundingCode 
								WHEN 0 THEN ROUND((TotalPaidValue - (TotalPaidValue / (1 + TaxRate))), 2)
								WHEN 1 THEN ROUND((TotalPaidValue - (TotalPaidValue / (1 + TaxRate))), 2, 1)
							END
		FROM @tbPartialInvoice unpaid_task
			JOIN Invoice.tbTask task ON unpaid_task.InvoiceNumber = task.InvoiceNumber
				AND unpaid_task.RefCode = task.TaskCode	
			JOIN App.tbTaxCode tax ON tax.TaxCode = task.TaxCode
		WHERE unpaid_task.RefType = 1 AND unpaid_task.TotalPaidValue <> 0;

		UPDATE item
		SET PaidValue = 0, PaidTaxValue = 0
		FROM @tbPartialInvoice unpaid_task
			JOIN Invoice.tbItem item ON unpaid_task.InvoiceNumber = item.InvoiceNumber
				AND unpaid_task.RefCode = item.CashCode
		WHERE unpaid_task.RefType = 1 AND unpaid_task.TotalPaidValue = 0;

		UPDATE item
		SET 
			PaidTaxValue = CASE RoundingCode 
								WHEN 0 THEN ROUND((TotalPaidValue - (TotalPaidValue / (1 + TaxRate))), 2)
								WHEN 1 THEN ROUND((TotalPaidValue - (TotalPaidValue / (1 + TaxRate))), 2, 1)
							END,
			PaidValue = TotalPaidValue -
							CASE RoundingCode 
								WHEN 0 THEN ROUND((TotalPaidValue - (TotalPaidValue / (1 + TaxRate))), 2)
								WHEN 1 THEN ROUND((TotalPaidValue - (TotalPaidValue / (1 + TaxRate))), 2, 1)
							END
		FROM @tbPartialInvoice unpaid_item
			JOIN Invoice.tbItem item ON unpaid_item.InvoiceNumber = item.InvoiceNumber
				AND unpaid_item.RefCode = item.CashCode	
			JOIN App.tbTaxCode tax ON tax.TaxCode = item.TaxCode
		WHERE unpaid_item.RefType = 1 AND unpaid_item.TotalPaidValue <> 0;

		WITH invoices AS
		(
			SELECT        task.InvoiceNumber, InvoiceValue, TaxValue, PaidValue, PaidTaxValue
			FROM       @tbPartialInvoice unpaid_task
			JOIN Invoice.tbTask task ON unpaid_task.InvoiceNumber = task.InvoiceNumber
				AND unpaid_task.RefCode = task.TaskCode	
			UNION
			SELECT        item.InvoiceNumber, InvoiceValue, TaxValue, PaidValue, PaidTaxValue
			FROM @tbPartialInvoice unpaid_item
				JOIN Invoice.tbItem item ON unpaid_item.InvoiceNumber = item.InvoiceNumber
					AND unpaid_item.RefCode = item.CashCode
		), totals AS
		(
			SELECT        InvoiceNumber, SUM(InvoiceValue) AS TotalInvoiceValue, SUM(TaxValue) AS TotalTaxValue, SUM(PaidValue) AS TotalPaidValue, SUM(PaidTaxValue) AS TotalPaidTaxValue
			FROM            invoices
			GROUP BY InvoiceNumber
		), selected AS
		(
			SELECT InvoiceNumber, 		
				TotalInvoiceValue, TotalTaxValue, TotalPaidValue, TotalPaidTaxValue, 
				(TotalPaidValue + TotalPaidTaxValue) AS TotalPaid
			FROM totals
			WHERE (TotalInvoiceValue + TotalTaxValue) > (TotalPaidValue + TotalPaidTaxValue)
		)
		UPDATE Invoice.tbInvoice
		SET InvoiceStatusCode = CASE WHEN TotalPaid > 0 THEN 2 ELSE 1 END,
			PaidValue = selected.TotalPaidValue, 
			PaidTaxValue = selected.TotalPaidTaxValue
		FROM         Invoice.tbInvoice INNER JOIN
							selected ON Invoice.tbInvoice.InvoiceNumber = selected.InvoiceNumber;

		COMMIT TRANSACTION

		--log successful rebuild
		DECLARE @Msg NVARCHAR(MAX);
		SELECT @Msg = CONCAT(@AccountCode, ' ', Message) FROM App.tbText WHERE TextId = 3006;
		EXEC App.proc_EventLog @EventMessage = @Msg, @EventTypeCode = 2;

  	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
go

CREATE PROCEDURE Org.proc_PaymentDelete
	(
	@PaymentCode nvarchar(20)
	)
 AS
  	SET NOCOUNT, XACT_ABORT ON;

	BEGIN TRY
		DECLARE 
			@AccountCode nvarchar(10)
			, @CashAccountCode nvarchar(10)

		SELECT  @AccountCode = AccountCode, @CashAccountCode = CashAccountCode
		FROM         Org.tbPayment
		WHERE     (PaymentCode = @PaymentCode)

		DELETE FROM Org.tbPayment
		WHERE     (PaymentCode = @PaymentCode)
	
		EXEC Org.proc_Rebuild @AccountCode

		BEGIN TRANSACTION
		EXEC Cash.proc_AccountRebuild @CashAccountCode
		COMMIT TRANSACTION

  	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
go

CREATE PROCEDURE Org.proc_PaymentMove
	(
	@PaymentCode nvarchar(20),
	@CashAccountCode nvarchar(10)
	)
  AS
    SET NOCOUNT, XACT_ABORT ON;

	BEGIN TRY
		DECLARE @OldAccountCode nvarchar(10)

		SELECT @OldAccountCode = CashAccountCode
		FROM         Org.tbPayment
		WHERE     (PaymentCode = @PaymentCode)
	
		BEGIN TRANSACTION
	
		UPDATE Org.tbPayment 
		SET CashAccountCode = @CashAccountCode,
			UpdatedOn = CURRENT_TIMESTAMP,
			UpdatedBy = (suser_sname())
		WHERE PaymentCode = @PaymentCode	

		EXEC Cash.proc_AccountRebuild @CashAccountCode
		EXEC Cash.proc_AccountRebuild @OldAccountCode
	
		COMMIT TRANSACTION
	 
  	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
go

CREATE PROCEDURE Org.proc_PaymentPost 
AS
    SET NOCOUNT, XACT_ABORT ON;

	BEGIN TRY
		DECLARE @PaymentCode nvarchar(20)

		DECLARE curMisc cursor local for
			SELECT        Org.tbPayment.PaymentCode
			FROM            Org.tbPayment INNER JOIN
									 Cash.tbCode ON Org.tbPayment.CashCode = Cash.tbCode.CashCode INNER JOIN
									 Cash.tbCategory ON Cash.tbCode.CategoryCode = Cash.tbCategory.CategoryCode
			WHERE        (Org.tbPayment.PaymentStatusCode = 0) 
				AND Org.tbPayment.UserId = (SELECT UserId FROM Usr.vwCredentials)
			ORDER BY Org.tbPayment.AccountCode, Org.tbPayment.PaidOn

		DECLARE curInv cursor local for
			SELECT     PaymentCode
			FROM         Org.tbPayment
			WHERE     (PaymentStatusCode = 0) AND (CashCode IS NULL)
				AND Org.tbPayment.UserId = (SELECT UserId FROM Usr.vwCredentials)
			ORDER BY AccountCode, PaidOn
		
		BEGIN TRANSACTION

		OPEN curMisc
		FETCH NEXT FROM curMisc INTO @PaymentCode
		WHILE @@FETCH_STATUS = 0
			BEGIN
			EXEC Org.proc_PaymentPostMisc @PaymentCode		
			FETCH NEXT FROM curMisc INTO @PaymentCode	
			END

		CLOSE curMisc
		DEALLOCATE curMisc
	
		OPEN curInv
		FETCH NEXT FROM curInv INTO @PaymentCode
		WHILE @@FETCH_STATUS = 0
			BEGIN
			EXEC Org.proc_PaymentPostInvoiced @PaymentCode		
			FETCH NEXT FROM curInv INTO @PaymentCode	
			END

		CLOSE curInv
		DEALLOCATE curInv

		COMMIT TRANSACTION

  	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
go

CREATE PROCEDURE Org.proc_Statement (@AccountCode NVARCHAR(10))
AS
 	SET NOCOUNT, XACT_ABORT ON;

	BEGIN TRY

		SELECT *
		FROM Org.vwStatement
		WHERE AccountCode = @AccountCode
		ORDER BY RowNumber DESC

	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog
	END CATCH
go

CREATE PROCEDURE Task.proc_AssignToParent 
	(
	@ChildTaskCode nvarchar(20),
	@ParentTaskCode nvarchar(20)
	)
  AS
   	SET NOCOUNT, XACT_ABORT ON;

	BEGIN TRY
		DECLARE 
			@TaskTitle nvarchar(100)
			, @StepNumber smallint

		BEGIN TRANSACTION
		
		IF EXISTS (SELECT ParentTaskCode FROM Task.tbFlow WHERE ChildTaskCode = @ChildTaskCode)
			DELETE FROM Task.tbFlow WHERE ChildTaskCode = @ChildTaskCode

		IF EXISTS(SELECT     TOP 1 StepNumber
				  FROM         Task.tbFlow
				  WHERE     (ParentTaskCode = @ParentTaskCode))
			BEGIN
			SELECT  @StepNumber = MAX(StepNumber) 
			FROM         Task.tbFlow
			WHERE     (ParentTaskCode = @ParentTaskCode)
			SET @StepNumber = @StepNumber - (@StepNumber % 10) + 10		
			END
		ELSE
			SET @StepNumber = 10


		SELECT     @TaskTitle = TaskTitle
		FROM         Task.tbTask
		WHERE     (TaskCode = @ParentTaskCode)		
	
		UPDATE    Task.tbTask
		SET              TaskTitle = @TaskTitle
		WHERE     (TaskCode = @ChildTaskCode) AND ((TaskTitle IS NULL) OR (TaskTitle = ActivityCode))
	
		INSERT INTO Task.tbFlow
							  (ParentTaskCode, StepNumber, ChildTaskCode)
		VALUES     (@ParentTaskCode, @StepNumber, @ChildTaskCode)
	
		COMMIT TRANSACTION

  	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
go

CREATE PROCEDURE Task.proc_NextCode
	(
		@ActivityCode nvarchar(50),
		@TaskCode nvarchar(20) OUTPUT
	)
AS
  	SET NOCOUNT, XACT_ABORT ON;

	BEGIN TRY
		DECLARE 
			@UserId nvarchar(10)
			, @NextTaskNumber int

		SELECT   @UserId = Usr.tbUser.UserId, @NextTaskNumber = Usr.tbUser.NextTaskNumber
		FROM         Usr.vwCredentials INNER JOIN
							Usr.tbUser ON Usr.vwCredentials.UserId = Usr.tbUser.UserId


		IF EXISTS(SELECT     App.tbRegister.NextNumber
				  FROM         Activity.tbActivity INNER JOIN
										App.tbRegister ON Activity.tbActivity.RegisterName = App.tbRegister.RegisterName
				  WHERE     ( Activity.tbActivity.ActivityCode = @ActivityCode))
			BEGIN
			DECLARE @RegisterName nvarchar(50)
			SELECT @RegisterName = App.tbRegister.RegisterName, @NextTaskNumber = App.tbRegister.NextNumber
			FROM         Activity.tbActivity INNER JOIN
										App.tbRegister ON Activity.tbActivity.RegisterName = App.tbRegister.RegisterName
			WHERE     ( Activity.tbActivity.ActivityCode = @ActivityCode)
			          
			UPDATE    App.tbRegister
			SET              NextNumber = NextNumber + 1
			WHERE     (RegisterName = @RegisterName)	
			END
		ELSE
			BEGIN	                      		
			UPDATE Usr.tbUser
			Set NextTaskNumber = NextTaskNumber + 1
			WHERE UserId = @UserId
			END
		                      
		SET @TaskCode = CONCAT(@UserId, '_', FORMAT(@NextTaskNumber, '0000'))
			                      
  	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
go

CREATE PROCEDURE Task.proc_Configure 
	(
	@ParentTaskCode nvarchar(20)
	)
AS
 	SET NOCOUNT, XACT_ABORT ON;

	BEGIN TRY
		DECLARE 
			@StepNumber smallint
			, @TaskCode nvarchar(20)
			, @UserId nvarchar(10)
			, @ActivityCode nvarchar(50)
			, @AccountCode nvarchar(10)
			, @DefaultAccountCode nvarchar(10)
			, @TaxCode nvarchar(10)

		IF @@NESTLEVEL = 1
			BEGIN TRANSACTION

		INSERT INTO Org.tbContact 
			(AccountCode, ContactName, FileAs, PhoneNumber, FaxNumber, EmailAddress)
		SELECT Task.tbTask.AccountCode, Task.tbTask.ContactName, Task.tbTask.ContactName AS NickName, Org.tbOrg.PhoneNumber, Org.tbOrg.FaxNumber, Org.tbOrg.EmailAddress
		FROM  Task.tbTask 
			INNER JOIN Org.tbOrg ON Task.tbTask.AccountCode = Org.tbOrg.AccountCode
		WHERE        (Task.tbTask.TaskCode = @ParentTaskCode)
					AND EXISTS (SELECT *
								FROM Task.tbTask
								WHERE (TaskCode = @ParentTaskCode) AND (NOT (ContactName IS NULL)) OR (TaskCode = @ParentTaskCode) AND (ContactName <> N''))
				AND NOT EXISTS(SELECT *
								FROM  Task.tbTask 
									INNER JOIN Org.tbContact ON Task.tbTask.AccountCode = Org.tbContact.AccountCode AND Task.tbTask.ContactName = Org.tbContact.ContactName
								WHERE     ( Task.tbTask.TaskCode = @ParentTaskCode))
	
		UPDATE Org.tbOrg
		SET OrganisationStatusCode = 1
		FROM Org.tbOrg INNER JOIN Task.tbTask ON Org.tbOrg.AccountCode = Task.tbTask.AccountCode
		WHERE ( Task.tbTask.TaskCode = @ParentTaskCode) AND ( Org.tbOrg.OrganisationStatusCode = 0)				
			AND EXISTS(SELECT *
				FROM  Org.tbOrg INNER JOIN Task.tbTask ON Org.tbOrg.AccountCode = Task.tbTask.AccountCode
				WHERE     ( Task.tbTask.TaskCode = @ParentTaskCode) AND ( Org.tbOrg.OrganisationStatusCode = 0))
	          
		UPDATE    Task.tbTask
		SET  ActionedOn = ActionOn
		WHERE (TaskCode = @ParentTaskCode)
			AND EXISTS(SELECT *
					  FROM Task.tbTask
					  WHERE (TaskStatusCode = 2) AND (TaskCode = @ParentTaskCode))

		UPDATE Task.tbTask
		SET TaskTitle = ActivityCode
		WHERE (TaskCode = @ParentTaskCode)
			AND EXISTS(SELECT *
				  FROM Task.tbTask
				  WHERE (TaskCode = @ParentTaskCode) AND (TaskTitle IS NULL))  	 				              
	     	
		INSERT INTO Task.tbAttribute
			(TaskCode, Attribute, AttributeDescription, PrintOrder, AttributeTypeCode)
		SELECT Task.tbTask.TaskCode, Activity.tbAttribute.Attribute, Activity.tbAttribute.DefaultText, Activity.tbAttribute.PrintOrder, Activity.tbAttribute.AttributeTypeCode
		FROM Activity.tbAttribute 
			INNER JOIN Task.tbTask ON Activity.tbAttribute.ActivityCode = Task.tbTask.ActivityCode
		WHERE     ( Task.tbTask.TaskCode = @ParentTaskCode)
	
		INSERT INTO Task.tbOp
			(TaskCode, UserId, OperationNumber, SyncTypeCode, Operation, Duration, OffsetDays, StartOn)
		SELECT Task.tbTask.TaskCode, Task.tbTask.UserId, Activity.tbOp.OperationNumber, Activity.tbOp.SyncTypeCode, Activity.tbOp.Operation, Activity.tbOp.Duration,  Activity.tbOp.OffsetDays, Task.tbTask.ActionOn
		FROM Activity.tbOp INNER JOIN Task.tbTask ON Activity.tbOp.ActivityCode = Task.tbTask.ActivityCode
		WHERE     ( Task.tbTask.TaskCode = @ParentTaskCode)
	                   
	
		SELECT @UserId = UserId FROM Task.tbTask WHERE Task.tbTask.TaskCode = @ParentTaskCode
	
		DECLARE curAct cursor local for
			SELECT Activity.tbFlow.StepNumber
			FROM Activity.tbFlow INNER JOIN Task.tbTask ON Activity.tbFlow.ParentCode = Task.tbTask.ActivityCode
			WHERE     ( Task.tbTask.TaskCode = @ParentTaskCode)
			ORDER BY Activity.tbFlow.StepNumber	
	
		OPEN curAct
		FETCH NEXT FROM curAct INTO @StepNumber
		WHILE @@FETCH_STATUS = 0
			BEGIN
			SELECT  
				@ActivityCode = Activity.tbActivity.ActivityCode, 
				@AccountCode = Task.tbTask.AccountCode
			FROM Activity.tbFlow 
				INNER JOIN Activity.tbActivity ON Activity.tbFlow.ChildCode = Activity.tbActivity.ActivityCode 
				INNER JOIN Task.tbTask ON Activity.tbFlow.ParentCode = Task.tbTask.ActivityCode
			WHERE     ( Activity.tbFlow.StepNumber = @StepNumber) AND ( Task.tbTask.TaskCode = @ParentTaskCode)
		
			EXEC Task.proc_NextCode @ActivityCode, @TaskCode output

			INSERT INTO Task.tbTask
				(TaskCode, UserId, AccountCode, ContactName, ActivityCode, TaskStatusCode, ActionById, ActionOn, TaskNotes, Quantity, UnitCharge, AddressCodeFrom, AddressCodeTo, CashCode, Printed, TaskTitle)
			SELECT  @TaskCode AS NewTask, Task_tb1.UserId, Task_tb1.AccountCode, Task_tb1.ContactName, Activity.tbActivity.ActivityCode, Activity.tbActivity.TaskStatusCode, 
						Task_tb1.ActionById, Task_tb1.ActionOn, Activity.tbActivity.DefaultText, Task_tb1.Quantity * Activity.tbFlow.UsedOnQuantity AS Quantity,
						Activity.tbActivity.UnitCharge, Org.tbOrg.AddressCode AS AddressCodeFrom, Org.tbOrg.AddressCode AS AddressCodeTo, 
						tbActivity.CashCode, CASE WHEN Activity.tbActivity.Printed = 0 THEN 1 ELSE 0 END AS Printed, Task_tb1.TaskTitle
			FROM  Activity.tbFlow 
				INNER JOIN Activity.tbActivity ON Activity.tbFlow.ChildCode = Activity.tbActivity.ActivityCode 
				INNER JOIN Task.tbTask Task_tb1 ON Activity.tbFlow.ParentCode = Task_tb1.ActivityCode 
				INNER JOIN Org.tbOrg ON Task_tb1.AccountCode = Org.tbOrg.AccountCode
			WHERE     ( Activity.tbFlow.StepNumber = @StepNumber) AND ( Task_tb1.TaskCode = @ParentTaskCode)

			IF EXISTS (SELECT * FROM Task.tbTask 
							INNER JOIN  Org.tbOrg ON Task.tbTask.AccountCode = Org.tbOrg.AccountCode 
							INNER JOIN App.tbTaxCode ON Org.tbOrg.TaxCode = App.tbTaxCode.TaxCode AND Org.tbOrg.TaxCode = App.tbTaxCode.TaxCode)
				BEGIN
				UPDATE Task.tbTask
				SET TaxCode = App.tbTaxCode.TaxCode
				FROM Task.tbTask 
					INNER JOIN Org.tbOrg ON Task.tbTask.AccountCode = Org.tbOrg.AccountCode 
					INNER JOIN App.tbTaxCode ON Org.tbOrg.TaxCode = App.tbTaxCode.TaxCode AND Org.tbOrg.TaxCode = App.tbTaxCode.TaxCode
				WHERE (Task.tbTask.TaskCode = @TaskCode)
				END
			ELSE
				BEGIN
				UPDATE Task.tbTask
				SET TaxCode = Cash.tbCode.TaxCode
				FROM  Task.tbTask 
					INNER JOIN Cash.tbCode ON Task.tbTask.CashCode = Cash.tbCode.CashCode
				WHERE  (Task.tbTask.TaskCode = @TaskCode)
				END			
			
			SELECT @DefaultAccountCode = (SELECT TOP 1  AccountCode FROM Task.tbTask
											WHERE   (ActivityCode = (SELECT ActivityCode FROM  Task.tbTask AS tbTask_1 WHERE (TaskCode = @TaskCode))) AND (TaskCode <> @TaskCode))

			IF NOT @DefaultAccountCode IS NULL
				BEGIN
				UPDATE Task.tbTask
				SET AccountCode = @DefaultAccountCode
				WHERE (TaskCode = @TaskCode)
				END
					
			INSERT INTO Task.tbFlow
				(ParentTaskCode, StepNumber, ChildTaskCode, SyncTypeCode, UsedOnQuantity, OffsetDays)
			SELECT Task.tbTask.TaskCode, Activity.tbFlow.StepNumber, @TaskCode AS ChildTaskCode, Activity.tbFlow.SyncTypeCode, Activity.tbFlow.UsedOnQuantity, Activity.tbFlow.OffsetDays
			FROM Activity.tbFlow 
				INNER JOIN Task.tbTask ON Activity.tbFlow.ParentCode = Task.tbTask.ActivityCode
			WHERE (Task.tbTask.TaskCode = @ParentTaskCode) AND ( Activity.tbFlow.StepNumber = @StepNumber)
		
			EXEC Task.proc_Configure @TaskCode

			FETCH NEXT FROM curAct INTO @StepNumber
			END
	
		CLOSE curAct
		DEALLOCATE curAct
		
		IF @@NESTLEVEL = 1
			COMMIT TRANSACTION

  	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH

go

CREATE PROCEDURE Task.proc_Schedule (@ParentTaskCode nvarchar(20))
AS
  	SET NOCOUNT, XACT_ABORT ON;

	BEGIN TRY
		IF @@NESTLEVEL = 1
			BEGIN TRANSACTION;

		WITH ops_top_level AS
		(
			SELECT task.TaskCode, ops.OperationNumber, ops.OffsetDays, task.ActionOn, ops.StartOn, ops.EndOn, task.TaskStatusCode, ops.OpStatusCode, ops.SyncTypeCode
			FROM Task.tbOp ops JOIN Task.tbTask task ON ops.TaskCode = task.TaskCode
			WHERE task.TaskCode = @ParentTaskCode
		), ops_candidates AS
		(
			SELECT *,
				ROW_NUMBER() OVER (PARTITION BY TaskCode ORDER BY TaskCode, OperationNumber DESC) AS LastOpRow,
				ROW_NUMBER() OVER (PARTITION BY TaskCode ORDER BY TaskCode, OperationNumber) AS FirstOpRow
			FROM ops_top_level
		), ops_unscheduled1 AS
		(
			SELECT TaskCode, OperationNumber,
				CASE TaskStatusCode 
					WHEN 0 THEN 0 
					WHEN 1 THEN 
						CASE WHEN FirstOpRow = 1 AND OpStatusCode < 1 THEN 1 ELSE OpStatusCode END				
					ELSE 2
					END AS OpStatusCode,
				CASE WHEN LastOpRow = 1 THEN App.fnAdjustToCalendar(ActionOn, OffsetDays) ELSE StartOn END AS StartOn,
				CASE WHEN LastOpRow = 1 THEN ActionOn ELSE EndOn END AS EndOn,
				LastOpRow,
				OffsetDays,
				CASE SyncTypeCode WHEN 1 THEN 0 ELSE OffsetDays END AS AsyncOffsetDays
			FROM ops_candidates
		)
		, ops_unscheduled2 AS
		(
			SELECT TaskCode, OperationNumber, OpStatusCode, 
				FIRST_VALUE(EndOn) OVER (PARTITION BY TaskCode ORDER BY OperationNumber DESC) AS ActionOn, 
				LAG(AsyncOffsetDays, 1, 0) OVER (PARTITION BY TaskCode ORDER BY OperationNumber DESC) AS AsyncOffsetDays,
				OffsetDays
			FROM ops_unscheduled1
		), ops_scheduled AS
		(
			SELECT TaskCode, OperationNumber, OpStatusCode,
				App.fnAdjustToCalendar(ActionOn, SUM(AsyncOffsetDays) OVER (PARTITION BY TaskCode ORDER BY OperationNumber DESC)) AS EndOn,
				App.fnAdjustToCalendar(ActionOn, SUM(AsyncOffsetDays) OVER (PARTITION BY TaskCode ORDER BY OperationNumber DESC) + OffsetDays) AS StartOn
			FROM ops_unscheduled2
		)
		UPDATE op
		SET OpStatusCode = ops_scheduled.OpStatusCode,
			StartOn = ops_scheduled.StartOn, EndOn = ops_scheduled.EndOn
		FROM Task.tbOp op JOIN ops_scheduled 
			ON op.TaskCode = ops_scheduled.TaskCode AND op.OperationNumber = ops_scheduled.OperationNumber;

		WITH first_op AS
		(
			SELECT Task.tbOp.TaskCode, MIN(Task.tbOp.StartOn) EndOn
			FROM Task.tbOp
			WHERE  (Task.tbOp.TaskCode = @ParentTaskCode)
			GROUP BY Task.tbOp.TaskCode
		), parent_task AS
		(
			SELECT  Task.tbTask.TaskCode, TaskStatusCode, Quantity, ISNULL(EndOn, Task.tbTask.ActionOn) AS EndOn, Task.tbTask.ActionOn
			FROM Task.tbTask LEFT OUTER JOIN first_op ON first_op.TaskCode = Task.tbTask.TaskCode
			WHERE  (Task.tbTask.TaskCode = @ParentTaskCode)	
		), task_flow AS
		(
			SELECT work_flow.ParentTaskCode, work_flow.ChildTaskCode, work_flow.StepNumber,
				CASE WHEN work_flow.UsedOnQuantity <> 0 THEN parent_task.Quantity * work_flow.UsedOnQuantity ELSE child_task.Quantity END AS Quantity, 
				CASE WHEN parent_task.TaskStatusCode < 3 AND child_task.TaskStatusCode < parent_task.TaskStatusCode 
					THEN parent_task.TaskStatusCode 
					ELSE child_task.TaskStatusCode 
					END AS TaskStatusCode,
				CASE SyncTypeCode WHEN 2 THEN parent_task.ActionOn ELSE parent_task.EndOn END AS EndOn, 
				parent_task.ActionOn,
				CASE SyncTypeCode WHEN 0 THEN 0 ELSE OffsetDays END  AS OffsetDays,
				CASE SyncTypeCode WHEN 1 THEN 0 ELSE OffsetDays END AS AsyncOffsetDays,
				SyncTypeCode
			FROM parent_task 
				JOIN Task.tbFlow work_flow ON parent_task.TaskCode = work_flow.ParentTaskCode
				JOIN Task.tbTask child_task ON work_flow.ChildTaskCode = child_task.TaskCode
				
		), calloff_tasks_lag AS
		(
			SELECT ParentTaskCode, ChildTaskCode, StepNumber, Quantity, TaskStatusCode, ActionOn EndOn, OffsetDays, 
					LAG(AsyncOffsetDays, 1, 0) OVER (PARTITION BY ParentTaskCode ORDER BY StepNumber DESC) AS AsyncOffsetDays, 2SyncTypeCode	 
			FROM task_flow
			WHERE EXISTS(SELECT * FROM task_flow WHERE SyncTypeCode = 2)
				AND (StepNumber > (SELECT TOP 1 StepNumber FROM task_flow WHERE SyncTypeCode = 0 ORDER BY StepNumber DESC)
					OR NOT EXISTS (SELECT * FROM task_flow WHERE SyncTypeCode = 0))
		), calloff_tasks AS
		(
			SELECT ParentTaskCode, ChildTaskCode, StepNumber, Quantity, TaskStatusCode, EndOn, OffsetDays, 
				SUM(AsyncOffsetDays) OVER (PARTITION BY ParentTaskCode ORDER BY StepNumber DESC) AS AsyncOffsetDays
			FROM calloff_tasks_lag
		), servicing_tasks_lag AS
		(
			SELECT ParentTaskCode, ChildTaskCode, StepNumber, Quantity, TaskStatusCode, EndOn, OffsetDays, 
					LAG(AsyncOffsetDays, 1, 0) OVER (PARTITION BY ParentTaskCode ORDER BY StepNumber DESC) AS AsyncOffsetDays
			FROM task_flow
			WHERE (StepNumber < (SELECT MIN(StepNumber) FROM calloff_tasks_lag))
				OR NOT EXISTS (SELECT * FROM task_flow WHERE SyncTypeCode = 2)
		), servicing_tasks AS
		(
			SELECT ParentTaskCode, ChildTaskCode, StepNumber, Quantity, TaskStatusCode, EndOn, OffsetDays, 
				SUM(AsyncOffsetDays) OVER (PARTITION BY ParentTaskCode ORDER BY StepNumber DESC) AS AsyncOffsetDays
			FROM servicing_tasks_lag
		), schedule AS
		(
			SELECT ChildTaskCode AS TaskCode, Quantity, TaskStatusCode, 
				DATEADD(DAY, (AsyncOffsetDays + OffsetDays) * -1, EndOn) AS ActionOn
			FROM calloff_tasks
			UNION
			SELECT ChildTaskCode AS TaskCode, Quantity, TaskStatusCode, 
				DATEADD(DAY, (AsyncOffsetDays + OffsetDays) * -1, EndOn) AS ActionOn
			FROM servicing_tasks
		)
		UPDATE task
		SET
			Quantity = schedule.Quantity,
			ActionOn = schedule.ActionOn,
			TaskStatusCode = schedule.TaskStatusCode
		FROM Task.tbTask task
			JOIN schedule ON task.TaskCode = schedule.TaskCode;

		DECLARE child_tasks CURSOR LOCAL FOR
			SELECT ChildTaskCode FROM Task.tbFlow WHERE ParentTaskCode = @ParentTaskCode;

		DECLARE @ChildTaskCode NVARCHAR(20);

		OPEN child_tasks;

		FETCH NEXT FROM child_tasks INTO @ChildTaskCode
		
		WHILE (@@FETCH_STATUS = 0)
		BEGIN
			EXEC Task.proc_Schedule @ChildTaskCode
			FETCH NEXT FROM child_tasks INTO @ChildTaskCode
		END

		CLOSE child_tasks;
		DEALLOCATE child_tasks;

		IF @@NESTLEVEL = 1
			COMMIT TRANSACTION;

  	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
go

CREATE PROCEDURE Task.proc_Copy
	(
	@FromTaskCode nvarchar(20),
	@ParentTaskCode nvarchar(20) = null,
	@ToTaskCode nvarchar(20) = null output
	)
AS
	SET NOCOUNT, XACT_ABORT ON
	BEGIN TRY
		DECLARE 
			@ActivityCode nvarchar(50)
			, @Printed bit
			, @ChildTaskCode nvarchar(20)
			, @TaskStatusCode smallint
			, @StepNumber smallint
			, @UserId nvarchar(10)
			, @AccountCode nvarchar(10)

		SELECT @UserId = UserId FROM Usr.vwCredentials
	
		SELECT  
			@AccountCode = Task.tbTask.AccountCode,
			@TaskStatusCode = Activity.tbActivity.TaskStatusCode, 
			@ActivityCode = Task.tbTask.ActivityCode, 
			@Printed = CASE WHEN Activity.tbActivity.Printed = 0 THEN 1 ELSE 0 END
		FROM         Task.tbTask INNER JOIN
							  Activity.tbActivity ON Task.tbTask.ActivityCode = Activity.tbActivity.ActivityCode
		WHERE     ( Task.tbTask.TaskCode = @FromTaskCode)
	
		EXEC Task.proc_NextCode @ActivityCode, @ToTaskCode output

		IF @@NESTLEVEL = 1
			BEGIN TRANSACTION;

		INSERT INTO Task.tbTask
							  (TaskCode, UserId, AccountCode, TaskTitle, ContactName, ActivityCode, TaskStatusCode, ActionById, ActionOn, ActionedOn, TaskNotes, Quantity, 
							  SecondReference, CashCode, TaxCode, UnitCharge, TotalCharge, AddressCodeFrom, AddressCodeTo, Printed)
		SELECT     @ToTaskCode AS ToTaskCode, @UserId AS Owner, AccountCode, TaskTitle, ContactName, ActivityCode, @TaskStatusCode AS TaskStatus, 
							  @UserId AS ActionUserId, CAST(CURRENT_TIMESTAMP AS date) AS ActionOn, 
							  CASE WHEN @TaskStatusCode > 1 THEN CAST(CURRENT_TIMESTAMP AS date) ELSE NULL END AS ActionedOn, TaskNotes, 
							  Quantity, SecondReference, CashCode, TaxCode, UnitCharge, TotalCharge, AddressCodeFrom, AddressCodeTo, @Printed AS Printed
		FROM         Task.tbTask AS Task_tb1
		WHERE     (TaskCode = @FromTaskCode)
	
		INSERT INTO Task.tbAttribute
							  (TaskCode, Attribute, PrintOrder, AttributeTypeCode, AttributeDescription)
		SELECT     @ToTaskCode AS ToTaskCode, Attribute, PrintOrder, AttributeTypeCode, AttributeDescription
		FROM         Task.tbAttribute 
		WHERE     (TaskCode = @FromTaskCode)
	
		INSERT INTO Task.tbQuote
							  (TaskCode, Quantity, TotalPrice, RunOnQuantity, RunOnPrice, RunBackQuantity, RunBackPrice)
		SELECT     @ToTaskCode AS ToTaskCode, Quantity, TotalPrice, RunOnQuantity, RunOnPrice, RunBackQuantity, RunBackPrice
		FROM         Task.tbQuote 
		WHERE     (TaskCode = @FromTaskCode)
	
		INSERT INTO Task.tbOp
							  (TaskCode, OperationNumber, OpStatusCode, UserId, SyncTypeCode, Operation, Note, StartOn, EndOn, Duration, OffsetDays)
		SELECT     @ToTaskCode AS ToTaskCode, OperationNumber, 0 AS OpStatusCode, UserId, SyncTypeCode, Operation, Note, 
			CAST(CURRENT_TIMESTAMP AS date) AS StartOn, CAST(CURRENT_TIMESTAMP AS date) AS EndOn, Duration, OffsetDays
		FROM         Task.tbOp 
		WHERE     (TaskCode = @FromTaskCode)
	
		IF (ISNULL(@ParentTaskCode, '') = '')
			BEGIN
			IF EXISTS(SELECT     ParentTaskCode
					FROM         Task.tbFlow
					WHERE     (ChildTaskCode = @FromTaskCode))
				BEGIN
				SELECT @ParentTaskCode = ParentTaskCode
				FROM         Task.tbFlow
				WHERE     (ChildTaskCode = @FromTaskCode)

				SELECT @StepNumber = MAX(StepNumber)
				FROM         Task.tbFlow
				WHERE     (ParentTaskCode = @ParentTaskCode)
				GROUP BY ParentTaskCode
				
				SET @StepNumber = @StepNumber - (@StepNumber % 10) + 10	
						
				INSERT INTO Task.tbFlow
				(ParentTaskCode, StepNumber, ChildTaskCode, SyncTypeCode, UsedOnQuantity, OffsetDays)
				SELECT TOP 1 ParentTaskCode, @StepNumber AS Step, @ToTaskCode AS ChildTask, SyncTypeCode, UsedOnQuantity, OffsetDays
				FROM         Task.tbFlow
				WHERE     (ChildTaskCode = @FromTaskCode)
				END
			END
		ELSE
			BEGIN		
			INSERT INTO Task.tbFlow
			(ParentTaskCode, StepNumber, ChildTaskCode, SyncTypeCode, UsedOnQuantity, OffsetDays)
			SELECT TOP 1 @ParentTaskCode As ParentTask, StepNumber, @ToTaskCode AS ChildTask, SyncTypeCode, UsedOnQuantity, OffsetDays
			FROM         Task.tbFlow 
			WHERE     (ChildTaskCode = @FromTaskCode)		
			END
	
		DECLARE curTask cursor local for			
			SELECT     ChildTaskCode
			FROM         Task.tbFlow
			WHERE     (ParentTaskCode = @FromTaskCode)
	
		OPEN curTask
	
		FETCH NEXT FROM curTask INTO @ChildTaskCode
		WHILE (@@FETCH_STATUS = 0)
			BEGIN
			EXEC Task.proc_Copy @ChildTaskCode, @ToTaskCode
			FETCH NEXT FROM curTask INTO @ChildTaskCode
			END
		
		CLOSE curTask
		DEALLOCATE curTask
		
		IF @@NESTLEVEL = 1
			BEGIN
			COMMIT TRANSACTION
			EXEC Task.proc_Schedule @ToTaskCode
			END

  	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
go

CREATE PROCEDURE Task.proc_Cost 
	(
	@ParentTaskCode nvarchar(20),
	@TotalCost money = 0 OUTPUT
	)
AS
 	SET NOCOUNT, XACT_ABORT ON;

	BEGIN TRY
		WITH task_flow AS
		(
			SELECT parent_task.TaskCode, child.ParentTaskCode, child.ChildTaskCode, 
				CASE WHEN child.UsedOnQuantity <> 0 THEN parent_task.Quantity * child.UsedOnQuantity ELSE child_task.Quantity END AS Quantity, 
				1 AS Depth				
			FROM Task.tbFlow child 
				JOIN Task.tbTask parent_task ON child.ParentTaskCode = parent_task.TaskCode
				JOIN Task.tbTask child_task ON child.ChildTaskCode = child_task.TaskCode
			WHERE parent_task.TaskCode = @ParentTaskCode

			UNION ALL

			SELECT parent.TaskCode, child.ParentTaskCode, child.ChildTaskCode, 
				CASE WHEN child.UsedOnQuantity <> 0 THEN parent.Quantity * child.UsedOnQuantity ELSE child_task.Quantity END AS Quantity, 
				parent.Depth + 1 AS Depth
			FROM Task.tbFlow child 
				JOIN task_flow parent ON child.ParentTaskCode = parent.ChildTaskCode
				JOIN Task.tbTask child_task ON child.ChildTaskCode = child_task.TaskCode
		)
		, tasks AS
		(
			SELECT task_flow.TaskCode, task.Quantity,
				CASE category.CashModeCode 
					WHEN NULL THEN 0 
					WHEN 0 THEN task.UnitCharge * -1 
					ELSE task.UnitCharge 
				END AS UnitCharge
			FROM task_flow
				JOIN Task.tbTask task ON task_flow.ChildTaskCode = task.TaskCode
				LEFT OUTER JOIN Cash.tbCode cashcode ON cashcode.CashCode = task.CashCode 
				LEFT OUTER JOIN Cash.tbCategory category ON category.CategoryCode = cashcode.CategoryCode
		), task_costs AS
		(
			SELECT TaskCode, SUM(Quantity * UnitCharge) AS TotalCost
			FROM tasks
			GROUP BY TaskCode
		)
		SELECT @TotalCost = TotalCost
		FROM task_costs;		

  	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
go

CREATE PROCEDURE Task.proc_DefaultDocType
	(
		@TaskCode nvarchar(20),
		@DocTypeCode smallint OUTPUT
	)
AS
   	SET NOCOUNT, XACT_ABORT ON;

	BEGIN TRY
		DECLARE 
			@CashModeCode smallint
			, @TaskStatusCode smallint

		IF EXISTS(SELECT     CashModeCode
				  FROM         Task.vwCashMode
				  WHERE     (TaskCode = @TaskCode))
			SELECT   @CashModeCode = CashModeCode
			FROM         Task.vwCashMode
			WHERE     (TaskCode = @TaskCode)			          
		ELSE
			SET @CashModeCode = 1

		SELECT  @TaskStatusCode =TaskStatusCode
		FROM         Task.tbTask
		WHERE     (TaskCode = @TaskCode)		
	
		IF @CashModeCode = 0
			SET @DocTypeCode = CASE @TaskStatusCode WHEN 0 THEN 2 ELSE 3 END								
		ELSE
			SET @DocTypeCode = CASE @TaskStatusCode WHEN 0 THEN 0 ELSE 1 END 
		 
  	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
go

CREATE PROCEDURE Task.proc_DefaultInvoiceType
	(
		@TaskCode nvarchar(20),
		@InvoiceTypeCode smallint OUTPUT
	)
AS
   	SET NOCOUNT, XACT_ABORT ON;

	BEGIN TRY

		DECLARE @CashModeCode smallint

		IF EXISTS(SELECT     CashModeCode
				  FROM         Task.vwCashMode
				  WHERE     (TaskCode = @TaskCode))
			SELECT   @CashModeCode = CashModeCode
			FROM         Task.vwCashMode
			WHERE     (TaskCode = @TaskCode)			          
		ELSE
			SET @CashModeCode = 1
		
		IF @CashModeCode = 0
			SET @InvoiceTypeCode = 2
		ELSE
			SET @InvoiceTypeCode = 0
		 
  	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
go

CREATE PROCEDURE Task.proc_DefaultTaxCode 
	(
	@AccountCode nvarchar(10),
	@CashCode nvarchar(50),
	@TaxCode nvarchar(10) OUTPUT
	)
AS
   	SET NOCOUNT, XACT_ABORT ON;

	BEGIN TRY		
		IF (NOT @AccountCode IS NULL) and (NOT @CashCode IS NULL)
			BEGIN
			IF EXISTS(SELECT     TaxCode
				  FROM         Org.tbOrg
				  WHERE     (AccountCode = @AccountCode) AND (NOT (TaxCode IS NULL)))
				BEGIN
				SELECT    @TaxCode = TaxCode
				FROM         Org.tbOrg
				WHERE     (AccountCode = @AccountCode) AND (NOT (TaxCode IS NULL))
				END
			ELSE
				BEGIN
				SELECT    @TaxCode =  TaxCode
				FROM         Cash.tbCode
				WHERE     (CashCode = @CashCode)		
				END
			END
		ELSE
			SET @TaxCode = null
		
  	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
go

CREATE PROCEDURE Task.proc_Delete 
	(
	@TaskCode nvarchar(20)
	)
AS
   	SET NOCOUNT, XACT_ABORT ON;

	BEGIN TRY
		DECLARE @ChildTaskCode nvarchar(20)

		IF @@NESTLEVEL = 1
			BEGIN TRANSACTION

		DELETE FROM Task.tbFlow
		WHERE     (ChildTaskCode = @TaskCode)

		DECLARE curFlow cursor local for
			SELECT     ChildTaskCode
			FROM         Task.tbFlow
			WHERE     (ParentTaskCode = @TaskCode)
	
		OPEN curFlow		
		FETCH NEXT FROM curFlow INTO @ChildTaskCode
		WHILE @@FETCH_STATUS = 0
			BEGIN
			EXEC Task.proc_Delete @ChildTaskCode
			FETCH NEXT FROM curFlow INTO @ChildTaskCode		
			END
	
		CLOSE curFlow
		DEALLOCATE curFlow
	
		DELETE FROM Task.tbTask
		WHERE (TaskCode = @TaskCode)
	
		IF @@NESTLEVEL = 1
			COMMIT TRANSACTION

  	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
go

CREATE PROCEDURE Task.proc_EmailAddress 
	(
	@TaskCode nvarchar(20),
	@EmailAddress nvarchar(255) OUTPUT
	)
AS
SET NOCOUNT, XACT_ABORT ON;

	BEGIN TRY
		IF EXISTS(SELECT     Org.tbContact.EmailAddress
				  FROM         Org.tbContact INNER JOIN
										Task.tbTask ON Org.tbContact.AccountCode = Task.tbTask.AccountCode AND Org.tbContact.ContactName = Task.tbTask.ContactName
				  WHERE     ( Task.tbTask.TaskCode = @TaskCode)
				  GROUP BY Org.tbContact.EmailAddress
				  HAVING      (NOT ( Org.tbContact.EmailAddress IS NULL)))
			BEGIN
			SELECT    @EmailAddress = Org.tbContact.EmailAddress
			FROM         Org.tbContact INNER JOIN
								tbTask ON Org.tbContact.AccountCode = Task.tbTask.AccountCode AND Org.tbContact.ContactName = Task.tbTask.ContactName
			WHERE     ( Task.tbTask.TaskCode = @TaskCode)
			GROUP BY Org.tbContact.EmailAddress
			HAVING      (NOT ( Org.tbContact.EmailAddress IS NULL))	
			END
		ELSE
			BEGIN
			SELECT    @EmailAddress =  Org.tbOrg.EmailAddress
			FROM         Org.tbOrg INNER JOIN
								 Task.tbTask ON Org.tbOrg.AccountCode = Task.tbTask.AccountCode
			WHERE     ( Task.tbTask.TaskCode = @TaskCode)
			END
		
  	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
go

CREATE PROCEDURE Task.proc_EmailDetail 
	(
	@TaskCode nvarchar(20)
	)
AS
SET NOCOUNT, XACT_ABORT ON;

	BEGIN TRY
		DECLARE 
			@NickName nvarchar(100)
			, @EmailAddress nvarchar(255)

		IF EXISTS(SELECT     Org.tbContact.ContactName
				  FROM         Org.tbContact INNER JOIN
										Task.tbTask ON Org.tbContact.AccountCode = Task.tbTask.AccountCode AND Org.tbContact.ContactName = Task.tbTask.ContactName
				  WHERE     ( Task.tbTask.TaskCode = @TaskCode))
			BEGIN
			SELECT  @NickName = CASE WHEN Org.tbContact.NickName is null THEN Org.tbContact.ContactName ELSE Org.tbContact.NickName END
						  FROM         Org.tbContact INNER JOIN
												tbTask ON Org.tbContact.AccountCode = Task.tbTask.AccountCode AND Org.tbContact.ContactName = Task.tbTask.ContactName
						  WHERE     ( Task.tbTask.TaskCode = @TaskCode)				
			END
		ELSE
			BEGIN
			SELECT @NickName = ContactName
			FROM         Task.tbTask
			WHERE     (TaskCode = @TaskCode)
			END
	
		EXEC Task.proc_EmailAddress	@TaskCode, @EmailAddress output
	
		SELECT     Task.tbTask.TaskCode, Task.tbTask.TaskTitle, Org.tbOrg.AccountCode, Org.tbOrg.AccountName, @NickName AS NickName, @EmailAddress AS EmailAddress, 
							  Task.tbTask.ActivityCode, Task.tbStatus.TaskStatus, Task.tbTask.TaskNotes
		FROM         Task.tbTask INNER JOIN
							  Task.tbStatus ON Task.tbTask.TaskStatusCode = Task.tbStatus.TaskStatusCode INNER JOIN
							  Org.tbOrg ON Task.tbTask.AccountCode = Org.tbOrg.AccountCode
		WHERE     ( Task.tbTask.TaskCode = @TaskCode)

  	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
go

CREATE PROCEDURE Task.proc_EmailFooter 
AS
--mod replace with view

	SET NOCOUNT, XACT_ABORT ON;

	BEGIN TRY
		SELECT        u.UserName, u.PhoneNumber, u.MobileNumber, o.AccountName, o.WebSite
		FROM            Usr.vwCredentials AS c INNER JOIN
								 Usr.tbUser AS u ON c.UserId = u.UserId 
			CROSS JOIN
			(SELECT        TOP (1) Org.tbOrg.AccountName, Org.tbOrg.WebSite
			FROM            Org.tbOrg INNER JOIN
										App.tbOptions ON Org.tbOrg.AccountCode = App.tbOptions.AccountCode) AS o

  	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
go

CREATE PROCEDURE Task.proc_FullyInvoiced
	(
	@TaskCode nvarchar(20),
	@IsFullyInvoiced bit = 0 output
	)
AS
	SET NOCOUNT, XACT_ABORT ON;

	BEGIN TRY
		DECLARE 
			@InvoiceValue money
			, @TotalCharge money

		SELECT @InvoiceValue = SUM(InvoiceValue)
		FROM         Invoice.tbTask
		WHERE     (TaskCode = @TaskCode)
	
	
		SELECT @TotalCharge = SUM(TotalCharge)
		FROM         Task.tbTask
		WHERE     (TaskCode = @TaskCode)
	
		IF (@TotalCharge = @InvoiceValue)
			SET @IsFullyInvoiced = 1
		ELSE
			SET @IsFullyInvoiced = 0	
  	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
go

CREATE PROCEDURE Task.proc_IsProject 
	(
	@TaskCode nvarchar(20),
	@IsProject bit = 0 output
	)
  AS
  	SET NOCOUNT, XACT_ABORT ON;

	BEGIN TRY
		IF EXISTS(SELECT     TOP 1 Attribute
				  FROM         Task.tbAttribute
				  WHERE     (TaskCode = @TaskCode))
			SET @IsProject = 1
		ELSE IF EXISTS (SELECT     TOP 1 ParentTaskCode, StepNumber
						FROM         Task.tbFlow
						WHERE     (ParentTaskCode = @TaskCode))
			SET @IsProject = 1
		ELSE
			SET @IsProject = 0
  	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH	
go

CREATE PROCEDURE Task.proc_Mode 
	(
	@TaskCode nvarchar(20)
	)
AS
  	SET NOCOUNT, XACT_ABORT ON;

	BEGIN TRY
		SELECT     Task.tbTask.AccountCode, Task.tbTask.ActivityCode, Task.tbTask.TaskStatusCode, Task.tbTask.ActionOn, Task.vwCashMode.CashModeCode
		FROM         Task.tbTask LEFT OUTER JOIN
							  Task.vwCashMode ON Task.tbTask.TaskCode = Task.vwCashMode.TaskCode
		WHERE     ( Task.tbTask.TaskCode = @TaskCode)
  	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
go

CREATE PROCEDURE Task.proc_NextAttributeOrder 
	(
	@TaskCode nvarchar(20),
	@PrintOrder smallint = 10 output
	)
AS
  	SET NOCOUNT, XACT_ABORT ON;

	BEGIN TRY

		IF EXISTS(SELECT     TOP 1 PrintOrder
				  FROM         Task.tbAttribute
				  WHERE     (TaskCode = @TaskCode))
			BEGIN
			SELECT  @PrintOrder = MAX(PrintOrder) 
			FROM         Task.tbAttribute
			WHERE     (TaskCode = @TaskCode)
			SET @PrintOrder = @PrintOrder - (@PrintOrder % 10) + 10		
			END
		ELSE
			SET @PrintOrder = 10
  	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
go

CREATE PROCEDURE Task.proc_NextOperationNumber 
	(
	@TaskCode nvarchar(20),
	@OperationNumber smallint = 10 output
	)
AS
  	SET NOCOUNT, XACT_ABORT ON;

	BEGIN TRY
		IF EXISTS(SELECT     TOP 1 OperationNumber
				  FROM         Task.tbOp
				  WHERE     (TaskCode = @TaskCode))
			BEGIN
			SELECT  @OperationNumber = MAX(OperationNumber) 
			FROM         Task.tbOp
			WHERE     (TaskCode = @TaskCode)
			SET @OperationNumber = @OperationNumber - (@OperationNumber % 10) + 10		
			END
		ELSE
			SET @OperationNumber = 10
  	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
go

CREATE PROCEDURE Task.proc_Op
	(
	@TaskCode nvarchar(20)
	)
AS
  	SET NOCOUNT, XACT_ABORT ON;

	BEGIN TRY
		IF EXISTS (SELECT     TaskCode
				   FROM         Task.tbOp
				   WHERE     (TaskCode = @TaskCode))
			BEGIN
			SELECT     Task.tbOp.*
				   FROM         Task.tbOp
				   WHERE     (TaskCode = @TaskCode)
			END
		ELSE
			BEGIN
			SELECT     Task.tbOp.*
				   FROM         Task.tbFlow INNER JOIN
										 Task.tbOp ON Task.tbFlow.ParentTaskCode = Task.tbOp.TaskCode
				   WHERE     ( Task.tbFlow.ChildTaskCode = @TaskCode)
			END
		
  	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
go

 CREATE PROCEDURE Task.proc_Parent 
	(
	@TaskCode nvarchar(20),
	@ParentTaskCode nvarchar(20) output
	)
AS
  	SET NOCOUNT, XACT_ABORT ON;

	BEGIN TRY
		SET @ParentTaskCode = @TaskCode
		IF EXISTS(SELECT     ParentTaskCode
					 FROM         Task.tbFlow
					 WHERE     (ChildTaskCode = @ParentTaskCode))
			SELECT @ParentTaskCode = ParentTaskCode
					 FROM         Task.tbFlow
					 WHERE     (ChildTaskCode = @ParentTaskCode)
		
  	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH


go

CREATE PROCEDURE Task.proc_Pay (@TaskCode NVARCHAR(20), @Post BIT = 0,	@PaymentCode nvarchar(20) NULL OUTPUT)
AS
	SET NOCOUNT, XACT_ABORT ON;

	BEGIN TRY
		
		DECLARE 
			@InvoiceTypeCode smallint
			, @InvoiceNumber NVARCHAR(20)
			, @InvoicedOn DATETIME = CURRENT_TIMESTAMP

		SELECT @InvoiceTypeCode = CASE CashModeCode WHEN 0 THEN 2 ELSE 0 END       
		FROM  Task.tbTask INNER JOIN
				Cash.tbCode ON Task.tbTask.CashCode = Cash.tbCode.CashCode INNER JOIN
				Cash.tbCategory ON Cash.tbCode.CategoryCode = Cash.tbCategory.CategoryCode AND Cash.tbCode.CategoryCode = Cash.tbCategory.CategoryCode AND 
				Cash.tbCode.CategoryCode = Cash.tbCategory.CategoryCode
		WHERE Task.tbTask.TaskCode = @TaskCode
		
		EXEC Invoice.proc_Raise @TaskCode = @TaskCode, @InvoiceTypeCode = @InvoiceTypeCode, @InvoicedOn = @InvoicedOn, @InvoiceNumber = @InvoiceNumber OUTPUT
		EXEC Invoice.proc_Accept @InvoiceNumber
		EXEC Invoice.proc_Pay @InvoiceNumber = @InvoiceNumber, @PaidOn = @InvoicedOn, @Post = @Post, @PaymentCode = @PaymentCode OUTPUT

	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
go

CREATE PROCEDURE Task.proc_Project 
	(
	@TaskCode nvarchar(20),
	@ParentTaskCode nvarchar(20) output
	)
AS
  	SET NOCOUNT, XACT_ABORT ON;

	BEGIN TRY
		SET @ParentTaskCode = @TaskCode
		WHILE EXISTS(SELECT     ParentTaskCode
					 FROM         Task.tbFlow
					 WHERE     (ChildTaskCode = @ParentTaskCode))
			SELECT @ParentTaskCode = ParentTaskCode
					 FROM         Task.tbFlow
					 WHERE     (ChildTaskCode = @ParentTaskCode)
  	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
go

CREATE PROCEDURE Task.proc_ReconcileCharge
	(
	@TaskCode nvarchar(20)
	)
AS
  	SET NOCOUNT, XACT_ABORT ON;

	BEGIN TRY
		DECLARE @InvoiceValue money

		SELECT @InvoiceValue = SUM(InvoiceValue)
		FROM         Invoice.tbTask
		WHERE     (TaskCode = @TaskCode)

		UPDATE    Task.tbTask
		SET              TotalCharge = @InvoiceValue, UnitCharge = @InvoiceValue / Quantity
		WHERE     (TaskCode = @TaskCode)	
	
  	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
go

CREATE PROCEDURE Task.proc_ResetChargedUninvoiced
AS
  	SET NOCOUNT, XACT_ABORT ON;

	BEGIN TRY
		UPDATE       Task
		SET                TaskStatusCode = 2
		FROM            Cash.tbCode INNER JOIN
								 Task.tbTask AS Task ON Cash.tbCode.CashCode = Task.CashCode LEFT OUTER JOIN
								 Invoice.tbTask AS InvoiceTask ON Task.TaskCode = InvoiceTask.TaskCode AND Task.TaskCode = InvoiceTask.TaskCode
		WHERE        (InvoiceTask.InvoiceNumber IS NULL) AND (Task.TaskStatusCode = 3)
  	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
go

CREATE PROCEDURE Task.proc_WorkFlow 
	(
	@TaskCode nvarchar(20)
	)
  AS
   	SET NOCOUNT, XACT_ABORT ON;

	BEGIN TRY
		SELECT     Task.tbFlow.ParentTaskCode, Task.tbFlow.StepNumber, Task.tbTask.TaskCode, Task.tbTask.AccountCode, Task.tbTask.ActivityCode, Task.tbTask.TaskStatusCode, 
							  Task.tbTask.ActionOn, Task.vwCashMode.CashModeCode, Task.tbFlow.OffsetDays
		FROM         Task.tbTask INNER JOIN
							  Task.tbFlow ON Task.tbTask.TaskCode = Task.tbFlow.ChildTaskCode LEFT OUTER JOIN
							  Task.vwCashMode ON Task.tbTask.TaskCode = Task.vwCashMode.TaskCode
		WHERE     ( Task.tbFlow.ParentTaskCode = @TaskCode)
		ORDER BY Task.tbFlow.StepNumber, Task.tbFlow.ParentTaskCode
  	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
go

CREATE PROCEDURE Task.proc_WorkFlowSelected 
	(
	@ChildTaskCode nvarchar(20),
	@ParentTaskCode nvarchar(20) = NULL
	)
  AS
   	SET NOCOUNT, XACT_ABORT ON;

	BEGIN TRY
		IF NOT (@ParentTaskCode IS NULL)
			SELECT        Task.tbTask.AccountCode, Task.tbTask.ActivityCode, Task.tbTask.TaskStatusCode, Task.tbTask.ActionOn, Task.vwCashMode.CashModeCode, Task.tbFlow.OffsetDays
			FROM            Task.tbTask INNER JOIN
									 Task.tbFlow ON Task.tbTask.TaskCode = Task.tbFlow.ChildTaskCode LEFT OUTER JOIN
									 Task.vwCashMode ON Task.tbTask.TaskCode = Task.vwCashMode.TaskCode
			WHERE        (Task.tbFlow.ParentTaskCode = @ParentTaskCode) AND (Task.tbFlow.ChildTaskCode = @ChildTaskCode)
		ELSE
			SELECT        Task.tbTask.AccountCode, Task.tbTask.ActivityCode, Task.tbTask.TaskStatusCode, Task.tbTask.ActionOn, Task.vwCashMode.CashModeCode, 0 AS OffsetDays
			FROM            Task.tbTask LEFT OUTER JOIN
									 Task.vwCashMode ON Task.tbTask.TaskCode = Task.vwCashMode.TaskCode
			WHERE        (Task.tbTask.TaskCode = @ChildTaskCode)
  	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
go

CREATE PROCEDURE Usr.proc_MenuCleanReferences(@MenuId SMALLINT)
AS
 	SET NOCOUNT, XACT_ABORT ON;

	BEGIN TRY
		WITH tbFolderRefs AS 
		(	SELECT        MenuId, EntryId, CAST(Argument AS int) AS FolderIdRef
			FROM            Usr.tbMenuEntry
			WHERE        (Command = 1))
		, tbBadRefs AS
		(
			SELECT        tbFolderRefs.EntryId
			FROM            tbFolderRefs LEFT OUTER JOIN
									Usr.tbMenuEntry AS tbMenuEntry ON tbFolderRefs.FolderIdRef = tbMenuEntry.FolderId AND tbFolderRefs.MenuId = tbMenuEntry.MenuId
			WHERE (tbMenuEntry.MenuId = @MenuId) AND (tbMenuEntry.MenuId IS NULL)
		)
		DELETE FROM Usr.tbMenuEntry
		FROM            Usr.tbMenuEntry INNER JOIN
								 tbBadRefs ON Usr.tbMenuEntry.EntryId = tbBadRefs.EntryId;

  	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
go

CREATE PROCEDURE Usr.proc_MenuInsert
	(
		@MenuName nvarchar(50),
		@FromMenuId smallint = 0,
		@MenuId smallint = null OUTPUT
	)
AS
 	SET NOCOUNT, XACT_ABORT ON;

	BEGIN TRY
		BEGIN TRANSACTION
	
		INSERT INTO Usr.tbMenu (MenuName) VALUES (@MenuName)
		SELECT @MenuId = @@IDENTITY
	
		IF @FromMenuId = 0
			BEGIN
			INSERT INTO Usr.tbMenuEntry (MenuId, FolderId, ItemId, ItemText, Command,  Argument)
					VALUES (@MenuId, 1, 0, @MenuName, 0, 'Root')
			END
		ELSE
			BEGIN
			INSERT INTO Usr.tbMenuEntry
								  (MenuId, FolderId, ItemId, OpenMode, Argument, ProjectName, Command, ItemText)
			SELECT     @MenuId AS ToMenuId, FolderId, ItemId, OpenMode, Argument, ProjectName, Command, ItemText
			FROM         Usr.tbMenuEntry
			WHERE     (MenuId = @FromMenuId)
			END

		COMMIT TRANSACTION

  	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
go

CREATE PROCEDURE Usr.proc_MenuItemDelete( @EntryId int )
AS
 	SET NOCOUNT, XACT_ABORT ON;

	BEGIN TRY
		BEGIN TRANSACTION

		DECLARE @MenuId SMALLINT = (SELECT MenuId FROM Usr.tbMenuEntry menu WHERE menu.EntryId = @EntryId);

		DELETE FROM Usr.tbMenuEntry
		WHERE Command = 1 
			AND MenuId = @MenuId
			AND Argument = (SELECT FolderId FROM Usr.tbMenuEntry menu WHERE Command = 0 AND menu.EntryId = @EntryId);

		 WITH root_folder AS
		 (
			 SELECT FolderId, MenuId 
			 FROM Usr.tbMenuEntry menu
			 WHERE Command = 0 AND menu.EntryId = @EntryId
		), child_folders AS
		(
			SELECT CAST(Argument AS smallint) AS FolderId, root_folder.MenuId
			FROM Usr.tbMenuEntry sub_folder 
			JOIN root_folder ON sub_folder.FolderId = root_folder.FolderId
			WHERE Command = 1 AND sub_folder.MenuId = @MenuId

			UNION ALL

			SELECT CAST(Argument AS smallint) AS FolderId, p.MenuId
			FROM child_folders p 
				JOIN Usr.tbMenuEntry m ON p.FolderId = m.FolderId
			WHERE Command = 1 AND m.MenuId = p.MenuId
		), folders AS
		(
			select FolderId from root_folder
			UNION
			select FolderId from child_folders
		)
		DELETE Usr.tbMenuEntry 
		FROM Usr.tbMenuEntry JOIN folders ON Usr.tbMenuEntry.FolderId = folders.FolderId

		DELETE FROM Usr.tbMenuEntry WHERE EntryId = @EntryId;

		COMMIT TRANSACTION

  	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
go

/*  TRIGGERS ****/
CREATE TRIGGER Activity.Activity_tbActivity_TriggerUpdate
   ON  Activity.tbActivity
   AFTER UPDATE, INSERT
AS 
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY	
		IF EXISTS (SELECT * FROM inserted i WHERE App.fnParsePrimaryKey(ActivityCode) = 0)
			BEGIN
			DECLARE @Msg NVARCHAR(MAX);
			SELECT @Msg = Message FROM App.tbText WHERE TextId = 2004;
			RAISERROR (@Msg, 10, 1)
			ROLLBACK
			END
		ELSE
			BEGIN
			UPDATE Activity.tbActivity
			SET UpdatedBy = SUSER_SNAME(), UpdatedOn = CURRENT_TIMESTAMP
			FROM Activity.tbActivity INNER JOIN inserted AS i ON tbActivity.ActivityCode = i.ActivityCode;
			END
	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
END
go
ALTER TABLE Activity.tbActivity ENABLE TRIGGER Activity_tbActivity_TriggerUpdate
go
CREATE TRIGGER Activity.Activity_tbAttribute_TriggerUpdate 
   ON  Activity.tbAttribute
   AFTER UPDATE
AS 
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY	
		UPDATE Activity.tbAttribute
		SET UpdatedBy = SUSER_SNAME(), UpdatedOn = CURRENT_TIMESTAMP
		FROM Activity.tbAttribute INNER JOIN inserted AS i ON tbAttribute.ActivityCode = i.ActivityCode AND tbAttribute.Attribute = i.Attribute;
	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
END
go
ALTER TABLE Activity.tbAttribute ENABLE TRIGGER Activity_tbAttribute_TriggerUpdate
go
CREATE TRIGGER Activity.Activity_tbFlow_TriggerUpdate 
   ON  Activity.tbFlow
   AFTER UPDATE
AS 
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY		
		UPDATE Activity.tbFlow
		SET UpdatedBy = SUSER_SNAME(), UpdatedOn = CURRENT_TIMESTAMP
		FROM Activity.tbFlow INNER JOIN inserted AS i ON tbFlow.ParentCode = i.ParentCode AND tbFlow.StepNumber = i.StepNumber;
	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
END
go
ALTER TABLE Activity.tbFlow ENABLE TRIGGER Activity_tbFlow_TriggerUpdate
go
CREATE TRIGGER Activity.Activity_tbOp_TriggerUpdate 
   ON  Activity.tbOp 
   AFTER UPDATE
AS 
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY
		UPDATE Activity.tbOp
		SET UpdatedBy = SUSER_SNAME(), UpdatedOn = CURRENT_TIMESTAMP
		FROM Activity.tbOp INNER JOIN inserted AS i ON tbOp.ActivityCode = i.ActivityCode AND tbOp.OperationNumber = i.OperationNumber;
	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
END
go
ALTER TABLE Activity.tbOp ENABLE TRIGGER Activity_tbOp_TriggerUpdate
go
CREATE TRIGGER App.App_tbCalendar_TriggerUpdate 
   ON  App.tbCalendar
   AFTER UPDATE, INSERT
AS 
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY
		IF EXISTS (SELECT * FROM inserted i WHERE App.fnParsePrimaryKey(CalendarCode) = 0)
			BEGIN
			DECLARE @Msg NVARCHAR(MAX);
			SELECT @Msg = Message FROM App.tbText WHERE TextId = 2004;
			RAISERROR (@Msg, 10, 1);
			ROLLBACK
			END
	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
END
go
ALTER TABLE App.tbCalendar ENABLE TRIGGER App_tbCalendar_TriggerUpdate
go
CREATE TRIGGER App.App_tbOptions_TriggerUpdate 
   ON  App.tbOptions
   AFTER UPDATE
AS 
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY
		UPDATE App.tbOptions
		SET UpdatedBy = SUSER_SNAME(), UpdatedOn = CURRENT_TIMESTAMP
		FROM App.tbOptions INNER JOIN inserted AS i ON tbOptions.Identifier = i.Identifier;
	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
END
go
ALTER TABLE App.tbOptions ENABLE TRIGGER App_tbOptions_TriggerUpdate
go
CREATE TRIGGER App.App_tbTaxCode_TriggerUpdate
   ON  App.tbTaxCode
   AFTER UPDATE, INSERT
AS 
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY
		IF EXISTS (SELECT * FROM inserted i WHERE App.fnParsePrimaryKey(TaxCode) = 0)
			BEGIN
			DECLARE @Msg NVARCHAR(MAX);
			SELECT @Msg = Message FROM App.tbText WHERE TextId = 2004;
			RAISERROR (@Msg, 10, 1);
			ROLLBACK TRANSACTION;
			END
		ELSE
			BEGIN
			UPDATE App.tbTaxCode
			SET UpdatedBy = SUSER_SNAME(), UpdatedOn = CURRENT_TIMESTAMP
			FROM App.tbTaxCode INNER JOIN inserted AS i ON tbTaxCode.TaxCode = i.TaxCode;
			END
	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
END
go
ALTER TABLE App.tbTaxCode ENABLE TRIGGER App_tbTaxCode_TriggerUpdate
go
CREATE TRIGGER App.App_tbUom_TriggerUpdate
   ON  App.tbUom
   AFTER UPDATE, INSERT
AS 
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY	
		IF EXISTS (SELECT * FROM inserted i WHERE App.fnParsePrimaryKey(UnitOfMeasure) = 0)
			BEGIN
			DECLARE @Msg NVARCHAR(MAX);
			SELECT @Msg = Message FROM App.tbText WHERE TextId = 2004;
			RAISERROR (@Msg, 10, 1)
			ROLLBACK
			END
	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
END
go
ALTER TABLE App.tbUom ENABLE TRIGGER App_tbUom_TriggerUpdate
go
CREATE TRIGGER Cash.Cash_tbCategory_TriggerUpdate 
   ON  Cash.tbCategory
   AFTER UPDATE, INSERT
AS 
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY	
		IF EXISTS (SELECT * FROM inserted i WHERE App.fnParsePrimaryKey(CategoryCode) = 0)
			BEGIN
			DECLARE @Msg NVARCHAR(MAX);
			SELECT @Msg = Message FROM App.tbText WHERE TextId = 2004;
			RAISERROR (@Msg, 10, 1)
			ROLLBACK
			END
		ELSE

			IF UPDATE (IsEnabled)
				BEGIN
				UPDATE  Cash.tbCode
				SET     IsEnabled = 0
				FROM        inserted INNER JOIN
										 Cash.tbCode ON inserted.CategoryCode = Cash.tbCode.CategoryCode
				WHERE        (inserted.IsEnabled = 0) AND (Cash.tbCode.IsEnabled <> 0)

				END
			UPDATE Cash.tbCategory
			SET UpdatedBy = SUSER_SNAME(), UpdatedOn = CURRENT_TIMESTAMP
			FROM Cash.tbCategory INNER JOIN inserted AS i ON tbCategory.CategoryCode = i.CategoryCode;
	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
END
go
ALTER TABLE Cash.tbCategory ENABLE TRIGGER Cash_tbCategory_TriggerUpdate
go
CREATE TRIGGER Cash.Cash_tbCode_TriggerUpdate
   ON  Cash.tbCode
   AFTER UPDATE, INSERT
AS 
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY	
		IF EXISTS (SELECT * FROM inserted i WHERE App.fnParsePrimaryKey(CashCode) = 0)
			BEGIN
			DECLARE @Msg NVARCHAR(MAX);
			SELECT @Msg = Message FROM App.tbText WHERE TextId = 2004;
			RAISERROR (@Msg, 10, 1);
			ROLLBACK
			END
		ELSE
			BEGIN
			UPDATE Cash.tbCode
			SET UpdatedBy = SUSER_SNAME(), UpdatedOn = CURRENT_TIMESTAMP
			FROM Cash.tbCode INNER JOIN inserted AS i ON tbCode.CashCode = i.CashCode;
			END
	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
END
go
ALTER TABLE Cash.tbCode ENABLE TRIGGER Cash_tbCode_TriggerUpdate
go
CREATE TRIGGER Cash.Cash_tbPeriod_Trigger_Update 
ON Cash.tbPeriod FOR INSERT, UPDATE
AS
	SET NOCOUNT ON;

	BEGIN TRY
	IF UPDATE (ForecastValue)
		BEGIN
		UPDATE tbPeriod
		SET ForecastTax = inserted.ForecastValue * tax_code.TaxRate
		FROM inserted 
			JOIN Cash.tbPeriod tbPeriod ON inserted.CashCode = tbPeriod.CashCode AND inserted.StartOn = tbPeriod.StartOn
			JOIN Cash.tbCode cash_code ON tbPeriod.CashCode = cash_code.CashCode 
			JOIN Cash.tbCategory ON cash_code.CategoryCode = Cash.tbCategory.CategoryCode 
            JOIN App.tbTaxCode tax_code ON cash_code.TaxCode = tax_code.TaxCode
		END
	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
go
ALTER TABLE Cash.tbPeriod ENABLE TRIGGER Cash_tbPeriod_Trigger_Update
go
CREATE TRIGGER Invoice.Invoice_tbInvoice_TriggerUpdate
ON Invoice.tbInvoice
FOR UPDATE
AS
	SET NOCOUNT ON;

	BEGIN TRY
		IF UPDATE (Spooled)
		BEGIN
			INSERT INTO App.tbDocSpool (DocTypeCode, DocumentNumber)
			SELECT     App.fnDocInvoiceType(i.InvoiceTypeCode) AS DocTypeCode, i.InvoiceNumber
			FROM         inserted i 
			WHERE     (i.Spooled <> 0)

			DELETE App.tbDocSpool
			FROM         inserted i INNER JOIN
								  App.tbDocSpool ON i.InvoiceNumber = App.tbDocSpool.DocumentNumber
			WHERE    (i.Spooled = 0) AND ( App.tbDocSpool.DocTypeCode > 3)
		END


		IF UPDATE (InvoicedOn)
		BEGIN
			UPDATE invoice
		SET DueOn = App.fnAdjustToCalendar(CASE WHEN org.PayDaysFromMonthEnd <> 0 
												THEN 
													DATEADD(d, -1, DATEADD(m, 1, CONCAT(FORMAT(DATEADD(d, org.PaymentDays, i.InvoicedOn), 'yyyyMM'), '01')))												
												ELSE
													DATEADD(d, org.PaymentDays, invoice.InvoicedOn)	
												END, 0),
			ExpectedOn = App.fnAdjustToCalendar(CASE WHEN org.PayDaysFromMonthEnd <> 0 
												THEN 
													DATEADD(d, -1, DATEADD(m, 1, CONCAT(FORMAT(DATEADD(d, org.PaymentDays + org.ExpectedDays, i.InvoicedOn), 'yyyyMM'), '01')))												
												ELSE
													DATEADD(d, org.PaymentDays + org.ExpectedDays, invoice.InvoicedOn)	
												END, 0)		
			FROM Invoice.tbInvoice invoice
				JOIN inserted i ON i.InvoiceNumber = invoice.InvoiceNumber
				JOIN Org.tbOrg org ON i.AccountCode = org.AccountCode
		END		
	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
go
ALTER TABLE Invoice.tbInvoice ENABLE TRIGGER Invoice_tbInvoice_TriggerUpdate
go
CREATE TRIGGER Invoice.Invoice_tbInvoice_TriggerInsert
ON Invoice.tbInvoice
FOR INSERT
AS
	SET NOCOUNT ON;

	BEGIN TRY
		UPDATE invoice
		SET DueOn = App.fnAdjustToCalendar(CASE WHEN org.PayDaysFromMonthEnd <> 0 
												THEN 
													DATEADD(d, -1, DATEADD(m, 1, CONCAT(FORMAT(DATEADD(d, org.PaymentDays, i.InvoicedOn), 'yyyyMM'), '01')))												
												ELSE
													DATEADD(d, org.PaymentDays, invoice.InvoicedOn)	
												END, 0),
			ExpectedOn = App.fnAdjustToCalendar(CASE WHEN org.PayDaysFromMonthEnd <> 0 
												THEN 
													DATEADD(d, -1, DATEADD(m, 1, CONCAT(FORMAT(DATEADD(d, org.PaymentDays + org.ExpectedDays, i.InvoicedOn), 'yyyyMM'), '01')))												
												ELSE
													DATEADD(d, org.PaymentDays + org.ExpectedDays, invoice.InvoicedOn)	
												END, 0)				 
		FROM Invoice.tbInvoice invoice
			JOIN inserted i ON i.InvoiceNumber = invoice.InvoiceNumber
			JOIN Org.tbOrg org ON i.AccountCode = org.AccountCode		
							
	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
go
ALTER TABLE Invoice.tbInvoice ENABLE TRIGGER Invoice_tbInvoice_TriggerInsert
go
CREATE TRIGGER Invoice.Invoice_tbItem_TriggerInsert
ON Invoice.tbItem
FOR INSERT, UPDATE
AS
	SET NOCOUNT ON;

	BEGIN TRY

		UPDATE item
		SET InvoiceValue = ROUND(inserted.TotalValue / (1 + TaxRate), 2),
			TaxValue = inserted.TotalValue - ROUND(inserted.TotalValue / (1 + TaxRate), 2)				
		FROM inserted 
			INNER JOIN Invoice.tbItem item ON inserted.InvoiceNumber = item.InvoiceNumber 
					AND inserted.CashCode = item.CashCode
				INNER JOIN App.tbTaxCode ON inserted.TaxCode = App.tbTaxCode.TaxCode 
		WHERE inserted.TotalValue <> 0;

		UPDATE item
		SET TaxValue = CASE App.tbTaxCode.RoundingCode 
				WHEN 0 THEN ROUND(item.InvoiceValue * App.tbTaxCode.TaxRate, 2)
				WHEN 1 THEN ROUND( item.InvoiceValue * App.tbTaxCode.TaxRate, 2, 1) END
		FROM Invoice.tbItem item 
			INNER JOIN inserted ON inserted.InvoiceNumber = item.InvoiceNumber
					 AND inserted.CashCode = item.CashCode
				INNER JOIN App.tbTaxCode ON item.TaxCode = App.tbTaxCode.TaxCode
		WHERE inserted.TotalValue = 0; 

	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
go
ALTER TABLE Invoice.tbItem ENABLE TRIGGER Invoice_tbItem_TriggerInsert
go
CREATE TRIGGER Invoice.Invoice_tbTask_TriggerDelete
ON Invoice.tbTask
FOR DELETE
AS
	SET NOCOUNT ON;

	BEGIN TRY
		UPDATE Task.tbTask
		SET TaskStatusCode = 2
		FROM deleted JOIN Task.tbTask ON deleted.TaskCode = Task.tbTask.TaskCode
		WHERE TaskStatusCode = 3;		
	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
go
ALTER TABLE Invoice.tbTask ENABLE TRIGGER Invoice_tbTask_TriggerDelete
go
CREATE TRIGGER Invoice.Invoice_tbTask_TriggerInsert
ON Invoice.tbTask
FOR INSERT, UPDATE
AS
	SET NOCOUNT ON;

	BEGIN TRY

		UPDATE task
		SET InvoiceValue = ROUND(inserted.TotalValue / (1 + TaxRate), 2),
			TaxValue = inserted.TotalValue - ROUND(inserted.TotalValue / (1 + TaxRate), 2)	
		FROM inserted 
			INNER JOIN Invoice.tbTask task ON inserted.InvoiceNumber = task.InvoiceNumber 
					AND inserted.TaskCode = task.TaskCode
				INNER JOIN App.tbTaxCode ON inserted.TaxCode = App.tbTaxCode.TaxCode 
		WHERE inserted.TotalValue <> 0;

		UPDATE task
		SET TaxValue = CASE App.tbTaxCode.RoundingCode 
				WHEN 0 THEN ROUND(task.InvoiceValue * App.tbTaxCode.TaxRate, 2)
				WHEN 1 THEN ROUND( task.InvoiceValue * App.tbTaxCode.TaxRate, 2, 1) END
		FROM Invoice.tbTask task 
			INNER JOIN inserted ON inserted.InvoiceNumber = task.InvoiceNumber
					 AND inserted.TaskCode = task.TaskCode
				INNER JOIN App.tbTaxCode ON task.TaxCode = App.tbTaxCode.TaxCode
		WHERE inserted.TotalValue = 0; 

	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
go
ALTER TABLE Invoice.tbTask ENABLE TRIGGER Invoice_tbTask_TriggerInsert
go
CREATE TRIGGER Org.Org_tbAccount_TriggerUpdate 
   ON  Org.tbAccount
   AFTER UPDATE, INSERT
AS 
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY
	DECLARE @Msg NVARCHAR(MAX);

		IF EXISTS (SELECT * FROM inserted i WHERE App.fnParsePrimaryKey(CashAccountCode) = 0)
			BEGIN		
			SELECT @Msg = Message FROM App.tbText WHERE TextId = 2004;
			RAISERROR (@Msg, 10, 1)
			ROLLBACK
			END
		ELSE IF EXISTS (SELECT * FROM inserted i JOIN Cash.tbCode c ON i.CashCode = c.CashCode WHERE DummyAccount <> 0)
			BEGIN
			SELECT @Msg = Message FROM App.tbText WHERE TextId = 3015;
			RAISERROR (@Msg, 10, 1)
			ROLLBACK
			END
		ELSE
			BEGIN	
			UPDATE Org.tbAccount
			SET UpdatedBy = SUSER_SNAME(), UpdatedOn = CURRENT_TIMESTAMP
			FROM Org.tbAccount INNER JOIN inserted AS i ON tbAccount.CashAccountCode = i.CashAccountCode;
			END
	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
END
go
ALTER TABLE Org.tbAccount ENABLE TRIGGER Org_tbAccount_TriggerUpdate
go
CREATE TRIGGER Org.Org_tbAddress_TriggerInsert
ON Org.tbAddress 
FOR INSERT
AS
	SET NOCOUNT ON;
	BEGIN TRY
		If EXISTS(SELECT     Org.tbOrg.AddressCode, Org.tbOrg.AccountCode
				  FROM         Org.tbOrg INNER JOIN
										inserted AS i ON Org.tbOrg.AccountCode = i.AccountCode
				  WHERE     ( Org.tbOrg.AddressCode IS NULL))
			BEGIN
			UPDATE Org.tbOrg
			SET AddressCode = i.AddressCode
			FROM         Org.tbOrg INNER JOIN
										inserted AS i ON Org.tbOrg.AccountCode = i.AccountCode
				  WHERE     ( Org.tbOrg.AddressCode IS NULL)
			END
	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH

go
ALTER TABLE Org.tbAddress ENABLE TRIGGER Org_tbAddress_TriggerInsert
go
CREATE TRIGGER Org.Org_tbAddress_TriggerUpdate 
   ON  Org.tbAddress
   AFTER UPDATE
AS 
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY
		UPDATE Org.tbAddress
		SET UpdatedBy = SUSER_SNAME(), UpdatedOn = CURRENT_TIMESTAMP
		FROM Org.tbAddress INNER JOIN inserted AS i ON tbAddress.AddressCode = i.AddressCode;
	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
END
go
ALTER TABLE Org.tbAddress ENABLE TRIGGER Org_tbAddress_TriggerUpdate
go
CREATE TRIGGER Org.Org_tbContact_TriggerInsert 
   ON  Org.tbContact
   AFTER INSERT
AS 
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY
	
		UPDATE Org.tbContact
		SET 
			NickName = RTRIM(CASE 
				WHEN LEN(ISNULL(i.NickName, '')) > 0 THEN i.NickName
				WHEN CHARINDEX(' ', tbContact.ContactName, 0) = 0 THEN tbContact.ContactName 
				ELSE LEFT(tbContact.ContactName, CHARINDEX(' ', tbContact.ContactName, 0)) END),
			FileAs = Org.fnContactFileAs(tbContact.ContactName)
		FROM Org.tbContact INNER JOIN inserted AS i ON tbContact.AccountCode = i.AccountCode AND tbContact.ContactName = i.ContactName;

	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
		EXEC App.proc_ErrorLog;
		THROW;
	END CATCH
END
go
ALTER TABLE Org.tbContact ENABLE TRIGGER Org_tbContact_TriggerInsert
go
CREATE TRIGGER Org.Org_tbContact_TriggerUpdate 
   ON  Org.tbContact
   AFTER UPDATE
AS 
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY	

		IF UPDATE(ContactName)
		BEGIN
			UPDATE Org.tbContact
			SET 
				FileAs = Org.fnContactFileAs(tbContact.ContactName)
			FROM Org.tbContact INNER JOIN inserted AS i ON tbContact.AccountCode = i.AccountCode AND tbContact.ContactName = i.ContactName;
		END

		UPDATE Org.tbContact
		SET UpdatedBy = SUSER_SNAME(), UpdatedOn = CURRENT_TIMESTAMP
		FROM Org.tbContact INNER JOIN inserted AS i ON tbContact.AccountCode = i.AccountCode AND tbContact.ContactName = i.ContactName;

	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
END

go
ALTER TABLE Org.tbContact ENABLE TRIGGER Org_tbContact_TriggerUpdate
go
CREATE TRIGGER Org.Org_tbDoc_TriggerUpdate 
   ON  Org.tbDoc
   AFTER UPDATE
AS 
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY	
		UPDATE Org.tbDoc
		SET UpdatedBy = SUSER_SNAME(), UpdatedOn = CURRENT_TIMESTAMP
		FROM Org.tbDoc INNER JOIN inserted AS i ON tbDoc.AccountCode = i.AccountCode AND tbDoc.DocumentName = i.DocumentName;
	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
END
go
ALTER TABLE Org.tbDoc ENABLE TRIGGER Org_tbDoc_TriggerUpdate
go
CREATE TRIGGER Org.Org_tbOrg_TriggerUpdate 
   ON  Org.tbOrg
   AFTER UPDATE, INSERT
AS 
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY
		IF EXISTS (SELECT * FROM inserted i WHERE App.fnParsePrimaryKey(AccountCode) = 0)
			BEGIN
			DECLARE @Msg NVARCHAR(MAX);
			SELECT @Msg = Message FROM App.tbText WHERE TextId = 2004;
			RAISERROR (@Msg, 10, 1);
			ROLLBACK TRANSACTION;
			END
		ELSE
			BEGIN
			UPDATE Org.tbOrg
			SET UpdatedBy = SUSER_SNAME(), UpdatedOn = CURRENT_TIMESTAMP
			FROM Org.tbOrg INNER JOIN inserted AS i ON tbOrg.AccountCode = i.AccountCode;
			END
	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
END
go
ALTER TABLE Org.tbOrg ENABLE TRIGGER Org_tbOrg_TriggerUpdate
go
CREATE TRIGGER Org.Org_tbPayment_TriggerInsert
ON Org.tbPayment
FOR INSERT
AS
	SET NOCOUNT ON;
	BEGIN TRY

		UPDATE payment
		SET PaymentStatusCode = 2
		FROM inserted
			JOIN Org.tbPayment payment ON inserted.PaymentCode = payment.PaymentCode
			JOIN Cash.tbCode ON inserted.CashCode = Cash.tbCode.CashCode 
			JOIN Cash.tbCategory category ON Cash.tbCode.CategoryCode = category.CategoryCode
		WHERE category.CashTypeCode = 2 AND inserted.PaymentStatusCode = 0

	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH

go
ALTER TABLE Org.tbPayment ENABLE TRIGGER Org_tbPayment_TriggerInsert
go
CREATE TRIGGER Org.Org_tbPayment_TriggerUpdate
ON Org.tbPayment
FOR UPDATE
AS
	SET NOCOUNT ON;
	BEGIN TRY
		UPDATE Org.tbPayment
		SET UpdatedBy = SUSER_SNAME(), UpdatedOn = CURRENT_TIMESTAMP
		FROM Org.tbPayment INNER JOIN inserted AS i ON tbPayment.PaymentCode = i.PaymentCode;

		IF UPDATE(PaidInValue) OR UPDATE(PaidOutValue)
			BEGIN
			DECLARE @AccountCode NVARCHAR(10)
			DECLARE org CURSOR LOCAL FOR 
				SELECT AccountCode 
				FROM inserted
				WHERE PaymentStatusCode = 1

			OPEN org
			FETCH NEXT FROM org INTO @AccountCode
			WHILE (@@FETCH_STATUS = 0)
				BEGIN		
				EXEC Org.proc_Rebuild @AccountCode
				FETCH NEXT FROM org INTO @AccountCode
			END

			CLOSE org
			DEALLOCATE org

			END
	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
go
ALTER TABLE Org.tbPayment ENABLE TRIGGER Org_tbPayment_TriggerUpdate
go
CREATE TRIGGER Task.Task_tbAttribute_TriggerUpdate 
   ON  Task.tbAttribute
   AFTER UPDATE
AS 
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY	
		UPDATE Task.tbAttribute
		SET UpdatedBy = SUSER_SNAME(), UpdatedOn = CURRENT_TIMESTAMP
		FROM Task.tbAttribute INNER JOIN inserted AS i ON tbAttribute.TaskCode = i.TaskCode AND tbAttribute.Attribute = i.Attribute;
	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
END
go
ALTER TABLE Task.tbAttribute ENABLE TRIGGER Task_tbAttribute_TriggerUpdate
go
CREATE TRIGGER Task.Task_tbDoc_TriggerUpdate 
   ON  Task.tbDoc
   AFTER UPDATE
AS 
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY	
		UPDATE Task.tbDoc
		SET UpdatedBy = SUSER_SNAME(), UpdatedOn = CURRENT_TIMESTAMP
		FROM Task.tbDoc INNER JOIN inserted AS i ON tbDoc.TaskCode = i.TaskCode AND tbDoc.DocumentName = i.DocumentName;
	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
END
go
ALTER TABLE Task.tbDoc ENABLE TRIGGER Task_tbDoc_TriggerUpdate
go
CREATE TRIGGER Task.Task_tbFlow_TriggerUpdate 
   ON  Task.tbFlow
   AFTER UPDATE
AS 
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY	
		UPDATE Task.tbFlow
		SET UpdatedBy = SUSER_SNAME(), UpdatedOn = CURRENT_TIMESTAMP
		FROM Task.tbFlow INNER JOIN inserted AS i ON tbFlow.ParentTaskCode = i.ParentTaskCode AND tbFlow.StepNumber = i.StepNumber;
	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
END
go
ALTER TABLE Task.tbFlow ENABLE TRIGGER Task_tbFlow_TriggerUpdate
go
CREATE TRIGGER Task.Task_tbOp_TriggerUpdate 
   ON  Task.tbOp 
   AFTER UPDATE, INSERT
AS 
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY
		DECLARE @Msg NVARCHAR(MAX);

		UPDATE ops
		SET StartOn = CAST(ops.StartOn AS DATE), EndOn = CAST(ops.EndOn AS DATE)
		FROM Task.tbOp ops JOIN inserted i ON ops.TaskCode = i.TaskCode AND ops.OperationNumber = i.OperationNumber
		WHERE (DATEDIFF(SECOND, CAST(i.StartOn AS DATE), i.StartOn) <> 0 
				OR DATEDIFF(SECOND, CAST(i.EndOn AS DATE), i.EndOn) <> 0);
					
		IF EXISTS (	SELECT *
				FROM inserted
					JOIN Task.tbOp ops ON inserted.TaskCode = ops.TaskCode AND inserted.OperationNumber = ops.OperationNumber
				WHERE inserted.StartOn > inserted.EndOn)
			BEGIN
			UPDATE ops
			SET EndOn = ops.StartOn
			FROM Task.tbOp ops JOIN inserted i ON ops.TaskCode = i.TaskCode AND ops.OperationNumber = i.OperationNumber;
						
			SELECT @Msg = Message FROM App.tbText WHERE TextId = 3016;
			EXEC App.proc_EventLog @EventMessage = @Msg, @EventTypeCode = 1		
			END;

		WITH tasks AS
		(
			SELECT TaskCode FROM inserted GROUP BY TaskCode
		), last_calloff AS
		(
			SELECT ops.TaskCode, MAX(OperationNumber) AS OperationNumber
			FROM Task.tbOp ops JOIN tasks ON ops.TaskCode = tasks.TaskCode	
			WHERE SyncTypeCode = 2 
			GROUP BY ops.TaskCode
		), calloff AS
		(
			SELECT inserted.TaskCode, inserted.EndOn FROM inserted 
			JOIN last_calloff ON inserted.TaskCode = last_calloff.TaskCode AND inserted.OperationNumber = last_calloff.OperationNumber
			WHERE SyncTypeCode = 2
		)
		UPDATE task
		SET ActionOn = calloff.EndOn
		FROM Task.tbTask task
		JOIN calloff ON task.TaskCode = calloff.TaskCode
		WHERE calloff.EndOn <> task.ActionOn AND task.TaskStatusCode < 3;

		UPDATE Task.tbOp
		SET UpdatedBy = SUSER_SNAME(), UpdatedOn = CURRENT_TIMESTAMP
		FROM Task.tbOp INNER JOIN inserted AS i ON tbOp.TaskCode = i.TaskCode AND tbOp.OperationNumber = i.OperationNumber;
	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
END
go
ALTER TABLE Task.tbOp ENABLE TRIGGER Task_tbOp_TriggerUpdate
go
CREATE TRIGGER Task.Task_tbQuote_TriggerUpdate 
   ON  Task.tbQuote
   AFTER UPDATE
AS 
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY
		UPDATE Task.tbQuote
		SET UpdatedBy = SUSER_SNAME(), UpdatedOn = CURRENT_TIMESTAMP
		FROM Task.tbQuote INNER JOIN inserted AS i ON tbQuote.TaskCode = i.TaskCode AND tbQuote.Quantity = i.Quantity;
	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
END
go
ALTER TABLE Task.tbQuote ENABLE TRIGGER Task_tbQuote_TriggerUpdate
go
CREATE TRIGGER Task.Task_tbTask_TriggerInsert
ON Task.tbTask
FOR INSERT
AS
	SET NOCOUNT ON;
	BEGIN TRY

	    UPDATE task
	    SET task.ActionOn = CAST(task.ActionOn AS DATE)
	    FROM Task.tbTask task JOIN inserted i ON task.TaskCode = i.TaskCode
	    WHERE DATEDIFF(SECOND, CAST(i.ActionOn AS DATE), i.ActionOn) <> 0;

	    UPDATE task
	    SET task.TotalCharge = i.UnitCharge * i.Quantity
	    FROM Task.tbTask task JOIN inserted i ON task.TaskCode = i.TaskCode
	    WHERE i.TotalCharge = 0 

	    UPDATE task
	    SET task.UnitCharge = i.TotalCharge / i.Quantity
	    FROM Task.tbTask task JOIN inserted i ON task.TaskCode = i.TaskCode
	    WHERE i.UnitCharge = 0 AND i.Quantity > 0;

	    UPDATE task
	    SET PaymentOn = App.fnAdjustToCalendar(
            CASE WHEN org.PayDaysFromMonthEnd <> 0 THEN 
                    DATEADD(d, -1, DATEADD(m, 1, CONCAT(FORMAT(DATEADD(d, org.PaymentDays + org.ExpectedDays, task.ActionOn), 'yyyyMM'), '01')))												
                ELSE 
                    DATEADD(d, org.PaymentDays + org.ExpectedDays, task.ActionOn) END, 0) 
	    FROM Task.tbTask task
		    JOIN Org.tbOrg org ON task.AccountCode = org.AccountCode
		    JOIN inserted i ON task.TaskCode = i.TaskCode
	    WHERE NOT task.CashCode IS NULL 

	    INSERT INTO Org.tbContact (AccountCode, ContactName)
	    SELECT DISTINCT AccountCode, ContactName 
	    FROM inserted
	    WHERE EXISTS (SELECT ContactName FROM inserted AS i WHERE (NOT (ContactName IS NULL)) AND (ContactName <> N''))
                AND NOT EXISTS(SELECT Org.tbContact.ContactName FROM inserted AS i INNER JOIN Org.tbContact ON i.AccountCode = Org.tbContact.AccountCode AND i.ContactName = Org.tbContact.ContactName)
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
		EXEC App.proc_ErrorLog;
		THROW;
	END CATCH
go
ALTER TABLE Task.tbTask ENABLE TRIGGER Task_tbTask_TriggerInsert
go
CREATE TRIGGER Task.Task_tbTask_TriggerUpdate
ON Task.tbTask
FOR UPDATE
AS
	SET NOCOUNT ON;

	BEGIN TRY

		UPDATE task
		SET task.ActionOn = CAST(task.ActionOn AS DATE)
		FROM Task.tbTask task JOIN inserted i ON task.TaskCode = i.TaskCode
		WHERE DATEDIFF(SECOND, CAST(i.ActionOn AS DATE), i.ActionOn) <> 0;

		IF UPDATE(TaskStatusCode)
			BEGIN
			UPDATE ops
			SET OpStatusCode = 2
			FROM inserted JOIN Task.tbOp ops ON inserted.TaskCode = ops.TaskCode
			WHERE TaskStatusCode > 1 AND OpStatusCode < 2;

			WITH first_ops AS
			(
				SELECT ops.TaskCode, MIN(ops.OperationNumber) AS OperationNumber
				FROM inserted i JOIN Task.tbOp ops ON i.TaskCode = ops.TaskCode 
				WHERE i.TaskStatusCode = 1		
				GROUP BY ops.TaskCode		
			), next_ops AS
			(
				SELECT ops.TaskCode, ops.OperationNumber, ops.SyncTypeCode,
					LEAD(ops.OperationNumber) OVER (PARTITION BY ops.TaskCode ORDER BY ops.OperationNumber) AS NextOpNo
				FROM inserted i JOIN Task.tbOp ops ON i.TaskCode = ops.TaskCode 
			), async_ops AS
			(
				SELECT first_ops.TaskCode, first_ops.OperationNumber, next_ops.NextOpNo
				FROM first_ops JOIN next_ops ON first_ops.TaskCode = next_ops.TaskCode AND first_ops.OperationNumber = next_ops.OperationNumber

				UNION ALL

				SELECT next_ops.TaskCode, next_ops.OperationNumber, next_ops.NextOpNo
				FROM next_ops JOIN async_ops ON next_ops.TaskCode = async_ops.TaskCode AND next_ops.OperationNumber = async_ops.NextOpNo
				WHERE next_ops.SyncTypeCode = 1

			)
			UPDATE ops
			SET OpStatusCode = 1
			FROM async_ops JOIN Task.tbOp ops ON async_ops.TaskCode = ops.TaskCode
				AND async_ops.OperationNumber = ops.OperationNumber;
			
			WITH cascade_status AS
			(
				SELECT TaskCode, TaskStatusCode
				FROM Task.tbTask inserted
				WHERE NOT CashCode IS NULL AND TaskStatusCode > 1
			), task_flow AS
			(
				SELECT cascade_status.TaskStatusCode ParentStatusCode, child.ParentTaskCode, child.ChildTaskCode, child_task.TaskStatusCode
				FROM Task.tbFlow child 
					JOIN cascade_status ON child.ParentTaskCode = cascade_status.TaskCode
					JOIN Task.tbTask child_task ON child.ChildTaskCode = child_task.TaskCode
				WHERE CashCode IS NULL

				UNION ALL

				SELECT parent.ParentStatusCode, child.ParentTaskCode, child.ChildTaskCode, child_task.TaskStatusCode
				FROM Task.tbFlow child 
					JOIN task_flow parent ON child.ParentTaskCode = parent.ChildTaskCode
					JOIN Task.tbTask child_task ON child.ChildTaskCode = child_task.TaskCode
				WHERE CashCode IS NULL
			)
			UPDATE task
			SET TaskStatusCode = CASE task_flow.ParentStatusCode WHEN 3 THEN 2 ELSE task_flow.ParentStatusCode END
			FROM Task.tbTask task JOIN task_flow ON task_flow.ChildTaskCode = task.TaskCode
			WHERE task.TaskStatusCode < 2;

			--not triggering fix
			WITH cascade_status AS
			(
				SELECT TaskCode, TaskStatusCode
				FROM Task.tbTask inserted
				WHERE NOT CashCode IS NULL AND TaskStatusCode > 1
			), task_flow AS
			(
				SELECT cascade_status.TaskStatusCode ParentStatusCode, child.ParentTaskCode, child.ChildTaskCode, child_task.TaskStatusCode
				FROM Task.tbFlow child 
					JOIN cascade_status ON child.ParentTaskCode = cascade_status.TaskCode
					JOIN Task.tbTask child_task ON child.ChildTaskCode = child_task.TaskCode
				WHERE CashCode IS NULL

				UNION ALL

				SELECT parent.ParentStatusCode, child.ParentTaskCode, child.ChildTaskCode, child_task.TaskStatusCode
				FROM Task.tbFlow child 
					JOIN task_flow parent ON child.ParentTaskCode = parent.ChildTaskCode
					JOIN Task.tbTask child_task ON child.ChildTaskCode = child_task.TaskCode
				WHERE CashCode IS NULL
			)
			UPDATE ops
			SET OpStatusCode = 2
			FROM Task.tbOp ops JOIN task_flow ON task_flow.ChildTaskCode = ops.TaskCode
			WHERE ops.OpStatusCode < 2;

			END

		IF UPDATE(Quantity)
			BEGIN
			UPDATE flow
			SET UsedOnQuantity = inserted.Quantity / parent_task.Quantity
			FROM Task.tbFlow AS flow 
				JOIN inserted ON flow.ChildTaskCode = inserted.TaskCode 
				JOIN Task.tbTask AS parent_task ON flow.ParentTaskCode = parent_task.TaskCode
				JOIN Cash.tbCode ON parent_task.CashCode = Cash.tbCode.CashCode
			WHERE (flow.UsedOnQuantity <> 0) AND (inserted.Quantity <> 0) 
				AND (inserted.Quantity / parent_task.Quantity <> flow.UsedOnQuantity)
			END

		IF UPDATE(Quantity) OR UPDATE(UnitCharge)
			BEGIN
			UPDATE task
			SET task.TotalCharge = i.Quantity * i.UnitCharge
			FROM Task.tbTask task JOIN inserted i ON task.TaskCode = i.TaskCode
			END

		IF UPDATE(TotalCharge)
			BEGIN
			UPDATE task
			SET task.UnitCharge = CASE i.TotalCharge + i.Quantity WHEN 0 THEN 0 ELSE i.TotalCharge / i.Quantity END
			FROM Task.tbTask task JOIN inserted i ON task.TaskCode = i.TaskCode			
			END

		IF UPDATE(ActionOn)
			BEGIN			
			WITH parent_task AS
			(
				SELECT        ParentTaskCode
				FROM            Task.tbFlow flow
					JOIN Task.tbTask task ON flow.ParentTaskCode = task.TaskCode
					JOIN Cash.tbCode cash ON task.CashCode = cash.CashCode
					JOIN inserted ON flow.ChildTaskCode = inserted.TaskCode
				--manual scheduling only
				WHERE (SELECT SUM(UsedOnQuantity) FROM inserted JOIN Task.tbFlow ON inserted.TaskCode = Task.tbFlow.ChildTaskCode) = 0	
			), task_flow AS
			(
				SELECT        flow.ParentTaskCode, flow.StepNumber, task.ActionOn,
						LAG(task.ActionOn, 1, task.ActionOn) OVER (PARTITION BY flow.ParentTaskCode ORDER BY StepNumber) AS PrevActionOn
				FROM Task.tbFlow flow
					JOIN Task.tbTask task ON flow.ChildTaskCode = task.TaskCode
					JOIN parent_task ON flow.ParentTaskCode = parent_task.ParentTaskCode
			), step_disordered AS
			(
				SELECT ParentTaskCode 
				FROM task_flow
				WHERE ActionOn < PrevActionOn
				GROUP BY ParentTaskCode
			), step_ordered AS
			(
				SELECT flow.ParentTaskCode, flow.ChildTaskCode,
					ROW_NUMBER() OVER (PARTITION BY flow.ParentTaskCode ORDER BY task.ActionOn, flow.StepNumber) * 10 AS StepNumber 
				FROM step_disordered
					JOIN Task.tbFlow flow ON step_disordered.ParentTaskCode = flow.ParentTaskCode
					JOIN Task.tbTask task ON flow.ChildTaskCode = task.TaskCode
			)
			UPDATE flow
			SET
				StepNumber = step_ordered.StepNumber
			FROM Task.tbFlow flow
				JOIN step_ordered ON flow.ParentTaskCode = step_ordered.ParentTaskCode AND flow.ChildTaskCode = step_ordered.ChildTaskCode;
			
			IF EXISTS(SELECT * FROM App.tbOptions WHERE IsAutoOffsetDays <> 0)
			BEGIN
				UPDATE flow
				SET OffsetDays = App.fnOffsetDays(inserted.ActionOn, parent_task.ActionOn)
									- ISNULL((SELECT SUM(OffsetDays) FROM Task.tbFlow sub_flow WHERE sub_flow.ParentTaskCode = flow.ParentTaskCode AND sub_flow.StepNumber > flow.StepNumber), 0)
				FROM Task.tbFlow AS flow 
					JOIN inserted ON flow.ChildTaskCode = inserted.TaskCode 
					JOIN Task.tbTask AS parent_task ON flow.ParentTaskCode = parent_task.TaskCode
					JOIN Cash.tbCode ON parent_task.CashCode = Cash.tbCode.CashCode
				WHERE (SELECT SUM(UsedOnQuantity) FROM inserted JOIN Task.tbFlow ON inserted.TaskCode = Task.tbFlow.ChildTaskCode) = 0
			END

			UPDATE task
			SET PaymentOn = App.fnAdjustToCalendar(CASE WHEN org.PayDaysFromMonthEnd <> 0 
													THEN 
														DATEADD(d, -1, DATEADD(m, 1, CONCAT(FORMAT(DATEADD(d, org.PaymentDays + org.ExpectedDays, i.ActionOn), 'yyyyMM'), '01')))												
													ELSE
														DATEADD(d, org.PaymentDays + org.ExpectedDays, i.ActionOn)	
													END, 0) 
			FROM Task.tbTask task
				JOIN inserted i ON task.TaskCode = i.TaskCode
				JOIN Org.tbOrg org ON i.AccountCode = org.AccountCode				
			WHERE NOT task.CashCode IS NULL 
			END

		IF UPDATE (TaskTitle)
		BEGIN
			WITH cascade_title_change AS
			(
				SELECT inserted.TaskCode, inserted.TaskTitle AS TaskTitle, deleted.TaskTitle AS PreviousTitle 				
				FROM inserted
					JOIN deleted ON inserted.TaskCode = deleted.TaskCode
			), task_flow AS
			(
				SELECT cascade_title_change.TaskTitle AS ProjectTitle, cascade_title_change.PreviousTitle, child.ParentTaskCode, child.ChildTaskCode, child_task.TaskTitle
				FROM Task.tbFlow child 
					JOIN cascade_title_change ON child.ParentTaskCode = cascade_title_change.TaskCode
					JOIN Task.tbTask child_task ON child.ChildTaskCode = child_task.TaskCode

				UNION ALL

				SELECT parent.ProjectTitle, parent.PreviousTitle, child.ParentTaskCode, child.ChildTaskCode, child_task.TaskTitle
				FROM Task.tbFlow child 
					JOIN task_flow parent ON child.ParentTaskCode = parent.ChildTaskCode
					JOIN Task.tbTask child_task ON child.ChildTaskCode = child_task.TaskCode
			)
			UPDATE task
			SET TaskTitle = ProjectTitle
			FROM Task.tbTask task JOIN task_flow ON task.TaskCode = task_flow.ChildTaskCode
			WHERE task_flow.PreviousTitle = task_flow.TaskTitle;
		END

		IF UPDATE (Spooled)
		BEGIN
			INSERT INTO App.tbDocSpool (DocTypeCode, DocumentNumber)
			SELECT CASE 
					WHEN CashModeCode = 0 THEN		--Expense
						CASE WHEN TaskStatusCode = 0 THEN 2	ELSE 3 END	--Enquiry								
					WHEN CashModeCode = 1 THEN		--Income
						CASE WHEN TaskStatusCode = 0 THEN 0	ELSE 1 END	--Quote
					END AS DocTypeCode, task.TaskCode
			FROM   inserted task INNER JOIN
									 Cash.tbCode ON task.CashCode = Cash.tbCode.CashCode INNER JOIN
									 Cash.tbCategory ON Cash.tbCode.CategoryCode = Cash.tbCategory.CategoryCode
			WHERE (task.Spooled <> 0)
				
			DELETE App.tbDocSpool
			FROM         inserted i INNER JOIN
								  App.tbDocSpool ON i.TaskCode = App.tbDocSpool.DocumentNumber
			WHERE    (i.Spooled = 0) AND ( App.tbDocSpool.DocTypeCode <= 3)
		END

		IF UPDATE (ContactName)
		BEGIN
			INSERT INTO Org.tbContact (AccountCode, ContactName)
			SELECT DISTINCT AccountCode, ContactName FROM inserted
			WHERE EXISTS (SELECT     *
						FROM         inserted AS i
						WHERE     (NOT (ContactName IS NULL)) AND
												(ContactName <> N''))
				AND NOT EXISTS(SELECT  *
								FROM         inserted AS i INNER JOIN
													Org.tbContact ON i.AccountCode = Org.tbContact.AccountCode AND i.ContactName = Org.tbContact.ContactName)
		END
		
		UPDATE Task.tbTask
		SET UpdatedBy = SUSER_SNAME(), UpdatedOn = CURRENT_TIMESTAMP
		FROM Task.tbTask INNER JOIN inserted AS i ON tbTask.TaskCode = i.TaskCode;

	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
go
ALTER TABLE Task.tbTask ENABLE TRIGGER Task_tbTask_TriggerUpdate
go
CREATE TRIGGER Usr.Usr_tbMenuEntry_TriggerUpdate 
   ON  Usr.tbMenuEntry
   AFTER UPDATE
AS 
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY
		UPDATE Usr.tbMenuEntry
		SET UpdatedBy = SUSER_SNAME(), UpdatedOn = CURRENT_TIMESTAMP
		FROM Usr.tbMenuEntry INNER JOIN inserted AS i ON tbMenuEntry.EntryId = i.EntryId AND tbMenuEntry.EntryId = i.EntryId;
	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
END
go
ALTER TABLE Usr.tbMenuEntry ENABLE TRIGGER Usr_tbMenuEntry_TriggerUpdate
go
CREATE TRIGGER Usr.Usr_tbUser_TriggerUpdate 
   ON  Usr.tbUser
   AFTER UPDATE
AS 
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY
		
		UPDATE Usr.tbUser
		SET UpdatedBy = SUSER_SNAME(), UpdatedOn = CURRENT_TIMESTAMP
		FROM Usr.tbUser INNER JOIN inserted AS i ON tbUser.UserId = i.UserId;
	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
END
go
ALTER TABLE Usr.tbUser ENABLE TRIGGER Usr_tbUser_TriggerUpdate
go

--*******************Register Creation ********************
INSERT INTO App.tbInstall (SQLDataVersion, SQLRelease) 
VALUES (3.23, 1)
go
