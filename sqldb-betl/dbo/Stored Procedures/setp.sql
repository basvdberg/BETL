/*------------------------------------------------------------------------------------------------
-- BETL, meta data driven ETL generation, licensed under GNU GPL https://github.com/basvdberg/BETL 
--------------------------------------------------------------------------------------------------
-- 2017-01-01 BvdB set property value
exec dbo.setp 'log_level', 'debug'
select * from dbo.Prop_ext
*/
CREATE PROCEDURE [dbo].[setp] 
	@prop varchar(255)
	, @value varchar(255)
	, @full_obj_name varchar(255) = null -- when property relates to a persistent object, otherwise leave empty
	, @batch_id as int = -1 -- use this for logging. 
as 
begin 
  -- first determine property_scope 
  declare @property_scope as varchar(255) 
		, @obj_id int
		, @prop_id as int 
		, @debug as bit = 1
	-- standard BETL header code... 
	set nocount on 
	declare @proc_name as varchar(255) =  object_name(@@PROCID);
	if @debug=1 
		exec dbo.log @batch_id =@batch_id, @log_type ='header', @msg ='? ? ? for ?', @i1 =@proc_name , @i2 =@prop, @i3 =@value, @i4=@full_obj_name, @simple_mode = 1
	-- END standard BETL header code... 

  select @property_scope = property_scope , @prop_id = property_id
  from dbo.Prop_ext
  where [property]=@prop
  if @prop_id is null 
  begin 
	print 'Property not found in static.Property '
	exec dbo.log @batch_id =@batch_id, @log_type ='error', @msg ='Property ? not found in static.Property ', @i1 =@prop, @simple_mode = 1
	goto footer
  end
  if @property_scope is null 
  begin 
	print 'Property scope is not defined in static.Property'
	exec dbo.log @batch_id =@batch_id, @log_type ='error', @msg ='Property scope ? defined in static.Property', @i1 =@prop, @simple_mode = 1
	goto footer
  end

  -- scope is not null 
  if @property_scope = 'user' -- then we need the obj_id of the current user
  begin
	set @full_obj_name = suser_sname()
  end
  exec [dbo].[get_obj_id] @full_obj_name, @obj_id output, @batch_id=@batch_id

  if @obj_id  is null 
  begin 
	if @property_scope = 'user' -- then create obj_id 
	begin
		insert into dbo.Obj (obj_type_id, obj_name, parent_id, server_type_id ) 
		values (60, @full_obj_name, 10, dbo.server_type())
		-- 10 is localhost
			
		exec [dbo].[get_obj_id] @full_obj_name, @obj_id output, @batch_id=@batch_id	
	end

	if @obj_id is null 
	begin
		if @debug =1 
			exec dbo.log @batch_id, 'ERROR', 'object not found ? , property_scope ? ', @full_obj_name , @property_scope
		goto footer
	end 
  end

	if @debug =1 
		exec dbo.log @batch_id, 'var', 'object ? (?) , property_scope ? ', @full_obj_name, @obj_id , @property_scope 
		
	exec setp_obj_id @prop_id, @value, @obj_id, @batch_id 

--	select * from [dbo].[Property_ext]	where obj_id = @obj_id and property like @prop
    footer:
		if @debug=1 
		exec dbo.log @batch_id =@batch_id, @log_type ='footer', @msg ='done ? ? ? for ?', @i1 =@proc_name , @i2 =@prop, @i3 =@value, @i4=@full_obj_name, @simple_mode = 1
	-- END standard BETL footer code... 
end