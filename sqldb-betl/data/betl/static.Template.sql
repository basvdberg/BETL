--EXEC sp_generate_merge @schema = 'static', @table_name ='Template'
SET NOCOUNT ON

MERGE INTO [static].[Template] AS [Target]
USING (VALUES
  (-1,N'unknown',NULL,NULL,'2019-11-19T18:14:22.970',N'')
 ,(1000,N'staging_create_view_h',N'-- begin staging_create_view_h {{schema_name}}.{{obj_name}}[{{obj_id}}]
IF OBJECT_ID(''{{schema_name}}.{{obj_name}}_h'', ''V'') IS NULL
exec sp_executesql N''
CREATE VIEW {{schema_name}}.{{obj_name}}_h AS
SELECT
{{#each columns}}
	{{#if data_type in (''''XML'''')}}convert(nvarchar(max),{{/endif}}
	[{{column_name}}] {{#if data_type in (''''XML'''')}}) [{{column_name}}]{{/endif}}
	{{#unless @last}},{{/unless}}
{{/each}}
FROM {{schema_name}}.[{{obj_name}}]
''
-- end staging_create_view_h {{schema_name}}.{{obj_name}}[{{obj_id}}]
',N'this view can be used for transformation between staging and rdw. e.g. xml columns are transformed into nvarchar(max)','2020-03-25T10:27:42.713',N'')
 ,(2000,N'rdw_create_table',N'-- begin rdw_create_table rdw.{{obj_name}}[{{obj_id}}]
IF OBJECT_ID(''rdw.{{obj_name}}'', ''U'') IS NULL 
	CREATE TABLE rdw.{{obj_name}} (
	{{#each columns}}
		[{{column_name}}] {{data_type}}{{data_size}} {{is_nullable}} {{default_value}}{{#unless @last}},{{/unless}}
	{{/each}}
	)

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = N''PK_rdw_{{obj_name}}_{{obj_id}}'')
ALTER TABLE rdw.{{obj_name}} ADD CONSTRAINT
	PK_rdw_{{obj_name}}_{{obj_id}} PRIMARY KEY CLUSTERED 
	(
	{{#each columns}}
		{{#if primary_key_sorting}}
			[{{column_name}}] {{primary_key_sorting}}
			{{#unless @last}},{{/unless}}
		{{/if}}
	{{/each}}
	) 
-- end rdw_create_table rdw.{{obj_name}}[{{obj_id}}]',N'this template is used e.g. to generate create table DDL from objects in the object tree','2020-03-11T10:42:01.060',N'')
 ,(2010,N'drop_and_create_latest_view',N'-- begin {{template_name}} {{schema_name}}.{{obj_name}}[{{obj_id}}]  

DROP VIEW IF EXISTS {{schema_name}}.[{{obj_name}}]

exec sp_executesql N''
CREATE VIEW {{schema_name}}.[{{obj_name}}] AS 
SELECT 
{{#each columns}}
	[{{column_name}}]{{#unless @last}},{{/unless}}
{{/each}}
FROM {{src_schema_name}}.[{{src_obj_name}}] h
WHERE h._delete_dt is null  -- do not show deleted records in latest view
and h._eff_dt = ( 
		select max(_eff_dt) max_eff_dt
		FROM {{src_schema_name}}.[{{src_obj_name}}] latest
		where 
		{{#each columns}}
		{{#if column_type_id in (100)}}
			h.[{{column_name}}] = latest.[{{column_name}}]{{#unless @last}}AND{{/unless}}
		{{/if}}
		{{/each}}
	) 
''
-- end {{template_name}} {{schema_name}}.{{obj_name}}[{{obj_id}}]  

',N'the latest view shows only the latest record in transaction time (e.g. having the max _Eff_dt ) ','2020-03-23T19:25:13.690',N'')
 ,(2020,N'drop_and_create_latest_view_sur_key',N'-- begin {{template_name}} {{schema_name}}.{{obj_name}}[{{obj_id}}]  
DROP VIEW IF EXISTS {{schema_name}}.[{{obj_name}}]

exec sp_executesql N''
CREATE VIEW {{schema_name}}.[{{obj_name}}] AS 
SELECT 
{{#each columns}}
	[{{column_name}}]{{#unless @last}},{{/unless}}
{{/each}}
FROM {{src_schema_name}}.[{{src_obj_name}}] h
WHERE h._delete_dt is null  -- do not show deleted records in latest view
and h._eff_dt = ( 
		select max(_eff_dt) max_eff_dt
		FROM {{src_schema_name}}.[{{src_obj_name}}] latest
		where 
		{{#each columns}}
		{{#if column_type_id in (200)}}
			h.[{{column_name}}] = latest.[{{column_name}}]{{#unless @last}}AND{{/unless}}
		{{/if}}
		{{/each}}
	) 
''
-- end {{template_name}} {{schema_name}}.{{obj_name}}[{{obj_id}}] ',NULL,'2020-07-01T11:01:30.497',N'')
 ,(3000,N'create_table_if_not_exists',N'-- begin create_table_if_not_exists {{schema_name}}.{{obj_name}}[{{obj_id}}]
IF OBJECT_ID(''{{schema_name}}.{{obj_name}}'', ''U'') IS NULL 
	CREATE TABLE {{schema_name}}.{{obj_name}} (
	{{#each columns}}
		[{{column_name}}] {{data_type}}{{data_size}} {{is_nullable}} {{default_value}}{{#unless @last}},{{/unless}}
	{{/each}}
	)


if len(''{{#each columns}}{{#if primary_key_sorting}}*{{/if}}{{/each}}'') > 0 
	exec sp_executesql N''
		IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = N''''PK_{{schema_name}}_{{obj_name}}_{{obj_id}}'''')
		ALTER TABLE {{schema_name}}.{{obj_name}} ADD CONSTRAINT
			PK_{{schema_name}}_{{obj_name}}_{{obj_id}} PRIMARY KEY CLUSTERED 
			(
			{{#each columns}}
				{{#if primary_key_sorting}}
					[{{column_name}}] {{primary_key_sorting}}
					{{#unless @last}},{{/unless}}
				{{/if}}
			{{/each}}
			) 
		''
-- end create_table_if_not_exists  {{schema_name}}.{{obj_name}}[{{obj_id}}]

',N'create table ddl','2020-04-03T12:24:28.643',N'')
 ,(3100,N'create_staging_view_if_not_exists',N'-- begin create_view_if_not_exists {{schema_name}}.{{obj_name}}[{{obj_id}}] {{src_obj_id}}
IF OBJECT_ID(''{{schema_name}}.{{obj_name}}'', ''V'') IS NULL
exec sp_executesql N''
CREATE VIEW {{schema_name}}.{{obj_name}} AS
SELECT
{{#each columns}}
	[{{column_name}}] as [{{column_name}}]
	{{#unless @last}},{{/unless}}
{{/each}}
FROM {{src_schema_name}}.[{{src_obj_name}}]
''
-- end create_view_if_not_exists {{schema_name}}.{{obj_name}}[{{obj_id}}] {{src_obj_id}}
',N'create view ddl','2020-04-03T17:35:35.340',N'')
 ,(3200,N'drop_and_create_table',N'-- begin drop_and_create_table {{schema_name}}.{{obj_name}}[{{obj_id}}]
IF OBJECT_ID(''{{schema_name}}.{{obj_name}}'', ''U'') IS NOT NULL 
	DROP TABLE {{schema_name}}.{{obj_name}} 

CREATE TABLE {{schema_name}}.{{obj_name}} (
	{{#each columns}}
		[{{column_name}}] {{data_type}}{{data_size}} {{is_nullable}} {{default_value}}{{#unless @last}},{{/unless}}
	{{/each}}
	)


if len(''{{#each columns}}{{#if primary_key_sorting}}*{{/if}}{{/each}}'') > 0 
	exec sp_executesql N''
		IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = N''''PK_{{schema_name}}_{{obj_name}}_{{obj_id}}'''')
		ALTER TABLE {{schema_name}}.{{obj_name}} ADD CONSTRAINT
			PK_{{schema_name}}_{{obj_name}}_{{obj_id}} PRIMARY KEY CLUSTERED 
			(
			{{#each columns}}
				{{#if primary_key_sorting}}
					[{{column_name}}] {{primary_key_sorting}}
					{{#unless @last}},{{/unless}}
				{{/if}}
			{{/each}}
			) 
		''
-- end drop_and_create_table{{schema_name}}.{{obj_name}}[{{obj_id}}]

',N'drop and create table','2020-04-04T09:03:55.033',N'')
 ,(3210,N'drop_and_create_staging_table',N'-- begin drop_and_create_table {{schema_name}}.{{obj_name}}[{{obj_id}}]
IF OBJECT_ID(''{{schema_name}}.{{obj_name}}'', ''U'') IS NOT NULL 
	DROP TABLE {{schema_name}}.{{obj_name}} 

CREATE TABLE {{schema_name}}.{{obj_name}} (
	{{#each columns}}
		[{{column_name}}] {{data_type}}{{data_size}} {{is_nullable}} {{default_value}}{{#unless @last}},{{/unless}}
	{{/each}}
	)

-- for staging tables we do not create a primary key. 

-- end drop_and_create_staging_table{{schema_name}}.{{obj_name}}[{{obj_id}}]

',N'no pkey. because uniqueness is handled in rdw','2020-04-04T09:11:00.517',N'')
 ,(3300,N'drop_and_create_staging_view',N'-- begin drop_and_create_staging_view {{schema_name}}.{{obj_name}}[{{obj_id}}] {{src_obj_id}}
IF OBJECT_ID(''{{schema_name}}.[{{obj_name}}]'', ''V'') IS NOT NULL
	DROP VIEW {{schema_name}}.[{{obj_name}}]

exec sp_executesql N''
CREATE VIEW {{schema_name}}.[{{obj_name}}] AS
SELECT
{{#each columns}}
	[{{column_name}}] as [{{column_name}}]
	{{#unless @last}},{{/unless}}
{{/each}}
FROM {{src_schema_name}}.[{{src_obj_name}}]
''
-- end drop_and_create_staging_view{{schema_name}}.{{obj_name}}[{{obj_id}}] {{src_obj_id}}
',NULL,'2020-04-04T20:44:12.237',N'')
 ,(3400,N'create_table',N'-- begin create_table {{schema_name}}.{{obj_name}}[{{obj_id}}]
CREATE TABLE {{schema_name}}.{{obj_name}} (
	{{#each columns}}
		[{{column_name}}] {{data_type}}{{data_size}} {{is_nullable}} {{default_value}}{{#unless @last}},{{/unless}}
	{{/each}}
	)


if len(''{{#each columns}}{{#if primary_key_sorting}}*{{/if}}{{/each}}'') > 0 
	exec sp_executesql N''
		IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = N''''PK_{{schema_name}}_{{obj_name}}_{{obj_id}}'''')
		ALTER TABLE {{schema_name}}.{{obj_name}} ADD CONSTRAINT
			PK_{{schema_name}}_{{obj_name}}_{{obj_id}} PRIMARY KEY CLUSTERED 
			(
			{{#each columns}}
				{{#if primary_key_sorting}}
					[{{column_name}}] {{primary_key_sorting}}
					{{#unless @last}},{{/unless}}
				{{/if}}
			{{/each}}
			) 
		''
-- end create_table{{schema_name}}.{{obj_name}}[{{obj_id}}]

',NULL,'2020-04-15T12:53:01.730',N'')
 ,(4000,N'rdw_insert',N'-- begin {{template_name}} {{schema_name}}.{{obj_name}}[{{obj_id}}]  
-- exec [dbo].[parse_handlebars] {{obj_id}}, ''{{template_name}}''
-- obj_id is historic rdw table ( we need access to src and trg)
-- E.g. staging.Customer_exp (src) -> rdw.Customer_h (obj_id) -> rdw.Customer ( trg)

declare @now as datetime = getdate() 


INSERT INTO {{schema_name}}.[{{obj_name}}]( 
{{#each columns}}    
	{{#if column_type_id in (100,105,110,300)}}
	[{{column_name}}]{{#unless @last}},{{/unless}}
	{{/endif}}
{{/each}} 
, _delete_dt
, _eff_dt
, _transfer_id
)
select q.*, @now _eff_dt , {{_transfer_id}} _transfer_id
FROM ( 
	select changed_and_new.*, null delete_dt
	FROM (
		select 
		{{#each columns}}    
			{{#if column_type_id in (100,105,110,300)}}
			[{{column_name}}]{{#unless @last}},{{/unless}}
			{{/endif}}
		{{/each}} 
		FROM {{src_schema_name}}.[{{src_obj_name}}]
		EXCEPT 
		SELECT  
		{{#each columns}}    
			{{#if column_type_id in (100,105,110,300)}}
			[{{column_name}}]{{#unless @last}},{{/unless}}
			{{/endif}}
		{{/each}} 
		FROM {{trg_schema_name}}.[{{trg_obj_name}}]
	) changed_and_new
	union all 

	select deleted.*, @now delete_dt
	FROM (
		select 
		{{#each columns}}    
			{{#if column_type_id in (100,105,110,300)}}
			[{{column_name}}]{{#unless @last}},{{/unless}}
			{{/endif}}
		{{/each}} 
		FROM {{trg_schema_name}}.[{{trg_obj_name}}] trg
		where not exists ( 
			select 1 
			FROM {{src_schema_name}}.[{{src_obj_name}}] src
			where {{#each columns}}{{#if column_type_id in (100,105,110)}}
				src.[{{column_name}}]= trg.[{{column_name}}] {{#unless @last}}AND{{/unless}}
									{{/endif}}
					{{/each}} 
		) 
	) deleted
) q 

select @@rowcount rec_cnt_new
-- end {{template_name}} {{schema_name}}.{{obj_name}}[{{obj_id}}]  
',NULL,'2020-04-20T15:06:01.930',N'')
 ,(5000,N'create_table_if_not_exists_identity',N'-- begin create_table_if_not_exists {{schema_name}}.{{obj_name}}[{{obj_id}}]
IF OBJECT_ID(''{{schema_name}}.{{obj_name}}'', ''U'') IS NULL 
	CREATE TABLE {{schema_name}}.{{obj_name}} (
	{{#each columns}}
		[{{column_name}}] {{data_type}}{{data_size}} {{is_nullable}} {{#if column_type_id in (200)}}identity(1,1){{/if}} {{default_value}}{{#unless @last}},{{/unless}}
	{{/each}}
	)


if len(''{{#each columns}}{{#if primary_key_sorting}}*{{/if}}{{/each}}'') > 0 
	exec sp_executesql N''
		IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = N''''PK_{{schema_name}}_{{obj_name}}_{{obj_id}}'''')
		ALTER TABLE {{schema_name}}.{{obj_name}} ADD CONSTRAINT
			PK_{{schema_name}}_{{obj_name}}_{{obj_id}} PRIMARY KEY CLUSTERED 
			(
			{{#each columns}}
				{{#if primary_key_sorting}}
					[{{column_name}}] {{primary_key_sorting}}
					{{#unless @last}},{{/unless}}
				{{/if}}
			{{/each}}
			) 
		''
-- end create_table_if_not_exists  {{schema_name}}.{{obj_name}}[{{obj_id}}]

',NULL,'2020-06-24T13:47:03.290',N'')
 ,(6000,N'update_idw',N'-- begin {{template_name}} {{schema_name}}.{{obj_name}}[{{obj_id}}]  
-- exec [dbo].[parse_handlebars] {{obj_id}}, ''{{template_name}}''
-- obj_id is the idw target table E.g. idw_imp.Persoon (src) -> idw.Persoon_h (obj_id) -> idw.Persoon (trg: latest view)

declare @now as datetime = getdate() 

INSERT INTO {{schema_name}}.[{{obj_name}}]( 
{{#each columns}}    
	{{#if column_type_id in (100,105,110,300)}}
	[{{column_name}}]{{#unless @last}},{{/unless}}
	{{/endif}}
{{/each}} 
, _delete_dt
, {{src_obj_name}}_sid
, _eff_dt
, _transfer_id
{{#each columns}}    
	{{#if column_type_id in (210}}
,[{{column_name}}]
	{{/endif}}
{{/each}} 
)
select q.*, hub.{{src_obj_name}}_sid,  @now _eff_dt , {{_transfer_id}} _transfer_id
{{#each columns}}
	{{#if column_type_id in (210}}
	, lookup_{{column_name}}.[{{column_name}}]
	{{/endif}}
{{/each}} 

FROM ( 
	select changed_and_new.*, null delete_dt
	FROM (
		select 
		{{#each columns}}    
			{{#if column_type_id in (100,105,110,300)}}
			[{{column_name}}]{{#unless @last}},{{/unless}}
			{{/endif}}
		{{/each}} 
		FROM {{src_schema_name}}.[{{src_obj_name}}]
		EXCEPT 
		SELECT  
		{{#each columns}}    
			{{#if column_type_id in (100,105,110,300)}}
			[{{column_name}}]{{#unless @last}},{{/unless}}
			{{/endif}}
		{{/each}} 
		FROM {{trg_schema_name}}.[{{trg_obj_name}}]
	) changed_and_new
	union all 

	select deleted.*, @now delete_dt
	FROM (
		select 
		{{#each columns}}    
			{{#if column_type_id in (100,105,110,300)}}
			[{{column_name}}]{{#unless @last}},{{/unless}}
			{{/endif}}
		{{/each}} 
		FROM {{trg_schema_name}}.[{{trg_obj_name}}] trg
		where not exists ( 
			select 1 
			FROM {{src_schema_name}}.[{{src_obj_name}}] src
			where {{#each columns}}{{#if column_type_id in (100,105)}}
				src.[{{column_name}}]= trg.[{{column_name}}] {{#unless @last}}AND{{/unless}}
									{{/endif}}
					{{/each}} 
		) 
	) deleted
) q 
left join idw_hub.{{src_obj_name}} hub on 
{{#each columns}}
	{{#if column_type_id in (100,105)}}
					q.[{{column_name}}]= hub.[{{column_name}}] {{#unless @last}}AND{{/unless}}
	{{/endif}}
{{/each}} 
-- lookup fkeys
{{#each columns}}
	{{#if column_type_id in (210)}} 
-- sur_fkey {{column_name}}
		{{#sql column_name arg dbo.fkey_sql}}-- generate fkey_sql
		{{/endsql}}
	{{/endif}}
{{/each}} 

select @@rowcount rec_cnt_new
-- end {{template_name}} {{schema_name}}.{{obj_name}}[{{obj_id}}]  
',NULL,'2020-06-24T15:02:52.530',N'')
 ,(6100,N'update_idw_hub',N'-- begin {{template_name}} {{schema_name}}.{{obj_name}}[{{obj_id}}]  
-- exec [dbo].[parse_handlebars] {{obj_id}}, ''{{template_name}}''
-- obj_id is the idw_hub table 
-- E.g. idw_imp.Persoon (src) -> idw_hub.Persoon (obj_id) 

declare @now as datetime = getdate() 

-- first update the hub. insert all new hubs
INSERT INTO {{schema_name}}.[{{obj_name}}]( 
{{#each columns}}    
	{{#if column_type_id in (100,105)}}
	[{{column_name}}]{{#unless @last}},{{/unless}}
	{{/endif}}
{{/each}} 
, _transfer_id
)

select q.*, {{_transfer_id}} _transfer_id
from ( 
	select distinct 
	{{#each columns}}    
		{{#if column_type_id in (100,105)}}
		[{{column_name}}]{{#unless @last}},{{/unless}}
		{{/endif}}
	{{/each}} 
	FROM {{src_schema_name}}.[{{src_obj_name}}]
	EXCEPT 
	SELECT 
	{{#each columns}}    
		{{#if column_type_id in (100,105)}}
		[{{column_name}}]{{#unless @last}},{{/unless}}
		{{/endif}}
	{{/each}} 
	FROM {{schema_name}}.[{{obj_name}}]
) q 
select @@rowcount rec_cnt_new
-- end {{template_name}} {{schema_name}}.{{obj_name}}[{{obj_id}}]  
',NULL,'2020-06-30T08:23:10.940',N'')
) AS [Source] ([template_id],[template_name],[template_code],[template_description],[_record_dt],[_record_name])
ON ([Target].[template_id] = [Source].[template_id])
WHEN MATCHED AND (
	NULLIF([Source].[template_name], [Target].[template_name]) IS NOT NULL OR NULLIF([Target].[template_name], [Source].[template_name]) IS NOT NULL OR 
	NULLIF([Source].[template_code], [Target].[template_code]) IS NOT NULL OR NULLIF([Target].[template_code], [Source].[template_code]) IS NOT NULL OR 
	NULLIF([Source].[template_description], [Target].[template_description]) IS NOT NULL OR NULLIF([Target].[template_description], [Source].[template_description]) IS NOT NULL OR 
	NULLIF([Source].[_record_dt], [Target].[_record_dt]) IS NOT NULL OR NULLIF([Target].[_record_dt], [Source].[_record_dt]) IS NOT NULL OR 
	NULLIF([Source].[_record_name], [Target].[_record_name]) IS NOT NULL OR NULLIF([Target].[_record_name], [Source].[_record_name]) IS NOT NULL) THEN
 UPDATE SET
  [template_name] = [Source].[template_name], 
  [template_code] = [Source].[template_code], 
  [template_description] = [Source].[template_description], 
  [_record_dt] = [Source].[_record_dt], 
  [_record_name] = [Source].[_record_name]
WHEN NOT MATCHED BY TARGET THEN
 INSERT([template_id],[template_name],[template_code],[template_description],[_record_dt],[_record_name])
 VALUES([Source].[template_id],[Source].[template_name],[Source].[template_code],[Source].[template_description],[Source].[_record_dt],[Source].[_record_name])
WHEN NOT MATCHED BY SOURCE THEN 
 DELETE
;
GO
DECLARE @mergeError int
 , @mergeCount int
SELECT @mergeError = @@ERROR, @mergeCount = @@ROWCOUNT
IF @mergeError != 0
 BEGIN
 PRINT 'ERROR OCCURRED IN MERGE FOR [static].[Template]. Rows affected: ' + CAST(@mergeCount AS VARCHAR(100)); -- SQL should always return zero rows affected
 END
ELSE
 BEGIN
 PRINT '[static].[Template] rows affected by MERGE: ' + CAST(@mergeCount AS VARCHAR(100));
 END
GO

SET NOCOUNT OFF
GO




