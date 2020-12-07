










-- select * from [dbo].[Obj_tree_Staging]

CREATE view [dbo].[Obj_tree_staging_tables] as 

with src_obj_tree as (  
	select 
	obj.obj_id src_obj_id
	, obj.server_type_id
	, obj.server_name
	, obj.db_name
	, obj.schema_name
	, obj.obj_name
	, schema_obj_name table_name
	, alias.inherited_value _source
	--, * 
	from dbo.obj_ext obj 
	inner join dbo.prop_ext pe on obj.obj_id = pe.obj_id 
	left join dbo.prop_ext alias on obj.obj_id = alias.obj_id  and alias.property = 'source'
	where pe.property = 'include_staging'
	and pe.inherited_value = 1 
	and obj.obj_type in ( 'table', 'view')

	--and db_name = 'sqldb_adventureWorks'
	
) , joined as ( 
	-- join with columns except meta data columns 999
	SELECT 
		st.src_obj_id, 
		st.server_type_id
		 , st.server_name
		, st.db_name -- target db name
		, st.[schema_name] 
		, st.obj_name 
		, 10 obj_type_id --table 
		,[ordinal_position]
		,[column_name]
		, column_type_id 
		 ,[is_nullable]
		  ,[data_type] 
		  ,[max_len] 
		  ,[numeric_precision]
		  ,[numeric_scale]
		  ,case when column_type_id = 100 and primary_key_sorting is null then 'DESC' else primary_key_sorting end primary_key_sorting
		  ,[default_value]
		  , _source
	from src_obj_tree st
	left  join dbo.Col_ext col on col.obj_id =  st.src_obj_id 
	where col.Column_type_id<> 999 -- skip meta data fields from staging... 

union all 
	-- union with static columns for RDW
	select 
	src_obj_id, 
		st.server_type_id
		 , st.server_name
		, st.db_name -- target db name
		, st.[schema_name] 
		, st.obj_name 
		, 10 obj_type_id --table 
		,col.column_id* 1000 ordinal_position
		,[column_name]
		, column_type_id 
		 ,col.[is_nullable]
		  ,[data_type]
		  ,[max_len]
		  ,null [numeric_precision]
		  ,null [numeric_scale]
		  ,primary_key_sorting
		  ,[default_value]
		  , _source
	from src_obj_tree st
	cross join static.[Column] col  
	where col.staging = 1 
)
select 
	src_obj_id
	, null external_obj_id 
	, 10 server_type_id
	, @@servername server_name
	, 'sqldb_ddppoc' [db_name] -- target db name
	, 'staging' [schema_name] 
	, isnull(_source+'_','')  +  case when schema_name <> 'dbo' then schema_name + '_'+ obj_name else obj_name end obj_name
	, obj_type_id --table 
    , row_number() over (partition by src_obj_id order by ordinal_position) [ordinal_position]
    ,[column_name]
	, column_type_id 
     ,[is_nullable]
      ,[data_type]
      ,[max_len]
      ,[numeric_precision]
      ,[numeric_scale]
      , null primary_key_sorting -- do not create prim keys in staging
      ,[default_value]
	  , _source
from joined 
-- order by obj_id, ordinal_position
/*
select * 
from dbo.rdw_object_tree 
order by obj_id, ordinal_position

*/