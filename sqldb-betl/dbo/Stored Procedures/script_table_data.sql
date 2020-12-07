	  
/*------------------------------------------------------------------------------------------------
-- BETL, meta data driven ETL generation, licensed under GNU GPL https://github.com/basvdberg/BETL 
--------------------------------------------------------------------------------------------------
-- 2017-01-01 BvdB used by ddl_betl release script
exec [dbo].[script_table_data] 'dbo.col_hist'
*/
CREATE PROCEDURE [dbo].[script_table_data]
    @full_obj_name AS VARCHAR(255) 
--    , @scope AS VARCHAR(255) 
--	, @cols AS dbo.ColumnTable READONLY
	, @transfer_id AS INT = -1
--	, @create_pkey AS BIT =1 
AS
BEGIN
	-- standard BETL header code... 
	set nocount on 
	declare  @proc_name as varchar(255) =  object_name(@@PROCID)
			, @betl varchar(100) =db_name() 
	exec dbo.log @transfer_id, 'header', '? ?, ?', @proc_name , @full_obj_name,  @transfer_id 
	-- END standard BETL header code... 
	declare @sql as varchar(max) 
			, @col_str as varchar(8000) =''
			, @nl as varchar(2) = char(13)+char(10)
			, @db as varchar(255) 
			, @obj_name as varchar(255) 
			, @schema as varchar(255) 
			, @schema_id as int
			, @this_db as varchar(255) = db_name()
			, @prim_key as varchar(1000) =''
			, @prim_key_sql as varchar(8000)=''
			, @p ParamTable
			, @unique_index as varchar(1000)=''
			, @index_sql as varchar(4000) 
			, @refresh_sql as varchar(4000) 
			, @recreate_tables as BIT
            , @object_id AS INT  -- ms  object_id 
			, @obj_id as int -- betl obj_id 
	----------------------------------------------------------------------------
	exec dbo.log @transfer_id, 'STEP', 'retrieve obj_id from name ?', @full_obj_name
	----------------------------------------------------------------------------
	exec dbo.inc_nesting
	exec dbo.get_obj_id @full_obj_name, @obj_id output, @scope=null, @transfer_id=@transfer_id
	exec dbo.dec_nesting
	select @db = [db_name] from dbo.obj_ext where obj_id = @obj_id 
	if @obj_id is null 
	begin 
		exec log 'error' , 'object ? not found', @full_obj_name
		goto footer
	end
	exec dbo.inc_nesting
	exec dbo.refresh_obj_id @obj_id
	exec dbo.dec_nesting

	set @sql ='
-------------------------------------------------
-- Start script table data <full_obj_name>
-------------------------------------------------
USE <db> 
'
	insert into @p values ('betl'					, @betl) 
	INSERT INTO @p VALUES ('full_obj_name'		, @full_obj_name) 
	INSERT INTO @p VALUES ('db'						, @db) 
	EXEC util.apply_params @sql OUTPUT, @p
	print @sql
/*
--Author Florian Reischl
   @handle_big_binary
      If set to 1 the user defined function udf_varbintohexstr_big will be used
      to convert BINARY, VARBINARY and IMAGE data. For futher information see remarks.
   @column_names
      If set to 0 only the values to be inserted will be scripted; the column names wont.
      This saves memory but the destination tables needs exactly the same columns in 
      same order.
      If set to 1 also the names of the columns to insert the values into will be scripted.
Remarks
=======
Attention:
   In case of colums of type BINARY, VARBINARY or IMAGE
   you either need the user defined function udf_varbintohexstr_big
   and option @handle_big_binary set to 1 or you risk a loss of data
   if the data of a cell are larger than 3998 bytes
Data type sql_variant is not supported.
*/
SET NOCOUNT ON
DECLARE @table_name SYSNAME
DECLARE @handle_big_binary BIT
DECLARE @column_names BIT
-- ////////////////////
-- -> Configuration
SET @table_name = @full_obj_name
SET @handle_big_binary = 1
SET @column_names = 1
-- <- Configuration
-- ////////////////////
print '
select ''set nocount on'' sql_statement
union all 
select ''truncate table '+@full_obj_name +''' sql_statement
union all 
select ''set identity_insert '+ @full_obj_name + ' on'' sql_statement
union all 
'

--SELECT * FROM sys.all_objects
SELECT @object_id = object_id, @schema_id = schema_id 
   FROM sys.tables 
   WHERE object_id = object_id(@table_name)
DECLARE @columns TABLE (column_name SYSNAME, ordinal_position INT, data_type SYSNAME, data_length INT, is_nullable BIT)
-- Get all column information
INSERT INTO @columns
   SELECT column_name, ordinal_position, data_type, character_maximum_length, CASE WHEN is_nullable = 'YES' THEN 1 ELSE 0 END
   FROM INFORMATION_SCHEMA.COLUMNS
   WHERE TABLE_SCHEMA = SCHEMA_NAME(@schema_id)
   AND TABLE_NAME = object_name(@object_id)
DECLARE @select VARCHAR(MAX)
DECLARE @insert VARCHAR(MAX)
DECLARE @crlf CHAR(2)
DECLARE @first BIT
DECLARE @pos INT
SET @pos = 1
SET @crlf = CHAR(13) + CHAR(10)
WHILE EXISTS (SELECT TOP 1 * FROM @columns WHERE ordinal_position >= @pos)
BEGIN
   DECLARE @column_name SYSNAME
   DECLARE @data_type SYSNAME
   DECLARE @data_length INT
   DECLARE @is_nullable BIT
   -- Get information for the current column
   SELECT @column_name = column_name, @data_type = data_type, @data_length = data_length, @is_nullable = is_nullable
      FROM @columns
      WHERE ordinal_position = @pos
   -- Create column select information to script the name of the source/destination column if configured
   IF (@select IS NULL)
      SET @select = ' ''' + QUOTENAME(@column_name)
   ELSE
      SET @select = @select + ','' + ' + @crlf + ' ''' + QUOTENAME(@column_name)
   -- Handle NULL values
   SET @sql = ' '
   SET @sql = @sql + 'CASE WHEN ' + QUOTENAME(@column_name) + ' IS NULL THEN ''NULL'' ELSE '
   -- Handle the different data types
   IF (@data_type IN ('bigint', 'bit', 'decimal', 'float', 'int', 'money', 'numeric',
 'real', 'smallint', 'smallmoney', 'tinyint'))
   BEGIN
      SET @sql = @sql + 'CONVERT(VARCHAR(40), ' + QUOTENAME(@column_name) + ')'
   END
   ELSE IF (@data_type IN ('char', 'nchar', 'nvarchar', 'varchar'))
   BEGIN
      SET @sql = @sql + ''''''''' + REPLACE(' + QUOTENAME(@column_name) + ', '''''''', '''''''''''') + '''''''''
   END
   ELSE IF (@data_type = 'date')

   BEGIN
      SET @sql = @sql + '''CONVERT(DATE, '' + master.sys.fn_varbintohexstr (CONVERT(BINARY(3), ' + QUOTENAME(@column_name) + ')) + '')'''
   END
   ELSE IF (@data_type = 'time')
   BEGIN
      SET @sql = @sql + '''CONVERT(TIME, '' + master.sys.fn_varbintohexstr (CONVERT(BINARY(5), ' + QUOTENAME(@column_name) + ')) + '')'''
   END
   ELSE IF (@data_type = 'datetime')
   BEGIN
      SET @sql = @sql + '''CONVERT(DATETIME, '' + master.sys.fn_varbintohexstr (CONVERT(BINARY(8), ' + QUOTENAME(@column_name) + ')) + '')'''
   END
   ELSE IF (@data_type = 'datetime2')
   BEGIN
      SET @sql = @sql + '''CONVERT(DATETIME2, '' + master.sys.fn_varbintohexstr (CONVERT(BINARY(8), ' + QUOTENAME(@column_name) + ')) + '')'''
   END
   ELSE IF (@data_type = 'smalldatetime')
   BEGIN
      SET @sql = @sql + '''CONVERT(SMALLDATETIME, '' + master.sys.fn_varbintohexstr (CONVERT(BINARY(4), ' + QUOTENAME(@column_name) + ')) + '')'''
   END
   ELSE IF (@data_type = 'text')
   BEGIN
      SET @sql = @sql + ''''''''' + REPLACE(CONVERT(VARCHAR(MAX), ' + QUOTENAME(@column_name) + '), '''''''', '''''''''''') + '''''''''
   END
   ELSE IF (@data_type IN ('ntext', 'xml'))
   BEGIN
      SET @sql = @sql + ''''''''' + REPLACE(CONVERT(NVARCHAR(MAX), ' + QUOTENAME(@column_name) + '), '''''''', '''''''''''') + '''''''''
   END
   ELSE IF (@data_type IN ('binary', 'varbinary'))
   BEGIN
      -- Use udf_varbintohexstr_big if available to avoid cutted binary data
      IF (@handle_big_binary = 1)
         SET @sql = @sql + ' dbo.udf_varbintohexstr_big (' + QUOTENAME(@column_name) + ')'
      ELSE
         SET @sql = @sql + ' master.sys.fn_varbintohexstr (' + QUOTENAME(@column_name) + ')'
   END
   ELSE IF (@data_type = 'timestamp')
   BEGIN
      SET @sql = @sql + '''CONVERT(TIMESTAMP, '' + master.sys.fn_varbintohexstr (CONVERT(BINARY(8), ' + QUOTENAME(@column_name) + ')) + '')'''
   END
   ELSE IF (@data_type = 'uniqueidentifier')
   BEGIN
      SET @sql = @sql + '''CONVERT(UNIQUEIDENTIFIER, '' + master.sys.fn_varbintohexstr (CONVERT(BINARY(16), ' + QUOTENAME(@column_name) + ')) + '')'''
   END
   ELSE IF (@data_type = 'image')
   BEGIN
      -- Use udf_varbintohexstr_big if available to avoid cutted binary data
      IF (@handle_big_binary = 1)
         SET @sql = @sql + ' dbo.udf_varbintohexstr_big (CONVERT(VARBINARY(MAX), ' + QUOTENAME(@column_name) + '))'
      ELSE
         SET @sql = @sql + ' master.sys.fn_varbintohexstr (CONVERT(VARBINARY(MAX), ' + QUOTENAME(@column_name) + '))'
   END
   ELSE
   BEGIN
      PRINT 'ERROR: Not supported data type: ' + @data_type
      RETURN
   END
   SET @sql = @sql + ' END'
   -- Script line end for finish or next column
   IF EXISTS (SELECT TOP 1 * FROM @columns WHERE ordinal_position > @pos)
      SET @sql = @sql + ' + '', '' +'
   ELSE
      SET @sql = @sql + ' + '
   -- Remember the data script
   IF (@insert IS NULL)
      SET @insert = @sql
   ELSE

      SET @insert = @insert + @crlf + @sql
   SET @pos = @pos + 1
END
-- Close the column names select
SET @select = @select + ''' +'
-- Print the INSERT INTO part
PRINT 'SELECT ''INSERT INTO ' + @table_name + ''' + '
-- Print the column names if configured
IF (@column_names = 1)
BEGIN
 PRINT ' ''('' + '
 PRINT @select
 PRINT ' '')'' + '
END
PRINT ' '' VALUES ('' +'
-- Print the data scripting
PRINT @insert
-- Script the end of the statement
PRINT ' '')'''
PRINT ' FROM ' + @table_name
print '
union all
select ''set identity_insert '+ @full_obj_name + ' off'' sql_statement
print ''done''
'
print
'-------------------------------------------------
-- End script table data  <full_obj_name>
-------------------------------------------------
print ''done''
'
	-- standard BETL footer code... 
    footer:
	exec dbo.log @transfer_id, 'footer', 'DONE ? ? ? ?', @proc_name , @full_obj_name, @transfer_id
	-- END standard BETL footer code... 
END