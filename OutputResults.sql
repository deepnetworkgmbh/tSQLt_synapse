ALTER PROCEDURE [tSQL_test_synapse].[OutputResults]
AS
BEGIN
	DECLARE @test_name NVARCHAR(MAX);
    DECLARE @result NVARCHAR(7);
    DECLARE @completed_tests int = 1;
    DECLARE @max_len_test_num int;
    DECLARE @max_len_test_name int;
    DECLARE @max_len_result int;
    DECLARE @total_tests int;
    DECLARE @success_tests int;
    DECLARE @failure_tests int;
    DECLARE @header NVARCHAR(MAX);
    DECLARE @errors NVARCHAR(MAX) = '';
    DECLARE @message NVARCHAR(MAX);

    SELECT @total_tests = COUNT(*), @success_tests = ISNULL(SUM(CASE WHEN Result = 'success' THEN 1 ELSE 0 END), 0), @failure_tests = ISNULL(SUM(CASE WHEN Result = 'failure' THEN 1 ELSE 0 END), 0) FROM [tSQL_test_synapse].[TestInfo];
    SELECT @max_len_test_num = max(len(CAST(test_number AS NVARCHAR(100)))) over () FROM [tSQL_test_synapse].[TestInfo];
    SELECT @max_len_test_name = max(len(test_name)) over () FROM [tSQL_test_synapse].[TestInfo];
    SELECT @max_len_result = max(len(result)) over () FROM [tSQL_test_synapse].[TestInfo];
    IF(len('No') > @max_len_test_num)
        SET @max_len_test_num = len('No')
    IF(len('Test Case Name') > @max_len_test_name)
        SET @max_len_test_name = len('Test Case Name')
     IF(len('Result') > @max_len_result)
        SET @max_len_result = len('Result')

    PRINT '+----------------------+';
    PRINT '|Test Execution Summary|';
    PRINT '+----------------------+';
    PRINT ' ';
    SET @header = '| No' + SPACE(@max_len_test_num - len('No') + 1) + ' | Test Case Name' + SPACE(@max_len_test_name - len('Test Case Name') + 1)+ ' | Result' + SPACE(@max_len_result - len('Result') + 1) + ' |';
    PRINT @header;
    PRINT REPLICATE('-', len(@header));

    WHILE(@completed_tests <= @total_tests)
    BEGIN
        SELECT @test_name = test_name, @result = result, @message = result_message FROM [tSQL_test_synapse].TestInfo WHERE test_number = @completed_tests;
        PRINT '| ' + CAST(@completed_tests AS NVARCHAR(100)) + SPACE(@max_len_test_num - len(CAST(@completed_tests AS NVARCHAR(100))) + 1) + ' | ' + @test_name + SPACE(@max_len_test_name - len(@test_name) + 1) + ' | ' + @result + SPACE(@max_len_result - len(@result) + 1) + ' |';
        SET @completed_tests = @completed_tests + 1;
        SET @errors = @errors + ISNULL('[' + @test_name + '] failed: ' + @message + CHAR(13) + CHAR(10), '')
    END
    PRINT REPLICATE('-', len(@header));
    PRINT @errors;
    PRINT '';
    PRINT 'Test Case Summary: ' + CAST(@total_tests AS NVARCHAR(100)) + ' test case(s) executed, ' + CAST(@success_tests AS NVARCHAR(100)) + ' succeeded, ' + CAST(@failure_tests AS NVARCHAR(100)) + ' failed.';
    PRINT REPLICATE('-', len(@header));
END;
GO