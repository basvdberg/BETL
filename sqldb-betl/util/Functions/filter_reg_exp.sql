/*---------------------------------------------------------------------------------------------
BETL, meta data driven ETL generation, licensed under GNU GPL https://github.com/basvdberg/BETL
-----------------------------------------------------------------------------------------------
-- 2019-12-11 BvdB filter characters from string using regular expression

select util.filter_reg_exp('Product_Id','^a-z')
select util.filter_reg_exp('443-34~!@@@Product_Id232  ','^a-z')
*/
CREATE FUNCTION [util].[filter_reg_exp]
(
    @s nvarchar(max)
    , @reg_exp VARCHAR(255)
)
RETURNS nvarchar(max)
AS
BEGIN
    SET @reg_exp =  '%['+@reg_exp +']%'

    WHILE PatIndex(@reg_exp , @s) > 0
        SET @s = Stuff(@s, PatIndex(@reg_exp, @s), 1, '')

    RETURN @s

END