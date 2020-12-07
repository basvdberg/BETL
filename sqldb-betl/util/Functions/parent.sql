	  
/*------------------------------------------------------------------------------------------------
-- BETL, meta data driven ETL generation, licensed under GNU GPL https://github.com/basvdberg/BETL 
--------------------------------------------------------------------------------------------------
-- 2019-03-21 BvdB returns parent by parsing the string. e.g. localhost.AdventureWorks2014.dbo = localhost.AdventureWorks2014
select util.parent('localhost.AdventureWorks2014.dbo')
*/    
CREATE FUNCTION [util].[parent]( @fullObj_name varchar(255) ) 
RETURNS varchar(255) 
AS
BEGIN
	declare @rev_str as varchar(255) 
			, @i as int
			, @res as varchar(255) 
	set @rev_str = reverse(@fullObj_name ) 
	set @i = charindex('.', @rev_str) 
	
	if @i = 0 
		set @res = null 
	else 
		set @res =  substring( @fullObj_name, 1, len( @fullObj_name) - @i ) 
	return @res 
END