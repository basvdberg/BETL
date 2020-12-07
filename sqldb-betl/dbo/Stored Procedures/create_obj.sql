	  

/*---------------------------------------------------------------------------------------------
BETL, meta data driven ETL generation, licensed under GNU GPL https://github.com/basvdberg/BETL
-----------------------------------------------------------------------------------------------
-- 2018-04-09 BvdB creates record in dbo.obj
select * from dbo.obj_ext
  
exec dbo.create_obj @obj_name = 'ssas01.company.nl', @obj_type = 'server', @server_type_id = 20
	, @is_linked_server =0
select * from dbo.obj_ext
*/ 
CREATE procedure [dbo].[create_obj] @obj_name as varchar(255), @obj_type as varchar(255) , @server_type_id as int, @is_linked_server as bit=0 , @transfer_id as int = 0 as 
begin 
	set nocount on 
	declare 
		@sql as varchar(max) = ''
		, @p as ParamTable
		, @obj_type_id as int 
	-- standard BETL header code... 
	declare   @proc_name as varchar(255) =  object_name(@@PROCID);
	exec dbo.log @transfer_id, 'header', '? ?(?) ', @proc_name , @obj_name, @obj_type_id
	set @obj_type_id = dbo.const(@obj_type) 
	if not exists ( select * from dbo.server_type where server_type_id = isnull(@server_type_id,0) ) 
	begin
		exec dbo.log @transfer_id, 'error',  'Invalid server_type_id ?.', @server_type_id
		goto footer
	end 
	if isnull(@obj_type_id,0)  not in ( 50) 
	begin
		exec dbo.log @transfer_id, 'error',  'obj_type ?(?) must be created using a dbo.refresh of a parent object.', @obj_type, @obj_type_id
		goto footer
	end 
	if exists (select * from dbo.obj where obj_type_id = @obj_type_id and [obj_name] = @obj_name and server_type_id = @server_type_id) 
	begin 
		exec dbo.log @transfer_id, 'info',  'Object already exists ?(?) .', @obj_name , @obj_type_id
		goto footer
	end 
	if @obj_type_id = 50 and @server_type_id =20 -- ssas server
	begin
		set @obj_name = replace( @obj_name ,'[','')
		set @obj_name = replace( @obj_name ,']','')
		if @is_linked_server = 1
		begin
			exec dbo.log @transfer_id, 'info',  'Trying to connect to linked server ? ', @obj_name 
			
			set @sql ='
				select count(*) cnt from openquery(<server> , 
				"select [CATALOG_NAME], [date_modified] from  $System.DBSCHEMA_CATALOGS"
				) 
				'
			delete from @p
			insert into @p values ('server'					, @obj_name) 
			EXEC util.apply_params @sql output, @p
			DECLARE @CountResults TABLE (CountReturned INT)
			insert @CountResults 
			exec(@sql) 
			
			if not exists ( select * from  @CountResults ) 
			begin
				exec dbo.log @transfer_id, 'error',  'Failed to connect to linked server, please check for example credentials...'
				goto footer
			end else
				exec dbo.log @transfer_id, 'info',  'Connection to linked server ? successfull.', @obj_name 
		end 
	end
	insert into dbo.obj ([obj_type_id], [obj_name] , server_type_id) 
	values ( @obj_type_id, @obj_name, @server_type_id) 

	exec dbo.log @transfer_id, 'info',  'Object ?(?:?) created.', @obj_name , @obj_type_id, @server_type_id
	footer:
	-- standard BETL footer code... 
	exec dbo.log @transfer_id, 'footer', '? ?(?) ', @proc_name , @obj_name, @obj_type_id
end