
/*------------------------------------------------------------------------------------------------
-- BETL, meta data driven ETL generation, licensed under GNU GPL https://github.com/basvdberg/BETL 
--------------------------------------------------------------------------------------------------
-- 2017-01-01 BvdB return schema name of this full object name 
-- e.g. My_PC.AdventureWorks2014.Person.Sales ->My_PC.AdventureWorks2014.Person
select util.obj_name('My_PC.AdventureWorks2014.Person.Sales') --> points to table 
*/
CREATE FUNCTION [util].[obj_name]( @fullObj_name varchar(255) ) 
RETURNS varchar(255) 
AS
BEGIN
-- standard BETL header code... 
--set nocount on 
--declare   @debug as bit =1
--		, @progress as bit =1
--		, @proc_name as varchar(255) =  object_name(@@PROCID);
--exec dbo.get_var 'debug', @debug output
--exec dbo.get_var 'progress', @progress output
--exec progress @progress, '? ?,?', @proc_name , @fullObj_name
-- END standard BETL header code... 
	--declare @fullObj_name varchar(255)= 'Tim_DWH.L2.Location'
	declare @t TABLE (item VARCHAR(8000), i int)
	declare  
	     @elem1 varchar(255)
	     ,@elem2 varchar(255)
	     ,@elem3 varchar(255)
	     ,@elem4 varchar(255)
		, @cnt_elems int 
		, @obj_id int 
		, @remove_chars varchar(255)
		, @cnt as int 
		 
	set @remove_chars = replace(@fullObj_name, '[','')
	set @remove_chars = replace(@remove_chars , ']','')
	
	insert into @t 
	select * from util.split(@remove_chars , '.') 
	--select * from @t 
	-- @t contains elemenents of fullObj_name 
	-- can be [server].[db_name].[schema_name].[table|view]
	-- as long as it's unique 
	select @cnt_elems = MAX(i) from @t	
	select @elem1 = item from @t where i=@cnt_elems
	select @elem2 = item from @t where i=@cnt_elems-1
	select @elem3 = item from @t where i=@cnt_elems-2
	select @elem4 = item from @t where i=@cnt_elems-3
	--select @obj_id= max(o.obj_id), @cnt = count(*) 
	--from dbo.[Obj] o
	--LEFT OUTER JOIN dbo.[Obj] AS parent_o ON o.parent_id = parent_o.[obj_id] 
	--LEFT OUTER JOIN dbo.[Obj] AS grand_parent_o ON parent_o.parent_id = grand_parent_o.[obj_id] 
	--LEFT OUTER JOIN dbo.[Obj] AS great_grand_parent_o ON grand_parent_o.parent_id = great_grand_parent_o.[obj_id] 
	--where 	o.[obj_name] = @elem2
	--and ( @elem3 is null or parent_o.[obj_name] = @elem3) 
	--and ( @elem4 is null or grand_parent_o.[obj_name] = @elem4) 
	declare @res as varchar(255) 
	--if @cnt >1 
	--	set @res =  -@cnt
	--else 
	--	set @res =@obj_id 
	set @res = '[' + @elem1 + ']'
	return @res 
END