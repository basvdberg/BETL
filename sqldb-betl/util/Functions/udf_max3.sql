	  
/*------------------------------------------------------------------------------------------------
-- BETL, meta data driven ETL generation, licensed under GNU GPL https://github.com/basvdberg/BETL 
--------------------------------------------------------------------------------------------------
-- 2017-01-01 BvdB returns max value 
*/
create FUNCTION [util].[udf_max3]
(
 @a sql_variant,
 @b sql_variant,
 @c sql_variant
) 
RETURNS sql_variant
as 
begin
	return util.udf_max(dbo.udf_max(@a, @b) , @c) 
end