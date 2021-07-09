/*------------------------------------------------------------------------------------------------
-- BETL, meta data driven ETL generation, licensed under GNU GPL https://github.com/basvdberg/BETL 
--------------------------------------------------------------------------------------------------
-- 2021-07-07 BvdB generate object and column definitions for rdw tables 
				  This is based on staging meta data 

clear_meta_data
exec dbo.update_rdw_def 
	select * from obj_ext  
	select * from col_ext  where is_definition=1
	order by obj_id, ordinal_position asc 

*/
CREATE procedure [dbo].[update_rdw_his_table_def] as 

-- BEGIN Generate RDW table definitions
declare @new_objects table( obj_name sysname, obj_id int, server_type_id int) 
declare @existing_objects table( obj_name sysname, obj_id int, _delete_dt datetime) 
declare
	@debug as bit = 0
	, @parent_id as int = dbo.obj_id('[sqldb-rdw].[rdw]') 

if @parent_id is null 
	exec dbo.log -1, 'ERROR', 'rdw object not found'
;

insert into @new_objects 
select 'aw_'+obj_name+'_his', obj_id, server_type_id 
-- select * 
from dbo.obj_ext o
where 
obj_type = 'table'
and db_name = 'sqldb-rdw'
and schema_name = 'staging_aw'
and _delete_dt is null 
and is_definition=0 
--and obj_name not like '%error%'

if @debug = 1
	select * from @new_objects 

insert into @existing_objects 
	select obj_name, obj_id, _delete_dt
	from dbo.Obj
	where parent_id = @parent_id 
	and is_definition=1
	and obj_type_id=10 -- table

if @debug = 1
	select * from @existing_objects 

-- insert new objects
insert into dbo.Obj(parent_id, obj_name, obj_type_id, src_obj_id, is_definition, server_type_id) 
select @parent_id, o.obj_name, 10 , o.obj_id, 1, server_type_id
from @new_objects o
left join @existing_objects eo on eo.obj_name = o.obj_name
where eo.obj_name is null

-- update deleted objects
update dbo.Obj set Obj._delete_dt=getdate()
from dbo.Obj o
inner join @existing_objects eo on o.obj_id = eo.obj_id
left join @new_objects new_o on o.obj_name= new_o.obj_name
where new_o.obj_name is null -- not found in new objects
and o.is_definition=1
and o.obj_type_id=10 -- table

-- update undeleted objects
update dbo.Obj set Obj._delete_dt=null, Obj.src_obj_id = new_o.obj_id
from dbo.Obj o
inner join @existing_objects eo on o.obj_id = eo.obj_id
inner join @new_objects new_o on o.obj_name= new_o.obj_name
where eo._delete_dt is not null 
and o.is_definition=1
and o.obj_type_id=10 -- table

-- END Generate RDW table definitions


-- BEGIN Generate RDW column definitions

-- for columns we choose to delete them and re-insert them 
delete from dbo.Col_h
where obj_id in ( 
	select od.obj_id 
	from dbo.Obj od
	inner join @new_objects o on od.src_obj_id = o.obj_id
	and od.is_definition=1
	and od.obj_type_id=10 -- table
) 
;
with col as ( 
	select 
		od.obj_id
		, c.[ordinal_position]
		, c.[column_name]
		, c.[column_type_id]
		,c.[is_nullable]
		,c.[data_type]
		,c.[max_len]
		,c.[numeric_precision]
		,c.[numeric_scale]
		,c.[part_of_unique_index]
		,c.[primary_key_sorting]
		,c.[default_value]
		, 1 is_definition
	from @new_objects o 
	inner join dbo.Obj od on o.obj_id = od.src_obj_id and od.is_definition=1
	inner join dbo.col c on o.obj_id = c.obj_id 
	where c.is_definition=0
	and od.obj_type_id=10 -- table
	union all 
	SELECT 
		od.obj_id
		,c.[ordinal_position]
		,lower(replace(c.[column_name], '{{obj_name}}', o.obj_name)) column_name 
		,c.[column_type_id]
		,c.[is_nullable]
		,c.[data_type]
		,c.[max_len]
		,null [numeric_precision]
		,null [numeric_scale]
		,null [part_of_unique_index]
		,c.[primary_key_sorting]
		,c.[default_value]
		, 1 is_definition
	FROM @new_objects o 
	inner join dbo.Obj od on o.obj_id = od.src_obj_id and od.is_definition=1
	cross join [static].[Column] c 
	where c.rdw=1 
) 
-- insert rdw static columns 
INSERT INTO [dbo].[Col]
           ([obj_id]
           ,[ordinal_position]
           ,[column_name]
           ,[column_type_id]
           ,[is_nullable]
           ,[data_type]
           ,[max_len]
           ,[numeric_precision]
           ,[numeric_scale]
           ,[part_of_unique_index]
           ,[primary_key_sorting]
           ,[default_value]
		   ,is_definition)
select 
           [obj_id]
           ,row_number() over (partition by obj_id order by [ordinal_position] asc) [ordinal_position]
           ,[column_name]
           ,[column_type_id]
           ,[is_nullable]
           ,[data_type]
           ,[max_len]
           ,[numeric_precision]
           ,[numeric_scale]
           ,[part_of_unique_index]
           ,[primary_key_sorting]
           ,[default_value]
		   ,is_definition
from col

-- END Generate RDW column definitions


-- we have to return something for ADF lookup task
select @@ROWCOUNT result
if @debug = 1
	SELECT * FROM [dbo].[Col_ext]
	where is_definition=1
	order by obj_id, ordinal_position


/*
insert into dbo.Obj_map ( obj_def_id, obj_id, join_type_id, ordinal_position)
select od.obj_def_id, src_obj_id, null, 10
from dbo.Obj_def od 
inner join @new_objects new_o on new_o.obj_id = od.src_obj_id

SELECT * FROM [dbo].[Obj_map]

delete from dbo.Obj_def
truncate table dbo.Obj_map
*/