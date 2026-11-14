CREATE TABLE [App].[tbYearPeriodTaxUk]
(
    [YearNumber] SMALLINT NOT NULL,
    [StartOn] DATETIME NOT NULL,
    [CorporationTaxMainRate] DECIMAL(9, 6) NOT NULL,
    [CorporationTaxSmallProfitsRate] DECIMAL(9, 6) NOT NULL,
    [CorporationTaxMarginalReliefFraction] DECIMAL(9, 6) NOT NULL,
    [CorporationTaxLowerLimit] DECIMAL(28, 5) NOT NULL,
    [CorporationTaxUpperLimit] DECIMAL(28, 5) NOT NULL,
    [InsertedBy] NVARCHAR(50) NOT NULL CONSTRAINT [DF_App_tbYearPeriodTaxUk_InsertedBy] DEFAULT (Usr.fnUserName()),
    [InsertedOn] DATETIME NOT NULL CONSTRAINT [DF_App_tbYearPeriodTaxUk_InsertedOn] DEFAULT (getdate()),
    [UpdatedBy] NVARCHAR(50) NOT NULL CONSTRAINT [DF_App_tbYearPeriodTaxUk_UpdatedBy] DEFAULT (Usr.fnUserName()),
    [UpdatedOn] DATETIME NOT NULL CONSTRAINT [DF_App_tbYearPeriodTaxUk_UpdatedOn] DEFAULT (getdate()),
    [RowVer] ROWVERSION NOT NULL,
    CONSTRAINT [PK_App_tbYearPeriodTaxUk] PRIMARY KEY CLUSTERED ([YearNumber], [StartOn]),
    CONSTRAINT [FK_App_tbYearPeriodTaxUk_App_tbYearPeriod]
        FOREIGN KEY ([YearNumber], [StartOn])
        REFERENCES [App].[tbYearPeriod] ([YearNumber], [StartOn])
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT [CK_App_tbYearPeriodTaxUk_Rates] CHECK
    (
        CorporationTaxSmallProfitsRate >= 0
        AND CorporationTaxSmallProfitsRate <= CorporationTaxMainRate
        AND CorporationTaxMainRate <= 1
        AND CorporationTaxMarginalReliefFraction >= 0
        AND CorporationTaxMarginalReliefFraction <= 1
    ),
    CONSTRAINT [CK_App_tbYearPeriodTaxUk_Limits] CHECK
    (
        CorporationTaxLowerLimit > 0
        AND CorporationTaxUpperLimit > CorporationTaxLowerLimit
    )
);
GO

CREATE TRIGGER [App].[App_tbYearPeriodTaxUk_TriggerUpdate]
ON [App].[tbYearPeriodTaxUk]
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT UPDATE(UpdatedBy) AND NOT UPDATE(UpdatedOn)
        UPDATE target
        SET UpdatedBy = Usr.fnUserName(),
            UpdatedOn = CURRENT_TIMESTAMP
        FROM App.tbYearPeriodTaxUk target
        JOIN inserted source
          ON source.YearNumber = target.YearNumber
         AND source.StartOn = target.StartOn;
END;
GO
