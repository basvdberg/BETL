	  

	  
/*------------------------------------------------------------------------------------------------
-- BETL, meta data driven ETL generation, licensed under GNU GPL https://github.com/basvdberg/BETL 
--------------------------------------------------------------------------------------------------
-- 2017-01-01 BvdB returns the minimum of two numbers
select util.udf_min(1,2)
select util.udf_min(null,2)
select util.udf_min(2,null)
select util.udf_min(2,3)
select util.udf_min(2,2)
*/
CREATE FUNCTION [util].[udf_min]
(
 @a sql_variant,
 @b sql_variant
 
)
RETURNS sql_variant
AS
BEGIN
 if @a is null or @b <= @a
  return @b
 else
  if @b is null or @a < @b
   return @a
 return null
END