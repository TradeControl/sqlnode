CREATE TABLE [App].[tbValueSource]
(
    [ValueSourceCode] NVARCHAR(10) NOT NULL,
    [ValueSourceName] NVARCHAR(50) NOT NULL,
    [RequiresReview] BIT NOT NULL CONSTRAINT [DF_App_tbValueSource_RequiresReview] DEFAULT (1),
    CONSTRAINT [PK_App_tbValueSource] PRIMARY KEY CLUSTERED ([ValueSourceCode]),
    CONSTRAINT [AK_App_tbValueSource_ValueSourceName] UNIQUE ([ValueSourceName])
);
