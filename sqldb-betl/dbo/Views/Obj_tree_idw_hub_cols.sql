



--  select * from [dbo].[Obj_tree_idw_hub] 
-- a hub is  a relation between natural business key and surrogate key
CREATE view [dbo].[Obj_tree_idw_hub_cols] as 

with q as ( 

SELECT [src_obj_id]
      ,[external_obj_id]
      ,[server_type_id]
      ,[server_name]
      ,[db_name]
      ,'idw_hub' [schema_name]
      ,[obj_name]
      ,[obj_type_id]
      ,[ordinal_position]
      ,[column_name]
      ,[column_type_id]
      ,case when column_type_id in (  100,105)  then 0 else [is_nullable] end [is_nullable]
      ,[data_type]
      ,[max_len]
      ,[numeric_precision]
      ,[numeric_scale]
      ,case when column_type_id in (  100,105)  then isnull([primary_key_sorting], 'DESC') else null end  [primary_key_sorting] -- only nat_pkey in prim key -> they must be unique... 
      ,[default_value]
      ,[_source]
from [dbo].[Obj_tree_idw_table_cols_basic]
where column_type_id in ( 100, 105, 200) 

union all 
	-- union with static columns for RDW

	select 
	src_obj_id
	, null external_obj_id 
	,	idw_tables.server_type_id
		 , idw_tables.server_name
		, idw_tables.db_name -- target db name
		, 'idw_hub' [schema_name] 
		, idw_tables.obj_name 
		, 10 obj_type_id --table 
    , [ordinal_position] -- renumber
		,replace([column_name], '{{obj_name}}', idw_tables.obj_name) column_name -- only here we can have handle bars expressions...eg {{obj_name}}_sid
		, column_type_id 
		 ,col.[is_nullable]
		  ,[data_type]
		  ,[max_len]
		  ,null [numeric_precision]
		  ,null [numeric_scale]
		  ,null primary_key_sorting
		  ,[default_value]
		  , idw_tables._source
	from [dbo].[Obj_tree_idw_tables]  idw_tables
	cross join static.[Column] col  
	where col.idw_hub = 1 
) 
select
	 src_obj_id
	, external_obj_id 
	, server_type_id
	 , server_name
	, [db_name] -- target db name
	, [schema_name] 
	, obj_name -- h means historic
	, obj_type_id --table 
    , row_number() over (partition by src_obj_id order by ordinal_position) [ordinal_position]
    ,[column_name]
	, column_type_id 
     ,[is_nullable]
      ,[data_type]
      ,[max_len]
      ,[numeric_precision]
      ,[numeric_scale]
      ,primary_key_sorting
      ,[default_value]
	  , _source
from q
-- order by obj_id, ordinal_position
/*
select * 
from dbo.rdw_object_tree 
order by obj_id, ordinal_position

*/