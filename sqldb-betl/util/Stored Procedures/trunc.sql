


/*------------------------------------------------------------------------------------------------
-- BETL, meta data driven ETL generation, licensed under GNU GPL https://github.com/basvdberg/BETL 
--------------------------------------------------------------------------------------------------
-- 2020-02-20 BvdB This proc was made to prevent giving alter permissions to a user for running truncate. 
exec util.trunc 'dbo.Stack'
*/    

CREATE PROCEDURE [util].[trunc] @table sysname
WITH EXECUTE AS OWNER
AS

SET NOCOUNT ON

DECLARE @sql nVARCHAR(max)
	,	@obj_id int

SET @obj_id = OBJECT_ID(@table)

BEGIN TRY
    IF @obj_id IS NOT NULL 
        BEGIN
            SET @sql = 'TRUNCATE TABLE ' + @table 
          --  print @sql 
			EXECUTE sp_executesql @sql
        END
    ELSE
    BEGIN
        PRINT N'table ' + @table+ ' does not exist'
    END
END TRY
BEGIN CATCH  
    PRINT N'error in [util].[truncate] '+isnull(@table,'?')
    SELECT ERROR_NUMBER() AS ErrorNumber, ERROR_MESSAGE() AS ErrorMessage   
END CATCH