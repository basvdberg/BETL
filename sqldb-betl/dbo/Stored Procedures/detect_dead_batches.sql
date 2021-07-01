
	  
/*------------------------------------------------------------------------------------------------
-- BETL, meta data driven ETL generation, licensed under GNU GPL https://github.com/basvdberg/BETL 
--------------------------------------------------------------------------------------------------
-- 2021-07-01 Dead batches are batches that are started but never finished or failed and exceed the maximum lifetime.
*/


CREATE procedure [dbo].[detect_dead_batches]
	@batch_id int -- the current batch that calls this proc. 

as 
begin
	declare 
		@proc_name as sysname =  object_name(@@PROCID)
		,@batch_max_lifetime as int -- after this period of inactivity the batch will be seen as stopped.. 
		,@min_batch_start_dt as datetime -- performance filter to filter batches that started more than @batch_max_lifetime ago.
		,@i as int =0

	-- standard BETL header code... 
	set nocount on 
	exec dbo.log_batch @batch_id, 'Header', '?(b?)', @proc_name , @batch_id
	-- END standard BETL header code... 

	-- first detect dead batches (running too long idle) 
	exec dbo.getp @prop='batch_max_lifetime', @value=@batch_max_lifetime output, @batch_id = @batch_id 
	set @min_batch_start_dt = dateadd(minute, -@batch_max_lifetime, getdate()) 
	exec dbo.log_batch @batch_id, 'VAR', '@min_batch_start_dt ?', @min_batch_start_dt

	update b
	set status_id = 700 
	from dbo.batch b
	left join 
	( select b.batch_id, max(tl.log_dt) log_dt 
	  from dbo.Logging tl 
	  inner join dbo.Batch b on tl.batch_id = b.batch_id
		where b.status_id = 400 -- running
		and b.batch_start_dt < @min_batch_start_dt 
		and tl.log_dt > @min_batch_start_dt -- performance filter
	  group by b.batch_id ) 
	latest_log_dt on latest_log_dt.batch_id = b.batch_id 
	--inner join static.Status s on b.status_id = s.status_id 
	where b.status_id = 400 -- running
	and b.batch_start_dt < @min_batch_start_dt -- performance filter
	and latest_log_dt.batch_id is null -- there is no activity logged after @min_batch_start_dt

	set @i= @@ROWCOUNT
	if @i>0 
	begin
		exec dbo.log_batch @batch_id, 'INFO', 'stopped ? dead batches .', @i
	
		-- also stop transfers for stopped batches
		update t
		set status_id = 700 
		from dbo.Transfer t
		inner join dbo.Batch b on t.batch_id = b.batch_id 
		where b.status_id = 700 and t.status_id in ( 600, 400) 
		
		set @i= @@ROWCOUNT
		exec dbo.log_batch @batch_id, 'INFO', 'stopped ? dead transfers .', @i
	end

	-- standard BETL footer code... 
	exec dbo.log_batch @batch_id, 'Footer', '?(b?)', @proc_name , @batch_id
	-- END standard BETL header code... 
end