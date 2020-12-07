	  
	  
/*------------------------------------------------------------------------------------------------
-- BETL, meta data driven ETL generation, licensed under GNU GPL https://github.com/basvdberg/BETL 
--------------------------------------------------------------------------------------------------
-- 2017-01-01 BvdB splits strings. Keeps string together when surrounded by [ ] 
CREATE TYPE SplitListType AS TABLE 	(item VARCHAR(8000), i int)
select * from util.split('AAP,NOOT', ',')
select * from util.split('[AAP,NOOT],VIS,[NOOT,MIES],OLIFANT', ',')
*/
CREATE  FUNCTION [util].[split](
    @s nVARCHAR(max) -- List of delimited items
  , @del nVARCHAR(16) = ',' -- delimiter that separates items
) RETURNS @List TABLE (item NVARCHAR(max), i int)
BEGIN
	DECLARE 
		@item VARCHAR(8000)
		, @i int =1
		, @n int 
		, @del_index int
		, @bracket_index_open int
		, @bracket_index_close int
	
	set @del_index = CHARINDEX(@del,@s,0)
	set @bracket_index_open = CHARINDEX('[',@s,0)
	WHILE @del_index <> 0 -- while there is a delimiter
	BEGIN
		if @del_index < @bracket_index_open or @bracket_index_open=0 -- delimeter occurs before [ or there is no [
		begin 
			set @n = @del_index-1
			SELECT
				@item=RTRIM(LTRIM(SUBSTRING(@s,1,@n))),
				-- set @s= tail 
				@s=RTRIM(LTRIM(SUBSTRING(@s,@del_index+LEN(@del),LEN(@s)-@n)))
		end 
		else -- [ occurs before delimiter
		begin
			set @bracket_index_close = CHARINDEX(']',@s,@bracket_index_open)
			set @n = case when @bracket_index_close=0 then len(@s) else  @bracket_index_close end
			
			SELECT
				@item=RTRIM(LTRIM(SUBSTRING(@s,1,@n))),
				-- set @s= tail 
				@s=RTRIM(LTRIM(SUBSTRING(@s,@n+1,LEN(@s)-@n)))
		end
		IF LEN(@item) > 0
		begin
			INSERT INTO @List SELECT @item, @i
			set @i += 1
		end 
		set @del_index= CHARINDEX(@del,@s,0)
		set @bracket_index_open= CHARINDEX('[',@s,0)
	END
	IF LEN(@s) > 0
	 INSERT INTO @List SELECT @s , @i-- Put the last item in
	RETURN
END