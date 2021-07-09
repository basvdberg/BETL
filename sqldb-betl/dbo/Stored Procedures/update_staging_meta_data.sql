/*------------------------------------------------------------------------------------------------
-- BETL, meta data driven ETL generation, licensed under GNU GPL https://github.com/basvdberg/BETL 
--------------------------------------------------------------------------------------------------
-- 2021-07-09 BvdB update src_obj_id and set column_type_id = 100 for pkey columns in staging based on source meta data. 

select * from obj_ext

*/

CREATE procedure [dbo].[update_staging_meta_data] as

-- update src_obj_id in staging meta data 

update  staging set src_obj_id = src.obj_id 
--case when src.schema_name <> 'dbo' then src.schema_name + '_' end + src.obj_name
from dbo.obj_ext src
inner join dbo.obj_ext staging on 
staging.schema_name = 'staging_aw' and 
case when src.schema_name <> 'dbo' then src.schema_name + '_' end + src.obj_name = staging.obj_name
where src.db_name ='sqldb-aw'
and src.obj_type = 'table'
and staging.src_obj_id is null -- not set before


update staging_col set staging_col .column_type_id = src_col.column_type_id
from dbo.col_ext staging_col 
inner join dbo.col_ext src_col on staging_col.src_obj_id = src_col.obj_id 
and staging_col.column_name = src_col.column_name
and staging_col.column_type_id = 300
and src_col.column_type_id = 100 -- because of p_key

select @@ROWCOUNT result