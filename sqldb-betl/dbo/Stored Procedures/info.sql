	  
/*------------------------------------------------------------------------------------------------
-- BETL, meta data driven ETL generation, licensed under GNU GPL https://github.com/basvdberg/BETL 
--------------------------------------------------------------------------------------------------
-- 2012-03-02 BvdB 
exec dbo.info '[My_PC].[AdventureWorks2014]', 'AW'
exec dbo.info 
*/
CREATE PROCEDURE [dbo].[info]
    @full_obj_name as varchar(255) =''
	, @transfer_id as int = -1
AS
BEGIN
	-- standard BETL header code... 
	set nocount on 
	declare  @proc_name as varchar(255) =  object_name(@@PROCID);
	exec dbo.log @transfer_id, 'header', '? ? ? ?', @proc_name , @full_obj_name,  @transfer_id
	-- END standard BETL header code... 
	declare @obj_id as int
			, @obj_name as varchar(255) 
			, @search as varchar(255) 
	--exec dbo.refresh @full_obj_name 
	--Set @obj_id = dbo.obj_id(@full_obj_name) 
	--if @obj_id is null 
	--	exec show_error 'Object ? not found ', @full_obj_name
	--else 
	--	exec dbo.log @transfer_id, 'INFO', 'obj_id ?', @obj_id 
	print 'test'	
	set @search = replace (@full_obj_name, @@SERVERNAME , 'LOCALHOST') 
	declare @replacer as ParamTable
	insert into @replacer values ( '[', '![')
	insert into @replacer values ( ']', '!]')
	insert into @replacer values ( '_', '!_')
	
	SELECT @search = REPLACE(@search, param_name, convert(varchar(255), param_value) )
	FROM @replacer;
	set @search  ='%%'+ @search +'%%'
	exec dbo.log @transfer_id, 'step', 'Searching ?', @search 
	declare @objects Table(
		obj_id int primary key
	) 
	insert into @objects 
	select o.obj_id
	from dbo.obj_ext o
	LEFT OUTER JOIN [dbo].[Obj] AS parent_o ON o.parent_id = parent_o.[obj_id] 
	LEFT OUTER JOIN [dbo].[Obj] AS grand_parent_o ON parent_o.parent_id = grand_parent_o.[obj_id] 
	LEFT OUTER JOIN [dbo].[Obj] AS great_grand_parent_o ON grand_parent_o.parent_id = great_grand_parent_o.[obj_id] 
	where ( o.full_obj_name like @search  ESCAPE '!'  or @search is null or @search = ''
	or 
	case when o.obj_type in ( 'user', 'server') then o.[obj_name] else 
		ISNULL( case when o.[server_name]<>'LOCALHOST'then o.[server_name] else null end  + '.', '') -- don't show localhost
		+ ISNULL( o.[db_name] , '') 
		+ ISNULL('.' + o.[schema_name] , '') 
		+ ISNULL('.' + o.schema_object , '') end  --full_obj_name_no_brackets
		like @search  ESCAPE '!'  
	) 
	

	select o.* 
	from dbo.obj_ext o 
	inner join @objects os on o.obj_id = os.obj_id
	order by o.obj_id
	select c.*
	from [dbo].[Col_ext] c
	inner join @objects os on os.obj_id = c.obj_id
	order by c.ordinal_position asc
	select p.*
	from [dbo].[Prop_ext] p
	inner join @objects os on os.obj_id = p.obj_id
	order by p.obj_id, p.property

    footer:
	exec dbo.log @transfer_id, 'footer', 'DONE ? ? ? ?', @proc_name , @full_obj_name, @transfer_id
END