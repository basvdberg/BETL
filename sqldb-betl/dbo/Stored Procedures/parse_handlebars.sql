CREATE procedure [dbo].[parse_handlebars] 
	@full_obj_name as sysname
	, @template_name as varchar(255)
	, @batch_id as int =-1 
	, @output as varchar(max) =''	OUTPUT  
	, @output_result as bit = 1

as 
begin
	-- BEGIN standard BETL header code
	declare @proc_name as sysname =  object_name(@@PROCID)
	set nocount on 
	exec dbo.log @batch_id, 'HEADER', '? @full_obj_name=?, @batch_id=?', @proc_name , @full_obj_name, @batch_id
	-- END standard BETL header code

	declare @obj_id as int 
		,	@sql as varchar(max)

	if @full_obj_name is null
	begin
		exec log @batch_id, 'ERROR', '@full_obj_name is null'
		goto footer
	end

	select @obj_id = dbo.obj_id(@full_obj_name)
	if @obj_id is null
	begin
		exec log @batch_id, 'ERROR', 'object with name=? cannot be found', @full_obj_name
		goto footer
	end

	exec dbo.parse_handlebars_obj_id  @obj_id, @template_name ,@batch_id, @output = @sql OUTPUT, @output_result=0;

	footer:
	select @sql _output
	-- BEGIN standard BETL footer code
	exec dbo.log @batch_id, 'FOOTER', '?(t?)', @proc_name , @batch_id
	-- END standard BETL footer code
end