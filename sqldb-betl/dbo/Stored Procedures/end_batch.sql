	  
/*------------------------------------------------------------------------------------------------
-- BETL, meta data driven ETL generation, licensed under GNU GPL https://github.com/basvdberg/BETL 
--------------------------------------------------------------------------------------------------
-- 2012-12-21 BvdB log ending of batch. allow custom code integration with external logging. 
declare @batch_id int 
exec dbo.end_batch @batch_id output 
print @batch_id 
*/
CREATE procedure [dbo].[end_batch] 
	@batch_id int output ,
	@status as varchar(255),
	@result_set as bit=0
as 
begin 
	declare @status_id as int 
		,@nu as datetime = getdatE() 
		,@proc_name as varchar(255) =  object_name(@@PROCID);

	if not @batch_id > 0 
		goto footer

	select @status_id =status_id 
	from static.Status 
	where status_name = @status

	update [dbo].[Batch]
	set [status_id] = @status_id , batch_end_dt =@nu
	where batch_id = @batch_id 
	and status_id <> 200 -- never overwrite error batch status

	footer:
	exec dbo.log_batch @batch_id , 'footer', '? ?(?)', @proc_name ,  @batch_id, @status

	if @result_set=1 
		select 'done' status
end