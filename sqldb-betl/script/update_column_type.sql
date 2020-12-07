update col set column_type_id = 100 -- nat_pkey
from dbo.Col_ext  col 
inner join static.Key_column kc on kc.column_name = col.column_name and kc.table_name = col.obj_name 
where col.schema_name= 'staging'
and col.obj_type = 'table'

update col set column_type_id = 100 -- nat_pkey
from dbo.Col_ext  col 
inner join static.Key_column kc on kc.column_name = col.column_name and kc.table_name + '_exp' = col.obj_name 
where col.schema_name= 'staging'
and col.obj_type = 'view'

select @@error error