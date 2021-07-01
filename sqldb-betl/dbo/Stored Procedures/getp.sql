
/*------------------------------------------------------------------------------------------------
-- BETL, meta data driven ETL generation, licensed under GNU GPL https://github.com/basvdberg/BETL 
--------------------------------------------------------------------------------------------------
-- 2017-01-01 BvdB get property value
declare @value varchar(255) 
exec dbo.getp 'log_level', @Value output 
print 'loglevel' + isnull(@Value,'?')

declare @batch_max_lifetime as varchar(255) -- after this period of inactivity the batch will be seen as stopped.. 
exec dbo.getp 'batch_max_lifetime', @batch_max_lifetime output
print @batch_max_lifetime 


select * from dbo.prop_ext
*/
CREATE PROCEDURE [dbo].[getp]
	@prop varchar(255)
	, @value varchar(255) output 
	, @full_obj_name varchar(255) = null -- when property relates to a persistent object, otherwise leave empty
	, @batch_id as int = -1 -- use this for logging. 
as
begin
	-- first determine scope 
	declare @property_scope as varchar(255) 
		, @obj_id int
		, @prop_id as int 
		, @debug as bit = 0	-- set to 1 to debug this proc
		, @enabled as bit

	-- standard BETL header code... 
	set nocount on
	declare @proc_name as varchar(255) =  object_name(@@PROCID);
	if @debug=1 
		exec dbo.log @batch_id =@batch_id, @log_type ='header', @msg ='? ? ?', @i1 =@proc_name , @i2 =@prop, @i3 =@full_obj_name, @simple_mode = 1
	-- END standard BETL header code... 

	begin try
		select @property_scope = property_scope , @prop_id = property_id, @enabled = [enabled]
		from static.Property
		where [property_name]=@prop
		
		if @debug = 1 exec dbo.log @batch_id =@batch_id, @log_type ='var', @msg ='Property scope ?', @i1 =@property_scope, @simple_mode = 1
		if @prop_id is null 
		begin
			print 'Property not found in static.Property '
			exec dbo.log @batch_id =@batch_id, @log_type ='error', @msg ='Property ? not found in static.Property ', @i1 =@prop, @simple_mode = 1
			goto footer
		end
		if @property_scope is null 
		begin
			print 'Property scope is not defined in static.Property'
			exec dbo.log @batch_id =@batch_id, @log_type ='error', @msg ='Property scope ? is not defined in static.Property', @i1 =@prop, @simple_mode = 1
			goto footer
		end
		if isnull(@enabled,0) = 0 
		begin 
			exec dbo.log @batch_id =@batch_id, @log_type ='error', @msg ='Property ? is not enabled in static.Property', @i1 =@prop, @simple_mode = 1
		end 


		-- scope is not null 
		if @property_scope = 'user' -- then we need an obj_id 
		begin
			set @full_obj_name =  suser_sname()
		end

		select @obj_id = dbo.obj_id(@full_obj_name )
		if @debug = 1 exec dbo.log @batch_id =@batch_id, @log_type ='var', @msg ='Lookup ?(?) ', @i1 =@full_obj_name, @i2=@obj_id ,  @simple_mode = 1

		-- exec dbo.get_obj_id @full_obj_name, @obj_id output, @property_scope=DEFAULT, @recursive_depth=DEFAULT, @batch_id=@batch_id
		if @obj_id  is null 
		begin
			if @property_scope = 'user' -- then create obj_id 
			begin
				insert into dbo.Obj	(obj_type_id, obj_name)
				values(60, @full_obj_name)

				select @obj_id = dbo.obj_id(@full_obj_name)
				if @debug = 1 exec dbo.log @batch_id =@batch_id, @log_type ='var', @msg ='Created object ?(?) ', @i1 =@full_obj_name, @i2=@obj_id ,  @simple_mode = 1
			end
		else 
			begin
				if @debug = 1 exec dbo.log @batch_id =@batch_id, @log_type ='error', @msg ='object not found ?(?) ', @i1 =@full_obj_name, @i2=@obj_id ,  @simple_mode = 1
				goto footer
			end
		end

		select @value = isnull(value,default_value)
		from dbo.Prop_ext
		where property = @prop and obj_id = @obj_id

		if @debug = 1 exec dbo.log @batch_id =@batch_id, @log_type ='var', @msg ='property value ?(?) ', @i1 =@prop, @i2=@value ,  @simple_mode = 1
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION
		declare 
			@msg as varchar(255) = 'error in SP ' + ISNULL(@proc_name,'')  +':'+  isnull( ERROR_MESSAGE() , '?') 
			, @sev as int = ERROR_SEVERITY()
			
			-- , @number as int = ERROR_NUMBER() 

		RAISERROR(@msg  , @sev , 0)  WITH NOWAIT
	END CATCH 
		
	-- start standard BETL footer code... 
	footer:
	if @debug=1 exec dbo.log @batch_id =@batch_id, @log_type ='footer', @msg ='DONE ? ? ?->?', @i1 =@proc_name , @i2 =@prop, @i3 =@full_obj_name, @i4=@value, @simple_mode = 1
	-- END standard BETL footer code... 
end