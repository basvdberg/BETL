	  
/*------------------------------------------------------------------------------------------------
-- BETL, meta data driven ETL generation, licensed under GNU GPL https://github.com/basvdberg/BETL 
--------------------------------------------------------------------------------------------------
-- 2017-01-21 BvdB remove left and right spaces and double and single quotes. 
select util.trim('    fsdds  fsddf  ',0)

*/    
CREATE FUNCTION [util].[trim]
(
	@s nvarchar(255)
	, @return_null bit = 1 
)
RETURNS nvarchar(255)
AS
BEGIN
	declare @result as nvarchar(max)= replace(replace(convert(nvarchar(255), ltrim(rtrim(@s))), '"', ''), '''' , '')
	if @return_null =0 
		return isnull(@result , '') 
	return @result 
END