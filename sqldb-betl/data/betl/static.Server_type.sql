--EXEC sp_generate_merge @schema = 'static', @table_name ='Server_type'
SET NOCOUNT ON

MERGE INTO [static].[Server_type] AS [Target]
USING (VALUES
  (-1,N'unknown',NULL,'2019-11-19T18:13:47.913',N'')
 ,(10,N'Azure sql server',N'',NULL,NULL)
 ,(15,N'On premise sql server',N'SQL Server 2012 (SP3) (KB3072779) - 11.0.6020.0 (X64)','2020-04-28T10:47:07.157',N'')
 ,(20,N'Azure ssas tabular',N'',NULL,NULL)
 ,(25,N'On premise ssas tabular',N'SQL Server Analysis Services Tabular Databases with Compatibility Level 1200','2020-04-28T10:47:17.760',N'')
 ,(30,N'MonetDB',N'Nov 2019-SP3 ','2020-04-10T08:20:38.620',N'')
 ,(40,N'IBM DB2 Z-OS',NULL,'2020-04-28T10:46:18.437',N'')
 ,(50,N'On premise file system',NULL,'2020-04-28T10:48:48.740',N'')
 ,(60,N'Azure file system (e.g. Blob storage)',NULL,'2020-04-28T10:49:02.610',N'')
) AS [Source] ([server_type_id],[server_type],[compatibility],[record_dt],[record_user])
ON ([Target].[server_type_id] = [Source].[server_type_id])
WHEN MATCHED AND (
	NULLIF([Source].[server_type], [Target].[server_type]) IS NOT NULL OR NULLIF([Target].[server_type], [Source].[server_type]) IS NOT NULL OR 
	NULLIF([Source].[compatibility], [Target].[compatibility]) IS NOT NULL OR NULLIF([Target].[compatibility], [Source].[compatibility]) IS NOT NULL OR 
	NULLIF([Source].[record_dt], [Target].[record_dt]) IS NOT NULL OR NULLIF([Target].[record_dt], [Source].[record_dt]) IS NOT NULL OR 
	NULLIF([Source].[record_user], [Target].[record_user]) IS NOT NULL OR NULLIF([Target].[record_user], [Source].[record_user]) IS NOT NULL) THEN
 UPDATE SET
  [server_type] = [Source].[server_type], 
  [compatibility] = [Source].[compatibility], 
  [record_dt] = [Source].[record_dt], 
  [record_user] = [Source].[record_user]
WHEN NOT MATCHED BY TARGET THEN
 INSERT([server_type_id],[server_type],[compatibility],[record_dt],[record_user])
 VALUES([Source].[server_type_id],[Source].[server_type],[Source].[compatibility],[Source].[record_dt],[Source].[record_user])
WHEN NOT MATCHED BY SOURCE THEN 
 DELETE
;
GO
DECLARE @mergeError int
 , @mergeCount int
SELECT @mergeError = @@ERROR, @mergeCount = @@ROWCOUNT
IF @mergeError != 0
 BEGIN
 PRINT 'ERROR OCCURRED IN MERGE FOR [static].[Server_type]. Rows affected: ' + CAST(@mergeCount AS VARCHAR(100)); -- SQL should always return zero rows affected
 END
ELSE
 BEGIN
 PRINT '[static].[Server_type] rows affected by MERGE: ' + CAST(@mergeCount AS VARCHAR(100));
 END
GO

SET NOCOUNT OFF
GO




