CREATE PROCEDURE [tSQL_test_synapse].[AssertEqualsInt]
    @expected int,
    @actual int
AS
BEGIN
    IF (
        (@expected <> @actual)
        OR (@expected IS NULL AND @actual IS NOT NULL)
        OR (@expected IS NOT NULL AND @actual IS NULL)
    )
        BEGIN
            DECLARE @Msg nvarchar(MAX);
            SELECT
                @Msg = 'Expected: <' + ISNULL(CAST(@Expected AS nvarchar(MAX)), 'NULL')
                + '> but was: <' + ISNULL(CAST(@Actual AS nvarchar(MAX)), 'NULL') + '>';
            EXEC [tSQL_test_synapse].[Fail] @Msg;
        END
END;
