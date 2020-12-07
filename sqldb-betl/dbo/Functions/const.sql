	  
/*------------------------------------------------------------------------------------------------
-- BETL, meta data driven ETL generation, licensed under GNU GPL https://github.com/basvdberg/BETL 
--------------------------------------------------------------------------------------------------
-- 2015-08-31 BvdB returns int value for const string. 
this way we don't have to use ints foreign keys in our code. 
Assumption: const is unique across all lookup tables. 
Lookup tables: obj_type
select dbo.const('table')
*/
CREATE FUNCTION [dbo].[const]
(
	@const varchar(255) 
)
RETURNS int 
AS
BEGIN
	declare @res as int 
	SELECT @res = obj_type_id from static.obj_type 
	where obj_type = @const 
	
	RETURN @res
END