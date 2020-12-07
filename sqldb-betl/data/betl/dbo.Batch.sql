-- EXEC sp_generate_merge @schema = 'dbo', @table_name ='Batch', @delete_if_not_matched =0
-- WARNING : do not delete records in dbo tables !

SET NOCOUNT ON
GO

SET IDENTITY_INSERT [dbo].[batch] ON
GO

MERGE INTO [dbo].[batch] AS [Target]
USING (VALUES
  (-1,N'unknown','2020-02-20T13:15:22.257',NULL,-1,-1,-1,N'unknown',N'unknown',N'unknown',NULL,0,NULL,NULL)
) AS [Source] ([batch_id],[batch_name],[batch_start_dt],[batch_end_dt],[status_id],[last_error_id],[prev_batch_id],[exec_server],[exec_host],[exec_user],[guid],[continue_batch],[batch_seq],[parent_batch_id])
ON ([Target].[batch_id] = [Source].[batch_id])
WHEN MATCHED AND (
	NULLIF([Source].[batch_name], [Target].[batch_name]) IS NOT NULL OR NULLIF([Target].[batch_name], [Source].[batch_name]) IS NOT NULL OR 
	NULLIF([Source].[batch_start_dt], [Target].[batch_start_dt]) IS NOT NULL OR NULLIF([Target].[batch_start_dt], [Source].[batch_start_dt]) IS NOT NULL OR 
	NULLIF([Source].[batch_end_dt], [Target].[batch_end_dt]) IS NOT NULL OR NULLIF([Target].[batch_end_dt], [Source].[batch_end_dt]) IS NOT NULL OR 
	NULLIF([Source].[status_id], [Target].[status_id]) IS NOT NULL OR NULLIF([Target].[status_id], [Source].[status_id]) IS NOT NULL OR 
	NULLIF([Source].[last_error_id], [Target].[last_error_id]) IS NOT NULL OR NULLIF([Target].[last_error_id], [Source].[last_error_id]) IS NOT NULL OR 
	NULLIF([Source].[prev_batch_id], [Target].[prev_batch_id]) IS NOT NULL OR NULLIF([Target].[prev_batch_id], [Source].[prev_batch_id]) IS NOT NULL OR 
	NULLIF([Source].[exec_server], [Target].[exec_server]) IS NOT NULL OR NULLIF([Target].[exec_server], [Source].[exec_server]) IS NOT NULL OR 
	NULLIF([Source].[exec_host], [Target].[exec_host]) IS NOT NULL OR NULLIF([Target].[exec_host], [Source].[exec_host]) IS NOT NULL OR 
	NULLIF([Source].[exec_user], [Target].[exec_user]) IS NOT NULL OR NULLIF([Target].[exec_user], [Source].[exec_user]) IS NOT NULL OR 
	NULLIF([Source].[guid], [Target].[guid]) IS NOT NULL OR NULLIF([Target].[guid], [Source].[guid]) IS NOT NULL OR 
	NULLIF([Source].[continue_batch], [Target].[continue_batch]) IS NOT NULL OR NULLIF([Target].[continue_batch], [Source].[continue_batch]) IS NOT NULL OR 
	NULLIF([Source].[batch_seq], [Target].[batch_seq]) IS NOT NULL OR NULLIF([Target].[batch_seq], [Source].[batch_seq]) IS NOT NULL OR 
	NULLIF([Source].[parent_batch_id], [Target].[parent_batch_id]) IS NOT NULL OR NULLIF([Target].[parent_batch_id], [Source].[parent_batch_id]) IS NOT NULL) THEN
 UPDATE SET
  [batch_name] = [Source].[batch_name], 
  [batch_start_dt] = [Source].[batch_start_dt], 
  [batch_end_dt] = [Source].[batch_end_dt], 
  [status_id] = [Source].[status_id], 
  [last_error_id] = [Source].[last_error_id], 
  [prev_batch_id] = [Source].[prev_batch_id], 
  [exec_server] = [Source].[exec_server], 
  [exec_host] = [Source].[exec_host], 
  [exec_user] = [Source].[exec_user], 
  [guid] = [Source].[guid], 
  [continue_batch] = [Source].[continue_batch], 
  [batch_seq] = [Source].[batch_seq], 
  [parent_batch_id] = [Source].[parent_batch_id]
WHEN NOT MATCHED BY TARGET THEN
 INSERT([batch_id],[batch_name],[batch_start_dt],[batch_end_dt],[status_id],[last_error_id],[prev_batch_id],[exec_server],[exec_host],[exec_user],[guid],[continue_batch],[batch_seq],[parent_batch_id])
 VALUES([Source].[batch_id],[Source].[batch_name],[Source].[batch_start_dt],[Source].[batch_end_dt],[Source].[status_id],[Source].[last_error_id],[Source].[prev_batch_id],[Source].[exec_server],[Source].[exec_host],[Source].[exec_user],[Source].[guid],[Source].[continue_batch],[Source].[batch_seq],[Source].[parent_batch_id])
;
GO
DECLARE @mergeError int
 , @mergeCount int
SELECT @mergeError = @@ERROR, @mergeCount = @@ROWCOUNT
IF @mergeError != 0
 BEGIN
 PRINT 'ERROR OCCURRED IN MERGE FOR [dbo].[batch]. Rows affected: ' + CAST(@mergeCount AS VARCHAR(100)); -- SQL should always return zero rows affected
 END
ELSE
 BEGIN
 PRINT '[dbo].[batch] rows affected by MERGE: ' + CAST(@mergeCount AS VARCHAR(100));
 END
GO

SET IDENTITY_INSERT [dbo].[batch] OFF
GO
SET NOCOUNT OFF
GO



