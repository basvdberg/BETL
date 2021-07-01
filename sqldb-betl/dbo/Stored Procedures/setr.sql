
/*------------------------------------------------------------------------------------------------
-- BETL, meta data driven ETL generation, licensed under GNU GPL https://github.com/basvdberg/BETL 
--------------------------------------------------------------------------------------------------
-- 2020-07-30 BvdB associate a business rule to a column, object or (foreign key) link.

exec dbo.setr 500, 'gvb', 'gvb_reg_datum'
select * from dbo.Rule_mapping

*/

CREATE PROCEDURE [dbo].[setr] 
	@rule_id int
	, @obj_name sysname
	, @column_name sysname = null 
	, @batch_id as int = -1 -- use this for logging. 
	, @schema_name sysname = 'idw_imp' 

as 
begin 
  -- first determine property_scope 
  declare 
		 @obj_id int
		, @lookup_rule_id as int 
		, @debug as bit = 0
		, @col_id as int

	-- standard BETL header code... 
	set nocount on 
	declare @proc_name as varchar(255) =  object_name(@@PROCID);
	if @debug=1 
		exec dbo.log @batch_id =@batch_id, @log_type ='header', @msg ='? ? ? ? ?', @i1 =@proc_name , @i2 =@rule_id, @i3 =@obj_id, @i4=@column_name, @i5=@schema_name, @simple_mode = 1
	-- END standard BETL header code... 

  select @lookup_rule_id = rule_id
  from static.[Rule]
  where rule_id= @rule_id 

  if @lookup_rule_id is null 
  begin 
	print 'Rule not found in static.Rule '
	exec dbo.log @batch_id =@batch_id, @log_type ='error', @msg ='Rule ? not found in static.Rule ', @i1 =@rule_id, @simple_mode = 1
	goto footer
  end

  select @obj_id = obj_id 
  from dbo.Obj_ext
  where obj_name = @obj_name and schema_name = @schema_name
  and _delete_dt is null 
  
  if @obj_id is null 
  begin 
	print 'Object not found'
	exec dbo.log @batch_id =@batch_id, @log_type ='error', @msg ='Object ?.? not found in dbo.col_ext ', @i1=@schema_name, @i2 =@obj_name , @simple_mode = 1
	goto footer
  end

  select @col_id = column_id
  from dbo.Col
  where obj_id = @obj_id and column_name = @column_name 
  and ( _delete_dt is null  ) 

  if @column_name is null 
	set @col_id = -1 -- when no column name is specified the rule applies to the entire object. column_id is set to -1 in this case

  if @col_id is null 
  begin 
	print 'Column not found'
	exec dbo.log @batch_id =@batch_id, @log_type ='error', @msg ='Column ?.?.? not found in dbo.col_ext ', @i1=@schema_name, @i2 =@obj_name ,@i3=@column_name, @simple_mode = 1
	goto footer
  end

  if not exists ( select 1 from dbo.Rule_mapping where rule_id = @rule_id and obj_id = @obj_id and column_id = @col_id ) 
	insert into dbo.Rule_mapping([rule_id], obj_id, column_id) 
	values(  @rule_id  , @obj_id  , @col_id   )
	
--	select * from [dbo].[Property_ext]	where obj_id = @obj_id and property like @prop
    footer:
		if @debug=1 
		exec dbo.log @batch_id =@batch_id, @log_type ='footer', @msg ='done ? ? ? ? ?', @i1 =@proc_name , @i2 =@rule_id, @i3 =@obj_id, @i4=@column_name, @i5=@schema_name, @simple_mode = 1
	-- END standard BETL footer code... 
end