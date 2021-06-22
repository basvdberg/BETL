	  
/*
------------------------------------------------------------------------------------------------
-- BETL, meta data driven ETL generation, licensed under GNU GPL https://github.com/basvdberg/BETL 
--------------------------------------------------------------------------------------------------

-- 2017-09-06 BvdB Return meta data id for a full object name
-- full object name can be a table, view, schema, database or ... 

declare @obj_id  as int 
exec [dbo].[get_obj_id] '[DDP_IDW].[dbo]', @obj_id  output


exec [dbo].[get_obj_id] 'LOCALHOST', @obj_id  output--, 'NF'
exec [dbo].[get_obj_id] 'AdventureWorks2014.Production.Product', @obj_id  output--, 'NF'

select @obj_id  

*/
CREATE PROCEDURE [dbo].[get_obj_id] 
	@full_obj_name varchar(255) 
	, @obj_id int output 
	, @obj_tree_depth int = 0
	, @batch_id as int = -1
as
BEGIN
	-- standard BETL header code. perform some logging.
	set nocount on 
	declare @proc_name as varchar(255) = object_name(@@PROCID);
	exec dbo.log @batch_id, 'header_detail', '? ? , , depth ?', @proc_name , @full_obj_name, @obj_tree_depth
	-- END standard BETL header code... 

	declare 
		@schema as varchar(255) 
		, @parent varchar(255) 
		, @db_name varchar(255) 

	
	-- retrieve object meta data. If not found->refresh parent (schema)... 

	Set @obj_id = dbo.obj_id(@full_obj_name) 

	-- When this proc is called on a table in an unknown database. The table obviously cannot be found in the meta data. 
	-- When this happens this procedure will try to go find the schema in the meta data. If this fails, it will try to get the database. If failed it will try to get the server name. 
	-- When successfull it wil go down again until it reaches the table. 
	
/*
	if @obj_id is null or @obj_id < 0 -- not found 
	begin -- refresh parent

		Set @parent = util.parent(@full_obj_name) 

		if @parent is null or @parent = ''
		begin
			-- this happens when for example a new view is just created in current database. 
			-- try to refresh current database
			exec dbo.log @batch_id, 'Warn', 'object ? not found in scope ? and no parent ', @full_obj_name, @scope 

			select @db_name = dbo.current_db() 
			if @db_name is not null and @db_name <> @full_obj_name -- not already refreshing current db. 
				and @full_obj_name <> 'localhost' -- always stop at localhost. 
			begin
				exec dbo.log @batch_id, 'INFO', 'Refreshing current db ? ', @db_name 
				exec dbo.refresh @db_name, 1
				-- retry
				Set @obj_id = dbo.obj_id(@full_obj_name, @scope) 
			end
			
			if @obj_id is null or @obj_id < 0 
			begin -- refreshing current database did not work -> try refreshing localhost
				exec dbo.log @batch_id, 'INFO', 'Refreshing localhost '
				exec dbo.refresh 'localhost', 0
				Set @obj_id = dbo.obj_id(@full_obj_name, @scope) 

				if @db_name is not null and @db_name <> @full_obj_name -- not already refreshing current db. 
				begin 
					exec dbo.log @batch_id, 'INFO', 'Attempt to refresh current db ? ', @db_name
					exec dbo.refresh @db_name, 1
				end 
				-- retry
				Set @obj_id = dbo.obj_id(@full_obj_name, @scope) 
			end

			if @obj_id is null or @obj_id < 0 
				exec dbo.log @batch_id, 'Warn', 'object ? not found', @full_obj_name, @scope 

			goto footer
		end
		exec dbo.log @batch_id, 'Warn', 'object ?(?) not found. Try to refresh parent -> ? ', @full_obj_name, @scope , @parent
		exec dbo.refresh @parent, 0, @scope -- @obj_tree_depth 
		Set @obj_id = dbo.obj_id(@full_obj_name, @scope) 
	end 
	*/
	if @obj_id <0 -- ambiguous object-id 
	begin
		exec dbo.log @batch_id, 'ERROR', 'Object name ? is ambiguous. ? duplicates.', @full_obj_name, @obj_id 

		-- this can occur when for example @full_obj_name = <schema>.<table|view>  and this object exists in more than 1 database.
		-- try to fix this by prefixing the current db_name
		select @db_name = dbo.current_db() 
		if @db_name is not null and @db_name <> @full_obj_name -- not already refreshing current db. 
			and @full_obj_name <> 'localhost' -- always stop at localhost. 
		begin
			set @full_obj_name = quotename(@db_name) + '.'+ @full_obj_name 
			-- retry
			Set @obj_id = dbo.obj_id(@full_obj_name) 
		end

		goto footer
	end

    footer:

	if isnull(@obj_id,0)  <= 0 
		exec dbo.log @batch_id, 'ERROR', 'Object ? NOT FOUND', @full_obj_name

--				exec dbo.log @batch_id, 'step', 'Found object-id ?(?)->?', @full_obj_name, @scope, @obj_id

	-- standard BETL footer code... 
	exec dbo.log @batch_id, 'footer_detail', 'DONE ? ?(?)', @proc_name , @full_obj_name, @obj_id -- @obj_tree_depth, @batch_id
	-- END standard BETL footer code... 
END