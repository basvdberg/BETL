/*------------------------------------------------------------------------------------------------
-- BETL, meta data driven ETL generation, licensed under GNU GPL https://github.com/basvdberg/BETL 
--------------------------------------------------------------------------------------------------
-- 2019-11-28 BvdB This is an ADF wrapper procedure ( because ADF does not really support SQL scripts. )
-- It reads the view that converts the source object tree into a 
-- staging object tree (ot) and ingests this ot using is_request=1 (to differentiate observed and requested object trees). 
-- next step would be to actually create / update the staging database schema.

exec [dbo].update_object_tree @schema_name = 'staging', @obj_type_name = 'table', @source = 'aa'
select * from dbo.obj_ext where schema_name = 'idw'
exec [dbo].update_object_tree 'sqldb_ddppoc' , 'idw'


select * from [dbo].col_ext where obj_name  = 'persoon' and schema_name = 'idw' and obj_type = 'view'
select * from [dbo].[Obj_tree_idw_views] where obj_name  = 'persoon'

*/
CREATE procedure [dbo].[update_object_tree]
	@db_name as sysname = 'sqldb_ddppoc'
	, @schema_name as sysname
	, @obj_type_name as varchar(100) = 'table'
	, @source as varchar(100) =null
	, @batch_id as int = -1 

as 
begin 
	declare 
		@proc_name as sysname =  object_name(@@PROCID)
		, @detect_table_delete as bit=0
		, @detect_view_delete as bit=0
		, @cnt as int 

	-- standard BETL header code... 
	set nocount on 
	exec dbo.log_batch @batch_id, 'Header', '?(b?) ?, ?, ?', @proc_name , @batch_id, @schema_name, @obj_type_name, @source
	-- END standard BETL header code... 

	declare @obj_tree_param ObjTreeTableParam
		, @schema_id as int

	select @schema_id = obj_id from obj_ext where obj_type = 'schema' and db_name = @db_name and obj_name = @schema_name and server_name = @@servername 
	if @schema_id is null 
	begin
		exec log_batch @batch_id, 'ERROR', '? Schema not found ?.?' , @proc_name, @db_name, @schema_name
		goto footer
	end else 
		exec log_batch @batch_id, 'INFO', '? ?.?[?]' , @proc_name, @db_name, @schema_name, @schema_id 

	if @schema_name = 'staging' and @obj_type_name = 'table' -- generate staging tables obj tree
	begin
		insert into @obj_tree_param 
		SELECT  *
		FROM [dbo].[Obj_tree_staging_tables]
		where _source = @source

		set @detect_table_delete= 1
	end
	if @schema_name = 'staging' and @obj_type_name = 'view' -- generate staging views obj tree
	begin
		insert into @obj_tree_param 
		SELECT  *
		FROM [dbo].[Obj_tree_staging_views]
		where _source = @source

		set @detect_view_delete= 1
	end

	if @schema_name = 'rdw' and @obj_type_name = 'table' -- generate staging tables obj tree
	begin
		insert into @obj_tree_param 
		SELECT  *
		FROM [dbo].[Obj_tree_rdw_tables]
		where _source = @source

		set @detect_table_delete= 1
	end
	if @schema_name = 'rdw' and @obj_type_name = 'view' -- generate staging views obj tree
	begin
		insert into @obj_tree_param 
		SELECT  *
		FROM [dbo].[Obj_tree_rdw_views]
		where _source = @source

		set @detect_view_delete= 1
	end

	if @schema_name = 'idw' and @obj_type_name = 'table' -- generate staging tables obj tree
	begin
/*		insert into @obj_tree_param 
		SELECT  *
		FROM [dbo].[Obj_tree_idw_table_h_cols]
		*/
		set @detect_table_delete= 1
	end
	if @schema_name = 'idw' and @obj_type_name = 'view' -- generate staging views obj tree
	begin
		insert into @obj_tree_param 
		SELECT  *
		FROM [dbo].[Obj_tree_idw_views]
		
		set @detect_view_delete= 1
	end

	if @schema_name = 'idw_hub' and @obj_type_name = 'table' -- generate staging tables obj tree
	begin
		insert into @obj_tree_param 
		SELECT  *
		FROM [dbo].[Obj_tree_idw_hub_cols]
		--where _source = @source

		set @detect_table_delete= 1
	end

	select @cnt = count(*) from @obj_tree_param 
	exec dbo.log_batch @batch_id, 'Info', 'cnt of @obj_tree_param : ?', @cnt 

	exec [dbo].[ingest_obj_tree] @obj_tree_param=@obj_tree_param, @batch_id=@batch_id, @is_request=1, @detect_table_delete=@detect_table_delete, @detect_view_delete=@detect_view_delete

	
	footer:
	exec dbo.log_batch @batch_id, 'Footer', '?(b?) ?, ?, ?', @proc_name , @batch_id, @schema_name, @obj_type_name, @source
	select @@error error

end