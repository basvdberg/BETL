



 CREATE view [dbo].[Obj_tree_idw_table_cols_basic] as 

	-- join with columns except meta data columns 999
	SELECT 
		t.src_obj_id, 
		t.external_obj_id,
		t.server_type_id
		, t.server_name
		, t.db_name -- target db name
		, t.[schema_name] 
		, t.obj_name 
		, 10 obj_type_id --table 
		,col.[ordinal_position]
		,[column_name]
		, case when column_name = '_source' then 300 else column_type_id end column_type_id 
		,[is_nullable]
		,[data_type] 
		,[max_len] 
		,[numeric_precision]
		,[numeric_scale]
		,case when column_type_id = 200 or column_name = '_eff_dt' then 'DESC' else null end primary_key_sorting
		,[default_value]
		, _source
	from dbo.Obj_tree_idw_tables t
	left  join dbo.Col_ext col on col.obj_id =  t.src_obj_id 
	where ( col.Column_type_id <> 999 or [column_name]='_source')  -- skip meta data fields from t.ging... 
	and ( col._delete_dt is null or col._request_create_dt is not null) -- either not deleted or requested