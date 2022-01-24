


/*------------------------------------------------------------------------------------------------
-- BETL, meta data driven ETL generation, licensed under GNU GPL https://github.com/basvdberg/BETL 
--------------------------------------------------------------------------------------------------
-- 2021-03-18 BvdB this query returns the object tree meta data flattened. Pass this to ingest_obj_Tree sp. 

select * from [dbo].[Obj_tree_ms_sql_server]

*/
CREATE view [dbo].[Obj_tree_ms_sql_server] as 

-- begin obj_tree_ms_sql_server .localhost[10]  
-- exec [dbo].[parse_handlebars] 10, 'obj_tree_ms_sql_server'

select 
	isnull(o.object_id, db.database_id) external_obj_id 
	,  case 
		when SERVERPROPERTY('EngineEdition') < 4 then 15 -- on premise
		when SERVERPROPERTY('EngineEdition') >= 5 then 10 -- azure
	  end  server_type_id
	, @@SERVERNAME server_name 
	, db.name db_name
	, s.name [schema_name]
	, o.name as obj_name 
	, case 
			when o.type = 'U' then 10 
			when o.type = 'V' then 20 
			when s.name is not null then 30
			when db.name is not null then 40 
			else 50 -- server
	  end obj_type_id 
	, c.column_id ordinal_position
	, c.name column_name
	, case when ic.is_descending_key is not null then 100 else 300 end column_type_id
	, convert(int, c.is_nullable) is_nullable
	, case when t.is_user_defined=0 then t.name else t2.name end data_type   
	, case when t.name in ('nvarchar', 'nchar') then c.max_length /2 else c.max_length end max_len
	, case when t.name in ('decimal', 'numeric') then c.precision else cast(null as int) end numeric_precision
	, case when t.name in ('decimal', 'numeric') then ODBCSCALE(c.system_type_id, c.scale) else cast(null as int) end numeric_scale
	, case when ic.is_descending_key=0 then 'ASC'when ic.is_descending_key=1 then 'DESC'else null end [primary_key_sorting]
	, convert(nvarchar(4000),  
	  OBJECT_DEFINITION(c.default_object_id))   AS [default_value]
	 , convert(varchar(255), prop__source.value) _source
	 , convert(int, prop_src_obj_id.value) src_obj_id
	 , convert(int, prop_obj_def_id.value) obj_def_id
from
	sys.databases db
	full outer join sys.schemas s on db.database_id = db_id()
	left join sys.objects o on o.schema_id = s.schema_id
	and o.type in ( 'U','V') -- only tables and views
	and o.object_id not in 
		(
		select major_id 
		from sys.extended_properties  
		where name = N'microsoft_database_tools_support' 
		and minor_id = 0 and class = 1) -- exclude ssms diagram objects
	left join sys.extended_properties prop__source on o.object_id    = prop__source.major_id    and prop__source.name = '_source' and prop__source.value <> ''
	left join sys.extended_properties prop_src_obj_id on o.object_id = prop_src_obj_id.major_id and prop_src_obj_id.name = 'src_obj_id' and prop_src_obj_id.value <> ''
	left join sys.extended_properties prop_obj_def_id on o.object_id = prop_obj_def_id.major_id and prop_obj_def_id.name = 'obj_def_id' and prop_obj_def_id.value <> ''
 
	left join sys.columns c on c.object_id = o.object_id 
	left join sys.types t on c.user_type_id = t.user_type_id 
    left join sys.types t2 on t2.system_type_id = t.system_type_id and t2.is_user_defined = 0 and t.is_user_defined = 1 and t2.name <> 'sysname'
	--  = s.name and col.table_name = o.name
	--	left join sys.columns col on 
	--col.table_schema = s.name 
		--and col.table_name = o.name 
		--and col.COLUMN_NAME=c.name
	left join sys.indexes i on 
		i.object_id = o.object_id 
		and i.is_primary_key = 1
	left join sys.index_columns ic on 
		ic.object_id = o.object_id 
		and ic.column_id = c.column_id
where 
	isnull(s.name,'') not in ( 'sys', 'INFORMATION_SCHEMA', 'guest') 
	and isnull(s.name,'') not like 'db[_]%'
	and db.name not in ('master','model','msdb','tempdb')
-- add users

union all 

select 
	 suser_sid() external_obj_id
	,  case 
		when SERVERPROPERTY('EngineEdition') < 4 then 15 -- on premise
		when SERVERPROPERTY('EngineEdition') >= 5 then 10 -- azure
	  end  server_type 
	, @@SERVERNAME server_name 
	, db_name() db_name
	, null [schema_name]
	, suser_sname()  obj_name
	, 60 obj_type_id -- user
	, null ordinal_position
	, null column_name
	, null column_type_id
	, null is_nullable
	, null data_type
	, null
	, null
	, null
	, null
	, null
	, null
	, null
	, null