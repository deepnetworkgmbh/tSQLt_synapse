CREATE PROCEDURE [tSQL_test_synapse].Fail
    @message NVARCHAR(MAX)
AS
BEGIN
    DECLARE @failure_message NVARCHAR(MAX);
    SET @failure_message = 'tSQL_test_synapse.Failure ' + @message;
    THROW 50000, @failure_message, 100;
END;