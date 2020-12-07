--EXEC sp_generate_merge @schema = 'static', @table_name ='Status'
SET NOCOUNT ON

MERGE INTO [static].[Status] AS [Target]
USING (VALUES
  (-1,N'unknown',0,NULL,NULL,NULL)
 ,(100,N'success',0,N'Execution of batch or transfer finished without any errors. ',NULL,NULL)
 ,(200,N'error',0,N'Execution of batch or transfer raised an error.',NULL,NULL)
 ,(300,N'not started',0,N'Execution of batch or transfer is not started because it cannot start (maybe it''s already running). ',NULL,NULL)
 ,(400,N'running',1,N'Batch or transfer is running. do not start a new instance.',NULL,NULL)
 ,(600,N'continue',1,N'This batch is continuing where the last instance stopped. ',NULL,NULL)
 ,(700,N'stopped',0,N'batch stopped without error (can be continued any time). ',NULL,NULL)
 ,(800,N'skipped',0,N'Transfer is skipped because batch will continue where it has left off. ',NULL,NULL)
 ,(900,N'deleted',0,N'Transfer or batch is deleted / dropped',NULL,NULL)
 ,(910,N'test',0,N'Transfer or batch is deleted / dropped',NULL,NULL)
) AS [Source] ([status_id],[status_name],[is_running],[description],[record_dt],[record_user])
ON ([Target].[status_id] = [Source].[status_id])
WHEN MATCHED AND (
	NULLIF([Source].[status_name], [Target].[status_name]) IS NOT NULL OR NULLIF([Target].[status_name], [Source].[status_name]) IS NOT NULL OR 
	NULLIF([Source].[is_running], [Target].[is_running]) IS NOT NULL OR NULLIF([Target].[is_running], [Source].[is_running]) IS NOT NULL OR 
	NULLIF([Source].[description], [Target].[description]) IS NOT NULL OR NULLIF([Target].[description], [Source].[description]) IS NOT NULL OR 
	NULLIF([Source].[record_dt], [Target].[record_dt]) IS NOT NULL OR NULLIF([Target].[record_dt], [Source].[record_dt]) IS NOT NULL OR 
	NULLIF([Source].[record_user], [Target].[record_user]) IS NOT NULL OR NULLIF([Target].[record_user], [Source].[record_user]) IS NOT NULL) THEN
 UPDATE SET
  [status_name] = [Source].[status_name], 
  [is_running] = [Source].[is_running], 
  [description] = [Source].[description], 
  [record_dt] = [Source].[record_dt], 
  [record_user] = [Source].[record_user]
WHEN NOT MATCHED BY TARGET THEN
 INSERT([status_id],[status_name],[is_running],[description],[record_dt],[record_user])
 VALUES([Source].[status_id],[Source].[status_name],[Source].[is_running],[Source].[description],[Source].[record_dt],[Source].[record_user])
WHEN NOT MATCHED BY SOURCE THEN 
 DELETE
;
GO
DECLARE @mergeError int
 , @mergeCount int
SELECT @mergeError = @@ERROR, @mergeCount = @@ROWCOUNT
IF @mergeError != 0
 BEGIN
 PRINT 'ERROR OCCURRED IN MERGE FOR [static].[Status]. Rows affected: ' + CAST(@mergeCount AS VARCHAR(100)); -- SQL should always return zero rows affected
 END
ELSE
 BEGIN
 PRINT '[static].[Status] rows affected by MERGE: ' + CAST(@mergeCount AS VARCHAR(100));
 END
GO

SET NOCOUNT OFF
GO




