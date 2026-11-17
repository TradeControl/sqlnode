/*
    Corporation Tax jurisdiction-isolation regression.

    Proves that common statement consumers retain jurisdiction-neutral
    contracts and that each business-tax calculation set crosses exactly one
    explicit provider-selection boundary. Arithmetic and unsupported-profile
    fail-closed behaviour are exercised by the marginal-relief and statement
    reconciliation fixtures respectively.
*/
SET NOCOUNT ON;

DECLARE @CommonContracts TABLE
(
    ObjectName sysname NOT NULL,
    ColumnName sysname NOT NULL,
    PRIMARY KEY (ObjectName, ColumnName)
);

INSERT @CommonContracts (ObjectName, ColumnName)
VALUES
    (N'Cash.vwTaxBizStatement', N'StartOn'),
    (N'Cash.vwTaxBizStatement', N'TaxDue'),
    (N'Cash.vwTaxBizStatement', N'TaxPaid'),
    (N'Cash.vwTaxBizStatement', N'Balance'),
    (N'Cash.vwTaxBizAccruals', N'StartOn'),
    (N'Cash.vwTaxBizAccruals', N'ProjectCode'),
    (N'Cash.vwTaxBizAccruals', N'QuantityRemaining'),
    (N'Cash.vwTaxBizAccruals', N'OrderValue'),
    (N'Cash.vwTaxBizAccruals', N'TaxDue');

IF EXISTS
(
    SELECT ObjectName, ColumnName
    FROM @CommonContracts
    EXCEPT
    SELECT OBJECT_SCHEMA_NAME(column_definition.object_id) + N'.'
            + OBJECT_NAME(column_definition.object_id),
           column_definition.name
    FROM sys.columns column_definition
    WHERE column_definition.object_id IN
    (
        OBJECT_ID(N'Cash.vwTaxBizStatement'),
        OBJECT_ID(N'Cash.vwTaxBizAccruals')
    )
)
OR EXISTS
(
    SELECT OBJECT_SCHEMA_NAME(column_definition.object_id) + N'.'
            + OBJECT_NAME(column_definition.object_id),
           column_definition.name
    FROM sys.columns column_definition
    WHERE column_definition.object_id IN
    (
        OBJECT_ID(N'Cash.vwTaxBizStatement'),
        OBJECT_ID(N'Cash.vwTaxBizAccruals')
    )
    EXCEPT
    SELECT ObjectName, ColumnName
    FROM @CommonContracts
)
    THROW 51450, 'A common business-tax statement contract has changed.', 1;

IF EXISTS
(
    SELECT 1
    FROM sys.columns column_definition
    WHERE column_definition.object_id IN
    (
        OBJECT_ID(N'Cash.vwTaxBizStatement'),
        OBJECT_ID(N'Cash.vwTaxBizAccruals'),
        OBJECT_ID(N'Cash.vwStatement'),
        OBJECT_ID(N'Cash.vwStatementWhatIf')
    )
      AND column_definition.name IN
      (
          N'TaxableTotalProfits', N'RelevantDistributions', N'AugmentedProfits',
          N'MainRate', N'SmallProfitsRate', N'MarginalReliefFraction',
          N'AdjustedLowerLimit', N'AdjustedUpperLimit', N'MarginalRelief'
      )
)
    THROW 51451, 'A UK-specific Corporation Tax measure escaped into a common statement contract.', 1;

DECLARE @ProviderBoundaries TABLE
(
    FunctionName sysname NOT NULL,
    ExpectedConsumer sysname NOT NULL,
    PRIMARY KEY (FunctionName)
);

INSERT @ProviderBoundaries (FunctionName, ExpectedConsumer)
VALUES
    (N'Cash.fnTaxBizComputationByYearSelected', N'Cash.vwTaxBizComputationByYear'),
    (N'Cash.fnTaxBizAccrualsSelected', N'Cash.vwTaxBizAccruals'),
    (N'Cash.fnTaxBizWhatIfAccrualsSelected', N'Cash.vwStatementWhatIf');

IF EXISTS
(
    SELECT 1
    FROM @ProviderBoundaries boundary
    CROSS APPLY
    (
        SELECT DefinitionText = OBJECT_DEFINITION(OBJECT_ID(boundary.FunctionName))
    ) definition
    WHERE definition.DefinitionText IS NULL
       OR
       (
           LEN(definition.DefinitionText)
           - LEN(REPLACE(definition.DefinitionText, N'FROM App.tbOptions', N''))
       ) / LEN(N'FROM App.tbOptions') <> 1
)
    THROW 51452, 'A selected business-tax provider does not resolve the node jurisdiction exactly once.', 1;

IF EXISTS
(
    SELECT 1
    FROM @ProviderBoundaries boundary
    CROSS APPLY
    (
        SELECT DefinitionText = OBJECT_DEFINITION(OBJECT_ID(boundary.ExpectedConsumer))
    ) definition
    WHERE definition.DefinitionText IS NULL
       OR definition.DefinitionText NOT LIKE N'%' + boundary.FunctionName + N'%'
)
    THROW 51453, 'A common statement consumer bypasses its selected business-tax provider.', 1;

IF EXISTS
(
    SELECT 1
    FROM sys.sql_expression_dependencies dependency
    WHERE dependency.referencing_id IN
    (
        OBJECT_ID(N'Cash.vwTaxBizComputationByYear'),
        OBJECT_ID(N'Cash.vwTaxBizAccruals'),
        OBJECT_ID(N'Cash.vwTaxBizStatement')
    )
      AND OBJECT_SCHEMA_NAME(dependency.referenced_id) = N'Cash'
      AND OBJECT_NAME(dependency.referenced_id) LIKE N'%TaxCorp%'
)
    THROW 51454, 'A common business-tax view directly depends on a UK Corporation Tax provider.', 1;

PRINT 'Corporation Tax jurisdiction-isolation regression passed.';
