--EXEC sp_generate_merge @schema = 'static', @table_name ='Property'
SET NOCOUNT ON

MERGE INTO [static].[Property] AS [Target]
USING (VALUES
  (-1,N'unknown',0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2019-11-19T18:13:35.830',N'')
 ,(10,N'target_schema_name',0,N'This is used by push for determining where to copy the data to. use this pattern: <db_name>.<schema_name> or <server_name>.<db_name>.<schema_name> if the first is ambiguous',N'db_object',NULL,1,1,1,1,NULL,'2015-08-31T13:18:22.073',N'')
 ,(15,N'template_name_create_table',1,N'which ETL template to use for creating tables (see static.Template) ',N'db_object',NULL,0,0,1,0,NULL,'2017-09-07T09:12:49.160',N'')
 ,(16,N'template_name_create_view',1,N'which ETL template to use for creating views (see static.Template) ',N'db_object',NULL,0,0,1,0,NULL,'2020-05-19T14:33:26.270',N'')
 ,(17,N'template_name_update_table',1,N'which ETL template to use for copying data into tables (see static.Template) ',N'db_object',NULL,0,0,1,0,NULL,'2020-05-19T14:39:51.060',N'')
 ,(20,N'has_synonym_id',0,N'apply syn pattern',N'db_object',NULL,0,0,0,1,NULL,'2015-08-31T13:18:56.070',N'')
 ,(50,N'is_linked_server',0,N'Should a server be accessed like a linked server (e.g. via openquery). Used for SSAS servers.',N'db_object',NULL,NULL,NULL,NULL,NULL,1,'2015-08-31T17:17:37.830',N'')
 ,(60,N'date_datatype_based_on_suffix',0,N'if a column ends with the suffix _date then it''s a date datatype column (instead of e.g. datetime)',N'db_object',N'1',NULL,NULL,NULL,NULL,1,'2015-09-02T13:16:15.733',N'')
 ,(70,N'is_localhost',0,N'This server is localhost. For performance reasons we don''t want to access localhost via linked server as we would with external sources',N'db_object',N'0',NULL,NULL,NULL,NULL,1,'2015-09-24T16:22:45.233',N'')
 ,(80,N'recreate_tables',0,N'This will drop and create tables (usefull during initial development)',N'db_object',NULL,NULL,NULL,1,1,NULL,NULL,NULL)
 ,(90,N'prefix_length',0,N'This object name uses a prefix of certain length x. Strip this from target name. ',N'db_object',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)
 ,(120,N'exec_sql',1,N'set this to 0 to print the generated sql instead of executing it. usefull for debugging',N'user',N'1',NULL,NULL,NULL,NULL,NULL,'2017-02-02T15:04:49.867',N'')
 ,(130,N'log_level',1,N'controls the amount of logging. ERROR,INFO, DEBUG, VERBOSE',N'user',N'INFO',NULL,NULL,NULL,NULL,NULL,'2017-02-02T15:06:12.167',N'')
 ,(150,N'delete_detection',0,N'detect deleted records',N'db_object',N'1',1,1,1,NULL,NULL,'2017-12-19T14:08:52.533',N'')
 ,(160,N'use_key_domain',0,N'adds key_domain_id to natural primary key of hubs to make key unique for a particular domain. push can derive key_domain e.g.  from source system name',N'db_object',NULL,1,1,NULL,NULL,NULL,'2018-01-09T10:26:57.017',N'')
 ,(170,N'privacy_level',0,N'scale : normal, sensitive, personal',N'db_object',N'10',1,1,NULL,NULL,NULL,'2018-04-09T16:38:43.057',N'')
 ,(180,N'filter_delete_detection',0,N'custom filter for delete detection',N'db_object',NULL,1,1,NULL,NULL,NULL,'2018-07-04T17:27:29.857',N'')
 ,(190,N'proc_max_cnt',0,N'how many concurrent processes / jobs. default 4 ',N'user',N'4',NULL,NULL,NULL,NULL,NULL,'2019-01-23T17:20:03.690',N'')
 ,(200,N'proc_max_wait_time_min',0,N'how long should we wait for a proc to finish when proc_max_cnt is reached. default 10 minutes. please increase this value for big datasets!',N'user',N'10',NULL,NULL,NULL,NULL,NULL,'2019-01-25T12:27:24.543',N'')
 ,(210,N'proc_polling_interval_sec',0,N'wait polling interval. How long till we check again. range: 1-59 . Too low might affect performance because every time we query  msdb.dbo.sysjobs',N'user',N'2',NULL,NULL,NULL,NULL,NULL,'2019-01-25T12:29:17.060',N'')
 ,(220,N'proc_dead_time_sec',0,N'delete jobs that are created more than @proc_dead_time_sec ago and are not running. ',N'user',N'60',NULL,NULL,NULL,NULL,NULL,'2019-01-25T12:40:13.197',N'')
 ,(230,N'batch_max_lifetime',1,N'after this period of inactivity the batch will be seen as dead and will be stopped if running. ',N'user',N'0',NULL,NULL,NULL,NULL,NULL,'2019-11-20T10:26:00.060',N'bas')
 ,(240,N'include_staging',1,N'include this source system table or view in Staging',N'db_object',NULL,1,1,1,1,NULL,'2019-12-04T08:21:22.433',N'')
 ,(250,N'layer',0,N'dwh layer. e.g. staging, rdw, idw, datamart',N'db_object',NULL,NULL,NULL,1,1,NULL,'2019-12-10T18:09:12.287',N'')
 ,(260,N'source',1,N'short name for e.g. a source database. used as prefix in staging',N'db_object',NULL,1,1,1,1,1,'2020-04-03T10:53:39.070',N'')
 ,(270,N'row_filter',1,N'Use this to filter rows in development env so that everything runs faster',N'db_object',NULL,1,NULL,1,NULL,NULL,'2020-06-17T10:06:20.933',N'')
) AS [Source] ([property_id],[property_name],[enabled],[description],[property_scope],[default_value],[apply_table],[apply_view],[apply_schema],[apply_db],[apply_srv],[record_dt],[record_user])
ON ([Target].[property_id] = [Source].[property_id])
WHEN MATCHED AND (
	NULLIF([Source].[property_name], [Target].[property_name]) IS NOT NULL OR NULLIF([Target].[property_name], [Source].[property_name]) IS NOT NULL OR 
	NULLIF([Source].[enabled], [Target].[enabled]) IS NOT NULL OR NULLIF([Target].[enabled], [Source].[enabled]) IS NOT NULL OR 
	NULLIF([Source].[description], [Target].[description]) IS NOT NULL OR NULLIF([Target].[description], [Source].[description]) IS NOT NULL OR 
	NULLIF([Source].[property_scope], [Target].[property_scope]) IS NOT NULL OR NULLIF([Target].[property_scope], [Source].[property_scope]) IS NOT NULL OR 
	NULLIF([Source].[default_value], [Target].[default_value]) IS NOT NULL OR NULLIF([Target].[default_value], [Source].[default_value]) IS NOT NULL OR 
	NULLIF([Source].[apply_table], [Target].[apply_table]) IS NOT NULL OR NULLIF([Target].[apply_table], [Source].[apply_table]) IS NOT NULL OR 
	NULLIF([Source].[apply_view], [Target].[apply_view]) IS NOT NULL OR NULLIF([Target].[apply_view], [Source].[apply_view]) IS NOT NULL OR 
	NULLIF([Source].[apply_schema], [Target].[apply_schema]) IS NOT NULL OR NULLIF([Target].[apply_schema], [Source].[apply_schema]) IS NOT NULL OR 
	NULLIF([Source].[apply_db], [Target].[apply_db]) IS NOT NULL OR NULLIF([Target].[apply_db], [Source].[apply_db]) IS NOT NULL OR 
	NULLIF([Source].[apply_srv], [Target].[apply_srv]) IS NOT NULL OR NULLIF([Target].[apply_srv], [Source].[apply_srv]) IS NOT NULL OR 
	NULLIF([Source].[record_dt], [Target].[record_dt]) IS NOT NULL OR NULLIF([Target].[record_dt], [Source].[record_dt]) IS NOT NULL OR 
	NULLIF([Source].[record_user], [Target].[record_user]) IS NOT NULL OR NULLIF([Target].[record_user], [Source].[record_user]) IS NOT NULL) THEN
 UPDATE SET
  [property_name] = [Source].[property_name], 
  [enabled] = [Source].[enabled], 
  [description] = [Source].[description], 
  [property_scope] = [Source].[property_scope], 
  [default_value] = [Source].[default_value], 
  [apply_table] = [Source].[apply_table], 
  [apply_view] = [Source].[apply_view], 
  [apply_schema] = [Source].[apply_schema], 
  [apply_db] = [Source].[apply_db], 
  [apply_srv] = [Source].[apply_srv], 
  [record_dt] = [Source].[record_dt], 
  [record_user] = [Source].[record_user]
WHEN NOT MATCHED BY TARGET THEN
 INSERT([property_id],[property_name],[enabled],[description],[property_scope],[default_value],[apply_table],[apply_view],[apply_schema],[apply_db],[apply_srv],[record_dt],[record_user])
 VALUES([Source].[property_id],[Source].[property_name],[Source].[enabled],[Source].[description],[Source].[property_scope],[Source].[default_value],[Source].[apply_table],[Source].[apply_view],[Source].[apply_schema],[Source].[apply_db],[Source].[apply_srv],[Source].[record_dt],[Source].[record_user])
WHEN NOT MATCHED BY SOURCE THEN 
 DELETE
;
GO
DECLARE @mergeError int
 , @mergeCount int
SELECT @mergeError = @@ERROR, @mergeCount = @@ROWCOUNT
IF @mergeError != 0
 BEGIN
 PRINT 'ERROR OCCURRED IN MERGE FOR [static].[Property]. Rows affected: ' + CAST(@mergeCount AS VARCHAR(100)); -- SQL should always return zero rows affected
 END
ELSE
 BEGIN
 PRINT '[static].[Property] rows affected by MERGE: ' + CAST(@mergeCount AS VARCHAR(100));
 END
GO

SET NOCOUNT OFF
GO




