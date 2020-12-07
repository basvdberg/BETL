	  
/*
------------------------------------------------------------------------------------------------
-- BETL, meta data driven ETL generation, licensed under GNU GPL https://github.com/basvdberg/BETL 
--------------------------------------------------------------------------------------------------
-- 2017-09-06 BvdB get user scope variables. Implement caching. 
-- nesting is DEPRECATED. Use @@NESTLEVEL instead

declare @log_level varchar(255)
, @exec_sql as bit
exec get_user_vars @log_level output, @exec_sql output

*/
CREATE PROCEDURE [dbo].[get_user_vars] 
	@log_level varchar(255) output
	, @exec_sql bit output
	, @transfer_id as int = -1
as

BEGIN

	-- standard BETL header code. perform some logging.
	set nocount on 
	declare 
		@proc_name as varchar(255) = object_name(@@PROCID)
		, @cache_hit as bit=0;
	-- prevent cyclic error
	--exec dbo.log @transfer_id, 'header_detail', '?', @proc_name
	-- END standard BETL header code... 
	begin try
	begin transaction 
		select @log_level=log_level, @exec_sql=exec_sql, @cache_hit = 1 
		from dbo.Cache_user_data
		where user_name = suser_sname() and expiration_dt > getdate() 

		if @cache_hit=0
		begin
			delete from  dbo.Cache_user_data where user_name = suser_sname()

		 	exec dbo.getp 'log_level', @log_level output 
			exec dbo.getp 'exec_sql' , @exec_sql output
	
			insert into dbo.Cache_user_data ( user_name, log_level, exec_sql, expiration_dt) values ( suser_sname(), @log_level , @exec_sql , dateadd(hour,1,getdate()) ) 
		end
		--else 			print 'cache hit'

		-- prevent null values. e.g. when 
		set @log_level= isnull(@log_level, 'INFO')
		set @exec_sql = isnull(@exec_sql, 1) 


	commit transaction 
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
                ROLLBACK TRANSACTION
		declare @msg as varchar(255) = 'error in [get_user_vars]' +  isnull( ERROR_MESSAGE() , '?') 
		, @sev as int = ERROR_SEVERITY()
		-- , @number as int = ERROR_NUMBER() 

		RAISERROR(@msg  , @sev , 0)  WITH NOWAIT

	END CATCH 

	-- standard BETL footer code... 
    --footer:
	-- prevent cyclic error
	--exec dbo.log @transfer_id, 'footer_detail', 'DONE ?', @proc_name 
	-- END standard BETL footer code... 
	return 1
END