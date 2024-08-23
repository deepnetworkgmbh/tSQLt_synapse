CREATE SCHEMA [UnitTests]
GO

-- AssertEqualsInt tests

CREATE PROCEDURE [UnitTests].[test_assert_equals_int_null_fail]
AS
BEGIN
    DECLARE @a int = NULL;
    DECLARE @b int = 4;
    EXEC [tSQL_test_synapse].[AssertEqualsInt] @a, @b;
    --expected result: failure
END;
GO

CREATE PROCEDURE [UnitTests].[test_assert_equals_int_fail]
AS
BEGIN
    DECLARE @a int = 1;
    DECLARE @b int = 2;
    EXEC [tSQL_test_synapse].[AssertEqualsInt] @a, @b;
    --expected result: failure
END;
GO

CREATE PROCEDURE [UnitTests].[test_assert_equals_int_success]
AS
BEGIN
    DECLARE @a int = 5;
    DECLARE @b int = 5;
    EXEC [tSQL_test_synapse].[AssertEqualsInt] @a, @b;
    --expected result: success
END;
GO

CREATE PROCEDURE [UnitTests].[test_assert_equals_bit_fail]
AS
BEGIN
    DECLARE @a bit = 0;
    DECLARE @b bit = 1;
    EXEC [tSQL_test_synapse].[AssertEqualsInt] @a, @b;
    --expected result: failure
END;
GO

CREATE PROCEDURE [UnitTests].[test_assert_equals_bit_success]
AS
BEGIN
    DECLARE @a bit = 0;
    DECLARE @b bit = 0;
    EXEC [tSQL_test_synapse].[AssertEqualsInt] @a, @b;
    --expected result: success
END;
GO

-- AssertEqualsString tests

CREATE PROCEDURE [UnitTests].[test_assert_equals_string_fail]
AS
BEGIN
    DECLARE @a nvarchar(3) = 'abc';
    DECLARE @b nvarchar(3) = 'bcd';
    EXEC [tSQL_test_synapse].[AssertEqualsString] @a, @b;
    --expected result: failure
END;
GO

CREATE PROCEDURE [UnitTests].[test_assert_equals_string_success]
AS
BEGIN
    DECLARE @a nvarchar(3) = 'abc';
    DECLARE @b nvarchar(3) = 'abc';
    EXEC [tSQL_test_synapse].[AssertEqualsString] @a, @b;
    --expected result: success
END;
GO

-- ExpectException tests

CREATE PROCEDURE [UnitTests].[test_result_error]
AS
	THROW 50100, 'error', 209;
    --expected result: error
GO

CREATE PROCEDURE [UnitTests].[test_expect_exception_success]
AS
BEGIN
    EXEC [tSQL_test_synapse].[ExpectException] 'check', 16, 209, 'msg', 50100;
    THROW 50100, 'check', 209;
    --expected result: success
END;
GO

CREATE PROCEDURE [UnitTests].[test_expect_exception_fail]
AS
BEGIN
    EXEC [tSQL_test_synapse].[ExpectException] 'check', 16, 209, 'msg', 50100;
    THROW 50100, 'fail', 209;
    --expected result: failure
END;
GO

CREATE PROCEDURE [UnitTests].[test_expect_two_exceptions]
AS
BEGIN
    EXEC [tSQL_test_synapse].[ExpectException] 'check', 16, 209, 'msg', 50100;
    EXEC [tSQL_test_synapse].[ExpectException] 'check2', 16, 202, 'msg', 50102;
    THROW 50100, 'check', 209;
    --expected result: error
END;
GO

-- ExpectNoException tests

CREATE PROCEDURE [UnitTests].[test_expect_two_no_exceptions]
AS
BEGIN
    EXEC [tSQL_test_synapse].[ExpectNoException] 'check';
    EXEC [tSQL_test_synapse].[ExpectNoException] 'check2';
    --expected result: error
END;
GO

CREATE PROCEDURE [UnitTests].[test_expect_exception_and_expect_no_exception]
AS
BEGIN
    EXEC [tSQL_test_synapse].[ExpectException] 'check', 16, 209, 'msg', 50100;
    EXEC [tSQL_test_synapse].[ExpectNoException] 'check2';
    --expected result: error
END;
GO

CREATE PROCEDURE [UnitTests].[test_expect_no_exception]
AS
BEGIN
    EXEC [tSQL_test_synapse].[ExpectNoException] 'no-exception';
    --expected result: success
END;
GO

-- Tests with rollbacks

CREATE PROCEDURE [UnitTests].[test_with_rollback]
AS
BEGIN
    SELECT * INTO [testTable2] FROM [tSQL_test_synapse].[TestInfo];
    SELECT * INTO [testTable3] FROM [tSQL_test_synapse].[TestInfo];
    -- expected result: success when its rollback SPROC [UnitTests].[rollback_test_with_rollback] is created
END;
GO

CREATE PROCEDURE [UnitTests].[rollback_test_with_rollback]
AS
BEGIN
    DROP TABLE [testTable2];
    DROP TABLE [testTable3];
END;
GO

-- AssertObjectExists tests

CREATE PROCEDURE [UnitTests].[test_object_exists_success]
AS
BEGIN
    EXEC [tSQL_test_synapse].[AssertObjectExists] 'tSQL_test_synapse.TestInfo';
    --expected result: success
END;
GO

CREATE PROCEDURE [UnitTests].[test_object_exists_success_temp]
AS
BEGIN
    EXEC [tSQL_test_synapse].[AssertObjectExists] '#BeforeExecutionObjectSnapshot';
    --expected result: success
END;
GO

CREATE PROCEDURE [UnitTests].[test_object_exists_fail_temp]
AS
BEGIN
    EXEC [tSQL_test_synapse].[AssertObjectExists] '#abc';
    --expected result: failure
END;
GO

CREATE PROCEDURE [UnitTests].[test_object_exists_fail]
AS
BEGIN
    EXEC [tSQL_test_synapse].[AssertObjectExists] '[tSQL_test_synapse].[abc]';
    --expected result: failure
END;
GO

-- AssertObjectDoesNotExist tests

CREATE PROCEDURE [UnitTests].[test_object_does_not_exist_fail]
AS
BEGIN
    EXEC [tSQL_test_synapse].[AssertObjectDoesNotExist] '[tSQL_test_synapse].[TestInfo]';
    --expected result: failure
END;
GO

CREATE PROCEDURE [UnitTests].[test_object_does_not_exist_success]
AS
BEGIN
    EXEC [tSQL_test_synapse].[AssertObjectDoesNotExist] '[tSQL_test_synapse].[abc]';
    --expected result: success
END;
GO

-- AssertNotEqualsInt tests

CREATE PROCEDURE [UnitTests].[test_assert_not_equals_int_success]
AS
BEGIN
    DECLARE @a int = NULL;
    DECLARE @b int = 4;
    EXEC [tSQL_test_synapse].[AssertNotEqualsInt] @a, @b;
    --expected result: success
END;
GO

CREATE PROCEDURE [UnitTests].[test_assert_not_equals_int_fail]
AS
BEGIN
    DECLARE @a int = 1;
    DECLARE @b int = 1;
    EXEC [tSQL_test_synapse].[AssertNotEqualsInt] @a, @b;
    --expected result: failure
END;
GO

-- AssertNotEqualsString tests

CREATE PROCEDURE [UnitTests].[test_assert_not_equals_string_success]
AS
BEGIN
    DECLARE @a nvarchar(3) = 'abc';
    DECLARE @b nvarchar(3) = 'bcd';
    EXEC [tSQL_test_synapse].[AssertNotEqualsString] @a, @b;
    --expected result: success
END;
GO

CREATE PROCEDURE [UnitTests].[test_assert_not_equals_string_fail]
AS
BEGIN
    DECLARE @a nvarchar(3) = 'abc';
    DECLARE @b nvarchar(3) = 'abc';
    EXEC [tSQL_test_synapse].[AssertNotEqualsString] @a, @b;
    --expected result: failure
END;
GO

-- AssertLike tests

CREATE PROCEDURE [UnitTests].[test_assert_like_success]
AS
BEGIN
    DECLARE @a nvarchar(5) = '%bcd%';
    DECLARE @b nvarchar(5) = 'abcde';
    EXEC [tSQL_test_synapse].[AssertLike] @a, @b;
    --expected result: success
END;
GO

CREATE PROCEDURE [UnitTests].[test_assert_like_fail]
AS
BEGIN
    DECLARE @a nvarchar(3) = 'abc';
    DECLARE @b nvarchar(3) = 'bcd';
    EXEC [tSQL_test_synapse].[AssertLike] @a, @b;
    --expected result: failure
END;
GO

-- AssertEmptyTable tests

CREATE PROCEDURE [UnitTests].[test_assert_empty_table_success]
AS
BEGIN
    CREATE TABLE [tSQL_test_synapse].[empty] (
    [c2] INT NOT NULL,
    [c3] INT NOT NULL) WITH (DISTRIBUTION = REPLICATE);

    EXEC [tSQL_test_synapse].[AssertEmptyTable] 'tSQL_test_synapse.empty';

    DROP TABLE [tSQL_test_synapse].[empty];
    --expected result: success
END;
GO

CREATE PROCEDURE [UnitTests].[test_assert_empty_table_fail]
AS
BEGIN
    EXEC [tSQL_test_synapse].[AssertEmptyTable] 'tSQL_test_synapse.TestInfo';
    --expected result: failure
END;
GO

-- AssertEqualsTable tests

CREATE PROCEDURE [UnitTests].[test_assert_equals_table_success]
AS
BEGIN
    CREATE TABLE [tSQL_test_synapse].[t1] (
    [c2] INT NOT NULL,
    [c3] INT NOT NULL) WITH (DISTRIBUTION = REPLICATE);
    INSERT INTO [tSQL_test_synapse].[t1] VALUES (3,2);


    CREATE TABLE [tSQL_test_synapse].[t2] (
    [c2] INT NOT NULL,
    [c3] INT NOT NULL) WITH (DISTRIBUTION = REPLICATE);
    INSERT INTO [tSQL_test_synapse].[t2] VALUES (3,2);

    EXEC [tSQL_test_synapse].[AssertEqualsTable] 'tSQL_test_synapse.t1', 'tSQL_test_synapse.t2';

    DROP TABLE [tSQL_test_synapse].[t1];
    DROP TABLE [tSQL_test_synapse].[t2];
    --expected result: success
END;
GO

CREATE PROCEDURE [UnitTests].[test_assert_equals_table_fail]
AS
BEGIN
    CREATE TABLE [tSQL_test_synapse].[t1] (
    [c2] INT NOT NULL,
    [c3] INT NOT NULL) WITH (DISTRIBUTION = REPLICATE);
    INSERT INTO [tSQL_test_synapse].[t1] VALUES (5,6);


    CREATE TABLE [tSQL_test_synapse].[t2] (
    [c2] INT NOT NULL,
    [c3] INT NOT NULL) WITH (DISTRIBUTION = REPLICATE);
    INSERT INTO [tSQL_test_synapse].[t2] VALUES (3,2);

    EXEC [tSQL_test_synapse].[AssertEqualsTable] 'tSQL_test_synapse.t1', 'tSQL_test_synapse.t2';
    --expected result: failure
END;
GO

CREATE PROCEDURE [UnitTests].[rollback_test_assert_equals_table_fail]
AS
BEGIN
    DROP TABLE [tSQL_test_synapse].[t1];
    DROP TABLE [tSQL_test_synapse].[t2];
END;
GO

-- Run the created tests
EXEC [tSQL_test_synapse].[RunAll];
GO
-- Check results from table
SELECT * FROM [tSQL_test_synapse].[TestInfo];
