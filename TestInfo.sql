CREATE TABLE [tSQL_test_synapse].[TestInfo](
        test_name NVARCHAR(2048) NOT NULL,
        test_number int NOT NULL,
        object_id int NOT NULL,
        test_rollback_name NVARCHAR(2048) NULL,
        test_rollback_result NVARCHAR(7) NULL,
        result NVARCHAR(7) NULL,
        result_message NVARCHAR(2048) NULL,
        test_start_time DATETIME NULL,
        test_end_time DATETIME NULL
    ) WITH ( DISTRIBUTION = ROUND_ROBIN ); 