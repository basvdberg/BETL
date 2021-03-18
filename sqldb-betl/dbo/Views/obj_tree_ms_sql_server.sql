

/*------------------------------------------------------------------------------------------------
-- BETL, meta data driven ETL generation, licensed under GNU GPL https://github.com/basvdberg/BETL 
--------------------------------------------------------------------------------------------------
-- 2021-03-18 BvdB this query returns the object tree meta data flattened. Pass this to ingest_obj_Tree sp. 

select * from [dbo].[obj_tree_ms_sql_server]

*/
CREATE view [dbo].[obj_tree_ms_sql_server] as 

select null src_obj_id
, isnull(o.object_id,db.obj_id) external_obj_id 
, db.server_type_id -- 10 = ms sql server
, db.server_name 
, db.db_name
, s.name [schema_name]
, o.name as obj_name 
,case o.type when 'U' then 10 when 'V' then 20 end obj_type_id 
, col.ordinal_position
, column_name
, null column_type_id
, case when col.is_nullable='YES' then 1 when col.is_nullable='NO' then 0 else NULL end is_nullable
, data_type 
, character_maximum_length max_len
, case when DATA_TYPE in ('int', 'bigint', 'smallint', 'tinyint', 'bit') then cast(null as int) else numeric_precision end numeric_precision
, case when DATA_TYPE in ('int', 'bigint', 'smallint', 'tinyint', 'bit') then cast(null as int) else numeric_scale end numeric_scale
, case when ic.is_descending_key=0 then 'ASC'when ic.is_descending_key=1 then 'DESC'else null end [primary_key_sorting]
, col.COLUMN_DEFAULT [default_value]
, null _source
from ( 
	select 
		-db_id() obj_id 
		, 10 server_type_id -- 10 = ms sql server 
		, @@SERVERNAME server_name
		, db_name() db_name  
	) db 
	cross join sys.schemas s 
	left join sys.objects o on o.schema_id = s.schema_id
	and o.type in ( 'U','V') 
	and o.object_id not in 
		(
		select major_id 
		from sys.extended_properties  
		where name = N'microsoft_database_tools_support' 
		and minor_id = 0 and class = 1) -- exclude ssms diagram procedures
	left join sys.columns c on c.object_id = o.object_id 
	--  = s.name and col.table_name = o.name
	left join information_schema.columns col on 
		col.table_schema = s.name 
		and col.table_name = o.name 
		and col.COLUMN_NAME=c.name
	left join sys.indexes i on 
		i.object_id = o.object_id 
		and i.is_primary_key = 1
	left join sys.index_columns ic on 
		ic.object_id = o.object_id 
		and ic.column_id = c.column_id
where s.name not in ( 'sys', 'INFORMATION_SCHEMA', 'guest') 
	and s.name not like 'db_%'