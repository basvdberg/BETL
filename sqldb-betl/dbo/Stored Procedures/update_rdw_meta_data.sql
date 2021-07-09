

/*------------------------------------------------------------------------------------------------
-- BETL, meta data driven ETL generation, licensed under GNU GPL https://github.com/basvdberg/BETL 
--------------------------------------------------------------------------------------------------
-- 2021-07-09 BvdB update src_obj_id in rdw his tables

select * from obj_ext
*/

CREATE procedure [dbo].[update_rdw_meta_data] as

-- update src_obj_id in staging meta data 
update observed set observed.src_obj_id = def.src_obj_id 
from dbo.obj observed
inner join dbo.obj def on def.is_definition=1 and observed.obj_name = def.obj_name and observed.parent_id = def.parent_id 
where observed.is_definition=0
and observed.src_obj_id is null

update col set col.column_type_id = col_def.column_type_id
from dbo.col_ext col 
inner join dbo.col_ext col_def on col_def.src_obj_id = col.src_obj_id
and col_def.is_definition=1 
and col_def.column_name = col.column_name
and col.column_type_id = 300
and col_def.column_type_id <> 300  -- because of p_key

select @@ROWCOUNT result