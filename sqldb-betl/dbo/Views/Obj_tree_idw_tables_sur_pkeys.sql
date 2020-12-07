


-- select * from [dbo].[Obj_tree_idw_tables_sur_pkeys] 
CREATE view [dbo].[Obj_tree_idw_tables_sur_pkeys] as 
-- lookup nat_fkeys
-- first we lookup the hub that contains at least the current column as natpkey and if this hub needs more columns then these must also be present. 
-- in set theorie: doorsnede hub natpkeys en idw table = alle hub natpkeys

with intersection as ( 
	select i.obj_name src_obj_name,  i.column_name src_column_name, i.column_type_id src_column_type_id, h.obj_name hub_obj_name, h.column_name hub_column_name, h.column_type_id hub_column_type_id
	, row_number()  over (partition by i.obj_name, h.obj_name order by h.ordinal_position asc ) match_nr
	, hub_nat_pkey_size.[nat_pkey_size] hub_nat_pkey_size
	, i.ordinal_position
	from [dbo].[Obj_tree_idw_table_cols] i
	inner join [dbo].[Obj_tree_idw_hub_cols]  h on i.column_name = h.column_name and h.column_type_id in (100, 105) -- nat_pkey
	inner join dbo.Obj_tree_idw_hubs_nat_pkey_size hub_nat_pkey_size on hub_nat_pkey_size.obj_name = h.obj_name 
	where i.column_type_id in ( 110, 105) 
	and i.obj_name <> h.obj_name -- a nat_fkey is never a parent child relation
	--select * from [dbo].[Obj_tree_idw_tables] i
) 

select src_obj_name , hub_obj_name , hub_obj_name + '_sid' column_name, 210 column_type_id , 1 [is_nullable], 'int' [data_type], null max_len, ordinal_position
--, row_number() over (partition by src_obj_name order by hub_nat_pkey_size desc) take_greatest_nat_pkey_match 
from intersection
where match_nr = hub_nat_pkey_size -- complete match ( all nat_pkeys are present in both tables)
-- order by src_obj_name , hub_obj_name , src_column_name