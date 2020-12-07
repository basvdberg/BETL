/*------------------------------------------------------------------------------------------------
-- BETL, meta data driven ETL generation, licensed under GNU GPL https://github.com/basvdberg/BETL 
--------------------------------------------------------------------------------------------------
-- 2017-01-01 BvdB set property value
exec dbo.setp 'log_level', 'debug'
select * from dbo.Prop_ext
*/
create PROCEDURE [dbo].[setp_obj_id] 
	@prop_id int
	, @value varchar(255)
	, @obj_id int = null -- when property relates to a persistent object, otherwise leave empty
	, @transfer_id as int = -1 -- use this for logging. 
as 
begin 
  -- first determine property_scope 
  declare @property_scope as varchar(255) 
		, @debug as bit = 0
	-- standard BETL header code... 
	set nocount on 
	declare @proc_name as varchar(255) =  object_name(@@PROCID);
	if @debug=1 
		exec dbo.log @transfer_id =@transfer_id, @log_type ='header', @msg ='? ? ? for ?', @i1 =@proc_name , @i2 =@prop_id, @i3 =@value, @i4=@obj_id, @simple_mode = 1
	-- END standard BETL header code... 

	begin try 
		begin transaction 
			-- delete any existing value. 
			delete from dbo.Property_Value 
			where obj_id = @obj_id and property_id = @prop_id 
			
			insert into dbo.Property_Value ( property_id, [obj_id], value) 
			values (@prop_id , @obj_id, @value)

			-- invalidate the entire user cache. So that it gets refreshed next time. 
			update dbo.Cache_user_data set expiration_dt = getdate() 
			where user_name = suser_sname() and expiration_dt  > getdate()  -- only when set in the future

		commit transaction
	end try 
	begin catch
		declare @msg as varchar(4000) 
		set @msg = ERROR_MESSAGE() 
		if @@TRANCOUNT>0 
			rollback transaction
		exec dbo.log @transfer_id, 'ERROR', 'msg ? ', @msg
	end catch 

--	select * from [dbo].[Property_ext]	where obj_id = @obj_id and property like @prop
    footer:
		if @debug=1 
		exec dbo.log @transfer_id =@transfer_id, @log_type ='footer', @msg ='? ? ? for ?', @i1 =@proc_name , @i2 =@prop_id, @i3 =@value, @i4=@obj_id, @simple_mode = 1
	-- END standard BETL footer code... 
end