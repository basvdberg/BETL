	  
/*------------------------------------------------------------------------------------------------
-- BETL, meta data driven ETL generation, licensed under GNU GPL https://github.com/basvdberg/BETL 
--------------------------------------------------------------------------------------------------
--2018-07-23 BvdB remove batch and corresponding transfers
exec dbo.drop_batch 10028
*/
CREATE procedure [dbo].[drop_batch]
	@batch_id int 
as 
begin 
	declare 
		@proc_name as varchar(255) =  object_name(@@PROCID)
		, @transfer_id as int =0
	update dbo.Batch set status_id = 400 -- running temporarily
	where batch_id = @batch_id 
	--exec dbo.start_transfer @batch_id, @transfer_id output, @proc_name 
	exec dbo.log @transfer_id, 'step', '? batch_id ', @proc_name , @batch_id
	update [dbo].[Batch]
	set [status_id] = (select status_id from static.status where status_name = 'deleted') 
	where batch_id = @batch_id 
	--update [dbo].[Transfer]
	--set [status_id] = (select status_id from static.status where status_name = 'deleted') 
	--where batch_id = @batch_id 
	--exec dbo.end_transfer @transfer_id
end