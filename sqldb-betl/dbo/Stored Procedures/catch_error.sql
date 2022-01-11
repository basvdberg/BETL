/*------------------------------------------------------------------------------------------------
-- BETL, meta data driven ETL generation, licensed under GNU GPL https://github.com/basvdberg/BETL 
--------------------------------------------------------------------------------------------------
-- 2022-01-11 BvdB added to handle the scenario where a rollback takes place, but you want to keep the logging
*/

CREATE PROCEDURE [dbo].[catch_error]
	@batch_id as int 
	, @proc_name as varchar(255) 
AS
BEGIN
		declare @msg2 as varchar(255) =ERROR_MESSAGE() 
				, @sev as int = ERROR_SEVERITY()
				, @number as int = ERROR_NUMBER() 
		
		-- save the logging and batch table from the rollback...
		declare @Logging as table ( 
			[log_dt] [datetime] NULL,
			[msg] [varchar](max) NULL,
			[batch_id] [int] NULL,
			[log_level_id] [smallint] NULL,
			[log_type_id] [smallint] NULL,
			[exec_sql] [bit] NULL
			) 
	   declare @Batch as table (
	   		[batch_id] [int] NOT NULL,
			[batch_name] [nvarchar](128) NULL,
			[parent_batch_id] [int] NULL,
			[batch_start_dt] [datetime] NULL,
			[batch_end_dt] [datetime] NULL,
			[status_id] [int] NULL,
			[last_error_id] [int] NULL,
			[prev_batch_id] [int] NULL,
			[exec_server] [nvarchar](128) NULL,
			[exec_host] [nvarchar](128) NULL,
			[exec_user] [nvarchar](128) NULL,
			[guid] [nvarchar](255) NULL,
			[continue_batch] [bit] NULL,
			[batch_seq] [int] NULL
	  ) 

		insert 
		into @Logging ( log_dt, msg,batch_id,log_level_id, log_type_id, exec_sql) 
		select log_dt, msg,batch_id,log_level_id, log_type_id, exec_sql from Logging where batch_id = @batch_id 

		INSERT INTO @Batch
           ([batch_id]
		   ,[batch_name]
           ,[parent_batch_id]
           ,[batch_start_dt]
           ,[batch_end_dt]
           ,[status_id]
           ,[last_error_id]
           ,[prev_batch_id]
           ,[exec_server]
           ,[exec_host]
           ,[exec_user]
           ,[guid]
           ,[continue_batch]
           ,[batch_seq])
		select  [batch_id]
      ,[batch_name]
      ,[parent_batch_id]
      ,[batch_start_dt]
      ,[batch_end_dt]
      ,[status_id]
      ,[last_error_id]
      ,[prev_batch_id]
      ,[exec_server]
      ,[exec_host]
      ,[exec_user]
      ,[guid]
      ,[continue_batch]
      ,[batch_seq]
		from Batch where batch_id = @batch_id 


		IF @@TRANCOUNT > 0                ROLLBACK TRANSACTION

		set identity_insert dbo.Batch on 
		INSERT INTO dbo.Batch
           ([batch_id]
		   , [batch_name]
           ,[parent_batch_id]
           ,[batch_start_dt]
           ,[batch_end_dt]
           ,[status_id]
           ,[last_error_id]
           ,[prev_batch_id]
           ,[exec_server]
           ,[exec_host]
           ,[exec_user]
           ,[guid]
           ,[continue_batch]
           ,[batch_seq])
		select  [batch_id]
      ,[batch_name]
      ,[parent_batch_id]
      ,[batch_start_dt]
      ,[batch_end_dt]
      ,[status_id]
      ,[last_error_id]
      ,[prev_batch_id]
      ,[exec_server]
      ,[exec_host]
      ,[exec_user]
      ,[guid]
      ,[continue_batch]
      ,[batch_seq]
		from @Batch 
		set identity_insert dbo.Batch off

		insert into dbo.Logging ( log_dt, msg,batch_id,log_level_id, log_type_id, exec_sql) 
		select log_dt, msg,@batch_id ,log_level_id, log_type_id, exec_sql from @Logging -- set batch_id to -1 because batches are rollbacked as well

		exec dbo.log_error @batch_id = @batch_id , @msg=@msg2,  @severity=@sev, @number=@number , @procedure=@proc_name
		
END