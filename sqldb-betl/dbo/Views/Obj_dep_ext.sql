

	  
-- select * from [dbo].[Obj_dep_ext] 
CREATE VIEW [dbo].[Obj_dep_ext] AS
select 
 obj.obj_id obj_id
, obj_dep.top_sort_rank
,obj.full_obj_name full_obj_name
, dep.obj_id dep_obj_id 
, dep.full_obj_name dep_full_obj_name
, obj_dep.dep_type_id
, dt.dep_type 

, obj.db_name obj_db_name
, obj.[schema_name] obj_schema_name
, obj.obj_name obj_name
, obj.obj_type 

, dep.db_name dep_db_name
, dep.[schema_name] dep_schema_name
, dep.obj_name dep_obj_name
, dep.obj_type dep_obj_type 


from dbo.Obj_dep obj_dep 
inner join static.dep_type dt on obj_dep.dep_type_id = dt.dep_type_id 
inner join dbo.obj_ext obj on obj_dep.obj_id = obj.obj_id
inner join dbo.obj_ext dep on obj_dep.dep_obj_id = dep.obj_id 
where obj_dep.delete_dt is null