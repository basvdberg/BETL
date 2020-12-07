	  
/*------------------------------------------------------------------------------------------------
-- BETL, meta data driven ETL generation, licensed under GNU GPL https://github.com/basvdberg/BETL 
--------------------------------------------------------------------------------------------------
-- 2017-01-01 BvdB 
exec dbo.info '[idv].[stgl_klantverloop]'
exec dbo.set_column_type '[AdventureWorks2014].[idv].[stgl_klantverloop]' , 'datum' , 102
*/
  
CREATE  PROCEDURE [dbo].[set_column_type] 
	@full_obj_name as varchar(255) 
	, @column_name as varchar(255) 
	, @column_type_id as int 
	, @scope as varchar(255) =null 
as 
begin 
	-- standard BETL header code... 
	set nocount on 
	declare @transfer_id as int = 0 -- for internal betl procedures
	declare @proc_name as varchar(255) =  object_name(@@PROCID);
	exec dbo.log @transfer_id, 'header', '? ? ? ?', @proc_name , @full_obj_name, @column_name, @column_type_id
	-- END standard BETL header code... 

	declare @obj_id as int
	exec dbo.get_obj_id @full_obj_name, @obj_id output, @scope , @obj_tree_depth=default, @transfer_id=@transfer_id
	if @obj_id is null or @obj_id < 0 
	begin
		exec dbo.log @transfer_id, 'step', 'Object ? not found in scope ? .', @full_obj_name, @scope 
		goto footer
	end
	exec dbo.log @transfer_id, 'step', 'obj_id resolved: ?(?), scope ? ',@full_obj_name, @obj_id , @scope
	-- first check column_type_id 
	declare @c_type as int 
	select @c_type  = column_type_id 
	from static.Column_type 
	where column_type_id = @column_type_id
	if @c_type is null 
		exec dbo.log @transfer_id, 'error', 'invalid column type ?' , @column_type_id 
	else 
	begin 
		declare @column_id as int 
		
		select @column_id = column_id 
		from dbo.col_hist 
		where column_name = @column_name and obj_id = @obj_id 
		
		if @column_id is null 
			exec dbo.log @transfer_id, 'error', 'column ? does not exist for object ?(?) ' , @column_name, @full_obj_name, @obj_id
		else 
		begin 
			exec dbo.log @transfer_id, 'var', 'column_id resolved: ?(?)',@column_name, @column_id
			update dbo.col_hist  set column_type_id = @column_type_id
			where column_id = @column_id 
			
			select * from dbo.col_ext where column_id = @column_id 
		end
		end 
	footer:
		exec dbo.log @transfer_id, 'footer', 'DONE ? ? ? ?', @proc_name , @full_obj_name, @column_name, @column_type_id
	-- END standard BETL footer code... 
end