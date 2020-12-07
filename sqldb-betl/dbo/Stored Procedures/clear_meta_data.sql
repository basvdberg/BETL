/*---------------------------------------------------------------------------------------------
BETL, meta data driven ETL generation, licensed under GNU GPL https://github.com/basvdberg/BETL
-----------------------------------------------------------------------------------------------
-- 2020-04-06 BvdB delete all customer related meta data
*/
-- exec [dbo].[clear_meta_data] 
CREATE procedure [dbo].[clear_meta_data] as 
begin 

	delete from dbo.Logging
	delete from dbo.transfer
	delete from dbo.Property_value
	delete from dbo.col_h
	delete from dbo.obj

	--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

	SET NOCOUNT ON

	MERGE INTO [dbo].[Obj] AS [Target]
	USING (VALUES
	  (-1,N'unknown',10,-1,NULL,NULL,10,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2020-04-03T10:35:47.990',N'')
	) AS [Source] ([obj_id],[obj_name],[obj_type_id],[parent_id],[prefix],[obj_name_no_prefix],[server_type_id],[identifier],[src_obj_id],[_create_dt],[_delete_dt],[_request_create_dt],[_request_delete_dt],[_transfer_id],[_record_dt],[_record_user])
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
		NULLIF([Source].[_create_dt], [Target].[_create_dt]) IS NOT NULL OR NULLIF([Target].[_create_dt], [Source].[_create_dt]) IS NOT NULL OR 
		NULLIF([Source].[_delete_dt], [Target].[_delete_dt]) IS NOT NULL OR NULLIF([Target].[_delete_dt], [Source].[_delete_dt]) IS NOT NULL OR 
		NULLIF([Source].[_request_create_dt], [Target].[_request_create_dt]) IS NOT NULL OR NULLIF([Target].[_request_create_dt], [Source].[_request_create_dt]) IS NOT NULL OR 
		NULLIF([Source].[_request_delete_dt], [Target].[_request_delete_dt]) IS NOT NULL OR NULLIF([Target].[_request_delete_dt], [Source].[_request_delete_dt]) IS NOT NULL OR 
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
	  [_create_dt] = [Source].[_create_dt], 
	  [_delete_dt] = [Source].[_delete_dt], 
	  [_request_create_dt] = [Source].[_request_create_dt], 
	  [_request_delete_dt] = [Source].[_request_delete_dt], 
	  [_transfer_id] = [Source].[_transfer_id], 
	  [_record_dt] = [Source].[_record_dt], 
	  [_record_user] = [Source].[_record_user]
	WHEN NOT MATCHED BY TARGET THEN
	 INSERT([obj_id],[obj_name],[obj_type_id],[parent_id],[prefix],[obj_name_no_prefix],[server_type_id],[identifier],[src_obj_id],[_create_dt],[_delete_dt],[_request_create_dt],[_request_delete_dt],[_transfer_id],[_record_dt],[_record_user])
	 VALUES([Source].[obj_id],[Source].[obj_name],[Source].[obj_type_id],[Source].[parent_id],[Source].[prefix],[Source].[obj_name_no_prefix],[Source].[server_type_id],[Source].[identifier],[Source].[src_obj_id],[Source].[_create_dt],[Source].[_delete_dt],[Source].[_request_create_dt],[Source].[_request_delete_dt],[Source].[_transfer_id],[Source].[_record_dt],[Source].[_record_user])
	WHEN NOT MATCHED BY SOURCE THEN 
	 DELETE
	;
	SET IDENTITY_INSERT [dbo].[Transfer] ON

	MERGE INTO [dbo].[Transfer] AS [Target]
	USING (VALUES
	  (-1,-1,N'unknown',-1,NULL,NULL,NULL,NULL,-1,NULL,NULL,NULL,NULL,NULL,-1,-1,-1,NULL,'2020-04-04T20:33:28.870',N'')
	) AS [Source] ([transfer_id],[batch_id],[transfer_name],[src_obj_id],[trg_obj_id],[trg_obj_name],[transfer_start_dt],[transfer_end_dt],[status_id],[rec_cnt_src],[rec_cnt_new],[rec_cnt_changed],[rec_cnt_deleted],[rec_cnt_undeleted],[last_error_id],[prev_transfer_id],[transfer_seq],[guid],[_record_dt],[_record_user])
	ON ([Target].[transfer_id] = [Source].[transfer_id])
	WHEN MATCHED AND (
		NULLIF([Source].[batch_id], [Target].[batch_id]) IS NOT NULL OR NULLIF([Target].[batch_id], [Source].[batch_id]) IS NOT NULL OR 
		NULLIF([Source].[transfer_name], [Target].[transfer_name]) IS NOT NULL OR NULLIF([Target].[transfer_name], [Source].[transfer_name]) IS NOT NULL OR 
		NULLIF([Source].[src_obj_id], [Target].[src_obj_id]) IS NOT NULL OR NULLIF([Target].[src_obj_id], [Source].[src_obj_id]) IS NOT NULL OR 
		NULLIF([Source].[trg_obj_id], [Target].[trg_obj_id]) IS NOT NULL OR NULLIF([Target].[trg_obj_id], [Source].[trg_obj_id]) IS NOT NULL OR 
		NULLIF([Source].[trg_obj_name], [Target].[trg_obj_name]) IS NOT NULL OR NULLIF([Target].[trg_obj_name], [Source].[trg_obj_name]) IS NOT NULL OR 
		NULLIF([Source].[transfer_start_dt], [Target].[transfer_start_dt]) IS NOT NULL OR NULLIF([Target].[transfer_start_dt], [Source].[transfer_start_dt]) IS NOT NULL OR 
		NULLIF([Source].[transfer_end_dt], [Target].[transfer_end_dt]) IS NOT NULL OR NULLIF([Target].[transfer_end_dt], [Source].[transfer_end_dt]) IS NOT NULL OR 
		NULLIF([Source].[status_id], [Target].[status_id]) IS NOT NULL OR NULLIF([Target].[status_id], [Source].[status_id]) IS NOT NULL OR 
		NULLIF([Source].[rec_cnt_src], [Target].[rec_cnt_src]) IS NOT NULL OR NULLIF([Target].[rec_cnt_src], [Source].[rec_cnt_src]) IS NOT NULL OR 
		NULLIF([Source].[rec_cnt_new], [Target].[rec_cnt_new]) IS NOT NULL OR NULLIF([Target].[rec_cnt_new], [Source].[rec_cnt_new]) IS NOT NULL OR 
		NULLIF([Source].[rec_cnt_changed], [Target].[rec_cnt_changed]) IS NOT NULL OR NULLIF([Target].[rec_cnt_changed], [Source].[rec_cnt_changed]) IS NOT NULL OR 
		NULLIF([Source].[rec_cnt_deleted], [Target].[rec_cnt_deleted]) IS NOT NULL OR NULLIF([Target].[rec_cnt_deleted], [Source].[rec_cnt_deleted]) IS NOT NULL OR 
		NULLIF([Source].[rec_cnt_undeleted], [Target].[rec_cnt_undeleted]) IS NOT NULL OR NULLIF([Target].[rec_cnt_undeleted], [Source].[rec_cnt_undeleted]) IS NOT NULL OR 
		NULLIF([Source].[last_error_id], [Target].[last_error_id]) IS NOT NULL OR NULLIF([Target].[last_error_id], [Source].[last_error_id]) IS NOT NULL OR 
		NULLIF([Source].[prev_transfer_id], [Target].[prev_transfer_id]) IS NOT NULL OR NULLIF([Target].[prev_transfer_id], [Source].[prev_transfer_id]) IS NOT NULL OR 
		NULLIF([Source].[transfer_seq], [Target].[transfer_seq]) IS NOT NULL OR NULLIF([Target].[transfer_seq], [Source].[transfer_seq]) IS NOT NULL OR 
		NULLIF([Source].[guid], [Target].[guid]) IS NOT NULL OR NULLIF([Target].[guid], [Source].[guid]) IS NOT NULL OR 
		NULLIF([Source].[_record_dt], [Target].[_record_dt]) IS NOT NULL OR NULLIF([Target].[_record_dt], [Source].[_record_dt]) IS NOT NULL OR 
		NULLIF([Source].[_record_user], [Target].[_record_user]) IS NOT NULL OR NULLIF([Target].[_record_user], [Source].[_record_user]) IS NOT NULL) THEN
	 UPDATE SET
	  [batch_id] = [Source].[batch_id], 
	  [transfer_name] = [Source].[transfer_name], 
	  [src_obj_id] = [Source].[src_obj_id], 
	  [trg_obj_id] = [Source].[trg_obj_id], 
	  [trg_obj_name] = [Source].[trg_obj_name], 
	  [transfer_start_dt] = [Source].[transfer_start_dt], 
	  [transfer_end_dt] = [Source].[transfer_end_dt], 
	  [status_id] = [Source].[status_id], 
	  [rec_cnt_src] = [Source].[rec_cnt_src], 
	  [rec_cnt_new] = [Source].[rec_cnt_new], 
	  [rec_cnt_changed] = [Source].[rec_cnt_changed], 
	  [rec_cnt_deleted] = [Source].[rec_cnt_deleted], 
	  [rec_cnt_undeleted] = [Source].[rec_cnt_undeleted], 
	  [last_error_id] = [Source].[last_error_id], 
	  [prev_transfer_id] = [Source].[prev_transfer_id], 
	  [transfer_seq] = [Source].[transfer_seq], 
	  [guid] = [Source].[guid], 
	  [_record_dt] = [Source].[_record_dt], 
	  [_record_user] = [Source].[_record_user]
	WHEN NOT MATCHED BY TARGET THEN
	 INSERT([transfer_id],[batch_id],[transfer_name],[src_obj_id],[trg_obj_id],[trg_obj_name],[transfer_start_dt],[transfer_end_dt],[status_id],[rec_cnt_src],[rec_cnt_new],[rec_cnt_changed],[rec_cnt_deleted],[rec_cnt_undeleted],[last_error_id],[prev_transfer_id],[transfer_seq],[guid],[_record_dt],[_record_user])
	 VALUES([Source].[transfer_id],[Source].[batch_id],[Source].[transfer_name],[Source].[src_obj_id],[Source].[trg_obj_id],[Source].[trg_obj_name],[Source].[transfer_start_dt],[Source].[transfer_end_dt],[Source].[status_id],[Source].[rec_cnt_src],[Source].[rec_cnt_new],[Source].[rec_cnt_changed],[Source].[rec_cnt_deleted],[Source].[rec_cnt_undeleted],[Source].[last_error_id],[Source].[prev_transfer_id],[Source].[transfer_seq],[Source].[guid],[Source].[_record_dt],[Source].[_record_user])
	WHEN NOT MATCHED BY SOURCE THEN 
	 DELETE
	;
end