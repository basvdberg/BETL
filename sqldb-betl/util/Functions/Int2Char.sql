/*------------------------------------------------------------------------------------------------
-- BETL, meta data driven ETL generation, licensed under GNU GPL https://github.com/basvdberg/BETL 
--------------------------------------------------------------------------------------------------
-- 2017-01-01 BvdB 
select util.int2Char(2)
*/
CREATE FUNCTION [util].[Int2Char] (     @i int)
RETURNS varchar(15) AS
BEGIN
       RETURN isnull(convert(varchar(15), @i), '')
END