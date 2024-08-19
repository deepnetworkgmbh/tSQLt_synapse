CREATE PROCEDURE tSQL_test_synapse.[AssertEqualsString]
    @expected NVARCHAR(MAX),
    @actual NVARCHAR(MAX)
AS
BEGIN
	IF ((@expected <> @actual) OR (@expected IS NULL AND @actual IS NOT NULL) OR (@expected IS NOT NULL AND @actual IS NULL))
    BEGIN
        DECLARE @Msg NVARCHAR(MAX);
        SELECT @Msg = 'tSQL_test_synapse.Failure Expected: <' + ISNULL(@Expected, 'NULL') + 
                    '> but was: <' + ISNULL(@Actual, 'NULL') + '>';
        THROW 50000, @Msg, 100;
    END
END;
GO