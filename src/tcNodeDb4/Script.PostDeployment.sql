/*
Post-Deployment Script Template							
--------------------------------------------------------------------------------------
 This file contains SQL statements that will be appended to the build script.		
 Use SQLCMD syntax to include a file in the post-deployment script.			
 Example:      :r .\myfile.sql								
 Use SQLCMD syntax to reference a variable in the post-deployment script.		
 Example:      :setvar TableName MyTable							
               SELECT * FROM [$(TableName)]					
--------------------------------------------------------------------------------------
*/

ALTER DATABASE [$(DatabaseName)] SET RECURSIVE_TRIGGERS OFF;

DECLARE
    @SQLDataVersion REAL = 4,
    @SQLRelease INT = 1,
    @SQLBuild INT = 22;

IF NOT EXISTS
(
    SELECT 1
    FROM App.tbInstall
    WHERE SQLDataVersion = @SQLDataVersion
      AND SQLRelease = @SQLRelease
      AND SQLBuild = @SQLBuild
)
    INSERT INTO App.tbInstall
    (
        SQLDataVersion,
        SQLRelease,
        SQLBuild
    )
    VALUES
    (
        @SQLDataVersion,
        @SQLRelease,
        @SQLBuild
    );

IF NOT EXISTS (SELECT 1 FROM App.tbDatabaseIdentity WHERE IdentityCode = 1)
    INSERT App.tbDatabaseIdentity (IdentityCode)
    VALUES (1);

IF OBJECT_ID(N'App.tbYearPeriodTaxUk', N'U') IS NOT NULL
   AND Cash.fnGetBizTaxType() = 0
   AND EXISTS (SELECT 1 FROM App.tbOptions WHERE JurisdictionCode = N'UK')
    INSERT INTO App.tbYearPeriodTaxUk
    (
        YearNumber, StartOn,
        CorporationTaxMainRate, CorporationTaxSmallProfitsRate,
        CorporationTaxMarginalReliefFraction,
        CorporationTaxLowerLimit, CorporationTaxUpperLimit
    )
    SELECT period.YearNumber, period.StartOn,
        seed.CorporationTaxMainRate,
        seed.CorporationTaxSmallProfitsRate,
        seed.CorporationTaxMarginalReliefFraction,
        seed.CorporationTaxLowerLimit,
        seed.CorporationTaxUpperLimit
    FROM App.tbYearPeriod period
    CROSS APPLY
    (
        SELECT TOP (1) ledger.*
        FROM App.vwYearPeriodTaxUkSeed ledger
        WHERE period.StartOn >= ledger.EffectiveFrom
        ORDER BY ledger.EffectiveFrom DESC, ledger.SQLBuild DESC
    ) seed
    WHERE NOT EXISTS
    (
        SELECT 1 FROM App.tbYearPeriodTaxUk existing
        WHERE existing.YearNumber = period.YearNumber
          AND existing.StartOn = period.StartOn
    );
