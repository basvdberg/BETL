/*------------------------------------------------------------------------------------------------
-- BETL, meta data driven ETL generation, licensed under GNU GPL https://github.com/basvdberg/BETL 
--------------------------------------------------------------------------------------------------
-- 2017-01-01 BvdB returns true if @s ends with @suffix
select util.suffix('gfjh_aap', '_') 
select util.suffix('gfjh_aap', 3) 
select util.suffix('gfjh_aap', '_a3p') 
select util.suffix('gfjh_aap', ';') 
select util.suffix('ggbvg;gfjh_aap', ';') 
select util.suffix(';ggbvg;gfjh_aap', ';') 


*/
CREATE FUNCTION [util].[suffix]
(
	@s as nvarchar(255)
	, @len_or_separator as sql_variant -- can be number or char 
)
RETURNS varchar(255)
AS
BEGIN
	declare @data_type as sql_variant
		, @n as int =len(@s) 
		, @i as int
		, @len_suffix as int
		, @result as bit=0
		, @separator as varchar(10) 
	
	SELECT @data_type  = SQL_VARIANT_PROPERTY(@len_or_separator, 'BaseType'); 
	if @data_type = 'int'
	begin
		set @len_suffix =convert(int, @len_or_separator) 
		set @i = @n+1-@len_suffix 
	end
	if @data_type = 'varchar'
	begin
		set @separator = convert(nvarchar(255), @len_or_separator) 
		set @i = CHARINDEX( @separator, @s)+1
		set @len_suffix = @n - @i+1
	end

	return SUBSTRING(@s,@i, @len_suffix) 
	--return convert(varchar(255), @i ) 
END