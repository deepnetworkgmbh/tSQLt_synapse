CREATE PROCEDURE [tSQL_test_synapse].[AssertEqualsBit]
    @expected BIT,
    @actual BIT
AS
BEGIN
	IF ((@expected <> @actual) OR (@expected IS NULL AND @actual IS NOT NULL) OR (@expected IS NOT NULL AND @actual IS NULL))
    BEGIN
        DECLARE @Msg NVARCHAR(MAX);
        SELECT @Msg = 'tSQL_test_synapse.Failure Expected: <' + ISNULL(CAST(@Expected AS NVARCHAR(MAX)), 'NULL') + 
                    '> but was: <' + ISNULL(CAST(@Actual AS NVARCHAR(MAX)), 'NULL') + '>';
        THROW 50000, @Msg, 100;
    END
END;
GO