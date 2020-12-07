--EXEC sp_generate_merge @schema = 'static', @table_name ='Obj_type'
SET NOCOUNT ON

MERGE INTO [static].[Obj_type] AS [Target]
USING (VALUES
  (-1,N'unknown',NULL,NULL,NULL)
 ,(10,N'table',40,NULL,NULL)
 ,(20,N'view',40,NULL,NULL)
 ,(30,N'schema',30,NULL,NULL)
 ,(40,N'database',20,NULL,NULL)
 ,(50,N'server',10,NULL,NULL)
 ,(60,N'user',40,NULL,NULL)
 ,(70,N'procedure',40,NULL,NULL)
 ,(80,N'role',30,NULL,NULL)
 ,(90,N'file_system',10,NULL,NULL)
 ,(100,N'file_folder',30,NULL,NULL)
 ,(110,N'file',40,NULL,NULL)
) AS [Source] ([obj_type_id],[obj_type],[obj_type_level],[record_dt],[record_user])
ON ([Target].[obj_type_id] = [Source].[obj_type_id])
WHEN MATCHED AND (
	NULLIF([Source].[obj_type], [Target].[obj_type]) IS NOT NULL OR NULLIF([Target].[obj_type], [Source].[obj_type]) IS NOT NULL OR 
	NULLIF([Source].[obj_type_level], [Target].[obj_type_level]) IS NOT NULL OR NULLIF([Target].[obj_type_level], [Source].[obj_type_level]) IS NOT NULL OR 
	NULLIF([Source].[record_dt], [Target].[record_dt]) IS NOT NULL OR NULLIF([Target].[record_dt], [Source].[record_dt]) IS NOT NULL OR 
	NULLIF([Source].[record_user], [Target].[record_user]) IS NOT NULL OR NULLIF([Target].[record_user], [Source].[record_user]) IS NOT NULL) THEN
 UPDATE SET
  [obj_type] = [Source].[obj_type], 
  [obj_type_level] = [Source].[obj_type_level], 
  [record_dt] = [Source].[record_dt], 
  [record_user] = [Source].[record_user]
WHEN NOT MATCHED BY TARGET THEN
 INSERT([obj_type_id],[obj_type],[obj_type_level],[record_dt],[record_user])
 VALUES([Source].[obj_type_id],[Source].[obj_type],[Source].[obj_type_level],[Source].[record_dt],[Source].[record_user])
WHEN NOT MATCHED BY SOURCE THEN 
 DELETE
;
GO
DECLARE @mergeError int
 , @mergeCount int
SELECT @mergeError = @@ERROR, @mergeCount = @@ROWCOUNT
IF @mergeError != 0
 BEGIN
 PRINT 'ERROR OCCURRED IN MERGE FOR [static].[Obj_type]. Rows affected: ' + CAST(@mergeCount AS VARCHAR(100)); -- SQL should always return zero rows affected
 END
ELSE
 BEGIN
 PRINT '[static].[Obj_type] rows affected by MERGE: ' + CAST(@mergeCount AS VARCHAR(100));
 END
GO

SET NOCOUNT OFF
GO




