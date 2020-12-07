select 'select * into dm2.' +name + ' from dm.'+ name 
from sys.views
where schema_name(schema_id) = 'dm'
and name not like '%_h'

select 'insert into dm.' +name + ' select * from rdw.'+ name 
from sys.tables
where schema_name(schema_id) = 'rdw'
and name like '%_h'
