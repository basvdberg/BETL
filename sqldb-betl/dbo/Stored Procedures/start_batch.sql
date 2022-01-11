	  
/*------------------------------------------------------------------------------------------------
-- BETL, meta data driven ETL generation, licensed under GNU GPL https://github.com/basvdberg/BETL 
--------------------------------------------------------------------------------------------------
-- 2012-12-21 BvdB continue batch if running or start new batch. allow custom code integration 
--  with external batch administration
declare @batch_id int 
exec dbo.start_batch @batch_id output 
print @batch_id 
select * from dbo.batch 
where batch_id = @batch_id 
*/
CREATE procedure [dbo].[start_batch]
		@batch_id int output 
	, @batch_name as varchar(255) ='adhoc' 
	, @guid as varchar(255)=null
	, @parent_batch_id as int = -1 
	, @result_set as bit =1 -- set this to 0 to prevent a result set

as 
begin
   declare
		@prev_batch_id as int 
		,@prev_status as varchar(255) 
		,@status as varchar(255) = 'Failed'
		,@legacy_status as varchar(255) 
		,@prev_batch_start_dt datetime
		,@prev_batch_name varchar(100) = null 
		,@status_id as int 
		,@nu as datetime = getdate() 
		,@proc_name as varchar(255) =  object_name(@@PROCID)
		,@continue_batch as bit =0 
		,@prev_seq_nr as int 
		,@sql as varchar(max) 
		,@otap as char(1)

	set @otap = replace(@@servername, 'sql-ddppoc-', '')

	-- standard BETL header code... 
	set nocount on 
	begin try 
		-- first create the batch so we can log under this batch_id 
		insert into dbo.Batch(batch_name, batch_start_dt, guid, parent_batch_id )
					  values (@batch_name, @nu			, @guid, @parent_batch_id) 
		set @batch_id = SCOPE_IDENTITY()
		exec dbo.log_batch @batch_id , 'Header', '? ?', @proc_name , @batch_name
		-- END standard BETL header code... 

		exec dbo.detect_dead_batches @batch_id
		
		-- get previous batch id. This is a batch with the same unique name. and not in a state deleted or not started.
		select @prev_batch_id = max(batch_id) 
		from dbo.Batch  b
		inner join static.Status s on b.status_id = s.status_id 
		where batch_name = @batch_name
			and isnull(status_name, '')   not in ( 'Not started', 'deleted') 
			and batch_id < @batch_id 

		-- get the status of the previous batch
		select @prev_status=status_name
		, @continue_batch=continue_batch
		, @prev_seq_nr = batch_seq
		from dbo.Batch  b
		left join static.Status s on b.status_id = s.status_id 
		where b.batch_id = @prev_batch_id 

		set @status= 
		case @prev_status 
			when 'Success'		then 'Running'		-- just start again
			when 'Error'		then 'Continue'		-- continue where prev batch failed
			when 'Running'		then 'Not started'  -- do not start when prev batch is running
			when 'Restart'		then 'Running'		-- just start again. 
			when 'Continue'		then 'Not started'  -- do not start when prev batch is running
			when 'Stopped'		then 'Continue'		-- continue where prev batch stopped
			else 'Running'
		end 

		-- only continue previous batch when @continue_batch=1. else just start from the beginning
		if @continue_batch=0 and @status='Continue'
			set @status='Running' 

		-- get status_id
		select @status_id = status_id 
		from static.Status 
		where status_name = @status

		update dbo.Batch
		set status_id=@status_id
		, prev_batch_id=@prev_batch_id
		, batch_seq= isnull(@prev_seq_nr+1,0)
		where batch_id = @batch_id 
	end try
	begin catch 
		declare @msg2 as varchar(255) =ERROR_MESSAGE() 
				, @sev as int = ERROR_SEVERITY()
				, @number as int = ERROR_NUMBER() 
		IF @@TRANCOUNT > 0                ROLLBACK TRANSACTION
			exec dbo.log_error @batch_id = @parent_batch_id , @msg=@msg2,  @severity=@sev, @number=@number , @procedure=@proc_name
	end catch 
	
	if not isnull(@batch_id, -1) > 0 
		exec log_batch @batch_id, 'ERROR', 'Failed to start batch ?[?.?.?]  ', @batch_name, @batch_id, @parent_batch_id, @guid
	
	if @status='Not started' 
	begin 
		exec dbo.log_batch @batch_id , 'ERROR', 'batch ? was not started because there is already one instance running with name ?, namely ? ', @batch_id, @batch_name , @prev_batch_id 
	end 

	exec dbo.log_batch @batch_id , 'footer', '? ?(b?)..? (?)', @proc_name , @batch_name, @batch_id, @prev_batch_id, @status
    if @result_set=1 
		select @batch_id batch_id , case when @status in ('Running', 'Continue') then 1 else 0 end is_running, @otap otap


/*
junk jard
			if @status is null and @continue_batch = 1 
			begin 
				--if @prev_batch_status in ( 'error', 'running', 'continue', 'stopped') 
				if isnull(@prev_status,'')  in ( 'success', 'skipped')
				--	and datediff(hour, @prev_transfer_end_dt , getdatE()) < 20 -- binnen 20 uur herstart ->continue
					set @status = 'skipped' -- skip this step 
				else
					set @status = 'running' -- run this step
				 set @msg = 'Batch status '+ @batch_status  + ', transfer status: '+ @status+ ' prev_status: '+@prev_status
			end 
			if @status is null and @batch_status in ( 'success') 
			begin 
				set @msg = 'Batch status changed from success to running'
				-- set batch status to running
				update dbo.Batch
				set status_id = (select status_id from static.status where status_name = 'running') 
				where batch_id = @batch_id 
				set @status = 'running' 
			end
			if @status is null and @batch_status in (  'running', 'restart') -- note that Restart should not occur. Because this 
			--- status is only set to previous batch
			begin 
				set @status = 'running' 
				set @msg = 'Batch status '+ @batch_status  + ', transfer status: '+ @status
			end 
*/

end