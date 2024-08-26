# tSQL_test_synapse

tSQL_test_synapse is a Synapse-specific unit testing framework. It was created by modifying the `tSQLt` framework to be compatible with Synapse. Currently, not all functionalities provided by tSQLt are covered in tSQL_test_synapse, but those that seem necessary may be added in the future. The supported functionalities are:
- AssertEmptyTable
- AssertEqualsInt 
- AssertEqualsString
- AssertEqualsTable
- AssertNotEqualsString
- AssertNotEqualsInt
- AssertObjectDoesNotExist
- AssertObjectExists
- Fail
- AssertLike
- ExpectException
- ExpectNoException
- RunAll

Their guides can be found at https://tsqlt.org/full-user-guide/. Since Synapse does not support a generic data type, tSQL_test_synapse uses AssertEqualsInt and AssertEqualsString instead of AssertEquals from tSQLt, and the same applies to AssertNotEquals.

Tests must be created as stored procedures within a schema named `UnitTests`. Test names must start with `test_`. For tests that include statements modifying the database state, users must write rollbacks to undo the modifications. Rollback names must follow the structure `rollback_<test-name>`. RunAll executes all tests inside UniteTests schema. Samples that demonstrate how to use tSQL_test_synapse can be found inside the **demo** folder. You can start using tSQL_test_synapse by deploying the project file inside the **sql** folder to your Synapse dedicated pool.