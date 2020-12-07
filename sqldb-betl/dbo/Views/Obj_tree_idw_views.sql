


--select * from [dbo].col_ext where obj_name  = 'persoon' and schema_name = 'idw' and obj_type = 'view'
-- select * from [dbo].[Obj_tree_idw_views] where obj_name  = 'persoon'
CREATE view [dbo].[Obj_tree_idw_views] as

select 
	obj.obj_id src_obj_id
	, null external_obj_id 
	, obj.server_type_id
	, obj.server_name
	, obj.[db_name] -- target db name
	, obj.[schema_name] 
	, replace( obj.obj_name , '_h', '')  obj_name
	, 20 obj_type_id -- view
    , col.[ordinal_position]
    , col.[column_name]
	, col.column_type_id 
    , col.[is_nullable]
    , [data_type]
    , max_len
    , col.[numeric_precision]
    , col.[numeric_scale]
    , col.primary_key_sorting
    , col.[default_value]
	, obj._source
	from dbo.obj_ext obj 
	left join dbo.Col_ext col on col.obj_id = obj.obj_id 
	where obj.obj_type in ( 'table')
	and obj.schema_name = 'idw'
	and obj.server_name = @@servername
	and ( ( col._delete_dt is null  
						and col._request_delete_dt is null)  -- column is not deleted or requested to be deleted. 
					  or col._request_create_dt is not null -- column is deleted, but also requested
					  ) 
	and obj._delete_dt is null 


--	and column_type_id <> 999