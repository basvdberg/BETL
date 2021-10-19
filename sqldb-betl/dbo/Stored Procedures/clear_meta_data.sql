/*---------------------------------------------------------------------------------------------
BETL, meta data driven ETL generation, licensed under GNU GPL https://github.com/basvdberg/BETL
-----------------------------------------------------------------------------------------------
-- 2020-04-06 BvdB delete all customer related meta data
*/
-- exec [dbo].[clear_meta_data] 
CREATE procedure [dbo].[clear_meta_data] as 
begin 
	
	delete from dbo.Logging
	delete from dbo.transfer
	delete from dbo.Property_value
	delete from dbo.col_h
	delete from dbo.Col_map_transform
	delete from dbo.col_map
	delete from col_def
	delete from Obj_map_transform
	delete from dbo.obj_map
	delete from obj_def
	delete from dbo.obj
	truncate table dbo.Cache_user_data

	exec dbo.init_meta_data
end