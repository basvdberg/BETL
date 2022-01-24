





CREATE view [dbo].[Obj_ext_all_unpivot] as 

	select _obj_id, _name, _value
		from ( 
		SELECT 
		obj_id _obj_id 
       , convert(sysname,  [obj_id]) [obj_id]
      , convert(sysname,  [full_obj_name]) [full_obj_name]
      , convert(sysname,  [schema_obj_name]) [schema_obj_name]
      , convert(sysname,  [obj_type]) [obj_type]
      , convert(sysname,  [server_type]) [server_type]
      , convert(sysname,  [obj_name]) [obj_name]
      , convert(sysname,  [server_name]) [server_name]
      , convert(sysname,  [db_name]) [db_name]
      , convert(sysname,  [schema_name]) [schema_name]
      , convert(sysname,  [schema_object]) [schema_object]
      , convert(sysname,  [prefix]) [prefix]
      , convert(sysname,  [obj_name_no_prefix]) [obj_name_no_prefix]
      , convert(sysname,  [src_obj_id]) [src_obj_id]
      , convert(sysname,  [obj_def_id]) [obj_def_id]
      , convert(sysname,  [_source]) [_source]


  FROM [dbo].[Obj_ext_all]
		  ) q 
	  unpivot
	(
		_value
		for _name in ( 
      [obj_id]
	  ,[full_obj_name]
      ,[schema_obj_name]
      ,[obj_type]
      ,[server_type]
      ,[obj_name]
      ,[server_name]
      ,[db_name]
      ,[schema_name]
      ,[schema_object]
      ,[prefix]
      ,[obj_name_no_prefix]
	  , src_obj_id
	  , obj_def_id
	  , _source


		  )
		) u