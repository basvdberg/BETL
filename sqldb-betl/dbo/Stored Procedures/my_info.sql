	  
/*------------------------------------------------------------------------------------------------
-- BETL, meta data driven ETL generation, licensed under GNU GPL https://github.com/basvdberg/BETL 
--------------------------------------------------------------------------------------------------
-- 2012-03-02 BvdB this proc prints out all user bound properties / settings 
exec [dbo].[my_info]
*/
CREATE PROCEDURE [dbo].[my_info]
	@batch_id as int=-1
AS
BEGIN
	-- standard BETL header code... 
	set nocount on 
	declare  
		@nesting as smallint
		, @proc_name as varchar(255) =  object_name(@@PROCID);
	exec dbo.log @batch_id, 'header', '? ', @proc_name 
	-- END standard BETL header code... 

	declare @output as varchar(max) = ''-- '-- Properties for '+ suser_sname() + ': 
	--exec dbo.log @batch_id, 'INFO', 'Properties for ? : ', suser_sname() 

	set @nesting = @@NESTLEVEL
	if @nesting > 2 set @nesting+=-2 else set @nesting=0 -- nesting always starts at 2  ( because there is always one calling proc that calls the log proc). 

--	exec dbo.getp 'nesting' , @nesting output
	select @output += replicate('  ', @nesting)+'-- ' +  isnull(property,'?') + ' = ' + isnull(value, '?') + '
'
	from dbo.Prop_ext
--	cross apply dbo.log 'footer', 'DONE ? ', @proc_name 
	where [full_obj_name] = suser_sname() 
	print @output 
    footer:
	exec dbo.log @batch_id, 'footer', 'DONE ? ', @proc_name 
END