



--  select * from [dbo].[Obj_tree_idw_table_h_cols]  
create view [dbo].[Obj_tree_idw_table_h_cols]  as

select 
	src_obj_id
	, external_obj_id 
	, server_type_id
	 , server_name
	, [db_name] -- target db name
	, [schema_name] 
	, obj_name + '_h' obj_name -- h means hit.ric
	, obj_type_id --table 
    , [ordinal_position] -- renumber
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
from [dbo].[Obj_tree_idw_table_cols] 
-- order by obj_id, ordinal_position