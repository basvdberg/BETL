



-- select * from [dbo].[Obj_tree_staging_views]

CREATE view [dbo].[Obj_tree_staging_views] as 

select 
	obj.obj_id src_obj_id
	, null external_obj_id 
	, obj.server_type_id
	, obj.server_name
	, obj.[db_name] -- target db name
	, obj.[schema_name] 
	, obj.obj_name + '_exp' obj_name
	, 20 obj_type_id -- view
    , col.[ordinal_position]
    , col.[column_name]
	, col.column_type_id 
     ,col.[is_nullable]
      ,case when col.[data_type]='XML' then 'nvarchar' else col.[data_type] end [data_type]
      ,case when col.[data_type]='XML' then 0 else col.max_len end max_len
      ,col.[numeric_precision]
      ,col.[numeric_scale]
      ,col.primary_key_sorting
      ,col.[default_value]
	  , obj._source
	from dbo.obj_ext obj 
	left  join dbo.Col_ext col on col.obj_id =  obj.obj_id 
	where obj.obj_type in ( 'table')
	and obj.schema_name = 'staging'
	and obj.server_name = @@servername
	and column_type_id <> 999