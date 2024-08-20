ALTER PROCEDURE [tSQL_test_synapse].[RunAll]
AS
BEGIN
    TRUNCATE TABLE [tSQL_test_synapse].[TestInfo];

    INSERT INTO [tSQL_test_synapse].[TestInfo] (test_name, test_number, object_id, test_rollback_name)
    SELECT 
    s2.[name],
    ROW_NUMBER() OVER(ORDER BY s2.object_id),
    s2.[object_id],
    (SELECT s1.name FROM sys.procedures AS s1
    WHERE s1.name LIKE N'rollback[_]%'
    AND SCHEMA_NAME(schema_id) = N'UnitTests'
    AND SUBSTRING(s1.name, len('rollback_') + 1, len(s1.name) - len('rollback_')) = s2.name)
    FROM 
        sys.procedures AS s2
    WHERE name LIKE N'test[_]%'
    AND SCHEMA_NAME(schema_id) = N'UnitTests'
    
    DECLARE @completed_tests int = 1;
    DECLARE @total_tests int;
    DECLARE @test_name NVARCHAR(MAX);
    DECLARE @rollback_name NVARCHAR(MAX);
    DECLARE @execute_stmt NVARCHAR(MAX);
    DECLARE @test_start_time DATETIME;
    DECLARE @test_end_time DATETIME;
    DECLARE @result NVARCHAR(7);
    DECLARE @rollback_result NVARCHAR(7);
    DECLARE @message NVARCHAR(MAX) = NULL;
    DECLARE @tmp_message NVARCHAR(MAX);

    SELECT @total_tests = COUNT(*) FROM [tSQL_test_synapse].[TestInfo];
    
    IF(OBJECT_ID('tempdb..#ExpectException') IS NOT NULL)
        DROP TABLE #ExpectException;
    CREATE TABLE #ExpectException(ExpectException INT,ExpectedMessage NVARCHAR(2048), ExpectedSeverity INT, ExpectedState INT, ExpectedErrorNumber INT, FailMessage NVARCHAR(2048)); 
    
       
    WHILE(@completed_tests <= @total_tests)
    BEGIN
        SELECT @test_name = test_name, @rollback_name = test_rollback_name FROM [tSQL_test_synapse].[TestInfo] WHERE test_number = @completed_tests;
        SET @execute_stmt = N'EXEC UnitTests.[' + @test_name + ']';
        TRUNCATE TABLE #ExpectException;
        SET @message = NULL;
        IF(OBJECT_ID('tempdb..#BeforeExecutionObjectSnapshot') IS NOT NULL)
            DROP TABLE #BeforeExecutionObjectSnapshot;
        SELECT object_id ObjectId, SCHEMA_NAME(schema_id) SchemaName, name ObjectName, type_desc ObjectType INTO #BeforeExecutionObjectSnapshot FROM sys.objects;
        SET @test_start_time = SYSDATETIME();
        BEGIN TRY
            EXEC sp_executesql @execute_stmt;
            IF(EXISTS(SELECT 1 FROM #ExpectException WHERE ExpectException = 1))
            BEGIN
                SET @tmp_message = COALESCE((SELECT FailMessage FROM #ExpectException)+' ','')+'Expected an error to be raised.';
                EXEC tSQL_test_synapse.Fail @tmp_message;
            END
            SET @test_end_time = SYSDATETIME();
            SET @result = 'success'
        END TRY
        BEGIN CATCH
            SET @test_end_time = SYSDATETIME();
            IF(ERROR_MESSAGE() LIKE '%tSQL_test_synapse.Failure%') --assertion fail
            BEGIN
                SET @result = 'failure';
                SET @message = ERROR_MESSAGE();
            END
            ELSE
            BEGIN
                IF(EXISTS(SELECT 1 FROM #ExpectException))
                BEGIN
                    DECLARE @ExpectException INT;
                    DECLARE @ExpectedMessage NVARCHAR(MAX);
                    DECLARE @ExpectedSeverity INT;
                    DECLARE @ExpectedErrorNumber INT;
                    DECLARE @ExpectedState INT;
                    DECLARE @FailMessage NVARCHAR(MAX);
                    SELECT @ExpectException = ExpectException,
                            @ExpectedMessage = ExpectedMessage, 
                            @ExpectedSeverity = ExpectedSeverity,
                            @ExpectedErrorNumber = ExpectedErrorNumber,
                            @ExpectedState = ExpectedState,
                            @FailMessage = FailMessage
                        FROM #ExpectException;

                    IF(@ExpectException = 1)
                    BEGIN
                        SET @result = 'success';
                        IF(ERROR_MESSAGE() <> @ExpectedMessage)
                        BEGIN
                            SET @message = 'Expected Message: <'+@ExpectedMessage+'>'+
                                        ' Actual Message  : <'+ERROR_MESSAGE()+'>';
                            SET @result = 'failure';
                        END
                        IF(ERROR_NUMBER() <> @ExpectedErrorNumber)
                        BEGIN
                            SET @message = 'Expected Error Number: '+CAST(@ExpectedErrorNumber AS NVARCHAR(MAX))+
                                        ' Actual Error Number  : '+CAST(ERROR_NUMBER() AS NVARCHAR(MAX));
                            SET @result = 'failure';
                        END
                        IF(ERROR_SEVERITY() <> @ExpectedSeverity)
                        BEGIN
                            SET @message = 'Expected Severity: '+CAST(@ExpectedSeverity AS NVARCHAR(MAX))+
                                        ' Actual Severity  : '+CAST(ERROR_SEVERITY() AS NVARCHAR(MAX));
                            SET @result = 'failure';
                        END
                        IF(ERROR_STATE() <> @ExpectedState)
                        BEGIN
                            SET @message = 'Expected State: '+CAST(@ExpectedState AS NVARCHAR(MAX))+
                                        ' Actual State  : '+CAST(ERROR_STATE() AS NVARCHAR(MAX));
                            SET @result = 'failure';
                        END
                    END 
                    ELSE
                    BEGIN
                        SET @result = 'failure';
                        SET @message =  COALESCE(@FailMessage+' ','') + 'Expected no error to be raised. Instead this error was encountered: ' + ERROR_MESSAGE()
                    END
                END
                ELSE
                BEGIN
                    SET @result = 'error';
                    SET @message = ERROR_MESSAGE();
                END;
            END
        END CATCH
        IF(@rollback_name IS NOT NULL)
        BEGIN TRY
            SET @execute_stmt = N'EXEC UnitTests.[' + @rollback_name + ']';
            EXEC sp_executesql @execute_stmt;
            SET @rollback_result = 'success'
        END TRY
        BEGIN CATCH
            PRINT 'Rollback ' + @rollback_name + ' terminated with exceptions.'
            SET @rollback_result = 'failure'
        END CATCH
        ELSE
            SET @rollback_result = NULL;
        UPDATE [tSQL_test_synapse].[TestInfo] SET result = @result, test_start_time = @test_start_time, test_end_time = @test_end_time, result_message = @message, test_rollback_result = @rollback_result WHERE test_number = @completed_tests;
        SET @completed_tests = @completed_tests + 1;
        IF(OBJECT_ID('tempdb..#AfterExecutionObjectSnapshot') IS NOT NULL)
            DROP TABLE #AfterExecutionObjectSnapshot;
        SELECT object_id ObjectId, SCHEMA_NAME(schema_id) SchemaName, name ObjectName, type_desc ObjectType INTO #AfterExecutionObjectSnapshot FROM sys.objects;
        EXEC [tSQL_test_synapse].AssertNoSideEffects '#BeforeExecutionObjectSnapshot', '#AfterExecutionObjectSnapshot', @test_name;
    END

    EXEC tSQL_test_synapse.OutputResults;
END;
