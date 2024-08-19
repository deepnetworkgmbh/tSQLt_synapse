CREATE PROCEDURE [tSQL_test_synapse].[ExpectException]
@ExpectedMessage NVARCHAR(MAX),
@ExpectedSeverity INT,
@ExpectedState INT,
@Message NVARCHAR(MAX),
@ExpectedErrorNumber INT
AS
BEGIN
    IF(EXISTS(SELECT 1 FROM #ExpectException WHERE ExpectException = 1))
    BEGIN
        -- we are deleting in order not to confuse test runner to throw wrong 
        DELETE #ExpectException;
        THROW 50001, 'Each test can only contain one call to tSQL_test_synapse.ExpectException.', 101;
    END;

    INSERT INTO #ExpectException(ExpectException, ExpectedMessage, ExpectedSeverity, ExpectedState, ExpectedErrorNumber, FailMessage)
    VALUES(1, @ExpectedMessage, @ExpectedSeverity, @ExpectedState, @ExpectedErrorNumber, @Message);
END;
