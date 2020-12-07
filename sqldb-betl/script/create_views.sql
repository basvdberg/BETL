select 'if object_id(''dm.'+name+''') is null exec(''create view dm.'+name + ' as select * from rdw.'+name + ''')
GO' from sys.views
where schema_name(schema_id) = 'rdw'
select 'if object_id(''dm.'+name+''') is null exec(''create view dm.'+name + ' as select * from rdw.'+name + ''')
GO' from sys.tables
where schema_name(schema_id) = 'rdw'
