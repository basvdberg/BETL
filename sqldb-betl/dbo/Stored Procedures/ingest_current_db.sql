
/*------------------------------------------------------------------------------------------------
-- BETL, meta data driven ETL generation, licensed under GNU GPL https://github.com/basvdberg/BETL 
--------------------------------------------------------------------------------------------------
-- 2021-03-29 BvdB ingest the object tree of the current database. 
*/
CREATE procedure [dbo].[ingest_current_db] 

as 
begin 
	set nocount on 
	declare @proc_name as sysname =  object_name(@@PROCID)
		, @batch_id as int

	-- standard BETL header code... 
	set nocount on 
	exec dbo.log @batch_id, 'Header', '?(b?)', @proc_name , @batch_id
	-- END standard BETL header code... 

	declare @obj_tree_param ObjTreeTableParam 

	insert into @obj_tree_param 
	select  *
	from dbo.obj_tree_ms_sql_server

	exec [dbo].[ingest_obj_tree] @obj_tree_param

	exec dbo.log @batch_id, 'Footer', '?(b?)', @proc_name , @batch_id
end