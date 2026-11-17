/*
    Scenario Project facts selected by the current user's costing set.

    Only quotation Projects participate. Project.vwCostSetProjects expands the
    selected finished good through its Project flow, so rescheduling the parent
    automatically changes the financial-year allocation of its dependent
    production and purchase Projects.
*/
CREATE VIEW Cash.vwTaxBizWhatIfOrderBook
AS
WITH scenario AS
(
    SELECT project.ProjectCode,
           project.CashCode,
           project.ActionOn,
           QuantityRemaining = CONVERT(decimal(18,4), project.Quantity),
           OrderValue = CONVERT(decimal(38,5), CASE category.CashPolarityCode
               WHEN 0 THEN project.TotalCharge * -1 ELSE project.TotalCharge END)
    FROM Project.vwCostSetProjects cost_set
    JOIN Project.tbProject project
      ON project.ProjectCode = cost_set.ProjectCode
    JOIN App.vwTaxBizCashCodes category
      ON category.CashCode = project.CashCode
    WHERE project.ProjectStatusCode = 0
      AND project.ActionOn <=
          (SELECT DATEADD(day, TaxHorizon, CURRENT_TIMESTAMP) FROM App.tbOptions)
)
SELECT period.StartOn,
       period.YearNumber,
       scenario.ProjectCode,
       scenario.CashCode,
       scenario.ActionOn,
       scenario.QuantityRemaining,
       scenario.OrderValue
FROM scenario
CROSS APPLY
(
    SELECT TOP (1) year_period.StartOn, year_period.YearNumber
    FROM App.tbYearPeriod year_period
    WHERE year_period.StartOn <= scenario.ActionOn
    ORDER BY year_period.StartOn DESC
) period;
GO
