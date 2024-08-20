CREATE SCHEMA tSQL_test_synapse
GO

CREATE SCHEMA UnitTests
GO
---
CREATE PROCEDURE UnitTests.[test_not_equals_null]
AS
BEGIN
	DECLARE @a int = NULL;
	DECLARE @b int = 4;
    EXEC tSQL_test_synapse.AssertEqualsInt @a, @b
END;
GO

CREATE PROCEDURE UnitTests.[test_not_equals]
AS
BEGIN
	DECLARE @a int = 1;
	DECLARE @b int = 2;
    EXEC tSQL_test_synapse.AssertEqualsInt @a, @b
END;
GO
---------
CREATE PROCEDURE UnitTests.[test_InfraValidateCrontabMonth_success]
AS
BEGIN
	DECLARE @month NVARCHAR(20) = '9,12,1-4';
    DECLARE @result BIT;
    SET @result = [mgmt_xtinfra].InfraValidateCrontabMonth(@month);
	DECLARE @expected BIT = 1;
    EXEC tSQL_test_synapse.AssertEqualsBit @expected, @result
END;
GO

CREATE PROCEDURE UnitTests.[test_InfraValidateCrontabMonth_invalid_input]
AS
BEGIN
	DECLARE @month NVARCHAR(20) = '11000';
    DECLARE @result BIT;
    SET @result = [mgmt_xtinfra].InfraValidateCrontabMonth(@month);
	DECLARE @expected BIT = 0;
    EXEC tSQL_test_synapse.AssertEqualsBit @expected, @result
END;
GO
---
CREATE PROCEDURE UnitTests.[test_InfraGetWorkspaceSchemaName_success]
AS
BEGIN
	DECLARE @workspace NVARCHAR(10) = 'testws';
    DECLARE @schema NVARCHAR(32) = 'test-schema';
    DECLARE @result NVARCHAR(43);
    SET @result = [mgmt_xtinfra].InfraGetWorkspaceSchemaName(@workspace, @schema);
	DECLARE @expected NVARCHAR(43) = 'testws_test-schema';
    EXEC tSQL_test_synapse.AssertEqualsString @expected, @result
END;
GO
---
CREATE PROCEDURE UnitTests.[test_exception]
AS
BEGIN
    EXEC tSQL_test_synapse.ExpectException 'check', 16, 209,'msg',50100;
	THROW 50100, 'check', 209;
END;
GO

CREATE PROCEDURE UnitTests.[test_exception_fail]
AS
BEGIN
    EXEC tSQL_test_synapse.ExpectException 'check', 16, 209,'msg',50100;
	THROW 50100, 'fail', 209;
END;
GO

CREATE PROCEDURE UnitTests.[test_expect_two_exceptions]
AS
BEGIN
    EXEC tSQL_test_synapse.ExpectException 'check', 16, 209,'msg',50100;
    EXEC tSQL_test_synapse.ExpectException 'check2', 16, 202,'msg',50102;
	THROW 50100, 'fail', 209;
END;
GO
----
CREATE PROCEDURE UnitTests.[test_roll2]
AS
BEGIN
    SELECT * INTO testTable2 FROM tSQL_test_synapse.TestInfo
    SELECT * INTO testTable3 FROM tSQL_test_synapse.TestInfo
END;
GO

CREATE PROCEDURE UnitTests.[rollback_test_roll]
AS
BEGIN
    DROP TABLE testTable
END;
GO

DROP PROCEDURE UnitTests.[rollback_test_roll2]
AS
BEGIN
    DROP TABLE testTable2
    DROP TABLE testTable3
END;
GO

CREATE PROCEDURE UnitTests.[test_result_error]
AS
	THROW 50100, 'error', 209;
GO

CREATE PROCEDURE UnitTests.[test_expect_two_no_exceptions]
AS
BEGIN
    EXEC tSQL_test_synapse.ExpectNoException 'check';
    EXEC tSQL_test_synapse.ExpectNoException 'check2';
END;
GO

CREATE PROCEDURE UnitTests.[test_expect_exception_and_no_exception]
AS
BEGIN
    EXEC tSQL_test_synapse.ExpectException 'check', 16, 209,'msg',50100;
    EXEC tSQL_test_synapse.ExpectNoException 'check2';
END;
GO

CREATE PROCEDURE UnitTests.[test_expect_no_exception]
AS
BEGIN
    EXEC tSQL_test_synapse.ExpectNoException 'no-exception';
END;
GO
----
EXEC [tSQL_test_synapse].RunAll
GO
SELECT * FROM [tSQL_test_synapse].[TestInfo]