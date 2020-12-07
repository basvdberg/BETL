--EXEC sp_generate_merge @schema = 'static', @table_name ='Version'
-- test
SET NOCOUNT ON

MERGE INTO [static].[Version] AS [Target]
USING (VALUES
  (4,0,0,'2019-11-15T09:59:22',NULL,NULL)
) AS [Source] ([major_version],[minor_version],[build],[build_dt],[record_dt],[record_user])
ON ([Target].[build] = [Source].[build] AND [Target].[major_version] = [Source].[major_version] AND [Target].[minor_version] = [Source].[minor_version])
WHEN MATCHED AND (
	NULLIF([Source].[build_dt], [Target].[build_dt]) IS NOT NULL OR NULLIF([Target].[build_dt], [Source].[build_dt]) IS NOT NULL OR 
	NULLIF([Source].[record_dt], [Target].[record_dt]) IS NOT NULL OR NULLIF([Target].[record_dt], [Source].[record_dt]) IS NOT NULL OR 
	NULLIF([Source].[record_user], [Target].[record_user]) IS NOT NULL OR NULLIF([Target].[record_user], [Source].[record_user]) IS NOT NULL) THEN
 UPDATE SET
  [build_dt] = [Source].[build_dt], 
  [record_dt] = [Source].[record_dt], 
  [record_user] = [Source].[record_user]
WHEN NOT MATCHED BY TARGET THEN
 INSERT([major_version],[minor_version],[build],[build_dt],[record_dt],[record_user])
 VALUES([Source].[major_version],[Source].[minor_version],[Source].[build],[Source].[build_dt],[Source].[record_dt],[Source].[record_user])
WHEN NOT MATCHED BY SOURCE THEN 
 DELETE
;
GO
DECLARE @mergeError int
 , @mergeCount int
SELECT @mergeError = @@ERROR, @mergeCount = @@ROWCOUNT
IF @mergeError != 0
 BEGIN
 PRINT 'ERROR OCCURRED IN MERGE FOR [static].[Version]. Rows affected: ' + CAST(@mergeCount AS VARCHAR(100)); -- SQL should always return zero rows affected
 END
ELSE
 BEGIN
 PRINT '[static].[Version] rows affected by MERGE: ' + CAST(@mergeCount AS VARCHAR(100));
 END
GO

SET NOCOUNT OFF
GO




