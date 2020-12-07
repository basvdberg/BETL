	  
/*------------------------------------------------------------------------------------------------
-- BETL, meta data driven ETL generation, licensed under GNU GPL https://github.com/basvdberg/BETL 
--------------------------------------------------------------------------------------------------
-- 2017-01-01 BvdB returns true if @s ends with @suffix
select dbo.prefix('gfjhaaaaa_aap', 4) 
*/
CREATE FUNCTION [util].[prefix]
(
                @s as varchar(255)
                , @len_suffix as int
                --, @suffix as varchar(255)
)
RETURNS varchar(255)
AS
BEGIN
                declare @n as int=len(@s) 
                                                --, @n_suffix as int = len(@suffix)
                declare @result as bit = 0 
                return SUBSTRING(@s, 1, @n-@len_suffix) 
END