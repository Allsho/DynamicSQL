DECLARE @StagingDatabaseName NVARCHAR(255) = 'YourStagingDBName';
DECLARE @ReportingDatabaseName NVARCHAR(255) = 'YourReportingDBName';

DECLARE @SchemaName NVARCHAR(255) = 'YourSchemaName';
DECLARE @StagingTableName NVARCHAR(255) = 'YourStagingTableName';
DECLARE @ReportingTableName NVARCHAR(255) = 'YourReportingTableName';

DECLARE @SqlQuery NVARCHAR(MAX);

SET @SqlQuery = N'
SELECT
    ''' + @SchemaName + ''' AS SchemaName,
    ''' + @StagingDatabaseName + ''' AS StagingDatabaseName,
    ''' + @StagingTableName + ''' AS StagingTableName,
    c.[COLUMN_NAME] AS ColumnName,
    c.[DATA_TYPE] AS DataType,
    CASE 
        WHEN c.[CHARACTER_MAXIMUM_LENGTH] IS NOT NULL THEN CAST(c.[CHARACTER_MAXIMUM_LENGTH] AS NVARCHAR(255))
        ELSE CAST(c.[NUMERIC_PRECISION] AS NVARCHAR(255))
    END AS DataLength,
    ''' + @ReportingDatabaseName + ''' AS ReportingDatabaseName,
    ''' + @ReportingTableName + ''' AS ReportingTableName,
    cm.[ReportingColumnName] AS ReportingColumnName,
    cm.[ReportingDataType] AS ReportingDataType,
    cm.[ReportingLength] AS ReportingDataLength,
    NULL AS TransformationRules,
    NULL AS IsNullable,
    NULL AS IsRequired
FROM [' + @StagingDatabaseName + '].[' + @SchemaName + '].[' + @StagingTableName + '] AS s
INNER JOIN [' + @ReportingDatabaseName + '].[' + @SchemaName + '].[' + @ReportingTableName + '] AS r
    ON s.[StagingColumnName] = r.[ReportingColumnName]
INNER JOIN [' + @StagingDatabaseName + '].information_schema.columns AS c
    ON c.[TABLE_SCHEMA] = ''' + @SchemaName + '''
    AND c.[TABLE_NAME] = ''' + @StagingTableName + '''
    AND c.[COLUMN_NAME] = s.[StagingColumnName]
INNER JOIN [' + @ReportingDatabaseName + '].information_schema.columns AS rc
    ON rc.[TABLE_SCHEMA] = ''' + @SchemaName + '''
    AND rc.[TABLE_NAME] = ''' + @ReportingTableName + '''
    AND rc.[COLUMN_NAME] = r.[ReportingColumnName]
INNER JOIN [dbo].[ColumnMappings] AS cm
    ON cm.[SchemaName] = ''' + @SchemaName + '''
    AND cm.[StagingDatabase] = ''' + @StagingDatabaseName + '''
    AND cm.[StagingTableName] = ''' + @StagingTableName + '''
    AND cm.[ReportingDatabaseName] = ''' + @ReportingDatabaseName + '''
    AND cm.[ReportingTableName] = ''' + @ReportingTableName + '''
    AND cm.[StagingColumnName] = s.[StagingColumnName]
';

-- Execute the dynamic SQL query
EXEC sp_executesql @SqlQuery;
