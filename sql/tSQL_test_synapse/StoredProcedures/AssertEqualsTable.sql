-- Modified by Deep Network GmbH to make it compatible with Synapse 
CREATE PROCEDURE [tSQL_test_synapse].[AssertEqualsTable]
    @expected NVARCHAR(MAX),
    @actual NVARCHAR(MAX)
AS
BEGIN

    EXEC [tSQL_test_synapse].[AssertObjectExists] @expected;
    EXEC [tSQL_test_synapse].[AssertObjectExists] @actual;

    DECLARE @ResultTable NVARCHAR(MAX);
    DECLARE @ResultTableWithSchema NVARCHAR(MAX);
    DECLARE @ResultColumn NVARCHAR(MAX);
    DECLARE @ColumnList NVARCHAR(MAX);
    DECLARE @UnequalRowsExist INT;
    DECLARE @CombinedMessage NVARCHAR(MAX);
    DECLARE @Cmd NVARCHAR(MAX);


    SELECT @ResultTable = 'result_table';
    SELECT @ResultColumn = '_m_';
    SELECT @ResultTableWithSchema = 'tSQL_test_synapse.' + @ResultTable;

    SET @Cmd = '
     SELECT TOP(0) ''>'' AS ' + @ResultColumn + ', Expected.* INTO ' + @ResultTableWithSchema + ' 
       FROM ' + @expected + ' AS Expected RIGHT JOIN ' + @expected + ' AS X ON 1=0; '
    EXEC [sp_executesql] @Cmd;

    SELECT
        @ColumnList
        = STRING_AGG(CASE WHEN [system_type_id] = TYPE_ID('datetime') THEN ';DATETIME columns are unsupported!;' ELSE QUOTENAME([name]) END, ',')
    FROM [sys].[columns]
    WHERE
        [object_id] = OBJECT_ID(@ResultTableWithSchema)
        AND [name] <> @ResultColumn

    BEGIN TRY
        SET @cmd = 'DECLARE @EatResult INT; SELECT @EatResult = COUNT(1) FROM ' + @ResultTableWithSchema + ' GROUP BY ' + @ColumnList + ';';
        EXEC [sp_executesql] @cmd;
    END TRY
    BEGIN CATCH
        THROW 50003, 'The table contains a datatype that is not supported for tSQLt.AssertEqualsTable', 103;
    END CATCH

    EXEC [tSQL_test_synapse].[Private_CompareTables]
        @Expected = @expected,
        @Actual = @actual,
        @ResultTable = @ResultTableWithSchema,
        @ColumnList = @ColumnList,
        @MatchIndicatorColumnName = @ResultColumn;

    SET @Cmd = 'DROP TABLE ' + @ResultTableWithSchema;
    EXEC [sp_executesql] @Cmd;
END;
