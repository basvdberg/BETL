





CREATE view [dbo].[Col_ext_unpivot] as 


	with new_col as ( 
		SELECT  [column_id]
      ,[column_name]
      ,[column_type_id]
      ,[column_type]
      ,[schema_name]
      ,[db_name]
      ,[full_obj_name]
   	, case when is_nullable=0 or ( column_type_id in (100,200) )   then 'NOT NULL' else 'NULL' end is_nullable
      ,[ordinal_position]
      , case when data_type in ('money', 'smallmoney')  then 'decimal' else data_type end data_type
	  , case when data_type in ( 'varchar', 'nvarchar', 'char', 'nchar', 'varbinary') then  isnull('('+ case when max_len<0 then 'MAX' else convert(varchar(10), max_len ) end + ')', '')
			   when numeric_precision is not null then '('+ convert(varchar(10), numeric_precision) +  
														isnull ( ',' + convert(varchar(10), numeric_scale), '') + ')' 
				else null
		end data_size
      ,[max_len]
      ,[numeric_precision]
      ,[numeric_scale]
      ,[obj_id]
      ,[obj_name]
      ,[part_of_unique_index]
      ,case when default_value is null then null else ' DEFAULT ('+ default_value + ')' end	default_value 
		, [primary_key_sorting]
		FROM [dbo].[Col_ext]
		where 
						( ( _delete_dt is null  
						and _request_delete_dt is null)  -- column is not deleted or requested to be deleted. 
					  or _request_create_dt is not null -- column is deleted, but also requested
					  ) 

	)


		select obj_id, ordinal_position, 
		_name, _value
		from ( 
		SELECT 
			obj_id, 
			ordinal_position, 
		  convert(sysname,  [column_id]) column_id 
		  , convert(sysname,  [column_name]) [column_name]
		  , convert(sysname,  [column_type_id])  [column_type_id]
		  , convert(sysname,  [column_type])  [column_type]
		  , convert(sysname,  [is_nullable])[is_nullable]
		  --, convert(sysname,  [ordinal_position]) [ordinal_position]
		  , convert(sysname,  [data_type]) [data_type]
		  , convert(sysname,  [data_size]) [data_size]
		  , convert(sysname,  [max_len]) [max_len]
		  , convert(sysname,  [numeric_precision]) [numeric_precision]
		  , convert(sysname,  [numeric_scale]) [numeric_scale]
		  , convert(sysname,  [part_of_unique_index]) [part_of_unique_index]
		  , convert(sysname,  [default_value]) [default_value]
		  , convert(sysname,  [primary_key_sorting]) [primary_key_sorting]
	    FROM new_col
		  ) q 
	  unpivot
	(
		_value
		for _name in ( 
		[column_id]
		,[column_name]
		,[column_type_id]
      ,[column_type]
      ,[is_nullable]
      --,[ordinal_position]
      ,[data_type]
	  , data_size
      ,[max_len]
      ,[numeric_precision]
      ,[numeric_scale]
      ,[part_of_unique_index]
	  ,[default_value]
	  ,[primary_key_sorting]

		  )
		) u