	  
/*------------------------------------------------------------------------------------------------
-- BETL, meta data driven ETL generation, licensed under GNU GPL https://github.com/basvdberg/BETL 
--------------------------------------------------------------------------------------------------
-- 2017-01-01 BvdB 
*/
CREATE FUNCTION [util].[addQuotes]
(
	@s varchar(7900) 
)
RETURNS varchar(8000) 
AS
BEGIN
	RETURN '''' + isnull(@s , '') + '''' 
END