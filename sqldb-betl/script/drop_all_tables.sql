select 'drop table '+schema_name(schema_id) + '.'+  name  from sys.tables 
where schema_name(schema_id) <> 'sys'
union all 
select 'drop view '+schema_name(schema_id) + '.'+  name  from sys.views
where schema_name(schema_id) <> 'sys'

