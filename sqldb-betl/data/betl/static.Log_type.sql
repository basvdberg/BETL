--EXEC sp_generate_merge @schema = 'static', @table_name ='Log_type'
SET NOCOUNT ON

MERGE INTO [static].[Log_type] AS [Target]
USING (VALUES
  (-1,N'unknown',NULL,'2019-11-19T18:12:23.283',N'')
 ,(10,N'header',30,NULL,NULL)
 ,(20,N'footer',30,NULL,NULL)
 ,(30,N'sql',40,NULL,NULL)
 ,(40,N'var',40,NULL,NULL)
 ,(50,N'error',10,NULL,NULL)
 ,(60,N'warn',20,NULL,NULL)
 ,(70,N'step',30,NULL,NULL)
 ,(80,N'progress',50,NULL,NULL)
) AS [Source] ([log_type_id],[log_type],[min_log_level_id],[record_dt],[record_user])
ON ([Target].[log_type_id] = [Source].[log_type_id])
WHEN MATCHED AND (
	NULLIF([Source].[log_type], [Target].[log_type]) IS NOT NULL OR NULLIF([Target].[log_type], [Source].[log_type]) IS NOT NULL OR 
	NULLIF([Source].[min_log_level_id], [Target].[min_log_level_id]) IS NOT NULL OR NULLIF([Target].[min_log_level_id], [Source].[min_log_level_id]) IS NOT NULL OR 
	NULLIF([Source].[record_dt], [Target].[record_dt]) IS NOT NULL OR NULLIF([Target].[record_dt], [Source].[record_dt]) IS NOT NULL OR 
	NULLIF([Source].[record_user], [Target].[record_user]) IS NOT NULL OR NULLIF([Target].[record_user], [Source].[record_user]) IS NOT NULL) THEN
 UPDATE SET
  [log_type] = [Source].[log_type], 
  [min_log_level_id] = [Source].[min_log_level_id], 
  [record_dt] = [Source].[record_dt], 
  [record_user] = [Source].[record_user]
WHEN NOT MATCHED BY TARGET THEN
 INSERT([log_type_id],[log_type],[min_log_level_id],[record_dt],[record_user])
 VALUES([Source].[log_type_id],[Source].[log_type],[Source].[min_log_level_id],[Source].[record_dt],[Source].[record_user])
WHEN NOT MATCHED BY SOURCE THEN 
 DELETE
;
GO
DECLARE @mergeError int
 , @mergeCount int
SELECT @mergeError = @@ERROR, @mergeCount = @@ROWCOUNT
IF @mergeError != 0
 BEGIN
 PRINT 'ERROR OCCURRED IN MERGE FOR [static].[Log_type]. Rows affected: ' + CAST(@mergeCount AS VARCHAR(100)); -- SQL should always return zero rows affected
 END
ELSE
 BEGIN
 PRINT '[static].[Log_type] rows affected by MERGE: ' + CAST(@mergeCount AS VARCHAR(100));
 END
GO

SET NOCOUNT OFF
GO




