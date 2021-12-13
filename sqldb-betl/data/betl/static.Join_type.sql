--EXEC sp_generate_merge @schema = 'static', @table_name ='join_type'
SET NOCOUNT ON

MERGE INTO [static].[join_type] AS [Target]
USING (VALUES
  (-1,N'unknown','2021-12-13T11:10:44.853',N'bas@c2h.nl')
 ,(10,N'left join','2021-12-13T11:11:01.260',N'bas@c2h.nl')
 ,(20,N'inner join','2021-12-13T11:11:04.400',N'bas@c2h.nl')
 ,(30,N'full outer join','2021-12-13T11:23:47.847',N'bas@c2h.nl')
) AS [Source] ([join_type_id],[join_type],[record_dt],[record_user])
ON ([Target].[join_type_id] = [Source].[join_type_id])
WHEN MATCHED AND (
	NULLIF([Source].[join_type], [Target].[join_type]) IS NOT NULL OR NULLIF([Target].[join_type], [Source].[join_type]) IS NOT NULL OR 
	NULLIF([Source].[record_dt], [Target].[record_dt]) IS NOT NULL OR NULLIF([Target].[record_dt], [Source].[record_dt]) IS NOT NULL OR 
	NULLIF([Source].[record_user], [Target].[record_user]) IS NOT NULL OR NULLIF([Target].[record_user], [Source].[record_user]) IS NOT NULL) THEN
 UPDATE SET
  [join_type] = [Source].[join_type], 
  [record_dt] = [Source].[record_dt], 
  [record_user] = [Source].[record_user]
WHEN NOT MATCHED BY TARGET THEN
 INSERT([join_type_id],[join_type],[record_dt],[record_user])
 VALUES([Source].[join_type_id],[Source].[join_type],[Source].[record_dt],[Source].[record_user])
WHEN NOT MATCHED BY SOURCE THEN 
 DELETE
;
GO
DECLARE @mergeError int
 , @mergeCount int
SELECT @mergeError = @@ERROR, @mergeCount = @@ROWCOUNT
IF @mergeError != 0
 BEGIN
 PRINT 'ERROR OCCURRED IN MERGE FOR [static].[join_type]. Rows affected: ' + CAST(@mergeCount AS VARCHAR(100)); -- SQL should always return zero rows affected
 END
ELSE
 BEGIN
 PRINT '[static].[join_type] rows affected by MERGE: ' + CAST(@mergeCount AS VARCHAR(100));
 END
GO

SET NOCOUNT OFF
GO
