create view vw_staging_obj_aw as 
-- definition of staging objects based on source syste, objects

SELECT o.[obj_id] src_obj_id -- this is the betl internal reference to the main object/table that acted as a source for this object
	, null external_obj_id -- this is an object id outside betl for this object. 
	  , server_type_id 
	  , 'sqls-betl-dev' server_name 
	  , 'sqldb-rdw' db_name 
      , 'staging_aw' schema_name 
      , case when schema_name <> 'dbo' then schema_name +'_' else '' end + [obj_name] [obj_name]
	  ,10 [obj_type_id]  -- table
      ,c.ordinal_position -- stays the same
      ,c.column_name
      ,c.column_type_id
      ,c.is_nullable
      ,c.data_type
      ,c.max_len
      ,c.numeric_precision
      ,c.numeric_scale
      ,c.primary_key_sorting
      ,null default_value -- just copy contents. Do not use source system defaults. 
      ,'aw' _source
--select * 
from prop_ext pe 
inner join dbo.obj_ext o on pe.obj_id = o.obj_id
inner join dbo.col c on c.obj_id= o.obj_id
where property = 'include_staging' and inherited_value = 1 
and pe.obj_type = 'table' 
and o._source = 'aw'