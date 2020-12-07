/****** Object:  View [dbo].[Obj_tree_idw_table_cols]    Script Date: 12/7/2020 10:28:54 AM ******/


--  select * from [dbo].[Obj_tree_idw_table_cols] 
CREATE view [dbo].[Obj_tree_idw_table_cols]  as

with q as ( 
	select 
		 [src_obj_id]
		,[external_obj_id]
		,[server_type_id]
		,[server_name]
		,[db_name]
		,[schema_name]
		,[obj_name]
		,[obj_type_id]
		,[ordinal_position]
		,[column_name]
		,[column_type_id]
		,[is_nullable]
		,[data_type]
		,[max_len]
		,[numeric_precision]
		,[numeric_scale]
		,[primary_key_sorting]
		,[default_value]
		,[_source]
	from dbo.Obj_tree_idw_table_cols_basic
union all 
	-- union with t.tic columns for RDW
	select 
		 t.src_obj_id
		 , t.external_obj_id
		 ,	t.server_type_id
		 , t.server_name
		, t.db_name -- target db name
		, t.[schema_name] 
		, t.obj_name 
		, 10 obj_type_id --table 
		,-500+ col.ordinal_position  ordinal_position
		,col.column_name -- only here we can have handle bars expressions...eg {{obj_name}}_sid
		, col.column_type_id 
		 ,col.[is_nullable]
		  ,col.[data_type]
		  ,col.[max_len]
		  ,null [numeric_precision]
		  ,null [numeric_scale]
		  ,null primary_key_sorting
		  ,null [default_value]
		  , t._source
	from [dbo].[Obj_tree_idw_tables] t
	inner join [dbo].[Obj_tree_idw_tables_sur_pkeys] col on t.obj_name = col.src_obj_name

union all 
	select 
		 t.src_obj_id
		 , t.external_obj_id
		 ,	t.server_type_id
		 , t.server_name
		, t.db_name -- target db name
		, t.[schema_name] 
		, t.obj_name 
		, 10 obj_type_id --table 
		,col.ordinal_position ordinal_position
		,replace(col.[column_name], '{{obj_name}}', t.obj_name) column_name -- only here we can have handle bars expressions...eg {{obj_name}}_sid
		, col.column_type_id 
		 ,col.[is_nullable]
		  ,col.[data_type]
		  ,col.[max_len]
		  ,null [numeric_precision]
		  ,null [numeric_scale]
		  ,col.primary_key_sorting
		  ,col.[default_value]
		  , t._source
	from [dbo].[Obj_tree_idw_tables] t
	cross join static.[Column] col  
	where col.idw = 1 
)
select 
	src_obj_id
	, null external_obj_id 
	, server_type_id
	 , server_name
	, db_name [db_name] -- target db name
	, [schema_name] 
	, obj_name -- h means hit.ric
	, obj_type_id --table 
    , row_number() over (partition by src_obj_id order by ordinal_position) [ordinal_position] -- renumber
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

GO


