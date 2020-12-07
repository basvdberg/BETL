	  
/*---------------------------------------------------------------------------------------------
BETL, meta data driven ETL generation, licensed under GNU GPL https://github.com/basvdberg/BETL
-----------------------------------------------------------------------------------------------
-- 2018-04-19 BvdB filter characters from string
select util.filter('aap','d')
select util.filter('
aap
', 'char(10),char(13)')
select util.filter('
"aap''
', 'char(10),char(13),",''')
*/
CREATE FUNCTION [util].[filter]
(
	@s varchar(255)
	, @filter varchar(200) 
--	, @return_null bit = 1 
)
RETURNS varchar(255)
AS
BEGIN
	declare @result as varchar(max)= ''
		, @i int =1
		, @n int =len(@s) 
		, @filter_list as SplitList
		, @c as char
	insert into @filter_list
	select * from  util.split(@filter, ',')
	
	update @filter_list
	set item = char(convert(int, replace(replace(item, 'char(',''), ')','')))  
	from @filter_list
	where item like 'char(%'
	while @i<@n+1
	begin
		set @c = substring(@s, @i,1) 
		if not exists ( select * from @filter_list where item = @c) 
			set @result+=@c
		set @i += 1 
	end
--	if @return_null =0 
	--	return isnull(@result , '') 
	return @result 
END