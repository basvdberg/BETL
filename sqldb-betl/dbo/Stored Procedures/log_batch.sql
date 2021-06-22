
	  
/*------------------------------------------------------------------------------------------------
-- BETL, meta data driven ETL generation, licensed under GNU GPL https://github.com/basvdberg/BETL 
--------------------------------------------------------------------------------------------------
-- 2019-12-05 BvdB wrapper to write batch related logging. first param is batch_id instead of batch_id
*/
CREATE PROCEDURE [dbo].[log_batch](
--	  @log_level smallint
	@batch_id as int=-1
	 ,@log_type varchar(50)  -- ERROR, WARN, INFO, DEBUG
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
	exec dbo.log 
	    @log_type =@log_type
		, @msg =@msg 
		, @i1 =@i1 
		, @i2 = @i2 
		, @i3 = @i3
		, @i4 = @i4
		, @i5 = @i5
		, @i6 = @i6
		, @i7 = @i7
		, @simple_mode = @simple_mode 
		, @batch_id = @batch_id 

END