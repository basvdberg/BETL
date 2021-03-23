




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
	null src_obj_id
	, isnull(o.object_id, db.database_id) external_obj_id 
	,  dbo.server_type() server_type 
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
	, null column_type_id
	, c.is_nullable is_nullable
	, t.name data_type 
	, c.max_length max_len
	--, case when DATA_TYPE in ('int', 'bigint', 'smallint', 'tinyint', 'bit') then cast(null as int) else numeric_precision end numeric_precision
	, convert(tinyint, CASE -- int/decimal/numeric/real/float/money  
	  WHEN c.system_type_id IN (48, 52, 56, 59, 60, 62, 106, 108, 122, 127) THEN c.precision  
	  END)          AS NUMERIC_PRECISION
	, convert(int, CASE -- datetime/smalldatetime  
	  WHEN c.system_type_id IN (40, 41, 42, 43, 58, 61) THEN NULL  
	  ELSE ODBCSCALE(c.system_type_id, c.scale) END) AS NUMERIC_SCALE
	, case when ic.is_descending_key=0 then 'ASC'when ic.is_descending_key=1 then 'DESC'else null end [primary_key_sorting]
	, convert(nvarchar(4000),  
	  OBJECT_DEFINITION(c.default_object_id))   AS [default_value]
	, null _source
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
	left join sys.columns c on c.object_id = o.object_id 
	left join sys.types t on c.user_type_id = t.user_type_id 
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

union all 

select null, suser_sid()
	,  dbo.server_type()
	, @@SERVERNAME server_name 
	, db_name()
	, null
	, suser_sname() 
	, 60 -- user
	, null
	, null
	, null
	, null
	, null
	, null
	, null
	, null
	, null
	, null
	, null