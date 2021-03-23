/*

	1. Invoke the following procedure to generate your MERGE statements:
		Example: EXEC sp_generate_merge @schema = 'dbo', @table_name ='Table'

	2. Paste it to a new file in the betl folder.

	3. Include it in the list below. Order of the tables in the list depends on your table relationships.
		Begin with the tables at the end of your relationship chain.
*/

:r .\betl\static.Column.sql
:r .\betl\static.Column_type.sql
:r .\betl\static.Dep_type.sql
:r .\betl\static.Log_level.sql
:r .\betl\static.Log_type.sql
:r .\betl\static.Obj_type.sql
:r .\betl\static.Property.sql
:r .\betl\static.Server_type.sql
:r .\betl\static.Status.sql
:r .\betl\static.Template.sql
:r .\betl\static.Version.sql
:r .\betl\dbo.Error.sql
:r .\betl\dbo.Batch.sql
:r .\betl\dbo.Obj.sql
:r .\betl\dbo.Transfer.sql

