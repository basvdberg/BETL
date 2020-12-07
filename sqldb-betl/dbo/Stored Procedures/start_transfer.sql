  
/*------------------------------------------------------------------------------------------------
-- BETL, meta data driven ETL generation, licensed under GNU GPL https://github.com/basvdberg/BETL 
--------------------------------------------------------------------------------------------------
-- 2012-12-21 BvdB create transfer if not exist 
declare @batch_id int ,
	@transfer_id int
exec dbo.start_transfer @batch_id output , @transfer_id output , 'test'
select * from dbo.batch where batch_id = @batch_id 
select * from dbo.transfer where transfer_id = @transfer_id
*/
CREATE procedure [dbo].[start_transfer]
	@batch_id int output
	, @transfer_id int output 
	, @transfer_name as varchar(255) 
	, @src_obj_id int=null 
	, @trg_obj_id int=null 
	, @trg_obj_name nvarchar(255) ='' 
	, @batch_name as varchar(255) =null -- '@pipeline().Pipeline'
	, @batch_guid as varchar(255)= null -- '@pipeline().RunId'	
	, @transfer_guid as varchar(255)= null -- '@pipeline().RunId'
	, @parent_batch_id as int=-1
	, @is_running as bit = 0 output
	, @result_set as bit =1 -- set this to 0 to prevent a result set
as 
begin 
	set nocount on 
	declare 
		@prev_batch_id as int 
		,@prev_transfer_id as int 
		,@batch_status as varchar(255) 
		,@status as varchar(255) = 'running'
		,@prev_batch_status as varchar(255) 
		,@prev_status as varchar(255) 
		,@prev_transfer_end_dt as datetime
		,@new_status as varchar(255) 
		,@prev_batch_start_dt datetime
		,@prev_batch_name varchar(100) = null 
		,@status_id as int 
		,@msg as varchar(255) =''
		,@nu as datetime = getdate() 
		,@proc_name as varchar(255) =  object_name(@@PROCID)
		,@continue_batch as bit
		,@prev_seq_nr as int =0 
		,@batch_is_running as bit=0

	--select @transfer_id = -1
	--select @transfer_id=transfer_id , @status =s.status_name
	--from dbo.[Transfer] t
	--inner join static.Status s on t.status_id = s.status_id
	--where transfer_name = @transfer_name and batch_id = @batch_id 

	--if @transfer_id>0 -- already exists
	--	goto footer 
	begin try 
		set @batch_id = isnull(@batch_id,-1)

		insert into dbo.Transfer( batch_id, transfer_start_dt, transfer_name, trg_obj_name,src_obj_id,  trg_obj_id, guid)
		values (@batch_id, @nu, @transfer_name, @trg_obj_name, @src_obj_id,   @trg_obj_id, @transfer_guid) 
		select @transfer_id = SCOPE_IDENTITY()

		exec dbo.log @transfer_id, 'Header', '? ?(?) (b?)', @proc_name , @transfer_name, @transfer_id , @batch_id

/*
		set @batch_name = isnull(@batch_name , isnull( @transfer_name ,'')) 
		if isnull(@batch_id,-1) <= 0 
			exec dbo.start_batch @batch_id output , @batch_name, @batch_guid , @parent_batch_id, 0 -- no result set
			*/
		select @batch_is_running = s.is_running , @batch_status = s.status_name ,@prev_batch_id= prev_batch_id
		from dbo.batch b
		inner join static.status s on b.status_id = s.status_id
		where b.batch_id = @batch_id 

		if  @batch_id > 0 and @batch_is_running=0 -- batch must be in a running state or be a debug batch 
		begin
			exec dbo.log @transfer_id , 'warn', 'batch_id ? is not in a running state.', @batch_id
			set @status = 'not started'
			goto footer
		end

		-- lookup previous transfer details 
		select @prev_status = s.status_name 
			, @prev_transfer_end_dt = t.transfer_end_dt
			, @prev_transfer_id = t.transfer_id 
			, @prev_seq_nr = transfer_seq
		from dbo.[Transfer] t 
		inner join static.status s on t.status_id = s.status_id
		where t.batch_id=@prev_batch_id
		and t.transfer_name = @transfer_name -- same name 

		if @batch_status = 'running'
			set @status='running'

		if @batch_status = 'continue'
			set @status = 
			case @prev_status 
				when 'Success'		then 'skipped'
				when 'Skipped'		then 'skipped' -- skip again
				else 'Running'
			end 

		select @status_id = status_id 
		from static.status where status_name = @status

		update dbo.Transfer
		set @batch_id = @batch_id, @status_id=status_id , prev_transfer_id= @prev_transfer_id
			,transfer_seq= isnull(@prev_seq_nr,0) +1 
		where transfer_id = @transfer_id 

	end try
	begin catch 
		declare @msg2 as varchar(255) =ERROR_MESSAGE() 
				, @sev as int = ERROR_SEVERITY()
				, @number as int = ERROR_NUMBER() 
--		IF @@TRANCOUNT > 0  ROLLBACK TRANSACTION
		exec dbo.log_error @transfer_id, @msg=@msg2,  @severity=@sev, @number=@number , @batch_id= @batch_id
	end catch 
	
	footer:

	if @status in ( 'error', 'not started', 'stopped') and @batch_id >0 
	begin 
		set @msg = 'failed to start transfer '+isnull(@msg,'')+ isnull(', @batch_id = '+convert(varchar(10), @batch_id),'') 
		exec dbo.log @transfer_id, 'error', '? batch_id ?, transfer ?(transfer_id) : ? ? ? ', @proc_name , @msg
	end 

	if isnull(@transfer_id,0) > 0 and ( @status in ( 'running', 'continue')  or @batch_id =-1 ) 
		set @is_running = 1

--	exec dbo.log @transfer_id, 'footer', '?(?) ?', @proc_name , @transfer_id, @msg
	if @result_set=1 
		select @transfer_id transfer_id, @is_running is_running 
end