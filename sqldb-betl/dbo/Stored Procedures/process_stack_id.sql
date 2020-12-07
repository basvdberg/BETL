	  
	
/*---------------------------------------------------------------------------------------------
BETL, meta data driven ETL generation, licensed under GNU GPL https://github.com/basvdberg/BETL
-----------------------------------------------------------------------------------------------
-- 2018-04-23 BvdB
 exec dbo.process_stack_id 1 

 */
CREATE procedure [dbo].[process_stack_id] 
	@stack_id as int 
	, @transfer_id as int = -1 

as
begin
	-- standard BETL header code... 
	set nocount on 
	declare @proc_name as varchar(255) =  object_name(@@PROCID);
	exec dbo.log @transfer_id, 'Header', '? ', @proc_name 
	-- END standard BETL header code... 

	--exec dbo.log @transfer_id, 'Header', '?', @proc_name 
	declare @sql as nvarchar(max) 
		--, @stack_id as int
	--select @stack_id = min(stack_id) from dbo.Stack
	if @stack_id is not null 
	begin 
		select @sql = [value] from dbo.Stack where stack_id = @stack_id 
		
		exec dbo.log @transfer_id, 'VAR', '@sql ? ', @sql

		exec dbo.exec_sql @transfer_id, @sql 
		delete from dbo.Stack 
		where stack_id = @stack_id 
		--exec [dbo].process_stack
	end 

	footer:
	exec dbo.log @transfer_id, 'Footer', '? ', @proc_name 

end