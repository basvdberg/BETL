/*------------------------------------------------------------------------------------------------
-- BETL, meta data driven ETL generation, licensed under GNU GPL https://github.com/basvdberg/BETL 
--------------------------------------------------------------------------------------------------
-- 2017-01-01 BvdB 
select dbo.[column_type_name](300) 
*/
CREATE FUNCTION [dbo].[column_type_name]
(
	@column_type_id int
)
RETURNS varchar(255) 
AS
BEGIN
	declare @column_type_name as varchar(255) 
	select @column_type_name = [column_type] from static.Column_type where column_type_id = @column_type_id 
	return @column_type_name + ' (' + convert(varchar(10), @column_type_id ) + ')'
END