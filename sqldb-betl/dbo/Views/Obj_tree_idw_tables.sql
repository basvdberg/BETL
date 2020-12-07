


CREATE view [dbo].[Obj_tree_idw_tables] as 

	select 
	so.obj_id src_obj_id
	, null external_obj_id 
	, so.db_name
	, 'idw' schema_name 
	,  so.obj_name obj_name
--	, so.schema_obj_name table_name
	, so.[server_name] server_name  -- _target because this object tree is not made persistent. It represents how RDW should look ( but not how it currently looks). 
	, so.server_type_id
	, so._source
	from dbo.obj_ext so
	where so.obj_type in ( 'view')
	and so.db_name = 'sqldb_ddppoc'
	and so.schema_name = 'idw_imp'
	and so.server_name = @@servername