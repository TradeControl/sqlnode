/*
Build-controlled UK Corporation Tax statutory parameter seed ledger.

These rows are provisioning evidence, not a calculation. Each supported UK
financial year must be added deliberately from an authoritative source. Period
generation may inherit an existing configured row or consume an applicable
entry from this ledger; it must not invent fallback rates.

Authoritative rate table:
https://www.gov.uk/government/publications/rates-and-allowances-corporation-tax/rates-and-allowances-corporation-tax
*/
CREATE VIEW App.vwYearPeriodTaxUkSeed
AS
    SELECT
        seed.FinancialYear,
        seed.EffectiveFrom,
        seed.EffectiveTo,
        seed.CorporationTaxMainRate,
        seed.CorporationTaxSmallProfitsRate,
        seed.CorporationTaxMarginalReliefFraction,
        seed.CorporationTaxLowerLimit,
        seed.CorporationTaxUpperLimit,
        seed.IsProvisional,
        SQLDataVersion = CONVERT(real, 4),
        SQLRelease = CONVERT(int, 1),
        SQLBuild = CONVERT(int, 22),
        SourceReference = CONVERT(nvarchar(256),
            N'HMRC Corporation Tax rates and allowances; effective financial year shown')
    FROM
    (
        VALUES
            (CONVERT(smallint, 2023), CONVERT(date, '20230401'), CONVERT(date, '20240331'),
             CONVERT(decimal(9,6), 0.25), CONVERT(decimal(9,6), 0.19), CONVERT(decimal(9,6), 0.015),
             CONVERT(decimal(28,5), 50000), CONVERT(decimal(28,5), 250000), CONVERT(bit, 0)),
            (CONVERT(smallint, 2024), CONVERT(date, '20240401'), CONVERT(date, '20250331'),
             CONVERT(decimal(9,6), 0.25), CONVERT(decimal(9,6), 0.19), CONVERT(decimal(9,6), 0.015),
             CONVERT(decimal(28,5), 50000), CONVERT(decimal(28,5), 250000), CONVERT(bit, 0)),
            (CONVERT(smallint, 2025), CONVERT(date, '20250401'), CONVERT(date, '20260331'),
             CONVERT(decimal(9,6), 0.25), CONVERT(decimal(9,6), 0.19), CONVERT(decimal(9,6), 0.015),
             CONVERT(decimal(28,5), 50000), CONVERT(decimal(28,5), 250000), CONVERT(bit, 0)),
            (CONVERT(smallint, 2026), CONVERT(date, '20260401'), CONVERT(date, '20270331'),
             CONVERT(decimal(9,6), 0.25), CONVERT(decimal(9,6), 0.19), CONVERT(decimal(9,6), 0.015),
             CONVERT(decimal(28,5), 50000), CONVERT(decimal(28,5), 250000), CONVERT(bit, 0)),
            (CONVERT(smallint, 2027), CONVERT(date, '20270401'), CONVERT(date, '20280331'),
             CONVERT(decimal(9,6), 0.25), CONVERT(decimal(9,6), 0.19), CONVERT(decimal(9,6), 0.015),
             CONVERT(decimal(28,5), 50000), CONVERT(decimal(28,5), 250000), CONVERT(bit, 1)),
            (CONVERT(smallint, 2028), CONVERT(date, '20280401'), CONVERT(date, '20290331'),
             CONVERT(decimal(9,6), 0.25), CONVERT(decimal(9,6), 0.19), CONVERT(decimal(9,6), 0.015),
             CONVERT(decimal(28,5), 50000), CONVERT(decimal(28,5), 250000), CONVERT(bit, 1))
    ) seed
    (
        FinancialYear, EffectiveFrom, EffectiveTo,
        CorporationTaxMainRate, CorporationTaxSmallProfitsRate,
        CorporationTaxMarginalReliefFraction,
        CorporationTaxLowerLimit, CorporationTaxUpperLimit, IsProvisional
    );
GO
