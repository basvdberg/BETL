/*---------------------------------------------------------------------------------------------
BETL, meta data driven ETL generation, licensed under GNU GPL https://github.com/basvdberg/BETL
-----------------------------------------------------------------------------------------------
-- 2021-03-23 BvdB insert init data into dbo tables. E.g. unknown records. 
*/
-- exec [dbo].[init_meta_data] 
CREATE procedure [dbo].[init_meta_data] as 
begin 
	SET NOCOUNT ON
	
	-- BEGIN dbo.error
	-- EXEC sp_generate_merge @schema = 'dbo', @table_name ='Error'
	SET IDENTITY_INSERT [dbo].[error] ON

	MERGE INTO [dbo].[error] AS [Target]
	USING (VALUES
	  (-1,-1,N'unknown',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2020-02-20T13:15:15.617',NULL)
	) AS [Source] ([error_id],[error_code],[error_msg],[error_line],[error_procedure],[error_procedure_id],[error_execution_id],[error_event_name],[error_severity],[error_state],[error_source],[error_interactive_mode],[error_machine_name],[error_user_name],[batch_id],[record_dt],[record_user])
	ON ([Target].[error_id] = [Source].[error_id])
	WHEN MATCHED AND (
		NULLIF([Source].[error_code], [Target].[error_code]) IS NOT NULL OR NULLIF([Target].[error_code], [Source].[error_code]) IS NOT NULL OR 
		NULLIF([Source].[error_msg], [Target].[error_msg]) IS NOT NULL OR NULLIF([Target].[error_msg], [Source].[error_msg]) IS NOT NULL OR 
		NULLIF([Source].[error_line], [Target].[error_line]) IS NOT NULL OR NULLIF([Target].[error_line], [Source].[error_line]) IS NOT NULL OR 
		NULLIF([Source].[error_procedure], [Target].[error_procedure]) IS NOT NULL OR NULLIF([Target].[error_procedure], [Source].[error_procedure]) IS NOT NULL OR 
		NULLIF([Source].[error_procedure_id], [Target].[error_procedure_id]) IS NOT NULL OR NULLIF([Target].[error_procedure_id], [Source].[error_procedure_id]) IS NOT NULL OR 
		NULLIF([Source].[error_execution_id], [Target].[error_execution_id]) IS NOT NULL OR NULLIF([Target].[error_execution_id], [Source].[error_execution_id]) IS NOT NULL OR 
		NULLIF([Source].[error_event_name], [Target].[error_event_name]) IS NOT NULL OR NULLIF([Target].[error_event_name], [Source].[error_event_name]) IS NOT NULL OR 
		NULLIF([Source].[error_severity], [Target].[error_severity]) IS NOT NULL OR NULLIF([Target].[error_severity], [Source].[error_severity]) IS NOT NULL OR 
		NULLIF([Source].[error_state], [Target].[error_state]) IS NOT NULL OR NULLIF([Target].[error_state], [Source].[error_state]) IS NOT NULL OR 
		NULLIF([Source].[error_source], [Target].[error_source]) IS NOT NULL OR NULLIF([Target].[error_source], [Source].[error_source]) IS NOT NULL OR 
		NULLIF([Source].[error_interactive_mode], [Target].[error_interactive_mode]) IS NOT NULL OR NULLIF([Target].[error_interactive_mode], [Source].[error_interactive_mode]) IS NOT NULL OR 
		NULLIF([Source].[error_machine_name], [Target].[error_machine_name]) IS NOT NULL OR NULLIF([Target].[error_machine_name], [Source].[error_machine_name]) IS NOT NULL OR 
		NULLIF([Source].[error_user_name], [Target].[error_user_name]) IS NOT NULL OR NULLIF([Target].[error_user_name], [Source].[error_user_name]) IS NOT NULL OR 
		NULLIF([Source].[batch_id], [Target].[batch_id]) IS NOT NULL OR NULLIF([Target].[batch_id], [Source].[batch_id]) IS NOT NULL OR 
		NULLIF([Source].[record_dt], [Target].[record_dt]) IS NOT NULL OR NULLIF([Target].[record_dt], [Source].[record_dt]) IS NOT NULL OR 
		NULLIF([Source].[record_user], [Target].[record_user]) IS NOT NULL OR NULLIF([Target].[record_user], [Source].[record_user]) IS NOT NULL) THEN
	 UPDATE SET
	  [error_code] = [Source].[error_code], 
	  [error_msg] = [Source].[error_msg], 
	  [error_line] = [Source].[error_line], 
	  [error_procedure] = [Source].[error_procedure], 
	  [error_procedure_id] = [Source].[error_procedure_id], 
	  [error_execution_id] = [Source].[error_execution_id], 
	  [error_event_name] = [Source].[error_event_name], 
	  [error_severity] = [Source].[error_severity], 
	  [error_state] = [Source].[error_state], 
	  [error_source] = [Source].[error_source], 
	  [error_interactive_mode] = [Source].[error_interactive_mode], 
	  [error_machine_name] = [Source].[error_machine_name], 
	  [error_user_name] = [Source].[error_user_name], 
	  [batch_id] = [Source].[batch_id], 
	  [record_dt] = [Source].[record_dt], 
	  [record_user] = [Source].[record_user]
	WHEN NOT MATCHED BY TARGET THEN
	 INSERT([error_id],[error_code],[error_msg],[error_line],[error_procedure],[error_procedure_id],[error_execution_id],[error_event_name],[error_severity],[error_state],[error_source],[error_interactive_mode],[error_machine_name],[error_user_name],[batch_id],[record_dt],[record_user])
	 VALUES([Source].[error_id],[Source].[error_code],[Source].[error_msg],[Source].[error_line],[Source].[error_procedure],[Source].[error_procedure_id],[Source].[error_execution_id],[Source].[error_event_name],[Source].[error_severity],[Source].[error_state],[Source].[error_source],[Source].[error_interactive_mode],[Source].[error_machine_name],[Source].[error_user_name],[Source].[batch_id],[Source].[record_dt],[Source].[record_user])
	;
	SET IDENTITY_INSERT [dbo].[error] OFF
	-- END dbo.error

	-- begin dbo.Batch
	-- EXEC sp_generate_merge @schema = 'dbo', @table_name ='Batch'
	SET IDENTITY_INSERT [dbo].[Batch] ON
	MERGE INTO [dbo].[Batch] AS [Target]
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
	SET IDENTITY_INSERT [dbo].[Batch] OFF
	-- END dbo.Batch


	-- BEGIN dbo.Transfer
	-- EXEC sp_generate_merge @schema = 'dbo', @table_name ='Transfer'
	SET IDENTITY_INSERT [dbo].[Transfer] ON
	MERGE INTO [dbo].[Transfer] AS [Target]
	USING (VALUES
	  (-1,-1,N'unknown',-1,NULL,NULL,NULL,NULL,-1,NULL,NULL,NULL,NULL,NULL,-1,-1,-1,NULL,'2020-04-04T20:33:28.870',N'')
	) AS [Source] ([batch_id],[batch_id],[transfer_name],[src_obj_id],[trg_obj_id],[trg_obj_name],[transfer_start_dt],[transfer_end_dt],[status_id],[rec_cnt_src],[rec_cnt_new],[rec_cnt_changed],[rec_cnt_deleted],[rec_cnt_undeleted],[last_error_id],[prev_batch_id],[transfer_seq],[guid],[_record_dt],[_record_user])
	ON ([Target].[batch_id] = [Source].[batch_id])
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
		NULLIF([Source].[prev_batch_id], [Target].[prev_batch_id]) IS NOT NULL OR NULLIF([Target].[prev_batch_id], [Source].[prev_batch_id]) IS NOT NULL OR 
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
	  [prev_batch_id] = [Source].[prev_batch_id], 
	  [transfer_seq] = [Source].[transfer_seq], 
	  [guid] = [Source].[guid], 
	  [_record_dt] = [Source].[_record_dt], 
	  [_record_user] = [Source].[_record_user]
	WHEN NOT MATCHED BY TARGET THEN
	 INSERT([batch_id],[batch_id],[transfer_name],[src_obj_id],[trg_obj_id],[trg_obj_name],[transfer_start_dt],[transfer_end_dt],[status_id],[rec_cnt_src],[rec_cnt_new],[rec_cnt_changed],[rec_cnt_deleted],[rec_cnt_undeleted],[last_error_id],[prev_batch_id],[transfer_seq],[guid],[_record_dt],[_record_user])
	 VALUES([Source].[batch_id],[Source].[batch_id],[Source].[transfer_name],[Source].[src_obj_id],[Source].[trg_obj_id],[Source].[trg_obj_name],[Source].[transfer_start_dt],[Source].[transfer_end_dt],[Source].[status_id],[Source].[rec_cnt_src],[Source].[rec_cnt_new],[Source].[rec_cnt_changed],[Source].[rec_cnt_deleted],[Source].[rec_cnt_undeleted],[Source].[last_error_id],[Source].[prev_batch_id],[Source].[transfer_seq],[Source].[guid],[Source].[_record_dt],[Source].[_record_user])
	;
	-- END dbo.Transfer

	-- BEGIN dbo.Obj
	-- EXEC sp_generate_merge @schema = 'dbo', @table_name ='Obj'
	MERGE INTO [dbo].[Obj] AS [Target]
	USING (VALUES
	  (-1,N'unknown',10,NULL,NULL,NULL,-1,NULL,NULL,NULL,NULL,NULL,NULL,Getdate(),suser_sname() )
	 ,(10,N'localhost',50,NULL,NULL,NULL, dbo.server_type(),NULL,NULL,NULL,NULL,NULL,NULL,Getdate(),suser_sname() )
	 ,(20, suser_sname()  ,60, 10,NULL, NULL, dbo.server_type(),NULL,NULL,NULL,NULL,NULL,NULL,Getdate(),suser_sname() )
	) AS [Source] ([obj_id],[obj_name],[obj_type_id],[parent_id],[prefix],[obj_name_no_prefix],[server_type_id],[identifier],[src_obj_id],[external_obj_id],[_create_dt],[_delete_dt],[_batch_id],[_record_dt],[_record_user])
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
		NULLIF([Source].[_batch_id], [Target].[_batch_id]) IS NOT NULL OR NULLIF([Target].[_batch_id], [Source].[_batch_id]) IS NOT NULL OR 
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
	  [_batch_id] = [Source].[_batch_id], 
	  [_record_dt] = [Source].[_record_dt], 
	  [_record_user] = [Source].[_record_user]
	WHEN NOT MATCHED BY TARGET THEN
	 INSERT([obj_id],[obj_name],[obj_type_id],[parent_id],[prefix],[obj_name_no_prefix],[server_type_id],[identifier],[src_obj_id],[external_obj_id],[_create_dt],[_delete_dt],[_batch_id],[_record_dt],[_record_user])
	 VALUES([Source].[obj_id],[Source].[obj_name],[Source].[obj_type_id],[Source].[parent_id],[Source].[prefix],[Source].[obj_name_no_prefix],[Source].[server_type_id],[Source].[identifier],[Source].[src_obj_id],[Source].[external_obj_id],[Source].[_create_dt],[Source].[_delete_dt],[Source].[_batch_id],[Source].[_record_dt],[Source].[_record_user])
	;
	-- END dbo.Obj



end