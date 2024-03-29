﻿	  
/*------------------------------------------------------------------------------------------------
-- BETL, meta data driven ETL generation, licensed under GNU GPL https://github.com/basvdberg/BETL 
--------------------------------------------------------------------------------------------------
-- 2012-03-21 BvdB write to [dbo].[Transfer_log] using log hierarchy
exec dbo.log 30820, 'error', 'test'
exec dbo.log @batch_id =30820, @log_type ='error', @msg ='test', @simple_mode =1
*/
CREATE PROCEDURE [dbo].[log](
	@batch_id as int =-1
	, @log_type varchar(50)  -- ERROR, WARN, INFO, DEBUG
	, @msg as varchar(max) 
	, @i1 as varchar(max) = null
	, @i2 as varchar(max) = null
	, @i3 as varchar(max)= null
	, @i4 as varchar(max)= null
	, @i5 as varchar(max)= null
	, @i6 as varchar(max)= null
	, @i7 as varchar(max)= null
	, @simple_mode as bit = 0 -- use this to skip getp and prevent getting into a loop. 
	

)
AS
BEGIN
	SET NOCOUNT ON;
	set @batch_id = isnull(@batch_id,-1) -- default for unknown batch_id is -1 
	--declare @batch_id as int
	--exec dbo.getp 'batch_id', @batch_id output 
	declare @log_level_id smallint
			, @log_type_id smallint
			, @nesting smallint
			, @nl as varchar(2) = char(13)+char(10)
			, @min_log_level_id smallint
			, @log_level varchar(255) 
			, @exec_sql as bit
			, @short_msg AS VARCHAR(255) 
	
	set @nesting =@@NESTLEVEL

	if isnull(@simple_mode,0) = 1 
	begin 
		set @log_level = 'INFO'
		set @exec_sql= 1
	end 
	else
	begin 
		exec get_user_vars @log_level output, @exec_sql output
	end 

	--print 'nesting: '+ convert(varchar(100) , @nesting) 
	select @log_level_id = log_level_id
	from static.[Log_level]
	where log_level = @log_level
	if @log_level_id  is null 
	begin
		set @log_level_id  =30 -- info
		goto footer
		--set @short_msg  = 'invalid log_level '+isnull(@log_level, '' )
		--RAISERROR( @short_msg    ,15,1) WITH SETERROR
	end
	select @log_type_id = log_type_id, @min_log_level_id = min_log_level_id
	from static.Log_type
	where log_type = @log_type
	if 	@log_type_id = null 
	begin
		set @short_msg  = 'invalid log_type '+isnull(@log_type, '' )
		RAISERROR( @short_msg    ,15,1) WITH SETERROR
		goto footer
	end
	--print 'log_type:'+ @log_type
	--print 'log_type_id:'+ convert(varchar(255), @log_type_id) 
	--print 'log_level_id:'+ convert(varchar(255), @log_level_id) 
	--print 'min_log_level_id:'+ convert(varchar(255), @min_log_level_id) 
	--print 'nesting:'+ convert(varchar(255), @nesting) 
		
	if @log_level_id < @min_log_level_id -- e.g. level = ERROR, but type = sql -> 40 
		return -- don't log
	
	--if @nesting>4 and @log_level_id < 50 and @log_type_id not in ( 10,20) -- header, footer
		--return -- when log_level not verbose then don't log level 2 and deeper (other than header and footer).
	-- first replace ? by %1 

	declare @i as int=0
			, @j as int = 1
			,@n int = len(@msg)
	set @i = charIndex('?', @msg, @i) 
	while @i>0 
	begin
		set @msg =  SUBSTRING(@msg,1,@i-1)+ '%'+CONVERT(varchar(2), @j) +SUBSTRING(@msg,@i+1, @n-@i+1)

		set @j+= 1
		set @n = len(@msg)
		set @i = charIndex('?', @msg,@i) 
	end 
	
	if @i1 is not null and CHARINDEX('%1', @msg)=0 
		set @msg += ' @i1'
	if @i2 is not null and CHARINDEX('%2', @msg)=0 
		set @msg += ', @i2'
	if @i3 is not null and CHARINDEX('%3', @msg)=0 
		set @msg += ', @i3'
	if @i4 is not null and CHARINDEX('%4', @msg)=0 
		set @msg += ', @i4'
	if @i5 is not null and CHARINDEX('%5', @msg)=0 
		set @msg += ', @i5'
	if @i6 is not null and CHARINDEX('%6', @msg)=0 
		set @msg += ', @i6'
	if @i7 is not null and CHARINDEX('%7', @msg)=0 
		set @msg += ', @i7'
		
	set @msg = replace(@msg, '%1', isnull(convert(varchar(max), @i1), '?') )
	set @msg = replace(@msg, '%2', isnull(convert(varchar(max), @i2), '?') )
	set @msg = replace(@msg, '%3', isnull(convert(varchar(max), @i3), '?') )
	set @msg = replace(@msg, '%4', isnull(convert(varchar(max), @i4), '?') )
	set @msg = replace(@msg, '%5', isnull(convert(varchar(max), @i5), '?') )
	set @msg = replace(@msg, '%6', isnull(convert(varchar(max), @i6), '?') )
	set @msg = replace(@msg, '%7', isnull(convert(varchar(max), @i7), '?') )
	
	if @nesting > 2 set @nesting+=-2 else set @nesting=0 -- nesting always starts at 2  ( because there is always one calling proc that calls the log proc). 

	set @msg = replicate('  ', @nesting) + '-- ' + upper(@log_type) + ': '+@msg
	
	--if charindex(@nl, @msg,0) >0 -- contains nl 
	--	set	@msg = '/*'+@nl+@msg+@nl+'*/'
	--set @msg = replace(@msg, @nl , @nl + '--') -- when logging sql prefix with --
--	end
--	ELSE
--		RAISERROR(@msg,10,1) WITH NOWAIT
	-- START CUSTOM_CODE. 
	--exec MyDWH_repository.dbo.SP_SSIS_LOGMSG @batch_id, @msg
	-- END CUSTOM_CODE
	if @log_type = 'ERROR'
	begin
		exec dbo.log_error @batch_id=@batch_id, @msg=@msg, @severity=15
		--SET @short_msg = substring(@msg, 0, 255) 
		--RAISERROR( @short_msg ,15,1) WITH SETERROR
	end 
	else 
	begin 
		PRINT cast(@msg as text) -- because print is limited to 8000 characters
		
		-- troubleshoot foreign key error !
		if @batch_id=0 
			print '--ERROR batch_id should not be 0. Use -1 for unknown batch_id !'

		--IF OBJECT_ID('tempdb..#Logging') IS NULL
		--	select getdate() log_dt, @msg msg, @batch_id batch_id, @log_level_id log_level_id, @log_type_id log_type_id, @exec_sql exec_sql
		--	into #Logging
		--ELSE
		--	insert 
		--	into #Logging ( log_dt, msg,batch_id,log_level_id, log_type_id, exec_sql) 
		--	values ( getdate(), @msg, @batch_id, @log_level_id, @log_type_id, @exec_sql) 

		insert into dbo.Logging ( log_dt, msg,batch_id,log_level_id, log_type_id, exec_sql) 
		values( getdate(), @msg, @batch_id, @log_level_id, @log_type_id, @exec_sql) 


	end 

    footer:
END