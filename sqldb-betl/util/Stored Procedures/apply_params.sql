	  	  
	  
/*------------------------------------------------------------------------------------------------
-- BETL, meta data driven ETL generation, licensed under GNU GPL https://github.com/basvdberg/BETL 
--------------------------------------------------------------------------------------------------
-- 2017-01-01 BvdB replaces parameters in a string by it's value
Declare @p as ParamTable
,	@sql as varchar(8000) = 'select <aap> from <wiz> where <where>="nice" '
insert into @p values ('aap', 9)
insert into @p values ('wiz', 'woz')
print @sql 
EXEC util.apply_params @sql output , @p
print @sql 
*/
CREATE PROCEDURE [util].[apply_params]
	@sql as nvarchar(max) output
	, @params as ParamTable readonly
	, @apply_defaults as bit = 1 
	as
BEGIN
	declare 
		@nl as varchar(2) = CHAR(13) + CHAR(10)
	declare
		@tmp as varchar(max) ='-- [apply_params]'+@nl
	SET NOCOUNT ON;

	--if @progress =1 
	--begin
	--	select @tmp += '-- '+ param_name + ' : '+ replace(isnull(convert(varchar(max), p.param_value), '?'), @nl, @nl+'--')   + @nl  
	--	from @params p
	--	print @tmp 
	--end

	-- insert some default params. 
	if @apply_defaults =1 
	begin 
		declare @default_params ParamTable
		insert into @default_params  values ('"', '''' ) 
		insert into @default_params  values ('<dt>', ''''+ convert(varchar(50), GETDATE(), 121)  + '''' ) 
		select @sql = REPLACE(@sql, p.param_name, convert(nvarchar(max), p.param_value) )
		from @default_params  p
	end 
	
	select @sql = REPLACE(@sql, '<'+ p.param_name+ '>', isnull(convert(nvarchar(max), p.param_value), '<' + isnull(p.param_name, '?') + ' IS NULL>'))
	from @params  p

END