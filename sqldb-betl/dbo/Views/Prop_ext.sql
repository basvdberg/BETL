



/*------------------------------------------------------------------------------------------------
-- BETL, meta data driven ETL generation, licensed under GNU GPL https://github.com/basvdberg/BETL 
--------------------------------------------------------------------------------------------------
-- 2017-01-01 BvdB properties per object

select * 
from dbo.prop_ext pe 
where property = 'include'

*/

CREATE VIEW [dbo].[Prop_ext]
AS

SELECT        
--o.obj_id, o.obj_type, o.obj_name, o.srv, o.db, o.[schema_name], o.table_or_view
o.obj_id, o.obj_type, o.full_obj_name
, o._delete_dt
 , p.property_id , p.property_name property, pv.value
 -- inheritance: take first not null value starting from leave and moving up the obj tree
 , coalesce(pv.value, pv_parent.value, pv_grand_parent.value , pv_great_grand_parent.value ) inherited_value 
 
 , p.default_value, p.property_scope
 , pv.record_dt 
 , pv_parent.value parent_value
 , pv_grand_parent.value  grand_parent_value
 , pv_great_grand_parent.value  great_grand_parent_value 

FROM dbo.Obj_ext_all AS o 
INNER JOIN static.Property AS p 
	ON o.obj_type = 'table' AND p.apply_table = 1 
	OR o.obj_type = 'view' AND p.apply_view = 1 
	OR o.obj_type = 'schema' AND p.apply_schema = 1 
	OR o.obj_type = 'database' AND p.apply_db = 1 
	OR o.obj_type = 'server' AND p.apply_srv = 1 
	OR o.obj_type = 'user' and p.[property_scope] = 'user' 
LEFT OUTER JOIN dbo.Property_Value AS pv ON pv.property_id = p.property_id AND pv.obj_id = o.obj_id
LEFT OUTER JOIN dbo.Property_Value AS pv_parent ON pv_parent.property_id = p.property_id AND pv_parent.obj_id = o.parent_id
LEFT OUTER JOIN dbo.Property_Value AS pv_grand_parent ON pv_grand_parent.property_id = p.property_id AND pv_grand_parent.obj_id = o.grand_parent_id
LEFT OUTER JOIN dbo.Property_Value AS pv_great_grand_parent ON pv_great_grand_parent.property_id = p.property_id AND pv_great_grand_parent.obj_id = o.great_grand_parent_id
where p.enabled=1