
/*------------------------------------------------------------------------------------------------
-- BETL, meta data driven ETL generation, licensed under GNU GPL https://github.com/basvdberg/BETL 
--------------------------------------------------------------------------------------------------
-- 2020-05-20 BvdB Setup properties. run this after a fresh repo install. It sets the default templates for object subtrees.

exec setup
*/
CREATE procedure [dbo].[setup]
	@batch_id as int=-1
as 
begin 
declare 
		@proc_name as sysname =  object_name(@@PROCID)

	-- standard BETL header code... 
	set nocount on 
	exec dbo.log_batch @batch_id, 'Header', '?(b?)', @proc_name , @batch_id
	-- END standard BETL header code... 

	exec dbo.log_batch @batch_id, 'Header', '?(b?)', @proc_name , @batch_id

	-- staging
	exec setp 'template_name_create_table', 'drop_and_create_table' , 'sqldb_ddppoc.staging'
	exec setp 'template_name_create_view', 'create_staging_view_if_not_exists' , 'sqldb_ddppoc.staging'

	-- rdw
	exec setp 'template_name_create_table', 'create_table_if_not_exists' , 'sqldb_ddppoc.rdw'
	exec setp 'template_name_create_view', 'drop_and_create_latest_view' , 'sqldb_ddppoc.rdw'

	-- idw
	exec setp 'template_name_create_table', 'create_table_if_not_exists' , 'sqldb_ddppoc.idw'
	exec setp 'template_name_create_table', 'create_table_if_not_exists_identity' , 'sqldb_ddppoc.idw_hub'
	exec setp 'template_name_create_view',  'drop_and_create_latest_view_sur_key' , 'sqldb_ddppoc.idw'

	exec setp 'template_name_update_table', 'update_idw' , 'sqldb_ddppoc.idw'
	exec setp 'template_name_update_table', 'update_idw_hub' , 'sqldb_ddppoc.idw_hub'
	

	exec dbo.log_batch @batch_id, 'Footer', '?(b?)', @proc_name , @batch_id
end