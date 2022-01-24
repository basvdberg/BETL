--EXEC sp_generate_merge @schema = 'static', @table_name ='Template'
SET NOCOUNT ON

MERGE INTO [static].[Template] AS [Target]
USING (VALUES
  (-1,N'unknown',NULL,NULL,N'ddl','2019-11-19T18:14:22.970',N'')
 ,(500,N'drop_and_create_table',N'-- begin drop_and_create_table {{schema_name}}.{{obj_name}}[{{obj_id}}]
IF OBJECT_ID(''{{schema_name}}.{{obj_name}}'', ''U'') IS NOT NULL 
	DROP TABLE {{schema_name}}.{{obj_name}} 

CREATE TABLE {{schema_name}}.{{obj_name}} (
	{{#each columns}}
		[{{column_name}}] {{data_type}}{{data_size}} {{is_nullable}} {{#if column_type_id in (200)}}IDENTITY{{/if}}{{default_value}}{{#unless @last}},{{/unless}}
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

{{#if _source}}
EXEC sys.sp_addextendedproperty @name=N''_source'', @value=N''{{_source}}'' , @level0type=N''SCHEMA'',@level0name=N''{{schema_name}}'', @level1type=N''TABLE'',@level1name=N''{{obj_name}}''
{{/if}}

{{#if obj_id}}
EXEC sys.sp_addextendedproperty @name=N''obj_def_id'', @value=N''{{obj_id}}'' , @level0type=N''SCHEMA'',@level0name=N''{{schema_name}}'', @level1type=N''TABLE'',@level1name=N''{{obj_name}}''
{{/if}}

{{#if src_obj_id}}
EXEC sys.sp_addextendedproperty @name=N''src_obj_id'', @value=N''{{src_obj_id}}'' , @level0type=N''SCHEMA'',@level0name=N''{{schema_name}}'', @level1type=N''TABLE'',@level1name=N''{{obj_name}}''
{{/if}}

-- end drop_and_create_table{{schema_name}}.{{obj_name}}[{{obj_id}}]
',N'drop and create table',N'ddl','2020-04-04T09:03:55.033',N'')
 ,(505,N'create_table_if_not_exists',N'-- begin create_table_if_not_exists {{schema_name}}.{{obj_name}}[{{obj_id}}]
IF OBJECT_ID(''{{schema_name}}.{{obj_name}}'', ''U'') IS NULL 
BEGIN
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

	{{#if _source}}
	EXEC sys.sp_addextendedproperty @name=N''_source'', @value=N''{{_source}}'' , @level0type=N''SCHEMA'',@level0name=N''{{schema_name}}'', @level1type=N''TABLE'',@level1name=N''{{obj_name}}''
	{{/if}}

	{{#if obj_id}}
	EXEC sys.sp_addextendedproperty @name=N''obj_def_id'', @value=N''{{obj_id}}'' , @level0type=N''SCHEMA'',@level0name=N''{{schema_name}}'', @level1type=N''TABLE'',@level1name=N''{{obj_name}}''
	{{/if}}

	{{#if src_obj_id}}
	EXEC sys.sp_addextendedproperty @name=N''src_obj_id'', @value=N''{{src_obj_id}}'' , @level0type=N''SCHEMA'',@level0name=N''{{schema_name}}'', @level1type=N''TABLE'',@level1name=N''{{obj_name}}''
	{{/if}}
END
-- end create_table_if_not_exists  {{schema_name}}.{{obj_name}}[{{obj_id}}]
',N'create table ddl',N'ddl','2020-04-03T12:24:28.643',N'')
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
',N'this view can be used for transformation between staging and rdw. e.g. xml columns are transformed into nvarchar(max)',N'ddl','2020-03-25T10:27:42.713',N'')
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

',N'the latest view shows only the latest record in transaction time (e.g. having the max _Eff_dt ) ',N'ddl','2020-03-23T19:25:13.690',N'')
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
-- end {{template_name}} {{schema_name}}.{{obj_name}}[{{obj_id}}] ',NULL,N'ddl','2020-07-01T11:01:30.497',N'')
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
',N'create view ddl',N'ddl','2020-04-03T17:35:35.340',N'')
 ,(3300,N'drop_and_create_staging_view',N'-- begin drop_and_create_table {{schema_name}}.{{obj_name}}[{{obj_id}}]
IF OBJECT_ID(''{{schema_name}}.{{obj_name}}'', ''U'') IS NOT NULL 
	DROP TABLE {{schema_name}}.{{obj_name}} 

CREATE TABLE {{schema_name}}.{{obj_name}} (
	{{#each columns}}
		[{{column_name}}] {{data_type}}{{data_size}} {{is_nullable}} {{#if column_type_id in (200)}}IDENTITY{{/if}}{{default_value}}{{#unless @last}},{{/unless}}
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

{{#if _source}}
EXEC sys.sp_addextendedproperty @name=N''_source'', @value=N''{{_source}}'' , @level0type=N''SCHEMA'',@level0name=N''{{schema_name}}'', @level1type=N''TABLE'',@level1name=N''{{obj_name}}''
{{/if}}

{{#if obj_id}}
EXEC sys.sp_addextendedproperty @name=N''obj_def_id'', @value=N''{{obj_id}}'' , @level0type=N''SCHEMA'',@level0name=N''{{schema_name}}'', @level1type=N''TABLE'',@level1name=N''{{obj_name}}''
{{/if}}

{{#if src_obj_id}}
EXEC sys.sp_addextendedproperty @name=N''src_obj_id'', @value=N''{{src_obj_id}}'' , @level0type=N''SCHEMA'',@level0name=N''{{schema_name}}'', @level1type=N''TABLE'',@level1name=N''{{obj_name}}''
{{/if}}

-- end drop_and_create_table{{schema_name}}.{{obj_name}}[{{obj_id}}]
',NULL,N'ddl','2020-04-04T20:44:12.237',N'')
 ,(4000,N'rdw_insert',N'-- begin {{template_name}} {{schema_name}}.{{obj_name}}[{{obj_id}}]  
-- exec [dbo].[parse_handlebars] {{obj_id}}, ''''{{template_name}}''''
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
select q.*, @now _eff_dt , <<_transfer_id>> _transfer_id -- please replace transfer_id runtime 
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
-- end {{template_name}} {{schema_name}}.{{obj_name}}[{{obj_id}}]  ',NULL,N'etl','2020-04-20T15:06:01.930',N'')
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

',NULL,N'ddl','2020-06-24T13:47:03.290',N'')
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
',NULL,N'etl','2020-06-24T15:02:52.530',N'')
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
',NULL,N'etl','2020-06-30T08:23:10.940',N'')
 ,(6200,N'obj_tree_ms_sql_server',N'-- get all databases, schemas, tables, views and columns. 
select 
	null src_obj_id
	, isnull(o.object_id, db.database_id) external_obj_id 
	,  case 
		when SERVERPROPERTY(''EngineEdition'') < 4 then 15 -- on premise
		when SERVERPROPERTY(''EngineEdition'') >= 5 then 10 -- azure
	  end  server_type_id
	, @@SERVERNAME server_name 
	, db.name db_name
	, s.name [schema_name]
	, o.name as obj_name 
	, case 
			when o.type = ''U'' then 10 
			when o.type = ''V'' then 20 
			when s.name is not null then 30
			when db.name is not null then 40 
			else 50 -- server
	  end obj_type_id 
	, c.column_id ordinal_position
	, c.name column_name
	, null column_type_id
	, convert(int, c.is_nullable) is_nullable
	, t.name data_type   
	, case when t.name in (''nvarchar'', ''nchar'') then c.max_length /2 else c.max_length end max_len
	, case when t.name in (''decimal'', ''numeric'') then c.precision else cast(null as int) end numeric_precision
	, case when t.name in (''decimal'', ''numeric'') then ODBCSCALE(c.system_type_id, c.scale) else cast(null as int) end numeric_scale
	, case when ic.is_descending_key=0 then ''ASC''when ic.is_descending_key=1 then ''DESC''else null end [primary_key_sorting]
	, convert(nvarchar(4000),  
	  OBJECT_DEFINITION(c.default_object_id))   AS [default_value]
	, null _source
from
	sys.databases db
	full outer join sys.schemas s on db.database_id = db_id()
	left join sys.objects o on o.schema_id = s.schema_id
	and o.type in ( ''U'',''V'') -- only tables and views
	and o.object_id not in 
		(
		select major_id 
		from sys.extended_properties  
		where name = N''microsoft_database_tools_support'' 
		and minor_id = 0 and class = 1) -- exclude ssms diagram objects
	left join sys.columns c on c.object_id = o.object_id 
	left join sys.types t on c.user_type_id = t.user_type_id 
	--  = s.name and col.table_name = o.name
	--	left join sys.columns col on 
	--col.table_schema = s.name 
		--and col.table_name = o.name 
		--and col.COLUMN_NAME=c.name
	left join sys.indexes i on 
		i.object_id = o.object_id 
		and i.is_primary_key = 1
	left join sys.index_columns ic on 
		ic.object_id = o.object_id 
		and ic.column_id = c.column_id
where 
	isnull(s.name,'''') not in ( ''sys'', ''INFORMATION_SCHEMA'', ''guest'') 
	and isnull(s.name,'''') not like ''db[_]%''
	and db.name not in (''master'',''model'',''msdb'',''tempdb'')
-- add users
union all 

select null src_obj_id
	, suser_sid() external_obj_id
	,  case 
		when SERVERPROPERTY(''EngineEdition'') < 4 then 15 -- on premise
		when SERVERPROPERTY(''EngineEdition'') >= 5 then 10 -- azure
	  end  server_type 
	, @@SERVERNAME server_name 
	, db_name() db_name
	, null [schema_name]
	, suser_sname()  obj_name
	, 60 obj_type_id -- user
	, null ordinal_position
	, null column_name
	, null column_type_id
	, null is_nullable
	, null data_type
	, null
	, null
	, null
	, null
	, null
	, null
',NULL,N'ddl','2021-03-29T21:07:28.417',N'AzureAD\BasvandenBerg')
 ,(6250,N'obj_tree_ms_sql_server_db_param',N'-- begin {{template_name}} {{schema_name}}.{{obj_name}}[{{obj_id}}]  
-- exec [dbo].[parse_handlebars] {{obj_id}}, ''{{template_name}}''

select 
	null src_obj_id
	, isnull(o.object_id, db.database_id) external_obj_id 
	,  dbo.server_type() server_type 
	, @@SERVERNAME server_name 
	, db.name db_name
	, s.name [schema_name]
	, o.name as obj_name 
	, case 
			when o.type = ''U'' then 10 
			when o.type = ''V'' then 20 
			when s.name is not null then 30
			when db.name is not null then 40 
			else 50 -- server
	  end obj_type_id 
	, c.column_id ordinal_position
	, c.name column_name
	, null column_type_id
	, c.is_nullable is_nullable
	, t.name data_type 
	, c.max_length max_len
	--, case when DATA_TYPE in (''int'', ''bigint'', ''smallint'', ''tinyint'', ''bit'') then cast(null as int) else numeric_precision end numeric_precision
	, convert(tinyint, CASE -- int/decimal/numeric/real/float/money  
	  WHEN c.system_type_id IN (48, 52, 56, 59, 60, 62, 106, 108, 122, 127) THEN c.precision  
	  END)          AS NUMERIC_PRECISION
	, convert(int, CASE -- datetime/smalldatetime  
	  WHEN c.system_type_id IN (40, 41, 42, 43, 58, 61) THEN NULL  
	  ELSE ODBCSCALE(c.system_type_id, c.scale) END) AS NUMERIC_SCALE
	, case when ic.is_descending_key=0 then ''ASC''when ic.is_descending_key=1 then ''DESC''else null end [primary_key_sorting]
	, convert(nvarchar(4000),  
	  OBJECT_DEFINITION(c.default_object_id))   AS [default_value]
	, null _source
from 
	{{db_name}}.sys.databases db
	full outer join {{db_name}}.sys.schemas s on db.database_id = db_id()
	left join {{db_name}}.sys.objects o on o.schema_id = s.schema_id
	and o.type in ( ''U'',''V'') -- only tables and views
	and o.object_id not in 
		(
		select major_id 
		from {{db_name}}.sys.extended_properties  
		where name = N''microsoft_database_tools_support'' 
		and minor_id = 0 and class = 1) -- exclude ssms diagram objects
	left join {{db_name}}.sys.columns c on c.object_id = o.object_id 
	left join {{db_name}}.sys.types t on c.user_type_id = t.user_type_id 
	--  = s.name and col.table_name = o.name
	--	left join {{db_name}}.sys.columns col on 
	--col.table_schema = s.name 
		--and col.table_name = o.name 
		--and col.COLUMN_NAME=c.name
	left join {{db_name}}.sys.indexes i on 
		i.object_id = o.object_id 
		and i.is_primary_key = 1
	left join {{db_name}}.sys.index_columns ic on 
		ic.object_id = o.object_id 
		and ic.column_id = c.column_id
where 
	isnull(s.name,'''') not in ( ''sys'', ''INFORMATION_SCHEMA'', ''guest'') 
	and isnull(s.name,'''') not like ''db[_]%''
	and db.name not in (''master'',''model'',''msdb'',''tempdb'')

union all 

select null, suser_sid()
	,  dbo.server_type()
	, @@SERVERNAME server_name 
	, db_name()
	, null
	, suser_sname() 
	, 60 -- user
	, null
	, null
	, null
	, null
	, null
	, null
	, null
	, null
	, null
	, null
	, null
-- end {{template_name}} {{schema_name}}.{{obj_name}}[{{obj_id}}]  
```
',NULL,N'ddl','2021-07-07T15:19:36.110',N'sa_sqls-betl-dev')
 ,(6300,N'ingest_obj_tree_ms_sql_server',N'-- begin {{template_name}} {{schema_name}}.{{obj_name}}[{{obj_id}}]  
-- exec [dbo].[parse_handlebars] {{obj_id}}, ''{{template_name}}''

declare @obj_tree_param ObjTreeTableParam 

with obj_tree_query as ( 
	select 
		null src_obj_id
		, isnull(o.object_id, db.database_id) external_obj_id 
		,  dbo.server_type() server_type 
		, @@SERVERNAME server_name 
		, db.name db_name
		, s.name [schema_name]
		, o.name as obj_name 
		, case 
				when o.type = ''U'' then 10 
				when o.type = ''V'' then 20 
				when s.name is not null then 30
				when db.name is not null then 40 
				else 50 -- server
		  end obj_type_id 
		, c.column_id ordinal_position
		, c.name column_name
		, null column_type_id
		, c.is_nullable is_nullable
		, t.name data_type 
		, c.max_length max_len
		--, case when DATA_TYPE in (''int'', ''bigint'', ''smallint'', ''tinyint'', ''bit'') then cast(null as int) else numeric_precision end numeric_precision
		, convert(tinyint, CASE -- int/decimal/numeric/real/float/money  
		  WHEN c.system_type_id IN (48, 52, 56, 59, 60, 62, 106, 108, 122, 127) THEN c.precision  
		  END)          AS NUMERIC_PRECISION
		, convert(int, CASE -- datetime/smalldatetime  
		  WHEN c.system_type_id IN (40, 41, 42, 43, 58, 61) THEN NULL  
		  ELSE ODBCSCALE(c.system_type_id, c.scale) END) AS NUMERIC_SCALE
		, case when ic.is_descending_key=0 then ''ASC''when ic.is_descending_key=1 then ''DESC''else null end [primary_key_sorting]
		, convert(nvarchar(4000),  
		  OBJECT_DEFINITION(c.default_object_id))   AS [default_value]
		, null _source
	from 
		{{db_name}}.sys.databases db
		left join {{db_name}}.sys.schemas s on db.name = ''{{db_name}}''
		left join {{db_name}}.sys.objects o on o.schema_id = s.schema_id
		and o.type in ( ''U'',''V'') -- only tables and views
		and o.object_id not in 
			(
			select major_id 
			from {{db_name}}.sys.extended_properties  
			where name = N''microsoft_database_tools_support'' 
			and minor_id = 0 and class = 1) -- exclude ssms diagram objects
		left join {{db_name}}.sys.columns c on c.object_id = o.object_id 
		left join {{db_name}}.sys.types t on c.user_type_id = t.user_type_id 
		--  = s.name and col.table_name = o.name
		--	left join {{db_name}}.sys.columns col on 
		--col.table_schema = s.name 
			--and col.table_name = o.name 
			--and col.COLUMN_NAME=c.name
		left join {{db_name}}.sys.indexes i on 
			i.object_id = o.object_id 
			and i.is_primary_key = 1
		left join {{db_name}}.sys.index_columns ic on 
			ic.object_id = o.object_id 
			and ic.column_id = c.column_id
	where 
		isnull(s.name,'''') not in ( ''sys'', ''INFORMATION_SCHEMA'', ''guest'') 
		and isnull(s.name,'''') not like ''db[_]%''
		and db.name not in (''master'',''model'',''msdb'',''tempdb'')

	union all 

	select null, suser_sid()
		,  dbo.server_type()
		, @@SERVERNAME server_name 
		, ''{{db_name}}''
		, null
		, suser_sname() 
		, 60 -- user
		, null
		, null
		, null
		, null
		, null
		, null
		, null
		, null
		, null
		, null
		, null
) 

insert into @obj_tree_param 
select  *
from obj_tree_query

exec [dbo].[ingest_obj_tree] @obj_tree_param

-- end {{template_name}} {{schema_name}}.{{obj_name}}[{{obj_id}}]  
',NULL,N'ddl','2021-03-29T21:37:10.250',N'AzureAD\BasvandenBerg')
 ,(6400,N'create_schema',N'-- begin {{template_name}} {{schema_name}}.{{obj_name}}[{{obj_id}}]  
-- exec [dbo].[parse_handlebars] {{obj_id}}, ''{{template_name}}''

IF NOT EXISTS ( SELECT  *
                FROM    sys.schemas
                WHERE   name = N''{{obj_name}}'' )
    EXEC(''CREATE SCHEMA [{{obj_name}}]'')

-- end {{template_name}} {{schema_name}}.{{obj_name}}[{{obj_id}}]  

',NULL,N'ddl','2021-12-08T18:14:20.923',N'bas@c2h.nl')
) AS [Source] ([template_id],[template_name],[template_code],[template_description],[template_type],[_record_dt],[_record_name])
ON ([Target].[template_id] = [Source].[template_id])
WHEN MATCHED AND (
	NULLIF([Source].[template_name], [Target].[template_name]) IS NOT NULL OR NULLIF([Target].[template_name], [Source].[template_name]) IS NOT NULL OR 
	NULLIF([Source].[template_code], [Target].[template_code]) IS NOT NULL OR NULLIF([Target].[template_code], [Source].[template_code]) IS NOT NULL OR 
	NULLIF([Source].[template_description], [Target].[template_description]) IS NOT NULL OR NULLIF([Target].[template_description], [Source].[template_description]) IS NOT NULL OR 
	NULLIF([Source].[template_type], [Target].[template_type]) IS NOT NULL OR NULLIF([Target].[template_type], [Source].[template_type]) IS NOT NULL OR 
	NULLIF([Source].[_record_dt], [Target].[_record_dt]) IS NOT NULL OR NULLIF([Target].[_record_dt], [Source].[_record_dt]) IS NOT NULL OR 
	NULLIF([Source].[_record_name], [Target].[_record_name]) IS NOT NULL OR NULLIF([Target].[_record_name], [Source].[_record_name]) IS NOT NULL) THEN
 UPDATE SET
  [template_name] = [Source].[template_name], 
  [template_code] = [Source].[template_code], 
  [template_description] = [Source].[template_description], 
  [template_type] = [Source].[template_type], 
  [_record_dt] = [Source].[_record_dt], 
  [_record_name] = [Source].[_record_name]
WHEN NOT MATCHED BY TARGET THEN
 INSERT([template_id],[template_name],[template_code],[template_description],[template_type],[_record_dt],[_record_name])
 VALUES([Source].[template_id],[Source].[template_name],[Source].[template_code],[Source].[template_description],[Source].[template_type],[Source].[_record_dt],[Source].[_record_name])
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

