
/*------------------------------------------------------------------------------------------------
-- BETL, meta data driven ETL generation, licensed under GNU GPL https://github.com/basvdberg/BETL 
--------------------------------------------------------------------------------------------------
-- 2017-01-01 BvdB execute and log sql statement ( if exec_sql = 1) 
exec dbo.setp 'log_level', 'verbose'
declare @result as int=0
exec @result = dbo.exec_sql 0, 'WAITFOR DELAY ''00:01:02''  ', 'tempdb', 1

--
exec dbo.exec_sql 0, 'select db_name() aap
GO  select getdate()
', 'ddp_idw'

, 'tempdb', 1
exec @result = dbo.exec_sql 0, 'select db_name()'
print @result 
-- =============================================
*/
CREATE PROCEDURE [dbo].[exec_sql]
	@batch_id as int =0 
	, @sql as nvarchar(max)
	, @trg_db_name as sysname =null 
	, @async bit =0 -- set to 1 to run asynchronously 
AS
BEGIN
	SET NOCOUNT ON;
	declare @log_level_id smallint
			, @log_type_id smallint
			, @nesting smallint
			, @nl as varchar(2) = char(13)+char(10)
			, @min_log_level_id smallint
			, @exec_sql bit
			, @result as int =0
			, @msg as varchar(255) = 'error in exec_sql'
			, @sev as int = 15
			, @number as int =0
			, @db_exec nvarchar(1000)
			, @proc_max_cnt as int = 0 
			, @cnt_proc as int = 0 
			, @category_id as int 
			, @cnt_procs as int
			, @proc_name_pattern as varchar(255) = 'betl_proc_' -- +convert(varchar(255), @batch_id) 
			, @wait_time_sec as int 
			, @proc_max_wait_time_min as int 
			, @proc_max_wait_time_sec as int 
			, @job_id as uniqueidentifier 
			, @job_name as varchar(255) 
			, @tmp_sql as varchar(max) 
			, @proc_polling_interval_sec as int 
			, @time_str as varchar(50) 
			, @proc_dead_time_sec as int 
			, @sql_statement as nvarchar(max)

	exec dbo.getp 'exec_sql', @exec_sql output
	if @exec_sql is null 
		set @exec_sql=1

	if @trg_db_name is null 
		set @trg_db_name = db_name()

	--exec dbo.log @batch_id, 'sql', @sql -- whether sql is logged is determined in usp log

	if @exec_sql =1 
	begin
		-- always declare and open this local cursor. closing is done in the 
		DECLARE cur CURSOR LOCAL READ_ONLY FORWARD_ONLY FOR   
		select item [sql_statement] from util.split(@sql, @nl + 'GO' )
		OPEN cur  

		begin try

			SET @db_exec = quotename(@trg_db_name)+ '.sys.sp_executesql';

			if @async =0
			begin
				-- split @sql in multiple sql statements separated by GO<newline>
				FETCH NEXT FROM cur INTO @sql_statement
				WHILE @@FETCH_STATUS = 0  
				BEGIN
					exec log @batch_id , 'sql', '? ? ' , @db_exec, @sql_statement
					exec @result = @db_exec @sql_statement
					if @result <> 0 
						goto footer

					FETCH NEXT FROM cur INTO @sql_statement
				END
			
			end
			else
			begin -- @async =1
				-- not supported yet in azure sql 
				/*
				-- how many concurrent processes / jobs. default 4 
				exec dbo.getp 'proc_max_cnt', @proc_max_cnt output
				-- how long should we wait for a proc to finish when proc_max_cnt is reached. default 1 minute
				-- in other words. When proc_max_cnt are running simultaneously. How long will it take for a slot to come free. 
				exec dbo.getp 'proc_max_wait_time_min', @proc_max_wait_time_min output
				set @proc_max_wait_time_sec = @proc_max_wait_time_min * 60
				-- wait polling interval. How long till we check again. range: 1-59 
				exec dbo.getp 'proc_polling_interval_sec', @proc_polling_interval_sec output
				set @time_str = '00:00:'+convert(varchar(2), @proc_polling_interval_sec) ;  
				-- delete jobs that are created more than @proc_dead_time_sec ago and are not running. 
				-- warning: do not set this too low or else new jobs that are being setup are deleted as well. 
				exec dbo.getp 'proc_dead_time_sec', @proc_dead_time_sec output
				
				if isnull(@proc_max_cnt,0) <=0 
					goto footer

				-- make sure that the job category exists 
				select @category_id = category_id from msdb.dbo.syscategories where category_class = 1 and category_type = 1 and name ='betl'
				if @category_id is null 
					exec msdb.dbo.sp_add_category @class = 'job', @type = 'local', @name = 'betl'
			    select @category_id = category_id from msdb.dbo.syscategories where category_class = 1 and category_type = 1 and name ='betl'
				if @category_id is null 
				begin 
					exec dbo.log @batch_id, 'ERROR', 'cannot create job category betl'
					goto footer
				end 
					
				-- select *from msdb.dbo.syscategories  where category_class = 1 and category_type = 1 and name ='betl'
			    -- EXEC msdb.dbo.sp_delete_category  @class=N'job',  @name=N'betl' ;  

				-- cleanup any not running jobs. 
				-- i.e. jobs that are created more than a minute ago and are not running. 
				-- jobs are created in a transaction, so there should not be a partially created job
				-- but to be sure we added a check on the last step ( set servername). 
				set @tmp_sql = '' 
				select @tmp_sql += 'exec msdb.dbo.sp_delete_job @job_id='''+ convert(varchar(255), j.job_id) + '''' + @nl
				from msdb.dbo.sysjobs j
				inner join msdb.sys.servers s on j.originating_server_id = s.server_id
				left join msdb.dbo.sysjobactivity AS a ON a.job_id = j.job_id
				where category_id = @category_id and j.name like @proc_name_pattern+ '%'
				and not ( a.start_execution_date IS not NULL and a.stop_execution_date IS NULL)  -- not running 
				and datediff(second, j.date_created, getdate()) > @proc_dead_time_sec
				and s.name = @@servername

				if isnull(@tmp_sql,'')  <> ''
				begin
					exec dbo.log @batch_id, 'info', @tmp_sql
					exec [dbo].[exec_sql] @batch_id, @tmp_sql, 'msdb'
				end
				-- try to create job, but wait for a proc to finish when @cnt_procs >= @proc_max_cnts (maximum @proc_max_wait_time_min seconds)
				set @wait_time_sec = 0 
				select @cnt_procs = count(*)  
				from msdb.dbo.sysjobs
				where category_id = @category_id and name like @proc_name_pattern + '%'

				while @wait_time_sec < @proc_max_wait_time_sec and @cnt_procs >= @proc_max_cnt
				begin 
					exec dbo.log @batch_id, 'PROGRESS', 'Waiting ? seconds for a process to finish', @proc_polling_interval_sec
					RAISERROR ('Waiting...', 0, 1) WITH NOWAIT
					
					WAITFOR DELAY @time_str 
					set @wait_time_sec += @proc_polling_interval_sec; 

					select @cnt_procs = count(*)  
					from msdb.dbo.sysjobs
					where category_id = @category_id and name like @proc_name_pattern+ '%'
				end 

				exec dbo.log @batch_id, 'INFO', 'procs ?,max ?,wait time ?,max ?, polling_interval ?', @cnt_procs, @proc_max_cnt, @wait_time_sec , @proc_max_wait_time_sec, @proc_polling_interval_sec
				
				if @cnt_procs < @proc_max_cnt
				begin

					-- create sql agent job 
					set @job_name = @proc_name_pattern  + 	format(getdate(), 'yyyy_MM_dd_HH_mm_ss_') + convert(varchar(255), @batch_id) + '_'+convert(Varchar(255), newid() ) 
					exec dbo.log @batch_id, 'INFO', 'create job ?', @job_name 

					BEGIN TRANSACTION
					EXEC @result =  msdb.dbo.sp_add_job @job_name=@job_name, 
							@enabled=1, 
							@notify_level_eventlog=0, 
							@notify_level_email=0, 
							@notify_level_netsend=0, 
							@notify_level_page=0, 
							@delete_level=0, 
							@description='betl auto created job',
							@category_name='betl', 
							@job_id = @job_id OUTPUT
					IF (@@ERROR <> 0 OR @result <> 0) 
					begin
						exec dbo.log @batch_id, 'ERROR', 'Error creating job ? , ?', @job_name, @cnt_procs
					end
					else
					begin 
						exec dbo.log @batch_id, 'INFO', 'Job ?(?) created. Other procs running: ?', @job_name, @job_id , @cnt_procs
					end 
					
					-- for some reason jobs. skip the set options of e.g. views. 
					-- this may result in errors like: SELECT failed because the following SET options have incorrect settings: 'QUOTED_IDENTIFIER'. 
					set @sql = 'SET ANSI_NULLS ON' + @nl + 'GO'+ @nl + 'SET QUOTED_IDENTIFIER ON'+ @nl+ 'GO' + @nl+ @sql 

					EXEC @result = msdb.dbo.sp_add_jobstep @job_id=@job_id, @step_name=N'exec betl sql', 
						@step_id=1, 
						@cmdexec_success_code=0, 
						@subsystem = N'TSQL',  
						@command = @sql,   
    					@retry_attempts=0, 
						@retry_interval=0, 
						@os_run_priority=0, 
						@database_name=@trg_db_name , 
						@on_success_action=3, -- go to next step
						@on_fail_action=3, -- also go to next step
						@flags=0
					IF (@@ERROR <> 0 OR @result <> 0) 
					begin
						exec dbo.log @batch_id, 'ERROR', 'Error creating job step exec sql for job ? ', @job_id
					end

					set @tmp_sql = 'exec msdb.dbo.sp_delete_job @job_id=''' + convert(varchar(255),@job_id)+''''
					EXEC @result = msdb.dbo.sp_add_jobstep @job_id=@job_id, @step_name=N'delete myself', 
						@step_id=2, 
						@cmdexec_success_code=0, 
						@subsystem = N'TSQL',  
						@command = @tmp_sql,
    					@retry_attempts=0, 
						@retry_interval=0, 
						@os_run_priority=0, 
						@database_name='master' , 
						@flags=0
					IF (@@ERROR <> 0 OR @result <> 0) 
					begin
						exec dbo.log @batch_id, 'ERROR', 'Error creating job step to delete myself for job ? ', @job_id
					end

					EXEC @result =  msdb.dbo.sp_add_jobserver @job_id=@job_id, 
						@server_name = @@servername

					COMMIT TRANSACTION 
					-- start the job
				
					EXEC @result = msdb.dbo.sp_start_job @job_id=@job_id
					if @result<> 0 
						exec dbo.log @batch_id, 'error', 'error starting job ? using msdb.dbo.sp_start_job. note that sp_start_job errors cannot be caught, but are printed when executed from ssms', @job_id

				end 
				else
				begin 
					exec dbo.log @batch_id, 'ERROR', 'Waited for ? seconds, but no process finished', @wait_time_sec
					goto footer
				end
*/
print 'not supported in azure'
			end -- @async =1

	
			footer:

		end try 
		begin catch
				set @msg  =ERROR_MESSAGE() 
				set @sev = ERROR_SEVERITY()
				set @number = ERROR_NUMBER() 
				IF @@trancount > 0 ROLLBACK TRANSACTION
				exec dbo.log_error @batch_id=@batch_id, @msg=@msg,  @severity=@sev, @number=@number
				print '-- exec_sql caught error in the following sql statement:'
				print @sql_statement
				if @result =0 
					set @result = -1
		end catch 

		CLOSE cur;  
		DEALLOCATE cur;  
	end

	if @result is null 
		set @result =-2
	
	if @result <> 0 
		RAISERROR(@msg , @sev ,@number)  WITH NOWAIT
	return @result 
END