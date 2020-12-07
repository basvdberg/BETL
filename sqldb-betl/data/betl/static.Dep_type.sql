--EXEC sp_generate_merge @schema = 'static', @table_name ='Dep_type'
SET NOCOUNT ON

MERGE INTO [static].[Dep_type] AS [Target]
USING (VALUES
  (-1,N'unknown',NULL,'2019-11-19T18:13:03.700',N'')
) AS [Source] ([dep_type_id],[dep_type],[dep_type_description],[record_dt],[record_user])
ON ([Target].[dep_type_id] = [Source].[dep_type_id])
WHEN MATCHED AND (
	NULLIF([Source].[dep_type], [Target].[dep_type]) IS NOT NULL OR NULLIF([Target].[dep_type], [Source].[dep_type]) IS NOT NULL OR 
	NULLIF([Source].[dep_type_description], [Target].[dep_type_description]) IS NOT NULL OR NULLIF([Target].[dep_type_description], [Source].[dep_type_description]) IS NOT NULL OR 
	NULLIF([Source].[record_dt], [Target].[record_dt]) IS NOT NULL OR NULLIF([Target].[record_dt], [Source].[record_dt]) IS NOT NULL OR 
	NULLIF([Source].[record_user], [Target].[record_user]) IS NOT NULL OR NULLIF([Target].[record_user], [Source].[record_user]) IS NOT NULL) THEN
 UPDATE SET
  [dep_type] = [Source].[dep_type], 
  [dep_type_description] = [Source].[dep_type_description], 
  [record_dt] = [Source].[record_dt], 
  [record_user] = [Source].[record_user]
WHEN NOT MATCHED BY TARGET THEN
 INSERT([dep_type_id],[dep_type],[dep_type_description],[record_dt],[record_user])
 VALUES([Source].[dep_type_id],[Source].[dep_type],[Source].[dep_type_description],[Source].[record_dt],[Source].[record_user])
WHEN NOT MATCHED BY SOURCE THEN 
 DELETE
;
GO
DECLARE @mergeError int
 , @mergeCount int
SELECT @mergeError = @@ERROR, @mergeCount = @@ROWCOUNT
IF @mergeError != 0
 BEGIN
 PRINT 'ERROR OCCURRED IN MERGE FOR [static].[Dep_type]. Rows affected: ' + CAST(@mergeCount AS VARCHAR(100)); -- SQL should always return zero rows affected
 END
ELSE
 BEGIN
 PRINT '[static].[Dep_type] rows affected by MERGE: ' + CAST(@mergeCount AS VARCHAR(100));
 END
GO

SET NOCOUNT OFF
GO




