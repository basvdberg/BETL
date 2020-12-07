
	  

/*------------------------------------------------------------------------------------------------
-- BETL, meta data driven ETL generation, licensed under GNU GPL https://github.com/basvdberg/BETL 
--------------------------------------------------------------------------------------------------
-- 2017-01-01 BvdB 
SELECT dbo.guess_foreignCol_id('par_relatie_id')
SELECT [util].[suffix_first_underscore]('relatie_id')
*/    
CREATE FUNCTION [util].[suffix_first_underscore]( @column_name VARCHAR(255) ) 
RETURNS VARCHAR(255) 
AS
BEGIN
	DECLARE @res VARCHAR(255) 
	,		@pos INT 
	SET @pos = CHARINDEX('_', @column_name)
	IF @pos IS NOT NULL
		SET @res = SUBSTRING(@column_name, @pos+1, LEN(@column_name) - @pos)
	RETURN @res 
	/* 
		declare @n as int=len(@s) 
			--, @n_suffix as int = len(@suffix)
	declare @result as bit = 0 
	return SUBSTRING(@s, 1, @n-@len_suffix) 
	*/
END