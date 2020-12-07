
CREATE  view [static].[column_enriched_ext] as 

	select 
		  [schema_name]
		  , obj_name
		  , obj_type 
		  ,[column_name]
		  ,[column_type_id]
	from static.Column_enriched 
	union all 
	SELECT 
		  [schema_name]
		  ,[obj_name]+ '_exp' obj_name
		  , 'view' obj_type 
		  ,[column_name]
		  ,[column_type_id]
	from static.Column_enriched 
	where [schema_name] = 'staging'