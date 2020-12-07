--EXEC sp_generate_merge @schema = 'static', @table_name ='Column_type'
SET NOCOUNT ON

MERGE INTO [static].[Column_type] AS [Target]
USING (VALUES
  (-1,N'unknown',N'Unknown,  not relevant','2015-10-20T13:22:19.590',N'bas')
 ,(100,N'nat_pkey',N'Natural primary key (e.g. user_key)','2015-10-20T13:22:19.590',N'bas')
 ,(105,N'nat_pkey_fkey',N'Natural primary and foreign key (e.g. persoon_id)',NULL,NULL)
 ,(110,N'nat_fkey',N'Natural foreign key (e.g. create_user_key)','2015-10-20T13:22:19.590',N'bas')
 ,(200,N'sur_pkey',N'Surrogate primary key (e.g. user_id)','2015-10-20T13:22:19.590',N'bas')
 ,(210,N'sur_fkey',N'Surrogate foreign key (e.g. create_user_id)','2015-10-20T13:22:19.590',N'bas')
 ,(300,N'attribute',N'low or non repetetive value for containing object. E.g. customer lastname, firstname.','2015-10-20T13:22:19.590',N'bas')
 ,(999,N'meta data',NULL,'2015-10-20T13:22:19.590',N'bas')
) AS [Source] ([column_type_id],[column_type],[column_type_description],[record_dt],[record_user])
ON ([Target].[column_type_id] = [Source].[column_type_id])
WHEN MATCHED AND (
	NULLIF([Source].[column_type], [Target].[column_type]) IS NOT NULL OR NULLIF([Target].[column_type], [Source].[column_type]) IS NOT NULL OR 
	NULLIF([Source].[column_type_description], [Target].[column_type_description]) IS NOT NULL OR NULLIF([Target].[column_type_description], [Source].[column_type_description]) IS NOT NULL OR 
	NULLIF([Source].[record_dt], [Target].[record_dt]) IS NOT NULL OR NULLIF([Target].[record_dt], [Source].[record_dt]) IS NOT NULL OR 
	NULLIF([Source].[record_user], [Target].[record_user]) IS NOT NULL OR NULLIF([Target].[record_user], [Source].[record_user]) IS NOT NULL) THEN
 UPDATE SET
  [column_type] = [Source].[column_type], 
  [column_type_description] = [Source].[column_type_description], 
  [record_dt] = [Source].[record_dt], 
  [record_user] = [Source].[record_user]
WHEN NOT MATCHED BY TARGET THEN
 INSERT([column_type_id],[column_type],[column_type_description],[record_dt],[record_user])
 VALUES([Source].[column_type_id],[Source].[column_type],[Source].[column_type_description],[Source].[record_dt],[Source].[record_user])
WHEN NOT MATCHED BY SOURCE THEN 
 DELETE
;
GO
DECLARE @mergeError int
 , @mergeCount int
SELECT @mergeError = @@ERROR, @mergeCount = @@ROWCOUNT
IF @mergeError != 0
 BEGIN
 PRINT 'ERROR OCCURRED IN MERGE FOR [static].[Column_type]. Rows affected: ' + CAST(@mergeCount AS VARCHAR(100)); -- SQL should always return zero rows affected
 END
ELSE
 BEGIN
 PRINT '[static].[Column_type] rows affected by MERGE: ' + CAST(@mergeCount AS VARCHAR(100));
 END
GO

SET NOCOUNT OFF
GO




