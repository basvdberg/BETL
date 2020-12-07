	  

/*------------------------------------------------------------------------------------------------
-- BETL, meta data driven ETL generation, licensed under GNU GPL https://github.com/basvdberg/BETL 
--------------------------------------------------------------------------------------------------
-- 2017-01-01 BvdB returns min value
*/
CREATE FUNCTION [util].[udf_min3]
(
 @a sql_variant,
 @b sql_variant,
 @c sql_variant
) 
RETURNS sql_variant
as 
begin
	return util.udf_min(util.udf_min(@a, @b) , @c) 
end