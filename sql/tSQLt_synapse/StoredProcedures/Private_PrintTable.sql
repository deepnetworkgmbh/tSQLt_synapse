CREATE PROCEDURE [tSQLt_synapse].[Private_PrintTable]
    @SchemaName NVARCHAR(MAX),
    @TableName NVARCHAR(MAX)
AS
BEGIN
    -- Check if the table exists
    IF
        NOT EXISTS (
            SELECT 1
            FROM [INFORMATION_SCHEMA].[TABLES]
            WHERE [TABLE_SCHEMA] = @SchemaName AND [TABLE_NAME] = @TableName
        )
        BEGIN
            PRINT 'Table not found.';
        END
    ELSE
        BEGIN
            IF OBJECT_ID('tempdb..#column_max_len') IS NOT NULL
                DROP TABLE #column_max_len;
            CREATE TABLE #column_max_len ([column_name] NVARCHAR(4000), [max_len] INT, [column_id] INT);

            DECLARE
                @Column VARCHAR(500),
                @MaxLength INT,
                @MaxLengthString VARCHAR(100),
                @ColumnID INT,
                @MaxColumnID INT,
                @Command NVARCHAR(2000);

            SELECT
                @ColumnID = MIN([clm].[column_id]),
                @MaxColumnID = MAX([clm].[column_id])
            FROM [sys].[tables] AS [tbl]
            INNER JOIN [sys].[columns] AS [clm] ON [tbl].[object_id] = [clm].[object_id]
            WHERE
                [tbl].[name] = @TableName
                AND SCHEMA_NAME([tbl].[schema_id]) = @SchemaName;

            WHILE (@ColumnID <= @MaxColumnID)
                BEGIN
                    SET @Column = NULL;

                    SELECT @Column = [clm].[name]
                    FROM [sys].[tables] AS [tbl]
                    INNER JOIN [sys].[columns] AS [clm] ON [tbl].[object_id] = [clm].[object_id]
                    WHERE
                        [tbl].[name] = @TableName
                        AND SCHEMA_NAME([tbl].[schema_id]) = @SchemaName
                        AND [clm].[column_id] = @ColumnID;

                    IF (@Column IS NOT NULL)
                        BEGIN
                            SET @Command = N'
                            INSERT INTO #column_max_len(column_name, max_len, column_id) 
                            SELECT ''' + @Column + '''
                            ,MAX(LEN(CAST([' + @Column + '] as VARCHAR(8000))))
                            ,' + CAST(@ColumnID AS NVARCHAR(MAX)) + '
                            FROM [' + @SchemaName + '].[' + @TableName + '] 
                            WHERE [' + @Column + '] IS NOT NULL';
                            EXEC (@Command);
                        END
                    SET @ColumnID = @ColumnID + 1;
                END

            DECLARE @ColumnList NVARCHAR(MAX) = '';
            SELECT
                @ColumnList = STRING_AGG(
                    QUOTENAME([column_name])
                    + SPACE(GREATEST([max_len], LEN(QUOTENAME([column_name]))) - LEN(QUOTENAME([column_name])) + 1),
                    ' '
                ) WITHIN GROUP (ORDER BY [column_id] ASC)
            FROM #column_max_len;

            -- Print column headers
            PRINT @ColumnList;

            -- Create a list of columns cast to NVARCHAR(MAX)
            DECLARE @ColumnCastList NVARCHAR(MAX) = '';
            SELECT
                @ColumnCastList = STRING_AGG(
                    'ISNULL(CAST(' + QUOTENAME([column_name])
                    + ' AS NVARCHAR(MAX)),'''') + SPACE(GREATEST('
                    + CAST([max_len] AS NVARCHAR(MAX))
                    + ',LEN(QUOTENAME('''
                    + [column_name]
                    + '''))) - ISNULL(LEN('
                    + QUOTENAME([column_name])
                    + '),0))',
                    ','
                ) WITHIN GROUP (ORDER BY [column_id] ASC)
            FROM #column_max_len;

            PRINT REPLICATE('-', LEN(@ColumnList));

            SET @Command = N'
            DECLARE @Output NVARCHAR(MAX);
            SELECT @Output = STRING_AGG(RowText, CHAR(10))
            FROM (
                SELECT CONCAT_WS('', '', ' + @ColumnCastList + ') AS RowText
                FROM [' + @SchemaName + '].[' + @TableName + ']
            ) t;
            PRINT @Output;';

            -- Execute the dynamic SQL
            EXEC [sp_executesql] @Command;
        END
END;
