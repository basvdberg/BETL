	  
/*------------------------------------------------------------------------------------------------
-- BETL, meta data driven ETL generation, licensed under GNU GPL https://github.com/basvdberg/BETL 
--------------------------------------------------------------------------------------------------
-- 2012-12-21 BvdB log transfer ending 
declare @batch_id int ,
	@transfer_id int
exec dbo.end_transfer @batch_id output , @transfer_id output , 'test'
print @batch_id 
print @transfer_id 
*/
CREATE procedure [dbo].[end_transfer]
	@transfer_id int 
	, @status as varchar(255) = 'success'
	, @rec_cnt_src as int =null 
	, @rec_cnt_new as int =null 
	, @rec_cnt_changed as int =null 
	, @rec_cnt_deleted as int =null 
	, @rec_cnt_undeleted as int =null 

as 
begin 
	declare @nu as datetime = getdatE() 
		, @status_id as int 
		,@proc_name as varchar(255) =  object_name(@@PROCID)

	exec dbo.log @transfer_id, 'step', '?(t?) status ?', @proc_name , @transfer_id ,  @status
	
	select @status_id =status_id 
	from static.Status 
	where status_name = @status
		
	update dbo.Transfer set status_id = isnull(@status_id,status_id) , transfer_end_dt = @nu
		, rec_cnt_src = isnull(@rec_cnt_src,  rec_cnt_src) 
	, rec_cnt_new = isnull(@rec_cnt_new ,rec_cnt_new) 
	, rec_cnt_changed = isnull(@rec_cnt_changed , rec_cnt_changed) 
	, rec_cnt_deleted = isnull(@rec_cnt_deleted , rec_cnt_deleted) 
	, rec_cnt_undeleted = isnull(@rec_cnt_undeleted , rec_cnt_undeleted) 
	where transfer_id = @transfer_id  

	-- if batch has same name as transfer-> end batch. 
	-- this is because batch was automatically created 
	-- by start_transfer
	declare @batch_id as int 
	select @batch_id = b.batch_id 
	from dbo.batch b
	inner join dbo.Transfer t on t.batch_id = b.batch_id
	where b.batch_name= t.transfer_name
	and t.transfer_id = @transfer_id

	if @batch_id is not null 
		exec dbo.end_batch @batch_id, @status, @transfer_id
	footer: 
end