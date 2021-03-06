﻿--EXEC sp_generate_merge @schema = 'static', @table_name ='Log_level'
SET NOCOUNT ON

MERGE INTO [static].[Log_level] AS [Target]
USING (VALUES
  (-1,N'unknown',NULL,'2019-11-19T18:12:06.007',N'')
 ,(10,N'error',N'Only log errors',NULL,NULL)
 ,(20,N'warn',N'Log errors and warnings (SSIS mode)',NULL,NULL)
 ,(30,N'info',N'Log headers and footers',NULL,NULL)
 ,(40,N'debug',N'Log everything only at top nesting level',NULL,NULL)
 ,(50,N'verbose',N'Log everything all nesting levels',NULL,NULL)
) AS [Source] ([log_level_id],[log_level],[log_level_description],[record_dt],[record_user])
ON ([Target].[log_level_id] = [Source].[log_level_id])
WHEN MATCHED AND (
	NULLIF([Source].[log_level], [Target].[log_level]) IS NOT NULL OR NULLIF([Target].[log_level], [Source].[log_level]) IS NOT NULL OR 
	NULLIF([Source].[log_level_description], [Target].[log_level_description]) IS NOT NULL OR NULLIF([Target].[log_level_description], [Source].[log_level_description]) IS NOT NULL OR 
	NULLIF([Source].[record_dt], [Target].[record_dt]) IS NOT NULL OR NULLIF([Target].[record_dt], [Source].[record_dt]) IS NOT NULL OR 
	NULLIF([Source].[record_user], [Target].[record_user]) IS NOT NULL OR NULLIF([Target].[record_user], [Source].[record_user]) IS NOT NULL) THEN
 UPDATE SET
  [log_level] = [Source].[log_level], 
  [log_level_description] = [Source].[log_level_description], 
  [record_dt] = [Source].[record_dt], 
  [record_user] = [Source].[record_user]
WHEN NOT MATCHED BY TARGET THEN
 INSERT([log_level_id],[log_level],[log_level_description],[record_dt],[record_user])
 VALUES([Source].[log_level_id],[Source].[log_level],[Source].[log_level_description],[Source].[record_dt],[Source].[record_user])
WHEN NOT MATCHED BY SOURCE THEN 
 DELETE
;
GO
DECLARE @mergeError int
 , @mergeCount int
SELECT @mergeError = @@ERROR, @mergeCount = @@ROWCOUNT
IF @mergeError != 0
 BEGIN
 PRINT 'ERROR OCCURRED IN MERGE FOR [static].[Log_level]. Rows affected: ' + CAST(@mergeCount AS VARCHAR(100)); -- SQL should always return zero rows affected
 END
ELSE
 BEGIN
 PRINT '[static].[Log_level] rows affected by MERGE: ' + CAST(@mergeCount AS VARCHAR(100));
 END
GO

SET NOCOUNT OFF
GO




