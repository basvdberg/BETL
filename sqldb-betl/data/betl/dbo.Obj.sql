--EXEC sp_generate_merge @schema = 'dbo', @table_name ='Obj'
SET NOCOUNT ON

MERGE INTO [dbo].[Obj] AS [Target]
USING (VALUES
  (-1,N'unknown',10,NULL,NULL,NULL,10,NULL,NULL,NULL,NULL,NULL,NULL,'2021-03-23T09:44:26.493',N'AzureAD\BasvandenBerg')
) AS [Source] ([obj_id],[obj_name],[obj_type_id],[parent_id],[prefix],[obj_name_no_prefix],[server_type_id],[identifier],[src_obj_id],[external_obj_id],[_create_dt],[_delete_dt],[_transfer_id],[_record_dt],[_record_user])
ON ([Target].[obj_id] = [Source].[obj_id])
WHEN MATCHED AND (
	NULLIF([Source].[obj_name], [Target].[obj_name]) IS NOT NULL OR NULLIF([Target].[obj_name], [Source].[obj_name]) IS NOT NULL OR 
	NULLIF([Source].[obj_type_id], [Target].[obj_type_id]) IS NOT NULL OR NULLIF([Target].[obj_type_id], [Source].[obj_type_id]) IS NOT NULL OR 
	NULLIF([Source].[parent_id], [Target].[parent_id]) IS NOT NULL OR NULLIF([Target].[parent_id], [Source].[parent_id]) IS NOT NULL OR 
	NULLIF([Source].[prefix], [Target].[prefix]) IS NOT NULL OR NULLIF([Target].[prefix], [Source].[prefix]) IS NOT NULL OR 
	NULLIF([Source].[obj_name_no_prefix], [Target].[obj_name_no_prefix]) IS NOT NULL OR NULLIF([Target].[obj_name_no_prefix], [Source].[obj_name_no_prefix]) IS NOT NULL OR 
	NULLIF([Source].[server_type_id], [Target].[server_type_id]) IS NOT NULL OR NULLIF([Target].[server_type_id], [Source].[server_type_id]) IS NOT NULL OR 
	NULLIF([Source].[identifier], [Target].[identifier]) IS NOT NULL OR NULLIF([Target].[identifier], [Source].[identifier]) IS NOT NULL OR 
	NULLIF([Source].[src_obj_id], [Target].[src_obj_id]) IS NOT NULL OR NULLIF([Target].[src_obj_id], [Source].[src_obj_id]) IS NOT NULL OR 
	NULLIF([Source].[external_obj_id], [Target].[external_obj_id]) IS NOT NULL OR NULLIF([Target].[external_obj_id], [Source].[external_obj_id]) IS NOT NULL OR 
	NULLIF([Source].[_create_dt], [Target].[_create_dt]) IS NOT NULL OR NULLIF([Target].[_create_dt], [Source].[_create_dt]) IS NOT NULL OR 
	NULLIF([Source].[_delete_dt], [Target].[_delete_dt]) IS NOT NULL OR NULLIF([Target].[_delete_dt], [Source].[_delete_dt]) IS NOT NULL OR 
	NULLIF([Source].[_transfer_id], [Target].[_transfer_id]) IS NOT NULL OR NULLIF([Target].[_transfer_id], [Source].[_transfer_id]) IS NOT NULL OR 
	NULLIF([Source].[_record_dt], [Target].[_record_dt]) IS NOT NULL OR NULLIF([Target].[_record_dt], [Source].[_record_dt]) IS NOT NULL OR 
	NULLIF([Source].[_record_user], [Target].[_record_user]) IS NOT NULL OR NULLIF([Target].[_record_user], [Source].[_record_user]) IS NOT NULL) THEN
 UPDATE SET
  [obj_name] = [Source].[obj_name], 
  [obj_type_id] = [Source].[obj_type_id], 
  [parent_id] = [Source].[parent_id], 
  [prefix] = [Source].[prefix], 
  [obj_name_no_prefix] = [Source].[obj_name_no_prefix], 
  [server_type_id] = [Source].[server_type_id], 
  [identifier] = [Source].[identifier], 
  [src_obj_id] = [Source].[src_obj_id], 
  [external_obj_id] = [Source].[external_obj_id], 
  [_create_dt] = [Source].[_create_dt], 
  [_delete_dt] = [Source].[_delete_dt], 
  [_transfer_id] = [Source].[_transfer_id], 
  [_record_dt] = [Source].[_record_dt], 
  [_record_user] = [Source].[_record_user]
WHEN NOT MATCHED BY TARGET THEN
 INSERT([obj_id],[obj_name],[obj_type_id],[parent_id],[prefix],[obj_name_no_prefix],[server_type_id],[identifier],[src_obj_id],[external_obj_id],[_create_dt],[_delete_dt],[_transfer_id],[_record_dt],[_record_user])
 VALUES([Source].[obj_id],[Source].[obj_name],[Source].[obj_type_id],[Source].[parent_id],[Source].[prefix],[Source].[obj_name_no_prefix],[Source].[server_type_id],[Source].[identifier],[Source].[src_obj_id],[Source].[external_obj_id],[Source].[_create_dt],[Source].[_delete_dt],[Source].[_transfer_id],[Source].[_record_dt],[Source].[_record_user])
;
GO
DECLARE @mergeError int
 , @mergeCount int
SELECT @mergeError = @@ERROR, @mergeCount = @@ROWCOUNT
IF @mergeError != 0
 BEGIN
 PRINT 'ERROR OCCURRED IN MERGE FOR [dbo].[Obj]. Rows affected: ' + CAST(@mergeCount AS VARCHAR(100)); -- SQL should always return zero rows affected
 END
ELSE
 BEGIN
 PRINT '[dbo].[Obj] rows affected by MERGE: ' + CAST(@mergeCount AS VARCHAR(100));
 END
GO

SET NOCOUNT OFF
GO
