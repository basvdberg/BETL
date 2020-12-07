	  
/*------------------------------------------------------------------------------------------------
-- BETL, meta data driven ETL generation, licensed under GNU GPL https://github.com/basvdberg/BETL 
--------------------------------------------------------------------------------------------------
-- 2019-03-21 BvdB removes comments from string.  
*/    
CREATE FUNCTION [util].[remove_comments]  (@str VARCHAR(MAX))   RETURNS VARCHAR(MAX)    AS  
 BEGIN  
   declare     @i bigint=1   
    , @j bigint=null    
	, @comment_start bigint=null     
	, @comment_end bigint=null     
	, @eol_pos bigint=null     
	, @n bigint=len(@str)     
	, @c char   
	, @buf as varchar(5) =''    
	, @result as varchar(max)=''   
	
	while @i<=@n    
	begin     
		set @c = substring(@str, @i,1)      
		--print convert(varchar(50), @i) +'. ' + @c         
		 if @c in ( '/', '*', '-')    
		 begin      
		   set @buf= substring(@str, @i,2)  -- take 2     
		   --  print '@buf ' + @buf           
		   if @buf = '--'  -- find end of line or end of string      
		   begin       
			set @comment_start = @i       
			set @eol_pos = charindex(CHAR(13) , @str, @i+2)        
			if @eol_pos = 0 -- no eol found        
				set @comment_end = @n -- must be end of string then       
			else set @comment_end = @eol_pos       
		  end        
		  
		  if @buf = '/*'      
		  begin       
			set @comment_start=@i -- start comment here        
			set @j=charindex('*/', @str, @i+2)        
			--print '@j '+ convert(varchar(50), @j)        
			if @j=0 -- end of comment not found        
				set @comment_end = @n       
			else set @comment_end = @j+1 -- @comment_end is last character in comment string e.g. /      
		  end        
		  
		  if @buf in ( '*/') -- end comment without begin comment...       
		  begin       
			set @comment_start=1 -- start of string       
			set @comment_end = @i+1       
			set @result='' -- empty result       
		  end        
		  --print '@comment_start ' + convert(varchar(30), @comment_start)       
		  --print '@comment_end ' + convert(varchar(30), @comment_end)       
		  -- skip to @comment_end       
		  --print '@i' + convert(varchar(10), @i)       
		  --print '@n' + convert(varchar(10), @n)         
		  
		  if @comment_end is null -- -> no comment found       
		  set @result += @c -- non comment character      
		  else        
			set @i=@comment_end             -- in any case reset counters      
		  set @comment_start=null      
		  set @comment_end=null      
		  set @buf = null       
		  -- set @c=null      
		end     
		else       
			set @result += @c -- non comment character       
			--print @c       
			set @i+=1    
		end   
	return @result   
end