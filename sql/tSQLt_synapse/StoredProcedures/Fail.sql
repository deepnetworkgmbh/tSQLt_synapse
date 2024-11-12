-- Modified by Deep Network GmbH to make it compatible with Synapse 
CREATE PROCEDURE [tSQLt_synapse].[Fail]
    @message NVARCHAR(MAX)
AS
BEGIN
    DECLARE @failure_message NVARCHAR(MAX);
    SET @failure_message = 'tSQLt_synapse.Failure ' + @message;
    THROW 50000, @failure_message, 100;
END;
