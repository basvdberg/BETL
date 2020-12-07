	  
	  
	  

/*------------------------------------------------------------------------------------------------
-- BETL, meta data driven ETL generation, licensed under GNU GPL https://github.com/basvdberg/BETL 
--------------------------------------------------------------------------------------------------
-- 2017-01-21 BvdB The meta data of views can get outdated when underlying tables change. Use this proc to refresh all views meta data. 
exec util.refresh_views 'AdventureWorks2014'
*/    
CREATE PROCEDURE [util].[refresh_views]
	--@db_name as varchar(255)  
AS
BEGIN
/*
	SET NOCOUNT ON;
	DECLARE @sql AS VARCHAR(MAX) 
		, @cur_db as varchar(255) 
    set @cur_db = DB_NAME()
	SET @sql = '
DECLARE @sql AS VARCHAR(MAX) =''use '+@db_name + ';
''
use '+@db_name+ ';
SELECT @sql += ''EXEC sp_refreshview '''''' + schema_name(schema_id)+ ''.''+ name + '''''' ;
''
  FROM sys.views
set @sql+= ''USE '+@Cur_db+ '''
PRINT @sql 
exec(@sql)
use ' +@cur_db+ '
'
	exec [dbo].[exec_sql] @sql
	--PRINT @sql 
--   EXEC(@sql)
   
   */

   declare @cur_db as varchar(255) 
			,@sql as varchar(255) 
   --select @cur_db = DB_NAME()
   --set @sql = 'use '+@db_name
   --exec (@sql) 
   --select DB_NAME()
	DECLARE @view_name AS NVARCHAR(500);
	DECLARE views_cursor CURSOR FOR 
		SELECT TABLE_SCHEMA + '.' +TABLE_NAME FROM INFORMATION_SCHEMA.TABLES 
		WHERE	TABLE_TYPE = 'VIEW' 
		ORDER BY TABLE_SCHEMA,TABLE_NAME 
	
	OPEN views_cursor 
	FETCH NEXT FROM views_cursor 
	INTO @view_name 
	WHILE (@@FETCH_STATUS <> -1) 
	BEGIN
		BEGIN TRY
			EXEC sp_refreshview @view_name;
			PRINT @view_name;
		END TRY
		BEGIN CATCH
			PRINT 'Error during refreshing view "' + @view_name + '".'+ + convert(varchar(255), isnull(ERROR_MESSAGE(),''))	;
		END CATCH;
		FETCH NEXT FROM views_cursor 
		INTO @view_name 
	END 
	CLOSE views_cursor; 
	DEALLOCATE views_cursor;
   set @sql = 'use '+@cur_db
   exec (@sql) 
END